import 'dart:async';
import 'dart:io';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FrmNonTera extends StatefulWidget {
  @override
  FrmNonTeraState createState() => FrmNonTeraState();
}

class FrmNonTeraState extends State<FrmNonTera> {
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtLocation = new TextEditingController();
  TextEditingController txtLocation2 = new TextEditingController();
  TextEditingController txtLastValue = new TextEditingController();
  TextEditingController txtNextValue = new TextEditingController();
  TextEditingController txtVHCID = new TextEditingController();
  TextEditingController txtNmDate = new TextEditingController();
  TextEditingController txtLastValueDate = new TextEditingController();
  TextEditingController txtNextValueDate = new TextEditingController();
  TextEditingController txtSearchVehicle = new TextEditingController();
  TextEditingController txtSearchVehicleNontera = new TextEditingController();
  List<Map<String, dynamic>> dataListUnits = [];
  List<Map<String, dynamic>> dataListNonTera = [];
  String nm_date = "";
  String nama_type = "";
  var is_edit = false;
  var is_view = false;
  String last_value_date = "";
  String next_value_date = "";
  String dropdownvalue = 'Pilih Type';
  var itemsType = ['Pilih Type', 'KIR','KIR-HILANG', 'PAJAK', 'STNK','STNK-HILANG'];
  var status_type="";
  final picker = ImagePicker();
  File? _imageFRONT;
  File? _imageRIGHT;
  File? _imageLEFT;
  File? _imageREAR;
  File? _imageUPLOAD;
  File? _imageFRONTCOMPLETE;
  File? _imageCEKFISIK;
  File? _imageBAINT;
  File? _imageBAEXT;
  File? _imageSURAT;

  String filePathImageFRONT = "";
  String filePathImageRIGHT = "";
  String filePathImageLEFT = "";
  String filePathImageREAR = "";
  String filePathImageUPLOAD = "";
  String filePathImageFRONTCOMPLETE = "";
  String filePathImageCEKFISIK= "";
  String filePathImageBAINT= "";
  String filePathImageBAIEXT= "";
  String filePathImageSURAT2= "";

  File? _imagePAJAK;
  File? _imageKIR;
  File? _imageSTNK;

