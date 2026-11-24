import 'dart:async';
import 'package:dms_anp/src/pages/inventory/ListWareHouseOpName.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Theme/app_theme.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dms_anp/src/Helper/scanner_helper.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;

import '../../flusbar.dart';

class FrmWareHouseOpName extends StatefulWidget {
  @override
  _FrmWareHouseOpNameState createState() => _FrmWareHouseOpNameState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class _FrmWareHouseOpNameState extends State<FrmWareHouseOpName> {
  // Design Tokens - Material Design 3 & ANP Theme (design_form.md)
  static const Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  static const Color lightOrange = Color(0xFFFFF4E6);   // Very light orange
  static const Color accentOrange = Color(0xFFFFB347);  // Peach orange
  static const Color darkOrange = Color(0xFFE07B39);    // Darker orange
  static const Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  static const Color cardColor = Color(0xFFFFF8F0);     // Light cream
  static const Color shadowColor = Color(0x20FF8C69);   // Soft orange shadow
  static const Color borderColor = Color(0x59FFB347);   // accentOrange 35%
  static const Color borderOrange = Color(0x59FFB347);

  InputDecoration softDecoration({String? label, required bool readOnly}) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
  String BASE_URL =
      GlobalData.baseUrl; //"http://apps.tuluatas.com:8085/cemindo";
  FocusNode myFocusNode = FocusNode();
  TextEditingController txtIDWareHouse = new TextEditingController();
  TextEditingController txtItemID = new TextEditingController();
  TextEditingController txtSearchPartname = new TextEditingController();
  TextEditingController txtType = new TextEditingController();
  TextEditingController txtTypeAccessories = new TextEditingController();
  TextEditingController txtMerk = new TextEditingController();
  TextEditingController txtItemSize = new TextEditingController();
  TextEditingController txtQuantityOnHands = new TextEditingController();
  TextEditingController txtPartName = new TextEditingController();
  TextEditingController txtQuantityOnActual = new TextEditingController();
  TextEditingController txtVHTID = new TextEditingController();
  TextEditingController txtGenuinoNumber = new TextEditingController();
  var isScan = false;
  var witwarehouseid = "";

  TextEditingController txtTypePO = new TextEditingController();
  TextEditingController txtItemCost = new TextEditingController();
  TextEditingController txtCurrencyTypeID = new TextEditingController();
  String selWareHouseID = "";
  String selCuryID = "";
  String selTypePO = "";
  String withMonth = "";
  List<Map<String, dynamic>> lstWareHouseID = [];
  List<Map<String, dynamic>> lstItemID = [];
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  int status_code = 0;
  String message = "";
  int _ocrCamera = 0; // Camera back (0 = back, 1 = front)
  String _text = "TEXT";

  String userid = "";
  String scanResult = '';

  bool isNumeric(String? s) {
    if (s == null || s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void reseTeks(bool is_save_or_update) {
    setState(() {
      txtItemID.text = "";
      witwarehouseid = "";
      txtType.text = "";
      txtTypeAccessories.text = "";
      txtMerk.text = "";
      txtVHTID.text = "";
      txtGenuinoNumber.text = "";
      txtItemSize.text = "";
      txtQuantityOnHands.text = "";
      txtQuantityOnActual.text = "";
      txtPartName.text = "";
      txtItemCost.text = "0";
      txtTypePO.text = "";
      txtCurrencyTypeID.text = "";
      if (is_save_or_update == false) {
        selWareHouseID = "";
        selCuryID = "";
        selTypePO = "";
        withMonth = "";
      }
      selTypePO = "STOCK";
      txtTypePO.text = "STOCK";
      selCuryID = "IDR";
      txtCurrencyTypeID.text = "IDR";
      globals.wh_itdlinenbr = "";
      globals.wh_method = "";
      globals.wh_id = "";
      globals.wh_itemid = "";
      globals.wh_type = "";
      globals.wh_accessories = "";
      globals.wh_quantity_on_hands = "";
      globals.wh_quantity_on_actuals = "";
      globals.wh_typepo = "";
      globals.wh_itemcost = "";
      globals.wh_currency_id = "";
      globals.wh_month = "";
      globals.wh_month_year = "";
      globals.wh_month_month = "";
      globals.wh_vhtid = ""; 
      globals.wh_merk = "";
    });
  }

  Future<String> getListWHId() async {
    String status = "";
    var urlData =
        "${BASE_URL}api/inventory/list_warehouseid.jsp?method=list-wh-v1";

    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstWareHouseID = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        //print("lstVheicleType");
        //print(lstVheicleType);
      }
    });
    return status;
  }

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("IDR"), value: "IDR-RUPIAH"),
      DropdownMenuItem(child: Text("USD"), value: "USD-US DOLLAR")
    ];
    return menuItems;
  }

  Future<String> getItemID(String value) async {
    String status = "";
    var urlData =
        "${BASE_URL}api/inventory/list_warehouse_item_id.jsp?method=list-item-wh-v2&item_id=" +
            value +
            "&search_part=";
    print(urlData);
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstItemID = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        if (lstItemID.length > 0) {
          print(lstItemID[0]['item_id']);
          setState(() {
            print('lstItemID[0][type]');
            print(lstItemID[0]['type']);
            txtTypeAccessories.text = lstItemID[0]['accessories'];
            txtMerk.text = lstItemID[0]['merk'];
            txtVHTID.text = lstItemID[0]['vhtid'];
            txtGenuinoNumber.text = lstItemID[0]['genuino_number'];
            txtItemSize.text = lstItemID[0]['item_size'];
            txtTypePO.text = lstItemID[0]['typepo'];
            //txtType.text = lstItemID[0]['idtype'];
            txtType.text = lstItemID[0]['type'];
            txtCurrencyTypeID.text = lstItemID[0]['curyid'];
            txtQuantityOnHands.text = lstItemID[0]['qty_on_hand'];
            txtPartName.text = lstItemID[0]['part_name'];
            selCuryID = lstItemID[0]['curyid'];
            witwarehouseid = lstItemID[0]['witwarehouseid'];
            txtIDWareHouse.text = lstItemID[0]['witwarehouseid'];
            selWareHouseID = lstItemID[0]['witwarehouseid'];
            ///txtQuantityOnHands.text = lstItemID[0]['quantity'];
            print(lstItemID[0]['quantity']);
          });
        }
        //print("lstVheicleType");
        //print(lstVheicleType);
      }
    });
    return status;
  }

  Future<String> getItemIDByPartName(String value, String whid) async {
    String status = "";
    try {
      EasyLoading.show();
      setState(() {
        dataListNewItem = [];
      });
      var urlData =
          "${BASE_URL}api/inventory/list_warehouse_item_id.jsp?method=list-item-wh-v2&witwarehouseid=" +
              whid +
              "&search_part=" +
              value +
              "&item_id=";

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        var data = json.decode(response.body);
        if (data != null && data.length > 0) {
          dataListNewItem = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          print(dataListNewItem);
        } else {
          dataListNewItem = [];
        }
      });
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return status;
  }

  Future<void> searchItemByPartName(BuildContext dialogContext) async {
    final searchText = txtSearchPartname.text.trim();
    if (searchText.isEmpty || selWareHouseID.isEmpty) {
      alert(scafoldGlobal.currentContext!, 2,
          "Warehouse dan partname tidak boleh kosong", "error");
      return;
    }

    await getItemIDByPartName(searchText, selWareHouseID);
    if (!mounted) {
      return;
    }

    Navigator.of(dialogContext).pop(false);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('List Item'),
            content: setupAlertDialoadContainerList(context),//
          );
        });
  }

  String _resolveWhId() {
    if (selWareHouseID.trim().isNotEmpty) return selWareHouseID.trim();
    if (txtIDWareHouse.text.trim().isNotEmpty) return txtIDWareHouse.text.trim();
    if (witwarehouseid.toString().trim().isNotEmpty) {
      return witwarehouseid.toString().trim();
    }
    final g = (globals.wh_id ?? '').toString().trim();
    return g;
  }

  void CreateStockOpname(String usr) async {
    try {
      var wh_id = _resolveWhId();
      var wh_itemid = txtItemID.text;
      var wh_partname = txtPartName.text;
      var wh_type = txtType.text;
      var username = usr;
      var wh_accessories = txtTypeAccessories.text;
      var wh_merk = txtMerk.text;
      var wh_vhtid = txtVHTID.text;
      var wh_genuin_number = txtGenuinoNumber.text;
      var wh_item_size = txtItemSize.text.toString() ?? "-";
      //var wh_qty_on_hands = txtQuantityOnHands.text;
      var wh_qty_on_hands =
          txtQuantityOnHands.text == null || txtQuantityOnHands.text == ""
              ? "0"
              : txtQuantityOnHands.text;
      var wh_qty_on_actual =
          txtQuantityOnActual.text == null || txtQuantityOnActual.text == ""
              ? "0"
              : txtQuantityOnActual.text;
      var wh_typepo = "STOCK"; //txtTypePO.text;
      var wh_itemcost = "0"; // txtItemCost.text;
      var wh_currency_id = "IDR";//txtCurrencyTypeID.text;

      if (wh_id == null || wh_id == "") {
        alert(scafoldGlobal.currentContext!!, 0, "WH ID tidak boleh kosong",
            "error");
      } else if (wh_itemid == null || wh_itemid == "") {
        alert(scafoldGlobal.currentContext!!, 0, "ItemID tidak boleh kosong",
            "error");
      } else if (wh_type == null || wh_type == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Type tidak boleh kosong",
            "error");
      } else if (wh_accessories == null || wh_accessories == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Accessories tidak boleh kosong",
            "error");
      } else if (wh_merk == null || wh_merk == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Merk tidak boleh kosong",
            "error");
      } else if (wh_vhtid == null || wh_vhtid == "") {
        alert(scafoldGlobal.currentContext!!, 0, "VHTID tidak boleh kosong",
            "error");
      } else if (wh_genuin_number == null || wh_genuin_number == "") {
        alert(scafoldGlobal.currentContext!!, 0,
            "Genuine Number tidak boleh kosong", "error");
      } else if (wh_item_size == null || wh_item_size == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Item Size tidak boleh kosong",
            "error");
      } else if (wh_qty_on_hands == null || wh_qty_on_hands == "") {
        alert(scafoldGlobal.currentContext!!, 0, "QTY On Books tidak boleh kosong",
            "error");
      } else if (wh_qty_on_actual == null || wh_qty_on_actual == "") {
        alert(scafoldGlobal.currentContext!!, 0,
            "QTY On Actual tidak boleh kosong", "error");
      } else if (txtPartName.text == null || txtPartName.text == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Part Name tidak boleh kosong",
            "error");
      } else if (wh_typepo == null || wh_typepo == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Type PO tidak boleh kosong",
            "error");
      } else if (wh_itemcost == null || wh_itemcost == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Item Cost tidak boleh kosong",
            "error");
      } else if (wh_currency_id == null || wh_currency_id == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Currency ID tidak boleh kosong",
            "error");
      } else {
        EasyLoading.show();
        var encoded =
            Uri.encodeFull("${BASE_URL}api/inventory/create_stock_opname.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-wh-v2',
          'wh_id': wh_id,
          'wh_itemid': wh_itemid,
          'wh_partname': wh_partname,
          'wh_type': wh_type,
          'wh_accessories': wh_accessories,
          'wh_merk': wh_merk,
          'wh_item_size': wh_item_size,
          'wh_quantity_on_hands': wh_qty_on_hands,
          'wh_quantity_on_actuals': wh_qty_on_actual,
          'wh_typepo': wh_typepo,
          'wh_itemcost': wh_itemcost,
          'wh_currency_id': wh_currency_id,
          'wh_vhtid': wh_vhtid,
          'wh_merk': wh_merk,
          'wh_genuine_no': wh_genuin_number,
          'username': usr,
          'witwarehouseid': witwarehouseid.toString().trim().isNotEmpty
              ? witwarehouseid.toString().trim()
              : wh_id
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
            //print(response.body);
            if (status_code == 200) {
              showDialog(
                context: scafoldGlobal.currentContext!,
                builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("$message"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
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
                        reseTeks(true);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else {
              //Navigator.of(context, rootNavigator: true).pop();
              alert(scafoldGlobal.currentContext!!, 0,
                  message.toString(), "error");
            }
          } else {
            alert(scafoldGlobal.currentContext!!, 0,
                "Gagal menyimpan ${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      if (e.toString().contains("Duplicate key")) {
        alert(scafoldGlobal.currentContext!!, 0, "Data sudah pernah di simpan",
            "error");
      } else {
        alert(scafoldGlobal.currentContext!!, 0, "Client, Gagal Menyimpan Data",
            "error");
      }

      print(e.toString());
    }
  }

  void UpdateStockOpname(String usr) async {
    try {
      var wh_id = _resolveWhId();
      var wh_itemid = txtItemID.text;
      var wh_partname = txtPartName.text;
      var wh_type = txtType.text;
      var username = usr;
      var wh_accessories = txtTypeAccessories.text;
      var wh_merk = txtMerk.text;
      var wh_item_size = txtItemSize.text;
      var wh_qty_on_hands =
          txtQuantityOnHands.text == null || txtQuantityOnHands.text == ""
              ? "0"
              : txtQuantityOnHands.text;
      var wh_qty_on_actual =
          txtQuantityOnActual.text == null || txtQuantityOnActual.text == ""
              ? "0"
              : txtQuantityOnActual.text;
      var wh_typepo = txtTypePO.text;
      var wh_vhtid = txtVHTID.text;
      var wh_genuin_number = txtGenuinoNumber.text;
      var wh_itemcost = "0"; // txtItemCost.text;
      var wh_currency_id = txtCurrencyTypeID.text;//

      if (wh_id == null || wh_id == "") {
        alert(scafoldGlobal.currentContext!!, 0, "WH ID tidak boleh kosong",
            "error");
      } else if (wh_itemid == null || wh_itemid == "") {
        alert(scafoldGlobal.currentContext!!, 0, "ItemID tidak boleh kosong",
            "error");
      } else if (wh_type == null || wh_type == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Type tidak boleh kosong",
            "error");
      } else if (wh_vhtid == null || wh_vhtid == "") {
        alert(scafoldGlobal.currentContext!!, 0, "VHTID tidak boleh kosong",
            "error");
      }else if (wh_merk == null || wh_merk == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Merk tidak boleh kosong",
            "error");
      } else if (wh_genuin_number == null || wh_genuin_number == "") {
        alert(scafoldGlobal.currentContext!!, 0,
            "Genuine Number tidak boleh kosong", "error");
      } else if (wh_accessories == null || wh_accessories == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Accessories tidak boleh kosong",
            "error");
      } else if (wh_merk == null || wh_merk == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Merk tidak boleh kosong",
            "error");
      } else if (wh_item_size == null || wh_item_size == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Item Size tidak boleh kosong",
            "error");
      } else if (wh_qty_on_hands == null || wh_qty_on_hands == "") {
        alert(scafoldGlobal.currentContext!!, 0, "QTY On Books tidak boleh kosong",
            "error");
      } else if (wh_qty_on_actual == null || wh_qty_on_actual == "") {
        alert(scafoldGlobal.currentContext!!, 0,
            "QTY On Actual tidak boleh kosong", "error");
      } else if (wh_partname == null || wh_partname == "") {
        alert(scafoldGlobal.currentContext!!, 0, "PartName tidak boleh kosong",
            "error");
      } else if (wh_typepo == null || wh_typepo == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Type PO tidak boleh kosong",
            "error");
      } else if (wh_itemcost == null || wh_itemcost == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Item Cost tidak boleh kosong",
            "error");
      } else if (wh_currency_id == null || wh_currency_id == "") {
        alert(scafoldGlobal.currentContext!!, 0, "Currency ID tidak boleh kosong",
            "error");
      } else {
        EasyLoading.show();
        var encoded =
            Uri.encodeFull("${BASE_URL}api/inventory/create_stock_opname.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          //'method': 'update-warehouse-v2',
          'method': 'update-wh-v2',
          'wh_id': wh_id,
          'wh_itemid': wh_itemid,
          'wh_partname': wh_partname,
          'wh_type': wh_type,
          'wh_accessories': wh_accessories,
          'wh_quantity_on_hands': wh_qty_on_hands,
          'wh_quantity_on_actuals': wh_qty_on_actual,
          'wh_typepo': wh_typepo,
          'wh_itemcost': wh_itemcost,
          'wh_currency_id': wh_currency_id,
          'wh_vhtid': wh_vhtid,
          'wh_merk': wh_merk,
          'wh_item_size': wh_item_size,
          'wh_genuine_no': wh_genuin_number,
          'month': globals.wh_month_month,
          'year': globals.wh_month_year,
          'username': usr,
          'witwarehouseid': witwarehouseid.toString().trim().isNotEmpty
              ? witwarehouseid.toString().trim()
              : wh_id,
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
            //print(response.body);
            if (status_code == 200) {
              showDialog(
                context: scafoldGlobal.currentContext!,
                builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("$message"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        //reseTeks();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else {
              //Navigator.of(context).pop(false);
              alert(scafoldGlobal.currentContext!!, 0,
                  "Gagal update ${message}", "error");
            }
          } else {
            alert(scafoldGlobal.currentContext!!, 0,
                "Gagal update ${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(scafoldGlobal.currentContext!!, 0, "Client, Gagal Menyimpan Data",//
          "error");
      print(e.toString());
    }
  }

  Future scanQRCode() async {
    if (!mounted) return;
    
    final String? scanResult = await openQrScanner(context);
    
    if (scanResult == null || scanResult.isEmpty) {
      if (mounted) {
        alert(scafoldGlobal.currentContext!!, 0, "Scan Item ID gagal!", "error");
      }
      return;
    }
    
    setState(() {
      this.scanResult = scanResult;
      txtItemID.text = scanResult;
    });
    
    // Jika scan berhasil, ambil data item
    if (scanResult.isNotEmpty) {
      var url = "${BASE_URL}api/inventory/list_item_barcode_mobile.jsp"
          "?method=list-items-v1"
          "&warehouseid=${selWareHouseID}"
          "&search=$scanResult"
          "&is_barcode=1";
      print(url);
      getItemBarcode(url, scanResult);
    }
  }

  void getItemBarcode(String url, String itemid) async {
    //print("getItemBarcode ${getItemBarcode}");
    var urlData = url;
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    http.Response response = await http.get(myUri);
    print(response.body.toString());
    setState(() {
      if (response.statusCode == 200) {
        List result = json.decode(response.body);
        print(result.length);
        if (result != null && result.length > 0) {
          lstItemID = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          if (lstItemID.length > 0) {
            print(lstItemID[0]['item_id']);//
            setState(() {
              final row = lstItemID[0];
              txtTypeAccessories.text = (row['accessories'] ?? '').toString();
              txtItemID.text = (row['item_id'] ?? '').toString();
              txtMerk.text = (row['merk'] ?? '').toString();
              txtPartName.text = (row['part_name'] ?? '').toString();
              txtItemSize.text = (row['item_size'] ?? '').toString();
              txtTypePO.text = (row['typepo'] ?? '').toString();
              txtType.text = (row['type'] ?? '').toString();
              txtCurrencyTypeID.text = (row['curyid'] ?? '').toString();
              selCuryID = (row['curyid'] ?? '').toString();
              txtQuantityOnHands.text = (row['quantity'] ?? '0').toString();
              txtQuantityOnActual.text = '0';
              txtVHTID.text = (row['vhtid'] ?? '').toString();
              txtGenuinoNumber.text = (row['genuine_no'] ?? '').toString();
              witwarehouseid = selWareHouseID;
            });
          }
        } else {
          alert(scafoldGlobal.currentContext!!, 2,
              "Data inventory tidak ditemukan", "warning");
        }
      } else {
        alert(scafoldGlobal.currentContext!!, 0,
            "Error,Response server ${response.statusCode}", "error");
      }
    });
  }

  @override
  void initState() {
    print('FORM Warehuse');
    print(globals.wh_method);
    setState(() {
      if (globals.wh_method == "edit") {
        final whId = (globals.wh_id ?? '').toString();
        txtIDWareHouse.text = whId;
        selWareHouseID = whId;
        witwarehouseid = whId;
        txtItemID.text = globals.wh_itemid!;
        txtPartName.text = globals.wh_part_name!;
        txtType.text = globals.wh_type!;
        txtVHTID.text = globals.wh_vhtid ?? '';
        txtTypeAccessories.text = globals.wh_accessories ?? '';
        txtMerk.text = globals.wh_merk ?? '';
        txtItemSize.text = globals.wh_item_size!;
        txtGenuinoNumber.text = globals.wh_genuine_no ?? '';
        txtQuantityOnHands.text = globals.wh_quantity_on_hands!;
        txtQuantityOnActual.text = globals.wh_quantity_on_actuals!;
        txtTypePO.text = globals.wh_typepo!;
        //globals.inv_itdinvtrannbr;
        txtItemCost.text = "0"; //globals.wh_itemcost;
        txtCurrencyTypeID.text = globals.wh_currency_id!;
        selCuryID = globals.wh_currency_id!;
        txtCurrencyTypeID.text = globals.wh_currency_id!;
        selTypePO = globals.wh_typepo!;
        txtTypePO.text = globals.wh_typepo!;
      }
    });
    getListWHId();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _goBack(BuildContext context) {
    reseTeks(false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  ProgressDialog? pr;
  @override
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack(context);
        }
      },
      child: Scaffold(
        key: scafoldGlobal,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 20.0,
            onPressed: () => _goBack(context),
          ),
          title: Text(
            globals.wh_method == "edit" ? 'Edit WH. Opname' : 'Form WH. Opname',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset Form',
              onPressed: () => reseTeks(false),
            ),
          ],
        ),
        body: _getContent(context),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildWHID(BuildContext context) {
    if (globals.wh_method != "edit") {
      final hasValue = selWareHouseID.isNotEmpty;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'WH ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('*',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            SmartSelect<String?>.single(
              title: 'Pilih Warehouse',
              selectedValue: selWareHouseID,
              placeholder: 'Pilih Gudang / Warehouse...',
              onChange: (selected) {
                setState(() {
                  selWareHouseID = selected.value ?? '';
                  txtIDWareHouse.text = selected.value ?? '';
                  witwarehouseid = selected.value ?? '';
                });
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                source: lstWareHouseID,
                value: (index, item) => item['whswarehouseid'],
                title: (index, item) =>
                    "${item['whswarehouseid']} - ${item['whsdescr']}",
              ),
              modalFilter: true,
              modalFilterAuto: true,
              modalType: S2ModalType.bottomSheet,
              modalConfig: const S2ModalConfig(
                style: S2ModalStyle(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
              ),
              tileBuilder: (context, state) {
                return InkWell(
                  onTap: () => state.showModal(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warehouse_outlined,
                            color: primaryOrange, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasValue
                                ? selWareHouseID
                                : 'Pilih Gudang / Warehouse...',
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
    return _buildTextField(
      controller: txtIDWareHouse,
      label: 'WH ID',
      icon: Icons.warehouse_outlined,
      readOnly: true,
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderOrange.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: lightOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primaryOrange, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
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
    bool readOnly = false,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    String? hintText,
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
            readOnly: readOnly,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              color: readOnly ? Colors.grey.shade700 : Colors.black87,
              fontWeight: readOnly ? FontWeight.w500 : FontWeight.normal,
            ),
            cursorColor: primaryOrange,
            onChanged: onChanged,
            decoration: softDecoration(
              label: label,
              readOnly: readOnly,
            ).copyWith(
              prefixIcon: Icon(icon, color: primaryOrange, size: 20),
              suffixIcon: suffix,
              hintText: hintText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemIdField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Item ID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 4),
              const Text('*',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: txtItemID,
            readOnly: globals.wh_method == "edit",
            style: TextStyle(
              fontSize: 14,
              color: globals.wh_method == "edit"
                  ? Colors.grey.shade700
                  : Colors.black87,
            ),
            cursorColor: primaryOrange,
            keyboardType: TextInputType.text,
            onChanged: (value) async {
              if (globals.wh_method != 'edit') {
                if (value.isNotEmpty && value.length > 5) {
                  if (isScan == true) {
                    await getItemID(value);
                  }
                }
              }
            },
            decoration: softDecoration(
              label: 'Item ID',
              readOnly: globals.wh_method == "edit",
            ).copyWith(
              prefixIcon: const Icon(Icons.qr_code_2_rounded,
                  color: primaryOrange, size: 20),
              suffixIcon: globals.wh_method == "edit"
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: primaryOrange,
                          size: 22,
                        ),
                        tooltip: 'Scan atau Cari Item',
                        onPressed: () => _showItemSearchChoiceModal(context),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemSearchChoiceModal(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (choiceCtx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: lightOrange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryOrange,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: primaryOrange,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pilih Metode Input Item',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan QR Code item atau cari berdasarkan nama item.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                    label: const Text(
                      'Scan QRCode',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      Navigator.of(choiceCtx).pop();
                      setState(() {
                        isScan = true;
                      });
                      scanQRCode();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search, color: Colors.white, size: 18),
                    label: const Text(
                      'Search By Name',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      Navigator.of(choiceCtx).pop();
                      setState(() {
                        isScan = false;
                      });
                      await Future.delayed(const Duration(milliseconds: 120));
                      if (!mounted) return;
                      showDialog(
                        context: parentContext,
                        builder: (dialogCtx) {
                          return Dialog(
                            insetPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: lightOrange,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryOrange,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: primaryOrange,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          'Search Item',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: darkOrange,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () => Navigator.of(dialogCtx).pop(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  setupAlertDialoadContainer(dialogCtx),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(choiceCtx).pop(),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockDifferenceBadge() {
    final booksQty = double.tryParse(txtQuantityOnHands.text.trim()) ?? 0.0;
    final actualQty = double.tryParse(txtQuantityOnActual.text.trim());

    if (actualQty == null) {
      return const SizedBox.shrink();
    }

    final diff = actualQty - booksQty;
    final isMatch = diff == 0;
    final isOver = diff > 0;

    final Color badgeBg = isMatch
        ? const Color(0xFFE8F5E9)
        : (isOver ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE));
    final Color badgeBorder = isMatch
        ? const Color(0xFF81C784)
        : (isOver ? const Color(0xFFFFB74D) : const Color(0xFFE57373));
    final Color badgeText = isMatch
        ? const Color(0xFF2E7D32)
        : (isOver ? const Color(0xFFE65100) : const Color(0xFFC62828));
    final IconData icon = isMatch
        ? Icons.check_circle_outline_rounded
        : (isOver
            ? Icons.arrow_circle_up_rounded
            : Icons.arrow_circle_down_rounded);

    final diffStr = isMatch
        ? 'Sesuai dengan sistem (0)'
        : (isOver
            ? 'Selisih Lebih: +${diff % 1 == 0 ? diff.toInt() : diff}'
            : 'Selisih Kurang: ${diff % 1 == 0 ? diff.toInt() : diff}');

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeText, size: 18),
          const SizedBox(width: 8),
          Text(
            diffStr,
            style: TextStyle(
              color: badgeText,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isEdit = globals.wh_method == "edit";
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset Button
          OutlinedButton.icon(
            onPressed: () => reseTeks(false),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Save / Update Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleSaveOrUpdate(context),
              icon: Icon(isEdit ? Icons.update_rounded : Icons.save_rounded,
                  size: 18, color: Colors.white),
              label: Text(
                isEdit ? 'Update Opname' : 'Simpan Opname',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Detail / List Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ListWareHouseOpName()),
              );
            },
            icon: const Icon(Icons.list_alt_rounded,
                size: 18, color: Colors.white),
            label: const Text(
              'Detail',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveOrUpdate(BuildContext context) async {
    final isEdit = globals.wh_method == "edit";
    final actualText = txtQuantityOnActual.text.trim();
    if (actualText.isEmpty) {
      alert(context, 2, "Quantity Actual tidak boleh kosong", "error");
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isEdit ? Icons.update_rounded : Icons.save_rounded,
              color: primaryOrange,
            ),
            const SizedBox(width: 8),
            Text(
              isEdit ? 'Update Opname' : 'Simpan Opname',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isEdit
              ? "Apakah Anda yakin ingin memperbarui data Stock Opname ini?"
              : "Apakah Anda yakin ingin menyimpan data Stock Opname ini?",
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("name") ?? "";

    if (isEdit) {
      UpdateStockOpname(username);
    } else {
      if (txtItemID.text.trim().isEmpty) {
        alert(context, 2, "Pilih Item ID terlebih dahulu", "error");
        return;
      }
      CreateStockOpname(username);
    }
  }

  List<Map<String, dynamic>> dataListNewItem = [];
  String _itemStr(dynamic v) {
    if (v == null) return '-';
    final t = v.toString().trim();
    if (t.isEmpty || t == 'null') return '-';
    return t;
  }

  Widget buildBtnAddNewItem(BuildContext context, dynamic item) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(Icons.check, color: Colors.white, size: 16.0),
        label: Text(
          "Pilih",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          Navigator.pop(context);
          print(item['item_id']);
          Timer(Duration(seconds: 1), () {
            setState(() {
              txtItemID.text = item['item_id'];
              txtPartName.text = item['part_name'];
              txtTypeAccessories.text = item['idaccess'];
              txtMerk.text = item['merk'];
              txtItemSize.text = item['item_size'];
              txtTypePO.text = item['typepo'];
              selTypePO = item['typepo'];
              txtType.text = item['idtype'];
              txtCurrencyTypeID.text = item['curyid'];
              selCuryID = item['curyid'];
              txtQuantityOnHands.text = item['qty_on_hand'];
              txtQuantityOnActual.text = '0';
              selCuryID = item['curyid'];
              print("selCuryID ${selCuryID}");
              witwarehouseid = item['witwarehouseid'];
              txtIDWareHouse.text = item['witwarehouseid'];
              selWareHouseID = item['witwarehouseid'];
              txtVHTID.text = item['vhtid'];
              txtGenuinoNumber.text = item['genuine_no'];
              print('Piilih ${selWareHouseID}');
              print('selTypePO ${selTypePO}');
            });
          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDListNewItems(BuildContext context, dynamic item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryOrange.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18FF8A50),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: Color(0xFFFFF4E6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Text(
              "WH ID : ${_itemStr(item['witwarehouseid'])}",
              style: TextStyle(
                color: Color(0xFFE07B39),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(88),
                1: FixedColumnWidth(14),
                2: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: [
                _kvRow("Item ID", _itemStr(item['item_id'])),
                _kvRow("Genuine No", _itemStr(item['genuine_no'])),
                _kvRow("Accesoris", _itemStr(item['idaccess'])),
                _kvRow("Part Name", _itemStr(item['part_name'])),
                _kvRow("Merk", _itemStr(item['merk'])),
                _kvRow("Item Size", _itemStr(item['item_size'])),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Row(children: <Widget>[buildBtnAddNewItem(context, item)]),
          ),
        ],
      ),
    );
  }

  TableRow _kvRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: Text(
          label,
          style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: Text(
          ":",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ]);
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 2),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(88),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        children: [
          _kvRow(label, value.isEmpty ? '-' : value),
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainer(BuildContext dialogContext) {
    final screenW = MediaQuery.of(dialogContext).size.width;
    return SizedBox(
      width: screenW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryOrange.withOpacity(0.55), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Color(0x18FF8A50),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              readOnly: globals.wh_method == "edit",
              cursorColor: primaryOrange,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              controller: txtSearchPartname,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchItemByPartName(dialogContext),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ketik part name / item ID...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                labelText: 'Search',
                labelStyle: TextStyle(
                  color: primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icon(Icons.search, color: primaryOrange, size: 22),
                suffixIcon: Material(
                  color: primaryOrange,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                    onTap: () async {
                      print('witwarehouseid ' + selWareHouseID);
                      await searchItemByPartName(dialogContext);
                    },
                    child: SizedBox(
                      width: 48,
                      child: Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryOrange, width: 1.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Masukkan minimal beberapa huruf lalu tap panah / Enter.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainerList(BuildContext ctx) {
    return SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.65,
      width: MediaQuery.of(ctx).size.width * 0.9,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(2.0),
          itemCount: dataListNewItem == null ? 0 : dataListNewItem.length,
          itemBuilder: (ctx, int index) {
            return _buildDListNewItems(ctx, dataListNewItem[index], index);
          }),
    );
  }

  Widget _getContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Informasi Gudang & Item',
            icon: Icons.warehouse_rounded,
            children: [
              _buildWHID(context),
              _buildItemIdField(context),
              _buildTextField(
                controller: txtPartName,
                label: 'Part Name',
                icon: Icons.label_outline_rounded,
                readOnly: globals.wh_method == "edit",
              ),
              _buildTextField(
                controller: txtType,
                label: 'Type',
                icon: Icons.category_outlined,
                readOnly: globals.wh_method == "edit",
              ),
              _buildTextField(
                controller: txtVHTID,
                label: 'VHTID',
                icon: Icons.tag_rounded,
                readOnly: globals.wh_method == "edit",
              ),
              _buildTextField(
                controller: txtGenuinoNumber,
                label: 'Genuine No',
                icon: Icons.verified_outlined,
                readOnly: globals.wh_method == "edit",
              ),
              _buildTextField(
                controller: txtTypeAccessories,
                label: 'Type Accessories',
                icon: Icons.extension_outlined,
                readOnly: globals.wh_method == "edit",
              ),
              _buildTextField(
                controller: txtMerk,
                label: 'Merk / Brand',
                icon: Icons.branding_watermark_outlined,
                readOnly: globals.wh_method == "edit",
              ),
              _buildTextField(
                controller: txtItemSize,
                label: 'Item Size',
                icon: Icons.straighten_rounded,
                keyboardType: TextInputType.number,
                readOnly: globals.wh_method == "edit",
              ),
            ],
          ),
          _buildCard(
            title: 'Perhitungan Stok Opname',
            icon: Icons.calculate_outlined,
            children: [
              _buildTextField(
                controller: txtQuantityOnHands,
                label: 'Quantity On Books (Sistem)',
                icon: Icons.auto_stories_outlined,
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: txtQuantityOnActual,
                label: 'Quantity Actual (Fisik)',
                icon: Icons.edit_note_rounded,
                focusNode: myFocusNode,
                keyboardType: TextInputType.number,
                isRequired: true,
                onChanged: (val) {
                  setState(() {});
                },
              ),
              _buildStockDifferenceBadge(),
            ],
          ),
        ],
      ),
    );
  }
}



class ItemInventoryModel {
  String item_id;
  String quantity;
  String cost;
  String uom_id;
  String merk;
  String type;
  String accessories;
  String part_name;
  String genuine_no;
  String ware_house;
  String itemdesc;
  String item_id2;

  ItemInventoryModel(
      {required this.item_id,
        required this.quantity,
        required this.cost,
        required this.uom_id,
        required this.merk,
        required this.type,
        required this.accessories,
        required this.part_name,
        required this.genuine_no,
        required this.ware_house,
        required this.itemdesc,
        required this.item_id2});
  factory ItemInventoryModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    return ItemInventoryModel(
      item_id: parsedJson['item_id'] as String,
      quantity: parsedJson['quantity'] as String,
      cost: parsedJson['cost'] as String,
      uom_id: parsedJson['uom_id'] as String,
      merk: parsedJson['merk'] as String,
      type: parsedJson['type'] as String,
      accessories: parsedJson['accessories'] as String,
      part_name: parsedJson['part_name'] as String,
      genuine_no: parsedJson['genuine_no'] as String,
      ware_house: parsedJson['ware_house'] as String,
      itemdesc: parsedJson['itemdesc'] as String,
      item_id2: parsedJson['item_id2'] as String,
    );
  }
}
