import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_select/awesome_select.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/choices.dart' as choices;
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/hrd/listAsset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrmAsset extends StatefulWidget {
  const FrmAsset({Key? key}) : super(key: key);

  @override
  _FrmAssetState createState() => _FrmAssetState();
}

class _FrmAssetState extends State<FrmAsset> {
  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker picker = ImagePicker();

  // Design Tokens - Material Design 3 & ANP Theme
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Controllers
  final TextEditingController txtAssetID = TextEditingController();
  final TextEditingController txtAssetName = TextEditingController();
  final TextEditingController txtAssetType = TextEditingController();
  final TextEditingController txtAssetOrder = TextEditingController();
  final TextEditingController txtDateExpired = TextEditingController();
  final TextEditingController txtAssetCustomer = TextEditingController();
  final TextEditingController txtAssetNoseri = TextEditingController();
  final TextEditingController txtUser = TextEditingController();
  final TextEditingController txtDivisi = TextEditingController();
  final TextEditingController txtService = TextEditingController();
  final TextEditingController txtCustService = TextEditingController();
  final TextEditingController txtAssetNotes = TextEditingController();
  final TextEditingController txtService1 = TextEditingController();
  final TextEditingController txtService2 = TextEditingController();
  final TextEditingController txtService3 = TextEditingController();
  final TextEditingController txtHardisk = TextEditingController();
  final TextEditingController txtMemory = TextEditingController();
  final TextEditingController photo = TextEditingController();

  String status_code = "";
  String message = "";
  String _dateExpire = "";

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

  @override
  void initState() {
    super.initState();
    getSession();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    txtAssetID.dispose();
    txtAssetName.dispose();
    txtAssetType.dispose();
    txtAssetOrder.dispose();
    txtDateExpired.dispose();
    txtAssetCustomer.dispose();
    txtAssetNoseri.dispose();
    txtUser.dispose();
    txtDivisi.dispose();
    txtService.dispose();
    txtCustService.dispose();
    txtAssetNotes.dispose();
    txtService1.dispose();
    txtService2.dispose();
    txtService3.dispose();
    txtHardisk.dispose();
    txtMemory.dispose();
    photo.dispose();
    super.dispose();
  }

  Future<void> resetTeks() async {
    setState(() {
      txtAssetID.clear();
      txtAssetName.clear();
      txtAssetType.clear();
      txtAssetOrder.clear();
      txtDateExpired.clear();
      txtAssetCustomer.clear();
      txtAssetNoseri.clear();
      txtUser.clear();
      txtDivisi.clear();
      txtService.clear();
      txtCustService.clear();
      txtAssetNotes.clear();
      txtService1.clear();
      txtService2.clear();
      txtService3.clear();
      txtHardisk.clear();
      txtMemory.clear();
      photo.clear();
      _seltype = "";
      _seldivisi = "";
      _selstatus = "";
      status_code = "";
      message = "";
      _dateExpire = "";
      _imageAsset = null;
      _imageAssetTD = null;
      buttonEvent = "Save";
      _pathImageAsset = "";
      _pathImageAssetTD = "";
      is_edit_image_asset = false;
      is_edit_image_asset_td = false;
    });
    await removeSesion();
  }

