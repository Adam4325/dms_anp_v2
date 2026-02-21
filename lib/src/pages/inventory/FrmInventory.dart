import 'dart:async';
import 'package:dms_anp/src/pages/inventory/ListInventoryDetail.dart';
import 'package:dms_anp/src/pages/inventory/ListInventoryTransNew.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dms_anp/src/Helper/scanner_helper.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:awesome_select/awesome_select.dart';

import '../../flusbar.dart';


class FrmInventory extends StatefulWidget {
  final String invTrxStatusBarang;
  const FrmInventory({Key? key, required this.invTrxStatusBarang})
      : super(key: key);

  @override
  _FrmInventoryState createState() => _FrmInventoryState();
}

//final globalScaffoldKey = GlobalKey<ScaffoldState>();

class _FrmInventoryState extends State<FrmInventory> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  String BASE_URL =
      GlobalData.baseUrl; //"http://apps.tuluatas.com:8085/cemindo";
  FocusNode myFocusNode = FocusNode();

  // Orange Soft Theme Colors (sesuai INSTRUCTIONS.md)
  final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
  final Color accentOrange = Color(0xFFFFB347); // Peach orange
  final Color darkOrange = Color(0xFFE07B39); // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  final Color cardColor = Color(0xFFF8F0); // Light cream
  final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow

  TextEditingController txtInvNumber = new TextEditingController();
  TextEditingController txtItemID = new TextEditingController();
  TextEditingController txtPartName = new TextEditingController();
  TextEditingController txtMerk = new TextEditingController();
  TextEditingController txtType = new TextEditingController();
  TextEditingController txtGenuineNo = new TextEditingController();
  TextEditingController txtVHTID = new TextEditingController();
  TextEditingController txtTypeAccess = new TextEditingController();
  TextEditingController txtQuantity = new TextEditingController();
  TextEditingController txtSnTyre = new TextEditingController();
  TextEditingController txtUnitCost = new TextEditingController();
  TextEditingController txtExtendedCost = new TextEditingController();
  TextEditingController txtUomID = new TextEditingController();

  // 2 Field Baru yang diminta
  TextEditingController txtRealQtyBekas =
      new TextEditingController(); // Quantity Barang Bekas
  String txtKondisiBarangBekas =
      ""; // Select kondisi (''=Pilih Status, 0=Rusak, 1=Tidak Rusak)

  var type_transaction = ""; //IS-M; IR-P
  String selUomID = "";
  List<Map<String, dynamic>> lstSelUomID = [];
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  int status_code = 0;
  String message = "";
  int _ocrCamera = 0; // Camera back (0 = back, 1 = front)
  String _text = "TEXT";

  String userid = "";
  String scanResult = '';
  String selitdlinenbr = '';
  String selitem_size = '';
  String seltowarehouseid = '';
  String selunitpricce = '';

  bool isNumeric(String? s) {
    if (s == null || s.isEmpty) {
      return false;
    }
    try {
      double.parse(s);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalScaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        elevation: 3.0,
        shadowColor: shadowColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _goBack(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Form Input Inventory',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
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
    );
  }

  void reseTeks() {
    setState(() {
      txtItemID.text = "";
      txtQuantity.text = "1";
      txtUomID.text = "";
      txtType.text = "";
      txtTypeAccess.text = "";
      txtPartName.text = "";
      txtMerk.text = "";
      txtSnTyre.text = "";
      txtGenuineNo.text = "";
      txtVHTID.text = "";
      selitdlinenbr = '';
      selitem_size = '';
      seltowarehouseid = '';
      txtRealQtyBekas.text = ''; // Reset field baru
      txtKondisiBarangBekas = ''; // Reset field baru ke "Pilih Status"
      // if(globals.inv_back_page!="form"){
      //   globals.inv_itdlinenbr = "";
      //   globals.inv_method = "";
      //   globals.inv_vendorid = "";
      //   globals.inv_towarehouse = "";
      //   globals.inv_back_page_detail = "";
      //   globals.inv_back_page = "";
      // }
    });
  }

  Future<String> getListUomId() async {
    String status = "";
    var urlData =
        "${BASE_URL}api/inventory/list_uom.jsp?method=list-items-uom-v1";

    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstSelUomID = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        //print("lstVheicleType");
        //print(lstVheicleType);
      }
    });
    return status;
  }

  void CreateInventory(String usr) async {
    try {
      var itdinvtrannbr = txtInvNumber.text;
      var ititemid = txtItemID.text;
      var idqty = txtQuantity.text;
      var uomid = globals.inv_itdlinenbr != "" ? selUomID : txtUomID.text;
      var username = usr;
      var idtype = txtType.text;
      print(type_transaction);
      var idaccess = txtTypeAccess.text;
      var part_name = txtPartName.text;
      var locid = globals.inv_locid == 'null' ||
              globals.inv_locid == '' ||
              globals.inv_locid == null
          ? ''
          : globals.inv_locid;
      var merk = txtMerk.text;
      var sntyre = txtSnTyre.text;
      var genuine_no = globals.inv_genuine_no == 'null' ||
              globals.inv_genuine_no == '' ||
              globals.inv_genuine_no == null
          ? txtGenuineNo.text
          : globals.inv_genuine_no; //txtGenuineNo.text;
      var vhtid = globals.inv_vhtid == 'null' ||
              globals.inv_vhtid == null ||
              globals.inv_vhtid == null
          ? txtVHTID.text
          : globals.inv_vhtid;

      if (itdinvtrannbr == null || itdinvtrannbr == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Number tidak boleh kosong", "error");
        }
      } else if (ititemid == null || ititemid == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "ItemID tidak boleh kosong", "error");
        }
      } else if (uomid == null || uomid == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "UOMID tidak boleh kosong", "error");
        }
      } else if (idtype == null || idtype == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Type tidak boleh kosong", "error");
        }
      }
      // else if (vhtid == null || vhtid == "") {
      //   alert(scafoldGlobal.currentContext, 0, "INVENTORY SEARCHVHTID tidak boleh kosong",
      //       "error");
      // }
      else if (idaccess == null || idaccess == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Accessories tidak boleh kosong", "error");
        }
      } else if (part_name == null || part_name == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Part name tidak boleh kosong", "error");
        }
      } else if (idqty == null || idqty == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Quantity (QTY) tidak boleh kosong", "error");
        }
      } else if (int.parse(idqty) <= 0) {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Quantity (QTY) harus lebih dari 0", "error");
        }
      } else {
        EasyLoading.show();
        var encoded =
            Uri.encodeFull("${BASE_URL}api/inventory/create_inv_detail.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-inv-detail-v1',
          'itdinvtrannbr': itdinvtrannbr,
          'inv_vendorid': globals.inv_vendorid,
          'type_transaction': type_transaction,
          'ititemid': ititemid,
          'idqty': idqty,
          'unitprice': selunitpricce,
          'uomid': uomid,
          'username': username,
          'idtype': idtype,
          'idaccess': idaccess,
          'part_name': part_name,
          'locid': locid,
          'merk': merk,
          'sntyre': sntyre,
          'genuine_no': genuine_no,
          'vhtid': vhtid,
          'towarehouseid': seltowarehouseid,
          'item_size': selitem_size,
          'itdlinenbr': selitdlinenbr,
          'vendorid': globals.inv_vendorid,
          'real_qty_bekas': txtRealQtyBekas.text, // Field baru
          'kondisi_barang_bekas': txtKondisiBarangBekas, // Field baru
          "userid": username
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
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        reseTeks();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: primaryOrange, // ✅ Orange background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            } else {
              //Navigator.of(scafoldGlobal.currentContext).pop(false);
              Future.delayed(Duration(milliseconds: 1));
              final ctx = globalScaffoldKey.currentContext;
              if (ctx != null) {
                alert(ctx, 0, "Gagal menyimpan ${message}", "error");
              }
            }
          } else {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
            //Navigator.of(scafoldGlobal.currentContext).pop(false);
            Future.delayed(Duration(milliseconds: 1));
            final ctx = globalScaffoldKey.currentContext;
            if (ctx != null) {
              alert(ctx, 0, "Gagal menyimpan ${response.statusCode}", "error");
            }
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Client, Gagal Menyimpan Data", "error");
      }
      print(e.toString());
    }
  }

  void UpdateInventory(String usr) async {
    try {
      var itdinvtrannbr = txtInvNumber.text;
      var ititemid = txtItemID.text;
      var idqty = txtQuantity.text;
      var uomid = selUomID;
      var username = usr;
      var idtype = txtType.text;
      var idaccess = txtTypeAccess.text;
      var part_name = txtPartName.text;
      var locid = globals.inv_locid;
      var merk = txtMerk.text;
      var sntyre = txtSnTyre.text;
      var genuine_no = txtGenuineNo.text;
      var vhtid = txtVHTID.text;
      var itdlinenbr = globals.inv_itdlinenbr;

      if (itdinvtrannbr == null || itdinvtrannbr == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Number tidak boleh kosong", "error");
        }
      } else if (itdlinenbr == null || itdlinenbr == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Line Number tidak boleh kosong", "error");
        }
      } else if (ititemid == null || ititemid == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "ItemID tidak boleh kosong", "error");
        }
      } else if (uomid == null || uomid == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "UOMID tidak boleh kosong", "error");
        }
      } else if (idtype == null || idtype == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Type tidak boleh kosong", "error");
        }
      }
      // else if (genuine_no == null || genuine_no == "") {
      //   alert(scafoldGlobal.currentContext, 0, "Genuineno tidak boleh kosong",
      //       "error");
      // }else if (vhtid == null || vhtid == "") {
      //   alert(scafoldGlobal.currentContext, 0, "VHTID tidak boleh kosong",
      //       "error");
      // }
      else if (idaccess == null || idaccess == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Accessories tidak boleh kosong", "error");
        }
      } else if (part_name == null || part_name == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Part name tidak boleh kosong", "error");
        }
      } else if (idqty == null || idqty == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Quantity (QTY) tidak boleh kosong", "error");
        }
      } else if (int.parse(idqty) <= 0) {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Quantity (QTY) harus lebih dari 0", "error");
        }
      } else {
        EasyLoading.show();
        var encoded =
            Uri.encodeFull("${BASE_URL}api/inventory/create_inv_detail.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'update-inv-detail-v1',
          'itdinvtrannbr': itdinvtrannbr,
          'ititemid': ititemid,
          'idqty': idqty,
          'uomid': uomid,
          'itdlinenbr': itdlinenbr,
          'username': username,
          'idtype': idtype,
          'idaccess': idaccess,
          'part_name': part_name,
          'locid': locid,
          'merk': merk,
          'sntyre': sntyre,
          'genuine_no': genuine_no,
          'vhtid': vhtid,
          'real_qty_bekas': txtRealQtyBekas.text, // Field baru
          'kondisi_barang_bekas': txtKondisiBarangBekas, // Field baru
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
        if (response.statusCode == 200) {
          status_code = json.decode(response.body)["status_code"];
          message = json.decode(response.body)["message"];
          //print(response.body);
          if (status_code == 200) {
            showDialog(
              context: globalScaffoldKey.currentContext!,
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
            //Navigator.of(scafoldGlobal.currentContext).pop(false);
            Future.delayed(Duration(milliseconds: 1));
            final ctx = globalScaffoldKey.currentContext;
            if (ctx != null) {
              alert(ctx, 0, "Gagal update ${message}", "error");
            }
          }
        } else {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          //Navigator.of(scafoldGlobal.currentContext).pop(false);
          Future.delayed(Duration(milliseconds: 1));
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 0, "Gagal update ${response.statusCode}", "error");
          }
          print("Gagal menyimpan ${response.statusCode}");
        }
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Client, Gagal Menyimpan Data", "error");
      }
      print(e.toString());
    }
  }

  Future scanQRCode() async {
    if (!mounted) return;

    final String? scanResult = await openQrScanner(context);

    if (scanResult == null || scanResult.isEmpty) {
      if (mounted) {
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, "Scan Item ID gagal!", "error");
      }
      return;
    }

    setState(() {
      this.scanResult = scanResult;
      txtItemID.text = scanResult;
    });

    // Jika scan berhasil, ambil data item
    if (scanResult.isNotEmpty) {
      var itemID = scanResult;
      if (itemID != null && itemID != '') {
        var url =
            "${BASE_URL}api/inventory/list_item_barcode_mobile.jsp?method=list-items-v1&trx_type=${type_transaction}&warehouseid=${globals.from_ware_house}&towarehouseid=${globals.inv_towarehouse}&vendor=${globals.inv_vendorid}&search=$itemID&is_barcode=1";
        print(url);
        getItemBarcode(url, itemID);
      } else {
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, "Item ID kosong", "error");
      }
    }
  }


  Future scanQRCodeDev() async {
    //TEST
    setState(() {
      var itemID = "10-10-68-50"; //scanResult;
      var url =
          "${BASE_URL}api/inventory/list_item_barcode_mobile.jsp?method=list-items-v1&trx_type=${type_transaction}&warehouseid=${globals.from_ware_house}&towarehouseid=${globals.inv_towarehouse}&vendor=${globals.inv_vendorid}&search=${itemID}&is_barcode=1";
      print(url);
      getItemBarcode(url, "10-10-68-50");
    });
  }

  var selvendorid = '';
  // selitem_size = '';
  // seltowarehouseid = '';
  // selunitpricce = '0';
  // selitdlinenbr = '';
  void getItemBarcode(String url, String itemid) async {
    //print("getItemBarcode ${getItemBarcode}");
    var urlData = url;
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print('getItemBarcode ${encoded}');
    http.Response response = await http.get(myUri);
    print(response.body.toString());
    setState(() {
      if (response.statusCode == 200) {
        List result = json.decode(response.body);
        print(result.length);
        if (result != null && result.length > 0) {
          txtItemID.text = itemid;
          txtPartName.text = result[0]['part_name'];
          txtQuantity.text = "1"; //result[0]['quantity'];
          selUomID = result[0]['uom_id'];
          txtUnitCost.text = '0';
          txtUnitCost.text = result[0]['cost'];
          txtType.text = result[0]['type'];
          txtTypeAccess.text = result[0]['accessories'];
          txtMerk.text = result[0]['merk'];
          txtUomID.text = result[0]['uom_id'];

          ///txtUomID.text = result[0]['genuien'];
          txtGenuineNo.text = result[0]['genuine_no'];
          txtVHTID.text = result[0]['vhtid'];
          selitem_size = result[0]['item_size'];
          selitdlinenbr = result[0]['itdlinenbr'];
          seltowarehouseid = result[0]['towarehouse'];
          selvendorid = result[0]['vendorid'];
          selunitpricce = '0';
          selunitpricce = result[0]['cost'];
          print(globals.inv_locid);
          myFocusNode.requestFocus();
        } else {
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 2, "Data inventory tidak ditemukan", "warning");
          }
        }
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(
              ctx, 0, "Error,Response server ${response.statusCode}", "error");
        }
      }
    });
  }

  @override
  void initState() {
    print('inv_back_page; ${globals.inv_back_page}');
    print('print(globals.inv_locid); ${globals.inv_locid}');
    print('FORM INVENTORY');
    print('inv_trx_type ${globals.inv_trx_type}');
    if (globals.inv_trx_type != null && globals.inv_trx_type != '') {
      type_transaction = globals.inv_trx_type!;
    }
    print('globals.inv_trx_number ${globals.inv_trx_number}');
    // if(globals.inv_back_page=="form"){
    //   reseTeks();
    // }else{
    //
    // }
    txtInvNumber.text = globals.inv_trx_number ?? '';
    txtItemID.text = globals.inv_ititemid ?? '';
    txtPartName.text = globals.inv_partname ?? '';
    if (globals.inv_method == "edit") {
      txtQuantity.text = globals.inv_idqty ?? '0';
    } else {
      txtQuantity.text = "0";
    }

    selUomID = globals.inv_uomid ?? '';
    txtUnitCost.text = globals.inv_itdunitcost ?? '0';
    txtExtendedCost.text = globals.inv_idtextcost ?? '0';
    //globals.inv_itdinvtrannbr;
    txtType.text = globals.inv_idtype ?? '';
    txtTypeAccess.text = globals.inv_idaccess ?? '';
    txtMerk.text = globals.inv_merk ?? '';
    txtSnTyre.text = globals.inv_sntyre ?? '';
    txtGenuineNo.text = globals.inv_genuine_no ?? '';
    txtVHTID.text = globals.inv_vhtid ?? '';
    getListUomId();
    print('widget.invTrxStatusBarang');
    print(widget.invTrxStatusBarang);//
    print('widget');
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
    reseTeks();
    globals.inv_itdlinenbr = "";
    globals.inv_method = "";
    globals.inv_vendorid = "";
    globals.inv_towarehouse = "";
    globals.inv_back_page_detail = "";
    globals.inv_back_page = "";
    if (globals.inv_back_page == "detail") {
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => ListInventoryDetail({tabName:"wid_list_inventory"})));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ListInventoryDetail(
            tabName: "wid_list_inventory",
            invTrxStatusBarang: '',
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ListInventoryTransNew(tabName: "wid_list_inventory")));
    }
    globals.inv_back_page = "";
  }

  // Custom TextField with orange theme (sesuai INSTRUCTIONS.md)
  Widget buildTextField({
    String labelText = '',
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixIcon,
    required Function(String) onTap,
    required Function(String) onChanged,
    FocusNode? focusNode,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      child: TextField(
        readOnly: readOnly,
        cursorColor: primaryOrange, // ✅ Orange cursor
        style: TextStyle(color: Colors.grey.shade800),
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        onChanged: onChanged,
        onTap: onTap != null ? () => onTap('') : null,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          fillColor:
              readOnly ? cardColor : Colors.white, // ✅ Light cream for readonly
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          isDense: true,
          contentPadding: EdgeInsets.all(12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: primaryOrange, width: 2), // ✅ Orange focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
          ),
        ),
      ),
    );
  }

  ProgressDialog? pr;
  // @override
  // Widget build(BuildContext context) {
  //   // pr = new ProgressDialog(context,
  //   //     type: ProgressDialogType.Normal, isDismissible: true);
  //   //
  //   // pr.style(
  //   //   message: 'Wait...',
  //   //   borderRadius: 10.0,
  //   //   backgroundColor: Colors.white,
  //   //   elevation: 10.0,
  //   //   insetAnimCurve: Curves.easeInOut,
  //   //   progress: 0.0,
  //   //   maxProgress: 100.0,
  //   //   progressTextStyle: TextStyle(
  //   //       color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
  //   //   messageTextStyle: TextStyle(
  //   //       color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
  //   // );
  //   return new WillPopScope(
  //     onWillPop: () {
  //       // globals.inv_itdlinenbr = "";
  //       // globals.inv_method = "";
  //       // globals.inv_vendorid = "";
  //       // globals.inv_towarehouse = "";
  //       // globals.inv_back_page_detail = "";
  //       // globals.inv_back_page = "";
  //       //
  //       // if (globals.inv_back_page == "detail") {
  //       //   globals.inv_back_page = "";
  //       //   Navigator.pushReplacement(context,
  //       //       MaterialPageRoute(builder: (context) => ListInventoryDetail()));
  //       //   return Future.value(false);
  //       // } else {
  //       //   globals.inv_back_page = "";
  //       //   Navigator.pushReplacement(context,
  //       //       MaterialPageRoute(builder: (context) => ListInventoryTransNew()));
  //       //   return Future.value(false);
  //       // }
  //       _goBack(context);
  //       return Future.value(false);
  //     },
  //     child: new Scaffold(
  //       backgroundColor: backgroundColor, // ✅ Cream background
  //       appBar: AppBar(
  //           backgroundColor: primaryOrange, // ✅ Orange AppBar
  //           elevation: 3.0,
  //           shadowColor: shadowColor, // ✅ Orange shadow
  //           leading: IconButton(
  //             icon: Icon(Icons.arrow_back, color: Colors.white),
  //             iconSize: 22.0,
  //             onPressed: () {
  //               _goBack(context);
  //             },
  //           ),
  //           centerTitle: true,
  //           title: Text('Form Input Inventory',
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600))),
  //       body: Container(
  //         key: globalScaffoldKey, //scafoldGlobal,
  //         constraints: BoxConstraints.expand(),
  //         color: HexColor("#f0eff4"),
  //         child: Stack(
  //           children: <Widget>[
  //             ImgHeader1(context),
  //             ImgHeader2(context),
  //             BuildHeader(context),
  //             _getContent(context),
  //             // _getContentNewDriver(context),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildUOMID(BuildContext context) {
    print(globals.inv_method);
    if (globals.inv_method == "edit" || globals.inv_itdlinenbr != "") {
      return Container(
        margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        child: SmartSelect<String?>.single(
          title: 'UOM ID',
          selectedValue: selUomID,
          placeholder: 'Pilih satu',
          onChange: (selected) => setState(() => selUomID = selected.value!),
          choiceItems: S2Choice.listFrom<String, Map>(
              source: lstSelUomID,
              value: (index, item) => item['uomid'],
              title: (index, item) => item['uomdescr']),
          modalFilter: true,
          modalFilterAuto: true,
          modalConfirm: true,
          modalType: S2ModalType.bottomSheet,
          choiceStyle: S2ChoiceStyle(
            titleStyle: TextStyle(color: Colors.grey.shade800),
            color: primaryOrange.withOpacity(0.1),
          ),
          modalStyle: S2ModalStyle(
            backgroundColor: cardColor,
            elevation: 3,
          ),
        ),
      );
    }
    return buildTextField(
      labelText: 'UOM ID',
      controller: txtUomID,
      readOnly: true,
      onTap: (String p1) {},
      onChanged: (String p1) {},
      focusNode: null,
    );
  }

  Widget _builButtonUpdate(BuildContext context) {
    if (globals.inv_method == "edit") {
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
                      elevation: 2.0,
                      backgroundColor:
                          Colors.grey.shade500, // ✅ Gray for No/Cancel
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                    if (globals.inv_method == "edit") {
                      UpdateInventory(username);
                    } else {
                      final ctx = globalScaffoldKey.currentContext;
                      if (ctx != null) {
                        alert(
                            ctx, 2, "Pilih Item Id yang akan dipilih", "error");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: primaryOrange, // ✅ Orange for Ok/Confirm
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            elevation: 2.0,
            backgroundColor: primaryOrange, // ✅ Orange background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    } else {
      return new Container();
    }
  }

  Widget _buildButtonCreateOrUpdate(BuildContext context) {
    if (globals.inv_method == "edit") {
      return new ElevatedButton.icon(
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 15.0,
          ),
          label: Text("Add",style: TextStyle(color: Colors.white)),
          onPressed: () async {
            setState(() {
              globals.inv_method = "";
            });
          },
          style: ElevatedButton.styleFrom(
              elevation: 2.0,
              backgroundColor: accentOrange, // ✅ Accent orange for Add
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)));
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
                content: new Text("Input Inventory?"),
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
                        elevation: 2.0,
                        backgroundColor:
                            Colors.grey.shade500, // ✅ Gray for No/Cancel
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
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
                      if (globals.inv_method == "") {
                        print(globals.inv_vendorid);
                        CreateInventory(username);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 2.0,
                        backgroundColor:
                            primaryOrange, // ✅ Orange for Ok/Confirm
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              elevation: 2.0,
              backgroundColor: primaryOrange, // ✅ Orange for Save
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));
    }
  }

  List<Map<String, dynamic>> dataListItemSearch = [];
  TextEditingController txtSearchPartname = new TextEditingController();
  Future getListDataItem(String type, String wonumber, String invnumber,
      String warehouseid) async {
    try {
      EasyLoading.show();

      var url =
          "${BASE_URL}api/inventory/list_item_sr_katalog_ism_isw.jsp?method=list-items-v1&type=${type}&wonumber=${wonumber}&invnumber=${invnumber}&warehouseid=${warehouseid}";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListItemSearch = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Gagal load data item", "error");
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Client, Load data item", "error");
      }
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  final FocusNode _focusNodeTxtQty = FocusNode();
  Widget _buildDListDetailItem(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
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
                  "Item ID : ${item['item_id']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Partname : ${item['part_name']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Type : ${item['type']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Merk : ${item['merk']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("ID ACCESS : ${item['accessories']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("UOM: ${item['uom_id']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("ITEM SIZE: ${item['item_size']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("VHTID: ${item['vhtid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  )
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
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Pilih"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    //print(item);
                    txtItemID.text = item['item_id'];
                    txtPartName.text = item['part_name'];
                    txtMerk.text = item['merk'];
                    txtType.text = item['type'];
                    txtGenuineNo.text = item['genuine_no'];
                    txtVHTID.text = item['vhtid'];
                    txtTypeAccess.text = item['accessories'];
                    txtUomID.text = item['uom_id'];
                    // txtSnTyre.text = item['part_name'];
                    txtQuantity.text = '0'; //;item['quantity'];
                    txtRealQtyBekas.text = '0';
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: primaryOrange, // ✅ Orange for Pilih
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                )),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Close"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: Colors.grey.shade500, // ✅ Gray for Close
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget listDataSearchItem(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Container(
          //   margin: EdgeInsets.all(10.0),
          //   child: TextField(
          //     readOnly: false,
          //     cursorColor: Colors.black,
          //     style: TextStyle(color: Colors.grey.shade800),
          //     controller: txtSearchPartname,
          //     keyboardType: TextInputType.text,
          //     decoration: new InputDecoration(
          //         suffixIcon: IconButton(
          //           icon: new Image.asset(
          //             "assets/img/search.png",
          //             width: 32.0,
          //             height: 32.0,
          //           ),
          //           onPressed: () async {
          //             if (txtSearchPartname.text != null &&
          //                 txtSearchPartname.text != "") {
          //               await getListDataItem(globals.inv_trx_type,globals.inv_wonumber,globals.inv_trx_number,globals.from_ware_house);
          //             }
          //           },
          //         ),
          //         fillColor: HexColor("FFF6F1BF"),
          //         filled: true,
          //         isDense: true,
          //         labelText: "Partname",
          //         contentPadding: EdgeInsets.all(5.0),
          //         border: OutlineInputBorder(
          //             borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          //   ),
          // ),
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: dataListItemSearch == null
                      ? 0
                      : dataListItemSearch.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailItem(
                        dataListItemSearch[index], index);
                  }))
        ],
      ),
    );
  }

  Widget _getContent(BuildContext context) {
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
                  buildTextField(
                    labelText: 'INV. Number',
                    controller: txtInvNumber,
                    readOnly: true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'Item ID',
                    controller: txtItemID,
                    readOnly: true,
                    suffixIcon: IconButton(
                      icon: new Image.asset(
                        "assets/img/qrcode.png",
                        width: 32.0,
                        height: 32.0,
                      ),
                      onPressed: () {
                        if (globals.inv_trx_type == 'IS-M' ||
                            globals.inv_trx_type == 'IR-W') {
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (BuildContext context) => new AlertDialog(
                              title: new Text('Information'),
                              content:
                                  new Text("View Opname/ Item By Scan Code"),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        label: Text("View Opname",style: TextStyle(color:Colors.white)),
                                        onPressed: () async {
                                          Navigator.of(context, rootNavigator: true).pop();
                                          getListDataItem(
                                              globals.inv_trx_type!,
                                              globals.inv_wonumber!,
                                              globals.inv_trx_number!,
                                              globals.from_ware_house!);
                                          await Future.delayed(Duration(milliseconds: 1));
                                          if (dataListItemSearch.length > 0) {
                                            print('dataListItemSearch ${dataListItemSearch.length}');
                                            print('Show dialog');
                                            showDialog(
                                                context: globalScaffoldKey.currentContext!,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('List Detail Item'),
                                                    content: listDataSearchItem(context),
                                                  );
                                                });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 2.0,
                                            backgroundColor: accentOrange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.qr_code_scanner,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        label: Text("Scan Barcode",style: TextStyle(color:Colors.white)),
                                        onPressed: () async {
                                          Navigator.of(context, rootNavigator: true).pop();//
                                          scanQRCode();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 2.0,
                                            backgroundColor: primaryOrange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        } else {
                          scanQRCode();
                        }

                        //scanQRCodeDev();
                      },
                    ),
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'Part Name',
                    controller: txtPartName,
                    readOnly: globals.inv_method == "edit" ? false : true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'Merk',
                    controller: txtMerk,
                    readOnly: globals.inv_method == "edit" ? false : true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'Type',
                    controller: txtType,
                    readOnly: true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'Genuine No',
                    controller: txtGenuineNo,
                    readOnly: true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'VHTID',
                    controller: txtVHTID,
                    readOnly: true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  buildTextField(
                    labelText: 'Type Access',
                    controller: txtTypeAccess,
                    readOnly: globals.inv_method == "edit" ? false : true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, top: 10, right: 10, bottom: 10),
                    child: _buildUOMID(context),
                  ),
                  buildTextField(
                    labelText: 'SN Tyre (No Stampl Ban)',
                    controller: txtSnTyre,
                    readOnly: globals.inv_method == "edit" ? false : true,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  // Container(
                  //   margin:
                  //   EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                  //   child: TextField(
                  //     readOnly: true,
                  //     cursorColor: Colors.black,
                  //     style: TextStyle(color: Colors.grey.shade800),
                  //     controller: txtUnitCost,
                  //     keyboardType: TextInputType.text,
                  //     decoration: new InputDecoration(
                  //       fillColor: Colors.white,
                  //       filled: true,
                  //       labelText: 'Unit Cost',
                  //       isDense: true,
                  //       contentPadding: EdgeInsets.all(2.0),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   margin:
                  //   EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                  //   child: TextField(
                  //     readOnly: true,
                  //     cursorColor: Colors.black,
                  //     style: TextStyle(color: Colors.grey.shade800),
                  //     controller: txtExtendedCost,
                  //     keyboardType: TextInputType.text,
                  //     decoration: new InputDecoration(
                  //       fillColor: Colors.white,
                  //       filled: true,
                  //       labelText: 'Extended Cost',
                  //       isDense: true,
                  //       contentPadding: EdgeInsets.all(2.0),
                  //     ),
                  //   ),
                  // ),
                  buildTextField(
                    labelText: 'Quantity',
                    controller: txtQuantity,
                    keyboardType: TextInputType.number,
                    focusNode: myFocusNode,
                    readOnly: false,
                    onTap: (String p1) {},
                    onChanged: (String p1) {},
                  ),
                  // Field baru 1: Quantity Barang Bekas
                  if (widget.invTrxStatusBarang != null &&
                      widget.invTrxStatusBarang.toString() == 'IS-M') ...[
                    Container(
                      margin: EdgeInsets.all(12.0),
                      child: DropdownButtonFormField<String>(
                        value: txtKondisiBarangBekas,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          labelText: 'Kondisi Barang Bekas',
                          labelStyle: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: primaryOrange, width: 2),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: primaryOrange),
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text('Pilih Status',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic)),
                          ),
                          // DropdownMenuItem<String>(
                          //   value: '0',
                          //   child: Text('Rusak',
                          //       style: TextStyle(color: Colors.black87)),
                          // ),
                          // DropdownMenuItem<String>(
                          //   value: '1',
                          //   child: Text('Tidak Rusak',
                          //       style: TextStyle(color: Colors.black87)),
                          // ),
                          DropdownMenuItem<String>(
                            value: '0',
                            child: Text('Scrab (DiBuang)',
                                style: TextStyle(color: Colors.black87)),
                          ),
                          DropdownMenuItem<String>(
                            value: '1',
                            child: Text('ReBuild (Diperbaiki)',
                                style: TextStyle(color: Colors.black87)),
                          ),
                          DropdownMenuItem<String>(
                            value: '2',
                            child: Text('ReUsed (Di Gunakan Kembali)',
                                style: TextStyle(color: Colors.black87)),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            txtKondisiBarangBekas = newValue!;
                          });
                        },
                      ),
                    ),
                    buildTextField(
                      labelText: 'Quantity Barang Bekas',
                      controller: txtRealQtyBekas,
                      keyboardType: TextInputType.number,
                      readOnly: false,
                      onTap: (String p1) {},
                      onChanged: (String p1) {},
                    ),
                    SizedBox(height: 50),
                  ],
                  Container(
                      margin: EdgeInsets.all(10.0),
                      child: Row(children: <Widget>[
                        Expanded(
                          child: _buildButtonCreateOrUpdate(context),
                        ),
                        SizedBox(
                          width: globals.inv_method == "edit" ? 10 : 0,
                        ),
                        globals.inv_method == "edit"
                            ? Expanded(
                                child: _builButtonUpdate(context),
                              )
                            : Container(),
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
