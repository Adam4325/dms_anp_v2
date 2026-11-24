import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PbViewDetailApproved extends StatefulWidget {
  final String pbnbr;
  const PbViewDetailApproved({Key? key, required this.pbnbr}) : super(key: key);
  @override
  State<PbViewDetailApproved> createState() => _PbViewDetailApprovedState();
}

class _PbViewDetailApprovedState extends State<PbViewDetailApproved> {
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
      var baseURL = GlobalData.baseUrl + "api/pb/list_detail_pb_approval.jsp?pbnbr=${widget.pbnbr}&method=list-view-approved";
      print(baseURL);
      final url = Uri.parse(baseURL);//
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
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xFFFF8C69),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "List PB Approved ${widget.pbnbr}",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8C69)))
          : (error != null
              ? Center(
                  child: Text(error!,
                      style: const TextStyle(color: Colors.black87)))
              : SafeArea(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _applyFilter,
                          cursorColor: const Color(0xFFFF8C69),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFF4E6),
                            isDense: true,
                            hintText: 'Cari part name / merk / item id...',
                            hintStyle: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFFFF8C69), size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _applyFilter('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0x59FFB347), width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0x59FFB347), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFFF8C69), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 24),
                          itemCount: viewItems.length,
                          itemBuilder: (context, index) {
                            final it = viewItems[index] as Map<String, dynamic>;
                            final partname =
                                (it['PARTNAME'] ?? '').toString();
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8F0),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0x59FFB347), width: 0.8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x20FF8C69),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF4E6),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        topRight: Radius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      partname.isNotEmpty
                                          ? partname
                                          : 'Item ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE07B39),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _kv("PB Nbr",
                                            (it['PBNBR'] ?? '').toString()),
                                        _kv("Item ID",
                                            (it['ITDITEMID'] ?? '').toString()),
                                        _kv("Merk",
                                            (it['MERK'] ?? '').toString()),
                                        _kv("Type",
                                            (it['IDTYPE'] ?? '').toString()),
                                        _kv("Access",
                                            (it['IDACCESS'] ?? '').toString()),
                                        _kv("UOM",
                                            (it['UOMID'] ?? '').toString()),
                                        _kv("Qty",
                                            (it['ITDQTY'] ?? '').toString()),
                                        _kv("Unit Cost",
                                            _rupiah(it['ITDUNITCOST'])),
                                        _kv("Ext. Cost",
                                            _rupiah(it['ITDEXTCOST'])),
                                        _kv(
                                            "Ext. After Disc",
                                            _rupiah(
                                                it['ITDEXTCOSTAFTERDISCOUNT'])),
                                        _kv("Loc",
                                            (it['LOCID'] ?? '').toString()),
                                        _kv("Status",
                                            (it['STATUS'] ?? '').toString()),
                                        _kv(
                                            "PB Line",
                                            (it['PBLINENBR'] ??
                                                    it['POLINENBR'] ??
                                                    '')
                                                .toString()),
                                        const SizedBox(height: 10),
                                        const Divider(
                                            height: 1,
                                            color: Color(0x25FF8C69)),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.search,
                                              size: 16, color: Colors.white),
                                          label: const Text("Cek Harga Barang",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFF8C69),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          onPressed: () {
                                            final merk =
                                                (it['MERK'] ?? '').toString();
                                            final partname =
                                                (it['PARTNAME'] ?? '')
                                                    .toString();
                                            _showHargaDialog(partname, merk);
                                          },
                                        ),
                                      ],
                                    ),
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
    if (value.trim().isEmpty || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            width: 10,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showHargaDialog(String partname, String merk) async {//
    try {
      var baseURL = GlobalData.baseUrl + "api/pb/list_cek_harga.jsp?method=cek-harga-barang&partname=${Uri.encodeComponent(partname)}&merk=${Uri.encodeComponent(merk)}";
      final uri = Uri.parse(baseURL);
      print(baseURL);
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
                          final hargaSatuan = _rupiah(m['HARGASATUAN']);
                          final unitCost = _rupiah(m['ITDUNITCOST']);
                          final extCost = _rupiah(m['ITDEXTCOST']);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (list.length > 1 && i > 0)
                                Container(
                                  height: 1,
                                  color: const Color(0xFFE0E0E0),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _kv("pbnbr", (m['pbnbr'] ?? '').toString()),
                                    _kv("PARTNAME", (m['PARTNAME'] ?? '').toString()),
                                    _kv("MERK", (m['MERK'] ?? '').toString()),
                                    _kv("IDTYPE", (m['IDTYPE'] ?? '').toString()),
                                    _kv("ITDITEMID", (m['ITDITEMID'] ?? '').toString()),
                                    _kv("IDACCESS", (m['IDACCESS'] ?? '').toString()),
                                    _kv("UOMID", (m['UOMID'] ?? '').toString()),
                                    _kv("HARGASATUAN", hargaSatuan),
                                    _kv("ITDUNITCOST", unitCost),
                                    _kv("ITDEXTCOST", extCost),
                                    _kv("TGL", (m['TGL'] ?? '').toString()),
                                    _kv("CPYNAME", (m['CPYNAME'] ?? '').toString()),
                                    _kv("CPYPHONE1", (m['CPYPHONE1'] ?? '').toString()),
                                    _kv("SIZEA", (m['SIZEA'] ?? '').toString()),
                                    _kv("TYPETRUCK", (m['TYPETRUCK'] ?? '').toString()),
                                  ],
                                ),
                              ),
                            ],
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
