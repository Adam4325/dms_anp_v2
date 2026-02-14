import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/component/custom_animated_bottom_bar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterNewDriver extends StatefulWidget {
  @override
  RegisterNewDriverstate createState() => RegisterNewDriverstate();
}

class RegisterNewDriverstate extends State<RegisterNewDriver> {
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
  TextEditingController txtStartDatePendidikan = new TextEditingController();
  TextEditingController txtEndDatePendidikan = new TextEditingController();

  TextEditingController txtLisenceName = new TextEditingController();
  TextEditingController txtNumberLisence = new TextEditingController();
  TextEditingController txtLisenceExpired = new TextEditingController();
  TextEditingController txtNoTelpon = new TextEditingController();
  TextEditingController txtCompany = new TextEditingController();
  TextEditingController txtCabang = new TextEditingController();
  TextEditingController txtVehicleType = new TextEditingController();
  TextEditingController txtStatusUser = new TextEditingController();

  TextEditingController txtAyahKandung = new TextEditingController();
  TextEditingController txtIbuKandung = new TextEditingController();
  TextEditingController txtBpjsKesehatan = new TextEditingController();
  TextEditingController txtNomorKK = new TextEditingController();
  TextEditingController txtStatusFamily = new TextEditingController();

  TextEditingController txtDriverNote = new TextEditingController();

  String _tglLahir = "";
  String _startDatePendidikan = "";
  String _endDatePendidikan = "";
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();

  int _currentIndex = 0;
  final _inactiveColor = Colors.grey;
  late File _image;
  String filePathImage = "";
  late CameraController controller;
  late List cameras;
  int? selectedCameraIdx;
  String? imagePath;
  //int _ocrCamera = FlutterMobileVision.CAMERA_BACK;
  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future getImageFromCamera() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image.readAsBytesSync();
        filePathImage = base64UrlEncode(imageBytes);
        //print(filePathImage);
      } else {
        print('No image selected.');
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library Forbidden'),
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  // _imgFromCamera() async {
  //   File image = (await ImagePicker.p(
  //       source: ImageSource.camera, imageQuality: 50
  //   )) as File;
  //
  //   setState(() {
  //     _image = image;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () {
              //_goBack(context);
            },
          ),
          title: Text("Register New Driver"),
          backgroundColor: Colors.blue,
        ),
        body: getBody(),
        bottomNavigationBar: _buildBottomBar());
  }

  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Colors.black,
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) => setState(() => _currentIndex = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: Icon(Icons.people),
          title: Text('Biodata'),
          activeColor: Colors.blueAccent,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.book),
          title: Text('Pendidikan'),
          activeColor: Colors.blueAccent,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.card_membership),
          title: Text('Identitas'),
          activeColor: Colors.blueAccent,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.family_restroom),
          title: Text('Keluarga'),
          activeColor: Colors.blueAccent,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.devices_other),
          title: Text('Lainnya'),
          activeColor: Colors.blue,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget getBody() {
    List<Widget> pages = [
      Container(
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
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtDriverName,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Driver name",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtNickName,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Nick Name",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtTglLahir,
                  //initialValue: _initialValue,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Tanggal Lahir',
                  //timeLabelText: "Hour",
                  //use24HourFormat: false,
                  //locale: Locale('pt', 'BR'),
                  selectableDayPredicate: (date) {
                    // if (date.weekday == 6 || date.weekday == 7) {
                    //   return false;
                    // }
                    return true;
                  },
                  onChanged: (val) => setState(() => _tglLahir = val),
                  validator: (val) {
                    setState(() => _tglLahir = val ?? '');
                    return null;
                  },
                  onSaved: (val) => setState(() => _tglLahir = val ?? ''),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtTempatLahir,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Tempat Lahir",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAddress,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Address",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtEmail,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Email",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtProvinsi,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Provinsi",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtCity,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Kota",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
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
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtPendidikan,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Pendidikan",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtStartDatePendidikan,
                  //initialValue: _initialValue,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Tanggal Mulai',
                  //timeLabelText: "Hour",
                  //use24HourFormat: false,
                  //locale: Locale('pt', 'BR'),
                  selectableDayPredicate: (date) {
                    if (date.weekday == 6 || date.weekday == 7) {
                      return false;
                    }
                    return true;
                  },
                  onChanged: (val) => setState(() => _startDatePendidikan = val),
                  validator: (val) {
                    setState(() => _startDatePendidikan = val ?? '');
                    return null;
                  },
                  onSaved: (val) => setState(() => _startDatePendidikan = val ?? ''),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: DateTimePicker(
                  //type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'yyyy-MM-dd',
                  controller: txtEndDatePendidikan,
                  //initialValue: _initialValue,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Tanggal Berakhir',
                  //timeLabelText: "Hour",
                  //use24HourFormat: false,
                  //locale: Locale('pt', 'BR'),
                  selectableDayPredicate: (date) {
                    if (date.weekday == 6 || date.weekday == 7) {
                      return false;
                    }
                    return true;
                  },
                  onChanged: (val) => setState(() => _endDatePendidikan = val),
                  validator: (val) {
                    setState(() => _endDatePendidikan = val ?? '');
                    return null;
                  },
                  onSaved: (val) => setState(() => _endDatePendidikan = val ?? ''),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAddress,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Address",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtEmail,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Email",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtProvinsi,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Provinsi",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtCity,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Kota",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
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
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtLisenceName,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Lisence KTP/SIM",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtNumberLisence,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Lisence Number",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtLisenceExpired,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Lisence Expired",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtNoTelpon,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Handphone Number",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtCompany,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Company",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtCabang,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Cabang",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtVehicleType,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Jenis Kendaraan",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
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
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtAyahKandung,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Nama Ayah Kandung",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtIbuKandung,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Nama Ibu Kandung",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtNomorKK,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Nomor Kartu Keluarga",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtStatusFamily,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Status Keluarga",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
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
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xffFDCF09),
                    child: _image != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtDriverNote,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    labelText: "Driver Notes",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                child: Row(children: <Widget>[
                  // Expanded(
                  //     child: ElevatedButton.icon(
                  //   icon: Icon(
                  //     Icons.camera,
                  //     color: Colors.white,
                  //     size: 15.0,
                  //   ),
                  //   label: Text("Upload Photo"),
                  //   onPressed: () {},
                  //   style: ElevatedButton.styleFrom(
                  //       elevation: 0.0,
                  //       backgroundColor: Colors.blue,
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  //       textStyle: TextStyle(
                  //           fontSize: 12, fontWeight: FontWeight.bold)),
                  // )),
                  // SizedBox(
                  //   width: 2,
                  // ),
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("Submit"),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blue,
                            padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                ]),
              ),
            ],
          ),
        ),
      ),
    ];
    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }
}
