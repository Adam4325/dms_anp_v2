import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/po/PoDetail.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/pages/po/ViewDetailApproved.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../flusbar.dart';

// Warna tema soft orange pastel
final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
final Color accentOrange = Color(0xFFFFB347); // Peach orange
final Color darkOrange = Color(0xFFE07B39); // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
final Color cardColor = Color(0xFFFFF8F0); // Light cream
final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow

class PoHeaderPage extends StatefulWidget {
  PoHeaderPage({Key? key}) : super(key: key);

  @override
  _PoHeaderPageState createState() => _PoHeaderPageState();
}

class _PoHeaderPageState extends State<PoHeaderPage> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List poList = []; //
  bool isLoading = true;
  String searchQuery = '';
  List poApprovedList = [];
  bool isLoadingApproved = true;
  String searchApprovedQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPoData('');
    fetchPoApprovedData('');
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<void> fetchPoData(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    setState(() {
      isLoading = true;
    });
    final hasAksesPO = globals.akses_pages != null &&
        globals.akses_pages.where((x) => x == "PO").isNotEmpty;
    if ((hasAksesPO && username == "ADMIN") ||
        (hasAksesPO && username == "BUDI") ||
        (hasAksesPO && username == "ETIENNE")) {
      try {
        var baseUrl = GlobalData.baseUrl +
            'api/po/po_header.jsp?method=list-po-header&search=$search';
        print("po_header");
        print(baseUrl);
        var url = Uri.parse(baseUrl);
        var res = await http.get(url);

        if (res.statusCode == 200) {
          setState(() {
            poList = json.decode(res.body);
            isLoading = false;
          });
        } else {
          throw Exception("Failed to load data");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PO Number",
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
          filled: true,
          fillColor: lightOrange,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: primaryOrange),
        ),
        onChanged: (val) {
          searchQuery = val;
          fetchPoData(searchQuery);
        },
      ),
    );
  }

  Future<void> fetchPoApprovedData(String search) async {
    setState(() {
      isLoadingApproved = true;
    });
    try {
      var baseUrl = GlobalData.baseUrl +
          'api/po/list_approved_po.jsp?method=list-po' +
          (search.isNotEmpty ? '&search=$search' : '');
      print(baseUrl);
      var url = Uri.parse(baseUrl);
      var res = await http.get(url);
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body is Map &&
            (body['status_code'] == '200' || body['status_code'] == 200)) {
          setState(() {
            poApprovedList = body['data'] ?? [];
            isLoadingApproved = false;
          });
        } else {
          setState(() {
            poApprovedList = [];
            isLoadingApproved = false;
          });
        }
      } else {
        throw Exception("Failed to load approved data");
      }
    } catch (e) {
      setState(() {
        isLoadingApproved = false;
      });
    }
  }

  Widget buildSearchFieldApproved() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PO Approved",
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
          filled: true,
          fillColor: lightOrange,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: primaryOrange),
        ),
        onChanged: (val) {
          searchApprovedQuery = val;
          () async {
            if (!EasyLoading.isShow) {
              EasyLoading.show();
            }
            await fetchPoApprovedData(searchApprovedQuery);
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
          }();
        },
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
      child: DefaultTabController(
        key: globalScaffoldKey,
        length: 2,
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                _goBack(context);
              },
            ),
            title: Text("Outstanding PO",
                style: TextStyle(fontWeight: FontWeight.bold)),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              onTap: (index) async {
                if (index == 1) {
                  if (!EasyLoading.isShow) {
                    EasyLoading.show();
                  }
                  await fetchPoApprovedData(searchApprovedQuery);
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                }
              },
              tabs: [
                Tab(text: 'Outstanding'),
                Tab(text: 'PO Approved'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: <Widget>[
                  buildSearchField(),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child:
                                CircularProgressIndicator(color: primaryOrange))
                        : poList.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                itemCount: poList.length,
                                itemBuilder: (context, index) {
                                  var po = poList[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shadowColor,
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      title: Text(
                                        po['ponbr'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkOrange,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                "Vendor: ${po['vendorid'] ?? ''}",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87)),
                                            SizedBox(height: 2),
                                            Text(
                                                "Warehouse: ${po['towarehouse'] ?? ''}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.grey.shade600)),
                                            Text(po['podate'] ?? '',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87)),
                                            SizedBox(height: 2),
                                            Text(
                                                "Status: ${po['postatus'] ?? ''}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87)),
                                            SizedBox(height: 2),
                                            Text("Type: ${po['typepo'] ?? ''}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87)),
                                            SizedBox(height: 2),
                                            Text("Loc: ${po['locid'] ?? ''}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87)),
                                            SizedBox(height: 2),
                                            Text(//
                                                po['ponotes'] ??
                                                    po['notes'] ??
                                                    '',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87)),
                                            SizedBox(height: 2),
                                          ],
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentOrange,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(6)),//
                                        ),
                                        onPressed: () {
                                          if (!EasyLoading.isShow) {
                                            EasyLoading.show();
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PoDetail(ponbr: po['ponbr']),
                                            ),
                                          );
                                        },
                                        child: Text("Detail",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  buildSearchFieldApproved(),
                  Expanded(
                    child: isLoadingApproved
                        ? Center(
                            child:
                                CircularProgressIndicator(color: primaryOrange))
                        : poApprovedList.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                itemCount: poApprovedList.length,
                                itemBuilder: (context, index) {
                                  var po = poApprovedList[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shadowColor,
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      title: Text(
                                        po['ponbr'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkOrange,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _kv("Warehouse", (po['towarehouse'] ?? '').toString()),
                                            _kv("Po Date", (po['podate'] ?? '').toString()),
                                            _kv("Vendor ID", (po['vendorid'] ?? '').toString()),
                                            _kv("Po Notes", (po['ponotes'] ?? '').toString()),
                                            _kv("Notes", (po['notes'] ?? '').toString()),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: accentOrange,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(6)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ViewDetailApproved(ponbr: po['ponbr'].toString()),
                                                      ),
                                                    );
                                                  },
                                                  child: Text("Detail",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                                SizedBox(width: 8),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.deepOrange,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(6)),
                                                  ),
                                                  onPressed: () async {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: Text('Konfirmasi'),
                                                        content: Text(
                                                            'Approve PO ${po['ponbr']}?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(ctx),
                                                            child: Text('Batal'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              Navigator.pop(ctx);
                                                              if (!EasyLoading.isShow) {
                                                                EasyLoading.show();
                                                              }
                                                              try {
                                                                final uri = Uri.parse(
                                                                    GlobalData.baseUrl +
                                                                        'api/po/approved_po.jsp?method=approve-po&ponbr=${po['ponbr']}');
                                                                final res = await http
                                                                    .get(uri)
                                                                    .timeout(Duration(seconds: 30));
                                                                if (res.statusCode == 200) {
                                                                  final body = json.decode(res.body);
                                                                  final code = body is Map ? body['status_code'] : null;
                                                                  final msg = body is Map ? (body['message']?.toString() ?? '') : '';
                                                                  if (code == '200' || code == 200) {
                                                                    alert(
                                                                        globalScaffoldKey.currentContext!,
                                                                        1,
                                                                        msg.isNotEmpty ? msg : 'PO berhasil di-approve',
                                                                        'success');
                                                                    await fetchPoApprovedData(searchApprovedQuery);
                                                                    await fetchPoData(searchQuery);
                                                                  } else {
                                                                    alert(
                                                                        globalScaffoldKey.currentContext!,
                                                                        0,
                                                                        msg.isNotEmpty ? msg : 'Gagal approve PO',
                                                                        'error');
                                                                  }
                                                                } else {
                                                                  alert(
                                                                      globalScaffoldKey.currentContext!,
                                                                      0,
                                                                      'Server error: ${res.statusCode}',
                                                                      'error');
                                                                }
                                                              } catch (e) {
                                                                alert(
                                                                    globalScaffoldKey.currentContext!,
                                                                    2,
                                                                    'Please check your internet connection.',
                                                                    'warning');
                                                              } finally {
                                                                if (EasyLoading.isShow) {
                                                                  EasyLoading.dismiss();
                                                                }
                                                              }
                                                            },
                                                            child: Text('Approve'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Text("Approved",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FrmPoHeader extends StatefulWidget {
  final Map<String, dynamic> po;
  const FrmPoHeader({Key? key, required this.po}) : super(key: key);
  @override
  State<FrmPoHeader> createState() => _FrmPoHeaderState();
}

Widget _kv(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
        const SizedBox(
          width: 10,
          child: Text(
            ":",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _FrmPoHeaderState extends State<FrmPoHeader> {
  final TextEditingController txtPonbr = TextEditingController();
  final TextEditingController txtPodate = TextEditingController();
  final TextEditingController txtPembayaran = TextEditingController();
  final TextEditingController txtNotes = TextEditingController();
  String selVendor = "[select]";
  List<String> vendorItems = ["[select]"];
  String selWarehouse = "";
  String selTypePo = "INVENTORY";

  @override
  void initState() {
    super.initState();
    txtPonbr.text = widget.po['ponbr']?.toString() ?? '';
    final podate = widget.po['podate']?.toString() ?? _formatDate(DateTime.now());
    txtPodate.text = podate;
    txtPembayaran.text = widget.po['pembayaran']?.toString() ?? '';
    txtNotes.text = widget.po['notes']?.toString() ?? '';
    selVendor = widget.po['vendorid']?.toString() ?? "[select]";
    if (selVendor != "[select]" && !vendorItems.contains(selVendor)) {
      vendorItems = ["[select]", selVendor];
    }
    selWarehouse = widget.po['towarehouse']?.toString() ?? "";
    selTypePo = widget.po['typepo']?.toString().isNotEmpty == true
        ? widget.po['typepo'].toString()
        : "INVENTORY";
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "$y-$m-$dd";
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      setState(() {
        txtPodate.text = _formatDate(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: Text("FrmPoHeader"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, 4))],
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildRowField("Purchase Order Number", _buildReadonly(txtPonbr, "* Auto Generate")),
              SizedBox(height: 10),
              _buildRowField("Purchase Order Date", _buildDate(txtPodate)),
              SizedBox(height: 10),
              _buildRowField("Vendor", _buildDropdown(
                value: selVendor,
                items: vendorItems,
                onChanged: (v) => setState(() => selVendor = v ?? selVendor),
                trailing: Material(
                  color: accentOrange,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FrmMasterVendor()),
                      );
                      if (res != null && res is String && res.isNotEmpty) {
                        setState(() {
                          selVendor = res;
                          if (!vendorItems.contains(res)) {
                            vendorItems = ["[select]", res];
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Center(child: Text("Add Vendor", style: TextStyle(color: Colors.white, fontSize: 12))),
                    ),
                  ),
                ),
              )),
              SizedBox(height: 10),
              _buildRowField("To Warehouse", _buildDropdown(
                value: selWarehouse.isEmpty ? "" : selWarehouse,
                items: [""],
                onChanged: (v) => setState(() => selWarehouse = v ?? selWarehouse),
              )),
              SizedBox(height: 10),
              _buildRowField("Type Po", _buildDropdown(
                value: selTypePo,
                items: [
                  "INVENTORY","OPEX","CAPEX","INVESTASI","STOCK","BK","RND","MATERIAL"
                ],
                onChanged: (v) => setState(() => selTypePo = v ?? selTypePo),
              )),
              SizedBox(height: 10),
              _buildRowField("Pembayaran", _buildNumber(txtPembayaran)),
              SizedBox(height: 10),
              _buildRowField("Notes", _buildSingleLine(txtNotes)),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PoDetail(ponbr: txtPonbr.text)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Transaction Detail"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(6)),//
                    ),
                    child: Text("PO Approve"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowField(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        Expanded(child: field),
      ],
    );
  }

  Widget _buildReadonly(TextEditingController c, String helper) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: c,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(helper, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDate(TextEditingController c) {
    return TextField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        suffixIcon: IconButton(icon: Icon(Icons.date_range, color: primaryOrange), onPressed: _pickDate),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(//
            initialValue: items.contains(value) ? value : null,
            items: items
                .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e.isEmpty ? "" : e),
                    ))
                .toList(),
            onChanged: onChanged,
            isDense: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 110, height: 36),
            child: trailing,
          ),
        ]
      ],
    );
  }

  Widget _buildNumber(TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }//

  Widget _buildSingleLine(TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}

class FrmMasterVendor extends StatefulWidget {
  const FrmMasterVendor({Key? key}) : super(key: key);
  @override
  State<FrmMasterVendor> createState() => _FrmMasterVendorState();
}

class _FrmMasterVendorState extends State<FrmMasterVendor> {
  final TextEditingController txtVendorId = TextEditingController();
  final TextEditingController txtNamaVendor = TextEditingController();
  final TextEditingController txtAlamatVendor = TextEditingController();
  final TextEditingController txtContactPerson = TextEditingController();
  final TextEditingController txtTelp = TextEditingController();
  String selStatus = "Non Active";

  @override
  void initState() {
    super.initState();
    txtVendorId.text = "";
    txtNamaVendor.text = "";
    txtAlamatVendor.text = "";
    txtContactPerson.text = "";
    txtTelp.text = "";
    selStatus = "Non Active";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: Text("FrmMasterVendor"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, 4))],
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildRowField("ID Vendor", _buildReadonly(txtVendorId, "* Auto Generate")),
              SizedBox(height: 10),
              _buildRowField("Nama Vendor", _buildSingleLine(txtNamaVendor)),
              SizedBox(height: 10),
              _buildRowField("Address Vendor", _buildSingleLine(txtAlamatVendor)),
              SizedBox(height: 10),
              _buildRowField("Contact Person", _buildSingleLine(txtContactPerson)),
              SizedBox(height: 10),
              _buildRowField("Tlp", _buildSingleLine(txtTelp)),//
              SizedBox(height: 10),
              _buildRowField("Status", _buildDropdown(
                value: selStatus,
                items: ["Active", "Non Active"],
                onChanged: (v) => setState(() => selStatus = v ?? selStatus),
              )),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("View Report"),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, txtVendorId.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Select"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Add"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowField(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        Expanded(child: field),
      ],
    );
  }

  Widget _buildReadonly(TextEditingController c, String helper) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: c,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(helper, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildSingleLine(TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : null,
            items: items
                .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e.isEmpty ? "" : e),
                    ))
                .toList(),
            onChanged: onChanged,
            isDense: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 110, height: 36),
            child: trailing,
          ),
        ]
      ],
    );
  }
}
