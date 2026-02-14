

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
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
  static const Color lightOrange = Color(0xFFFFA376);
  static const Color veryLightOrange = Color(0xFFFFE4D6);
  static const Color backgroundColor = Color(0xFFFFF5F0);
  static const Color cardBackground = Color(0xFFFEFEFE);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  Future<bool> onWillPop() {
    return Future.value(false);
  }

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    return canCheckBiometrics;
  }

  String _identifier = '';
  Future<void> initUniqueIdentifierState() async {
    String? identifier;
    try {
      identifier = await UniqueIdentifier.serial;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("androidID", identifier ?? '');
    } catch (platformException) {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;

    setState(() {
      _identifier = identifier ?? '';
    });
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
        localizedReason: 'Please authenticate to login',
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

  Future doLogin(BuildContext context, bool isFinger) async {
    EasyLoading.show();
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      var endpointUrl =
          "https://apps.tuluatas.com/trucking/mobile/api/authorize_v6.jsp";

      String username = TxtUsername.text;
      String password = TxtPassword.text;
      print('_identifier ${_identifier}');
      Map<String, String> queryParams = {
        'method': 'authorize-v1',
        'username': username,
        'password': password,
        'imeiid': _identifier,
        'isfinger': isFinger == true ? "1" : "0"
      };
      print(queryParams);
      print("isFinger == true  ${(isFinger == true ? "1" : "0")}");
      print(endpointUrl);
      var headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

      String queryString = Uri(queryParameters: queryParams).query;
      var requestUrl = endpointUrl + '?' + queryString;
      Uri myUri = Uri.parse(requestUrl);

      var response = await http.get(myUri, headers: headers);
      if (response.statusCode != 200) {
        EasyLoading.dismiss();
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Error while fetching data", "error");
        }
      } else {
        var result = _decoder.convert(response.body);
        if (int.parse(result["status_code"]) == 100) {
          EasyLoading.dismiss();
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 0, result["message"], "error");
          }
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
          var status_karyawan = result["data"][0]["status_karyawan"];
          var login_type = result["data"][0]["login_type"];
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
              prefs.setStringList("akses_pages", arrAksesPage);
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
          prefs.setString('login_type', login_type);
          prefs.setString('status_karyawan', status_karyawan);

          Timer(Duration(seconds: 1), () {
            EasyLoading.dismiss();
            final ctx = globalScaffoldKey.currentContext;
            if (ctx != null) {
              if (loginname == "MECHANIC" && isMenuForeman == false) {
                Navigator.pushReplacement(ctx,
                    MaterialPageRoute(builder: (context) => ViewListWoMCN()));
              } else {
                prefs.setString(
                    'isMenuForeman', (isMenuForeman == true ? "1" : "0"));
                Navigator.pushReplacement(ctx,
                    MaterialPageRoute(builder: (context) => ViewDashboard()));
              }
            }
          });
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                veryLightOrange,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  // Header Section
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryOrange,
                          lightOrange,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.business_center_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
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
                                      final ctx = globalScaffoldKey.currentContext;
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
                                      initUniqueIdentifierState();
                                      print("_identifier ${_identifier}");
                                      await _authenticate();
                                    } catch (e) {
                                      print("ERROR ${e.toString()}");
                                      final ctx = globalScaffoldKey.currentContext;
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
                    "Version 3.0",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    initUniqueIdentifierState();
  }
}
