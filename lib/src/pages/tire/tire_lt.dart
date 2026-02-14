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
String tire_vhttype = "";
String tire_total_km = "0";
String tire_alasan_unit = "";
String tire_status = "";
String tire_kerusakan_ban = "";
String tire_masalah_unit = "";
String title_header_tire = "";

List<Map<String, String>> tyrePosts = [];
String selectedTyrePost = "0";
String new_fit_post = '';
String id_tyre_post = "0";
String id_tyre_post2 = "0";

List<Map<String, String>> tireDetails = []; // List to hold tire data

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
      var vhcid = prefs.getString("tire_vhcid") ?? "";
      var typeUnits = prefs.getString("tire_vhttype") ?? "";
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
            log_vehicleid = vhcid ?? "";
            log_vhtype = typeUnits ?? "";
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
    return Container(
      color: Colors.white, // Background color of the bar
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => FrmServiceTire()));
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
    );
  }
}

class TireLT extends StatefulWidget {
  @override
  _TireLTState createState() => _TireLTState();
}

class _TireLTState extends State<TireLT> {
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
    String tire_vhcid = prefs.getString("tire_vhcid") ?? "";
    var urlBase = "";
    urlBase =
    "${GlobalData
        .baseUrl}api/maintenance/sr/detail_ban_tire.jsp?method=get-status-sn-tire-ban-v1&vhcid=${tire_vhcid}";
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
    String vhcid = prefs.getString("tire_vhcid") ?? "";

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
              .map((item) =>
          {
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
    String tire_vhcid = prefs.getString("tire_vhcid") ?? "";
    tireDetailsBan = [];
    var urlBase = "";
    urlBase =
    "${GlobalData
        .baseUrl}api/maintenance/sr/detail_ban_tire.jsp?method=get-list-sn-tire-ban-v1&vhcid=${tire_vhcid}";
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
      var vhcid = prefs.getString("tire_vhcid") ?? "";
      var typeUnits = prefs.getString("tire_vhttype") ?? "";
      EasyLoading.show();
      dataListTireDetail = [];
      var urlBase = "";
      urlBase =
      "${GlobalData
          .baseUrl}api/maintenance/sr/list_detail_log_tire.jsp?method=lookup-list-tire-logs-v1&vhcid=${vhcid}";
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
            log_vehicleid = vhcid ?? "";
            log_vhtype = typeUnits ?? "";
          }
        });
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Gagal load data list detail opname", "error");
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Client, Load data logs tire", "error");
      }
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> updateTyreFitPost(String id_old, String id_new,
      String fitPostOld, String fitPostNew) async {
    String baseUrl =
        "${GlobalData
        .baseUrl}api/maintenance/sr/create_opname_sr_detai_tire.jsp";
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
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 0, "Silahkan kembali ke page opname", "error");
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Silahkan kembali ke page opname")),
          );
        }
      } else {
        print("Failed: ${response.statusCode}");
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Err,Gagal update perubahan fitpost", "error");
        }
      }
    } catch (e) {
      print("Error: $e");
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Exception ${e},Gagal update perubahan fitpost", "error");
      }
    }
  }

  Future getListDataTireDetail(bool isload, String tyrepost,
      String vehicle_id) async {
    try {
      EasyLoading.show();
      dataListTireDetail = [];
      var urlBase = "";
      urlBase =
      "${GlobalData
          .baseUrl}api/maintenance/sr/list_data_opname_sr.jsp?method=list-detail-tire-sr&tyrepost=${tyrepost}&vhcid=${vehicle_id}";
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
            id_tyre_post = dataListTireDetail[0]['id'];
          }
        });
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Gagal load data list detail opname", "error");
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Client, Load data ban", "error");
      }
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
