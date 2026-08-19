import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/inventory/FrmInventory.dart';
import 'package:dms_anp/src/pages/inventory/ListInventoryTransNew.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dms_anp/src/widgets/simple_paginator.dart';

class ListInventoryDetail extends StatefulWidget {
  final String tabName;
  final String invTrxStatusBarang;//
  const ListInventoryDetail(
      {Key? key, required this.tabName, required this.invTrxStatusBarang})
      : super(key: key);
  @override
  _ListInventoryDetailState createState() => _ListInventoryDetailState();
}

class _ListInventoryDetailState extends State<ListInventoryDetail> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _txtSearch = TextEditingController();

  final Color primaryOrange = Color(0xFFFF8C69);
  final Color accentOrange = Color(0xFFFFB347);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);
  final Color shadowColor = Color(0x20FF8C69);

  Icon customIcon = const Icon(Icons.search, color: Colors.white);
  Widget customSearchBar = const Text('List Inventory Detail.');

  _goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ListInventoryTransNew(tabName: '',)));
  }

  void _reloadList() {
    paginatorGlobalKey.currentState?.changeState(
      pageLoadFuture: sendDriverDataRequest,
      resetState: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
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
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: shadowColor,
          automaticallyImplyLeading: false,
          title: customSearchBar,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _goBack(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: customIcon,
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel, color: Colors.white);
                    customSearchBar = ListTile(
                      onTap: () async {
                        if (_txtSearch.text.isEmpty) return;
                        _searchText = _txtSearch.text;
                        _reloadList();
                      },
                      leading: Icon(Icons.search, color: Colors.white, size: 28),
                      title: TextField(
                        controller: _txtSearch,
                        decoration: InputDecoration(
                          hintText: 'Cari part name / Item ID...',
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                        onSubmitted: (_) {
                          _searchText = _txtSearch.text;
                          _reloadList();
                        },
                      ),
                    );
                  } else {
                    _searchText = "";
                    _txtSearch.text = "";
                    customIcon = const Icon(Icons.search, color: Colors.white);
                    customSearchBar = const Text('List Inventory Detail');
                    _reloadList();
                  }
                });
              },
            ),
          ],
        ),
        body: Paginator.listView(
          key: paginatorGlobalKey,
          pageLoadFuture: sendDriverDataRequest,
          pageItemsGetter: (data) => listItemsGetter(data as DriverDataModel),
          listItemBuilder: listItemBuilder,
          loadingWidgetBuilder: loadingWidgetMaker,
          errorWidgetBuilder: errorWidgetMaker,
          emptyListWidgetBuilder: (data) => emptyListWidgetMaker(data),
          totalItemsGetter: (data) => totalPagesGetter(data as DriverDataModel),
          pageErrorChecker: (data) => pageErrorChecker(data as DriverDataModel),
          scrollPhysics: const BouncingScrollPhysics(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          onPressed: () {
            setState(() {
              _searchText = "";
              _txtSearch.text = "";
            });
            _reloadList();//
          },
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }

  Future<DriverDataModel> sendDriverDataRequest(int page) async {
    var number = globals.inv_trx_number;
    var type = globals.inv_trx_type;
    var from = globals.from_ware_house;
    try {
      final uri = Uri.parse(
              '${GlobalData.baseUrl}api/inventory/list_inventory_detail.jsp')
          .replace(queryParameters: {
        'method': 'list-inventory-detail-v1',
        'number': number ?? '',
        'type': type ?? '',//
        'from': from ?? '',
        'page': page.toString(),
        'search': _searchText,
      });
      print(uri);
      http.Response response = await http.get(uri);
      return DriverDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        alert(context, 2, "Please check your internet connection.", "warning");
        return DriverDataModel.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return DriverDataModel.withError('Something went wrong.');
      }
    }
  }

  List<Map<String, dynamic>> listItemsGetter(DriverDataModel driverData) {
    List<Map<String, dynamic>> list = [];
    driverData.driverdatas.forEach((value) {
      list.add({
        "ititemid": (value['ititemid'] ?? '').toString(),
        "partname": (value['partname'] ?? '').toString(),
        "idqty": value['idqty'],
        "uomid": value['uomid'],
        "itdunitcost": value['itdunitcost'],
        "idtextcost": value['idtextcost'],
        "itdinvtrannbr": value['itdinvtrannbr'],
        "idtype": value['idtype'],
        "itdlinenbr": value['itdlinenbr'],
        "idaccess": value['idaccess'],
        "merk": value['merk'],
        "size": value['size'],
        "sntyre": value['sntyre'],
        "idrealqty": value['idrealqty'],
        "vhtid": value['vhtid'],
        "genuine_no": value['genuine_no'],
        "genuineno": value['genuineno'],
      });
    });
    return list;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  ButtonStyle _orangeBtnStyle({Color? bg}) {
    return ElevatedButton.styleFrom(
      elevation: 2,
      backgroundColor: bg ?? primaryOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget listItemBuilder(value, int index) {
    return Card(
      elevation: 4,
      color: cardColor,
      shadowColor: shadowColor,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: Color(0xFFFFF4E6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: primaryOrange),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value['ititemid'] ?? '-',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        value['partname'] ?? '-',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Column(
              children: [
                _infoRow('Qty', '${value['idqty'] ?? '-'}'),
                _infoRow('UOM', '${value['uomid'] ?? '-'}'),
                _infoRow('Type', '${value['idtype'] ?? '-'}'),
                _infoRow('Merk', '${value['merk'] ?? '-'}'),
                _infoRow('Size', '${value['size'] ?? '-'}'),
                _infoRow('Trx No', '${value['itdinvtrannbr'] ?? '-'}'),
                _infoRow('Line', '${value['itdlinenbr'] ?? '-'}'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 4, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit_outlined, size: 15),
                    label: Text('Select', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      globals.inv_ititemid = value['ititemid'];
                      globals.inv_partname = value['partname'];
                      globals.inv_idqty = value['idqty'];
                      globals.inv_uomid = value['uomid'];
                      globals.inv_itdunitcost = value['itdunitcost'];
                      globals.inv_idtextcost = value['idtextcost'];
                      globals.inv_itdinvtrannbr = value['itdinvtrannbr'];
                      globals.inv_idtype = value['idtype'];
                      globals.inv_idaccess = value['idaccess'];
                      globals.inv_merk = value['merk'];
                      globals.inv_sntyre = value['sntyre'];
                      globals.inv_idrealqty = value['idrealqty'];
                      globals.inv_itdlinenbr = value['itdlinenbr'];
                      globals.inv_vhtid = value['vhtid'];
                      globals.inv_genuine_no = value['genuine_no'];
                      globals.inv_method = "edit";
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FrmInventory(
                            invTrxStatusBarang: widget.invTrxStatusBarang,
                          ),
                        ),
                      );
                    },
                    style: _orangeBtnStyle(bg: accentOrange),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.delete_outline, size: 15),
                    label: Text('Delete', style: TextStyle(fontSize: 11)),
                    onPressed: () async {
                      await _deleteInventoryDetail(value);
                    },
                    style: _orangeBtnStyle(bg: Color(0xFFE07B39)),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.close, size: 15),
                    label: Text('Close', style: TextStyle(fontSize: 11)),
                    onPressed: () async {
                      await _closeInventoryDetail(value);
                    },
                    style: _orangeBtnStyle(bg: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(color: primaryOrange),
    );
  }

  Widget errorWidgetMaker(dynamic data, VoidCallback retry) {
    final driverDatas = data as DriverDataModel?;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(driverDatas?.errorMessage ?? "Something went wrong."),
        ),
        ElevatedButton(
          onPressed: retry,
          style: _orangeBtnStyle(),
          child: Text('Retry'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(dynamic data) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: accentOrange),
            SizedBox(height: 12),
            Text('Tidak ada data dalam list',
                style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  int totalPagesGetter(dynamic data) {
    return (data as DriverDataModel).total;
  }

  bool pageErrorChecker(dynamic data) {
    return (data as DriverDataModel).statusCode != 200;
  }

  Future<void> _deleteInventoryDetail(Map<String, dynamic> value) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Konfirmasi Hapus'),
        content: Text(
            'Hapus item ${value['itdinvtrannbr']} - ${value['ititemid']} - ${value['partname']} dari detail inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: _orangeBtnStyle(bg: Color(0xFFE07B39)),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _showLoader();
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString("name") ?? prefs.getString("loginname") ?? "";
      final itdinvtrannbr = (value['itdinvtrannbr'] ?? '').toString();
      final itdlinenbr = (value['itdlinenbr'] ?? '').toString();
      final ititemid = (value['ititemid'] ?? '').toString();

      if (itdinvtrannbr.isEmpty || itdlinenbr.isEmpty) {
        _hideLoader();
        alert(context, 0, "Data item tidak valid untuk dihapus", "error");
        return;
      }

      final uri = Uri.parse(
          "${GlobalData.baseUrl}api/inventory/delete_inv_detail.jsp");
      final response = await http.post(
        uri,
        body: {
          'method': 'delete-item-detail',
          'id': itdlinenbr,
          'itdinvtrannbr': itdinvtrannbr,
          'itemid': ititemid,
          'userid': userId,
        },
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName('utf-8'),
      );

      _hideLoader();

      if (response.statusCode != 200) {
        alert(context, 0, "Gagal menghapus item (${response.statusCode})",
            "error");
        return;
      }

      final decoded = json.decode(response.body);
      final status = decoded['status']?.toString().toLowerCase() ?? '';
      final message = decoded['message']?.toString() ?? 'Item gagal dihapus';

      if (status == 'success') {
        alert(context, 1, message, "success");
        _reloadList();
      } else {
        alert(context, 0, message, "error");
      }
    } catch (e) {
      _hideLoader();
      alert(context, 0, "Client, gagal menghapus item", "error");
      print(e.toString());
    }
  }

  Future<String> _fetchQtyOnHand(String itemId, String warehouseId) async {
    try {
      final uri = Uri.parse(
              '${GlobalData.baseUrl}api/inventory/update_inv_detail_realqty.jsp')
          .replace(queryParameters: {
        'method': 'get-qty-onhand',
        'itemid': itemId,
        'warehouseid': warehouseId,
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) return '0';
      final decoded = json.decode(response.body);
      if ((decoded['status']?.toString().toLowerCase() ?? '') == 'success') {
        return (decoded['qty_onhand'] ?? '0').toString();
      }
    } catch (_) {}
    return '0';
  }

  Future<void> _closeInventoryDetail(Map<String, dynamic> value) async {
    final trxType = (globals.inv_trx_type ?? '').toString().trim().toUpperCase();
    if (trxType == 'IS-M') {
      await _closeInventoryDetailWithActual(value);
    } else {
      await _closeInventoryDetailSimple(value);
    }
  }

  Future<void> _closeInventoryDetailSimple(Map<String, dynamic> value) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Konfirmasi Close'),
        content: Text(
            'Close item ${value['itdinvtrannbr']} - ${value['ititemid']}?\nItem tidak akan tampil lagi di list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: _orangeBtnStyle(),
            child: Text('Close'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      _showLoader();
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString("name") ?? prefs.getString("loginname") ?? "";
      final itdinvtrannbr = (value['itdinvtrannbr'] ?? '').toString();
      final itdlinenbr = (value['itdlinenbr'] ?? '').toString();

      if (itdinvtrannbr.isEmpty || itdlinenbr.isEmpty) {
        _hideLoader();
        alert(context, 0, "Data item tidak valid untuk di-close", "error");
        return;
      }

      final uri = Uri.parse(
          "${GlobalData.baseUrl}api/inventory/close_inv_detail_param.jsp");
      final response = await http.post(
        uri,
        body: {
          'method': 'close-item-detail',
          'itdinvtrannbr': itdinvtrannbr,
          'itdlinenbr': itdlinenbr,
          'userid': userId,
        },
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName('utf-8'),
      );

      _hideLoader();

      if (response.statusCode != 200) {
        alert(context, 0, "Gagal close item (${response.statusCode})", "error");
        return;
      }

      final decoded = json.decode(response.body);
      final status = decoded['status']?.toString().toLowerCase() ?? '';
      final message = decoded['message']?.toString() ?? 'Close item gagal';

      if (status == 'success') {
        alert(context, 1, message, "success");
        _reloadList();
      } else {
        alert(context, 0, message, "error");
      }
    } catch (e) {
      _hideLoader();
      alert(context, 0, "Client, gagal close item", "error");
      print(e.toString());
    }
  }

  Future<void> _closeInventoryDetailWithActual(
      Map<String, dynamic> value) async {
    final itdinvtrannbr = (value['itdinvtrannbr'] ?? '').toString();
    final itdlinenbr = (value['itdlinenbr'] ?? '').toString();
    final ititemid = (value['ititemid'] ?? '').toString();
    final warehouseId = (globals.from_ware_house ?? '').toString();

    if (itdinvtrannbr.isEmpty || itdlinenbr.isEmpty || ititemid.isEmpty) {
      alert(context, 0, "Data item tidak valid untuk di-close", "error");
      return;
    }
    if (warehouseId.isEmpty) {
      alert(context, 0, "Warehouse tidak ditemukan", "error");
      return;
    }

    _showLoader();
    final qtyOnHand = await _fetchQtyOnHand(ititemid, warehouseId);
    _hideLoader();

    final actualCtrl = TextEditingController(text: qtyOnHand);
    String? formError;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text('Close & Stock Actual'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${value['itdinvtrannbr']} - ${value['ititemid']}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${value['partname'] ?? ''}',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 12),
                    ),
                    SizedBox(height: 14),
                    Text('Qty On Books',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                    SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        qtyOnHand,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('Stock Actual',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                    SizedBox(height: 4),
                    TextField(
                      controller: actualCtrl,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Input stock actual',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: primaryOrange, width: 1.5),
                        ),
                      ),
                    ),
                    if (formError != null) ...[
                      SizedBox(height: 8),
                      Text(formError!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 12)),
                    ],
                    SizedBox(height: 8),
                    Text(
                      'Setelah disimpan, item tidak akan tampil lagi di list.',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final raw = actualCtrl.text.trim();
                    if (raw.isEmpty) {
                      setModalState(() {
                        formError = 'Stock Actual wajib diisi';
                      });
                      return;
                    }
                    if (double.tryParse(raw) == null) {
                      setModalState(() {
                        formError = 'Stock Actual harus angka';
                      });
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  style: _orangeBtnStyle(),
                  child: Text('Simpan & Close'),
                ),
              ],
            );
          },
        );
      },
    );

    final realQty = actualCtrl.text.trim();
    actualCtrl.dispose();

    if (confirmed != true) return;

    try {
      _showLoader();
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString("name") ?? prefs.getString("loginname") ?? "";

      // 1) Update ITDREALQTY
      final updateUri = Uri.parse(
          "${GlobalData.baseUrl}api/inventory/update_inv_detail_realqty.jsp");
      final updateRes = await http.post(
        updateUri,
        body: {
          'method': 'update-realqty',
          'itdinvtrannbr': itdinvtrannbr,
          'ititemid': ititemid,
          'itdlinenbr': itdlinenbr,
          'realqty': realQty,
          'userid': userId,
        },
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName('utf-8'),
      );

      if (updateRes.statusCode != 200) {
        _hideLoader();
        alert(context, 0,
            "Gagal update Stock Actual (${updateRes.statusCode})", "error");
        return;
      }

      final updateDecoded = json.decode(updateRes.body);
      final updateStatus =
          updateDecoded['status']?.toString().toLowerCase() ?? '';
      if (updateStatus != 'success') {
        _hideLoader();
        alert(
            context,
            0,
            updateDecoded['message']?.toString() ??
                'Update Stock Actual gagal',
            "error");
        return;
      }

      // 2) Close item (hide from list)
      final closeUri = Uri.parse(
          "${GlobalData.baseUrl}api/inventory/close_inv_detail_param.jsp");
      final closeRes = await http.post(
        closeUri,
        body: {
          'method': 'close-item-detail',
          'itdinvtrannbr': itdinvtrannbr,
          'itdlinenbr': itdlinenbr,
          'userid': userId,
        },
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName('utf-8'),
      );

      _hideLoader();

      if (closeRes.statusCode != 200) {
        alert(context, 0,
            "Stock Actual tersimpan, tapi gagal close (${closeRes.statusCode})",
            "error");
        return;
      }

      final closeDecoded = json.decode(closeRes.body);
      final closeStatus =
          closeDecoded['status']?.toString().toLowerCase() ?? '';
      final message = closeDecoded['message']?.toString() ?? 'Close item gagal';

      if (closeStatus == 'success') {
        alert(context, 1, "Stock Actual tersimpan. $message", "success");
        _reloadList();
      } else {
        alert(context, 0, message, "error");
      }
    } catch (e) {
      _hideLoader();
      alert(context, 0, "Client, gagal close item", "error");
      print(e.toString());
    }
  }

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );
  }

  void _hideLoader() {
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

class DriverDataModel {
  late List<dynamic> driverdatas;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  DriverDataModel.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    List jsonData = json.decode(response.body);
    driverdatas = jsonData[1] ?? [];
    total = ((jsonData[0] as Map)['total'] ?? 0) as int;
    nItems = driverdatas.length;
    errorMessage = '';
  }

  DriverDataModel.withError(String msg)
      : driverdatas = [],
        statusCode = 0,
        total = 0,
        nItems = 0,
        errorMessage = msg;
}