  void _goBack(BuildContext context) async {
    await removeSesion();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewDashboard()),
      );
    }
  }

  Future<void> removeSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_edit_asset", false);
    await prefs.remove("is_edit_asset");
    await prefs.remove("asset_assetid");
    await prefs.remove("asset_asset_name");
    await prefs.remove("asset_asset_type");
    await prefs.remove("asset_asset_order");
    await prefs.remove("asset_asset_customer");
    await prefs.remove("asset_no_seri");
    await prefs.remove("asset_asset_user");
    await prefs.remove("asset_divisi");
    await prefs.remove("asset_service");
    await prefs.remove("asset_asset_customer_service");
    await prefs.remove("asset_status");
    await prefs.remove("asset_notes");
    await prefs.remove("asset_service1");
    await prefs.remove("asset_service2");
    await prefs.remove("asset_service3");
    await prefs.remove("asset_hardisk");
    await prefs.remove("asset_memory");
    await prefs.remove("asset_type");
    await prefs.remove("expired_date");
    await prefs.remove("asset_expired_date");
  }

  Future<void> updateTeks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var assetid = prefs.getString("asset_assetid") ?? "";
      _pathImageAsset = assetid.isNotEmpty ? "$assetid.jpg" : "";
      _pathImageAssetTD = assetid.isNotEmpty ? "TDTM_$assetid.jpg" : "";

      txtAssetID.text = assetid;
      txtAssetName.text = prefs.getString("asset_name") ?? "";
      txtAssetType.text = prefs.getString("asset_type") ?? "";
      txtAssetOrder.text = prefs.getString("asset_order") ?? "";
      txtAssetCustomer.text = prefs.getString("asset_customer") ?? "";
      txtAssetNoseri.text = prefs.getString("asset_no_seri") ?? "";
      txtUser.text = prefs.getString("asset_user") ?? "";
      _seldivisi = prefs.getString("asset_divisi") ?? "";
      txtService.text = prefs.getString("asset_service") ?? "";
      txtCustService.text = prefs.getString("asset_customer_service") ?? "";
      _selstatus = prefs.getString("asset_status") ?? "";
      txtAssetNotes.text = prefs.getString("asset_notes") ?? "";
      txtService1.text = prefs.getString("asset_service1") ?? "";
      txtService2.text = prefs.getString("asset_service2") ?? "";
      txtService3.text = prefs.getString("asset_service3") ?? "";
      txtHardisk.text = prefs.getString("asset_hardisk") ?? "";
      txtMemory.text = prefs.getString("asset_memory") ?? "";
      _seltype = prefs.getString("asset_type") ?? "";
      _dateExpire = prefs.getString("asset_expired_date") ?? "";
      txtDateExpired.text = _dateExpire;
    });
  }

  Future<void> getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var is_edit = prefs.getBool("is_edit_asset");
    if (is_edit != null && is_edit == true) {
      await updateTeks();
      if (mounted) {
        setState(() {
          is_edit_image_asset = false;
          buttonEvent = "Update";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          buttonEvent = "Save";
        });
      }
      await removeSesion();
    }
  }

  void getPicture(String namaPhoto, String opsi) async {
    final ImageSource source =
        opsi == 'GALLERY' ? ImageSource.gallery : ImageSource.camera;
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null && mounted) {
      final file = File(pickedFile.path);
      final imageBytes = file.readAsBytesSync();
      final base64Img = base64Encode(imageBytes);

      setState(() {
        if (namaPhoto == 'ASSET') {
          _imageAsset = file;
          _pathImageAsset = base64Img;
          is_edit_image_asset = true;
        } else if (namaPhoto == 'TD') {
          _imageAssetTD = file;
          _pathImageAssetTD = base64Img;
          is_edit_image_asset_td = true;
        }
      });
    }
  }

  Future<void> getImageFromCameraNew(
      BuildContext context, String namaPhoto) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                namaPhoto == 'ASSET'
                    ? 'Pilih Foto Asset'
                    : 'Pilih File Tanda Terima',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: lightOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: primaryOrange),
                ),
                title: const Text('Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ambil foto langsung melalui kamera'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(ctx).pop();
                  getPicture(namaPhoto, 'CAMERA');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: lightOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: primaryOrange),
                ),
                title: const Text('Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih foto dari galeri HP'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(ctx).pop();
                  getPicture(namaPhoto, 'GALLERY');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlert(
      BuildContext? ctx, int type, String message, String colorInfo) {
    if (ctx != null) alert(ctx, type, message, colorInfo);
  }

  void updateAsset() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var asset_id = txtAssetID.text.trim();
      var asset_name = txtAssetName.text.trim();
      var asset_type = _seltype;
      var asset_order = txtAssetOrder.text.trim();
      var asset_customer = txtAssetCustomer.text.trim();
      var no_seri = txtAssetNoseri.text.trim();
      var user = txtUser.text.trim();
      var seldivisi = _seldivisi;
      var service = txtService.text.trim();
      var customer_service = txtCustService.text.trim();
      var asset_status = _selstatus;
      var asset_notes = txtAssetNotes.text.trim();
      var service1 = txtService1.text.trim();
      var service2 = txtService2.text.trim();
      var service3 = txtService3.text.trim();
      var hardisk = txtHardisk.text.trim();
      var memory = txtMemory.text.trim();
      var seltype = _seltype;
      var currentUserId = prefs.getString("name") ?? "";

      if (asset_id.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset ID tidak boleh kosong", "error");
      } else if (asset_name.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset name tidak boleh kosong", "error");
      } else if (asset_type.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset type tidak boleh kosong", "error");
      } else if (asset_order.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset Order tidak boleh kosong", "error");
      } else if (asset_customer.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset customer tidak boleh kosong", "error");
      } else if (no_seri.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "No Seri tidak boleh kosong", "error");
      } else if (user.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "User tidak boleh kosong", "error");
      } else if (seldivisi.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Divisi tidak boleh kosong", "error");
      } else if (asset_status.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Status tidak boleh kosong", "error");
      } else if (asset_notes.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Notes tidak boleh kosong", "error");
      } else {
        EasyLoading.show(status: 'Menyimpan update...');
        var encoded =
            Uri.encodeFull("${GlobalData.baseUrlOri}api/edp/asset.jsp");
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
          'userid': currentUserId,
          'filename': _pathImageAsset,
          'filename_td': _pathImageAssetTD
        };

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

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          var _status_code = decoded["status_code"];
          message = decoded["message"] ?? "Berhasil update";

          if (_status_code == 200) {
            final ctx = globalScaffoldKey.currentContext;
            if (ctx != null) {
              showDialog(
                context: ctx,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Berhasil',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text("$message"),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          } else {
            _showAlert(globalScaffoldKey.currentContext, 0,
                "Gagal menyimpan: $message", "error");
          }
        } else {
          _showAlert(globalScaffoldKey.currentContext, 0,
              "Gagal menyimpan: ${response.statusCode}", "error");
        }
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      _showAlert(globalScaffoldKey.currentContext, 0, "Error: ${e.toString()}",
          "error");
    }
  }

  void saveAsset() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var asset_id = txtAssetID.text.trim();
      var asset_name = txtAssetName.text.trim();
      var asset_type = _seltype;
      var asset_order = txtAssetOrder.text.trim();
      var asset_customer = txtAssetCustomer.text.trim();
      var no_seri = txtAssetNoseri.text.trim();
      var user = txtUser.text.trim();
      var seldivisi = _seldivisi;
      var service = txtService.text.trim();
      var customer_service = txtCustService.text.trim();
      var asset_status = _selstatus;
      var asset_notes = txtAssetNotes.text.trim();
      var service1 = txtService1.text.trim();
      var service2 = txtService2.text.trim();
      var service3 = txtService3.text.trim();
      var hardisk = txtHardisk.text.trim();
      var memory = txtMemory.text.trim();
      var seltype = _seltype;
      var currentUserId = prefs.getString("name") ?? "";

      if (asset_id.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset ID tidak boleh kosong", "error");
      } else if (asset_name.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset name tidak boleh kosong", "error");
      } else if (asset_type.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset type tidak boleh kosong", "error");
      } else if (asset_order.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset Order tidak boleh kosong", "error");
      } else if (asset_customer.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Asset customer tidak boleh kosong", "error");
      } else if (no_seri.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "No Seri tidak boleh kosong", "error");
      } else if (user.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "User tidak boleh kosong", "error");
      } else if (seldivisi.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Divisi tidak boleh kosong", "error");
      } else if (asset_status.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Status tidak boleh kosong", "error");
      } else if (asset_notes.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Notes tidak boleh kosong", "error");
      } else if (_imageAsset == null && _pathImageAsset.isEmpty) {
        _showAlert(globalScaffoldKey.currentContext, 0,
            "Photo Asset tidak boleh kosong", "error");
      } else {
        EasyLoading.show(status: 'Menyimpan asset...');
        var encoded =
            Uri.encodeFull("${GlobalData.baseUrlOri}api/edp/asset.jsp");
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
          'userid': currentUserId,
          'filename': _pathImageAsset
        };

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

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          var _status_code = decoded["status_code"];
          message = decoded["message"] ?? "Berhasil menyimpan";

          if (_status_code == 200) {
            final ctx = globalScaffoldKey.currentContext;
            if (ctx != null) {
              showDialog(
                context: ctx,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Berhasil',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text("$message"),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          } else {
            _showAlert(globalScaffoldKey.currentContext, 0,
                "Gagal menyimpan: $message", "error");
          }
        } else {
          _showAlert(globalScaffoldKey.currentContext, 0,
              "Gagal menyimpan: ${response.statusCode}", "error");
        }
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      _showAlert(globalScaffoldKey.currentContext, 0, "Error: ${e.toString()}",
          "error");
    }
  }

  void _handleSaveOrUpdate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var is_edit = prefs.getBool("is_edit_asset");
    final bool isEdit = is_edit != null && is_edit == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline_rounded, color: primaryOrange),
            SizedBox(width: 8),
            Text('Konfirmasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content:
            Text(isEdit ? "Update data asset ini?" : "Simpan data asset baru?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (isEdit) {
                updateAsset();
              } else {
                saveAsset();
              }
            },
            child: Text(isEdit ? "Update" : "Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 20),
            onPressed: () => _goBack(context),
          ),
          title: Text(
            buttonEvent == "Update" ? 'Form Edit Asset' : 'Form Create Asset',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: darkOrange),
              tooltip: 'Reset Form',
              onPressed: () => resetTeks(),
            ),
          ],
        ),
        body: _getContent(context),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: <Widget>[
          // 1. Informasi Utama Asset
          _buildCard(
            title: "Informasi Utama Asset",
            icon: Icons.inventory_2_outlined,
            children: [
              _buildTextField(
                controller: txtAssetID,
                label: "Asset ID",
                icon: Icons.qr_code_2_rounded,
                isRequired: true,
              ),
              _buildTextField(
                controller: txtAssetName,
                label: "Asset Name",
                icon: Icons.label_outline_rounded,
                isRequired: true,
              ),
              _buildTextField(
                controller: txtAssetType,
                label: "Asset Type",
                icon: Icons.category_outlined,
                isRequired: true,
              ),
              _buildSmartSelect(
                title: "Asset Group Type",
                placeholder: "Pilih Asset Group",
                selectedValue: _seldivisi,
                choicesList: choices.assetSelDivisi,
                icon: Icons.layers_outlined,
                onChanged: (val) => setState(() => _seldivisi = val),
              ),
              _buildSmartSelect(
                title: "Kategori Tipe",
                placeholder: "Pilih Tipe",
                selectedValue: _seltype,
                choicesList: choices.assetSelType,
                icon: Icons.devices_other_outlined,
                isRequired: true,
                onChanged: (val) => setState(() => _seltype = val),
              ),
              _buildSmartSelect(
                title: "Status Asset",
                placeholder: "Pilih Status",
                selectedValue: _selstatus,
                choicesList: choices.assetSelStatus,
                icon: Icons.check_circle_outline_rounded,
                isRequired: true,
                onChanged: (val) => setState(() => _selstatus = val),
              ),
            ],
          ),

          // 2. Kepemilikan & Tanggal
          _buildCard(
            title: "Kepemilikan & Tanggal",
            icon: Icons.badge_outlined,
            children: [
              _buildDatePicker(
                controller: txtAssetOrder,
                label: "Asset Order",
                icon: Icons.event_available_outlined,
                isRequired: true,
                onChanged: (val) {},
              ),
              _buildDatePicker(
                controller: txtDateExpired,
                label: "Expire Date",
                icon: Icons.event_busy_outlined,
                onChanged: (val) => setState(() => _dateExpire = val),
              ),
              _buildTextField(
                controller: txtAssetCustomer,
                label: "Customer",
                icon: Icons.business_outlined,
                isRequired: true,
              ),
              _buildTextField(
                controller: txtAssetNoseri,
                label: "No Seri",
                icon: Icons.pin_outlined,
                isRequired: true,
              ),
              _buildTextField(
                controller: txtUser,
                label: "User Penanggung Jawab",
                icon: Icons.person_outline_rounded,
                isRequired: true,
              ),
              _buildSmartSelect(
                title: "Divisi",
                placeholder: "Pilih Divisi",
                selectedValue: _seldivisi,
                choicesList: choices.assetSelDivisi,
                icon: Icons.corporate_fare_outlined,
                isRequired: true,
                onChanged: (val) => setState(() => _seldivisi = val),
              ),
            ],
          ),

          // 3. Layanan & Pemeliharaan
          _buildCard(
            title: "Layanan & Spesifikasi",
            icon: Icons.build_circle_outlined,
            children: [
              _buildTextField(
                controller: txtService,
                label: "Service",
                icon: Icons.settings_outlined,
              ),
              _buildTextField(
                controller: txtCustService,
                label: "Customer Service",
                icon: Icons.support_agent_outlined,
              ),
              _buildDatePicker(
                controller: txtService1,
                label: "Service 1",
                icon: Icons.event_note_outlined,
                onChanged: (val) {},
              ),
              _buildDatePicker(
                controller: txtService2,
                label: "Service 2",
                icon: Icons.event_note_outlined,
                onChanged: (val) {},
              ),
              _buildDatePicker(
                controller: txtService3,
                label: "Service 3",
                icon: Icons.event_note_outlined,
                onChanged: (val) {},
              ),
              _buildTextField(
                controller: txtHardisk,
                label: "Hardisk",
                icon: Icons.storage_rounded,
                hint: "Contoh: 512GB SSD",
              ),
              _buildTextField(
                controller: txtMemory,
                label: "Memory / RAM",
                icon: Icons.memory_rounded,
                hint: "Contoh: 16GB DDR4",
              ),
              _buildTextField(
                controller: txtAssetNotes,
                label: "Asset Notes",
                icon: Icons.notes_rounded,
                maxLines: 3,
                isRequired: true,
                hint: "Tuliskan catatan kelengkapan atau kondisi aset...",
              ),
            ],
          ),

          // 4. Foto Asset & Dokumen Tanda Terima
          _buildCard(
            title: "Foto Asset & Dokumen",
            icon: Icons.photo_library_outlined,
            children: [
              _buildPhotoUploadCard(
                title: "Foto Asset (Wajib)",
                subtitle: "Ketuk untuk upload foto kondisi fisik aset",
                imageFile: _imageAsset,
                pathImage: _pathImageAsset,
                isEdit: is_edit_image_asset,
                type: "ASSET",
                onTap: () => getImageFromCameraNew(context, "ASSET"),
                onRemove: () {
                  setState(() {
                    _imageAsset = null;
                    _pathImageAsset = "";
                    is_edit_image_asset = false;
                  });
                },
              ),
              const SizedBox(height: 14),
              _buildPhotoUploadCard(
                title: "File Tanda Terima (Opsional)",
                subtitle: "Ketuk untuk upload bukti serah terima / nota",
                imageFile: _imageAssetTD,
                pathImage: _pathImageAssetTD,
                isEdit: is_edit_image_asset_td,
                type: "TD",
                onTap: () => getImageFromCameraNew(context, "TD"),
                onRemove: () {
                  setState(() {
                    _imageAssetTD = null;
                    _pathImageAssetTD = "";
                    is_edit_image_asset_td = false;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: primaryOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkOrange,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text('*',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            cursorColor: primaryOrange,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint ?? 'Masukkan $label...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: primaryOrange, size: 20),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: primaryOrange, width: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSelect({
    required String title,
    required String placeholder,
    required String selectedValue,
    required List<S2Choice<String>> choicesList,
    required ValueChanged<String> onChanged,
    required IconData icon,
    bool isRequired = false,
  }) {
    final hasValue = selectedValue.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text('*',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          SmartSelect<String>.single(
            title: title,
            placeholder: placeholder,
            selectedValue: selectedValue,
            onChange: (state) => onChanged(state.value),
            choiceType: S2ChoiceType.radios,
            choiceItems: choicesList,
            modalType: S2ModalType.bottomSheet,
            modalHeader: true,
            modalConfig: const S2ModalConfig(
              style: S2ModalStyle(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
            tileBuilder: (context, state) {
              return InkWell(
                onTap: () => state.showModal(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: primaryOrange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasValue ? selectedValue : placeholder,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasValue
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: hasValue
                                ? Colors.black87
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text('*',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: DateTimePicker(
              dateMask: 'yyyy-MM-dd',
              controller: controller,
              firstDate: DateTime(1950),
              lastDate: DateTime(2100),
              icon: Icon(icon, color: primaryOrange, size: 20),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Pilih $label...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) => onChanged(val),
              validator: (val) {
                onChanged(val ?? '');
                return null;
              },
              onSaved: (val) => onChanged(val ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadCard({
    required String title,
    required String subtitle,
    required File? imageFile,
    required String pathImage,
    required bool isEdit,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    required String type,
  }) {
    final File? localFile = (isEdit && imageFile != null) ? imageFile : null;
    final bool hasLocalFile = localFile != null;
    final bool hasRemoteUrl = !hasLocalFile && pathImage.isNotEmpty;
    final bool hasImage = hasLocalFile || hasRemoteUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasImage ? Colors.green.shade400 : borderColor,
          width: hasImage ? 1.5 : 1,
        ),
      ),
      child: hasImage
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: onTap,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Ganti',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: localFile != null
                      ? Image.file(
                          localFile,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          type == "ASSET"
                              ? "${GlobalData.baseUrlOri}photo/asset/$pathImage"
                              : "${GlobalData.baseUrlOri}photo/asset/TDTM_$pathImage",
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 120,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined,
                                color: Colors.grey),
                          ),
                        ),
                ),
              ],
            )
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: lightOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: primaryOrange,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () {
                  removeSesion();
                  resetTeks();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: Icon(
                  buttonEvent == "Update"
                      ? Icons.update_rounded
                      : Icons.save_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  buttonEvent == "Update" ? "Update Asset" : "Simpan Asset",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () => _handleSaveOrUpdate(context),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.list_alt_rounded, color: primaryOrange),
              tooltip: 'Daftar Asset',
              style: IconButton.styleFrom(
                backgroundColor: lightOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () async {
                await removeSesion();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ListAsset()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
