
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/MapAddress.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// flutter_mobile_vision_2 removed - OCR not used; CAMERA_BACK = 0
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;
import 'package:http/http.dart' as http;
import '../../flusbar.dart';
import 'dart:ui' as skia;
import 'dart:ui' show Size;

class RegisterNewDriver extends StatefulWidget {
  @override
  _RegisterNewDriverState createState() => _RegisterNewDriverState();
}

class _RegisterNewDriverState extends State<RegisterNewDriver>
    with SingleTickerProviderStateMixin {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;
  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  final String BASE_URL =
      GlobalData.baseUrlOriIP; // "http://apps.tuluatas.com:8080/trucking";
  final String BASE_URL2 =
      GlobalData.baseUrlOri; // "http://apps.tuluatas.com:8080/trucking";
  int status_code = 0;
  bool is_edit_image_driver = false;
  bool is_edit_image_ktp = false;
  bool is_edit_image_sim = false;
  bool is_edit_image_kk = false;
  String message = "";
  String btnSubmitText = "Crate New Driver";
  late TabController _tabController;
  TextEditingController txtDriverName = new TextEditingController();
  TextEditingController txtNickName = new TextEditingController();
  TextEditingController txtTglLahir = new TextEditingController();
  TextEditingController txtJenisKelamin = new TextEditingController();
  TextEditingController txtTempatLahir = new TextEditingController();
  TextEditingController txtAddress = new TextEditingController();
  TextEditingController txtEmail = new TextEditingController();
  TextEditingController txtProvinsi = new TextEditingController();
  TextEditingController txtCity = new TextEditingController();
  TextEditingController txtPendidikan = new TextEditingController();
  TextEditingController txtUkuranSepatu = new TextEditingController();
  TextEditingController txtUkuranCelana = new TextEditingController();
  TextEditingController txtUkuranBaju = new TextEditingController();
  TextEditingController txtStartDatePendidikan = new TextEditingController();
  TextEditingController txtStartDateJoin = new TextEditingController();
  TextEditingController txtEndDatePendidikan = new TextEditingController();

  TextEditingController txtKTPName = new TextEditingController();
  TextEditingController txtNomorKTP = new TextEditingController();
  TextEditingController txtMasaBerlakuKTP = new TextEditingController();

  TextEditingController txtSIMName = new TextEditingController();
  TextEditingController txtNomorSIM = new TextEditingController();
  TextEditingController txtMasaBerlakuSIM = new TextEditingController();

  TextEditingController txtNoTelpon = new TextEditingController();
  TextEditingController txtCompany = new TextEditingController();
  TextEditingController txtNomorRekening = new TextEditingController();
  TextEditingController txtStatusUser = new TextEditingController();

  TextEditingController txtAyahKandung = new TextEditingController();
  TextEditingController txtIbuKandung = new TextEditingController();
  TextEditingController txtBpjsKesehatan = new TextEditingController();
  TextEditingController txtNomorBpjsKetenagakerjaan =
  new TextEditingController();
  TextEditingController txtNomorKK = new TextEditingController();
  TextEditingController txtStatusFamily = new TextEditingController();

  TextEditingController txtDriverNote = new TextEditingController();
  TextEditingController txtLatLon = new TextEditingController();
  TextEditingController txtRequestNumber = new TextEditingController();

  String _car = '';
  List<String> _smartphone = [];

  String selProvinsi = '';
  String selVehicleType = '';
  String selStatusKeluarga = '';
  String selJenisKelamin = '';
  String selGolDar = '';
  String selRequestNumber = '';
  String selReffereni = '';
  List<String> _provinsi = [];

  String _tglLahir = "";
  String _tglMasaBerlakuKTP = "";
  String _tglMasaBerlakuSIM = "";
  String _startDatePendidikan = "";
  String _endDatePendidikan = "";
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();

  int _currentIndex = 0;
  final _inactiveColor = Colors.grey;
  File? _imageDriver;
  File? _imageSIM;
  File? _imageKTP;
  File? _image_KK;
  String filePathImageDriver = "";
  String filePathImageSIM = "";
  String filePathImageKTP = "";
  String filePathImage_KK = "";
  CameraController? controller;
  List cameras = [];
  int selectedCameraIdx = 0;
  String imagePath = '';
  static const int _ocrCamera = 0; // back camera (was FlutterMobileVision.CAMERA_BACK)
  List<Map<String, dynamic>> lstVheicleType = [];
  List<Map<String, dynamic>> lstRequestNumber = [];
  List<Map<String, dynamic>> lstRefferensi = [];

  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void resetTeks() {
    setState(() {
      status_code = 0;
      message = "";
      txtDriverName.text = "";
      txtNickName.text = "";
      txtTglLahir.text = "";
      txtJenisKelamin.text = "";
      txtTempatLahir.text = "";
      txtAddress.text = "";
      txtEmail.text = "";
      txtProvinsi.text = "";
      txtCity.text = "";
      txtPendidikan.text = "";
      txtUkuranSepatu.text = "";
      txtUkuranCelana.text = "";
      txtUkuranBaju.text = "";
      txtStartDatePendidikan.text = "";
      txtStartDateJoin.text = "";
      txtEndDatePendidikan.text = "";

      txtKTPName.text = "KTP";
      txtNomorKTP.text = "";
      txtMasaBerlakuKTP.text = "";
      txtLatLon.text = "";

      txtSIMName.text = "";
      txtNomorSIM.text = "";
      txtMasaBerlakuSIM.text = "";

      txtNoTelpon.text = "";
      txtCompany.text = "";
      txtNomorRekening.text = "";
      txtStatusUser.text = "";

      txtAyahKandung.text = "";
      txtIbuKandung.text = "";
      txtBpjsKesehatan.text = "";
      txtNomorBpjsKetenagakerjaan.text = "";
      txtNomorKK.text = "";
      txtStatusFamily.text = "";

      txtDriverNote.text = "";
      txtRequestNumber.text = "";
      selProvinsi = '';
      selVehicleType = '';
      selStatusKeluarga = '';
      selJenisKelamin = '';
      selGolDar = '';
      selRequestNumber = '';
      selReffereni = '';

      _tglLahir = "";
      _tglMasaBerlakuKTP = "";
      _tglMasaBerlakuSIM = "";
      _startDatePendidikan = "";
      _endDatePendidikan = "";

      _imageDriver = null;
      _imageSIM = null;
      _imageKTP = null;
      _image_KK = null;
      filePathImageDriver = "";
      filePathImageSIM = "";
      filePathImageKTP = "";
      filePathImage_KK = "";
      is_edit_image_driver = false;
      is_edit_image_ktp = false;
      is_edit_image_sim = false;
      is_edit_image_kk = false;
    });
  }

  void getDriverById() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var isEdit = prefs.getBool("is_edit");
      var driverId = prefs.getString("driver_id");
      print(driverId);
      if (isEdit == true && (driverId != "" && driverId != null)) {
        EasyLoading.show();
        btnSubmitText = "Update Driver";
        var urlData =
            "${BASE_URL}api/driver/list_driver.jsp?method=list-driver-by-id-v1&drvid=" +
                driverId;
        var encoded = Uri.encodeFull(urlData);
        print(encoded);
        Uri myUri = Uri.parse(encoded);
        var response =
        await http.get(myUri, headers: {"Accept": "application/json"});
        var dataDriver = json.decode(response.body);
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        setState(() {
          if (response.statusCode == 200) {
            //print("$BASE_URLapi/driver/file/$filePathImageDriver");
            _imageDriver = null;
            _imageSIM = null;
            _imageKTP = null;
            is_edit_image_driver = false;
            is_edit_image_sim = false;
            is_edit_image_ktp = false;
            txtDriverName.text = dataDriver[0]['drvname'] == "null"
                ? ""
                : dataDriver[0]['drvname'];
            txtNickName.text = dataDriver[0]['drvnickname'] == "null"
                ? ""
                : dataDriver[0]['drvnickname'];
            txtTglLahir.text = dataDriver[0]['drvdob'] == "null"
                ? ""
                : dataDriver[0]['drvdob'];
            txtTempatLahir.text = dataDriver[0]['drvplaceofbirth'] == "null"
                ? ""
                : dataDriver[0]['drvplaceofbirth'];
            selJenisKelamin =
            dataDriver[0]['sex'] == "null" ? "" : dataDriver[0]['sex'];
            txtAddress.text = dataDriver[0]['drvaddress'] == "null"
                ? ""
                : dataDriver[0]['drvaddress'];
            txtEmail.text = dataDriver[0]['drvemail'] == "null"
                ? ""
                : dataDriver[0]['drvemail'];
            selProvinsi = dataDriver[0]['drvprovince'] == "null"
                ? ""
                : dataDriver[0]['drvprovince'];
            txtCity.text = dataDriver[0]['drvcity'] == "null"
                ? ""
                : dataDriver[0]['drvcity'];
            txtKTPName.text = "KTP";
            txtNomorKTP.text = dataDriver[0]['drvidentitynbr'] == "null"
                ? ""
                : dataDriver[0]['drvidentitynbr'];
            txtMasaBerlakuKTP.text =
            dataDriver[0]['drvidentityexpireddate'] == "null"
                ? ""
                : dataDriver[0]['drvidentityexpireddate'];
            txtSIMName.text = dataDriver[0]['drvlicensetype'] == "null"
                ? ""
                : dataDriver[0]['drvlicensetype'];
            txtNomorSIM.text = dataDriver[0]['drvlicensenbr'] == "null"
                ? ""
                : dataDriver[0]['drvlicensenbr'];
            txtMasaBerlakuSIM.text =
            dataDriver[0]['drvlicenseexpireddate'] == "null"
                ? ""
                : dataDriver[0]['drvlicenseexpireddate'];
            txtNoTelpon.text =
            dataDriver[0]['phone'] == "null" ? "" : dataDriver[0]['phone'];
            selVehicleType = dataDriver[0]['vehicletype'] == "null"
                ? ""
                : dataDriver[0]['vehicletype'];
            var drvstatus = dataDriver[0]['drvstatus'] == "null"
                ? ""
                : dataDriver[0]['drvstatus'];
            txtAyahKandung.text =
            dataDriver[0]['ayah'] == "null" ? "" : dataDriver[0]['ayah'];
            txtIbuKandung.text =
            dataDriver[0]['ibu'] == "null" ? "" : dataDriver[0]['ibu'];
            txtBpjsKesehatan.text =
            dataDriver[0]['bpjs'] == "null" ? "" : dataDriver[0]['bpjs'];
            txtNomorBpjsKetenagakerjaan.text =
            dataDriver[0]['bpjsket'] == "null"
                ? ""
                : dataDriver[0]['bpjsket'];
            txtNomorKK.text =
            dataDriver[0]['nokk'] == "null" ? "" : dataDriver[0]['nokk'];
            txtPendidikan.text = dataDriver[0]['drvpendidikan'] == "null"
                ? ""
                : dataDriver[0]['drvpendidikan'];
            txtUkuranBaju.text =
            dataDriver[0]['baju'] == "null" ? "" : dataDriver[0]['baju'];
            txtUkuranCelana.text = dataDriver[0]['celana'] == "null"
                ? ""
                : dataDriver[0]['celana'];
            txtUkuranSepatu.text = dataDriver[0]['sepatu'] == "null"
                ? ""
                : dataDriver[0]['sepatu'];
            var statusdrv = dataDriver[0]['statusdrv'] == "null"
                ? ""
                : dataDriver[0]['statusdrv'];
            selStatusKeluarga = statusdrv;

            selGolDar = dataDriver[0]['goldarah'] == "null"
                ? ""
                : dataDriver[0]['goldarah'];
            txtDriverNote.text = dataDriver[0]['drvnotes'] == "null"
                ? ""
                : dataDriver[0]['drvnotes'];
            txtNomorRekening.text =
            dataDriver[0]['norek'] == "null" ? "" : dataDriver[0]['norek'];
            selRequestNumber = dataDriver[0]['request_number'] == "null"
                ? ""
                : dataDriver[0]['request_number'];

            selReffereni = dataDriver[0]['drvnotes'] == "null"
                ? ""
                : dataDriver[0]['drvnotes'];

            filePathImageDriver = dataDriver[0]['photo_driver'] == "null"
                ? ""
                : dataDriver[0]['photo_driver'];
            filePathImageSIM = dataDriver[0]['photo_sim'] == "null"
                ? ""
                : dataDriver[0]['photo_sim'];
            filePathImageKTP = dataDriver[0]['photo_ktp'] == "null"
                ? ""
                : dataDriver[0]['photo_ktp'];

            filePathImage_KK = dataDriver[0]['photo_kk'] == "null"
                ? ""
                : dataDriver[0]['photo_kk'];
            print("PHOTO EDIT");
            print(filePathImageDriver);
            print(filePathImageSIM);
            print(filePathImageKTP);
            var userid = prefs.getString("name");
            print("USERID :${userid}");
            print(selVehicleType);
            print(selGolDar);
            print(selJenisKelamin);
            print(selProvinsi);
            print(selStatusKeluarga);
            print(selRequestNumber);
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal load data detail driver", "error");
          }
        });
      } else {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        btnSubmitText = "Create New Driver";
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
          "error");
      print(e.toString());
    }
  }

  void updateDriver(String drvID) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var driver_id = drvID;
      var drvname = txtDriverName.text;
      var drvnickname = txtNickName.text;
      var drvdob = txtTglLahir.text;
      var drvplaceofbirth = txtTempatLahir.text;
      print(drvplaceofbirth);
      var sex = selJenisKelamin;
      //print(sex);
      var drvaddress1 = txtAddress.text;
      var drvaddress2 = txtEmail.text;
      var drvprovince = selProvinsi;
      var drvcity = txtCity.text;
      var drvidentitytype = txtKTPName.text;
      var drvidentitynbr = txtNomorKTP.text;
      var drvidentityepiredate = txtMasaBerlakuKTP.text;
      var drvlicensetype = txtSIMName.text;
      var drvlicensenbr = txtNomorSIM.text;
      var drvlicenseexpiredate = txtMasaBerlakuSIM.text;
      var phone = txtNoTelpon.text;
      var vehicletype = selVehicleType;
      //var drvstatus = "Not Active";
      var ayah = txtAyahKandung.text;
      var ibu = txtIbuKandung.text;
      var bpjs = txtBpjsKesehatan.text;
      var bpjsket = txtNomorBpjsKetenagakerjaan.text;
      var nokk = txtNomorKK.text;
      //print(nokk);
      //print(txtNomorKK.text);
      var pendidikan = txtPendidikan.text;
      var baju = txtUkuranBaju.text;
      var celana = txtUkuranCelana.text;
      var sepatu = txtUkuranSepatu.text;
      var statusdrv = selStatusKeluarga;
      var drvnotes = selReffereni;// txtDriverNote.text;
      var nomor_rekening = txtNomorRekening.text;
      var userid = prefs.getString("name");

      if (driver_id == null || driver_id == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (drvname == null || drvname == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver name tidak boleh kosong", "error");
      } else if (sex == null || sex == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Jenis kelamin tidak boleh kosong", "error");
      } else if (drvdob == null || drvdob == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Tanggal Lahir tidak boleh kosong", "error");
      } else if (drvplaceofbirth == null || drvplaceofbirth == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Tempat Lahir tidak boleh kosong", "error");
      } else if (drvaddress1 == null || drvaddress1 == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0, "Alamat tidak boleh kosong",
            "error");
      } else if (drvprovince == null || drvprovince == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Provinsi tidak boleh kosong", "error");
      } else if (drvidentitynbr == null || drvidentitynbr == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor KTP tidak boleh kosong", "error");
      } else if (drvlicensetype == null || drvlicensetype == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nama SIM tidak boleh kosong", "error");
      } else if (drvlicensenbr == null || drvlicensenbr == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor SIM tidak boleh kosong", "error");
      } else if (drvlicenseexpiredate == null || drvlicenseexpiredate == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "SIM Expire Date tidak boleh kosong", "error");
      } else if (phone == null || phone == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor Handphone tidak boleh kosong", "error");
      } else if (ibu == null || ibu == "") {
        _tabController.animateTo(2);
        alert(globalScaffoldKey.currentContext!, 0,
            "Ibu kandung tidak boleh kosong", "error");
      } else if (nokk == null || nokk == "") {
        _tabController.animateTo(2);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor KK tidak boleh kosong", "error");
      } else if (txtLatLon.text == null || txtLatLon.text == "") {
        _tabController.animateTo(2);
        alert(globalScaffoldKey.currentContext!, 0,
            "Coordinate/Alamat tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        print(driver_id);

        var data = {
          'method': 'update-new-driver-v1',
          'drvid': driver_id,
          'drvname': drvname,
          'drvnickname': drvnickname,
          'drvdob': drvdob,
          'drvplaceofbirth': drvplaceofbirth,
          'sex': sex,
          'drvaddress1': drvaddress1,
          'drvaddress2': drvaddress2,
          'drvprovince': drvprovince,
          'drvcity': drvcity,
          'drvidentitytype': drvidentitytype,
          'drvidentitynbr': drvidentitynbr,
          'drvidentityepiredate': drvidentityepiredate,
          'drvlicensetype': drvlicensetype,
          'drvlicensenbr': drvlicensenbr,
          'drvlicenseexpiredate': drvlicenseexpiredate,
          'phone': phone,
          'vehicletype': vehicletype,
          'ayah': ayah,
          'ibu': ibu,
          'bpjs': bpjs,
          'bpjsket': bpjsket,
          'nokk': nokk,
          'pendidikan': pendidikan,
          'baju': baju,
          'celana': celana,
          'sepatu': sepatu,
          'statusdrv': statusdrv,
          'drvnotes': drvnotes,
          'nomor_rekening': nomor_rekening,
          'lat_lon': txtLatLon.text,
          'userid': userid,
          'request_number': selRequestNumber,
          'photo_driver': filePathImageDriver,
          'photo_sim': filePathImageSIM,
          'photo_ktp': filePathImageKTP,
          'photo_kk': filePathImage_KK,
        };
        print(data);
        var encoded = Uri.encodeFull("${BASE_URL}api/driver/driver_new.jsp");
        //print("filePathImageDriver");
        // print(filePathImageDriver);
        // print(filePathImageSIM);
        // print(filePathImageKTP);
        Uri urlEncode = Uri.parse(encoded);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            //print(response);
            if (status_code == 200) {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: cardColor,
                  title: new Text('Information',
                      style: TextStyle(
                        color: darkOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        prefs.setBool("is_edit", false);
                        prefs.setString("driver_id", "");
                        resetTeks();
                        setState(() {
                          btnSubmitText = "Create New Driver";
                        });
                        _tabController.animateTo(0);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            } else {
              alert(globalScaffoldKey.currentContext!, 0,
                  "Gagal mengupdate ${message}", "error");
            }
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, Gagal Menyimpan Data",
          "error");
      print(e.toString());
    }
  }


  void saveDriver(String ip) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var drvname = txtDriverName.text;
      var drvnickname = txtNickName.text;
      var drvdob = txtTglLahir.text;
      var drvplaceofbirth = txtTempatLahir.text;
      var sex = selJenisKelamin;
      var drvaddress1 = txtAddress.text;
      var drvaddress2 = txtEmail.text;
      var drvprovince = selProvinsi;
      var drvcity = txtCity.text;
      var drvidentitytype = txtKTPName.text;
      var drvidentitynbr = txtNomorKTP.text;
      var drvidentityepiredate = txtMasaBerlakuKTP.text;
      var drvlicensetype = txtSIMName.text;
      var drvlicensenbr = txtNomorSIM.text;
      var drvlicenseexpiredate = txtMasaBerlakuSIM.text;
      var phone = txtNoTelpon.text;
      var vehicletype = selVehicleType;
      var drvstatus = "new";
      var ayah = txtAyahKandung.text;
      var ibu = txtIbuKandung.text;
      var bpjs = txtBpjsKesehatan.text;
      var bpjsket = txtNomorBpjsKetenagakerjaan.text;
      var nokk = txtNomorKK.text;
      var pendidikan = txtPendidikan.text;
      var baju = txtUkuranBaju.text;
      var celana = txtUkuranCelana.text;
      var sepatu = txtUkuranSepatu.text;
      var statusdrv = selStatusKeluarga;
      var drvnotes = selReffereni;
      var nomor_rekening = txtNomorRekening.text;
      var userid = prefs.getString("name");
      if (drvname == null || drvname == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver name tidak boleh kosong", "error");
      } else if (sex == null || sex == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Jenis kelamin tidak boleh kosong", "error");
      } else if (drvdob == null || drvdob == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Tanggal Lahir tidak boleh kosong", "error");
      } else if (drvplaceofbirth == null || drvplaceofbirth == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Tempat Lahir tidak boleh kosong", "error");
      } else if (drvaddress1 == null || drvaddress1 == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0, "Alamat tidak boleh kosong",
            "error");
      } else if (drvprovince == null || drvprovince == "") {
        _tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Provinsi tidak boleh kosong", "error");
      } else if (drvidentitynbr == null || drvidentitynbr == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor KTP tidak boleh kosong", "error");
      } else if (drvidentitynbr.length != 16) {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0, "Nomor KTP maximum 16 digit",
            "error");
      } else if (drvlicensetype == null || drvlicensetype == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nama SIM tidak boleh kosong", "error");
      } else if (drvlicensenbr == null || drvlicensenbr == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor SIM tidak boleh kosong", "error");
      } else if (drvlicenseexpiredate == null || drvlicenseexpiredate == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "SIM Expire Date tidak boleh kosong", "error");
      } else if (phone == null || phone == "") {
        _tabController.animateTo(1);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor Handphone tidak boleh kosong", "error");
      } else if (ibu == null || ibu == "") {
        _tabController.animateTo(2);
        alert(globalScaffoldKey.currentContext!, 0,
            "Ibu kandung tidak boleh kosong", "error");
      } else if (nokk == null || nokk == "") {
        _tabController.animateTo(2);
        alert(globalScaffoldKey.currentContext!, 0,
            "Nomor KK tidak boleh kosong", "error");
      } else if (txtLatLon.text == null || txtLatLon.text == "") {
        _tabController.animateTo(2);
        alert(globalScaffoldKey.currentContext!, 0,
            "Coordinat/Alamat tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = ip == "1"
            ? Uri.encodeFull("${BASE_URL}api/driver/driver_new.jsp")
            : Uri.encodeFull("${BASE_URL2}api/driver/driver_new.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-new-driver-v1',
          'drvname': drvname,
          'drvnickname': drvnickname,
          'drvdob': drvdob,
          'drvplaceofbirth': drvplaceofbirth,
          'sex': sex,
          'drvaddress1': drvaddress1,
          'drvaddress2': drvaddress2,
          'drvprovince':
          "${drvprovince[0].toUpperCase()}${drvprovince.substring(1).toLowerCase()}", //drvprovince.toUpperCase()}${this.substring(1).toLowerCase(),
          'drvcity': drvcity,
          'drvidentitytype': drvidentitytype,
          'drvidentitynbr': drvidentitynbr,
          'drvidentityepiredate': drvidentityepiredate,
          'drvlicensetype': drvlicensetype,
          'drvlicensenbr': drvlicensenbr,
          'drvlicenseexpiredate': drvlicenseexpiredate,
          'phone': phone,
          'drvstatus': drvstatus,
          'vehicletype': vehicletype,
          'ayah': ayah,
          'ibu': ibu,
          'bpjs': bpjs,
          'bpjsket': bpjsket,
          'nokk': nokk,
          'pendidikan': pendidikan,
          'baju': baju,
          'celana': celana,
          'sepatu': sepatu,
          'statusdrv': statusdrv,
          'drvnotes': drvnotes,
          'nomor_rekening': nomor_rekening,
          'lat_lon': txtLatLon.text,
          'userid': userid,
          'request_number': selRequestNumber,
          'photo_driver': filePathImageDriver,
          'photo_sim': filePathImageSIM,
          'photo_ktp': filePathImageKTP,
          'photo_kk': filePathImage_KK
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
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(response);
            if (status_code == 200) {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: cardColor,
                  title: new Text('Information',
                      style: TextStyle(
                        color: darkOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                        _tabController.animateTo(0);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            } else {
              alert(globalScaffoldKey.currentContext!, 0,
                  "Gagal menyimpan ${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal menyimpan ${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Failed, ${e.toString()} ",
          "error");
      print(e.toString());
    }
  }

  Future<String> getVehicleType() async {
    String status = "";
    var urlData =
        "${BASE_URL}api/driver/vehicle_type.jsp?method=select-vehicle-type-v1";

    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
    await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstVheicleType = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        //print("lstVheicleType");
        //print(lstVheicleType);
      }
    });
    return status;
  }

  Future<String> getRequestNumber() async {
    String status = "";
    var urlData =
        "${BASE_URL}mobile/api/driver/lis_request_number.jsp?method=get-list-reqnumber";

    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
    await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstRequestNumber = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        // Transform data for dropdown - combine svrsvcreqnumber and vhcid
        lstRequestNumber = lstRequestNumber.map((item) {
          return {
            'value': item['svrsvcreqnumber'],
            'title': '${item['svrsvcreqnumber']} - ${item['vhcid']}'
          };
        }).toList();
        print("lstRequestNumber");
        print(lstRequestNumber);
      }
    });
    return status;
  }

  Future<String> getRefferensi() async {
    String status = "";
    var urlData =
        "${BASE_URL}mobile/api/driver/list_refferensi.jsp?method=get-list-reff";

    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
    await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstRefferensi = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        // Transform data for dropdown - combine svrsvcreqnumber and vhcid
        lstRefferensi = lstRefferensi.map((item) {
          return {
            'value': item['drvid'],
            'title': '${item['drvname']}'
          };
        }).toList();
        print("lstRefferensi");
        print(lstRefferensi);
      }
    });
    return status;
  }

  void getPicture(String namaPhoto, opsi) async {
    if (opsi == 'GALLERY') {
      final pickedFile =
      await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        if (namaPhoto == "DRIVER") {
          setState(() {
            _imageDriver = File(pickedFile.path);
            List<int> imageBytes = _imageDriver!.readAsBytesSync();
            var kb = _imageDriver!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            print("MB " + mb.toString());
            print("KB " + kb.toString());
            filePathImageDriver = base64Encode(imageBytes);
            is_edit_image_driver = true;
          });
        } else if (namaPhoto == "SIM") {
          setState(() {
            _imageSIM = File(pickedFile.path);
            List<int> imageBytes = _imageSIM!.readAsBytesSync();
            filePathImageSIM = base64Encode(imageBytes);
            is_edit_image_sim = true;
          });
        } else if (namaPhoto == "KTP") {
          setState(() {
            _imageKTP = File(pickedFile.path);
            List<int> imageBytes = _imageKTP!.readAsBytesSync();
            filePathImageKTP = base64Encode(imageBytes);
            is_edit_image_ktp = true;
          });
        }else if (namaPhoto == "KK") {
          setState(() {
            _image_KK = File(pickedFile.path);
            List<int> imageBytes = _image_KK!.readAsBytesSync();
            filePathImage_KK = base64Encode(imageBytes);
            is_edit_image_kk = true;
          });
        } else {
          setState(() {
            filePathImageDriver = "";
            filePathImageSIM = "";
            filePathImageKTP = "";
            filePathImage_KK = "";
          });
        }
        //print(filePathImage);
      } else {
        setState(() {
          _imageDriver = null;
          _imageSIM = null;
          _imageKTP = null;
          _image_KK = null;
          filePathImageDriver = "";
          filePathImageSIM = "";
          filePathImageKTP = "";
          filePathImage_KK = "";
          print('No image selected.');
        });
      }
    } else {
      final pickedFile =
      await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        if (namaPhoto == "DRIVER") {
          setState(() {
            _imageDriver = File(pickedFile.path);
            List<int> imageBytes = _imageDriver!.readAsBytesSync();
            var kb = _imageDriver!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            print("MB " + mb.toString());
            print("KB " + kb.toString());
            filePathImageDriver = base64Encode(imageBytes);
            is_edit_image_driver = true;
          });
        } else if (namaPhoto == "SIM") {
          setState(() {
            _imageSIM = File(pickedFile.path);
            List<int> imageBytes = _imageSIM!.readAsBytesSync();
            filePathImageSIM = base64Encode(imageBytes);
            is_edit_image_sim = true;
          });
        } else if (namaPhoto == "KTP") {
          setState(() {
            _imageKTP = File(pickedFile.path);
            List<int> imageBytes = _imageKTP!.readAsBytesSync();
            filePathImageKTP = base64Encode(imageBytes);
            is_edit_image_ktp = true;
          });
        } else if (namaPhoto == "KK") {
          setState(() {
            _image_KK= File(pickedFile.path);
            List<int> imageBytes = _image_KK!.readAsBytesSync();
            filePathImage_KK = base64Encode(imageBytes);
            is_edit_image_kk = true;
          });
        } else {
          setState(() {
            filePathImageDriver = "";
            filePathImageSIM = "";
            filePathImageKTP = "";
            filePathImage_KK = "";
          });
        }
        //print(filePathImage);
      } else {
        setState(() {
          _imageDriver = null;
          _imageSIM = null;
          _imageKTP = null;
          _image_KK = null;
          filePathImageDriver = "";
          filePathImageSIM = "";
          filePathImageKTP = "";
          filePathImage_KK = "";
          print('No image selected.');
        });
      }
    }
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    showDialog(
      context: contexs,
      builder: (contexs) => new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: cardColor,
        title: new Text('Information',
            style: TextStyle(
              color: darkOrange,
              fontWeight: FontWeight.w600,
            )),
        content: new Text("Get Picture"),
        actions: <Widget>[
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 18.0,
            ),
            label: Text("Camera"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture(namaPhoto, 'CAMERA');
            },
            style: ElevatedButton.styleFrom(
                elevation: 2.0,
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle:
                TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: 18.0,
            ),
            label: Text("Gallery"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture(namaPhoto, 'GALLERY');
            },
            style: ElevatedButton.styleFrom(
                elevation: 2.0,
                backgroundColor: accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle:
                TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context, String namaPhoto) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: cardColor,
        builder: (context) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 16),
                        new ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: lightOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.photo_camera, color: primaryOrange),
                          ),
                          title: new Text('Camera',
                              style: TextStyle(
                                color: darkOrange,
                                fontWeight: FontWeight.w500,
                              )),
                          onTap: () async {
                            await getImageFromCamera(context, namaPhoto);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void GetSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var latLon = prefs.getString("lat_lon");
    if (latLon != null && latLon != "") {
      //var arrLat = latLon.split(",");
      setState(() {
        txtLatLon.text = latLon.toString();
      });
      _tabController.animateTo(0);
    }
  }

  @override
  void initState() {
    // var a = "Adam";
    // print("${a[0].toUpperCase()}${a.substring(1).toLowerCase()}");
    _tabController = new TabController(vsync: this, length: 5);
    txtKTPName.text = "KTP";
    setState(() {
      getVehicleType();
      getRequestNumber();
      getRefferensi();
      getDriverById();
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    GetSession();
    super.initState();
  }

  // Custom TextField with orange theme
  Widget buildTextField({
    String? labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: TextField(
        readOnly: readOnly,
        cursorColor: primaryOrange,
        style: TextStyle(color: Colors.black87, fontSize: 14),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryOrange, width: 2),
          ),
        ),
      ),
    );
  }

  // Custom SmartSelect with orange theme
  Widget buildSmartSelect({
    String? title,
    String value = '',
    required Function(dynamic) onChange,
    required List<S2Choice<String>> choices,
    bool modalFilter = true,
    String filterHint = 'Cari...',
  }) {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: SmartSelect<String>.single(
        title: title ?? '',
        placeholder: 'Pilih satu',
        selectedValue: value,
        onChange: onChange,
        choiceType: S2ChoiceType.radios,
        choiceItems: choices,
        modalType: S2ModalType.popupDialog,
        modalHeader: true,
        modalFilter: modalFilter,
        modalFilterAuto: modalFilter,
        modalConfig: S2ModalConfig(
          useHeader: true,
          useFilter: modalFilter,
          filterAuto: modalFilter,
          filterHint: filterHint,
          style: S2ModalStyle(
            elevation: 8,
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
        ),
        tileBuilder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ListTile(
              title: Text(
                title ?? '',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                (value != null && value.isNotEmpty) ? value : 'Pilih satu',
                style: TextStyle(
                  color: (value != null && value.isNotEmpty) ? Colors.black87 : Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol clear value
                  //if (value != null && value.isNotEmpty)
                    // GestureDetector(
                    //   onTap: () => onChange(''),  // reset ke string kosong
                    //   child: Icon(Icons.clear, color: Colors.redAccent, size: 20),
                    // ),
                  Icon(Icons.arrow_drop_down, color: primaryOrange),
                ],
              ),
              onTap: state.showModal,
            ),
          );
        },
      ),
    );
  }

  // Custom DateTimePicker with orange theme
  Widget buildDateTimePicker({
    required String labelText,
    required String labelHint,
    required TextEditingController controller,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: DateTimePicker(
        dateMask: 'yyyy-MM-dd',
        controller: controller,
        firstDate: DateTime(1950),
        lastDate: DateTime(2100),
        icon: Icon(Icons.event, color: primaryOrange),
        dateLabelText: labelText,
        style: TextStyle(color: Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: labelHint,
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryOrange, width: 2),
          ),
        ),
        selectableDayPredicate: (date) {
          return true;
        },
        onChanged: onChanged,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  //int selectedPage=1;
  //_RegisterNewDriverState(this.selectedPage);
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                _goBack(context);
              },
            ),
            title: Text(
              'Pendaftaran Driver Baru',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size(double.infinity, 60.0),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: primaryOrange,
                  indicatorWeight: 3,
                  labelColor: primaryOrange,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.person_outline, size: 20),
                      child: Text('Biodata'),
                    ),
                    Tab(
                      icon: Icon(Icons.card_membership_outlined, size: 20),
                      child: Text('Lisence'),
                    ),
                    Tab(
                      icon: Icon(Icons.family_restroom_outlined, size: 20),
                      child: Text('Keluarga'),
                    ),
                    Tab(
                      icon: Icon(Icons.devices_other_outlined, size: 20),
                      child: Text('Lainnya'),
                    ),
                    Tab(
                      icon: Icon(Icons.camera_alt_outlined, size: 20),
                      child: Text('Photo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            key: globalScaffoldKey,
            controller: _tabController,
            children: [
              // Biodata Tab
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightOrange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: primaryOrange, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Data Personal',
                              style: TextStyle(
                                color: darkOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTextField(
                        labelText: "Latitude,Longitude",
                        controller: txtLatLon,
                        readOnly: false,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.location_on, color: primaryOrange),
                          onPressed: () async {
                            print('Tap');
                            showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: cardColor,
                                title: new Text('Information',
                                    style: TextStyle(
                                      color: darkOrange,
                                      fontWeight: FontWeight.w600,
                                    )),
                                content: new Text(
                                    "Proses pencarian dengan maps, akan mereset semua input yang sudah ada,lanjutkan ?"),
                                actions: <Widget>[
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                    label: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 2.0,
                                        backgroundColor: Colors.grey.shade500,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                    label: Text("Yes"),
                                    onPressed: () async {
                                      Navigator.of(context).pop(false);
                                      SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                      EasyLoading.show();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapAddress()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 2.0,
                                        backgroundColor: primaryOrange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      buildTextField(
                        labelText: "Nama Pengemudi",
                        controller: txtDriverName,
                      ),
                      buildTextField(
                        labelText: "Nama Panggilan",
                        controller: txtNickName,
                      ),
                      buildSmartSelect(
                        title: 'Jenis Kelamin',
                        value: selJenisKelamin,
                        onChange: (selected) {
                          setState(() => selJenisKelamin = selected.value);
                        },
                        choices: choices.jenisKelamin,
                      ),
                      Container(
                        margin: EdgeInsets.all(12.0),
                        child: DateTimePicker(
                          //type: DateTimePickerType.dateTimeSeparate,
                          dateMask: 'yyyy-MM-dd',
                          controller: txtTglLahir,
                          //initialValue: _initialValue,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          icon: Icon(Icons.event),
                          dateLabelText: 'Tanggal Lahir',
                          decoration: InputDecoration(
                            hintText: 'Tanggal Lahir',
                            fillColor: Colors.white,
                            filled: true,
                            isDense: true,
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryOrange, width: 2),
                            ),
                          ),
                          selectableDayPredicate: (date) {
                            return true;
                          },
                          onChanged: (val) => setState(() => _tglLahir = val),
                          validator: (val) {
                            setState(() => _tglLahir = val ?? '');
                            return null;
                          },
                          onSaved: (val) =>
                              setState(() => _tglLahir = val ?? ''),
                        ),
                      ),
                      buildTextField(
                        labelText: "Tempat Lahir *",
                        controller: txtTempatLahir,
                      ),
                      buildTextField(
                        labelText: "Alamat",
                        controller: txtAddress,
                      ),
                      buildSmartSelect(
                        title: 'Provinsi',
                        value: selProvinsi,
                        onChange: (selected) =>
                            setState(() => selProvinsi = selected.value),
                        choices: S2Choice.listFrom<String, Map>(
                            source: choices.provinsi,
                            value: (index, item) => item['value'],
                            title: (index, item) => item['title']),
                        modalFilter: true,
                      ),
                      buildTextField(
                        labelText: "Kota",
                        controller: txtCity,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // License Tab
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightOrange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.card_membership, color: primaryOrange, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Data Lisensi & Kontak',
                              style: TextStyle(
                                color: darkOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTextField(
                        labelText: "Type",
                        controller: txtKTPName,
                        readOnly: true,
                      ),
                      buildTextField(
                        labelText: "Nomor KTP *",
                        controller: txtNomorKTP,
                        keyboardType: TextInputType.number,
                      ),
                      buildTextField(
                        labelText: "Type SIM *",
                        controller: txtSIMName,
                      ),
                      buildTextField(
                        labelText: "Nomor SIM *",
                        controller: txtNomorSIM,
                        keyboardType: TextInputType.number,
                      ),
                      buildDateTimePicker(
                        labelText: 'Masa Berlaku SIM',
                        labelHint: 'Masa Berlaku SIM',
                        controller: txtMasaBerlakuSIM,
                        onChanged: (val) =>
                            setState(() => _tglMasaBerlakuSIM = val!),
                        validator: (val) {
                          setState(() => _tglMasaBerlakuSIM = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _tglMasaBerlakuSIM = val ?? ''),
                      ),
                      buildTextField(
                        labelText: "Nomor Handphone",
                        controller: txtNoTelpon,
                        keyboardType: TextInputType.phone,
                      ),
                      buildTextField(
                        labelText: "Email",
                        controller: txtEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      buildTextField(
                        labelText: "Nomor Rekening",
                        controller: txtNomorRekening,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Family Tab
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightOrange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.family_restroom, color: primaryOrange, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Data Keluarga & Kesehatan',
                              style: TextStyle(
                                color: darkOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTextField(
                        labelText: "Nama Ayah Kandung",
                        controller: txtAyahKandung,
                      ),
                      buildTextField(
                        labelText: "Nama Ibu Kandung",
                        controller: txtIbuKandung,
                      ),
                      buildTextField(
                        labelText: "Nomor Kartu Keluarga*",
                        controller: txtNomorKK,
                        keyboardType: TextInputType.number,
                      ),
                      buildTextField(
                        labelText: "Nomor BPJS Kesehatan",
                        controller: txtBpjsKesehatan,
                        keyboardType: TextInputType.number,
                      ),
                      buildTextField(
                        labelText: "Nomor BPJS Ketenagakerjaan",
                        controller: txtNomorBpjsKetenagakerjaan,
                        keyboardType: TextInputType.number,
                      ),
                      buildSmartSelect(
                        title: 'Status Keluarga',
                        value: selStatusKeluarga,
                        onChange: (selected) {
                          setState(() => selStatusKeluarga = selected.value);
                        },
                        choices: choices.familyStatus,
                      ),
                      buildSmartSelect(
                        title: 'Golongan Darah',
                        value: selGolDar,
                        onChange: (selected) {
                          setState(() => selGolDar = selected.value);
                        },
                        choices: choices.golonganDarah,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Others Tab
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightOrange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.devices_other, color: primaryOrange, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Data Lainnya',
                              style: TextStyle(
                                color: darkOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildTextField(
                        labelText: "Pendidikan",
                        controller: txtPendidikan,
                      ),
                      buildTextField(
                        labelText: "Ukuran Baju",
                        controller: txtUkuranBaju,
                      ),
                      buildTextField(
                        labelText: "Ukuran Celana",
                        controller: txtUkuranCelana,
                        keyboardType: TextInputType.number,
                      ),
                      buildTextField(
                        labelText: "Ukuran Sepatu",
                        controller: txtUkuranSepatu,
                        keyboardType: TextInputType.number,
                      ),
                      buildSmartSelect(
                        title: 'Type Kendaraan',
                        value: selVehicleType,
                        onChange: (selected) =>
                            setState(() => selVehicleType = selected.value),
                        choices: S2Choice.listFrom<String, Map>(
                            source: lstVheicleType,
                            value: (index, item) => item['value'],
                            title: (index, item) => item['title']),
                        modalFilter: true,
                      ),
                      buildSmartSelect(
                        title: 'Request Number',
                        value: selRequestNumber,
                        onChange: (selected) =>
                            setState(() => selRequestNumber = selected.value),
                        choices: S2Choice.listFrom<String, Map>(
                            source: lstRequestNumber,
                            value: (index, item) => item['value'],
                            title: (index, item) => item['title']),
                        modalFilter: true,
                      ),
                      buildSmartSelect(
                        title: 'Refferensi',
                        value: selReffereni,
                        onChange: (selected) =>
                            setState(() => selReffereni = selected.value),
                        choices: S2Choice.listFrom<String, Map>(
                            source: lstRefferensi,
                            value: (index, item) => item['value'],
                            title: (index, item) => item['title']),
                        modalFilter: true,
                      ),
                      // buildTextField(
                      //   labelText: "Refferensi",
                      //   controller: txtDriverNote,
                      // ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Photo Tab
              Container(
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightOrange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, color: primaryOrange, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Foto Dokumen',
                              style: TextStyle(
                                color: darkOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () async {
                            await getImageFromCamera(context, "DRIVER");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _imageDriver != null &&
                                is_edit_image_driver == true
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageDriver!,
                                width: double.infinity,
                                height: 200.0,
                                scale: 0.8,
                                fit: BoxFit.cover,
                              ),
                            )
                                : _imageDriver == null &&
                                is_edit_image_driver == false &&
                                filePathImageDriver != ""
                                ? Container(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(12.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageDriver",
                                        ),
                                        fit: BoxFit.cover)),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )),
                              width: double.infinity,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: primaryOrange,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Photo Driver",
                                    style: TextStyle(
                                      color: darkOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Tap to take photo",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () async {
                            await getImageFromCamera(context, "SIM");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _imageSIM != null &&
                                is_edit_image_sim == true
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageSIM!,
                                width: double.infinity,
                                height: 200,
                                scale: 0.8,
                                fit: BoxFit.cover,
                              ),
                            )
                                : _imageSIM == null &&
                                is_edit_image_sim == false &&
                                filePathImageSIM != ""
                                ? Container(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(12.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageSIM",
                                        ),
                                        fit: BoxFit.cover)),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )),
                              width: double.infinity,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card_outlined,
                                    color: primaryOrange,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Photo SIM",
                                    style: TextStyle(
                                      color: darkOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Tap to take photo",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () async {
                            await getImageFromCamera(context, "KTP");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _imageKTP != null &&
                                is_edit_image_ktp == true
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageKTP!,
                                width: double.infinity,
                                height: 200,
                                scale: 0.8,
                                fit: BoxFit.cover,
                              ),
                            )
                                : _imageKTP == null &&
                                is_edit_image_ktp == false &&
                                filePathImageKTP != ""
                                ? Container(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(12.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageKTP",
                                        ),
                                        fit: BoxFit.cover)),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )),
                              width: double.infinity,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    color: primaryOrange,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Photo KTP",
                                    style: TextStyle(
                                      color: darkOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Tap to take photo",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () async {
                            await getImageFromCamera(context, "KK");
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _image_KK != null &&
                                is_edit_image_kk == true
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _image_KK!,
                                width: double.infinity,
                                height: 200,
                                scale: 0.8,
                                fit: BoxFit.cover,
                              ),
                            )
                                : _image_KK == null &&
                                is_edit_image_kk == false &&
                                filePathImage_KK != ""
                                ? Container(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(12.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImage_KK",
                                        ),
                                        fit: BoxFit.cover)),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )),
                              width: double.infinity,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.family_restroom_outlined,
                                    color: primaryOrange,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Photo KK",
                                    style: TextStyle(
                                      color: darkOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Tap to take photo",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 16, top: 0, right: 16, bottom: 8),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                                label: Text("Cancel"),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  prefs.setBool("is_edit", false);
                                  prefs.setString("driver_id", "");
                                  resetTeks();
                                  setState(() {
                                    btnSubmitText = "Create New Driver";
                                    _imageDriver = null;
                                    _imageSIM = null;
                                    _imageKTP = null;
                                    filePathImageDriver = "";
                                    filePathImageSIM = "";
                                    filePathImageKTP = "";
                                  });
                                  _tabController.animateTo(0);
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 2.0,
                                    backgroundColor: Colors.grey.shade500,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    textStyle: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                              )),
                          SizedBox(width: 8),
                          Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                                label: Text(btnSubmitText + " 1"),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  var is_edit = prefs.getBool("is_edit");
                                  if (is_edit != null && is_edit == true) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: cardColor,
                                        title: new Text('Information',
                                            style: TextStyle(
                                              color: darkOrange,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        content: new Text("Update data driver"),
                                        actions: <Widget>[
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: Colors.grey.shade500,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("Ok"),
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              var driverID =
                                              prefs.getString("driver_id");
                                              updateDriver(driverID!);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: primaryOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );
                                    print('Update');
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: cardColor,
                                        title: new Text('Information',
                                            style: TextStyle(
                                              color: darkOrange,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        content: new Text("Save data driver"),
                                        actions: <Widget>[
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: Colors.grey.shade500,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("Ok"),
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              saveDriver("1");
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: primaryOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );
                                    print('save');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 2.0,
                                    backgroundColor: primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    textStyle: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                              ))
                        ]),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 16, top: 0, right: 16, bottom: 16),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                  size: 18.0,
                                ),
                                label: Text(btnSubmitText + " 2"),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  var is_edit = prefs.getBool("is_edit");
                                  if (is_edit != null && is_edit == true) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: cardColor,
                                        title: new Text('Information',
                                            style: TextStyle(
                                              color: darkOrange,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        content: new Text("Update data driver"),
                                        actions: <Widget>[
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: Colors.grey.shade500,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("Ok"),
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              var driverID =
                                              prefs.getString("driver_id");
                                              updateDriver(driverID!);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: primaryOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );
                                    print('Update');
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: cardColor,
                                        title: new Text('Information',
                                            style: TextStyle(
                                              color: darkOrange,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        content: new Text("Save data driver"),
                                        actions: <Widget>[
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: Colors.grey.shade500,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            label: Text("Ok"),
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              saveDriver("2");
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2.0,
                                                backgroundColor: primaryOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );
                                    print('save');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 2.0,
                                    backgroundColor: accentOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    textStyle: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                              )),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}