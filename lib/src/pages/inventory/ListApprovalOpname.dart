import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dms_anp/src/widgets/simple_paginator.dart';

class ListApprovalOpname extends StatefulWidget {
  @override
  _ListApprovalOpnameState createState() => _ListApprovalOpnameState();
}

class _ListApprovalOpnameState extends State<ListApprovalOpname> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Approval Opname');

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
    if (EasyLoading.isShow) EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack(context);
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8A50),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        automaticallyImplyLeading: false,
        title: customSearchBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 20.0,
          onPressed: () => _goBack(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: customIcon,
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    onTap: () async {
                      if (_txtSearch.text.isEmpty) return;
                      _searchText = _txtSearch.text;
                      paginatorGlobalKey.currentState?.changeState(
                          pageLoadFuture: fetchApprovalOpname,
                          resetState: true);
                    },
                    leading: Icon(Icons.search, color: Colors.white, size: 28),
                    title: TextField(
                      controller: _txtSearch,
                      decoration: InputDecoration(
                        hintText: 'No. transaksi / search',
                        hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  _searchText = "";
                  _txtSearch.text = "";
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('List Approval Opname');
                }
              });
            },
          ),
        ],
      ),
      body: Paginator.listView(
        key: paginatorGlobalKey,
        pageLoadFuture: fetchApprovalOpname,
        pageItemsGetter: (data) =>
            listItemsGetter(data as ApprovalOpnameDataModel),
        listItemBuilder: listItemBuilder,
        loadingWidgetBuilder: loadingWidgetMaker,
        errorWidgetBuilder: errorWidgetMaker,
        emptyListWidgetBuilder: (data) =>
            emptyListWidgetMaker(data as ApprovalOpnameDataModel),
        totalItemsGetter: (data) =>
            totalPagesGetter(data as ApprovalOpnameDataModel),
        pageErrorChecker: (data) =>
            pageErrorChecker(data as ApprovalOpnameDataModel),
        scrollPhysics: BouncingScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _searchText = "";
            _txtSearch.text = "";
          });
          paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: fetchApprovalOpname, resetState: true);
        },
        child: Icon(Icons.refresh),
      ),
      ),
    );
  }

  static const int _pageSize = 10;

  Future<ApprovalOpnameDataModel> fetchApprovalOpname(int page) async {//
    try {
      var baseURL = '${GlobalData.baseUrl}api/inventory/list_approval_opname.jsp?method=list-approval-opname&page=$page&limit=$_pageSize&search=$_searchText';
      String url = Uri.encodeFull(baseURL);
      http.Response response = await http.get(Uri.parse(url));
      var result = ApprovalOpnameDataModel.fromResponse(response);
      if (EasyLoading.isShow) EasyLoading.dismiss();
      return result;
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      if (e is IOException) {
        alert(context, 2, "Periksa koneksi internet.", "warning");
        return ApprovalOpnameDataModel.withError('Periksa koneksi internet.');
      } else {
        alert(context, 2, "Terjadi kesalahan.", "warning");
        return ApprovalOpnameDataModel.withError('Terjadi kesalahan.');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetail(String wonumber) async {
    try {
      var baseURL = '${GlobalData.baseUrl}api/inventory/list_approval_opname.jsp?method=list-approval-opname-detail&wonumber=$wonumber';
      print(baseURL);
      var url = Uri.encodeFull(baseURL);
      http.Response response = await http.get(Uri.parse(url));
      List<dynamic> raw = json.decode(response.body) as List<dynamic>? ?? [];
      return raw.map((e) => Map<String, dynamic>.from(e is Map ? e : {})).toList();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> listItemsGetter(ApprovalOpnameDataModel data) {
    List<Map<String, dynamic>> list = [];
    for (var raw in data.items) {
      var m = raw is Map ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};
      list.add({
        "trx_no": m['_trx_no'],
        "vhcid": m['_vhcid'],
        "posisi": m['_posisi'],
        "wodnotes": m['_wodnotes'],//
      });
    }
    return list;
  }

  Widget listItemBuilder(value, int index) {
    final trxNo = value['trx_no']?.toString() ?? '-';
    final vhcid = value['vhcid']?.toString() ?? '-';
    final merk = value['wodnotes']?.toString() ?? '';
    final posisi = value['posisi']?.toString() ?? '';

    return _HeaderOpnameTile(
      trxNo: trxNo,
      vhcid: vhcid,
      wodnotes: merk,
      fetchDetail: fetchDetail,
      onCancel: (List<String> detailIds) async {
        if (detailIds.isEmpty) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString("name") ?? "";
        EasyLoading.show();
        try {
          int ok = 0;
          for (String id in detailIds) {
            final uri = Uri.parse(
                "${GlobalData.baseUrl}api/inventory/cancel_opname.jsp")
                .replace(queryParameters: {
              "method": "cancel-opname-detail",
              "id": id,
              "updated_user": username,
            });
            final res = await http.get(uri);
            if (res.statusCode == 200) {
              final body = json.decode(res.body) as Map<String, dynamic>?;
              if (body != null && body["status"] == "success") ok++;
            }
          }
          if (EasyLoading.isShow) EasyLoading.dismiss();
          if (ok == detailIds.length) {
            alert(context, 1, "Cancel success", "success");
          } else {
            alert(context, 0, "Cancel failed ($ok/${detailIds.length})", "error");
          }
          paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: fetchApprovalOpname, resetState: true);
        } catch (e) {
          if (EasyLoading.isShow) EasyLoading.dismiss();
          alert(context, 0, "Error: $e", "error");
        }
      },
      onApproved: (List<String> detailIds) async {
        if (detailIds.isEmpty) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String username = prefs.getString("name") ?? "";
        EasyLoading.show();
        try {
          int ok = 0;
          for (String id in detailIds) {
            final uri = Uri.parse(
                "${GlobalData.baseUrl}api/inventory/approve_opname.jsp")//
                .replace(queryParameters: {
              "method": "approve-opname-detail",
              "id": id,
              "apv_user": username,
            });
            final res = await http.get(uri);
            if (res.statusCode == 200) {
              final body = json.decode(res.body) as Map<String, dynamic>?;
              if (body != null && body["status"] == "success") ok++;
            }
          }
          if (EasyLoading.isShow) EasyLoading.dismiss();
          if (ok == detailIds.length) {
            alert(context, 1, "Approved success", "success");
          } else {
            alert(context, 0, "Approved failed ($ok/${detailIds.length})", "error");
          }
          paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: fetchApprovalOpname, resetState: true);
        } catch (e) {
          if (EasyLoading.isShow) EasyLoading.dismiss();
          alert(context, 0, "Error: $e", "error");
        }
      },
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetMaker(
      dynamic model, VoidCallback retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(model?.errorMessage ?? "Terjadi kesalahan."),
        ),
        TextButton(
          onPressed: retryListener,
          child: Text('Coba lagi'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(ApprovalOpnameDataModel model) {
    return Center(
      child: Text('Tidak ada data approval opname'),
    );
  }

  int totalPagesGetter(ApprovalOpnameDataModel model) {
    return model.total;
  }

  bool pageErrorChecker(ApprovalOpnameDataModel model) {
    return model.statusCode != 200;
  }
}

class _HeaderOpnameTile extends StatefulWidget {
  final String trxNo;
  final String vhcid;
  final String wodnotes;
  final Future<List<Map<String, dynamic>>> Function(String) fetchDetail;
  final void Function(List<String> detailIds) onApproved;
  final void Function(List<String> detailIds) onCancel;

  const _HeaderOpnameTile({
    required this.trxNo,
    required this.vhcid,
    required this.wodnotes,
    required this.fetchDetail,
    required this.onApproved,
    required this.onCancel,
  });

  @override
  State<_HeaderOpnameTile> createState() => _HeaderOpnameTileState();
}

class _HeaderOpnameTileState extends State<_HeaderOpnameTile> {
  bool _expanded = false;
  bool _loading = false;
  List<Map<String, dynamic>> _details = [];

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label :", style: const TextStyle(color: Colors.black, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showConfirm(BuildContext context, String title, String message, VoidCallback onYes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onYes();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleExpand() async {
    if (widget.trxNo.isEmpty || widget.trxNo == '-') return;
    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }
    setState(() => _loading = true);
    final list = await widget.fetchDetail(widget.trxNo);
    if (mounted) {
      setState(() {
        _details = list;
        _loading = false;
        _expanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trxNo,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Unit: ${widget.vhcid}",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        if (widget.wodnotes.isNotEmpty)
                          Text(
                            "Catatan: ${widget.wodnotes}",
                            style: TextStyle(
                                color: Colors.black87, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: SizedBox(//
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          if (_expanded && !_loading && _details.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(color: Color.fromRGBO(250, 250, 252, 1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _details.map((d) {
                  final id = d['_id']?.toString() ?? '';
                  final part = (d['_partname'] ?? '').toString();
                  final qty = (d['_qty'] ?? '').toString();
                  //final note = (d['_wodnotes'] ?? '').toString();
                  final merk = (d['_wodnotes'] ?? '').toString();
                  final posisi = (d['_posisi'] ?? '').toString();
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv("Part", part),
                        _kv("Qty", qty),
                        _kv("Merk", merk),
                        _kv("Posisi", posisi),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.cancel, size: 16, color: Colors.white),
                              label: Text("Cancel", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              onPressed: () => _showConfirm(context, "Cancel", "Batalkan untuk part ini?", () {
                              print('Cancel id: $id');
                              widget.onCancel([id]);
                            }),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.grey[600],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.check_circle, color: Colors.white, size: 16),
                              label: Text("Approved", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              onPressed: id.isEmpty
                                ? null
                                : () => _showConfirm(context, "Approved", "Approve part ini?", () {
                                    print('Approved id: $id');
                                    widget.onApproved([id]);
                                  }),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class ApprovalOpnameDataModel {
  late List<dynamic> items;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  ApprovalOpnameDataModel.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    try {
      List jsonData = json.decode(response.body);
      items = jsonData.length > 1 ? (jsonData[1] ?? []) : [];
      total = jsonData.isNotEmpty && jsonData[0] is Map
          ? ((jsonData[0] as Map)['total'] ?? 0) as int
          : 0;
    } catch (_) {
      items = [];
      total = 0;
    }
    nItems = items.length;
    errorMessage = '';
  }

  ApprovalOpnameDataModel.withError(String msg)
      : items = [],
        statusCode = 0,
        total = 0,
        nItems = 0,
        errorMessage = msg;
}
