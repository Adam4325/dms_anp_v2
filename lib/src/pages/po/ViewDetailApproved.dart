import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ViewDetailApproved extends StatefulWidget {
  final String ponbr;
  const ViewDetailApproved({Key? key, required this.ponbr}) : super(key: key);
  @override
  State<ViewDetailApproved> createState() => _ViewDetailApprovedState();
}

class _ViewDetailApprovedState extends State<ViewDetailApproved> {
  List<dynamic> items = [];
  List<dynamic> viewItems = [];
  bool loading = true;
  String? error;
  final TextEditingController _searchCtrl = TextEditingController();
  final NumberFormat _idrFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  String _rupiah(dynamic v) {
    final s = (v ?? '').toString();
    final n = num.tryParse(s.replaceAll(',', ''));
    return n == null ? 'Rp $s' : _idrFmt.format(n);
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final url = Uri.parse(GlobalData.baseUrl + "api/po/list_detail_po_approval.jsp?ponbr=${widget.ponbr}&method=list-view-approved");//
      final resp = await http.get(url, headers: {"Accept": "application/json"});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          items = (data is List) ? data : [];
          viewItems = List<dynamic>.from(items);
          loading = false;
        });
      } else {
        setState(() {
          error = "Server ${resp.statusCode}";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _applyFilter(String q) {
    final qq = q.trim().toLowerCase();
    setState(() {
      if (qq.isEmpty) {
        viewItems = List<dynamic>.from(items);
      } else {
        viewItems = items.where((e) {
          final it = e as Map<String, dynamic>;
          final a = (it['PARTNAME'] ?? '').toString().toLowerCase();
          final b = (it['ITDITEMID'] ?? '').toString().toLowerCase();
          final c = (it['MERK'] ?? '').toString().toLowerCase();
          return a.contains(qq) || b.contains(qq) || c.contains(qq);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE6E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C69),
        foregroundColor: Colors.white,
        title: Text("List PO Approved ${widget.ponbr}",style: TextStyle(fontSize: 16)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.black87)))
              : SafeArea(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _applyFilter,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            labelText: 'Search',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            suffixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                          itemCount: viewItems.length,
                          itemBuilder: (context, index) {
                            final it = viewItems[index] as Map<String, dynamic>;
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    color: const Color(0xFFFFE8D6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      (it['PARTNAME'] ?? '').toString(),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _kv("PB Nbr", (it['PBNBR'] ?? '').toString()),
                                        _kv("Item ID", (it['ITDITEMID'] ?? '').toString()),
                                        _kv("Merk", (it['MERK'] ?? '').toString()),
                                        _kv("Type", (it['IDTYPE'] ?? '').toString()),
                                        _kv("Access", (it['IDACCESS'] ?? '').toString()),
                                        _kv("UOM", (it['UOMID'] ?? '').toString()),
                                        _kv("Qty", (it['ITDQTY'] ?? '').toString()),
                                        _kv("Unit Cost", _rupiah(it['ITDUNITCOST'])),
                                        _kv("Ext. Cost", _rupiah(it['ITDEXTCOST'])),
                                        _kv("Ext. After Disc", _rupiah(it['ITDEXTCOSTAFTERDISCOUNT'])),
                                        //_kv("Real Harga", _rupiah(it['REALHARGA'])),
                                        _kv("Loc", (it['LOCID'] ?? '').toString()),
                                        _kv("Status", (it['STATUS'] ?? '').toString()),
                                        const SizedBox(height: 6),
                                        _kv("PO Line", (it['POLINENBR'] ?? '').toString()),
                                        _kv("PB Line", (it['PBLINENBR'] ?? '').toString()),

                                      ],
                                    ),
                                  ),
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
                                    onPressed: () {
                                      final merk = (it['MERK'] ?? '').toString();
                                      final partname = (it['PARTNAME'] ?? '').toString();
                                      _showHargaDialog(partname, merk);
                                    },
                                    child: Text("Cek Harga Barang",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.w500)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          // Titik dua
          const SizedBox(
            width: 10, // jarak tetap
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
          // Value
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showHargaDialog(String partname, String merk) async {
    try {
      final uri = Uri.parse(
          "https://apps.tuluatas.com/trucking/mobile/api/po/list_cek_harga.jsp?method=cek-harga-barang&partname=${Uri.encodeComponent(partname)}&merk=${Uri.encodeComponent(merk)}");
      final res = await http.get(uri).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = (body is Map && body['data'] is List) ? (body['data'] as List) : const [];
        showDialog(
          context: context,
          builder: (ctx) {
            final size = MediaQuery.of(ctx).size;
            return Dialog(
              insetPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C69),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cek Harga Barang",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: size.height * 0.6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final m = list[i] as Map<String, dynamic>;
                          final c4 = _rupiah(m['COL_4']);
                          final c13 = _rupiah(m['COL_13']);
                          final c12 = _rupiah(m['COL_12']);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _kv("COL_0", (m['COL_0'] ?? '').toString()),
                                _kv("COL_1", (m['COL_1'] ?? '').toString()),//
                                _kv("COL_2", (m['COL_2'] ?? '').toString()),
                                _kv("COL_3", (m['COL_3'] ?? '').toString()),
                                _kv("COL_4", c4),
                                _kv("COL_5", (m['COL_5'] ?? '').toString()),
                                _kv("COL_6", (m['COL_6'] ?? '').toString()),
                                _kv("COL_7", (m['COL_7'] ?? '').toString()),
                                _kv("COL_8", (m['COL_8'] ?? '').toString()),
                                _kv("COL_9", (m['COL_9'] ?? '').toString()),
                                _kv("COL_10", (m['COL_10'] ?? '').toString()),
                                _kv("COL_11", (m['COL_11'] ?? '').toString()),
                                _kv("COL_13", c13),
                                _kv("COL_12", c12),
                                _kv("COL_14", (m['COL_14'] ?? '').toString()),
                                _kv("COL_15", (m['COL_15'] ?? '').toString()),
                                _kv("COL_16", (m['COL_16'] ?? '').toString()),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text("Tutup"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Server error: ${res.statusCode}"),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Tutup"))
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Tutup"))
          ],
        ),
      );
    }
  }
}
