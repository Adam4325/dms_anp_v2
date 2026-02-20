import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/helpers/database_helper.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/maintenance/FrmServiceTire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../flusbar.dart';

final TextEditingController serialNoController = TextEditingController();
final TextEditingController patternController = TextEditingController();
final TextEditingController indepth = TextEditingController();
final TextEditingController mid1depth = TextEditingController();
final TextEditingController mid2depth = TextEditingController();
final TextEditingController outdepth = TextEditingController();
final TextEditingController tekanan_angin = TextEditingController();
final TextEditingController tire_note = TextEditingController();
final TextEditingController old_fitpost = TextEditingController();
final TextEditingController new_fitpost = TextEditingController();
List<Map<String, dynamic>> dataListTireDetail = [];
List<Map<String, dynamic>> tireDetailsLogs = [];

bool casing_yes = false;
bool casing_no = false;
String fitpost = "";
String log_vehicleid = "";
String log_km_sekarang = "";
String log_vhtype = "";
String log_location = "";
String tire_vhcid = "";
String tire_total_km = "0";
String tire_vhttype = "";
String tire_alasan_unit = "";
String tire_status = "";
String tire_kerusakan_ban = "";
String title_header_tire = "";
String tire_masalah_unit = "";

List<Map<String, String>> tyrePosts = [];
String selectedTyrePost = "0";
String new_fit_post = '';
String id_tyre_post = "0";
String id_tyre_post2 = "0";

List<Map<String, String>> tireDetails = [];

class BottomActionBar extends StatefulWidget {
  @override
  _BottomActionBarState createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {
  void _showDetailLog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: Text('Achievement Check'),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height *
                    0.7, // Adjust height for better visibility
                child: ListView(
                  // ListView instead of Column
                  shrinkWrap: true,
                  children: [
                    // Static details
                    Text('Vehicle ID: ${log_vehicleid}'),
                    Text('Type: ${log_vhtype}'),
                    Text('KM Current: ${log_km_sekarang}'),
                    Text('Location: ${log_location}'),
                    SizedBox(height: 16), // Spacing
                    tireDetailsLogs.isEmpty
                        ? Center(
                            child: Text(
                              'No detail logs!',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap:
                                true, // Allows the ListView to work inside another scrollable widget
                            physics:
                                NeverScrollableScrollPhysics(), // Prevent ListView from scrolling independently
                            itemCount: tireDetailsLogs.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                elevation: 3,
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 0),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Serial No: ${tireDetailsLogs[index]["tyresn"]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              'Tyre Post: ${tireDetailsLogs[index]["tyrepost"]}'),
                                          Text(
                                              'Pattern: ${tireDetailsLogs[index]["pattern"]}'),
                                          Text(
                                              'Item Size: ${tireDetailsLogs[index]["itemsize"]}'),
                                          Text(
                                              'ID Type: ${tireDetailsLogs[index]["idtype"]}'),
                                          Text(
                                              'KM Target: ${tireDetailsLogs[index]["kmtarget"]}'),
                                          Text(
                                              'Merk: ${tireDetailsLogs[index]["merk"]}'),
                                          Text(
                                              'CPK: ${tireDetailsLogs[index]["cpk"]}'),
                                          Text(
                                              'Date Fitted: ${tireDetailsLogs[index]["dat_fitted"]}'),
                                          Text(
                                              'KM Fit: ${tireDetailsLogs[index]["km_fit"]}'),
                                          Text(
                                              'Umur KM/Rit: ${tireDetailsLogs[index]["km_rit"]}'),
                                          Text(
                                              'Umur KM/Trip: ${tireDetailsLogs[index]["rit_trip"]}'),
                                          Text(
                                              'Days: ${tireDetailsLogs[index]["days"]}'),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        });
      },
    );
  }

  Future getListDataTireDetailLogs(bool isload, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var vhcid = prefs.getString("tire_vhcid")!;
      var typeUnits = prefs.getString("tire_vhttype")!;
      EasyLoading.show();
      dataListTireDetail = [];
      var urlBase = "";
      urlBase =
          "${GlobalData.baseUrl}api/maintenance/sr/list_detail_log_tire.jsp?method=lookup-list-tire-logs-v1&vhcid=${vhcid}";
      var urlData = urlBase;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          tireDetailsLogs = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          if (tireDetailsLogs != null && tireDetailsLogs.length > 0) {
            log_vehicleid = vhcid;
            log_km_sekarang = tireDetailsLogs[0]['km_sekarang'];
            log_vhtype = typeUnits;
            log_location = tireDetailsLogs[0]['locid'];
          } else {
            log_vehicleid = vhcid;
            log_vhtype = typeUnits;
          }
        });
      } else {
        alert(context, 0, "Gagal load data list detail opname", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(context, 0, "Client, Load data logs tire", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => FrmServiceTire()));
        },
        child: Container(
          color: Colors.white, // Background color of the bar
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FrmServiceTire()));
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Back to Opname'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  print('Detail');
                  getListDataTireDetailLogs(true, context);
                  Timer(Duration(seconds: 2), () {
                    _showDetailLog(context);
                  });
                },
                icon: Icon(Icons.book),
                label: Text('List Detail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ));
  }
}

