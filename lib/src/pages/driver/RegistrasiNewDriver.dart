
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
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
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
  TextEditingController txtNomorDarurat = new TextEditingController();
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
  final Map<String, String> _ktpScan = {
    'nik': '',
    'nama': '',
    'ttl': '',
    'jenisKelamin': '',
    'golDarah': '',
    'alamat': '',
    'rtRw': '',
    'kelDesa': '',
    'kecamatan': '',
    'agama': '',
    'status': '',
    'pekerjaan': '',
    'kewarganegaraan': '',
    'berlaku': '',
  };
  List<Map<String, dynamic>> lstVheicleType = [];
  List<Map<String, dynamic>> lstRequestNumber = [];
  List<Map<String, dynamic>> lstRefferensi = [];
  final List<S2Choice<String>> simTypeChoices = [
    S2Choice<String>(value: 'B1', title: 'B1'),
    S2Choice<String>(value: 'B1 UMUM', title: 'B1 UMUM'),
    S2Choice<String>(value: 'BII', title: 'BII'),
    S2Choice<String>(value: 'B II UMUM', title: 'B II UMUM'),
  ];
  final List<S2Choice<String>> ukuranBajuChoices = [
    S2Choice<String>(value: 'M', title: 'M'),
    S2Choice<String>(value: 'L', title: 'L'),
    S2Choice<String>(value: 'XL', title: 'XL'),
    S2Choice<String>(value: 'XXL', title: 'XXL'),
    S2Choice<String>(value: 'XXXL', title: 'XXXL'),
  ];
  final List<S2Choice<String>> ukuranCelanaChoices = List.generate(
    10,
    (index) {
      final value = (29 + index).toString();
      return S2Choice<String>(value: value, title: value);
    },
  );
  final List<S2Choice<String>> ukuranSepatuChoices = List.generate(
    5,
    (index) {
      final value = (39 + index).toString();
      return S2Choice<String>(value: value, title: value);
    },
  );

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
      txtNomorDarurat.text = "";
      _clearKtpScan();
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
            txtNomorDarurat.text =
            dataDriver[0]['drvemaile'] == null ||
                    dataDriver[0]['drvemaile'] == "null"
                ? ""
                : dataDriver[0]['drvemaile'];
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
      var drvemaile = txtNomorDarurat.text;
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
          'drvemaile': drvemaile,
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
      var drvemaile = txtNomorDarurat.text;
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
          'drvemaile': drvemaile,
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

  // Custom TextField with orange theme//
  void _clearKtpScan() {
    _ktpScan.updateAll((key, value) => '');
  }

  List<MapEntry<String, String>> _ktpRowsOf(Map<String, String> data) {
    const labels = <String, String>{
      'nik': 'NIK',
      'nama': 'Nama',
      'ttl': 'Tempat/Tgl Lahir',
      'jenisKelamin': 'Jenis Kelamin',
      'golDarah': 'Gol. Darah',
      'alamat': 'Alamat',
      'rtRw': 'RT/RW',
      'kelDesa': 'Kel/Desa',
      'kecamatan': 'Kecamatan',
      'agama': 'Agama',
      'status': 'Status Perkawinan',
      'pekerjaan': 'Pekerjaan',
      'kewarganegaraan': 'Kewarganegaraan',
      'berlaku': 'Berlaku Hingga',
    };
    return labels.entries
        .map((e) => MapEntry(e.value, (data[e.key] ?? '').trim()))
        .where((e) => e.value.isNotEmpty)
        .toList();
  }

  List<MapEntry<String, String>> _ktpScanVisible() => _ktpRowsOf(_ktpScan);

  Map<String, String> _emptyKtpMap() => {
        'nik': '',
        'nama': '',
        'ttl': '',
        'jenisKelamin': '',
        'golDarah': '',
        'alamat': '',
        'rtRw': '',
        'kelDesa': '',
        'kecamatan': '',
        'agama': '',
        'status': '',
        'pekerjaan': '',
        'kewarganegaraan': '',
        'berlaku': '',
      };

  String _ktpCompact(String s) =>
      s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  int _lev(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final m = List.generate(a.length + 1, (i) => List<int>.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) m[i][0] = i;
    for (var j = 0; j <= b.length; j++) m[0][j] = j;
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        m[i][j] = [m[i - 1][j] + 1, m[i][j - 1] + 1, m[i - 1][j - 1] + cost]
            .reduce((x, y) => x < y ? x : y);
      }
    }
    return m[a.length][b.length];
  }

  bool _nearLabel(String compact, String target, [int maxDist = 2]) {
    if (compact == target) return true;
    if (compact.startsWith(target) && compact.length <= target.length + 5) {
      return true;
    }
    if (target.startsWith(compact) && target.length - compact.length <= 2) {
      return compact.length >= 4;
    }
    if ((compact.length - target.length).abs() > maxDist + 1) return false;
    return _lev(compact, target) <= maxDist;
  }

  static const _ktpLabelTargets = [
    'NIK',
    'NAMA',
    'TEMPATLAHIR',
    'TEMPATGLLAHIR',
    'FEMPATGLLAHIR',
    'FEMPATHGLLAHIR',
    'TTL',
    'JENISKELAMIN',
    'JENTSKELAMIN',
    'GOLDARAH',
    'ALAMAT',
    'ALAMAE',
    'RTRW',
    'RTRWE',
    'KELDESA',
    'KELURAHAN',
    'KECAMATAN',
    'KECAMNATAN',
    'AGAMA',
    'STATUSPERKAWINAN',
    'STATUS',
    'PEKERJAAN',
    'KEWARGANEGARAAN',
    'BERLAKUHINGGA',
    'BERLAKU',
    'PROVINSI',
    'KABUPATEN',
    'KOTA',
    'KARTUTANDAPENDUDUK',
  ];

  bool _looksLikeKtpLabel(String raw) {
    final c = _ktpCompact(raw.split(':').first);
    if (c.isEmpty) return true;
    // TEMPATTGL + LAHIR tanpa huruf kecil
    final ttlCanon = 'TEMPATTGL' 'LAHIR';
    return _ktpLabelTargets.any((l) => _nearLabel(c, l)) ||
        _nearLabel(c, ttlCanon) ||
        c.contains('LAHIR');
  }

  bool _isNoiseLine(String line) {
    final u = line.toUpperCase();
    const junk = [
      'ATMOS',
      'DOLBY',
      'WIFI',
      'CERTIFIED',
      'DDR',
      'SHIFT',
      'ENTER',
      'INSERT',
      'BLADE',
      'MULTIMEDIA',
      'NTERFACE',
      'PERFORMANCE',
      'TWO-WAY',
      'FINITION',
      'VISIONKIT',
      'HIGH PERFORMANCE',
      'POPUP',
    ];
    return junk.any((n) => u.contains(n));
  }

  String _fixNik(String raw, {bool aggressive = false}) {
    final direct = RegExp(r'\d{16}').firstMatch(raw);
    if (direct != null) return direct.group(0)!;
    var token = raw.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');
    token = token
        .replaceAll('O', '0')
        .replaceAll('Q', '0')
        .replaceAll('L', '1')
        .replaceAll('I', '1');
    if (aggressive) {
      token = token
          .replaceAll('D', '0')
          .replaceAll('Z', '2')
          .replaceAll('S', '5')
          .replaceAll('B', '8')
          .replaceAll('G', '6');
    } else {
      token = token.replaceAll('D', '0');
    }
    final m = RegExp(r'\d{16}').firstMatch(token);
    return m?.group(0) ?? '';
  }

  bool _isNikLabel(String line) {
    final c = _ktpCompact(line.split(':').first);
    return c == 'NIK' || _nearLabel(c, 'NIK', 1);
  }

  bool _isNamaLabelLine(String line) {
    final left = line.split(':').first.trim();
    final c = _ktpCompact(left);
    return c == 'NAMA' || c == 'NAME';
  }

  bool _isTtlLine(String line) {
    final c = _ktpCompact(line);
    return c.contains('LAHIR') ||
        RegExp(r'\d{1,2}[-/.]\d{1,2}[-/.]\d{4}').hasMatch(line);
  }

  Set<String> _headerPlaces(List<String> lines) {
    final places = <String>{};
    for (final line in lines) {
      final u = line.toUpperCase();
      if (!u.contains('PROVINSI') &&
          !u.contains('KABUPATEN') &&
          !RegExp(r'\bKOTA\b').hasMatch(u)) {
        continue;
      }
      final rest = u
          .replaceAll('PROVINSI', ' ')
          .replaceAll('KABUPATEN', ' ')
          .replaceAll(RegExp(r'\bKOTA\b'), ' ');
      for (final w in rest.split(RegExp(r'[^A-Z]+'))) {
        if (w.length >= 4) places.add(w);
      }
    }
    return places;
  }

  String _validPersonName(String raw, Set<String> header) {
    if (raw.trim().isEmpty) return '';
    var v = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z .]'), ' ');
    v = v.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (v.isEmpty || _fixNik(v).isNotEmpty) return '';
    if (v.contains('PROVINSI') ||
        v.contains('KABUPATEN') ||
        v.contains('LAHIR') ||
        v.contains('GOL') ||
        v.contains('JENIS') ||
        v.contains('ALAMAT') ||
        v.contains('PENDUDUK')) {
      return '';
    }
    if (_looksLikeKtpLabel(v)) return '';
    final words = v.split(' ').where((w) => w.length >= 2).toList();
    if (words.isEmpty) return '';
    if (words.every((w) => header.contains(w))) return '';
    if (words.length == 1 && header.contains(words.first)) return '';
    // 1 kata pendek = hampir pasti header (BOGOR), bukan nama KTP
    if (words.length == 1 && words.first.length <= 8) return '';
    if (!RegExp(r'[A-Z]{3,}').hasMatch(v)) return '';
    return words.join(' ');
  }

  String _extractNikFromLines(List<String> lines) {
    final joined = lines.join(' ');
    var n = _fixNik(joined);
    if (n.isNotEmpty) return n;
    for (var i = 0; i < lines.length; i++) {
      if (!_isNikLabel(lines[i]) && _fixNik(lines[i]).isEmpty) continue;
      for (final idx in [i, i + 1, i - 1]) {
        if (idx < 0 || idx >= lines.length) continue;
        n = _fixNik(lines[idx]);
        if (n.isEmpty) n = _fixNik(lines[idx], aggressive: true);
        if (n.isNotEmpty) return n;
      }
    }
    return _fixNik(joined, aggressive: true);
  }

  /// Nama KTP selalu setelah NIK, bukan kota di header (BOGOR).
  String _extractNamaAfterNik(List<String> lines) {
    final header = _headerPlaces(lines);
    int nikIdx = -1;
    int namaIdx = -1;
    for (var i = 0; i < lines.length; i++) {
      if (nikIdx < 0 &&
          (_isNikLabel(lines[i]) || _fixNik(lines[i]).isNotEmpty)) {
        nikIdx = i;
      }
      if (namaIdx < 0 && _isNamaLabelLine(lines[i])) namaIdx = i;
    }

    String? fromNamaLine;
    if (namaIdx >= 0) {
      final line = lines[namaIdx];
      final colon = line.indexOf(':');
      if (colon >= 0) {
        fromNamaLine = _validPersonName(line.substring(colon + 1), header);
      } else {
        final rest = line.replaceFirst(RegExp(r'^nama\s*', caseSensitive: false), '');
        fromNamaLine = _validPersonName(rest, header);
      }
    }
    if (fromNamaLine != null && fromNamaLine.isNotEmpty) return fromNamaLine;

    final scored = <({int score, String name})>[];
    void addCand(int idx, int score) {
      if (idx < 0 || idx >= lines.length) return;
      if (_isNamaLabelLine(lines[idx]) || _isNikLabel(lines[idx])) return;
      if (_isTtlLine(lines[idx]) && _ktpCompact(lines[idx]).contains('LAHIR')) {
        return;
      }
      final name = _validPersonName(lines[idx], header);
      if (name.isEmpty) return;
      scored.add((score: score + (name.contains(' ') ? 5 : 0), name: name));
    }

    if (namaIdx >= 0) {
      addCand(namaIdx + 1, 20);
      addCand(namaIdx - 1, 8);
    }
    if (nikIdx >= 0) {
      var after = nikIdx + 1;
      if (after < lines.length && _isNikLabel(lines[nikIdx]) && _fixNik(lines[after]).isNotEmpty) {
        after++;
      }
      if (after < lines.length && _isNamaLabelLine(lines[after])) {
        addCand(after + 1, 25);
      } else {
        addCand(after, 18);
        addCand(after + 1, 12);
      }
    }

    if (nikIdx >= 0) {
      final start = nikIdx;
      final end = (namaIdx >= 0 ? namaIdx + 2 : nikIdx + 6).clamp(0, lines.length);
      for (var i = start; i < end; i++) {
        if (_isTtlLine(lines[i]) && i > nikIdx + 1) break;
        addCand(i, 6);
      }
    }

    if (scored.isEmpty) return '';
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.first.name;
  }

  String _sanitizeKtp(String key, String raw) {
    var v = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    v = v.replaceFirst(RegExp(r'^[:.\-\s]+'), '').trim();
    if (v.isEmpty || v == '-') return '';

    switch (key) {
      case 'nik':
        return _fixNik(v);
      case 'nama':
        return _validPersonName(v, const {});
      case 'ttl':
        var chunk = v.toUpperCase();
        final lahirAt = chunk.indexOf('LAHIR');
        if (lahirAt >= 0) chunk = chunk.substring(lahirAt + 5);
        final m = RegExp(
                r'([A-Z]{3,}),\s*(\d{1,2}[-/.]\d{1,2}[-/.]\d{4})')
            .firstMatch(chunk);
        return m == null ? '' : '${m.group(1)!.trim()}, ${m.group(2)}';
      case 'jenisKelamin':
        final u = v.toUpperCase();
        if (u.contains('PEREMPUAN')) return 'PEREMPUAN';
        if (u.contains('LAKI')) return 'LAKI-LAKI';
        return '';
      case 'golDarah':
        final u = v.toUpperCase().replaceAll(RegExp(r'[^ABO]'), '');
        if (u.contains('AB')) return 'AB';
        if (u == 'A' || u == 'B' || u == 'O') return u;
        return '';
      case 'rtRw':
        final m = RegExp(r'(\d{1,3})\s*/\s*(\d{1,3})').firstMatch(v);
        return m == null ? '' : '${m.group(1)}/${m.group(2)}';
      case 'agama':
        final u = v.toUpperCase();
        for (final a in [
          'ISLAM',
          'KRISTEN',
          'KATHOLIK',
          'KATOLIK',
          'HINDU',
          'BUDDHA',
          'BUDHA',
          'KONGHUCU'
        ]) {
          if (u.contains(a)) return a;
        }
        return '';
      case 'status':
        final u = v.toUpperCase();
        if (u.contains('BELUM')) return 'BELUM KAWIN';
        if (u.contains('CERAI HIDUP')) return 'CERAI HIDUP';
        if (u.contains('CERAI MATI')) return 'CERAI MATI';
        if (RegExp(r'\bKAWIN\b').hasMatch(u) || u == 'KAWIN') return 'KAWIN';
        return '';
      case 'kewarganegaraan':
        final u = v.toUpperCase();
        if (u.contains('WNI')) return 'WNI';
        if (u.contains('WNA')) return 'WNA';
        return '';
      case 'berlaku':
        if (v.toUpperCase().contains('SEUMUR')) return 'SEUMUR HIDUP';
        final m = RegExp(r'\d{1,2}[-/.]\d{1,2}[-/.]\d{4}').firstMatch(v);
        return m?.group(0) ?? '';
      case 'pekerjaan':
        if (v.toUpperCase().contains('KEWARGANEGARAAN') || _looksLikeKtpLabel(v)) {
          return '';
        }
        return v.toUpperCase();
      case 'alamat':
        if (_looksLikeKtpLabel(v) ||
            v.toUpperCase() == 'ISLAM' ||
            _fixNik(v).isNotEmpty) {
          return '';
        }
        if (!RegExp(r'[0-9]').hasMatch(v) &&
            !v.contains(' ') &&
            v.length < 12) {
          return '';
        }
        return v.toUpperCase();
      case 'kelDesa':
        if (_looksLikeKtpLabel(v) || v.contains('/')) return '';
        return RegExp(r'[A-Z]{3,}').hasMatch(v.toUpperCase()) ? v.toUpperCase() : '';
      case 'kecamatan':
        if (_looksLikeKtpLabel(v) ||
            v.contains('/') ||
            v.toUpperCase() == 'ISLAM' ||
            v.toUpperCase() == 'KAWIN') {
          return '';
        }
        return RegExp(r'[A-Z]{3,}').hasMatch(v.toUpperCase()) ? v.toUpperCase() : '';
      default:
        return v;
    }
  }

  void _setKtpIfEmpty(Map<String, String> parsed, String key, String? raw) {
    if (raw == null || (parsed[key] ?? '').isNotEmpty) return;
    final v = _sanitizeKtp(key, raw);
    if (v.isNotEmpty) parsed[key] = v;
  }

  /// Label di kiri colon / awal baris. Fuzzy: AlamaE, Kecamnatan, RT/RWE.
  String? _valueForLabel(String line, List<String> labelCompacts) {
    final colon = line.indexOf(':');
    if (colon >= 0) {
      final leftC = _ktpCompact(line.substring(0, colon));
      for (final lab in labelCompacts) {
        if (_nearLabel(leftC, lab)) return line.substring(colon + 1).trim();
      }
      return null;
    }
    final compact = _ktpCompact(line);
    for (final lab in labelCompacts) {
      if (_nearLabel(compact, lab)) return '';
      if (compact.startsWith(lab) && compact.length > lab.length + 2) {
        final m = RegExp(r'^[A-Za-z./]{3,24}\s+(.+)$').firstMatch(line);
        if (m != null) return m.group(1)!.trim();
        // glued: FempatHglLahirHASIKMALAYA, 12-03-1981
        return line;
      }
    }
    return null;
  }

  bool _lineIsKtpLabel(String line) {
    return _looksLikeKtpLabel(line.split(':').first);
  }

  String? _whichKtpField(String line, Map<String, List<String>> fieldLabels) {
    final left = line.split(':').first;
    final compact = _ktpCompact(left);
    String? hit;
    for (final e in fieldLabels.entries) {
      for (final lab in e.value) {
        if (_nearLabel(compact, lab) ||
            (compact.contains('LAHIR') && e.key == 'ttl')) {
          hit = e.key;
          break;
        }
      }
      if (hit != null) break;
    }
    return hit;
  }

  Map<String, String> _parseKtpLines(List<String> rawLines) {
    final parsed = _emptyKtpMap();
    final lines = rawLines
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !_isNoiseLine(e))
        .toList();
    final joined = lines.join('\n');

    final fieldLabels = <String, List<String>>{
      'nik': ['NIK'],
      'nama': ['NAMA'],
      'ttl': [
        'TEMPATTGL' 'LAHIR',
        'TEMPATGLLAHIR',
        'FEMPATGLLAHIR',
        'FEMPATHGLLAHIR',
        'TEMPATLAHIR',
        'TTL'
      ],
      'jenisKelamin': ['JENISKELAMIN', 'JENTSKELAMIN', 'JENTSKELAMINE'],
      'golDarah': ['GOLDARAH'],
      'alamat': ['ALAMAT', 'ALAMAE', 'ALAMA'],
      'rtRw': ['RTRW', 'RTRWE'],
      'kelDesa': ['KELDESA', 'KELURAHAN'],
      'kecamatan': ['KECAMATAN', 'KECAMNATAN'],
      'agama': ['AGAMA'],
      'status': ['STATUSPERKAWINAN'],
      'pekerjaan': ['PEKERJAAN'],
      'kewarganegaraan': ['KEWARGANEGARAAN'],
      'berlaku': ['BERLAKUHINGGA', 'BERLAKU'],
    };

    parsed['nik'] = _extractNikFromLines(lines);
    _setKtpIfEmpty(
        parsed,
        'jenisKelamin',
        RegExp(r'(LAKI[\s\-]*LAKI|PEREMPUAN)', caseSensitive: false)
            .firstMatch(joined)
            ?.group(1));
    _setKtpIfEmpty(
        parsed,
        'agama',
        RegExp(r'\b(ISLAM|KRISTEN|KATHOLIK|KATOLIK|HINDU|BUDDHA|BUDHA|KONGHUCU)\b',
                caseSensitive: false)
            .firstMatch(joined)
            ?.group(1));
    _setKtpIfEmpty(
        parsed,
        'status',
        RegExp(r'(BELUM\s+KAWIN|CERAI\s+HIDUP|CERAI\s+MATI|\bKAWIN\b)',
                caseSensitive: false)
            .firstMatch(joined)
            ?.group(0));
    _setKtpIfEmpty(
        parsed,
        'kewarganegaraan',
        RegExp(r'\b(WNI|WNA)\b', caseSensitive: false).firstMatch(joined)?.group(1));
    _setKtpIfEmpty(
        parsed,
        'berlaku',
        RegExp(r'SEUMUR\s+HIDUP', caseSensitive: false).firstMatch(joined)?.group(0));
    for (final line in lines) {
      _setKtpIfEmpty(parsed, 'ttl', line);
    }
    _setKtpIfEmpty(
        parsed,
        'rtRw',
        RegExp(r'(\d{1,3})\s*/\s*(\d{1,3})').firstMatch(joined)?.group(0));

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final key = _whichKtpField(line, fieldLabels);
      if (key == null || key == 'nama' || (parsed[key] ?? '').isNotEmpty) continue;

      var val = _valueForLabel(line, fieldLabels[key]!);
      if (val == null) continue;
      if (val.isNotEmpty) _setKtpIfEmpty(parsed, key, val);

      if ((parsed[key] ?? '').isEmpty) {
        final neighbors = key == 'alamat'
            ? [i - 1, i + 1, i - 2, i + 2]
            : [i - 1, i + 1];
        final chunks = <String>[];
        for (final idx in neighbors) {
          if (idx < 0 || idx >= lines.length) continue;
          if (_isNoiseLine(lines[idx])) continue;
          if (_lineIsKtpLabel(lines[idx]) && key != 'ttl') continue;
          final ok = _sanitizeKtp(key, lines[idx]);
          if (ok.isEmpty) continue;
          if (key == 'alamat') {
            chunks.add(ok);
          } else {
            parsed[key] = ok;
            break;
          }
        }
        if (key == 'alamat' && chunks.isNotEmpty) {
          parsed['alamat'] = chunks.toSet().join(' ');
        }
      }
    }

    final nama = _extractNamaAfterNik(lines);
    if (nama.isNotEmpty) parsed['nama'] = nama;

    return parsed;
  }

  Map<String, String> _parseKtpText(String raw) {
    final lines = raw.replaceAll('\r', '\n').split('\n');
    final a = _parseKtpLines(lines);
    final b = _parseKtpLines(lines.reversed.toList());
    return _scoreKtp(a) >= _scoreKtp(b) ? a : b;
  }

  int _scoreKtp(Map<String, String> d) {
    var s = 0;
    final hasNik = (d['nik'] ?? '').length == 16;
    final hasNama = (d['nama'] ?? '').isNotEmpty;
    final hasTtl = (d['ttl'] ?? '').contains(',');
    if (hasNik) s += 15;
    if (hasNama) s += 10;
    if (hasTtl) s += 10;
    if ((d['jenisKelamin'] ?? '').isNotEmpty) s += 3;
    if ((d['alamat'] ?? '').length > 4) s += 4;
    if ((d['agama'] ?? '').isNotEmpty) s += 3;
    if ((d['status'] ?? '').isNotEmpty) s += 2;
    if ((d['pekerjaan'] ?? '').isNotEmpty) s += 2;
    if ((d['kewarganegaraan'] ?? '').isNotEmpty) s += 2;
    if ((d['berlaku'] ?? '').isNotEmpty) s += 2;
    if ((d['rtRw'] ?? '').contains('/')) s += 2;
    if ((d['kelDesa'] ?? '').isNotEmpty) s += 2;
    if ((d['kecamatan'] ?? '').isNotEmpty) s += 2;
    // orientasi laptop-sticker jangan menang cuma karena agama+pekerjaan
    if (!hasNik && !hasNama && !hasTtl) s = s > 6 ? 6 : s;
    return s;
  }

  String _normalizeKtpDate(String raw) {
    final m = RegExp(r'(\d{1,2})[-\/.](\d{1,2})[-\/.](\d{4})').firstMatch(raw);
    if (m == null) return raw;
    final d = m.group(1)!.padLeft(2, '0');
    final mo = m.group(2)!.padLeft(2, '0');
    return '${m.group(3)}-$mo-$d';
  }

  /// NIK digit 7-8: hari, perempuan = hari+40.
  String? _jkFromNik(String nik) {
    if (nik.length != 16) return null;
    final day = int.tryParse(nik.substring(6, 8));
    if (day == null) return null;
    return day > 40 ? 'FEMALE' : 'MALE';
  }

  void _applyKtpToForm(Map<String, String> d) {
    final nama = (d['nama'] ?? '').trim();
    if (nama.isNotEmpty) {
      txtDriverName.text = nama;
      txtNickName.text = nama;
    }

    final ttl = d['ttl'] ?? '';
    if (ttl.contains(',')) {
      final parts = ttl.split(',');
      final tempat = parts[0].trim();
      if (tempat.isNotEmpty) txtTempatLahir.text = tempat;
      if (parts.length > 1) {
        txtTglLahir.text = _normalizeKtpDate(parts[1].trim());
      }
    }

    final addr = <String>[];
    final alamat = (d['alamat'] ?? '').trim();
    final rt = (d['rtRw'] ?? '').trim();
    final kel = (d['kelDesa'] ?? '').trim();
    final kec = (d['kecamatan'] ?? '').trim();
    if (alamat.isNotEmpty) addr.add(alamat);
    if (rt.isNotEmpty) addr.add('RT/RW $rt');
    if (kel.isNotEmpty) addr.add('Kel/Desa $kel');
    if (kec.isNotEmpty) addr.add('Kecamatan $kec');
    if (addr.isNotEmpty) txtAddress.text = addr.join(', ');

    final jk = (d['jenisKelamin'] ?? '').toUpperCase();
    if (jk.contains('PEREMPUAN') || jk.contains('WANITA')) {
      selJenisKelamin = 'FEMALE';
      d['jenisKelamin'] = 'PEREMPUAN';
    } else if (jk.contains('LAKI')) {
      selJenisKelamin = 'MALE';
      d['jenisKelamin'] = 'LAKI-LAKI';
    } else {
      final fromNik = _jkFromNik(d['nik'] ?? '');
      if (fromNik != null) {
        selJenisKelamin = fromNik;
        d['jenisKelamin'] = fromNik == 'MALE' ? 'LAKI-LAKI' : 'PEREMPUAN';
      }
    }

    final nik = (d['nik'] ?? '').trim();
    if (nik.isNotEmpty) txtNomorKTP.text = nik;
    if (selGolDar.isEmpty && (d['golDarah'] ?? '').isNotEmpty) {
      selGolDar = d['golDarah']!.toUpperCase();
    }
  }

  Future<File> _rotateKtpFile(File src, int deg) async {
    if (deg == 0) return src;
    final decoded = img.decodeImage(await src.readAsBytes());
    if (decoded == null) return src;
    var im = decoded;
    if (im.width > 1600) {
      im = img.copyResize(im, width: 1600);
    }
    im = img.copyRotate(im, angle: deg);
    final out = File(
        '${Directory.systemTemp.path}/ktp_${deg}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await out.writeAsBytes(img.encodeJpg(im, quality: 90));
    return out;
  }

  Future<String> _recognizeKtpText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await textRecognizer.processImage(inputImage).timeout(
        Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('OCR timeout'),
      );
      final rows = <({double y, double x, String t})>[];
      for (final block in recognized.blocks) {
        for (final line in block.lines) {
          final box = line.boundingBox;
          rows.add((y: box.top, x: box.left, t: line.text.trim()));
        }
      }
      rows.sort((a, b) {
        if ((a.y - b.y).abs() < 14) return a.x.compareTo(b.x);
        return a.y.compareTo(b.y);
      });
      if (rows.isEmpty) return recognized.text;
      return rows.map((e) => e.t).join('\n');
    } finally {
      await textRecognizer.close();
    }
  }

  Future<Map<String, String>> _ocrKtpBest(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    final portrait = decoded != null && decoded.height > decoded.width;
    final angles = portrait ? [90, 270, 0, 180] : [0, 90, 180, 270];

    var best = _emptyKtpMap();
    var bestScore = -1;
    for (final deg in angles) {
      File fileToUse = imageFile;
      try {
        fileToUse = await _rotateKtpFile(imageFile, deg)
            .timeout(Duration(seconds: 8), onTimeout: () => imageFile);
      } catch (_) {
        fileToUse = imageFile;
      }
      final text = await _recognizeKtpText(fileToUse);
      debugPrint('KTP OCR $deg°:\n$text');
      final parsed = _parseKtpText(text);
      final score = _scoreKtp(parsed);
      debugPrint('KTP score $deg°=$score $parsed');
      if (score > bestScore) {
        bestScore = score;
        best = parsed;
      }
      if (score >= 28) break;
    }
    return best;
  }

  Future<void> _scanKtp() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (picked == null) return;
      final imageFile = File(picked.path);
      if (filePathImageKTP.isEmpty) {
        _imageKTP = imageFile;
        filePathImageKTP = base64Encode(imageFile.readAsBytesSync());
        is_edit_image_ktp = true;
      }

      EasyLoading.show(status: 'Membaca KTP (OCR)...');
      final parsed = await _ocrKtpBest(imageFile);
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      await _showKtpResultDialog(parsed);
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      if (mounted) {
        alert(globalScaffoldKey.currentContext!, 0, 'Gagal scan KTP: $e',
            'error');
      }
    }
  }

  Map<String, String> _previewKtp(Map<String, String> parsed) {
    final data = _emptyKtpMap();
    parsed.forEach((k, v) {
      if (v.trim().isNotEmpty) data[k] = v.trim();
    });
    final jk = (data['jenisKelamin'] ?? '').toUpperCase();
    if (!jk.contains('LAKI') &&
        !jk.contains('PEREMPUAN') &&
        !jk.contains('WANITA')) {
      final fromNik = _jkFromNik(data['nik'] ?? '');
      if (fromNik != null) {
        data['jenisKelamin'] = fromNik == 'MALE' ? 'LAKI-LAKI' : 'PEREMPUAN';
      }
    }
    return data;
  }

  Future<void> _showKtpResultDialog(Map<String, String> parsed) async {
    final data = _previewKtp(parsed);
    final rows = _ktpRowsOf(data);
    if (rows.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0,
          'Data KTP tidak terbaca. Foto ulang dengan pencahayaan lebih baik.',
          'error');
      return;
    }
    if (!mounted) return;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(18, 16, 8, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryOrange, darkOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.badge_outlined,
                            color: Colors.white, size: 22),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data KTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Cek dulu, baru masuk ke form',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx, 'close'),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (_, i) {
                      final e = rows[i];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 112,
                              child: Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(14, 10, 14, 14),
                  decoration: BoxDecoration(
                    color: lightOrange,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, 'close'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Close',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, 'ulang'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkOrange,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: primaryOrange, width: 1.4),
                            padding: EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Ulang',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, 'ok'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('OK',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (action == 'ok') {
      setState(() {
        _clearKtpScan();
        data.forEach((k, v) {
          if (v.trim().isNotEmpty) _ktpScan[k] = v.trim();
        });
        _applyKtpToForm(_ktpScan);
      });
    } else if (action == 'ulang') {
      await Future.delayed(Duration(milliseconds: 180));
      if (mounted) await _scanKtp();
    }
  }

  Widget _buildKtpScanSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: ElevatedButton.icon(
        onPressed: _scanKtp,
        icon: Icon(Icons.document_scanner, color: Colors.white, size: 18),
        label: Text('Scan KTP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12),
          minimumSize: Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),//
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
                      _buildKtpScanSection(),
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
                      buildSmartSelect(
                        title: 'Type SIM *',
                        value: txtSIMName.text,
                        onChange: (selected) {
                          setState(() => txtSIMName.text = selected.value);
                        },
                        choices: simTypeChoices,
                        modalFilter: false,
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
                      buildTextField(
                        labelText: "Nomor Darurat",
                        controller: txtNomorDarurat,
                        keyboardType: TextInputType.phone,
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
                      buildSmartSelect(
                        title: 'Ukuran Baju',
                        value: txtUkuranBaju.text,
                        onChange: (selected) {
                          setState(() => txtUkuranBaju.text = selected.value);
                        },
                        choices: ukuranBajuChoices,
                        modalFilter: false,
                      ),
                      buildSmartSelect(
                        title: 'Ukuran Celana',
                        value: txtUkuranCelana.text,
                        onChange: (selected) {
                          setState(() => txtUkuranCelana.text = selected.value);
                        },
                        choices: ukuranCelanaChoices,
                        modalFilter: false,
                      ),
                      buildSmartSelect(
                        title: 'Ukuran Sepatu',
                        value: txtUkuranSepatu.text,
                        onChange: (selected) {
                          setState(() => txtUkuranSepatu.text = selected.value);
                        },
                        choices: ukuranSepatuChoices,
                        modalFilter: false,
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