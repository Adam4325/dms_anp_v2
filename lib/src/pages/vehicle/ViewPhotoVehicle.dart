
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../../flusbar.dart';
import '../ViewDashboard.dart';

class ViewPhotoVehicle extends StatefulWidget {
  @override
  _ViewPhotoVehicleState createState() => _ViewPhotoVehicleState();
}

class _ViewPhotoVehicleState extends State<ViewPhotoVehicle> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();
  int status_code = 100;
  var message = "";
  var view_name = "";
  var vhcid = '';
  var drvid = '';
  File? _imageUNITS;
  File? _imageSIM;
  File? _imageSTNK;
  File? _imageKIR;
  File? _imageFAMILY;
  File? _imageDOMISILY;
  String filePathImageUNITS = "";
  String filePathImageSIM = "";
  String filePathImageSTNK = "";
  String filePathImageKIR = "";
  String filePathImageFAMILY = "";
  String filePathImageDOMISILY = "";
  late CameraController controller;
  int? selectedCameraIdx;
  var is_edit_image_sim = false;
  var is_edit_image_stnk = false;
  var is_edit_image_kir = false;
  var is_edit_image_family = false;
  var is_edit_image_domisily = false;
  var is_edit_image_status_unit = false;
  final String BASE_URL =
      GlobalData.baseUrlOriIP; // "http://apps.tuluatas.com:8080/trucking";

  // Fungsi untuk menampilkan gambar full screen
  void showFullScreenImage(
    BuildContext context, {
    File? imageFile,
    String? networkImageUrl,
    String title = "Image",
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageFile: imageFile,
          networkImageUrl: networkImageUrl,
          title: title,
        ),
      ),
    );
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("view_name");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var nameTitle ='';// ${view_name=='FAMILY'?'KELUARGA':view_name}';
    if(view_name=='FAMILY'){
      nameTitle = 'Keluarga';
    }else if(view_name=='STATUS_UNIT'){
      nameTitle = 'QR';
    }else{
      nameTitle = view_name;
    }
    return WillPopScope(
      onWillPop: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("view_name");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
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
                  _goBack(context);
                },
              ),
            ),
            centerTitle: true,
            title: Text(
              'View Photo ${nameTitle}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            )),
        body: Container(
          key: globalScaffoldKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: <Widget>[
                        if (view_name == 'STATUS_UNIT') ...[
                          _buildPhotoSection(
                            context: context,
                            title: "Photo QR",
                            image: _imageUNITS,
                            isEdited: is_edit_image_status_unit,
                            filePath: filePathImageUNITS,
                            photoType: "STATUS_UNIT",
                            urlPath: "${BASE_URL}photo_trucking/PHOTO_UNITS/$filePathImageUNITS",
                          )
                        ],
                        if (view_name == 'SIM') ...[
                          _buildPhotoSection(
                            context: context,
                            title: "Photo SIM",
                            image: _imageSIM,
                            isEdited: is_edit_image_sim,
                            filePath: filePathImageSIM,
                            photoType: "SIM",
                            urlPath: "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageSIM",
                          )
                        ],
                        if (view_name == 'STNK') ...[
                          _buildPhotoSection(
                            context: context,
                            title: "Photo STNK",
                            image: _imageSTNK,
                            isEdited: is_edit_image_stnk,
                            filePath: filePathImageSTNK,
                            photoType: "STNK",
                            urlPath: "${BASE_URL}photo_vehicle/$filePathImageSTNK",
                          )
                        ],
                        if (view_name == 'KIR') ...[
                          _buildPhotoSection(
                            context: context,
                            title: "Photo KIR",
                            image: _imageKIR,
                            isEdited: is_edit_image_kir,
                            filePath: filePathImageKIR,
                            photoType: "KIR",
                            urlPath: "${BASE_URL}photo_vehicle/$filePathImageKIR",
                          )
                        ],
                        if (view_name == 'FAMILY') ...[
                          _buildPhotoSection(
                            context: context,
                            title: "Photo Keluarga",
                            image: _imageFAMILY,
                            isEdited: is_edit_image_family,
                            filePath: filePathImageFAMILY,
                            photoType: "FAMILY",
                            urlPath: "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageFAMILY",
                          )
                        ],
                        if (view_name == 'DOMISILI') ...[
                          _buildPhotoSection(
                            context: context,
                            title: "Photo Domisili",
                            image: _imageDOMISILY,
                            isEdited: is_edit_image_domisily,
                            filePath: filePathImageDOMISILY,
                            photoType: "DOMISILI",
                            urlPath: "${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageDOMISILY",
                          )
                        ],
                        SizedBox(height: 32),
                        _buildUpdateButton(nameTitle),
                      ],
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

  Widget _buildPhotoSection({
    required BuildContext context,
    required String title,
    File? image,
    required bool isEdited,
    required String filePath,
    required String photoType,
    required String urlPath,
  }) {
    // Cek apakah ada gambar yang tersedia:
    // - jika sudah diedit: pakai file lokal (image)
    // - jika belum diedit tetapi ada path: pakai url (filePath)
    bool hasImage = (isEdited && image != null && image.path.isNotEmpty) || filePath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                letterSpacing: 0.3,
              ),
            ),
            if (hasImage) ...[
              ElevatedButton.icon(
                onPressed: () {
                  print("Full screen button pressed");
                  showFullScreenImage(
                    context,
                    imageFile: (image != null && isEdited) ? image : null,
                    networkImageUrl: !isEdited && filePath != null && filePath != "" ? urlPath : null,
                    title: title,
                  );
                },
                icon: Icon(
                  Icons.fullscreen,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  "View",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size(0, 32),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            print("Image tapped for camera/gallery selection");
            // Selalu tampilkan pilihan kamera/gallery untuk ganti gambar
            await getImageFromCamera(context, photoType);
          },
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Image content
                  if (hasImage)
                    (isEdited && image != null
                        ? Image.file(
                            image,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            urlPath,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF7FAFC),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Color(0xFFE65100),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) {
                              return _buildPlaceholder(title);
                            },
                          ))
                  else
                    _buildPlaceholder(title),

                  // Overlay untuk menunjukkan bahwa gambar bisa di-tap untuk ganti
                  if (hasImage) ...[
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Tap untuk ganti",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7FAFC),
            Color(0xFFEDF2F7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE2E8F0),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Color(0xFFE65100).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFFE65100),
              size: 32,
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Tap untuk tambah foto",
            style: TextStyle(
              color: Color(0xFFA0AEC0),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFE65100).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Camera | Gallery",
              style: TextStyle(
                color: Color(0xFFE65100),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(String nameTitle) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE65100),
            Color(0xFFD84315),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE65100).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.cloud_upload_outlined,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          "Update Photo ${nameTitle}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: () async {
          print('Submit ${nameTitle} ${vhcid}');
          showDialog(
            context: globalScaffoldKey.currentContext!,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFE65100).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Color(0xFFE65100),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Konfirmasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              content: Text(
                "Apakah Anda yakin ingin mengupdate photo?",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    if(view_name=="SIM" || view_name=="FAMILY"){
                       SaveOrUpdateSIM();
                    }else if(view_name=="DOMISILI"){
                       SaveOrUpdateDOMISILI();
                    }else if(view_name=="STATUS_UNIT"){
                       SaveOrUpdateUNIT();
                    }else{
                       SaveOrUpdate();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE65100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<String> GetViewImage(String viewName) async {
    //update_or_view_photo_vehicle
    var ret = "";
    try {
      var urlData =
          "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp?method=list-photo-vehicle&vhcid=${vhcid}";
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        var photo_stnk = json.decode(response.body)["photo_stnk"];
        var photo_kir = json.decode(response.body)["photo_kir"];
        if (status_code != null && status_code == 200) {
          if (view_name == "STNK") {
            filePathImageSTNK = photo_stnk;
          } else if (view_name == "KIR") {
            filePathImageKIR = photo_kir;
          } else {
            filePathImageSTNK = "";
            filePathImageKIR = "";
          }
        }
      });
    } catch ($e) {}
    return ret;
  }

  Future<String> GetViewImageSIM(String viewName, String drvid) async {
    //update_or_view_photo_vehicle
    var ret = "";
    try {
      var urlData =
          "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp?method=list-photo-sim&drvid=${drvid}";
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        var photo_sim = json.decode(response.body)["photo_sim"];
        if (status_code != null && status_code == 200) {
          if (photo_sim != null && photo_sim != "null" && photo_sim != '') {
            filePathImageSIM = photo_sim;
            print("${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageSIM");
          }
        }
      });
    } catch ($e) {}
    return ret;
  }

  Future<String> GetViewImageUNITS(String viewName, String drvid,String vhcid) async {
    //update_or_view_photo_vehicle
    var ret = "";
    try {
      var urlData =
          "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp?method=list-photo-units&drvid=${drvid}&vhcid=${vhcid}";
      print(urlData);
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        var photo_units = json.decode(response.body)["photo_units"];
        if (status_code != null && status_code == 200) {
          if (photo_units != null && photo_units != "null" && photo_units != '') {
            filePathImageUNITS = photo_units;
            print("${BASE_URL}photo_trucking/PHOTO_UNITS/$filePathImageUNITS");
          }
        }
      });
    } catch ($e) {}
    return ret;
  }

  Future<String> GetViewImageKELUARGA(String viewName, String drvid) async {
    //update_or_view_photo_vehicle
    var ret = "";
    try {
      var urlData =
          "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp?method=list-photo-keluarga&drvid=${drvid}";
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        var photo_keluarga = json.decode(response.body)["photo_keluarga"];
        if (status_code != null && status_code == 200) {
          if (photo_keluarga != null && photo_keluarga != "null" && photo_keluarga != '') {
            filePathImageFAMILY = photo_keluarga;
            print("${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageFAMILY");
          }
        }
      });
    } catch ($e) {}
    return ret;
  }

  Future<String> GetViewImageDOMISLI(String viewName, String drvid) async {
    //update_or_view_photo_vehicle
    var ret = "";
    try {
      var urlData =
          "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp?method=list-photo-domisili&drvid=${drvid}";
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        var photo_domisili = json.decode(response.body)["photo_domisili"];
        if (status_code != null && status_code == 200) {
          if (photo_domisili != null && photo_domisili != "null" && photo_domisili != '') {
            filePathImageDOMISILY = photo_domisili;
            print("${BASE_URL}photo_trucking/PHOTO_DRIVER/$filePathImageDOMISILY");
          }
        }
      });
    } catch ($e) {}
    return ret;
  }

  void SaveOrUpdate() async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userid = prefs.getString("name") ?? '';
      if (vhcid == null || vhcid == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Vehicle tidak boleh kosong",
            "error");
      } else if (userid == null || userid == "") {
        alert(globalScaffoldKey.currentContext!, 0, "User ID tidak boleh kosong",
            "error");
      } else if (view_name != "STNK" && view_name != "KIR") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo STNK/KIR tidak boleh kosong", "error");
      } else if (view_name == "STNK" &&
          (filePathImageSTNK == null || filePathImageSTNK == "")) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo STNK tidak boleh kosong", "error");
      } else if (view_name == "KIR" &&
          (filePathImageKIR == null || filePathImageKIR == "")) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo KIR tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-or-update-photo',
          'vhcid': vhcid,
          'view_name': view_name,
          'userid': userid,
          //'str_photo': "",
          'str_photo':
          view_name == "STNK" ? filePathImageSTNK : filePathImageKIR
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
            var dataRes = json.decode(response.body);
            if (dataRes.length > 0) {
              status_code = dataRes["status_code"];
              message = dataRes["message"];
              print(response);
              if (status_code == 200) {
                alert(globalScaffoldKey.currentContext!, 1, message, "success");
              } else {
                alert(globalScaffoldKey.currentContext!, 0,
                    "Gagal update ${message}", "error");
              }
            } else {
              alert(globalScaffoldKey.currentContext!, 0, "Gagal update photo",
                  "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal update ${response.statusCode}", "error");
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

  void SaveOrUpdateSIM() async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userid = prefs.getString("name") ?? '';
      print("view_name ${view_name}");
      if (drvid == null || drvid == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (userid == null || userid == "") {
        alert(globalScaffoldKey.currentContext!, 0, "User ID tidak boleh kosong",
            "error");
      } else if (view_name != "SIM" && view_name != "FAMILY") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo tidak boleh kosong", "error");
      } else if ((filePathImageSIM == "" || filePathImageSIM == null) && view_name=="SIM") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo SIM tidak boleh kosong", "error");
      } else if (view_name == "FAMILY" &&
          (filePathImageFAMILY == null || filePathImageFAMILY == "")) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo Keluarga tidak boleh kosong", "error");
      }else {

        var encoded = Uri.encodeFull(
            "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-or-update-photo-sim',
          'drvid': drvid,
          'view_name': view_name== "SIM" ? "SIM":"FAMILY",
          'userid': userid,
          //'str_photo': "",
          'str_photo': view_name== "SIM" ? filePathImageSIM:filePathImageFAMILY
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
            var dataRes = json.decode(response.body);
            if (dataRes.length > 0) {
              status_code = dataRes["status_code"];
              message = dataRes["message"];
              print(response);
              if (status_code == 200) {
                alert(globalScaffoldKey.currentContext!, 1, message, "success");
              } else {
                alert(globalScaffoldKey.currentContext!, 0,
                    "Gagal update ${message}", "error");
              }
            } else {
              alert(globalScaffoldKey.currentContext!, 0, "Gagal update photo sim",
                  "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal update ${response.statusCode}", "error");
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

  void SaveOrUpdateUNIT() async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userid = prefs.getString("name") ?? '';
      var vehicle_id = prefs.getString("vehicle_id") ?? '';
      print("view_name ${view_name}");
      if (drvid == null || drvid == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (vehicle_id == null || vehicle_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VHCID tidak boleh kosong", "error");
      } else if (userid == null || userid == "") {
        alert(globalScaffoldKey.currentContext!, 0, "User ID tidak boleh kosong",
            "error");
      } else if (view_name != "STATUS_UNIT") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo tidak boleh kosong", "error");
      } else {
        var encoded = Uri.encodeFull(
            "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-or-update-photo-units',
          'drvid': drvid,
          'vehicle_id': vehicle_id,
          'view_name': "UNIT",
          'userid': userid,
          //'str_photo': "",
          'str_photo': filePathImageUNITS
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
            var dataRes = json.decode(response.body);
            if (dataRes.length > 0) {
              status_code = dataRes["status_code"];
              message = dataRes["message"];
              print(response);
              if (status_code == 200) {
                alert(globalScaffoldKey.currentContext!, 1, message, "success");
              } else {
                alert(globalScaffoldKey.currentContext!, 0,
                    "Gagal update ${message}", "error");
              }
            } else {
              alert(globalScaffoldKey.currentContext!, 0, "Gagal update photo unit",
                  "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal update ${response.statusCode}", "error");
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

  void SaveOrUpdateDOMISILI() async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userid = prefs.getString("name") ?? '';
      print("view_name ${view_name}");
      if (drvid == null || drvid == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (userid == null || userid == "") {
        alert(globalScaffoldKey.currentContext!, 0, "User ID tidak boleh kosong",
            "error");
      } else if (view_name != "DOMISILI") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Photo tidak boleh kosong", "error");
      } else {
        var encoded = Uri.encodeFull(
            "${GlobalData.baseUrl}api/vehicle/update_or_view_photo_vehicle.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-or-update-photo-domisili',
          'drvid': drvid,
          'view_name': "DOMISILI",
          'userid': userid,
          //'str_photo': "",
          'str_photo': filePathImageDOMISILY
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
            var dataRes = json.decode(response.body);
            if (dataRes.length > 0) {
              status_code = dataRes["status_code"];
              message = dataRes["message"];
              print(response);
              if (status_code == 200) {
                alert(globalScaffoldKey.currentContext!, 1, message, "success");
              } else {
                alert(globalScaffoldKey.currentContext!, 0,
                    "Gagal update ${message}", "error");
              }
            } else {
              alert(globalScaffoldKey.currentContext!, 0, "Gagal update photo sim",
                  "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal update ${response.statusCode}", "error");
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

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    print("getImageFromCamera called with: $namaPhoto");

    // Cek apakah sudah ada gambar sebelumnya
    bool hasExistingImage = false;
    if (namaPhoto == "STNK" && (_imageSTNK != null || filePathImageSTNK != "")) hasExistingImage = true;
    if (namaPhoto == "KIR" && (_imageKIR != null || filePathImageKIR != "")) hasExistingImage = true;
    if (namaPhoto == "SIM" && (_imageSIM != null || filePathImageSIM != "")) hasExistingImage = true;
    if (namaPhoto == "FAMILY" && (_imageFAMILY != null || filePathImageFAMILY != "")) hasExistingImage = true;
    if (namaPhoto == "DOMISILI" && (_imageDOMISILY != null || filePathImageDOMISILY != "")) hasExistingImage = true;
    if (namaPhoto == "STATUS_UNIT" && (_imageUNITS != null || filePathImageUNITS != "")) hasExistingImage = true;

    showDialog(
      context: contexs,
      builder: (contexs) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFE65100).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasExistingImage ? Icons.edit : Icons.camera_alt_outlined,
                color: Color(0xFFE65100),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              hasExistingImage ? 'Ganti Foto' : 'Tambah Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        content: Text(
          hasExistingImage
              ? "Pilih sumber untuk mengganti foto ${namaPhoto}"
              : "Pilih sumber untuk mengambil foto ${namaPhoto}",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
            height: 1.5,
          ),
        ),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF718096),
              size: 18,
            ),
            label: Text(
              "Gallery",
              style: TextStyle(
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () async {
              print("Gallery selected");
              Navigator.of(contexs).pop();
               getPicture(namaPhoto, 'GALLERY');
            },
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              "Camera",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              print("Camera selected");
              Navigator.of(contexs).pop();
               getPicture(namaPhoto, 'CAMERA');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE65100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void getPicture(String namaPhoto, opsi) async {
    print('getPicture called with: $namaPhoto, $opsi');

    try {
      final pickedFile = await picker.pickImage(
          source: opsi == 'GALLERY' ? ImageSource.gallery : ImageSource.camera,
          imageQuality: 50
      );

      if (pickedFile != null) {
        print('Image picked successfully: ${pickedFile.path}');

        if (namaPhoto == "STNK") {
          setState(() {
            _imageSTNK = File(pickedFile.path);
            List<int> imageBytes = _imageSTNK!.readAsBytesSync();
            var kb = _imageSTNK!.readAsBytesSync().lengthInBytes / 1024;
            var mb = kb / 1024;
            print("MB " + mb.toString());
            print("KB " + kb.toString());
            filePathImageSTNK = base64Encode(imageBytes);
            is_edit_image_stnk = true;
            print("STNK image updated");
          });
        } else if (namaPhoto == "KIR") {
          setState(() {
            _imageKIR = File(pickedFile.path);
            List<int> imageBytes = _imageKIR!.readAsBytesSync();
            filePathImageKIR = base64Encode(imageBytes);
            is_edit_image_kir = true;
            print("KIR image updated");
          });
        } else if (namaPhoto == "SIM") {
          setState(() {
            _imageSIM = File(pickedFile.path);
            List<int> imageBytes = _imageSIM!.readAsBytesSync();
            filePathImageSIM = base64Encode(imageBytes);
            is_edit_image_sim = true;
            print("SIM image updated");
          });
        } else if (namaPhoto == "FAMILY") {
          setState(() {
            _imageFAMILY = File(pickedFile.path);
            List<int> imageBytes = _imageFAMILY!.readAsBytesSync();
            filePathImageFAMILY = base64Encode(imageBytes);
            is_edit_image_family = true;
            print("FAMILY image updated");
          });
        } else if (namaPhoto == "DOMISILI") {
          setState(() {
            _imageDOMISILY = File(pickedFile.path);
            List<int> imageBytes = _imageDOMISILY!.readAsBytesSync();
            filePathImageDOMISILY = base64Encode(imageBytes);
            is_edit_image_domisily = true;
            print("DOMISILI image updated");
          });
        } else if (namaPhoto == "STATUS_UNIT") {
          setState(() {
            _imageUNITS = File(pickedFile.path);
            List<int> imageBytes = _imageUNITS!.readAsBytesSync();
            filePathImageUNITS = base64Encode(imageBytes);
            is_edit_image_status_unit = true;
            print("STATUS_UNIT image updated");
          });
        } else {
          print("Unknown photo type: $namaPhoto");
          // Jangan reset gambar yang sudah ada jika photo type tidak dikenali
        }
      } else {
        print('No image selected - keeping existing image');
        // Jangan reset gambar yang sudah ada jika user cancel
        // Gambar yang sudah ada tetap dipertahankan
      }
    } catch (e) {
      print('Error picking image: $e');
      // Jangan reset gambar yang sudah ada jika terjadi error
      // Tampilkan pesan error saja
      ScaffoldMessenger.of(globalScaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  String vhcid_units = '';
  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      view_name = prefs.getString("view_name") ?? '';
      vhcid = prefs.getString("vhcid") ?? '';
      drvid = prefs.getString("drvid") ?? '';
      vhcid_units = prefs.getString("vehicle_id") ?? '';
      print('view_name ${view_name}');
      if (view_name == "SIM") {
        GetViewImageSIM(view_name, drvid);
      }else if (view_name == "FAMILY") {
        GetViewImageKELUARGA(view_name, drvid);
      }else if (view_name == "DOMISILI") {
        GetViewImageDOMISLI(view_name, drvid);
      }else if (view_name == "STATUS_UNIT") {
        GetViewImageUNITS(view_name, drvid,vhcid_units);
      } else {
        GetViewImage(view_name);
      }
    });
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

// Widget Full Screen Image Viewer
class FullScreenImageViewer extends StatefulWidget {
  final File? imageFile;
  final String? networkImageUrl;
  final String title;

  FullScreenImageViewer({
    Key? key,
    this.imageFile,
    this.networkImageUrl,
    this.title = "Image",
  }) : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              color: Colors.white,
            ),
            onPressed: _isDownloading ? null : () async {
              setState(() {
                _isDownloading = true;
              });

              try {
                String fileName = '${widget.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';

                if (widget.imageFile != null) {
                  // Download dari file
                  await _downloadFileImage(widget.imageFile!, fileName);
                } else if (widget.networkImageUrl != null) {
                  // Download dari network
                  await _downloadNetworkImage(widget.networkImageUrl!, fileName);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              setState(() {
                _isDownloading = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image viewer
          Center(
              child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: widget.imageFile != null
                  ? Image.file(
                widget.imageFile!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              )
                  : widget.networkImageUrl != null
                  ? Image.network(
                widget.networkImageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              )
                  : _buildErrorWidget(),
            ),
          ),

          // Download progress indicator
          if (_isDownloading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Downloading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.white, size: 50),
          SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadNetworkImage(String imageUrl, String fileName) async {
    try {
      // Request permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission denied untuk menyimpan gambar"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Download image
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
      // Save to gallery using image_gallery_saver_plus
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.bodyBytes),
        name: fileName,
        quality: 80,
      );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gambar berhasil disimpan ke galeri"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan gambar ke galeri"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal download gambar"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadFileImage(File imageFile, String fileName) async {
    try {
      // Request permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permission denied untuk menyimpan gambar"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Read file as bytes
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Save to gallery using image_gallery_saver_plus
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name: fileName,
        quality: 80,
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gambar berhasil disimpan ke galeri"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan gambar ke galeri"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}