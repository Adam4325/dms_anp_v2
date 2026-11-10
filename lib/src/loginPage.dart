import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dms_anp/helpers/sim_phone_guard.dart';
import 'package:dms_anp/src/Helper/MasterDataPreloader.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
import 'package:dms_anp/src/services/FcmAduanService.dart';
import 'package:dms_anp/src/widgets/user_inactivity_scope.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unique_identifier/unique_identifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

/// Debug mode: ketika true dan login pakai fingerprint, tampilkan dialog URL
const bool isDebug = false;

class _LoginPageState extends State<LoginPage> {
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  DateTime? currentBackPressTime;
  TextEditingController TxtUsername = new TextEditingController();
  TextEditingController TxtPassword = new TextEditingController();

  // For password visibility toggle
  bool isPasswordVisible = false;

  // Soft Orange Color Palette
  static const Color primaryOrange = Color(0xFFFF8A50);
  //static const Color lightOrange = Color(0xFFFFA376);
  static const Color veryLightOrange = Color(0xFFFFE4D6);
  static const Color backgroundColor = Color(0xFFFFF5F0);
  static const Color cardBackground = Color(0xFFFEFEFE);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  String? _customBgUrl;

  Future<void> _loadSavedBackground() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cached = prefs.getString('bg_mobile_url');
      if (cached != null && cached.isNotEmpty && mounted) {
        setState(() {
          _customBgUrl = cached;
        });
      }
      final url =
          '${GlobalData.baseUrl}api/menu/api_bg_mobile.jsp?method=get-active-bg';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status_code'] == '200' && data['data'] != null) {
          String urlPic = data['data']['url_picture'] ?? '';
          if (urlPic.isNotEmpty) {
            String fullUrl = urlPic.startsWith('http')
                ? urlPic
                : '${GlobalData.baseUrlOri}$urlPic';
            await prefs.setString('bg_mobile_url', fullUrl);
            if (mounted && fullUrl != _customBgUrl) {
              setState(() {
                _customBgUrl = fullUrl;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error load bg login: $e');
    }
  }

  Future<bool> onWillPop() {
    return Future.value(false);
  }

  String _identifier = '';
  Future<String> initUniqueIdentifierState() async {
    String? identifier;
    try {
      //identifier = "3d011a9d72e23c29"; //await UniqueIdentifier.serial;
      identifier = await UniqueIdentifier.serial;
      if (identifier != null &&
          identifier.isNotEmpty &&
          identifier != 'Failed to get Unique Identifier') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("androidID", identifier);
      }
    } catch (platformException) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      identifier = prefs.getString("androidID");
      if (identifier == null || identifier.isEmpty) {
        identifier = 'Failed to get Unique Identifier';
      }
    }

    if (mounted) {
      setState(() {
        _identifier = identifier ?? '';
      });
    } else {
      _identifier = identifier ?? '';
    }
    return _identifier;
  }

  void showToast(String? message) {
    if (message == null || message == "") return;
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: primaryOrange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Method to authenticate using fingerprint
  Future<void> _authenticate() async {
    try {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Silakan scan sidik jari untuk login',
        persistAcrossBackgrounding: true,
      );

      if (isAuthenticated) {
        await doLogin(context, true);
      } else {
        showToast('Authentication failed!');
      }
    } catch (e) {
      showToast('Error: ${e.toString()}');
      print('Error: ${e.toString()}');
    }
  }

  bool isMenuForeman = false;
  Future<void> getAksesMenuForeMan(imeiid) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //String imeiid = imeiid;//"201b6e7e58fcea51";
    final String baseUrl = GlobalData.baseUrlOri +
        "akses_menu_v1.jsp?method=get-akses-menu-foreman&imeiid=${imeiid}"; // ganti sesuai URL API kamu
    final Uri url = Uri.parse(baseUrl);
    print(baseUrl);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final datas = jsonDecode(response.body);

