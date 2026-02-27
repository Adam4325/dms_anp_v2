import 'dart:async';
import 'dart:io';
import 'package:dms_anp/src/pages/FrmInspeksiVehicle.dart';
import 'package:dms_anp/src/pages/ViewService.dart';
import 'package:dms_anp/src/pages/driver/FormStoring.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Theme/app_theme.dart';
import 'package:dms_anp/src/pages/ViewAntrian.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewListDo.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'dart:convert';

import '../../flusbar.dart';

class FrmStoring extends StatefulWidget {
  @override
  _FrmStoringState createState() => _FrmStoringState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

const Color _softOrange = Color(0xFFFFAB76);
const Color _softOrangeDark = Color(0xFFE8955A);

class _FrmStoringState extends State<FrmStoring> {
  static const TextStyle _btnTextWhite = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  TextEditingController txtNopol = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtKMOld = new TextEditingController();
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  String status_code = "";
  String message = "";
  final ImagePicker _picker = ImagePicker();
  String loginname = "";
  String drvid = "";
  String locid = "";
  String vhckm = "";
  String dlodetaildonumber = "";
  String vhcid = "";
  String dloorigin = "";
  String dlodestination = "";
  String userid = "";

  bool isNumeric(String s) {
    if (s.isEmpty) return false;
    return double.tryParse(s) != null;
  }

  /// Ambil angka yang paling mirip odometer (deret digit terpanjang, 4–8 digit) dari teks OCR.
  String _extractOdometerKm(String fullText) {
    if (fullText.isEmpty) return '';
    final digitsOnly = fullText.replaceAll(RegExp(r'\D'), ' ');
    final parts = digitsOnly.split(RegExp(r'\s+')).where((s) => s.length >= 4 && s.length <= 8).toList();
    if (parts.isEmpty) {
      final any = RegExp(r'\d{4,8}').firstMatch(fullText);
      return any?.group(0) ?? '';
    }
    parts.sort((a, b) => b.length.compareTo(a.length));
    return parts.first;
  }

  /// Simpan foto ke file sementara (path dari image_picker di Android sering tidak valid untuk ML Kit).
  Future<File?> _pickedImageToTempFile(XFile pickedFile) async {
    try {
      final bytes = await pickedFile.readAsBytes();
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/odometer_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Temp file error: $e');
      return null;
    }
  }

  /// Preprocess gambar (grayscale, contrast, denoise) agar OCR angka odometer lebih akurat.
  Future<File> _preprocessImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return file;
      final gray = img.grayscale(image);
      final contrast = img.contrast(gray, contrast: 175);
      final denoised = img.gaussianBlur(contrast, radius: 1);
      final output = img.encodeJpg(denoised);
      final dir = await getTemporaryDirectory();
      final outFile = File('${dir.path}/odometer_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await outFile.writeAsBytes(output);
      return outFile;
    } catch (e) {
      debugPrint('Preprocess image error: $e');
      return file;
    }
  }

  /// Baca teks dari foto pakai ML Kit.
  Future<String> _recognizeText(File imageFile) async {
    File fileToUse = imageFile;
    try {
      fileToUse = await _preprocessImage(imageFile);
    } catch (_) {}
    final inputImage = InputImage.fromFile(fileToUse);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognized = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognized.text;
  }

  /// Baca KM dari odometer: kamera → foto → OCR (ML Kit) → dialog konfirmasi.
  Future<void> _read() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (pickedFile == null || !mounted) return;

      EasyLoading.show(status: 'Membaca KM dari foto (OCR)...');

      final imageFile = await _pickedImageToTempFile(pickedFile);
      if (imageFile == null || !imageFile.existsSync()) {
        if (!mounted) return;
        if (EasyLoading.isShow) EasyLoading.dismiss();
        alert(globalScaffoldKey.currentContext!, 0, 'Gagal menyimpan foto. Coba lagi.', 'error');
        _showKmConfirmDialog(txtKM.text);
        return;
      }