  String filePathImagePAJAK = "";
  String filePathImageKIR = "";
  String filePathImageSTNK = "";

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        },
        child: Scaffold(
          key: globalScaffoldKey,
          backgroundColor: Colors.blueAccent,
          appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(context);
                },
              ),
              centerTitle: true,
              title: Text('Non-Tera')),
          body: Container(
            constraints: BoxConstraints.expand(),
            color: HexColor("#f0eff4"),
            child: Stack(
              children: <Widget>[
                FrmNonTeraSubmit(context),
              ],
            ),
          ),
        ));
  }

  Future getListDataUnits(bool isload, String search) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();

      var urlData = Uri.parse(
          "${GlobalData.baseUrl}api/nontera/list_vehicle.jsp?method=list_units&vhcid=" +
              search);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListUnits = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data units",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data units",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataNonTera(bool isload, String search) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();

      var urlData = Uri.parse(
          "${GlobalData.baseUrl}api/nontera/list_non_tera.jsp?method=list_nontera&vhcid=" +
              search);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListNonTera = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data nontera",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data units",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget _buildDListDetailUnits(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.black45))),
                  child: Icon(Icons.settings_applications, color: Colors.black),
                ),
                title: Text(
                  "VHCID : ${item['vhcid']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text(
                      "Location : ${item['locid']}\nStnk : ${item['dt_stnk']}\nPajak : ${item['dt_pajak']}\nKir : ${item['dt_kir']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                ]),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Add"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    setState(() {
                      txtVHCID.text = item['vhcid'].toString();
                      txtLocation.text = item['locid'].toString();
                      if (dropdownvalue == "STNK") {
                        txtLastValueDate.text = item['dt_stnk'].toString();
                      } else if (dropdownvalue == "PAJAK") {
                        txtLastValueDate.text = item['dt_pajak'].toString();
                      } else if (dropdownvalue == "KIR") {
                        txtLastValueDate.text = item['dt_kir'].toString();
                      } else {
                        txtLastValueDate.text = "";
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                // SizedBox(width: 10),
                // Expanded(
                //     child: ElevatedButton.icon(
                //       icon: Icon(
                //         Icons.close,
                //         color: Colors.white,
                //         size: 15.0,
                //       ),
                //       label: Text("Close"),
                //       onPressed: () async {
                //         Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                //       },
                //       style: ElevatedButton.styleFrom(
                //           elevation: 0.0,
                //           backgroundColor: Colors.orangeAccent,
                //           padding:
                //           EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                //           textStyle:
                //           TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                //     )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDListDetailNonTera(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.black45))),
                  child: Icon(Icons.settings_applications, color: Colors.black),
                ),
                title: Text(
                  "VHCID : ${item['vhcid']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text(
                      "Request Date : ${item['date']}"
                      "\nTera Type ID : ${item['typeid']}"
                      "\nLast Value : ${item['lastvalue']}"
                      "\nNext Value : ${item['nextvalue']}"
                      "\nAmount : ${item['amount']}"
                      "\nLocid : ${item['locid']}"
                      "\nStatus : ${item['status']}",
                      style: TextStyle(color: Colors.black)),
                ]),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.no_accounts,
                    color: Colors.redAccent,
                    size: 15.0,
                  ),
                  label: Text("Close"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    showDialog(
                      context: globalScaffoldKey.currentContext!,
                      builder: (context) => new AlertDialog(
                        title: new Text('Information'),
                        content: new Text("Close data non-tera?"),
                        actions: <Widget>[
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text("Submit"),
                            onPressed: () async {
                              //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                              Navigator.of(globalScaffoldKey.currentContext!)
                                  .pop(false);
                              await Future.delayed(Duration(seconds: 1));
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              var user_id = prefs.getString("name");
                              var nmnbr = item['nmnbr'];
                              var vhcid = item['vhcid'];
                              if (nmnbr == null || nmnbr == "") {
                                alert(
                                    context,
                                    2,
                                    "Number Non-tera tidak boleh kosong",
                                    "warning");
                              } else if (vhcid == null || vhcid == "") {
                                alert(context, 2, "VHCID tidak boleh kosong",
                                    "warning");
                              } else {
                                await closeNonTera(user_id!, nmnbr, vhcid);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text("Cancel"),
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              reset_save();
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.orangeAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.redAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("View"),
                  onPressed: () async {
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                    is_view = true;
                    setState(() {
                      filePathImageFRONT = item['photo_front'] != null
                          ? item['photo_front']
                          : "";
                      filePathImageRIGHT = item['photo_right'] != null
                          ? item['photo_right']
                          : "";
                      filePathImageLEFT =
                          item['photo_left'] != null ? item['photo_left'] : "";
                      filePathImageREAR =
                          item['photo_rear'] != null ? item['photo_rear'] : "";
                      filePathImageUPLOAD = item['photo_nontera'] != null
                          ? item['photo_nontera']
                          : "";
                      filePathImageSTNK = item['photo_stnk'] != null
                          ? item['photo_stnk']
                          : "";
                      filePathImageKIR = item['photo_kir'] != null
                          ? item['photo_kir']
                          : "";
                      filePathImageBAINT = item['photo_baint'] != null
                          ? item['photo_baint']
                          : "";
                      filePathImageBAIEXT = item['photo_baext'] != null
                          ? item['photo_baext']
                          : "";
                      filePathImageCEKFISIK = item['photo_cekfisisk'] != null
                          ? item['photo_cekfisisk']
                          : "";
                      filePathImageSURAT2 = item['photo_surat2'] != null
                          ? item['photo_surat2']
                          : "";
                      filePathImageFRONTCOMPLETE = item['photo_surat2'] != null
                          ? item['photo_surat2']
                          : "";
                      txtLastValueDate.text = item['lastvalue'];
                      txtLocation.text = item['locid'];
                      txtNmDate.text = item['date'];
                      txtVHCID.text = item['vhcid'];
                      dropdownvalue = item['typeid'];
                      nama_type = dropdownvalue;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget listDataUnits(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: TextField(
              readOnly: false,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.grey.shade800),
              controller: txtSearchVehicle,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  suffixIcon: IconButton(
                    icon: new Image.asset(
                      "assets/img/search.png",
                      width: 32.0,
                      height: 32.0,
                    ),
                    onPressed: () async {
                      if(is_view==false){
                        if (txtSearchVehicle.text != null &&
                            txtSearchVehicle.text != "") {
                          await getListDataUnits(true, txtSearchVehicle.text);
                        }
                      }

                    },
                  ),
                  fillColor: HexColor("FFF6F1BF"),
                  filled: true,
                  isDense: true,
                  labelText: "VHCID",
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: dataListUnits == null ? 0 : dataListUnits.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailUnits(dataListUnits[index], index);
                  })),
        ],
      ),
    );
  }

  Widget listDataNonTera(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: TextField(
              readOnly: false,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.grey.shade800),
              controller: txtSearchVehicle,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  suffixIcon: IconButton(
                    icon: new Image.asset(
                      "assets/img/search.png",
                      width: 32.0,
                      height: 32.0,
                    ),
                    onPressed: () async {
                      if (txtSearchVehicleNontera.text != null &&
                          txtSearchVehicleNontera.text != "") {
                        await getListDataNonTera(
                            true, txtSearchVehicleNontera.text);
                      }
                    },
                  ),
                  fillColor: HexColor("FFF6F1BF"),
                  filled: true,
                  isDense: true,
                  labelText: "VHCID",
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount:
                      dataListNonTera == null ? 0 : dataListNonTera.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailNonTera(
                        dataListNonTera[index], index);
                  })),
        ],
      ),
    );
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    showDialog(
      context: contexs,
      builder: (contexs) => new AlertDialog(
        title: new Text('Information'),
        content: new Text("Get Picture"),
        actions: <Widget>[
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Camera"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture(namaPhoto, 'CAMERA');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Gallery"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture(namaPhoto, 'GALLERY');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void getPicture(String namaPhoto, opsi) async {
    if (opsi == 'GALLERY') {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        if (namaPhoto == "FRONT") {
          setState(() {
            _imageFRONT = File(pickedFile.path);
            List<int> imageBytes = _imageFRONT!.readAsBytesSync();
            var kb = _imageFRONT!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            print("MB " + mb.toString());
            print("KB " + kb.toString());
            filePathImageFRONT = base64Encode(imageBytes);

            ///is_edit_image_driver = true;
          });
        } else if (namaPhoto == "RIGHT") {
          setState(() {
            _imageRIGHT = File(pickedFile.path);
            List<int> imageBytes = _imageRIGHT!.readAsBytesSync();
            filePathImageRIGHT = base64Encode(imageBytes);
            //is_edit_image_sim = true;
          });
        } else if (namaPhoto == "LEFT") {

          setState(() {
            _imageLEFT = File(pickedFile.path);
            List<int> imageBytes = _imageLEFT!.readAsBytesSync();
            filePathImageLEFT = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        } else if (namaPhoto == "REAR") {
          setState(() {
            _imageREAR = File(pickedFile.path);
            List<int> imageBytes = _imageREAR!.readAsBytesSync();
            filePathImageREAR = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        } else if (namaPhoto == "UPLOAD") {
          setState(() {
            _imageUPLOAD = File(pickedFile.path);
            List<int> imageBytes = _imageUPLOAD!.readAsBytesSync();
            filePathImageUPLOAD = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "SURAT2") {
          print(filePathImageSURAT2);
          setState(() {
            _imageSURAT = File(pickedFile.path);
            List<int> imageBytes = _imageSURAT!.readAsBytesSync();
            filePathImageSURAT2 = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "CEKFISIK") {
          print(filePathImageSURAT2);
          setState(() {
            _imageCEKFISIK  = File(pickedFile.path);
            List<int> imageBytes = _imageCEKFISIK!.readAsBytesSync();
            filePathImageCEKFISIK = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "FRONT-COMPLETE") {
          setState(() {
            _imageFRONTCOMPLETE = File(pickedFile.path);
            List<int> imageBytes = _imageFRONTCOMPLETE!.readAsBytesSync();
            filePathImageFRONTCOMPLETE = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "BAINT") {
          setState(() {
            _imageBAINT = File(pickedFile.path);
            List<int> imageBytes = _imageBAINT!.readAsBytesSync();
            filePathImageBAINT = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "BAEXT") {
          setState(() {
            _imageBAEXT = File(pickedFile.path);
            List<int> imageBytes = _imageBAEXT!.readAsBytesSync();
            filePathImageBAIEXT = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        } else {
          setState(() {
            _imageFRONT = null;
            _imageRIGHT = null;
            _imageLEFT = null;
            _imageREAR = null;
            _imageUPLOAD = null;
            _imageKIR = null;
            _imageSTNK = null;
            _imageFRONTCOMPLETE = null;
            _imageSURAT= null;
            _imageBAINT= null;
            _imageBAEXT= null;

            filePathImageFRONT = "";
            filePathImageRIGHT = "";
            filePathImageLEFT = "";
            filePathImageREAR = "";
            filePathImageUPLOAD = "";
            filePathImageKIR = "";
            filePathImageSTNK = "";
            filePathImageFRONTCOMPLETE = "";
            filePathImageBAINT = "";
            filePathImageBAIEXT = "";
          });
        }
        //print(filePathImage);
      } else {
        setState(() {
          _imageFRONT = null;
          _imageRIGHT = null;
          _imageLEFT = null;
          _imageREAR = null;
          _imageUPLOAD = null;
          _imageKIR = null;
          _imageSTNK = null;
          _imageFRONTCOMPLETE = null;
          _imageSURAT= null;
          _imageBAINT= null;
          _imageBAEXT= null;

          filePathImageFRONT = "";
          filePathImageRIGHT = "";
          filePathImageLEFT = "";
          filePathImageREAR = "";
          filePathImageUPLOAD = "";
          filePathImageKIR = "";
          filePathImageSTNK = "";
          filePathImageFRONTCOMPLETE = "";
          filePathImageBAINT = "";
          filePathImageBAIEXT = "";
          print('No image selected.');
        });
      }
    } else {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        if (namaPhoto == "FRONT") {
          setState(() {
            _imageFRONT = File(pickedFile.path);
            List<int> imageBytes = _imageFRONT!.readAsBytesSync();
            var kb = _imageFRONT!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            print("MB " + mb.toString());
            print("KB " + kb.toString());
            filePathImageFRONT = base64Encode(imageBytes);

            ///is_edit_image_driver = true;
          });
        } else if (namaPhoto == "RIGHT") {
          setState(() {
            _imageRIGHT = File(pickedFile.path);
            List<int> imageBytes = _imageRIGHT!.readAsBytesSync();
            filePathImageRIGHT = base64Encode(imageBytes);
            //is_edit_image_sim = true;
          });
        } else if (namaPhoto == "LEFT") {
          setState(() {
            _imageLEFT = File(pickedFile.path);
            List<int> imageBytes = _imageLEFT!.readAsBytesSync();
            filePathImageLEFT = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        } else if (namaPhoto == "REAR") {
          setState(() {
            _imageREAR = File(pickedFile.path);
            List<int> imageBytes = _imageREAR!.readAsBytesSync();
            filePathImageREAR = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        } else if (namaPhoto == "UPLOAD") {
          setState(() {
            _imageUPLOAD = File(pickedFile.path);
            List<int> imageBytes = _imageUPLOAD!.readAsBytesSync();
            filePathImageUPLOAD = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "SURAT2") {
          print(filePathImageSURAT2);
          setState(() {
            _imageSURAT = File(pickedFile.path);
            List<int> imageBytes = _imageSURAT!.readAsBytesSync();
            filePathImageSURAT2 = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "CEKFISIK") {
          print(filePathImageSURAT2);
          setState(() {
            _imageCEKFISIK  = File(pickedFile.path);
            List<int> imageBytes = _imageCEKFISIK!.readAsBytesSync();
            filePathImageCEKFISIK = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "FRONT-COMPLETE") {
          setState(() {
            _imageFRONTCOMPLETE = File(pickedFile.path);
            List<int> imageBytes = _imageFRONTCOMPLETE!.readAsBytesSync();
            filePathImageFRONTCOMPLETE = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "BAINT") {
          setState(() {
            _imageBAINT = File(pickedFile.path);
            List<int> imageBytes = _imageBAINT!.readAsBytesSync();
            filePathImageBAINT = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "BAEXT") {
          setState(() {
            _imageBAEXT = File(pickedFile.path);
            List<int> imageBytes = _imageBAEXT!.readAsBytesSync();
            filePathImageBAIEXT = base64Encode(imageBytes);
            //is_edit_image_ktp = true;
          });
        } else {
          setState(() {
            _imageFRONT = null;
            _imageRIGHT = null;
            _imageLEFT = null;
            _imageREAR = null;
            _imageUPLOAD = null;
            _imageKIR = null;
            _imageSTNK = null;
            _imageFRONTCOMPLETE = null;
            _imageSURAT= null;
            _imageBAINT= null;
            _imageBAEXT= null;

            filePathImageFRONT = "";
            filePathImageRIGHT = "";
            filePathImageLEFT = "";
            filePathImageREAR = "";
            filePathImageUPLOAD = "";
            filePathImageKIR = "";
            filePathImageSTNK = "";
            filePathImageFRONTCOMPLETE = "";
            filePathImageBAINT = "";
            filePathImageBAIEXT = "";
          });
        }
        //print(filePathImage);
      } else {
        setState(() {
          _imageFRONT = null;
          _imageRIGHT = null;
          _imageLEFT = null;
          _imageREAR = null;
          _imageUPLOAD = null;
          _imageKIR = null;
          _imageSTNK = null;
          _imageFRONTCOMPLETE = null;
          _imageSURAT= null;
          _imageBAINT= null;
          _imageBAEXT= null;

          filePathImageFRONT = "";
          filePathImageRIGHT = "";
          filePathImageLEFT = "";
          filePathImageREAR = "";
          filePathImageUPLOAD = "";
          filePathImageKIR = "";
          filePathImageSTNK = "";
          filePathImageFRONTCOMPLETE = "";
          filePathImageBAINT = "";
          filePathImageBAIEXT = "";
          print('no image selected');
        });
      }
    }
  }

  void reset_save() {
    setState(() {
      txtNmDate.text = '';
      txtVHCID.text = '';
      txtLastValueDate.text = '';
      txtNextValueDate.text = '';
      txtLastValue.text = '';
      txtNextValue.text = '';
      txtLocation.text = '';
      filePathImageFRONT = '';
      filePathImageRIGHT = '';
      filePathImageLEFT = '';
      filePathImageREAR = '';
      filePathImageUPLOAD = '';
      _imageUPLOAD = null;
      _imageFRONT = null;
      _imageRIGHT = null;
      _imageLEFT = null;
      _imageREAR = null;
      nm_date = '';
      nama_type = '';
      dropdownvalue = 'Pilih Type';
    });
  }

  void reset_update() {
    setState(() {
      txtNmDate.text = '';
      txtVHCID.text = '';
      txtLastValueDate.text = '';
      txtNextValueDate.text = '';
      txtLocation2.text = '';
      filePathImageFRONT = '';
      filePathImageRIGHT = '';
      filePathImageLEFT = '';
      filePathImageREAR = '';
      filePathImageUPLOAD = '';
      _imageUPLOAD = null;
      _imageFRONT = null;
      _imageRIGHT = null;
      _imageLEFT = null;
      _imageREAR = null;
      nm_date = '';
      nama_type = '';
      dropdownvalue = 'Pilih Type';
    });
  }

  Future<String> saveNonTera(String user_id) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();
      print('SAVE ');
      var url_base = "";
      var encoded = Uri.encodeFull(
          "${GlobalData.baseUrl}api/nontera/save_or_update_non_tera.jsp");
      print(encoded);
      Uri urlEncode = Uri.parse(encoded);

      var data = {
        'method': "create-non-tera-v1",
        'terattypeid': dropdownvalue,
        'nmdate': txtNmDate.text,
        'vhcid': txtVHCID.text,
        'nmvaluetype': "DATE",
        'nmlastvalue': txtLastValueDate.text,
        'nmnextvalue': "",
        'locid': txtLocation.text,
        'photo_front': filePathImageFRONT,
        'photo_right': filePathImageRIGHT,
        'photo_left': filePathImageLEFT,
        'photo_rear': filePathImageREAR,
        'photo_nontera': filePathImageUPLOAD,
        'photo_cekfisik': filePathImageCEKFISIK,
        'photo_front_complete': filePathImageFRONTCOMPLETE,
        'photo_baint': filePathImageBAINT,
        'photo_baext': filePathImageBAIEXT,
        'photo_surat2': filePathImageSURAT2,
        'company': 'AN',
        'user_id': user_id,
      };
      print(data); //DEMO
      final response = await http.post(
        urlEncode,
        body: data,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
      );
      print(response.body);
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      setState(() {
        var message = "";
        var status_code = "100";
        if (response.statusCode == 200) {
          message = json.decode(response.body)["message"];
          status_code = json.decode(response.body)["status_code"];
          if (status_code == "200") {
            alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
            reset_save();
          } else {
            alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
          }
        } else {
          message = json.decode(response.body)["message"];
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
    return "";
  }

  Future<String?> closeNonTera(
      String user_id, String nmnbr, String vhcid) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();
      print('Close Nontera');
      var url_base = "";
      var encoded = Uri.encodeFull(
          "${GlobalData.baseUrl}api/nontera/save_or_update_non_tera.jsp");
      print(encoded);
      Uri urlEncode = Uri.parse(encoded);

      var data = {
        'method': "close-non-tera-v1",
        'vhcid': vhcid,
        'nmnbr': nmnbr,
        'company': 'AN',
        'user_id': user_id,
      };
      print(data); //DEMO
      final response = await http.post(
        urlEncode,
        body: data,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
      );
      print(response.body);
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      setState(() {
        var message = "";
        var status_code = "100";
        if (response.statusCode == 200) {
          message = json.decode(response.body)["message"];
          status_code = json.decode(response.body)["status_code"];
          if (status_code == "200") {
            alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
          } else {
            alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
          }
        } else {
          message = json.decode(response.body)["message"];
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
    return "";
  }

  Widget FrmNonTeraSubmit(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
        child: ListView(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: Card(
                  elevation: 2.0,
                  shadowColor: Color(0x802196F3),
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 2, right: 20, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButtonHideUnderline(
                              child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton(
                              isExpanded: true,
                              value: dropdownvalue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: itemsType.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                  if (dropdownvalue != "Pilih Type") {
                                    setState(() {
                                      nama_type = dropdownvalue;
                                      print('nama_type ${nama_type}');
                                      setState(() {
                                        _imageFRONT = null;
                                        _imageRIGHT = null;
                                        _imageLEFT = null;
                                        _imageREAR = null;
                                        _imageUPLOAD = null;
                                        _imageKIR = null;
                                        _imageSTNK = null;
                                        _imageFRONTCOMPLETE = null;
                                        _imageSURAT= null;
                                        _imageBAINT= null;
                                        _imageBAEXT= null;

                                        filePathImageFRONT = "";
                                        filePathImageRIGHT = "";
                                        filePathImageLEFT = "";
                                        filePathImageREAR = "";
                                        filePathImageUPLOAD = "";
                                        filePathImageKIR = "";
                                        filePathImageSTNK = "";
                                        filePathImageFRONTCOMPLETE = "";
                                        filePathImageBAINT = "";
                                        filePathImageBAIEXT = "";
                                      });
                                    });
                                  }
                                });
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: DateTimePicker(
                        //type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'yyyy-MM-dd',
                        controller: txtNmDate,
                        //initialValue: _initialValue,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'Request Date',
                        selectableDayPredicate: (date) {
                          return true;
                        },
                        onChanged: (val) => setState(() => nm_date = val),
                        validator: (val) {
                          setState(() => nm_date = val ?? '');
                          return null;
                        },
                        onSaved: (val) => setState(() => nm_date = val ?? ''),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 20, right: 20, bottom: 5),
                      child: TextField(
                        controller: txtVHCID,
                        readOnly: true,
                        decoration: new InputDecoration(
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                            hintText: 'VHCID',
                            suffixIcon: IconButton(
                              onPressed: () async {
                                if (dropdownvalue == "Pilih Type" ||
                                    dropdownvalue == null ||
                                    dropdownvalue == "") {
                                  alert(
                                      context,
                                      2,
                                      "Silahkan pilih type terlebih dahulu",
                                      "warning");
                                } else {
                                  await getListDataUnits(false, "");
                                  Timer(Duration(seconds: 1), () {
                                    showDialog(
                                        context:
                                            globalScaffoldKey.currentContext!,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('List Units'),
                                            content: listDataUnits(context),
                                            actions: <Widget>[
                                              new TextButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                            globalScaffoldKey
                                                                .currentContext!)
                                                        .pop(false);
                                                  },
                                                  child: new Text('Close')),
                                            ],
                                          );
                                        });
                                  });
                                }
                              },
                              icon: Icon(Icons.search),
                            ),
                            labelText: 'VHCID',
                            prefixIcon: const Icon(
                              Icons.car_rental,
                              color: Colors.blueAccent,
                            ),
                            prefixText: ' ',
                            //suffixText: 'USD',
                            suffixStyle: const TextStyle(color: Colors.green)),
                      ),
                    ),
                    if (is_edit == true) ...[
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 5),
                        child: TextField(
                          readOnly: true,
                          controller: txtLastValue,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'Last Value',
                              labelText: 'Last Value',
                              prefixIcon: const Icon(
                                Icons.date_range,
                                color: Colors.blueAccent,
                              ),
                              prefixText: ' ',
                              //suffixText: 'USD',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 20),
                        child: TextField(
                          controller: txtNextValue,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'Location',
                              labelText: 'Location',
                              prefixIcon: const Icon(
                                Icons.book,
                                color: Colors.blueAccent,
                              ),
                              prefixText: ' ',
                              //suffixText: 'USD',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 20, right: 20, bottom: 5),
                        child: TextField(
                          controller: txtLocation2,
                          readOnly: true,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'Location',
                              labelText: 'Location',
                              prefixIcon: const Icon(
                                Icons.pin_drop,
                                color: Colors.blueAccent,
                              ),
                              prefixText: ' ',
                              //suffixText: 'USD',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ),
                    ],
                    if (is_edit == false) ...[
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 5),
                        child: TextField(
                          readOnly: true,
                          controller: txtLastValueDate,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'Last Value',
                              labelText: 'Last Value',
                              prefixIcon: const Icon(
                                Icons.date_range,
                                color: Colors.blueAccent,
                              ),
                              prefixText: ' ',
                              //suffixText: 'USD',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.all(10.0),
                      //   child: DateTimePicker(
                      //     //type: DateTimePickerType.dateTimeSeparate,
                      //     dateMask: 'yyyy-MM-dd',
                      //     controller: txtLastValueDate,
                      //     //initialValue: _initialValue,
                      //     firstDate: DateTime(1950),
                      //     lastDate: DateTime(2100),
                      //     icon: Icon(Icons.event),
                      //     dateLabelText: 'Last Value',
                      //     selectableDayPredicate: (date) {
                      //       return true;
                      //     },
                      //     onChanged: (val) =>
                      //         setState(() => last_value_date = val),
                      //     validator: (val) {
                      //       setState(() => last_value_date = val ?? '');
                      //       return null;
                      //     },
                      //     onSaved: (val) =>
                      //         setState(() => last_value_date = val ?? ''),
                      //   ),
                      // ),
                      // Container(
                      //   margin: EdgeInsets.all(10.0),
                      //   child: DateTimePicker(
                      //     //type: DateTimePickerType.dateTimeSeparate,
                      //     dateMask: 'yyyy-MM-dd',
                      //     controller: txtNextValueDate,
                      //     //initialValue: _initialValue,
                      //     firstDate: DateTime(1950),
                      //     lastDate: DateTime(2100),
                      //     icon: Icon(Icons.event),
                      //     dateLabelText: 'Next Value',
                      //     selectableDayPredicate: (date) {
                      //       return true;
                      //     },
                      //     onChanged: (val) =>
                      //         setState(() => next_value_date = val),
                      //     validator: (val) {
                      //       setState(() => next_value_date = val ?? '');
                      //       return null;
                      //     },
                      //     onSaved: (val) =>
                      //         setState(() => next_value_date = val ?? ''),
                      //   ),
                      // ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 20, right: 20, bottom: 5),
                        child: TextField(
                          controller: txtLocation,
                          readOnly: false,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'Location',
                              // suffixIcon: IconButton(
                              //   onPressed: () {},
                              //   icon: Icon(Icons.search),
                              // ),
                              labelText: 'Location',
                              prefixIcon: const Icon(
                                Icons.pin_drop,
                                color: Colors.blueAccent,
                              ),
                              prefixText: ' ',
                              //suffixText: 'USD',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ),
                    ],
                    if(nama_type=='STNK' || nama_type=='PAJAK')...[
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () async {
                            await getImageFromCamera(context, "UPLOAD");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _imageUPLOAD != null &&  (is_edit == false || is_view==false)
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _imageUPLOAD!,
                                width: double.infinity,
                                height: 200.0,
                                scale: 0.8,
                                fit: BoxFit.cover,
                              ),
                            )
                                : _imageUPLOAD == null &&
                                (is_edit == true || is_view==true) &&
                                filePathImageUPLOAD != ""
                                ? Container(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageUPLOAD", //http://apps.tuluatas.com:8080/trucking
                                        ),
                                        fit: BoxFit.cover)),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius:
                                  BorderRadius.circular(10)),
                              width: double.infinity,
                              height: 200,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.camera,
                                  color: Colors.white,
                                  size: 15.0,
                                ),
                                label: Text(
                                    "Photo ${nama_type} to Upload"), onPressed: () {  },
                              ),
                            ),
                          ),
                        ),
                      )],//UPLOAD
                    if(nama_type=='STNK-HILANG' || nama_type=='KIR-HILANG')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          await getImageFromCamera(context, "FRONT");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageFRONT != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageFRONT!,
                                    width: double.infinity,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _imageFRONT == null &&
                              (is_edit == true || is_view==true) &&
                                      filePathImageFRONT != ""
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageFRONT", //http://apps.tuluatas.com:8080/trucking
                                                ),
                                                fit: BoxFit.cover)),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Photo front"), onPressed: () {  },
                                      ),
                                    ),
                        ),
                      ),
                    )],//FRONT
                    if(nama_type=='STNK-HILANG' || nama_type=='KIR-HILANG') ...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          await getImageFromCamera(context, "RIGHT");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageRIGHT != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageRIGHT!,
                                    width: double.infinity,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _imageRIGHT == null &&
                              (is_edit == true || is_view==true) &&
                                      filePathImageRIGHT != ""
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageRIGHT", //http://apps.tuluatas.com:8080/trucking
                                                ),
                                                fit: BoxFit.cover)),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Photo right"), onPressed: () {  },
                                      ),
                                    ),
                        ),
                      ),
                    )],//RIGHT
                    if(nama_type=='STNK-HILANG' || nama_type=='KIR-HILANG')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          await getImageFromCamera(context, "LEFT");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageLEFT != null &&  (is_edit == false || is_view==false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageLEFT!,
                                    width: double.infinity,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _imageLEFT == null &&
                              (is_edit == true || is_view==true) &&
                                      filePathImageLEFT != ""
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageLEFT", //http://apps.tuluatas.com:8080/trucking
                                                ),
                                                fit: BoxFit.cover)),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Photo left"), onPressed: () {  },
                                      ),
                                    ),
                        ),
                      ),
                    )],//LEFT
                    if(nama_type=='STNK-HILANG' || nama_type=='KIR-HILANG')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          await getImageFromCamera(context, "REAR");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageREAR != null &&  (is_edit == false || is_view==false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageREAR!,
                                    width: double.infinity,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _imageREAR == null &&
                              (is_edit == true || is_view==true) &&
                                      filePathImageREAR != ""
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: double.infinity,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageREAR", //http://apps.tuluatas.com:8080/trucking
                                                ),
                                                fit: BoxFit.cover)),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Photo rear"), onPressed: () {  },
                                      ),
                                    ),
                        ),
                      ),
                    )],//REAR
                    if(nama_type=='STNK-HILANG' || nama_type=='KIR-HILANG')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          await getImageFromCamera(context, "FRONT-COMPLETE");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageFRONTCOMPLETE != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageFRONTCOMPLETE!,
                              width: double.infinity,
                              height: 200.0,
                              scale: 0.8,
                              fit: BoxFit.cover,
                            ),
                          )
                              : _imageFRONTCOMPLETE == null &&
                              (is_edit == true || is_view==true) &&
                              filePathImageFRONTCOMPLETE != ""
                              ? Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageFRONTCOMPLETE", //http://apps.tuluatas.com:8080/trucking
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("Photo bagian depan mobil beserta supir"), onPressed: () {  },
                            ),
                          ),
                        ),
                      ),
                    )],//FRONT COMPLETE
                    if(nama_type=='STNK')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          await getImageFromCamera(context, "CEKFISIK");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageCEKFISIK != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageCEKFISIK!,
                              width: double.infinity,
                              height: 200.0,
                              scale: 0.8,
                              fit: BoxFit.cover,
                            ),
                          )
                              : _imageCEKFISIK == null &&
                              (is_edit == true || is_view==true) &&
                              filePathImageCEKFISIK != ""
                              ? Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageCEKFISIK", //http://apps.tuluatas.com:8080/trucking
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("Photo cek fisik"), onPressed: () {  },
                            ),
                          ),
                        ),
                      ),
                    )],//CEK FISIK
                    if(nama_type=='STNK-HILANG' || nama_type=='KIR-HILANG')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          await getImageFromCamera(context, "BAINT");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageBAINT != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageBAINT!,
                              width: double.infinity,
                              height: 200.0,
                              scale: 0.8,
                              fit: BoxFit.cover,
                            ),
                          )
                              : _imageBAINT == null &&
                              (is_edit == true || is_view==true) &&
                              filePathImageBAINT != ""
                              ? Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageBAINT", //http://apps.tuluatas.com:8080/trucking
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("Photo BA Internal cek fisik"), onPressed: () {  },
                            ),
                          ),
                        ),
                      ),
                    )],//BA INTERNAL
                    if(nama_type=='STNK-HILANG')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          await getImageFromCamera(context, "BAEXT");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageBAEXT != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageBAEXT!,
                              width: double.infinity,
                              height: 200.0,
                              scale: 0.8,
                              fit: BoxFit.cover,
                            ),
                          )
                              : _imageBAEXT == null &&
                              (is_edit == true || is_view==true) &&
                              filePathImageBAIEXT != ""
                              ? Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageBAIEXT", //http://apps.tuluatas.com:8080/trucking
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("Photo BA External"), onPressed: () {  },
                            ),
                          ),
                        ),
                      ),
                    )],//BA EXTERNAL
                    if(nama_type=='KIR')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          //_showPicker(context, "DRIVER");
                          print('KIR !!!');
                          await getImageFromCamera(context, "SURAT2");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageSURAT != null && (is_edit == false || is_view==false)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageSURAT!,
                              width: double.infinity,
                              height: 200.0,
                              scale: 0.8,
                              fit: BoxFit.cover,
                            ),
                          )
                              : _imageSURAT == null &&
                              (is_edit == true || is_view==true) &&
                              filePathImageSURAT2 != ""
                              ? Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "${GlobalData.baseUrlOri}photo-non-tera/$filePathImageSURAT2",
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                BorderRadius.circular(10)),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("Photo Kartu kir beserta Surat / Kertas kir"), onPressed: () {  },
                            ),
                          ),
                        ),
                      ),
                    )],//SURAT2
                    Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 5, right: 20, bottom: 0),
                        child: Row(children: <Widget>[
                          if (is_view == false) ...[
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("Save"),
                              onPressed: () async {
                                showDialog(
                                  context: globalScaffoldKey.currentContext!,
                                  builder: (context) => new AlertDialog(
                                    title: new Text('Information'),
                                    content: new Text("Submit non-tera?"),
                                    actions: <Widget>[
                                      new ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        label: Text("Submit"),
                                        onPressed: () async {
                                          //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                                          Navigator.of(globalScaffoldKey
                                                  .currentContext!)
                                              .pop(false);
                                          await Future.delayed(
                                              Duration(seconds: 1));
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          var user_id = prefs.getString("name");
                                          if (dropdownvalue.toString() ==
                                              'Pilih Type') {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "Type belum di pilih",
                                                "error");
                                          } else if (txtVHCID.text == null ||
                                              txtVHCID.text == "") {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "VHCID tidak boleh kosong",
                                                "error");
                                          } else if (txtLastValueDate.text ==
                                                  null ||
                                              txtLastValueDate.text == "") {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "Last Value tidak boleh kosong",
                                                "error");
                                          }
                                          else if (txtLocation.text == null ||
                                              txtLocation.text == "") {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "Cabang/Lokasi tidak boleh kosong",
                                                "error");
                                          } else if (txtNmDate.text == null ||
                                              txtNmDate.text == "") {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "Request Date tidak boleh kosong",
                                                "error");
                                          } else if (user_id == null ||
                                              user_id == "") {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "USER ID tidak boleh kosong",
                                                "error");
                                          } else {
                                            await saveNonTera(user_id);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Colors.blueAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      new ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.save,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        label: Text("Cancel"),
                                        onPressed: () async {
                                          Navigator.of(context).pop(false);
                                          reset_save();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Colors.orangeAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ))
                          ],
                          if (is_view == true) ...[
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("Reset"),
                              onPressed: () async {
                                setState(() {
                                  is_view = false;
                                });
                                reset_save();
                                reset_update();
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ))
                          ],
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.details,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text("Detail Non-tera"),
                            onPressed: () async {
                              await getListDataNonTera(false, "");
                              Timer(Duration(seconds: 1), () {
                                showDialog(
                                    context: globalScaffoldKey.currentContext!,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('List Non-tera'),
                                        content: listDataNonTera(context),
                                        actions: <Widget>[
                                          new TextButton(
                                              onPressed: () {
                                                Navigator.of(globalScaffoldKey
                                                        .currentContext!)
                                                    .pop(false);
                                              },
                                              child: new Text('Close')),
                                        ],
                                      );
                                    });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          )),
                        ]))
                  ])))
        ]));
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var edit = prefs.getString("non_tera_is_edit");
    if (edit != null && edit != "" && edit == "true") {
      is_edit = true;
    }
  }

  @override
  void initState() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }
}
