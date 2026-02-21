import 'dart:async';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/FrmCreateAntrianNewDriver.dart';
import 'package:dms_anp/src/pages/FrmSetKmByDoMixer.dart';
import 'package:dms_anp/src/pages/FrmSetKmByDriver.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/ListDriverInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import '../../flusbar.dart';
import '../ViewAntrian.dart';
import '../ViewAntrianMixer.dart';
import '../ViewService.dart';

class DailyCheckScreenP2H extends StatefulWidget {
  @override
  _DailyCheckScreenP2HState createState() => _DailyCheckScreenP2HState();
}

class _DailyCheckScreenP2HState extends State<DailyCheckScreenP2H> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> inspections = [];
  Map<String, String> selectedValues =
      {}; // key: inspeksi_id, value: 'ya'/'tidak'
  final TextEditingController kilometerController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (globals.p2hVhcDriver == "yes") {
        kilometerController.text = (prefs.getString("km_new") ?? "");
      } else {
        kilometerController.text = (globals.p2hVhcKilometer ?? "");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSession();
    _getLocation().then((position) {
      userLocation = position;
    });
    fetchInspectionData();
  }

  void fetchInspectionData() async {
    var urlBase = GlobalData.baseUrl +
        'api/master_data_inspeksi.jsp?method=list-inspeksi-v2&vhcid=${globals.p2hVhcid.toString()}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);
    if (response.statusCode == 200) {
      setState(() {
        inspections = json.decode(response.body);
      });
    } else {
      print('Failed to load data');
    }
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  Future<bool> submitInspeksiP2H(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);

    final response = await http.post(
      Uri.parse(GlobalData.baseUrl + 'api/create_form_inspeksiv2_new.jsp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("km_new", kilometerController.text.toString());
          prefs.setString("vhcid_last_antrian", globals.p2hVhcid!);
          prefs.setString("method", "new");

          globals.page_inspeksi = "new_driver";
          globals.p2hVhcid = globals.p2hVhcid;
          globals.p2hVhclocid = globals.p2hVhclocid;
          globals.p2hVhcDriver = "";

          return true;
        } else {
          // Gunakan mounted check
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Gagal'),
                content: Text(responseData['message'] ?? 'Terjadi kesalahan.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx), child: Text('OK'))
                ],
              ),
            );
          }
          return false;
        }
      } catch (e) {
        print("JSON decode error: $e");
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Error'),
              content: Text('Respon tidak valid dari server.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx), child: Text('OK'))
              ],
            ),
          );
        }
        return false;
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Gagal'),
            content: Text('Tidak dapat menghubungi server.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK'))
            ],
          ),
        );
      }
      return false;
    }
  }

  void handleSubmit() async {
    // Cek apakah widget masih mounted
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String lat = userLocation?.latitude?.toString() ?? "";
    String lon = userLocation?.longitude?.toString() ?? "";
    String speed = userLocation?.speed?.toString() ?? "";

    if (lat.isEmpty && lon.isEmpty) {
      if (mounted) {
        alert(
            context,
            0,
            "Coordinate/Lokasi tidak ditemukan, silakan aktifkan GPS terlebih dahulu",
            "warning");
      }
      return;
    }

    await updatePosition("IN");

    // Cek apakah widget masih mounted sebelum validasi
    if (!mounted) return;

    if (txtAddr != null &&
        txtAddr.toString().isNotEmpty &&
        (txtAddr.toString().toUpperCase() == "OUTGEO" ||
            txtAddr.toString().toUpperCase() != "INGEO")) {
      if (mounted) {
        alert(globalScaffoldKey.currentContext!, 0,
            "P2H tidak diijinkan, silakan ke Geofence/Area Pool", "warning");
      }
      return;
    }

    if (txtAddr == null || txtAddr == "") {
      if (mounted) {
        alert(globalScaffoldKey.currentContext!, 2,
            "Coba lagi untuk melakukan submit P2H", "warning");
      }
      return;
    }

    var username = prefs.getString("name");
    var _locid = prefs.getString("locid");

    // ✅ PERBAIKAN: Gunakan unique IDs untuk validasi
    final uniqueIds = inspections.map((e) => e['id']).toSet();
    final incomplete = uniqueIds.any((id) => selectedValues[id] == null);

    if (incomplete) {
      if (mounted) {
        _showValidationDialog('Semua inspeksi wajib diisi (Ya atau Tidak).');
      }
      return;
    }

    // ✅ PERBAIKAN: Buat hasil inspeksi TANPA DUPLICATE
    List<Map<String, dynamic>> result = [];
    Set<String> processedIds = Set<String>();

    print("=== DEBUG CREATE RESULT ===");
    print("Total inspections: ${inspections.length}");

    for (var item in inspections) {
      String id = item['id'].toString();
      String name = item['inspeksi_name'].toString();

      // Skip jika ID sudah diproses
      if (processedIds.contains(id)) {
        print("⚠️  SKIP DUPLICATE: ID $id, Name: $name");
        continue;
      }

      String? selectedValue = selectedValues[id];
      if (selectedValue != null) {
        result.add({
          "id": id,
          "inspeksi_name": name,
          "inspeksi": selectedValue == "ya" ? 1 : 0,
        });
        processedIds.add(id);
        print("✅ ADDED: ID $id, Name: $name, Value: $selectedValue");
      }
    }

    print("=== FINAL RESULT ===");
    print("Original inspections: ${inspections.length}");
    print("Unique result: ${result.length}");
    print("Duplicates removed: ${inspections.length - result.length}");

    // Buat payload
    final data = {
      "kilometer": globals.p2hVhcDriver == "yes"
          ? prefs.getString("km_new")
          : kilometerController.text,
      "catatan": notesController.text,
      "drvid":
          globals.p2hVhcDriver == "yes" ? prefs.getString("drvid") ?? "" : "",
      "lon": lon,
      "lat": lat,
      "geoid": geo_id_area,
      "geo_name": geofence_name,
      "vhcid": globals.p2hVhcDriver == "yes"
          ? (prefs.getString("vhcidfromdo")?.isEmpty ?? true
              ? prefs.getString("vhcid_last_antrian")
              : prefs.getString("vhcidfromdo"))
          : globals.p2hVhcid.toString(),
      "locid": globals.p2hVhcDriver == "yes"
          ? _locid
          : globals.p2hVhclocid.toString(),
      "userid": username,
      "inspeksi_result": result, // ✅ SUDAH UNIQUE
    };

    // === Jika Driver: Tampilkan Dialog Konfirmasi Submit ===
    if (globals.p2hVhcDriver == "yes") {
      if (mounted) {
        _showConfirmationDialog(
          "Inspeksi berhasil diisi di area $geofence_name. Lanjutkan ke proses Antrian?",
          () async {
            // Cek mounted lagi sebelum submit
            if (!mounted) return;

            bool isSuccess = await submitInspeksiP2H(data);
            if (isSuccess) {
              if (mounted) {
                alert(globalScaffoldKey.currentContext!, 1,
                    "Success membuat p2h", "success");
                Timer(Duration(seconds: 1), () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var p2h_antrian = prefs.setString("p2h_antrian", "true");
                  var login_type = prefs.getString("login_type");
                  if (mounted) {
                    if (login_type == "MIXER") {
                      Navigator.pushReplacement(
                        globalScaffoldKey.currentContext!,
                        MaterialPageRoute(
                            builder: (context) => ViewAntrianMixer()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        globalScaffoldKey.currentContext!,
                        MaterialPageRoute(builder: (context) => ViewAntrian()),
                      );
                    }
                  }
                });
              }
            } else {
              if (mounted) {
                alert(globalScaffoldKey.currentContext!, 0, "Gagal membuat p2h",
                    "error");
              }
            }
          },
        );
      }
    } else {
      // === Jika Bukan Driver: Langsung Submit ===
      var isSuccess = await submitInspeksiP2H(data);
      if (!isSuccess) {
        if (mounted) {
          alert(globalScaffoldKey.currentContext!, 0, "Gagal membuat p2h",
              "error");
        }
      } else {
        if (mounted) {
          alert(globalScaffoldKey.currentContext!, 1, "Success membuat p2h",
              "success");
          Timer(Duration(seconds: 1), () {
            if (mounted) {
              _showSuccessDialog();
            }
          });
        }
      }
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Sukses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 12),

              // Content
              Text(
                'Form inspeksi berhasil disubmit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 25),

              // Action Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();

                    if (!mounted) return;

                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    var loginName = sharedPreferences.getString("loginname");
                    var login_type = sharedPreferences.getString("login_type");

                    if (loginName == 'DRIVER') {
                      if (EasyLoading.isShow) {
                        EasyLoading.dismiss();
                      }
                      String message = globals.page_inspeksi == 'service'
                          ? "Lanjutkan ke proses service ${login_type}?"
                          : "Lanjutkan ke proses antrian ${login_type}?";

                      if (mounted) {
                        _showConfirmationDialog(
                          message,
                          () {
                            Navigator.of(context).pop();
                            if (mounted) {
                              if (login_type == "MIXER") {
                                Navigator.pushReplacement(
                                  globalScaffoldKey.currentContext!,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        globals.page_inspeksi == 'service'
                                            ? ViewService()
                                            : ViewAntrianMixer(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  globalScaffoldKey.currentContext!,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        globals.page_inspeksi == 'service'
                                            ? ViewService()
                                            : ViewAntrian(),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationDialog(String message) {
    showDialog(
      context: globalScaffoldKey.currentContext!,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade300, Colors.red.shade400],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Validasi Gagal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              SizedBox(height: 12),

              // Content
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 25),

              // OK Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Konfirmasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 12),

              // Content
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 25),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.close, color: Colors.white, size: 18),
                        label: Text(
                          "Tidak",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Confirm Button
                  Expanded(
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.orange.shade600
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check, color: Colors.white, size: 18),
                        label: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Position? userLocation;
  double _lat = 0.0;
  double _lon = 0.0;
  bool _serviceEnabled = true;
  bool _isisMock = false;
  String androidID = "";
  List listGeofence = [];
  String txtAddr = "";

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrlOri}api/create_geofence_area_p2h.jsp?method=list-geofence-area-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listGeofence = [];
          listGeofence = (jsonDecode(response.body) as List)
              //.map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data geofence",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data geofence",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  String geofence_name = "";
  var geo_id_area = 0;
  Future updatePosition(String inorout) async {
    //print(androidID.toString());
    //print(userLocation);
    if (userLocation != null) {
      //print(userLocation);
      if (listGeofence.length > 0) {
        var radiusOld = 0.0;
        var geo_idOld = 0;
        var geo_nmOld = "";
        var isValid = false;
        for (var i = 0; i < listGeofence.length; i++) {
          var a = listGeofence[i];
          var radius = double.parse(a['radius']);
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lon']), double.parse(a['lat'])),
              LatLng(userLocation!.longitude, userLocation!.latitude));
          //print('distanceBetweenPoints ${distanceBetweenPoints} meter ${distanceBetweenPoints / 1000} KM');
          //if (distanceBetweenPoints >= radius) {
          //FOR DEV
          txtAddr = "";
          if (distanceBetweenPoints <= radius) {
            if (i == 0) {
              radiusOld = radius;
              geo_idOld = int.parse(a['geo_id']);
              geo_id_area = int.parse(a['geo_id']);
              geo_nmOld = a['name'];
            } else {
              if (radiusOld < radius) {
                radius = radiusOld;
                geo_idOld = int.parse(a['geo_id']);
                geo_id_area = int.parse(a['geo_id']);
                geo_nmOld = a['name'];
              }
            }
          }
        }

        if (geo_nmOld != "" && geo_nmOld != null) {
          setState(() {
            txtAddr = "INGEO";
            print("valid geo_nmOld ${geo_nmOld}");
            isValid = true;
            geofence_name = geo_nmOld;
          });
        } else {
          setState(() {
            txtAddr = "OUTGEO";
            print("not valid geo_nmOld ${geo_nmOld}");
            geofence_name = "";
          });
        }

        if (isValid == true) {}
      } else {
        getListGeofenceArea(true);
      }
    } else {
      print('location');
      _getLocation();
    }
    Timer(const Duration(seconds: 1), () {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    });
  }

  bool isMock = false;
  var truslat = "0.0";
  var trusLon = "0.0";

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      try {
        isMock = await TrustLocation.isMockLocation;
      } catch (e) {
        print('TrustLocation isMockLocation check error: $e');
        isMock = false;
      }
      TrustLocation.start(5);

      /// the stream getter where others can listen to.
      TrustLocation.onChange.listen((values) {
        print(
            'TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}');
        truslat = values.latitude!;
        trusLon = values.longitude!;
      });

      /// stop repeating by timer
      TrustLocation.stop();
      //pos.
    } catch (e) {
      currentLocation = null;
    }
    //print(currentLocation);
    return currentLocation;
  }

  void handleSubmitOld2() {
    // Cek apakah semua inspeksi sudah dipilih
    final uniqueIds = inspections.map((e) => e['id']).toSet();
    final incomplete = uniqueIds.any((id) => selectedValues[id] == null);

    if (incomplete) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Semua inspeksi wajib diisi (Ya atau Tidak).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Jika valid, lanjutkan proses
    List<Map<String, dynamic>> result = [];

    final grouped = <String, String>{};
    for (var item in inspections) {
      grouped[item['id']] = item['inspeksi_name'];
    }

    grouped.forEach((id, name) {
      final value = selectedValues[id];
      result.add({
        "id": id,
        "inspeksi_name": name,
        "inspeksi": value == "ya" ? 1 : 0,
      });
    });

    final data = {
      "inspeksi_result": result,
      "kilometer": kilometerController.text,
      "catatan": notesController.text,
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // TODO: Kirim jsonString ke server via http.post atau sesuai backend-mu
  }

  void handleCancel() {
    setState(() {
      if (globals.p2hVhcDriver == "yes") {
        selectedValues.clear();
        notesController.clear();
      } else {
        selectedValues.clear();
        kilometerController.clear();
        notesController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PERBAIKAN: Group berdasarkan ID untuk menghindari duplicate UI
    final Map<String, Map<String, dynamic>> uniqueInspections = {};

    print("=== DEBUG BUILD METHOD ===");
    print("Total inspections from API: ${inspections.length}");

    for (var item in inspections) {
      String id = item['id'].toString();
      String name = item['inspeksi_name'].toString();

      if (!uniqueInspections.containsKey(id)) {
        uniqueInspections[id] = {'id': id, 'inspeksi_name': name, 'subs': []};
        print("✅ Added unique inspection: ID $id, Name: $name");
      } else {
        print("⚠️  Skipped duplicate inspection: ID $id, Name: $name");
      }

      // Tambahkan sub inspeksi jika ada
      if (item['subs_inspeksi_name'] != null &&
          item['subs_inspeksi_name'].toString() != "-") {
        uniqueInspections[id]?['subs'].add(item);
      }
    }

    print("=== UNIQUE INSPECTIONS ===");
    print("Total unique inspections: ${uniqueInspections.length}");
    //FrmSetKmByDriver
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (globals.p2hVhcDriver == "yes") {
          // if (prefs.getString("login_type") == "MIXER") {
          //   final kmMixer = prefs.getString("km_mixer") ?? "";
          //   final vhcidMixer = prefs.getString("vhcid_mixer") ?? "";
          //   final bujnbrMixer = prefs.getString("bujnumber_mixer") ?? "";
          //   final doNumberMixer =
          //       (prefs.getString("do_number_mixer") ?? prefs.getString("do_numbe_mixer")) ?? "";
          //   final driverIdMixer = prefs.getString("driver_id_mixer") ?? "";
          //   if (kmMixer.isNotEmpty &&
          //       vhcidMixer.isNotEmpty &&
          //       bujnbrMixer.isNotEmpty &&
          //       doNumberMixer.isNotEmpty &&
          //       driverIdMixer.isNotEmpty) {
          //     Navigator.pushReplacement(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => FrmSetKmByDoMixer(
          //                 vehilce: vhcidMixer,
          //                 vhckm: kmMixer,
          //                 bujnbr: bujnbrMixer,
          //                 do_number: doNumberMixer,
          //                 driver_id: driverIdMixer)));
          //   } else {
          //     Navigator.pushReplacement(context,
          //         MaterialPageRoute(builder: (context) => FrmSetKmByDriver()));
          //   }
          // } else {
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (context) => FrmSetKmByDriver()));
          // }
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        }
      },
      child: Scaffold(
        key: globalScaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xFFE65100),
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
              onPressed: () {
                if (globals.p2hVhcDriver == "yes") {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FrmSetKmByDriver()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListDriverInspeksiV2()));
                }
              },
            ),
          ),
          title: Text('Form Inspeksi ${globals.p2hVhcid.toString()}',
              style: TextStyle(color: Colors.white)),
        ),
        body: inspections.isEmpty
            ? const Center(
                child: Text("List data inspeksi tidak di temukan di database"))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text("Daily Check Before Riding",
                          style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 16),

                    // ✅ PERBAIKAN: Render unique inspections saja
                    ...uniqueInspections.entries.map((entry) {
                      final groupId = entry.key;
                      final inspection = entry.value;
                      final groupTitle = inspection['inspeksi_name'];
                      final subs = inspection['subs'];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(groupTitle,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Colors.grey,
                                    radioTheme: RadioThemeData(
                                      fillColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        if (selectedValues[groupId] ==
                                            'tidak') {
                                          return Colors.red;
                                        }
                                        return Colors.blue;
                                      }),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: 'ya',
                                        groupValue: selectedValues[groupId],
                                        onChanged: (val) {
                                          setState(() {
                                            selectedValues[groupId] = val!;
                                          });
                                        },
                                      ),
                                      const Text("Ya"),
                                      Radio<String>(
                                        value: 'tidak',
                                        groupValue: selectedValues[groupId],
                                        onChanged: (val) {
                                          setState(() {
                                            selectedValues[groupId] = val!;
                                          });
                                        },
                                      ),
                                      const Text("Tidak"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),

                            // ✅ Show sub inspections
                            ...subs
                                .map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.circle, size: 6),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                                item['subs_inspeksi_name']),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      );
                    }).toList(),

                    // Kilometer input
                    const SizedBox(height: 16),
                    TextField(
                      controller: kilometerController,
                      keyboardType: TextInputType.number,
                      readOnly: globals.p2hVhcDriver == "yes" ? true : false,
                      decoration: InputDecoration(
                        labelText: 'Kilometer',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes input
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
        backgroundColor: Colors.grey.shade100,
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.orange.shade600
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          print('prefs.getString("p2h_antrian")');
                          print(prefs.getString("p2h_antrian"));
                          handleSubmit();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white, size: 15),
                            SizedBox(width: 5),
                            Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          handleCancel();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 15),
                            SizedBox(width: 5),
                            Text(
                              "Reset",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