        if (datas['status_code'] == "200") {
          setState(() {
            isMenuForeman = true;
            print('isMenuForeman ${isMenuForeman}');
          });
        } else {
          print('failed: ${datas['status_code']}');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<bool> _updateImeiOnServer(
      {required String imeiid,
      required String statusKaryawan,
      required String drvid,
      required String kryid,
      String? username}) async {
    try {
      if (imeiid.isEmpty || imeiid == 'Failed to get Unique Identifier') {
        print('update-imeiid skipped: imeiid is empty');
        return false;
      }
      bool isSuccess = false;
      final bool isDriver = statusKaryawan.toLowerCase() == 'driver';
      final String effectiveUser = (username != null && username.isNotEmpty)
          ? username
          : (isDriver ? drvid : (kryid.isNotEmpty ? kryid : drvid));

      // 1. Panggil change_imeiid_user.jsp (aktif di server produksi, mengupdate TBLUSER.LOCID5 & TBLUSERDRIVER)
      try {
        final changeUri = Uri.parse(GlobalData.baseUrl + "api/change_imeiid_user.jsp")
            .replace(queryParameters: {
          'method': 'change-imeiid-v1',
          'id': isDriver ? drvid : effectiveUser,
          'username': effectiveUser,
          'userid': effectiveUser,
          'loginname': isDriver ? 'DRIVER' : 'DISPATCHER',
          'imeiid': imeiid,
        });
        print('change_imeiid url: ${changeUri.toString()}');
        final responseChange =
            await http.get(changeUri).timeout(const Duration(seconds: 7));
        print(
            'change_imeiid statusCode: ${responseChange.statusCode}, body: ${responseChange.body}');
        if (responseChange.statusCode == 200) {
          final resJson = jsonDecode(responseChange.body);
          if (resJson['status_code']?.toString() == '200') {
            isSuccess = true;
          }
        }
      } catch (e) {
        print('change_imeiid exception: $e');
      }

      // 2. Panggil juga update_imeiid.jsp (untuk pembaruan tabel tbldriver / tblkaryawan)
      try {
        final status = isDriver ? 'driver' : 'karyawan';
        final targetId =
            isDriver ? drvid : (kryid.isNotEmpty ? kryid : effectiveUser);
        final baseUrl = GlobalData.baseUrl + "api/imeiid/update_imeiid.jsp";
        final Map<String, String> params = {
          'method': 'update-imeiid-anp',
          'imeiid': imeiid,
          'status': status,
          'id': targetId,
          if (username != null && username.isNotEmpty) 'username': username,
        };
        final uri = Uri.parse(baseUrl).replace(queryParameters: params);
        print('update-imeiid url: ${uri.toString()}');
        final response =
            await http.get(uri).timeout(const Duration(seconds: 7));
        print(
            'update-imeiid statusCode: ${response.statusCode}, body: ${response.body}');
        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body);
          if (resJson['status'] == 'success') {
            isSuccess = true;
          }
        }
      } catch (e) {
        print('update-imeiid exception: $e');
      }

      return isSuccess;
    } catch (e) {
      print('update-imeiid general exception: $e');
      return false;
    }
  }

  Future doLogin(BuildContext context, bool isFinger) async {
    EasyLoading.show();
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      var endpointUrl = GlobalData.baseUrl + "api/authorize_v14.jsp";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = TxtUsername.text.trim();
      String password = TxtPassword.text;
      // Fingerprint: langsung kirim imeiid perangkat tanpa username dan password
      if (isFinger) {
        username = "";
        password = "";
        if (_identifier.isEmpty ||
            _identifier == 'Failed to get Unique Identifier') {
          _identifier = prefs.getString('androidID') ?? '';
        }
        if (_identifier.isEmpty) {
          _identifier = await initUniqueIdentifierState();
        }
        if (_identifier.isEmpty ||
            _identifier == 'Failed to get Unique Identifier') {
          EasyLoading.dismiss();
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(
              ctx,
              0,
              "Device ID (IMEIID) tidak dapat dibaca dari perangkat. Pastikan izin telah diberikan.",
              "error");
          return;
        }
      }
      print('_identifier $_identifier');
      Map<String, String> queryParams = {
        'method': 'authorize-v1',
        'username': username,
        'password': password,
        'imeiid': _identifier,
        'isfinger': isFinger ? "1" : "0"
      };
      print(queryParams);
      print("isFinger ${isFinger ? "1" : "0"}");
      print(endpointUrl);
      var headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      Uri myUri = Uri.parse(requestUrl);

      // Debug: tampilkan dialog URL saat login fingerprint
      if (isFinger && isDebug && mounted) {
        EasyLoading.dismiss();
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Debug - Fingerprint Login'),
            content: SingleChildScrollView(
              child: SelectableText(requestUrl),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy URL'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: requestUrl));
                  showToast('URL disalin ke clipboard');
                },
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        EasyLoading.show();
      }

      var response = await http.get(myUri, headers: headers);
      if (response.statusCode != 200) {
        EasyLoading.dismiss();
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, "Error while fetching data", "error");
      } else {
        var result = _decoder.convert(response.body);
        if (int.parse(result["status_code"]) == 100) {
          EasyLoading.dismiss();
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 0, result["message"], "error");
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var drvid = result["data"][0]["drvid"];
          var photo_driver = result["data"][0]["photo_driver"];
          var mechanicid = result["data"][0]["drvid"];
          var name = result["data"][0]["name"];
          var nickname = result["data"][0]["nickname"];
          var loginname = result["data"][0]["loginname"];
          var vhcid = result["data"][0]["vhcid"];
          var vhcnopol = result["data"][0]["vhcnopol"];
          var locid = result["data"][0]["locid"];
          var akses_page = result["akses"][0];
          var vhckm = result["data"][0]["vhckm"];
          var cpyid = result["data"][0]["cpyid"];
          var cpyname = result["data"][0]["cpyname"];
          var ismixer = result["data"][0]["ismixer"];
          var phone = result["data"][0]["phone"] ?? "";
          // default true bila field belum ada di response lama
          final dynamic isReadSimRaw = result["data"][0]["is_read_sim"];
          final bool isReadSim = (() {
            if (isReadSimRaw == null) return true;
            if (isReadSimRaw is bool) return isReadSimRaw;
            final s = isReadSimRaw.toString().trim().toLowerCase();
            if (s == 'false' || s == '0' || s == 'no') return false;
            return true;
          })();
          var status_karyawan = result["data"][0]["status_karyawan"];
          var rawKry = result["data"][0]["kryid"];
          String kryid = '';
          if (rawKry != null) {
            final s = rawKry.toString().trim();
            if (s.isNotEmpty &&
                s.toLowerCase() != 'null' &&
                s.toLowerCase() != 'undefined') {
              kryid = s;
            }
          }
          var login_type = result["data"][0]["login_type"];
          var api_lokar = result["data"][0]["api_lokar"];
          var lokar_client_id = result["data"][0]["lokar_client_id"];
          var lokar_api_token = result["data"][0]["lokar_api_token"];
          await getAksesMenuForeMan(_identifier);
          if (loginname != null && loginname != "DRIVER") {
            if (akses_page != null) {
              String s = akses_page;
              print(s);
              var dataAkses = s.split(',');
              List<String> arrAksesPage = [];
              if (dataAkses.length > 0) {
                for (var i = 0; i < dataAkses.length; i++) {
                  print(dataAkses[i]);
                  arrAksesPage.add(dataAkses[i]);
                }
              }
              await prefs.setStringList("akses_pages", arrAksesPage);
            }
          }

          // Bersihkan string 'null' dari backend
          if (loginname != null &&
              loginname.toString().trim().toLowerCase() == 'null') {
            loginname = '';
          }
          if (nickname != null &&
              nickname.toString().trim().toLowerCase() == 'null') {
            nickname = '';
          }

          // Fingerprint: username kosong → pakai name/drvid dari API (sama seperti login manual)
          if (username.isEmpty) {
            username = (name ?? drvid ?? '').toString().trim();
          }

          // Normalisasi akun ADMIN / Staff / Karyawan
          final String effUser = username.toUpperCase();
          final bool isAdminUser = effUser == 'ADMIN' ||
              (drvid != null && drvid.toString().toUpperCase() == 'ADMIN') ||
              (name != null && name.toString().toUpperCase() == 'ADMIN');
          final bool isNonDriver = nickname == 'DISPATCHER' ||
              isAdminUser ||
              (loginname != null &&
                  loginname.toString().isNotEmpty &&
                  loginname.toString().toUpperCase() != 'DRIVER');

          if (isAdminUser) {
            status_karyawan = 'KARYAWAN';
            if (loginname == null ||
                loginname.toString().trim().isEmpty ||
                loginname.toString().toLowerCase() == 'null') {
              loginname = 'IT';
            }
            if (kryid.isEmpty || kryid.toLowerCase() == 'null') {
              kryid = '1184-020118.81';
            }
          } else if (isNonDriver &&
              (status_karyawan == null ||
                  status_karyawan.toString().toUpperCase() == 'DRIVER')) {
            status_karyawan = 'KARYAWAN';
            if (loginname == null ||
                loginname.toString().trim().isEmpty ||
                loginname.toString().toLowerCase() == 'null') {
              loginname = (nickname != null && nickname.toString().isNotEmpty)
                  ? nickname
                  : 'STAFF';
            }
          }

          print(drvid);
          print(cpyid);
          print(cpyname);
          print(vhcnopol);
          print(vhcid);
          if ((prefs.getString('loginname') != null &&
              prefs.getString('loginname') == 'DRIVER')) {
            if (prefs.getString('bujnumber') != null &&
                prefs.getString('drvid') == drvid &&
                prefs.getString('vhcid') == vhcid) {
              print('buj number ${prefs.getString('bujnumber')}');
            } else {
              prefs.remove('bujnumber');
            }
          }

          prefs.setString('drvid', drvid);
          prefs.setString('photo_driver', photo_driver);
          prefs.setString('mechanicid', mechanicid);
          prefs.setString('username', username);
          prefs.setString('password', password);
          prefs.setString('name', name);
          prefs.setString('nickname', nickname);
          prefs.setString('loginname', loginname);
          prefs.setString('vhcid', vhcid);
          prefs.setString('vhcnopol', vhcnopol);
          prefs.setString('locid', locid);
          prefs.setString('vhckm', vhckm);
          prefs.setString('cpyid', cpyid);
          prefs.setString('cpyname', cpyname);
          prefs.setString('ismixer', ismixer);
          prefs.setString('phone', phone);
          prefs.setBool('is_read_sim', isReadSim);
          prefs.setString('login_type', login_type);
          prefs.setString('status_karyawan', status_karyawan);
          prefs.setString('kryid', kryid);
          prefs.setString('api_lokar', api_lokar ?? '');
          prefs.setString(
              'lokar_client_id', (lokar_client_id ?? '').toString());
          prefs.setString(
              'lokar_api_token', (lokar_api_token ?? '').toString());
          print('IMMEIID $_identifier');
          // Debug: dump nomor login vs nomor SIM yang terbaca di device
          unawaited(
            SimPhoneGuard.debugDumpSimPhones(note: 'setelah login'),
          );
          UserInactivityController.resetTimer();
          UserInactivityController.reloadIdleDuration();

          String imeiToSend = (prefs.getString('androidID') ?? _identifier);
          if (imeiToSend.isEmpty ||
              imeiToSend == 'Failed to get Unique Identifier') {
            try {
              final newId = await UniqueIdentifier.serial;
              if (newId != null && newId.isNotEmpty) {
                imeiToSend = newId;
                await prefs.setString('androidID', newId);
              }
            } catch (_) {}
          }
          // Jika login manual (bukan finger), cek apakah IMEI perangkat sudah terdaftar untuk akun ini
          if (!isFinger &&
              imeiToSend.isNotEmpty &&
              imeiToSend != 'Failed to get Unique Identifier') {
            bool isImeiRegistered = false;
            try {
              final checkUri = Uri.parse(endpointUrl).replace(queryParameters: {
                'method': 'authorize-v1',
                'username': '',
                'password': '',
                'imeiid': imeiToSend,
                'isfinger': '1',
              });
              final checkRes =
                  await http.get(checkUri).timeout(const Duration(seconds: 4));
              if (checkRes.statusCode == 200) {
                final checkResult = _decoder.convert(checkRes.body);
                if (int.tryParse(checkResult["status_code"]?.toString() ?? '') ==
                    200) {
                  final checkData = checkResult["data"];
                  if (checkData != null &&
                      checkData is List &&
                      checkData.isNotEmpty) {
                    final matchedUser = (checkData[0]["drvid"] ??
                            checkData[0]["name"] ??
                            '')
                        .toString()
                        .toUpperCase();
                    if (matchedUser == effUser ||
                        matchedUser == drvid.toString().toUpperCase()) {
                      isImeiRegistered = true;
                    }
                  }
                }
              }
            } catch (_) {}

            if (!isImeiRegistered) {
              if (EasyLoading.isShow) EasyLoading.dismiss();
              final ctx = globalScaffoldKey.currentContext ?? context;
              bool? activateFinger = await showDialog<bool>(
                context: ctx,
                barrierDismissible: false,
                builder: (dCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.fingerprint, color: primaryOrange, size: 28),
                      SizedBox(width: 8),
                      Text("Aktifkan Fingerprint?",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: const Text(
                    "Device ID perangkat ini belum terdaftar untuk login Fingerprint.\n\n"
                    "Apakah Anda ingin mengaktifkan login Fingerprint menggunakan perangkat ini?",
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dCtx, false),
                      child: const Text("No",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(dCtx, true),
                      child: const Text("Yes",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ],
                ),
              );

              if (activateFinger == true) {
                EasyLoading.show(status: 'Mengaktifkan Fingerprint...');
                final bool success = await _updateImeiOnServer(
                  imeiid: imeiToSend,
                  statusKaryawan: status_karyawan,
                  drvid: drvid,
                  kryid: kryid,
                  username: username,
                );
                if (EasyLoading.isShow) EasyLoading.dismiss();
                if (success) {
                  showToast("Fingerprint berhasil diaktifkan");
                } else {
                  showToast("Gagal mengaktifkan Fingerprint di server");
                }
              }
            }
          }

          await FcmAduanService.instance.syncTokenIfPossible();
          unawaited(MasterDataPreloader.preloadCommon(forceRefresh: true));

          if (EasyLoading.isShow) EasyLoading.dismiss();
          final ctx = globalScaffoldKey.currentContext ?? context;
          if (loginname == "MECHANIC" && isMenuForeman == false) {
            Navigator.pushReplacement(
                ctx, MaterialPageRoute(builder: (context) => ViewListWoMCN()));
          } else {
            prefs.setString(
                'isMenuForeman', (isMenuForeman == true ? "1" : "0"));
            Navigator.pushReplacement(
                ctx, MaterialPageRoute(builder: (context) => ViewDashboard()));
          }
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalScaffoldKey,
      backgroundColor: backgroundColor,
      body: InkWell(
        onTap: () {
          onWillPop();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: _customBgUrl != null && _customBgUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(_customBgUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: _customBgUrl == null || _customBgUrl!.isEmpty
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor,
                      veryLightOrange,
                    ],
                  )
                : null,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  // Header Section
                  //iOCN INI
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        GlobalData.baseUrlOri + 'img/dms.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  //SAMPE ICON SINI
                  SizedBox(height: 20),
                  Text(
                    "PT. Andalan Nusa Pratama",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sign in to your account",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Field
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: veryLightOrange,
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: TxtUsername,
                            style: TextStyle(
                              fontSize: 16,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter your username",
                              hintStyle: TextStyle(
                                color: textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: primaryOrange,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Password Field
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: veryLightOrange,
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: TxtPassword,
                            obscureText: !isPasswordVisible,
                            style: TextStyle(
                              fontSize: 16,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              hintStyle: TextStyle(
                                color: textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: primaryOrange,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: primaryOrange,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Forgot password functionality
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Login and Biometric Buttons
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(2, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      print('dologin');
                                      await doLogin(context, false);
                                    } catch (e) {
                                      print("ERROR ${e.toString()}");
                                      final ctx =
                                          globalScaffoldKey.currentContext;
                                      if (ctx != null) {
                                        alert(ctx, 0, e.toString(), "error");
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                width: 50,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      print('Fingerprint check available');
                                      await initUniqueIdentifierState();
                                      print("_identifier ${_identifier}");
                                      await _authenticate();
                                    } catch (e) {
                                      print("ERROR ${e.toString()}");
                                      final ctx =
                                          globalScaffoldKey.currentContext;
                                      if (ctx != null) {
                                        alert(ctx, 0, e.toString(), "error");
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cardBackground,
                                    foregroundColor: primaryOrange,
                                    padding: EdgeInsets.all(8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: primaryOrange,
                                        width: 2,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Icon(
                                    Icons.fingerprint,
                                    color: primaryOrange,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Version 3.16",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500, //
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    initUniqueIdentifierState();
    _loadSavedBackground();
  }
}