      String ocrKm = '';
      String? ocrError;
      try {
        final ocrText = await _recognizeText(imageFile);
        ocrKm = _extractOdometerKm(ocrText);
      } catch (e) {
        ocrError = e.toString();
        debugPrint('OCR error: $e');
      }

      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (ocrError != null && mounted) {
        alert(globalScaffoldKey.currentContext!, 0, 'Gagal baca KM: $ocrError. Silakan input manual.', 'error');
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showKmConfirmDialog(ocrKm.isNotEmpty ? ocrKm : txtKM.text);
        });
      }
    } catch (e) {
      if (mounted) {
        if (EasyLoading.isShow) EasyLoading.dismiss();
        alert(globalScaffoldKey.currentContext!, 0, "Gagal: $e", "error");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showKmConfirmDialog(txtKM.text);
        });
      }
    }
  }

  void _showKmConfirmDialog(String initialKm) {
    if (!mounted) return;
    final ctrl = TextEditingController(text: initialKm);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('KM dari Odometer (OCR)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto odometer telah diproses. Periksa nilai KM di bawah atau ubah jika salah baca.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Total KM dari odometer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = ctrl.text.trim();
              if (value.isNotEmpty && isNumeric(value)) {
                setState(() => txtKM.text = value);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _softOrangeDark,
              textStyle: _btnTextWhite,
            ),
            child: Text('OK', style: _btnTextWhite),
          ),
        ],
      ),
    );
  }

  void updateKM(String vhckm, int isBack) async {
    String km = "";
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SEMENTARA
    print('prefs.getString("vhcidfromdo")${prefs.getString("vhcidfromdo")}');
    String imeiid = prefs.getString("androidID")!;
    vhcid = prefs.getString("vhcidfromdo") ?? "";
    //vhcid = 'B 9189 KYW';
    if (vhcid != null && vhcid != "") {
      drvid = prefs.getString("drvid") ?? "";
      prefs.setString("km_new", vhckm);
      prefs.setString("vhcid_last_antrian", vhcid);
      locid = prefs.getString("locid") ?? "";
      String name = prefs.getString("name") ?? "";
      var urlData =
          "${GlobalData.baseUrl}api/update_km_vehicle.jsp?method=update_vhc&imeiid=${imeiid}&vhcid=" +
              vhcid +
              "&vhckm=" +
              vhckm +
              "&userid=" +
              name +
              "&driverid=" +
              drvid +
              "&locid=" +
              locid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          //SHOW ALERT SUCCESS
          //prefs.remove("bujnumber");
          if (isBack == 0) {
            Timer(Duration(seconds: 1), () {
              // 5s over, navigate to a new page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ViewAntrian()));
            });
          }
          //END ALERT SUCCESS
        } else {
          //alert(context, 0, message.toString(), "error");
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Information'),
              content: Text("$message"),
              actions: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(Icons.check, color: Colors.white, size: 20),
                  label: Text("Ok", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  var dataListVehicle = [];
  void getVehiceldriverBuj() async {
    //get_list_vehicle_driver_buj
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var driver_id = prefs.getString("drvid");
    var bujnumber = prefs.getString("bujnumber");
    print(bujnumber);
    var urlData =
        "${GlobalData.baseUrl}api/get_list_vehicle_driver_buj.jsp?method=list-vehicle&drvid=${driver_id}&bujnumber=${bujnumber}";
    print(urlData);
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});
    setState(() {
      dataListVehicle = json.decode(response.body);
      print(dataListVehicle);
    });
  }

  void updateKMStandby(
      String bujnumber, BuildContext context, String vhckm, int isBack) async {
    String km = "";
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SEMENTARA
    String imeiid = prefs.getString("androidID")!;
    print('prefs.getString("vhcidfromdo")${prefs.getString("vhcidfromdo")}');
    var _vhcid =
        (vhcid == null || vhcid == '') ? (prefs.getString("vhcidfromdo") ?? "") : vhcid;
    //vhcid = 'B 9189 KYW';
    if (_vhcid != null && _vhcid != "") {
      drvid = prefs.getString("drvid") ?? "";
      prefs.setString("km_new", vhckm);
      prefs.setString("vhcid_last_antrian", _vhcid);
      locid = prefs.getString("locid") ?? "";
      String name = prefs.getString("name") ?? "";
      var urlData =
          "${GlobalData.baseUrl}api/update_km_vehicle.jsp?method=update_vhc-standby&imeiid=${imeiid}&vhcid=" +
              _vhcid +
              "&vhckm=" +
              vhckm +
              "&drvid=" +
              drvid +
              "&bujnumber=" +
              bujnumber;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          //prefs.remove("bujnumber");
          // print(status_code);
          // print(message);
          // //SHOW ALERT SUCCESS
          alert(context, 1, message, "Success");
          Timer(Duration(seconds: 2), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          });
        }
      });
    }
  }

  Future<String> getApiKm() async {
    String km = "0";
    SharedPreferences prefs = await SharedPreferences.getInstance(); //SEMENTARA
    String vhcid = prefs.getString("vhcid")!;
    if ((vhcid != null && vhcid != "")) {
      var urlData =
          "${GlobalData.baseUrl}api/get_km_by_vehicle_driver.jsp?method=km_vehicle&vhcid=" +
              vhcid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        // Get the JSON data
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        String _km = "0";
        _km = json.decode(response.body)["km"];
        if (status_code != null && status_code == "200") {
          km = _km;
        } else {
          km = "0";
        }
      });
    } else {
      alert(context, 2, "Please contact your Administrator!", "warning");
    }
    return km;
  }

  Future getLoginName() async {
    //SEMENTARA

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove("bujnumber");
    await getApiKm().then((String result) {
      setState(() {
        txtKMOld.text = result == null || result == "0" ? "0" : result;
      });
    });
    setState(() {
      loginname = prefs.getString("name")!;
      locid = prefs.getString("locid")!;
      //vhcid = prefs.getString("vhcidfromdo");
      vhcid = prefs.getString("vhcid")!;
      print(vhcid);
      //vhcid = 'B 9565 YM';
    });
  }

  @override
  void initState() {
    super.initState();
    getLoginName();
    if (EasyLoading.isShow) EasyLoading.dismiss();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _goBack(BuildContext context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {
    var vehicleNopol = vhcid == null || vhcid == "" ? "[No Nopol]" : vhcid;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        backgroundColor: HexColor("#f0eff4"),
        appBar: AppBar(
          backgroundColor: _softOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 22.0,
            onPressed: () => _goBack(context),
          ),
          centerTitle: true,
          title: Text(
            'Form Storing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Container(
          key: scafoldGlobal,
          constraints: BoxConstraints.expand(),
          color: HexColor("#f0eff4"),
          child: Stack(
            children: <Widget>[
              ImgHeader1(context),
              ImgHeader2(context),
              BuildHeader(context),
              _getContent(context),
            ],
          ),
        ),
      ),
    );
  }

  //String vhcid="";

  Widget _getVehicleList(BuildContext context) {
    txtNopol.text = vhcid;
    return TextField(
      readOnly: true,
      controller: txtNopol,
      decoration: InputDecoration(
        fillColor: Color(0xFFF5F5F5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    const double cardPadding = 20.0;
    const InputDecoration _inputDecoration = InputDecoration(
      fillColor: Color(0xFFF5F5F5),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: ListView(
        children: <Widget>[
          Card(
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "Nopol",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  _getVehicleList(context),
                  SizedBox(height: 16),
                  Text(
                    "Kilometer Awal",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    readOnly: true,
                    controller: txtKMOld,
                    style: TextStyle(color: Colors.grey.shade800),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Kilometer Akhir",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: txtKM,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.document_scanner, color: Colors.white, size: 18),
                        label: Text("Baca KM (OCR)", style: _btnTextWhite),
                        onPressed: _read,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _softOrangeDark,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          textStyle: _btnTextWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.home_repair_service_sharp, color: Colors.white, size: 20),
                      label: Text("Service", style: _btnTextWhite),
                      onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String vhcidNew = vhcid;
                            String km_awal = txtKMOld.value.text.toString();
                            String km_new = txtKM.value.text.toString();

                            prefs.setString("km_new_storing", txtKM.text.toString());

                            print("${vhcidNew}");
                            print("${km_awal}");
                            print("${km_awal}");
                            if (km_new == null || km_new == "") {
                              alert(context, 2, "KM tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_new) <= 0) {
                              alert(context, 2, "KM Akhir tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_awal) >=
                                int.parse(km_new)) {
                              print(
                                  "${int.parse(km_awal)}-${int.parse(km_new)}");
                              alert(context, 2, "KM Akhir harus > dari KM Awal",
                                  "warning");
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Information'),
                                  content: Text(
                                      "Lanjutkan proses ke Maintenance Service?"),
                                  actions: <Widget>[
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.close, color: Colors.white, size: 18),
                                      label: Text("No", style: _btnTextWhite),
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.grey.shade700,
                                        foregroundColor: Colors.white,
                                        textStyle: _btnTextWhite,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.navigate_next, color: Colors.white, size: 18),
                                      label: Text("Ya", style: _btnTextWhite),
                                      onPressed: () async {
                                        globals.page_inspeksi = '';
                                        globals.p2hVhckm = 0;
                                        prefs.setString("name_event", "service");
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FormStoring()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: _softOrangeDark,
                                        foregroundColor: Colors.white,
                                        textStyle: _btnTextWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _softOrangeDark,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        foregroundColor: Colors.white,
                        textStyle: _btnTextWhite,
                      ),
                    ),
                  )],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //DISABLE
  // Widget _getContentNewDriver(BuildContext context) {
  //   return Container(
  //     margin: EdgeInsets.fromLTRB(0, 270.0, 0, 0),
  //     padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
  //     child: ListView(
  //       children: <Widget>[
  //         Container(
  //           child: Card(
  //             elevation: 14.0,
  //             shadowColor: Color(0x802196F3),
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15.0)),
  //             clipBehavior: Clip.antiAlias,
  //             child: Column(
  //               children: <Widget>[
  //                 ListTile(title: Text("Create Antrian New Driver")),
  //                 Container(
  //                     margin: EdgeInsets.only(
  //                         left: 20, top: 5, right: 20, bottom: 5),
  //                     child: Row(children: <Widget>[
  //                       Expanded(
  //                           child: ElevatedButton.icon(
  //                         icon: Icon(
  //                           Icons.save,
  //                           color: Colors.white,
  //                           size: 15.0,
  //                         ),
  //                         label: Text("Create Antrian"),
  //                         onPressed: () async {
  //                           SharedPreferences prefs = await SharedPreferences
  //                               .getInstance(); //SEMENTARA
  //                           showDialog(
  //                             context: context,
  //                             builder: (context) => new AlertDialog(
  //                               title: new Text('Information'),
  //                               content: new Text("Buat Antrian?"),
  //                               actions: <Widget>[
  //                                 new ElevatedButton.icon(
  //                                   icon: Icon(
  //                                     Icons.close,
  //                                     color: Colors.white,
  //                                     size: 20.0,
  //                                   ),
  //                                   label: Text("No"),
  //                                   onPressed: () {
  //                                     Navigator.of(context).pop(false);
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                       elevation: 0.0,
  //                                       backgroundColor: Colors.blue,
  //                                       padding: EdgeInsets.symmetric(
  //                                           horizontal: 10, vertical: 0),
  //                                       textStyle: TextStyle(
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold)),
  //                                 ),
  //                                 new ElevatedButton.icon(
  //                                   icon: Icon(
  //                                     Icons.navigate_next,
  //                                     color: Colors.white,
  //                                     size: 20.0,
  //                                   ),
  //                                   label: Text("Ok"),
  //                                   onPressed: () {
  //                                     userid = prefs.getString("name");
  //                                     Navigator.pushReplacement(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 FrmCreateAntrianNewDriver()));
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                       elevation: 0.0,
  //                                       backgroundColor: Colors.blue,
  //                                       padding: EdgeInsets.symmetric(
  //                                           horizontal: 10, vertical: 0),
  //                                       textStyle: TextStyle(
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold)),
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                             elevation: 0.0,
  //                             backgroundColor: Colors.blue,
  //                             padding: EdgeInsets.symmetric(
  //                                 horizontal: 5, vertical: 0),
  //                             textStyle: TextStyle(
  //                                 fontSize: 10, fontWeight: FontWeight.bold)),
  //                       )),
  //                     ]))
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget LoadListMenu(BuildContext context) {
    return Expanded(
      child: Container(
        //padding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
        child: GridView.count(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 3,
          //childAspectRatio: .90,
          children: <Widget>[
            Container(
              height: 10,
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 5.0,
                //shadowColor: Color(0x802196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => ViewListDo())),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Material(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.pageview,
                                  color: Colors.white, size: 34.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        //AutoSizeText('Dashboard')
                        Text('List DO OPENED',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0)),
                        //Text('Dashboard',
                        //    style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Card(
                elevation: 5.0,
                //shadowColor: Color(0x802196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  // onTap: () => Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => DoPage())),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Material(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.work,
                                  color: Colors.white, size: 34.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        Text('Profile',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0)),
                        //Text('Dashboard',
                        //    style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Card(
                elevation: 5.0,
                //shadowColor: Color(0x802196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  onTap: () {
                    print("LOGOUT");
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Material(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 34.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        Text('Log Out',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0)),
                        //Text('Dashboard',
                        //    style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ImgHeader1(BuildContext context) {
    return Container(
      child: new Image.asset(
        "assets/img/truck_header.jpg",
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: new BoxConstraints.expand(height: 295.0),
    );
  }

  Widget ImgHeader2(BuildContext context) {
    return Container(
      margin: new EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          //colors: <Color>[new Color(0x00736AB7), new Color(0xFF736AB7)],
          colors: <Color>[new Color(0x00736AB7), HexColor("#f0eff4")],
          stops: [0.0, 0.9],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  Widget BuildHeader(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
        title: Text(
          'Driver Management System',
          style: TextStyle(
              color: AppTheme.nearlyWhite,
              fontWeight: FontWeight.w500,
              fontSize: 16.0),
        ),
        trailing: Icon(Icons.account_circle,
            size: 35,
            color: AppTheme
                .nearlyBlack) //CircleAvatar(backgroundColor: AppTheme.white),
        );
  }
}