class TireTriller extends StatefulWidget {
  @override
  _TireTrillerState createState() => _TireTrillerState();
}

class _TireTrillerState extends State<TireTriller> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  bool _showNoDataMessage = false;
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();
  File? _imagePhoto1;
  File? _imagePhoto2;
  File? _imagePhoto3;

  String filePathImage1 = "";
  String filePathImage2 = "";
  String filePathImage3 = "";

  List<Map<String, dynamic>> tireDetailsBan = [];
  List<Map<String, dynamic>> tireDetailsStatus = [];
  List<Map<String, dynamic>> tireDetailsStatus1 = [];
  List<Map<String, dynamic>> tireDetailsStatus2 = [];
  List<Map<String, dynamic>> tireDetailsStatus3 = [];
  List<Map<String, dynamic>> tireDetailsStatus4 = [];

  void resetTeks() {
    serialNoController.text = '';
    patternController.text = '';
    indepth.text = '';
    outdepth.text = '';
    mid1depth.text = '';
    mid2depth.text = '';
    tekanan_angin.text = '';
    tire_note.text = '';
    casing_yes = false;
    casing_no = false;
    _imagePhoto1 = null;
    _imagePhoto2 = null;
    _imagePhoto3 = null;
    filePathImage1 = '';
    filePathImage2 = '';
    filePathImage3 = '';
  }

  Future getPicture(String namaPhoto, opsi) async {
    if (opsi == 'CAMERA') {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        if (namaPhoto == "PHOTO1") {
          setState(() {
            _imagePhoto1 = File(pickedFile.path);
            List<int> imageBytes = _imagePhoto1!.readAsBytesSync();
            var kb = _imagePhoto1!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            filePathImage1 = base64Encode(imageBytes);
          });
        } else if (namaPhoto == "PHOTO2") {
          setState(() {
            _imagePhoto2 = File(pickedFile.path);
            List<int> imageBytes = _imagePhoto2!.readAsBytesSync();
            var kb = _imagePhoto2!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            filePathImage2 = base64Encode(imageBytes);
          });
        } else if (namaPhoto == "PHOTO3") {
          setState(() {
            _imagePhoto3 = File(pickedFile.path);
            List<int> imageBytes = _imagePhoto3!.readAsBytesSync();
            var kb = _imagePhoto3!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            filePathImage3 = base64Encode(imageBytes);
          });
        } else {
          setState(() {
            _imagePhoto1 = null;
            _imagePhoto2 = null;
            _imagePhoto3 = null;
            filePathImage1 = "";
            filePathImage2 = "";
            filePathImage3 = "";
          });
        }
        //print(filePathImage);
      } else {
        setState(() {
          _imagePhoto1 = null;
          _imagePhoto2 = null;
          _imagePhoto3 = null;
          filePathImage1 = "";
          filePathImage2 = "";
          filePathImage3 = "";
        });
      }
    }
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    await getPicture(namaPhoto, 'CAMERA');
  }

  Future GetDetailListStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tire_vhcid = prefs.getString("tire_vhcid")!;
    var urlBase = "";
    urlBase =
        "${GlobalData.baseUrl}api/maintenance/sr/detail_ban_tire.jsp?method=get-status-sn-tire-ban-v1&vhcid=${tire_vhcid}";
    var urlData = urlBase;
    var encoded = Uri.encodeFull(urlData);
    print(urlData);
    Uri myUri = Uri.parse(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      setState(() {
        tireDetailsStatus = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        print(tireDetailsStatus);
        if (tireDetailsStatus.isNotEmpty) {
          // Convert Iterable to List using .toList()
          tireDetailsStatus1 =
              tireDetailsStatus.where((e) => e['status'] == 'ETC').toList();
          tireDetailsStatus2 =
              tireDetailsStatus.where((e) => e['status'] == 'COND').toList();
          tireDetailsStatus3 =
              tireDetailsStatus.where((e) => e['status'] == 'DAMAGE').toList();
          tireDetailsStatus4 =
              tireDetailsStatus.where((e) => e['status'] == 'IMPACT').toList();

          if (tireDetailsStatus1.isNotEmpty) {
            tire_alasan_unit = tireDetailsStatus1[0]['id'];
          } else {
            tire_alasan_unit = "MTC BD";
          }

          if (tireDetailsStatus2.isNotEmpty) {
            tire_status = tireDetailsStatus2[0]['id'];
          } else {
            tire_status = "AFKIR";
          }

          if (tireDetailsStatus3.isNotEmpty) {
            tire_kerusakan_ban = tireDetailsStatus3[0]['id'];
          } else {
            tire_kerusakan_ban = "ZIPPER";
          }

          if (tireDetailsStatus4.isNotEmpty) {
            tire_masalah_unit = tireDetailsStatus4[0]['id'];
          } else {
            tire_masalah_unit = "-";
          }
          print('----------------------/-----------------');
          print(tireDetailsStatus1);
          print(tireDetailsStatus2);
          print(tireDetailsStatus3);
        } else {
          print("tireDetailsStatus is empty.");
        }
      });
    } else {
      tireDetailsBan = [];
    }
  }

  Future<void> fetchTyrePosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String baseUrl =
        "${GlobalData.baseUrl}api/maintenance/sr/refference_tyre.jsp";
    String method = "list-fitpost";
    String vhcid = prefs.getString("tire_vhcid").toString();

    String url = "$baseUrl?method=$method&vhcid=$vhcid";
    Uri myUri = Uri.parse(Uri.encodeFull(url));
    print("fetchTyrePosts ${myUri}");
    try {
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          tyrePosts = data
              .map((item) => {
                    "value": item["value"].toString(),
                    "title": item["title"].toString()
                  })
              .toList();
        });
        print("tyrePosts");
        print(tyrePosts);
        print(id_tyre_post2);
      } else {
        print("Failed: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error fetching data: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }

  Future GetDetailListBan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tire_vhcid = prefs.getString("tire_vhcid")!;
    var urlBase = "";
    urlBase =
        "${GlobalData.baseUrl}api/maintenance/sr/detail_ban_tire.jsp?method=get-list-sn-tire-ban-v1&vhcid=${tire_vhcid}";
    var urlData = urlBase;
    var encoded = Uri.encodeFull(urlData);
    print(urlData);
    Uri myUri = Uri.parse(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      setState(() {
        tireDetailsBan = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
      });
    } else {
      tireDetailsBan = [];
    }
  }

  Future getListDataTireDetailLogs(bool isload) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var vhcid = prefs.getString("tire_vhcid");
      var typeUnits = prefs.getString("tire_vhttype");
      EasyLoading.show();
      dataListTireDetail = [];
      var urlBase = "";
      urlBase =
          "${GlobalData.baseUrl}api/maintenance/sr/list_detail_log_tire.jsp?method=lookup-list-tire-logs-v1&vhcid=${vhcid}";
      var urlData = urlBase;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          tireDetailsLogs = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          if (tireDetailsLogs != null && tireDetailsLogs.length > 0) {
            log_vehicleid = vhcid!;
            log_km_sekarang = tireDetailsLogs[0]['km_sekarang'];
            log_vhtype = typeUnits!;
            log_location = tireDetailsLogs[0]['locid'];
          } else {
            log_vehicleid = vhcid!;
            log_vhtype = typeUnits!;
          }
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list detail opname", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data logs tire",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> updateTyreFitPost(String id_old, String id_new,
      String fitPostOld, String fitPostNew) async {
    String baseUrl =
        "${GlobalData.baseUrl}api/maintenance/sr/create_opname_sr_detai_tire.jsp";
    String method = "udpdate-tyre-fitpost";

    // Construct URL with parameters
    String urlData =
        "${baseUrl}?method=${method}&id_old=${id_old}&id_new=${id_new}&fit_post_old=${fitPostOld}&fit_post_new=${fitPostNew}";
    Uri myUri = Uri.parse(Uri.encodeFull(urlData));
    print('${myUri}');
    try {
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      print('response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var sttsCode = data['status_code'];
        print(data['status_code']);
        print(data['message']);
        if (sttsCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Succes update perubahan fitpost")),
          );
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Silahkan kembali ke page opname", "error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Silahkan kembali ke page opname")),
          );
        }
      } else {
        print("Failed: ${response.statusCode}");
        alert(globalScaffoldKey.currentContext!, 0,
            "Err,Gagal update perubahan fitpost", "error");
      }
    } catch (e) {
      print("Error: $e");
      alert(globalScaffoldKey.currentContext!, 0,
          "Exception ${e},Gagal update perubahan fitpost", "error");
    }
  }

  Future getListDataTireDetail(
      bool isload, String tyrepost, String vehicle_id) async {
    try {
      EasyLoading.show();
      dataListTireDetail = [];
      var urlBase = "";
      urlBase =
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_opname_sr.jsp?method=list-detail-tire-sr&tyrepost=${tyrepost}&vhcid=${vehicle_id}";
      var urlData = urlBase;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListTireDetail = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          if (dataListTireDetail != null && dataListTireDetail.length > 0) {
            serialNoController.text = dataListTireDetail[0]['tyresn'];
            patternController.text = dataListTireDetail[0]['pattern'];
          }
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list detail opname", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data ban",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  void _showInputDialog(BuildContext context, String fit_post, String nopol) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: Text('${title_header_tire} (${fit_post})'),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      readOnly: true,
                      controller: serialNoController,
                      decoration: InputDecoration(
                        labelText: 'Serial No',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      readOnly: true,
                      controller: patternController,
                      decoration: InputDecoration(
                        labelText: 'Pattern',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft, // Align to the left
                      child: Text(
                        "Depth/Tek. Angin",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: indepth,
                                decoration: InputDecoration(
                                  labelText: 'IN',
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 10),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // Space between the two TextFields
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: mid1depth,
                                decoration: InputDecoration(
                                  labelText: 'MID 1',
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 10),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // Space between the two TextFields
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: mid2depth,
                                decoration: InputDecoration(
                                  labelText: 'MID 2',
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 10),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // Space between the two TextFields
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: outdepth,
                                decoration: InputDecoration(
                                  labelText: 'OUT',
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 10),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // Space between the two TextFields
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Warna background
                                  borderRadius: BorderRadius.circular(
                                      8), // Agar sudutnya melengkung
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10), // Padding dalam container
                                child: TextField(
                                  controller: tekanan_angin,
                                  decoration: const InputDecoration(
                                    labelText: 'Tek. Angin',
                                    border: InputBorder
                                        .none, // Hilangkan border bawaan
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: tire_alasan_unit,
                      decoration: InputDecoration(
                        labelText: 'Alasan unit',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      items: tireDetailsStatus1.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'],
                          child: Text(data['alias'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tire_alasan_unit = newValue!;
                        });
                      },
                      hint: Text("Select status"),
                      isExpanded: true,
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: tire_status,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      items: tireDetailsStatus2.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'],
                          child: Text(data['alias'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tire_status = newValue!;
                        });
                      },
                      hint: Text("Select status"),
                      isExpanded: true,
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: tire_kerusakan_ban,
                      decoration: InputDecoration(
                        labelText: 'Kerusakan Ban',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      items: tireDetailsStatus3.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'],
                          child: Text(data['alias'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tire_kerusakan_ban = newValue!;
                        });
                      },
                      hint: Text("Select kerusakan ban"),
                      isExpanded: true,
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: tire_masalah_unit,
                      decoration: InputDecoration(
                        labelText: 'Masalah Unit',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      items: tireDetailsStatus4.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'],
                          child: Text(data['alias'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tire_masalah_unit = newValue!;
                        });
                      },
                      hint: Text("Select Masalah Unit"),
                      isExpanded: true,
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: tire_note,
                      decoration: InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ganti Ban',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: casing_yes,
                              onChanged: (bool? value) {
                                setState(() {
                                  casing_yes = value ?? false;
                                });
                              },
                            ),
                            const Text('Yes'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(5.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: _imagePhoto1 != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _imagePhoto1!,
                                        width: double.infinity,
                                        height: 50.0,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Ban"),
                                        onPressed: () async {
                                          await getImageFromCamera(
                                              context, "PHOTO1");
                                          setState(() {});
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(5.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: _imagePhoto2 != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _imagePhoto2!,
                                        width: double.infinity,
                                        height: 50.0,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Tapak"),
                                        onPressed: () async {
                                          await getImageFromCamera(
                                              context, "PHOTO2");
                                          setState(() {}); // Force UI refresh
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(5.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: _imagePhoto3 != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _imagePhoto3!,
                                        width: double.infinity,
                                        height: 50.0,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Damage"),
                                        onPressed: () async {
                                          await getImageFromCamera(
                                              context, "PHOTO3");
                                          setState(() {}); // Force UI refresh
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: tireDetails.isEmpty
                          ? Center(
                              child: Text(
                                'No tires added yet!',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: tireDetails.length,
                              itemBuilder: (context, index) {
                                if (index >= tireDetails.length) {
                                  return Container(); // Or handle the error case
                                }
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 0),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Serial No: ${tireDetails[index]["serialNo"]},Fit Post: ${tireDetails[index]["fitpost"]}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Pattern: ${tireDetails[index]["pattern"]}',
                                            ),
                                            Text(
                                              'IN Depth: ${tireDetails[index]["indepth"]},MID 1 Depth: ${tireDetails[index]["mid1depth"]},MID 2 Depth: ${tireDetails[index]["mid2depth"]},OUT Depth: ${tireDetails[index]["outdepth"]},Tek Angin: ${tireDetails[index]["tek_angin"]}',
                                            ),
                                            Text(
                                              'Ganti Ban: ${casing_yes == true ? "Yes" : ""}',
                                            ),
                                            Text(
                                              'Note: ${tireDetails[index]["note"]}',
                                            ),
                                            Text(
                                              'Photo Ban: ${tireDetails[index]["photo_ban"] != null || tireDetails[index]["photo_ban"] != '' ? 'Ada' : ''},Photo Tapak: ${tireDetails[index]["photo_tapak"] != null || tireDetails[index]["photo_tapak"] != '' ? 'Ada' : ''},Photo Damage: ${tireDetails[index]["photo_damage"] != null || tireDetails[index]["photo_damage"] != '' ? 'Ada' : ''}',
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            if (index >= 0 &&
                                                tireDetails.length > 0) {
                                              final tireDetail =
                                                  tireDetails[index];
                                              //print('Tire ID: ${tireDetail['vhcid']}, FitPost: ${tireDetail['fitpost']}');
                                              // Access other fields here as needed
                                              final List<Map<String, dynamic>>
                                                  items = await DatabaseHelper
                                                      .instance
                                                      .fetchItemsLogs();
                                              print(items);
                                              items.forEach((item) {
                                                print(
                                                    'after delete id_tire: ${item['id_tire']}, vhcid: ${item['vhcid']}');
                                              });
                                              print(
                                                  'pit post ${tireDetail['fitpost']}');
                                              int affected =
                                                  await DatabaseHelper.instance
                                                      .deleteItemLogsByFitPost(
                                                          tireDetail[
                                                              'fitpost']!);
                                              print('affected ${affected}');
                                              if (affected > 0) {
                                                print('success deleted');
                                                setState(() {
                                                  tireDetails.removeAt(index);
                                                });
                                              } else {
                                                print('fail deleted 2');
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var count = await DatabaseHelper.instance.countTableTire();
                  print('COUNT ${count}');
                  if (count > 0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm'),
                          content:
                              Text('Apakah ingin menghapus semua data Log?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close the dialog
                                print('User selected No');
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                //await DatabaseHelper.instance.dropTable('tire_logs');
                                tireDetails = [];
                                prefs.remove("tire_vhcid");
                                prefs.remove("tire_drvid");
                                prefs.remove("tire_vhttype");
                                Navigator.of(context).pop(); // Close dialog
                                var isDeleted = await DatabaseHelper.instance
                                    .deleteItemLogsAll();
                                if (isDeleted > 0) {
                                  print('database empty');
                                }
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Empty Draft'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  //showEditDialog(tire_vhttype);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Edit Position"),
                        content: TextField(
                          controller: old_fitpost,
                          decoration: const InputDecoration(
                            labelText: "FitPost OLD",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog utama
                              showEditDialog(
                                  tire_vhttype); // Panggil dialog edit
                            },
                            child: const Text("Edit"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Lanjut transaksi dengan input yang sudah ada
                              //String inputText = inputController.text;
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      );
                    },
                  );
                  // Close dialog
                },
                child: Text('Edit Posisi'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FrmServiceTire())); // Close dialog
                },
                child: Text('Finish'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Handle form submission
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String serialNo = serialNoController.text;
                  String pattern = patternController.text;
                  String _indepth = indepth.text;
                  String _outdepth = outdepth.text;
                  String _mid1depth = mid1depth.text;
                  String _mid2depth = mid2depth.text;
                  String _tekanan_angin = tekanan_angin.text;
                  String _tire_note = tire_note.text;
                  var casingYes = casing_yes == true ? 1 : 0;
                  var casingNO = casing_no == true ? 1 : 0;

                  // For now, just print the values

                  var exists =
                      tireDetails.any((el) => el['fitpost'] == fitpost);
                  var tire_vhcid = prefs.getString("tire_vhcid");
                  if (_indepth == null || _indepth == '') {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "IN Depth tidak boleh kosong", "error");
                  } else if (_outdepth == null || _outdepth == '') {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "OUT Depth tidak boleh kosong", "error");
                  } else if (_tekanan_angin == null || _tekanan_angin == '') {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Tekanan angin tidak boleh kosong", "error");
                  } else {
                    if (!exists) {
                      if (serialNoController.text != null &&
                          patternController.text != null &&
                          tire_vhcid != null) {
                        setState(() {
                          tireDetails.add({
                            "serialNo": serialNoController.text,
                            "pattern": patternController.text,
                            "indepth": indepth.text,
                            "outdepth": outdepth.text,
                            "mid1depth": mid1depth.text,
                            "mid2depth": mid2depth.text,
                            "tek_angin": tekanan_angin.text,
                            "fitpost": fitpost,
                            "vhcid": tire_vhcid,
                            "note": _tire_note,
                            "casing_yes": casingYes.toString(),
                            "casing_no": casingNO.toString(),
                            "alasan_unit": tire_alasan_unit.toString(),
                            "status_unit": tire_status.toString(),
                            "kerusakan_ban": tire_kerusakan_ban.toString(),
                            "masalah_unit": tire_masalah_unit.toString(),
                            "photo_ban": filePathImage1.toString(),
                            "photo_tapak": filePathImage2.toString(),
                            "photo_damage": filePathImage3.toString()
                          });
                        });
                        print('INSERT to Table');
                        await DatabaseHelper.instance.insertItemLogs({
                          'id_tire': serialNoController.text,
                          'vhcid': tire_vhcid,
                          'serial_no': serialNoController.text,
                          'pattern': patternController.text,
                          'in_depth': indepth.text,
                          'out_dept': outdepth.text,
                          'mid1_depth': mid1depth.text,
                          'mid2_depth': mid2depth.text,
                          'tekanan_angin': tekanan_angin.text,
                          'fitpost': fitpost,
                          'note': _tire_note,
                          "casing_yes": casingYes.toString(),
                          "casing_no": casingNO.toString(),
                          "alasan_unit": tire_alasan_unit.toString(),
                          "status_unit": tire_status.toString(),
                          "kerusakan_ban": tire_kerusakan_ban.toString(),
                          "masalah_unit": tire_masalah_unit.toString(),
                          "photo_ban": filePathImage1.toString(),
                          "photo_tapak": filePathImage2.toString(),
                          "photo_damage": filePathImage3.toString()
                        });
                      }
                      final List<Map<String, dynamic>> items =
                          await DatabaseHelper.instance.fetchItemsLogs();

                      // items.forEach((item) {
                      //   print(
                      //       'id_tire: ${item['id_tire']}, vhcid: ${item['vhcid']}');
                      // });
                      serialNoController.clear();
                      patternController.clear();
                      indepth.clear();
                      mid1depth.clear();
                      mid1depth.clear();
                      mid2depth.clear();
                      outdepth.clear();
                      tekanan_angin.clear();
                      filePathImage1 = "";
                      filePathImage2 = "";
                      filePathImage3 = "";
                      _imagePhoto1 = null;
                      _imagePhoto2 = null;
                      _imagePhoto3 = null;
                    } else {
                      // Handle the case when fitpost already exists, e.g., show a message or do nothing
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Fitpost already exists!")),
                      );
                    }
                  }
                },
                child: Text('Add to Draft'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<String> GetSerialNo(String _fitpost) {
    return SharedPreferences.getInstance().then((prefs) {
      String vhcid = prefs.getString("tire_vhcid")!;
      String arvhcid = vhcid.split("/")[0].toString();
      String serialNo = '';
      //print('_fitpost ${_fitpost}');
      var nopol = vhcid.split("/")[0];
      setState(() {
        title_header_tire = "${nopol} TRONTON";
      });
      if (tireDetailsBan.length > 0) {
        var datas = tireDetailsBan.firstWhere(
          (element) =>
              element['vhcid'] == arvhcid && element['post'] == _fitpost,
          orElse: () => {},
        );
        var km_rit = "${datas['km_rit']}/${datas['rit_trip']}";
        var a = datas != {}
            ? "${_fitpost}\nSN:${datas['serial_no']}\nUMUR KM/RIT:\n${km_rit}"
            : _fitpost;
        setState(() {
          serialNo = a;
        });
        //print('serialNo ${serialNo}');
      }
      return serialNo;
    });
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FrmServiceTire()));
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FrmServiceTire()));
        return Future.value(false);
      },
      child: new Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              iconSize: 20.0,
              onPressed: () {
                _goBack(globalScaffoldKey.currentContext!);
              },
            ),
            title: Text(
              '${tire_vhcid.split('/')[0]}/${tire_vhttype} (${tire_total_km} KM)',
              style: TextStyle(color: Colors.black),
            ),
          ),
          bottomNavigationBar: BottomActionBar(),
          body: SafeArea(
            key: globalScaffoldKey,
            child: new Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/img/triller.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                // Buttons for positions
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  right: MediaQuery.of(context).size.width * 0.25,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("A2"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'A2', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'A2',
                                'A2', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'A2', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data A2");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  left: MediaQuery.of(context).size.width * 0.25,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("A1"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'A1', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'A1',
                                'A1', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'A1', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data A1");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  right: MediaQuery.of(context).size.width * 0.25,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B3"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B3', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B3',
                                'B3', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B3', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B3");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  right: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B4"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B4', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B4',
                                'B4', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B4', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B4");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: MediaQuery.of(context).size.width * 0.235,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B2"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B2', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B2',
                                'B2', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B2', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B2");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B1"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B1', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B1',
                                'B1', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B1', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B1");
                      }
                    },
                  ),
                ), // B5-B8
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.295,
                  right: MediaQuery.of(context).size.width * 0.25,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B7"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B7', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B7',
                                'B7', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B7', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B7");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.295,
                  right: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B8"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B8', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B8',
                                'B8', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B8', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B8");
                      }
                    },
                  ),
                ), //SEREO
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.385,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: _createButton(
                      context,
                      'S2',
                      'S2',
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.295,
                  left: MediaQuery.of(context).size.width * 0.24,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B6"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B6', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B6',
                                'B6', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B6', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B6");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.295,
                  left: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("B5"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'B5', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'B5',
                                'B5', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'B5', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data B5");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.51,
                  right: MediaQuery.of(context).size.width * 0.26,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C3"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C3', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C3',
                                'C3', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C3', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C3");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.51,
                  right: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C4"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C4', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C4',
                                'C4', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C4', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C4");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.51,
                  left: MediaQuery.of(context).size.width * 0.24,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C2"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C2', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C2',
                                'C2', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C2', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C2");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.51,
                  left: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C1"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C1', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C1',
                                'C1', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C1', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C1");
                      }
                    },
                  ),
                ), //C5-C8
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.606,
                  right: MediaQuery.of(context).size.width * 0.256,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C7"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C7', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C7',
                                'C7', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C7', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C7");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.606,
                  right: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C8"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C8', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C8',
                                'C8', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C8', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C8");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.606,
                  left: MediaQuery.of(context).size.width * 0.24,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C6"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C6', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C6',
                                'C6', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C6', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C6");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.606,
                  left: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C5"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C5', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C5',
                                'C5', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C5', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C5");
                      }
                    },
                  ),
                ), //C9-C12
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  right: MediaQuery.of(context).size.width * 0.254,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C11"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C11', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C11',
                                'C11', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C11', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C11");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  right: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C12"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C12', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C12',
                                'C12', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C12', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C12");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  left: MediaQuery.of(context).size.width * 0.245,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C10"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C10', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C10',
                                'C10', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C10', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C10");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  left: MediaQuery.of(context).size.width * 0.01,
                  child: FutureBuilder<String>(
                    future: GetSerialNo("C9"), // Call the async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_showNoDataMessage) {
                          if (snapshot.hasData) {
                            return _createButton(
                                context,
                                snapshot.data!,
                                'C9', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          } else {
                            return _createButton(
                                context,
                                'C9',
                                'C9', // Pass the retrieved serial number to your button
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)));
                          }
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                      } else if (snapshot.hasError) {
                        return Text(
                            "Error: ${snapshot.error}"); // Show error if any
                      } else if (snapshot.hasData) {
                        return _createButton(
                          context,
                          snapshot.data!,
                          'C9', // Pass the retrieved serial number to your button
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      } else {
                        return Text("No data C9");
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.79,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: _createButton(
                      context,
                      'S1',
                      'S1',
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )
              ],
            ),
          )),
    );
  }

  void showEditDialog(String vh_fitpost) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih data baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: "0", // Make sure vh_fitpost matches the data type
                decoration: const InputDecoration(
                  labelText: 'Select FitPost',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                items: tyrePosts.map((tyre) {
                  return DropdownMenuItem<String>(
                    value: tyre["value"]
                        .toString(), // Ensure all values are Strings
                    child: Text(
                        tyre["title"].toString()), // Convert title to String
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    id_tyre_post2 = newValue
                        .toString(); // ?? "0"; // Default to "0" if null

                    // Find the corresponding title from tyrePosts
                    new_fit_post = tyrePosts
                        .firstWhere(
                            (tyre) =>
                                tyre["value"].toString() == newValue.toString(),
                            orElse: () => {"title": "Unknown"})["title"]
                        .toString();

                    print("Selected Title: $new_fit_post"); // Print the title
                  });
                },
                hint: const Text("Select FitPost"),
                isExpanded: true,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                var idold = "";
                var idnew = "";
                var oldfit = "";
                var newfit = "";
                id_tyre_post = tyrePosts
                    .firstWhere(
                      (item) => item['title'] == old_fitpost.text,
                      orElse: () => {'value': ""},
                    )['value']!
                    .toString();
                setState(() {
                  idold = id_tyre_post;
                  idnew = id_tyre_post2;
                  oldfit = old_fitpost.text;
                  newfit = new_fit_post == null || new_fit_post == ""
                      ? vh_fitpost
                      : new_fit_post;
                });
                await updateTyreFitPost(idold, idnew, oldfit, newfit);
                setState(() {
                  id_tyre_post = "0";
                  old_fitpost.text = "";
                  new_fit_post = "";
                });
                await GetDetailListBan();
                setState(() {});
                Navigator.of(context).pop(); // Tutup dialog edit
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget _createButton(BuildContext context, String label, String vh_fitpost,
      OutlinedBorder shape) {
    return SizedBox(
      width: 80, // Set desired width
      height: 60, // Set desired height
      child: ElevatedButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          resetTeks();
          fitpost = label;
          var nopol = prefs.getString("tire_vhcid");
          nopol = nopol?.split('/')[0];
          await getListDataTireDetail(true, vh_fitpost, nopol!);
          Timer(Duration(seconds: 1), () {
            setState(() {
              old_fitpost.text = vh_fitpost;
            });
            print("vh_fitpost ${vh_fitpost}, id_tyre_post ${id_tyre_post}");
            _showInputDialog(context, vh_fitpost, nopol!);
          });
        },
        style: ElevatedButton.styleFrom(
          shape: shape, // Custom ShapeBorder
          padding: EdgeInsets.zero, // No padding since size is fixed
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
        ),
      ),
    );
  }

  void GetSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tire_vhcid = prefs.getString("tire_vhcid")!;
    tire_vhttype = prefs.getString("tire_vhttype")!;
    tire_total_km = prefs.getString("tire_total_km")!;
  }

  @override
  void initState() {
    GetSession();
    getListDataTireDetailLogs(true);
    GetDetailListBan();
    GetDetailListStatus();
    fetchTyrePosts();
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showNoDataMessage = true;
        });
      }
    });
  }
}
