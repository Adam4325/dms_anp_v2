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
// import 'package:qrscan/qrscan.dart' as scanner; // removed - migrate to mobile_scanner
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
            txtTypeAccessories.text = lstItemID[0]['idaccess'];
            txtMerk.text = lstItemID[0]['merk'];
            txtVHTID.text = lstItemID[0]['vhtid'];
            txtGenuinoNumber.text = lstItemID[0]['genuino_number'];
            txtItemSize.text = lstItemID[0]['item_size'];
            txtTypePO.text = lstItemID[0]['typepo'];
            txtType.text = lstItemID[0]['idtype'];
            txtCurrencyTypeID.text = lstItemID[0]['curyid'];
            txtQuantityOnHands.text = lstItemID[0]['qty_on_hand'];
            txtPartName.text = lstItemID[0]['part_name'];
            selCuryID = lstItemID[0]['curyid'];
            witwarehouseid = lstItemID[0]['witwarehouseid'];
            txtIDWareHouse.text = lstItemID[0]['witwarehouseid'];
            selWareHouseID = lstItemID[0]['witwarehouseid'];
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

  void CreateStockOpname(String usr) async {
    try {
      var wh_id = selWareHouseID;
      var wh_itemid = txtItemID.text;
      var wh_partname = txtPartName.text;
      var wh_type = txtType.text;
      var wharehouseid =
          globals.wh_itdlinenbr != "" ? selWareHouseID : txtIDWareHouse;
      var username = usr;
      var wh_accessories = txtTypeAccessories.text;
      var wh_merk = txtMerk.text;
      var wh_vhtid = txtVHTID.text;
      var wh_genuin_number = txtGenuinoNumber.text;
      var wh_item_size = txtItemSize.text;
      //var wh_qty_on_hands = txtQuantityOnHands.text;
      var wh_qty_on_hands =
          txtQuantityOnHands.text == null || txtQuantityOnHands.text == ""
              ? "0"
              : txtQuantityOnHands.text;
      var wh_qty_on_actual =
          txtQuantityOnActual.text == null || txtQuantityOnActual.text == ""
              ? "0"
              : txtQuantityOnActual.text;
      var wh_typepo = txtTypePO.text;
      var wh_itemcost = "0"; // txtItemCost.text;
      var wh_currency_id = txtCurrencyTypeID.text;

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
        alert(scafoldGlobal.currentContext!!, 0, "QTY On Hand tidak boleh kosong",
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
          'wh_genuine_no': wh_genuin_number,
          'username': usr,
          'witwarehouseid': witwarehouseid
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
      var wh_id = selWareHouseID;
      var wh_itemid = txtItemID.text;
      var wh_partname = txtPartName.text;
      var wh_type = txtType.text;
      var wharehouseid =
          globals.wh_itdlinenbr != "" ? selWareHouseID : txtIDWareHouse;
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
      var wh_itemcost = 0; // txtItemCost.text;
      var wh_currency_id = txtCurrencyTypeID.text;

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
        alert(scafoldGlobal.currentContext!!, 0, "QTY On Hand tidak boleh kosong",
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
          'wh_genuine_no': wh_genuin_number,
          'month': globals.wh_month_month,
          'year': globals.wh_month_year,
          'username': usr,
          'witwarehouseid': witwarehouseid,
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
      alert(scafoldGlobal.currentContext!!, 0, "Client, Gagal Menyimpan Data",
          "error");
      print(e.toString());
    }
  }

  Future scanQRCode() async {
    // TODO: Migrate to mobile_scanner - qrscan package removed
    alert(scafoldGlobal.currentContext!!, 2,
        "Fitur scan QR perlu migrasi ke mobile_scanner", "warning");
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
            print(lstItemID[0]['item_id']);
            setState(() {
              txtTypeAccessories.text = lstItemID[0]['idaccess'];
              txtItemID.text = lstItemID[0]['item_id'];
              txtMerk.text = lstItemID[0]['merk'];
              txtPartName.text = lstItemID[0]['part_name'];
              txtItemSize.text = lstItemID[0]['item_size'];
              txtTypePO.text = lstItemID[0]['typepo'];
              txtType.text = lstItemID[0]['idtype'];
              txtCurrencyTypeID.text = lstItemID[0]['curyid'];
              selCuryID = lstItemID[0]['curyid'];
              txtQuantityOnHands.text = lstItemID[0]['qty_on_hand'];
              txtQuantityOnActual.text = '0';
              txtVHTID.text = lstItemID[0]['vhtid'];
              txtGenuinoNumber.text = lstItemID[0]['genuine_no'];
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
        txtIDWareHouse.text = globals.wh_id!;
        txtItemID.text = globals.wh_itemid!;
        txtPartName.text = globals.wh_part_name!;
        txtType.text = globals.wh_type!;
        txtTypeAccessories.text = globals.wh_accessories!;
        txtMerk.text = globals.wh_merk!;
        txtItemSize.text = globals.wh_item_size!;
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
  Widget build(BuildContext context) {

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          }
        },
        child:Scaffold(
          backgroundColor: Color(0xFFEAE6E6),
          appBar: AppBar(
              backgroundColor: Colors.blueAccent,
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
              title:
              Text('Form WH. Opname', style: TextStyle(color: Colors.white))),
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
                // _getContentNewDriver(context),
              ],
            ),
          ),
        )
    );
  }

  Future<Widget?> _buildWHID(BuildContext context) async {
    print("globals.wh_method == ${globals.wh_method != 'edit'}");
    if (globals.wh_method != "edit") {
      // var valWHID = "";
      // setState(() {
      //   valWHID = selWareHouseID;
      // });
      // print("valWHID ${valWHID}");
      return new SmartSelect<String?>.single(
        title: 'WH ID',
        selectedValue: selWareHouseID,
        placeholder: 'Pilih satu',
        onChange: (selected) {
          print('selected.value ${selected.value}');
          setState(() {
            selWareHouseID = selected.value!;
          });
        },
        choiceItems: S2Choice.listFrom<String, Map>(
            source: lstWareHouseID,
            value: (index, item) => item['whswarehouseid'],
            title: (index, item) =>
                item['whswarehouseid'] + " - " + item['whsdescr']),
        //choiceGrouped: true,
        modalFilter: true,
        modalFilterAuto: true,
      );
    }
    // return new TextField(
    //   readOnly: true,
    //   cursorColor: Colors.black,
    //   style: TextStyle(color: Colors.grey.shade800),
    //   controller: txtIDWareHouse,
    //   keyboardType: TextInputType.text,
    //   decoration: new InputDecoration(
    //     fillColor: Colors.black12,
    //     filled: true,
    //     labelText: 'WH ID',
    //     isDense: true,
    //     contentPadding: EdgeInsets.all(2.0),
    //   ),
    // );
  }

  Widget _builButtonUpdate(BuildContext context) {
    if (globals.wh_method == "edit") {
      return new ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Update"),
        onPressed: () async {
          SharedPreferences prefs =
              await SharedPreferences.getInstance(); //SEMENTARA
          showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Information'),
              content: new Text("Update Inventory?"),
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
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var username = prefs.getString("name") ?? "";
                    if (globals.wh_method == "edit") {
                      UpdateStockOpname(username);
                    } else {
                      alert(scafoldGlobal.currentContext!!, 2,
                          "Pilih Item Id yang akan dipilih", "error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      );
    } else {
      return new Container();
    }
  }

  Widget _buildButtonCreateOrUpdate(BuildContext context) {
    if (globals.wh_method == "edit") {
      return new ElevatedButton.icon(
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 15.0,
          ),
          label: Text("Add"),
          onPressed: () async {
            setState(() {
              globals.wh_method = "";
            });
          },
          style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
    } else {
      return new ElevatedButton.icon(
          icon: Icon(
            Icons.save,
            color: Colors.white,
            size: 15.0,
          ),
          label: Text("Save"),
          onPressed: () async {
            SharedPreferences prefs =
                await SharedPreferences.getInstance(); //SEMENTARA
            showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text('Information'),
                content: new Text("Input Stock Opname?"),
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
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
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
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      var username = prefs.getString("name") ?? "";
                      if (globals.wh_method == "") {
                        CreateStockOpname(username);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
    }
  }

  Widget _buildButtonShowDetail(BuildContext context) {
    return new ElevatedButton.icon(
        icon: Icon(
          Icons.book,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Detail"),
        onPressed: () async {
          Timer(Duration(seconds: 1), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ListWareHouseOpName()));
          });
        },
        style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
  }

  Widget _buildButtonCancel(BuildContext context) {
    return new ElevatedButton.icon(
        icon: Icon(
          Icons.cancel,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Cancel"),
        onPressed: () async {
          reseTeks(false);
        },
        style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
  }

  List<Map<String, dynamic>> dataListNewItem = [];
  Widget buildBtnAddNewItem(BuildContext context, dynamic item) {
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.check,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Pilih"),
      onPressed: () async {
        //Navigator.of(context).pop(false);
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
            //FocusScope.of(context).requestFocus(myFocusNode);
          });
        });
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.orangeAccent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ));
  }

  Widget _buildDListNewItems(BuildContext context, dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
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
                  "WH ID : ${item['witwarehouseid']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Item ID : ${item['item_id']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Accesoris : ${item['idaccess']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Part Name: ${item['part_name']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Merk: ${item['merk']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Item Size: ${item['item_size']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[buildBtnAddNewItem(context, item)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainer(BuildContext ctx) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
            child: TextField(
              readOnly: globals.wh_method != "edit" ? false : true,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.grey.shade800),
              controller: txtSearchPartname,
              keyboardType: TextInputType.text,
              onChanged: (value) async {
                if (value != null && value != '') {
                  if (value.length > 5) {
                    //await getItemID(value);
                    //print(lstItemID);
                  }
                }
              },
              decoration: new InputDecoration(
                suffixIcon: IconButton(
                  icon: new Image.asset(
                    "assets/img/search.png",
                    width: 32.0,
                    height: 32.0,
                  ),
                  onPressed: () async {
                    print('witwarehouseid ' + selWareHouseID);
                    if ((txtSearchPartname.text != null &&
                            txtSearchPartname.text != "") &&
                        (selWareHouseID != null && selWareHouseID != "")) {
                      await getItemIDByPartName(
                          txtSearchPartname.text, selWareHouseID);
                      Navigator.of(context).pop(false);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('List Item'),
                              content: setupAlertDialoadContainerList(ctx),
                            );
                          });
                    } else {
                      alert(scafoldGlobal.currentContext!!, 2,
                          "Warehouse dan partname tidak boleh kosong", "error");
                    }
                  },
                ),
                fillColor: Colors.white,
                filled: true,
                labelText: 'Search',
                isDense: true,
                contentPadding: EdgeInsets.all(2.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainerList(BuildContext ctx) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(ctx)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(ctx).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount:
                      dataListNewItem == null ? 0 : dataListNewItem.length,
                  itemBuilder: (ctx, int index) {
                    return _buildDListNewItems(
                        ctx, dataListNewItem[index], index);
                  }))
        ],
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    print('globals.wh_method ${globals.wh_method}');
    return Container(
      padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
      child: ListView(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 0.0,
              shadowColor: Color(0x802196F3),
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: FutureBuilder<Widget?>(
                      future: _buildWHID(context),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return snapshot.data!;
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtItemID,
                      keyboardType: TextInputType.text,
                      onChanged: (value) async {
                        if (globals.wh_method != 'edit') {
                          if (value != null && value != '') {
                            if (value.length > 5) {
                              if (isScan == true) {
                                await getItemID(value);
                                print(lstItemID);
                              }
                            }
                          }
                        }
                      },
                      decoration: new InputDecoration(
                        suffixIcon: IconButton(
                          icon: new Image.asset(
                            "assets/img/qrcode.png",
                            width: 32.0,
                            height: 32.0,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                title: new Text('Information'),
                                content:
                                    new Text("Filter by name or Scan item ID?"),
                                actions: <Widget>[
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("Scan QRCode"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      setState(() {
                                        isScan = true;
                                      });
                                      scanQRCode();
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
                                      Icons.search,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("Search By Name"),
                                    onPressed: () async {
                                      Navigator.of(context).pop(false);
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      var username = prefs.getString("name") ?? "";
                                      print('Search By Name');
                                      setState(() {
                                        isScan = false;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Search Item'),
                                              content:
                                                  setupAlertDialoadContainer(
                                                      context),
                                            );
                                          });
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
                          },
                        ),
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Item ID',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtPartName,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Part Name',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtType,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Type',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtVHTID,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'VHTID',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtGenuinoNumber,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Genuine No',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtTypeAccessories,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Type Accessories',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtMerk,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Merk',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtItemSize,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Item Size',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtQuantityOnHands,
                      keyboardType: TextInputType.number,
                      //focusNode: myFocusNode,
                      decoration: new InputDecoration(
                        fillColor: Colors.black12,
                        filled: true,
                        labelText: 'Quantity OnHands',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: TextField(
                      readOnly: globals.wh_method != "edit" ? false : true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtQuantityOnActual,
                      keyboardType: TextInputType.number,
                      focusNode: myFocusNode,
                      decoration: new InputDecoration(
                        fillColor: globals.wh_method != "edit"
                            ? Colors.white
                            : Colors.black12,
                        filled: true,
                        labelText: 'Quantity Actual',
                        isDense: true,
                        contentPadding: EdgeInsets.all(2.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Flexible(
                            child: SmartSelect<String?>.single(
                              title: 'Type PO',
                              selectedValue: selTypePO,
                              onChange: (selected) {
                                setState(() {
                                  selTypePO = selected.value!;
                                  print('selTypePO ${selTypePO}');
                                  txtTypePO.text = selTypePO;
                                });
                              },
                              choiceType: S2ChoiceType.radios,
                              choiceItems: choices.listTypePO,
                              modalType: S2ModalType.popupDialog,
                              modalHeader: false,
                              modalConfig: const S2ModalConfig(
                                style: S2ModalStyle(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          new Flexible(
                              child: new TextField(
                            readOnly: true,
                            cursorColor: Colors.black,
                            style: TextStyle(color: Colors.grey.shade800),
                            controller: txtTypePO,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                              fillColor: globals.wh_method != "edit"
                                  ? Colors.white
                                  : Colors.black12,
                              filled: true,
                              labelText: 'Type Po',
                              isDense: true,
                              contentPadding: EdgeInsets.all(2.0),
                            ),
                          )),
                        ]),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Flexible(
                            child: SmartSelect<String?>.single(
                              title: 'Curr.',
                              selectedValue: selCuryID,
                              onChange: (selected) {
                                setState(() {
                                  selCuryID = selected.value!;
                                  txtCurrencyTypeID.text = selCuryID;
                                  print('selCuryID ${selCuryID}');
                                });
                              },
                              choiceType: S2ChoiceType.radios,
                              choiceItems: choices.currencyID,
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
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          new Flexible(
                              child: new TextField(
                            readOnly: true,
                            cursorColor: Colors.black,
                            style: TextStyle(color: Colors.grey.shade800),
                            controller: txtCurrencyTypeID,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                              fillColor: globals.wh_method != "edit"
                                  ? Colors.white
                                  : Colors.black12,
                              filled: true,
                              isDense: true,
                              contentPadding: EdgeInsets.all(2.0),
                            ),
                          )),
                        ]),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(
                  //       left: 10, top: 10, right: 10, bottom: 10),
                  //   child: TextField(
                  //     cursorColor: Colors.black,
                  //     style: TextStyle(color: Colors.grey.shade800),
                  //     controller: txtItemCost,
                  //     keyboardType: TextInputType.number,
                  //     //focusNode: myFocusNode,
                  //     decoration: new InputDecoration(
                  //       fillColor: Colors.white,
                  //       filled: true,
                  //       labelText: 'Item Cost',
                  //       isDense: true,
                  //       contentPadding: EdgeInsets.all(2.0),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   margin: EdgeInsets.only(
                  //       left: 10, top: 10, right: 10, bottom: 10),
                  //   child: TextField(
                  //     cursorColor: Colors.black,
                  //     style: TextStyle(color: Colors.grey.shade800),
                  //     controller: txtCurrencyTypeID,
                  //     keyboardType: TextInputType.text,
                  //     //focusNode: myFocusNode,
                  //     decoration: new InputDecoration(
                  //       fillColor: Colors.white,
                  //       filled: true,
                  //       labelText: 'Currency Type ID',
                  //       isDense: true,
                  //       contentPadding: EdgeInsets.all(2.0),
                  //     ),
                  //   ),
                  // ),
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: Row(children: <Widget>[
                        Expanded(
                          child: _buildButtonCreateOrUpdate(context),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: _buildButtonShowDetail(context),
                        ),
                        SizedBox(
                          width: globals.wh_method == "edit" ? 10 : 0,
                        ),
                        globals.wh_method == "edit"
                            ? Expanded(
                                child: _builButtonUpdate(context),
                              )
                            : Container(),
                      ])),
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: Row(children: <Widget>[
                        Expanded(
                          child: _buildButtonCancel(context),
                        ),
                        SizedBox(
                          width: 5,
                        )
                      ]))
                ],
              ),
            ),
          ),
        ],
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
