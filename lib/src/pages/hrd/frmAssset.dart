import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dms_anp/src/pages/hrd/listAsset.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class FrmAsset extends StatefulWidget {
  @override
  _FrmAssetState createState() => _FrmAssetState();
}

class _FrmAssetState extends State<FrmAsset> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();

  TextEditingController txtAssetID = new TextEditingController();
  TextEditingController txtAssetName = new TextEditingController();
  TextEditingController txtAssetType = new TextEditingController();
  TextEditingController txtAssetOrder = new TextEditingController();
  TextEditingController txtDateExpired = new TextEditingController();
  TextEditingController txtAssetCustomer = new TextEditingController();
  TextEditingController txtAssetNoseri = new TextEditingController();
  TextEditingController txtUser = new TextEditingController();
  TextEditingController txtDivisi = new TextEditingController();
  TextEditingController txtService = new TextEditingController();
  TextEditingController txtCustService = new TextEditingController();
  //TextEditingController selAssetStatus = new TextEditingController();
  TextEditingController txtAssetNotes = new TextEditingController();
  TextEditingController txtService1 = new TextEditingController();
  TextEditingController txtService2 = new TextEditingController();
  TextEditingController txtService3 = new TextEditingController();
  TextEditingController txtHardisk = new TextEditingController();
  TextEditingController txtMemory = new TextEditingController();
  //TextEditingController selType = new TextEditingController();
  TextEditingController photo = new TextEditingController();
  String status_code = "";
  String message = "";
  String _assetOrder = "";
  String _dateExpire = "";
  String _service1 = "";
  String _service2 = "";
  String _service3 = "";
  File? _imageAsset;
  File? _imageAssetTD;
  String _seltype = "";
  String _seldivisi = "";
  String _selstatus = "";
  String _pathImageAsset = "";
  String _pathImageAssetTD = "";
  String locid = "";
  String userid = "";
  String buttonEvent = "Save";
  bool is_edit_image_asset = false;
  bool is_edit_image_asset_td = false;

  Future<void> resetTeks() async {
    setState(() {
      txtAssetID.text = "";
      txtAssetName.text = "";
      txtAssetType.text = "";
      txtAssetOrder.text = "";
      txtAssetCustomer.text = "";
      txtAssetNoseri.text = "";
      txtUser.text = "";
      _seldivisi = "";
      txtService.text = "";
      txtCustService.text = "";
      _selstatus = "";
      txtAssetNotes.text = "";
      txtService1.text = "";
      txtService2.text = "";
      txtService3.text = "";
      txtHardisk.text = "";
      txtMemory.text = "";
      _seltype = "";
      _seldivisi = "";
      _selstatus = "";
      photo.text = "";
      status_code = "";
      message = "";
      _assetOrder = "";
      _dateExpire = "";
      _service1 = "";
      _service2 = "";
      _service3 = "";
      _imageAsset = null;
      _imageAssetTD = null;
      removeSesion();
      buttonEvent="Save";
      _pathImageAsset = "";
      _pathImageAssetTD = "";
    });
  }

  _goBack(BuildContext context) async{
    removeSesion();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }
  void removeSesion()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_edit_asset",false);
    prefs.remove("is_edit_asset");
    prefs.remove("asset_assetid");
    prefs.remove("asset_asset_name");
    prefs.remove("asset_asset_type");
    prefs.remove("asset_asset_order");
    prefs.remove("asset_asset_customer");
    prefs.remove("asset_no_seri");
    prefs.remove("asset_asset_user");
    prefs.remove("asset_divisi");
    prefs.remove("asset_service");
    prefs.remove("asset_asset_customer_service");
    prefs.remove("asset_status");
    prefs.remove("asset_notes");
    prefs.remove("asset_service1");
    prefs.remove("asset_service2");
    prefs.remove("asset_service3");
    prefs.remove("asset_service3");
    prefs.remove("asset_hardisk");
    prefs.remove("asset_memory");
    prefs.remove("asset_type");
    prefs.remove("expired_date");
  }
  Future updateTeks()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var assetid = prefs.getString("asset_assetid");
      _pathImageAsset = assetid.toString()+".jpg";
      _pathImageAssetTD = "TDTM_"+assetid.toString()+".jpg";

      print("${GlobalData.baseUrlOri}photo/asset/$_pathImageAsset");
      txtAssetID.text = assetid==null || assetid=="null" || assetid == "" ? "":assetid;
      var assetname = prefs.getString("asset_name");
      txtAssetName.text = assetname==null || assetname=="null" || assetname == "" ? "":assetname;
      var assetType = prefs.getString("asset_type");
      txtAssetType.text = assetType==null || assetType=="null" || assetType == "" ? "":assetType;
      var assetOrder = prefs.getString("asset_order");
      txtAssetOrder.text = assetOrder==null || assetOrder=="null" || assetOrder == "" ? "":assetOrder;
      var assetCustomer = prefs.getString("asset_customer");
      txtAssetCustomer.text = assetCustomer==null || assetCustomer=="null" || assetCustomer == "" ? "":assetCustomer;
      var no_seri = prefs.getString("asset_no_seri");
      print("no_seri ${no_seri}");
      txtAssetNoseri.text = no_seri==null || no_seri=="null" || no_seri == "" ? "":no_seri;
      var assetUser = prefs.getString("asset_user");
      txtUser.text = assetUser==null || assetUser=="null" || assetUser == "" ? "":assetUser;
      var pdivisi = prefs.getString("asset_divisi");
      _seldivisi = pdivisi==null || pdivisi=="null" || pdivisi == "" ? "":pdivisi;
      print('_seldivisi ${_seldivisi}');
      var pservice = prefs.getString("asset_service");
      txtService.text = pservice==null || pservice=="null" || pservice == "" ? "":pservice;
      var pcustomerService = prefs.getString("asset_customer_service");
      txtCustService.text = pcustomerService==null || pcustomerService=="null" || pcustomerService == "" ? "":pcustomerService;
      var pstatus = prefs.getString("asset_status");
      _selstatus = pstatus==null || pstatus=="null" || pstatus == "" ? "":pstatus;
      var pnotes = prefs.getString("asset_notes");
      txtAssetNotes.text = pnotes==null || pnotes=="null" || pnotes == "" ? "":pnotes;
      var pservice1 = prefs.getString("asset_service1");
      txtService1.text = pservice1==null || pservice1=="null" || pservice1 == "" ? "":pservice1;
      var pservice2 = prefs.getString("asset_service2");
      txtService2.text = pservice2==null || pservice2=="null" || pservice2 == "" ? "":pservice2;
      var pservice3 = prefs.getString("asset_service3");
      txtService3.text = pservice3==null || pservice3=="null" || pservice3 == "" ? "":pservice3;
      var phardisk = prefs.getString("asset_hardisk");
      txtHardisk.text = phardisk==null || phardisk=="null" || phardisk == "" ? "":phardisk;
      var pmemory = prefs.getString("asset_memory");
      txtMemory.text = pmemory==null || pmemory=="null" || pmemory == "" ? "":pmemory;
      var ptype = prefs.getString("asset_type");
      _seltype = ptype==null || ptype=="null" || ptype == "" ? "":ptype;

      var pexpired_date = prefs.getString("asset_expired_date");
      _dateExpire = pexpired_date==null || pexpired_date=="null" || pexpired_date == "" ? "":pexpired_date;
    });
  }
  Future<void> getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var is_edit = prefs.getBool("is_edit_asset");
    print("IS EDIT ${is_edit}");
    if (is_edit != null && is_edit == true){
      await updateTeks();
      setState((){
        is_edit_image_asset = false;
        buttonEvent="Update";
      });
    }else{
      setState(() {
        buttonEvent="Save";
        removeSesion();
      });
    }
  }
  void getPicture(String namaPhoto,opsi) async{
    //XFile pickedFile;
    if(opsi=='GALLERY'){
      final pickedFile =
      await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      print('pickedFile ${pickedFile}');
      if (pickedFile != null) {
        if(namaPhoto=='ASSET'){
          setState(() {
            _imageAsset = File(pickedFile.path);
            List<int> imageBytes = _imageAsset!.readAsBytesSync();
            var kb = _imageAsset!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            _pathImageAsset = base64Encode(imageBytes);
            print(_pathImageAsset);
            is_edit_image_asset = true;
          });

        }
        if(namaPhoto=='TD'){
          setState(() {
            _imageAssetTD = File(pickedFile.path);
            List<int> imageBytes = _imageAssetTD!.readAsBytesSync();
            var kb = _imageAssetTD!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            _pathImageAssetTD = base64Encode(imageBytes);
            is_edit_image_asset_td = true;
          });

        }
      }
    }else{
      final pickedFile =
      await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      print('pickedFile ${pickedFile}');
      if (pickedFile != null) {
        if(namaPhoto=='ASSET'){
          setState(() {
            _imageAsset = File(pickedFile.path);
            List<int> imageBytes = _imageAsset!.readAsBytesSync();
            var kb = _imageAsset!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            _pathImageAsset = base64Encode(imageBytes);
            print(_pathImageAsset);
            is_edit_image_asset = true;
          });

        }
        if(namaPhoto=='TD'){
          setState(() {
            _imageAssetTD = File(pickedFile.path);
            List<int> imageBytes = _imageAssetTD!.readAsBytesSync();
            var kb = _imageAssetTD!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            _pathImageAssetTD = base64Encode(imageBytes);
            is_edit_image_asset_td = true;
          });

        }
      }
    }

    //await picker.pickImage(source: ImageSource.camera, imageQuality: 50);


  }

  Future getImageFromCamera(String namaPhoto) async {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Information'),
        content: new Text("Get Picture"),
        actions: <Widget>[
          new ElevatedButton.icon(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Camera"),
            onPressed: () async{
              Navigator.of(context).pop(false);
              //await getPicture(namaPhoto,'CAMERA');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 0),
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.save,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Gallery"),
            onPressed: () async {
              Navigator.of(context).pop(false);
              //await getPicture(namaPhoto,'GALLERY');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 0),
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

  }

  Future getImageFromCameraNew(BuildContext context,String namaPhoto) async {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
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
            onPressed: () async{
              Navigator.of(context).pop(false);
               getPicture(namaPhoto,'CAMERA');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 0),
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Gallery"),
            onPressed: () async {
              Navigator.of(context).pop(false);
               getPicture(namaPhoto,'GALLERY');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 0),
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

  }

  void _showAlert(BuildContext? ctx, int type, String message, String colorInfo) {
    if (ctx != null) alert(ctx, type, message, colorInfo);
  }

  void _showPicker(context, String namaPhoto) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImageFromCamera(namaPhoto);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void updateAsset() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var asset_id = txtAssetID.text;
      var asset_name = txtAssetName.text;
      var asset_type = _seltype;
      var asset_order = txtAssetOrder.text;
      var asset_customer = txtAssetCustomer.text;
      var no_seri = txtAssetNoseri.text;
      var user = txtUser.text;
      var seldivisi = _seldivisi;
      var service = txtService.text;
      var customer_service = txtCustService.text;
      var asset_status = _selstatus;
      var asset_notes = txtAssetNotes.text;
      var service1 = txtService1.text;
      var service2 = txtService2.text;
      var service3 = txtService3.text;
      var hardisk = txtHardisk.text;
      var memory = txtMemory.text;
      var seltype = _seltype;
      var userid = prefs.getString("name");
      if (asset_id == null || asset_id == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset ID tidak boleh kosong", "error");
      } else if (asset_name == null || asset_name == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset name tidak boleh kosong", "error");
      } else if (asset_type == null || asset_type == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset type tidak boleh kosong", "error");
      } else if (asset_order == null || asset_order == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset Order tidak boleh kosong", "error");
      } else if (asset_customer == null || asset_customer == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset customer tidak boleh kosong", "error");
      } else if (no_seri == null || no_seri == "") {
        _showAlert(globalScaffoldKey.currentContext, 0, "No Seri tidak boleh kosong",
            "error");
      } else if (user == null || user == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "User tidak boleh kosong", "error");
      } else if (seldivisi == null || seldivisi == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Divisi tidak boleh kosong", "error");
      }else if (asset_status == null || asset_status == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Status tidak boleh kosong", "error");
      }else if (asset_notes == null || asset_notes == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Notes tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded =Uri.encodeFull("${GlobalData.baseUrlOri}api/edp/asset.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'update-new-asset-v1',
          'ASSETID': asset_id,
          'ASSETNAME': asset_name,
          'ASSETTYPE': asset_type,
          'ASSETORDER': asset_order,
          'DATEEXPIRE': _dateExpire,
          'ASSETCUSTOMER': asset_customer,
          'ASSETNOSERI': no_seri,
          'ASSETUSER': user,
          'ASSETDIVISI': seldivisi,
          'ASSETSERVICE': service,
          'ASSETCUSTSERVICE': customer_service,
          'ASSETSERVICE1': service1,
          'ASSETSTATUS': asset_status,
          'ASSETNOTES': asset_notes,
          'ASSETSERVICE2': service2,
          'ASSETSERVICE3': service3,
          'HARDISK': hardisk,
          'MEMORY': memory,
          'TYPE': seltype,
          'userid': userid,
          'filename':_pathImageAsset
        };
        print(data);
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
          if (response.statusCode == 200) {
            var _status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(response);
            if (_status_code == 200) {
              final ctx = globalScaffoldKey.currentContext;
              if (ctx != null) {
                showDialog(
                  context: ctx,
                  builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blue,
                          padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } else {
              _showAlert(globalScaffoldKey.currentContext, 0,
                  "Gagal menyimpan ${message}", "error");
            }
          } else {
            _showAlert(globalScaffoldKey.currentContext, 0,
                "Gagal menyimpan ${response.statusCode}", "error");
          }
        }});
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      _showAlert(globalScaffoldKey.currentContext, 0, "Failed, ${e.toString()} ",
          "error");
      print(e.toString());
    }
  }

  void saveAsset() async {
    //try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var asset_id = txtAssetID.text;
      var asset_name = txtAssetName.text;
      var asset_type = _seltype;
      var asset_order = txtAssetOrder.text;
      var asset_customer = txtAssetCustomer.text;
      var no_seri = txtAssetNoseri.text;
      var user = txtUser.text;
      var seldivisi = _seldivisi;
      var service = txtService.text;
      var customer_service = txtCustService.text;
      var asset_status = _selstatus;
      var asset_notes = txtAssetNotes.text;
      var service1 = txtService1.text;
      var service2 = txtService2.text;
      var service3 = txtService3.text;
      var hardisk = txtHardisk.text;
      var memory = txtMemory.text;
      var seltype = _seltype;
      var userid = prefs.getString("name");
      if (asset_id == null || asset_id == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset ID tidak boleh kosong", "error");
      }else if (asset_name == null || asset_name == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset name tidak boleh kosong", "error");
      } else if (asset_type == null || asset_type == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset type tidak boleh kosong", "error");
      } else if (asset_order == null || asset_order == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset Order tidak boleh kosong", "error");
      } else if (asset_customer == null || asset_customer == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset customer tidak boleh kosong", "error");
      } else if (no_seri == null || no_seri == "") {
        _showAlert(globalScaffoldKey.currentContext, 0, "No Seri tidak boleh kosong",
            "error");
      } else if (user == null || user == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "User tidak boleh kosong", "error");
      } else if (seldivisi == null || seldivisi == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Divisi tidak boleh kosong", "error");
      }else if (asset_status == null || asset_status == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Status tidak boleh kosong", "error");
      }else if (asset_notes == null || asset_notes == "") {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Notes tidak boleh kosong", "error");
      }else if (_imageAsset == null) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Photo tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded =Uri.encodeFull("${GlobalData.baseUrlOri}api/edp/asset.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-new-asset-v1',
          'ASSETID': asset_id,
          'ASSETNAME': asset_name,
          'ASSETTYPE': asset_type,
          'ASSETORDER': asset_order,
          'DATEEXPIRE': _dateExpire,
          'ASSETCUSTOMER': asset_customer,
          'ASSETNOSERI': no_seri,
          'ASSETUSER': user,
          'ASSETDIVISI': seldivisi,
          'ASSETSERVICE': service,
          'ASSETCUSTSERVICE': customer_service,
          'ASSETSERVICE1': service1,
          'ASSETSTATUS': asset_status,
          'ASSETNOTES': asset_notes,
          'ASSETSERVICE2': service2,
          'ASSETSERVICE3': service3,
          'HARDISK': hardisk,
          'MEMORY': memory,
          'TYPE': seltype,
          'userid': userid,
          'filename':_pathImageAsset
        };
        print(data);
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

          if (response.statusCode == 200) {
            var _status_code = json.decode(response.body)["status_code"];
            print("response.statusCode ${_status_code}");
            //status_code = _status_code;
            message = json.decode(response.body)["message"];
            print("status_code ${status_code}");
            if (_status_code == 200) {
              final ctx = globalScaffoldKey.currentContext;
              if (ctx != null) {
                showDialog(
                  context: ctx,
                  builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("${message}"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blue,
                          padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              }
            } else {
              _showAlert(globalScaffoldKey.currentContext, 0,
                  "Gagal menyimpan ${message}", "error");
            }
          } else {
            _showAlert(globalScaffoldKey.currentContext, 0,
                "Gagal menyimpan ${response.statusCode}", "error");
          }
        });
      }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          //backgroundColor: Color(0xFFFF1744),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('Form Create Asset')),
        body: Container(
          key: globalScaffoldKey,
          constraints: BoxConstraints.expand(),
          color: HexColor("#f0eff4"),
          child: Stack(
            children: <Widget>[
              _getContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.blue, spreadRadius: 1),
          ],
        ),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            clipBehavior: Clip.antiAlias,
            child: Column(children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAssetID,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Asset ID",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAssetName,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Asset Name",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAssetType,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Asset Type",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              SmartSelect<String>.single(
                title: 'Asset Group Type',
                placeholder: 'Pilih Asset',
                selectedValue: _seldivisi,
                onChange: (state) {
                  setState(() => _seldivisi = state.value);
                },
                choiceType: S2ChoiceType.radios,
                choiceItems: choices.assetSelDivisi,
                modalType: S2ModalType.popupDialog,
                modalHeader: false,
                modalConfig: const S2ModalConfig(
                  style: S2ModalStyle(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtAssetOrder,
                  //initialValue: _initialValue,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Asset Order',
                  selectableDayPredicate: (date) {
                    return true;
                  },
                  onChanged: (val) { setState(() => _assetOrder = val ?? ''); },
                  validator: (val) {
                    setState(() => _assetOrder = val ?? '');
                    return null;
                  },
                  onSaved: (val) { setState(() => _assetOrder = val ?? ''); },
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtDateExpired,
                  //initialValue: _initialValue,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Expire Date',
                  selectableDayPredicate: (date) {
                    return true;
                  },
                  onChanged: (val) { setState(() => _dateExpire = val ?? ''); },
                  validator: (val) {
                    setState(() => _dateExpire = val ?? '');
                    return null;
                  },
                  onSaved: (val) { setState(() => _dateExpire = val ?? ''); },
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAssetCustomer,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Customer",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAssetNoseri,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "No Seri",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtUser,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "User",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              SmartSelect<String>.single(
                title: 'Divisi',
                placeholder: 'Pilih Divisi',
                selectedValue: _seldivisi,
                onChange: (state) {
                  setState(() => _seldivisi = state.value);
                },
                choiceType: S2ChoiceType.radios,
                choiceItems: choices.assetSelDivisi,
                modalType: S2ModalType.popupDialog,
                modalHeader: false,
                modalConfig: const S2ModalConfig(
                  style: S2ModalStyle(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtService,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Service",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtCustService,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Customer Service",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              SmartSelect<String>.single(
                title: 'Status',
                placeholder: 'Pilih Status',
                selectedValue: _selstatus,
                onChange: (state) {
                  setState(() => _selstatus = state.value);
                },
                choiceType: S2ChoiceType.radios,
                choiceItems: choices.assetSelStatus,
                modalType: S2ModalType.popupDialog,
                modalHeader: false,
                modalConfig: const S2ModalConfig(
                  style: S2ModalStyle(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              SmartSelect<String>.single(
                title: 'Type',
                placeholder: 'Pilih Type',
                selectedValue: _seltype,
                onChange: (state) {
                  setState(() => _seltype = state.value);
                },
                choiceType: S2ChoiceType.radios,
                choiceItems: choices.assetSelType,
                modalType: S2ModalType.popupDialog,
                modalHeader: false,
                modalConfig: const S2ModalConfig(
                  style: S2ModalStyle(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAssetNotes,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Asset Notes",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtService1,
                  //initialValue: _initialValue,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Service 1',
                  selectableDayPredicate: (date) {
                    return true;
                  },
                  onChanged: (val) { setState(() => _service2 = val ?? ''); },
                  validator: (val) {
                    setState(() => _service2 = val ?? '');
                    return null;
                  },
                  onSaved: (val) { setState(() => _service3 = val ?? ''); },
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtService2,
                  //initialValue: _initialValue,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Service 2',
                  selectableDayPredicate: (date) {
                    return true;
                  },
                  onChanged: (val) { setState(() => _service2 = val ?? ''); },
                  validator: (val) {
                    setState(() => _service2 = val ?? '');
                    return null;
                  },
                  onSaved: (val) { setState(() => _service3 = val ?? ''); },
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtService3,
                  //initialValue: _initialValue,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Service 3',
                  selectableDayPredicate: (date) {
                    return true;
                  },
                  onChanged: (val) { setState(() => _service3 = val ?? ''); },
                  validator: (val) {
                    setState(() => _service3 = val ?? '');
                    return null;
                  },
                  onSaved: (val) { setState(() => _service3 = val ?? ''); },
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    getImageFromCameraNew(context, "ASSET");
                    print("_imageAsset ${_pathImageAsset}");
                    print("_imageAsset ${_imageAsset}");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: _imageAsset != null &&
                        is_edit_image_asset == true
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageAsset!,
                        width: double.infinity,
                        height: 200.0,
                        scale: 0.8,
                        fit: BoxFit.cover,
                      ),
                    )
                        : _imageAsset == null &&
                        is_edit_image_asset == false &&
                        _pathImageAsset != ""
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
                                  "${GlobalData.baseUrlOri}photo/asset/$_pathImageAsset", //http://apps.tuluatas.com:8080/trucking
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
                        label: Text("Upload Photo Asset"),
                        onPressed: () => getImageFromCameraNew(context, "ASSET"),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    //_showPicker(context, "ASSET");
                    getImageFromCameraNew(context, "TD");
                    setState(() {
                      print("_imageAsset ${_pathImageAssetTD}");
                      print("_imageAsset ${_imageAssetTD}");
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: _imageAssetTD != null &&
                        is_edit_image_asset_td == true
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageAssetTD!,
                        width: double.infinity,
                        height: 200.0,
                        scale: 0.8,
                        fit: BoxFit.cover,
                      ),
                    )
                        : _imageAssetTD == null &&
                        is_edit_image_asset_td == false &&
                        _pathImageAssetTD != ""
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
                                  "${GlobalData.baseUrlOri}photo/asset/TDTM_$_pathImageAssetTD", //http://apps.tuluatas.com:8080/trucking
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
                        label: Text("File tanda terima"),
                        onPressed: () => getImageFromCameraNew(context, "TD"),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 10, top: 0, right: 10, bottom: 0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("Cancel"),
                        onPressed: () async {
                          removeSesion();
                          resetTeks();
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.deepOrange,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(width: 5),
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text(buttonEvent),
                        onPressed:   () async {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          var is_edit = prefs.getBool("is_edit_asset");
                          if (is_edit != null && is_edit == true) {
                            showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                title: new Text('Information'),
                                content: new Text("Update data asset"),
                                actions: <Widget>[
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("Ok"),
                                    onPressed: () async {
                                      Navigator.of(context).pop(false);
                                      var assetid =
                                      prefs.getString("assetid");
                                      updateAsset();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Colors.blue,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            print('Update');
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                title: new Text('Information'),
                                content: new Text("Save data asset"),
                                actions: <Widget>[
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("Ok"),
                                    onPressed: () async {
                                      Navigator.of(context).pop(false);
                                      saveAsset();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Colors.blue,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            print('save');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(width: 5),
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("View Asset"),
                        onPressed: () async {
                          removeSesion();
                          Timer(Duration(seconds: 1), () {
                            // 5s over, navigate to a new page
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListAsset()));
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                ]),
              ),
            ])));
  }

  @override
  void initState() {
    getSession();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();

  }
}
