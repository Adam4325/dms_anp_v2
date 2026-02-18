import 'dart:async';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/mekanik/ListMekanikInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;

import '../../flusbar.dart';

class ToolItem {
  final String id;
  final String groupId;
  final String namaTools;
  int qty;
  bool ada;
  bool rusak;
  bool tidakAda;

  ToolItem({
    required this.id,
    required this.groupId,
    required this.namaTools,
    this.qty = 0,
    this.ada = false,
    this.rusak = false,
    this.tidakAda = false,
  });

  factory ToolItem.fromJson(Map<String, dynamic> json) {
    return ToolItem(
      id: json['id'],
      groupId: json['groupid'],
      namaTools: json['nama_tools'],
      qty: int.parse(json['qty'].toString()),
    );
  }
}

class DailyMekanikCheckScreenP2H extends StatefulWidget {
  @override
  _DailyMekanikCheckScreenP2HState createState() =>
      _DailyMekanikCheckScreenP2HState();
}

class _DailyMekanikCheckScreenP2HState
    extends State<DailyMekanikCheckScreenP2H> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<ToolItem>> futureTools;
  List<ToolItem> tools = [];
  TextEditingController _noteController = TextEditingController();

  Future<List<ToolItem>> fetchTools() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var mechanicid = globals.p2hVhcMekanik == "yes"
        ? sharedPreferences.getString("mechanicid")
        : globals.Mckryid;
    var baseUrl =
       GlobalData.baseUrl + 'api/mekanik/master_data_inspeksi.jsp?method=list-inspeksi-v2&kryid=${mechanicid}';
    print(baseUrl);
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ToolItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tools');
    }
  }

  void setAllStatus(List<ToolItem> items, String status, bool value) {
    setState(() {
      for (var item in items) {
        if (status == 'ada') {
          item.ada = value;
          item.rusak = false;
          item.tidakAda = false;
        } else if (status == 'rusak') {
          item.rusak = value;
          item.ada = false;
          item.tidakAda = false;
        } else if (status == 'tidakAda') {
          item.tidakAda = value;
          item.ada = false;
          item.rusak = false;
        }
      }
    });
  }

  void resetAllCheckBox() {
    setState(() {
      // Tambahkan setState di sini
      for (var item in tools) {
        item.ada = false;
        item.rusak = false;
        item.tidakAda = false;
      }
      _noteController.text = "";
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var username = prefs.getString("name");
    var _locid = prefs.getString("locid");

    // Validasi: Semua ToolItem harus dipilih salah satu (ada/rusak/tidakAda)
    final incomplete = tools.any((tool) =>
        tool.ada == false && tool.rusak == false && tool.tidakAda == false);

    if (incomplete) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text(
              'Semua inspeksi wajib diisi (Baik, Rusak, atau Tidak Ada).'),
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

    // Format data inspeksi_result
    List<Map<String, dynamic>> result = tools.map((tool) {
      int inspeksiValue = 0;
      if (tool.ada) {
        inspeksiValue = 1;
      } else if (tool.rusak) {
        inspeksiValue = 2;
      } else if (tool.tidakAda) {
        inspeksiValue = 0;
      }

      return {
        "id": tool.id,
        "qty": tool.qty,
        "inspeksi_name": tool.namaTools,
        "inspeksi": inspeksiValue,
      };
    }).toList();

    print(result);

    String lat = userLocation?.latitude?.toString() ?? "";
    String lon = userLocation?.longitude?.toString() ?? "";

    if (lon.isEmpty && lat.isEmpty) {
      alert(
        globalScaffoldKey.currentContext!,
        0,
        "Coordinate/Lokasi tidak ditemukan, silahkan aktifkan GPS terlebih dahulu",
        "warning",
      );
      return;
    }

    txtAddr = "";
    await updatePosition("IN");

    final data = {
      "catatan": _noteController.text,
      "kryid": globals.p2hVhcMekanik == "yes"
          ? prefs.getString("mechanicid").toString()
          : globals.Mckryid,
      "lon": lon,
      "lat": lat,
      "geoid": geo_id_area,
      "geo_name": geofence_name,
      "locid": _locid,
      "userid": username,
      "inspeksi_result": result,
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    try {
      final response = await http.post(
        Uri.parse(
            GlobalData.baseUrl + 'api/mekanik/create_p2h_mekanik_new.jsp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonString,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Ambil status dan message
        final status = data['status'];
        final message = data['message'];
        if (status == 'success') {
          alert(
              globalScaffoldKey.currentContext!, 1, "Submit berhasil", "success");
          Timer(Duration(seconds: 1), () {
            globals.inspeksi_name = "new_inspeksi_mc";
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          });
        }else{
          alert(
              globalScaffoldKey.currentContext!, 0, message, "error");
        }

      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Submit gagal: ${response.statusCode}", "error");
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Terjadi kesalahan: $e",
          "error");
    }
  }

  Position? userLocation;
  double _lat = 0.0;
  double _lon = 0.0;
  bool _serviceEnabled = true;
  bool _isisMock = true;
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
              LatLng(double.parse(a['lat']), double.parse(a['lon'])),
              LatLng(userLocation!.latitude, userLocation!.longitude));
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

  bool isMock = true;
  var truslat = "0.0";
  var trusLon = "0.0";

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      isMock = await TrustLocation.isMockLocation;
      TrustLocation.start(5);

      /// the stream getter where others can listen to.
      TrustLocation.onChange.listen((values) {
            print(
                'TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}');
            truslat = values.latitude.toString();
            trusLon = values.longitude.toString();
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

  void handleCancel() {
    resetAllCheckBox();
  }

  String namaUser = "";
  String karyawan_id = "";
  String karyawanGrade = "";
  bool isLoading = true;

  Future<String?> fetchGrade(String kryid) async {
    var urlBase =
       GlobalData.baseUrl + 'api/mekanik/mekanik_grade.jsp?kryid=${kryid}';
    print(urlBase);
    final url = Uri.parse(urlBase);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          return data['grade']; // Ambil grade-nya saja
        } else {
          print('Status not success');
          return null;
        }
      } else {
        print('Request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void GetSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('globals.p2hVhcMekanik ${globals.p2hVhcMekanik}');
    setState(() {
      namaUser = prefs.getString('nickname') ?? "";
      karyawan_id = (globals.p2hVhcMekanik == 'yes'
          ? prefs.getString('mechanicid')
          : globals.Mckryid)!;
      isLoading = false;
    });
    var a = globals.p2hVhcMekanik == 'yes'
        ? await fetchGrade(karyawan_id)
        : globals.McGrade;
    setState(() {
      karyawanGrade = a ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    GetSession();
    getListGeofenceArea(false);
    _getLocation().then((position) {
      userLocation = position;
    });
    futureTools = fetchTools();
    futureTools.then((value) {
      tools = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          //SharedPreferences prefs = await SharedPreferences.getInstance();
          if (globals.p2hVhcMekanik == "yes") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
            return Future.value(false);
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ListMekanikInspeksiV2()));
            return Future.value(false);
          }
        },
        child: Scaffold(
          key: globalScaffoldKey,
          appBar: AppBar(title: Text("P2H Tools"),leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (globals.p2hVhcMekanik == "yes") {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ViewDashboard()));
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListMekanikInspeksiV2()));
              }
            },
          )),
          body: FutureBuilder<List<ToolItem>>(
            future: futureTools,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tools = snapshot.data;
                final grouped = <String, List<ToolItem>>{};
                for (var item in tools!) {
                  grouped.putIfAbsent(item.groupId, () => []).add(item);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRowLabel("NAMA", namaUser),
                          SizedBox(height: 4),
                          _buildRowLabel("ID", karyawan_id),
                          SizedBox(height: 4),
                          _buildRowLabel("GRADE", karyawanGrade.toUpperCase()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: grouped.entries.map((entry) {
                          final items = entry.value;
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('GROUP ID: ${entry.key}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Divider(),
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(3),
                                      1: FixedColumnWidth(50),
                                      2: FixedColumnWidth(50),
                                      3: FixedColumnWidth(50),
                                      4: FixedColumnWidth(90),
                                    },
                                    border: TableBorder.all(
                                        color: Colors.grey.shade400),
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(color: Colors.grey.shade300),
                                        children: [
                                          TableCell(
                                            verticalAlignment: TableCellVerticalAlignment.middle,
                                            child: Center(
                                              child: Text(
                                                "TOOLS",
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment: TableCellVerticalAlignment.middle,
                                            child: Center(
                                              child: Text(
                                                "QTY",
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text("ADA", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                                              Checkbox(
                                                value: items.every((e) => e.ada),
                                                onChanged: (val) => setAllStatus(items, 'ada', val!),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text("RUSAK", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                                              Checkbox(
                                                value: items.every((e) => e.rusak),
                                                onChanged: (val) => setAllStatus(items, 'rusak', val!),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text("TIDAK ADA", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                                              Checkbox(
                                                value: items.every((e) => e.tidakAda),
                                                onChanged: (val) => setAllStatus(items, 'tidakAda', val!),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ...items.map((tool) {
                                        return TableRow(children: [
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text(tool.namaTools)),
                                          TableCell(
                                            verticalAlignment: TableCellVerticalAlignment.middle,
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(4),
                                                child: TextFormField(
                                                  initialValue: tool.qty.toString(),
                                                  keyboardType: TextInputType.number,
                                                  readOnly: true,
                                                  textAlign: TextAlign.center, // agar isi angka juga di tengah
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true, // biar lebih ringkas
                                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      tool.qty = int.tryParse(val) ?? 0;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Checkbox(
                                              value: tool.ada,
                                              onChanged: (val) {
                                                setState(() {
                                                  tool.ada = val ?? false;
                                                  if (val == true) {
                                                    tool.rusak = false;
                                                    tool.tidakAda = false;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          Center(
                                            child: Checkbox(
                                              value: tool.rusak,
                                              onChanged: (val) {
                                                setState(() {
                                                  tool.rusak = val ?? false;
                                                  if (val == true) {
                                                    tool.ada = false;
                                                    tool.tidakAda = false;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          Center(
                                            child: Checkbox(
                                              value: tool.tidakAda,
                                              onChanged: (val) {
                                                setState(() {
                                                  tool.tidakAda = val ?? false;
                                                  if (val == true) {
                                                    tool.ada = false;
                                                    tool.rusak = false;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              handleSubmit();
                            },
                            icon: Icon(Icons.check),
                            label: Text("SUBMIT"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              handleCancel();
                            },
                            icon: Icon(Icons.cancel),
                            label: Text("CANCEL"),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }

  Widget _buildRowLabel(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70, // pastikan semua label cukup
          child: Text(
            "$label",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          ": ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
