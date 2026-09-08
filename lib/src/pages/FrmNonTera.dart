import 'dart:async';
import 'dart:io';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
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
  // Soft Orange Pastel Theme (design_tab.md)
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);
  final Color shadowColor = Color(0x20FF8C69);

  InputDecoration softDecoration({
    String? label,
    String? hint,
    bool readOnly = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  ButtonStyle ntBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  ButtonStyle ntPhotoBtnStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: Size(double.infinity, 200),
    );
  }

  Widget ntBtnLabel(String text, {double size = 13}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }//

  AlertDialog ntAlertDialog({
    required String title,
    required Widget content,
    List<Widget> actions = const <Widget>[],
  }) {//
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: cardColor,
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Text(
        title,
        style: TextStyle(
            color: darkOrange, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      content: content,
      actions: actions,
    );
  }

  String _s(dynamic v) {
    if (v == null) return '';
    final t = v.toString().trim();
    if (t.isEmpty || t == 'null') return '';
    return t;
  }

  Widget _kv(String label, String value, {bool dense = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 0 : 2),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(10),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: dense ? 11 : 12)),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(":",
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: dense ? 11 : 12)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: dense ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _ntBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool expanded = true,
  }) {
    final btn = ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 15),
      label: ntBtnLabel(label),
      onPressed: onPressed,
      style: ntBtnStyle(color),
    );
    return expanded ? Expanded(child: btn) : btn;
  }

  Widget _ntListCard({
    required String title,
    required List<Widget> rows,
    Widget? actions,
    bool compact = false,
  }) {
    final m = compact ? 6.0 : 12.0;
    final v = compact ? 3.0 : 6.0;
    final r = compact ? 10.0 : 14.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: m, vertical: v),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: accentOrange.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
              color: shadowColor,
              blurRadius: compact ? 4 : 8,
              offset: Offset(0, compact ? 1 : 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: compact
                ? EdgeInsets.fromLTRB(10, 6, 10, 6)
                : EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r),
                topRight: Radius.circular(r),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: darkOrange,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 14,
              ),
            ),
          ),
          Padding(
            padding: compact
                ? EdgeInsets.fromLTRB(10, 4, 10, 4)
                : EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: compact
                  ? EdgeInsets.fromLTRB(8, 2, 8, 8)
                  : EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: actions,
            ),
        ],
      ),
    );
  }

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
          backgroundColor: backgroundColor,
          appBar: AppBar(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 2,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(context);
                },
              ),
              centerTitle: true,
              title: Text('Non-Tera',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600))),
          body: SafeArea(
            child: FrmNonTeraSubmit(context),
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
    return _ntListCard(
      compact: true,
      title: "VHCID : ${_s(item['vhcid'])}",
      rows: [
        _kv("Location", _s(item['locid']), dense: true),
        _kv("Stnk", _s(item['dt_stnk']), dense: true),
        _kv("Pajak", _s(item['dt_pajak']), dense: true),
        _kv("Kir", _s(item['dt_kir']), dense: true),
      ],
      actions: Row(
        children: [
          _ntBtn(
            icon: Icons.add_circle_outline,
            label: "Add",
            color: primaryOrange,
            onPressed: () {
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
          ),
        ],
      ),
    );
  }

  Widget _buildDListDetailNonTera(dynamic item, int index) {
    return _ntListCard(
      compact: true,
      title: "VHCID : ${_s(item['vhcid'])}",
      rows: [
        _kv("Request Date", _s(item['date']), dense: true),
        _kv("Tera Type ID", _s(item['typeid']), dense: true),
        _kv("Last Value", _s(item['lastvalue']), dense: true),
        _kv("Next Value", _s(item['nextvalue']), dense: true),
        _kv("Amount", _s(item['amount']), dense: true),
        _kv("Locid", _s(item['locid']), dense: true),
        _kv("Status", _s(item['status']), dense: true),
      ],
      actions: Row(
        children: [
          _ntBtn(
            icon: Icons.close,
            label: "Close",
            color: Colors.redAccent,
            onPressed: () async {
              Navigator.of(context).pop(false);
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => ntAlertDialog(
                  title: 'Information',
                  content: const Text("Close data non-tera?"),
                  actions: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.white, size: 16),
                      label: ntBtnLabel("Submit"),
                      style: ntBtnStyle(primaryOrange),
                      onPressed: () async {
                        Navigator.of(globalScaffoldKey.currentContext!)
                            .pop(false);
                        await Future.delayed(Duration(seconds: 1));
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        var user_id = prefs.getString("name");
                        var nmnbr = item['nmnbr'];
                        var vhcid = item['vhcid'];
                        if (nmnbr == null || nmnbr == "") {
                          alert(context, 2,
                              "Number Non-tera tidak boleh kosong", "warning");
                        } else if (vhcid == null || vhcid == "") {
                          alert(context, 2, "VHCID tidak boleh kosong",
                              "warning");
                        } else {
                          await closeNonTera(user_id!, nmnbr, vhcid);
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      label: ntBtnLabel("Cancel"),
                      style: ntBtnStyle(Colors.grey.shade500),
                      onPressed: () async {
                        Navigator.of(context).pop(false);
                        reset_save();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _ntBtn(
            icon: Icons.remove_red_eye,
            label: "View",
            color: primaryOrange,
            onPressed: () {
              Navigator.of(globalScaffoldKey.currentContext!).pop(false);
              is_view = true;
              setState(() {
                filePathImageFRONT =
                    item['photo_front'] != null ? item['photo_front'] : "";
                filePathImageRIGHT =
                    item['photo_right'] != null ? item['photo_right'] : "";
                filePathImageLEFT =
                    item['photo_left'] != null ? item['photo_left'] : "";
                filePathImageREAR =
                    item['photo_rear'] != null ? item['photo_rear'] : "";
                filePathImageUPLOAD = item['photo_nontera'] != null
                    ? item['photo_nontera']
                    : "";
                filePathImageSTNK =
                    item['photo_stnk'] != null ? item['photo_stnk'] : "";
                filePathImageKIR =
                    item['photo_kir'] != null ? item['photo_kir'] : "";
                filePathImageBAINT =
                    item['photo_baint'] != null ? item['photo_baint'] : "";
                filePathImageBAIEXT =
                    item['photo_baext'] != null ? item['photo_baext'] : "";
                filePathImageCEKFISIK = item['photo_cekfisisk'] != null
                    ? item['photo_cekfisisk']
                    : "";
                filePathImageSURAT2 =
                    item['photo_surat2'] != null ? item['photo_surat2'] : "";
                filePathImageFRONTCOMPLETE =
                    item['photo_surat2'] != null ? item['photo_surat2'] : "";
                txtLastValueDate.text = item['lastvalue'];
                txtLocation.text = item['locid'];
                txtNmDate.text = item['date'];
                txtVHCID.text = item['vhcid'];
                dropdownvalue = item['typeid'];
                nama_type = dropdownvalue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget listDataUnits(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height * 0.7,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: txtSearchVehicle,
                  cursorColor: primaryOrange,
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) async {
                    if (is_view == false && value.trim().isNotEmpty) {
                      await getListDataUnits(true, value);
                    }
                  },
                  decoration: softDecoration(
                    label: "VHCID",
                    hint: "Cari VHCID",
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (is_view == false &&
                      txtSearchVehicle.text.trim().isNotEmpty) {
                    await getListDataUnits(true, txtSearchVehicle.text);
                  }
                },
                style: ntBtnStyle(primaryOrange),
                child: ntBtnLabel("Search"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: dataListUnits.isEmpty
                ? Center(
                    child: Text("Data unit tidak di temukan",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  )
                : ListView.builder(
                    itemCount: dataListUnits.length,
                    itemBuilder: (context, index) {
                      return _buildDListDetailUnits(dataListUnits[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget listDataNonTera(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height * 0.7,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: txtSearchVehicleNontera,
                  cursorColor: primaryOrange,
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) async {
                    if (value.trim().isNotEmpty) {
                      await getListDataNonTera(true, value);
                    }
                  },
                  decoration: softDecoration(
                    label: "VHCID",
                    hint: "Cari VHCID",
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (txtSearchVehicleNontera.text.trim().isNotEmpty) {
                    await getListDataNonTera(true, txtSearchVehicleNontera.text);
                  }
                },
                style: ntBtnStyle(primaryOrange),
                child: ntBtnLabel("Search"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: dataListNonTera.isEmpty
                ? Center(
                    child: Text("Data non-tera tidak di temukan",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  )
                : ListView.builder(
                    itemCount: dataListNonTera.length,
                    itemBuilder: (context, index) {
                      return _buildDListDetailNonTera(
                          dataListNonTera[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    if (!mounted) return;
    
    try {
      await showDialog(
        context: contexs,
        builder: (BuildContext dialogContext) => ntAlertDialog(
          title: 'Information',
          content: const Text("Get Picture"),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined,
                  color: Colors.white, size: 16),
              label: ntBtnLabel("Camera"),
              style: ntBtnStyle(primaryOrange),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await getPicture(namaPhoto, 'CAMERA');
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library,
                  color: Colors.white, size: 16),
              label: ntBtnLabel("Gallery"),
              style: ntBtnStyle(accentOrange),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await getPicture(namaPhoto, 'GALLERY');
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error showing dialog: $e');
    }
  }

  Future<void> getPicture(String namaPhoto, opsi) async {
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
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: ListView(children: <Widget>[
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
                Icon(Icons.assignment_outlined, color: primaryOrange, size: 24),
                SizedBox(width: 12),
                Text('Form Non-Tera',
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButtonHideUnderline(
                              child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton(
                              isExpanded: true,
                              value: dropdownvalue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: primaryOrange),
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
                      margin: EdgeInsets.all(12.0),
                      child: DateTimePicker(
                        //type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'yyyy-MM-dd',
                        controller: txtNmDate,
                        //initialValue: _initialValue,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event, color: primaryOrange),
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
                      margin: EdgeInsets.all(12.0),
                      child: TextField(
                        controller: txtVHCID,
                        readOnly: true,
                        cursorColor: primaryOrange,
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                        decoration: softDecoration(
                            label: 'VHCID',
                            hint: 'VHCID',
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
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ntAlertDialog(
                                            title: 'List Units',
                                            content: listDataUnits(context),
                                            actions: [
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.white,
                                                    size: 16),
                                                label: ntBtnLabel("Close"),
                                                style: ntBtnStyle(accentOrange),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  });
                                }
                              },
                              icon: Icon(Icons.search, color: primaryOrange),
                            ),
                            prefixIcon: Icon(
                              Icons.car_rental,
                              color: primaryOrange,
                            )),
                      ),
                    ),
                    if (is_edit == true) ...[
                      Container(
                        margin: EdgeInsets.all(12.0),
                        child: TextField(
                          readOnly: true,
                          controller: txtLastValue,
                          cursorColor: primaryOrange,
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: softDecoration(
                              hint: 'Last Value',
                              label: 'Last Value',
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: primaryOrange,
                              )),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(12.0),
                        child: TextField(
                          controller: txtNextValue,
                          cursorColor: primaryOrange,
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: softDecoration(
                              hint: 'Location',
                              label: 'Location',
                              prefixIcon: Icon(
                                Icons.book,
                                color: primaryOrange,
                              )),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(12.0),
                        child: TextField(
                          controller: txtLocation2,
                          readOnly: true,
                          cursorColor: primaryOrange,
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: softDecoration(
                              hint: 'Location',
                              label: 'Location',
                              prefixIcon: Icon(
                                Icons.pin_drop,
                                color: primaryOrange,
                              )),
                        ),
                      ),
                    ],
                    if (is_edit == false) ...[
                      Container(
                        margin: EdgeInsets.all(12.0),
                        child: TextField(
                          readOnly: true,
                          controller: txtLastValueDate,
                          cursorColor: primaryOrange,
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: softDecoration(
                              hint: 'Last Value',
                              label: 'Last Value',
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: primaryOrange,
                              )),
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
                        margin: EdgeInsets.all(12.0),
                        child: TextField(
                          controller: txtLocation,
                          readOnly: false,
                          cursorColor: primaryOrange,
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: softDecoration(
                              hint: 'Location',
                              label: 'Location',
                              prefixIcon: Icon(
                                Icons.pin_drop,
                                color: primaryOrange,
                              )),
                        ),
                      ),
                    ],
                    if(nama_type=='STNK' || nama_type=='PAJAK')...[
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: Container(
                          alignment: Alignment.center,
                          child: _imageUPLOAD != null &&  (is_edit == false || is_view==false)
                              ? GestureDetector(
                            onTap: () async {
                              await getImageFromCamera(context, "UPLOAD");
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _imageUPLOAD!,
                                width: double.infinity,
                                height: 200.0,
                                scale: 0.8,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              : _imageUPLOAD == null &&
                              (is_edit == true || is_view==true) &&
                              filePathImageUPLOAD != ""
                              ? GestureDetector(
                            onTap: () async {
                              await getImageFromCamera(context, "UPLOAD");
                            },
                            child: Container(
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
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Photo ${nama_type} to Upload", size: 14),
                              onPressed: () async {
                                await getImageFromCamera(context, "UPLOAD");
                              },
                              style: ntPhotoBtnStyle(),
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        label: ntBtnLabel("Photo front", size: 14),
                                        onPressed: () async {
                                          await getImageFromCamera(context, "FRONT");
                                        },
                                        style: ntPhotoBtnStyle(),
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        label: ntBtnLabel("Photo right", size: 14),
                                        onPressed: () async {
                                          await getImageFromCamera(context, "RIGHT");
                                        },
                                        style: ntPhotoBtnStyle(),
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        label: ntBtnLabel("Photo left", size: 14),
                                        onPressed: () async {
                                          await getImageFromCamera(context, "LEFT");
                                        },
                                        style: ntPhotoBtnStyle(),
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
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]),
                                      width: double.infinity,
                                      height: 200,
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        label: ntBtnLabel("Photo rear", size: 14),
                                        onPressed: () async {
                                          await getImageFromCamera(context, "REAR");
                                        },
                                        style: ntPhotoBtnStyle(),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Photo bagian depan mobil beserta supir", size: 14),
                              onPressed: () async {
                                await getImageFromCamera(context, "FRONT-COMPLETE");
                              },
                              style: ntPhotoBtnStyle(),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Photo cek fisik", size: 14),
                              onPressed: () async {
                                await getImageFromCamera(context, "CEKFISIK");
                              },
                              style: ntPhotoBtnStyle(),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Photo BA Internal cek fisik", size: 14),
                              onPressed: () async {
                                await getImageFromCamera(context, "BAINT");
                              },
                              style: ntPhotoBtnStyle(),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Photo BA External", size: 14),
                              onPressed: () async {
                                await getImageFromCamera(context, "BAEXT");
                              },
                              style: ntPhotoBtnStyle(),
                            ),
                          ),
                        ),
                      ),
                    )],//BA EXTERNAL
                    if(nama_type=='KIR')...[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: _imageSURAT != null && (is_edit == false || is_view==false)
                            ? GestureDetector(
                          onTap: () async {
                            print('KIR !!!');
                            await getImageFromCamera(context, "SURAT2");
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _imageSURAT!,
                              width: double.infinity,
                              height: 200.0,
                              scale: 0.8,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                            : _imageSURAT == null &&
                            (is_edit == true || is_view==true) &&
                            filePathImageSURAT2 != ""
                            ? GestureDetector(
                          onTap: () async {
                            print('KIR !!!');
                            await getImageFromCamera(context, "SURAT2");
                          },
                          child: Container(
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
                          ),
                        )
                              : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            width: double.infinity,
                            height: 200,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Photo Kartu kir beserta Surat / Kertas kir", size: 14),
                              onPressed: () async {
                                print('KIR !!!');
                                await getImageFromCamera(context, "SURAT2");
                              },
                              style: ntPhotoBtnStyle(),
                            ),
                          ),
                      ),
                    )],//SURAT2
                    Container(
                        margin: EdgeInsets.fromLTRB(12, 8, 12, 16),
                        child: Row(children: <Widget>[
                          if (is_view == false) ...[
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Save", size: 14),
                              onPressed: () async {
                                showDialog(
                                  context: globalScaffoldKey.currentContext!,
                                  builder: (context) => ntAlertDialog(
                                    title: 'Information',
                                    content: const Text("Submit non-tera?"),
                                    actions: [
                                      ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16.0,
                                        ),
                                        label: ntBtnLabel("Submit"),
                                        style: ntBtnStyle(primaryOrange),
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
                                      ),
                                      ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16.0,
                                        ),
                                        label: ntBtnLabel("Cancel"),
                                        style: ntBtnStyle(Colors.grey.shade500),
                                        onPressed: () async {
                                          Navigator.of(context).pop(false);
                                          reset_save();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ntBtnStyle(primaryOrange),
                            ))
                          ],
                          if (is_view == true) ...[
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: ntBtnLabel("Reset", size: 14),
                              onPressed: () async {
                                setState(() {
                                  is_view = false;
                                });
                                reset_save();
                                reset_update();
                              },
                              style: ntBtnStyle(Colors.grey.shade500),
                            ))
                          ],
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.list_alt,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: ntBtnLabel("Detail Non-tera", size: 14),
                            onPressed: () async {
                              await getListDataNonTera(false, "");
                              Timer(Duration(seconds: 1), () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ntAlertDialog(
                                        title: 'List Non-tera',
                                        content: listDataNonTera(context),
                                        actions: [
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.close,
                                                color: Colors.white, size: 16),
                                            label: ntBtnLabel("Close"),
                                            style: ntBtnStyle(accentOrange),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              });
                            },
                            style: ntBtnStyle(accentOrange),
                          )),
                        ]),
                      ),
          ]),
        ]),
    );
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
