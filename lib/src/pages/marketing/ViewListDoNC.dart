import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class ViewListDoNC extends StatefulWidget {
  const ViewListDoNC({super.key});
  @override
  State<ViewListDoNC> createState() => _ViewListDoNCState();
}

class _ViewListDoNCState extends State<ViewListDoNC> {
  // Design Tokens (design_list.md)
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> items = [];
  bool loading = false;
  int page = 1;
  final int limit = 20;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData({int? toPage}) async {
    setState(() => loading = true);
    final int p = toPage ?? page;
    final String search = searchController.text.trim();
    final String url =
        "${GlobalData.baseUrl}api/marketing/list_do_nc.jsp?method=list"
        "${search.isNotEmpty ? "&search=${Uri.encodeComponent(search)}" : ""}"
        "&page=$p&limit=$limit";
    try {
      if (!EasyLoading.isShow) EasyLoading.show();
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        final List<dynamic> list = data["data"] ?? [];
        items = list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        page = data["page"] is int ? data["page"] : p;
        totalPages = data["totalPages"] is int ? data["totalPages"] : 1;
      } else {
        items = [];
      }
    } catch (_) {
      items = [];
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String _s(dynamic v) {
    if (v == null) return '-';
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null' || s == 'NULL') return '-';
    return s;
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(100),
          1: FixedColumnWidth(12),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              cursorColor: primaryOrange,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: primaryOrange, size: 20),
                hintText: "Cari Nomor/PO/Customer...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentOrange.withValues(alpha: 0.35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentOrange.withValues(alpha: 0.35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryOrange, width: 1.5),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          fetchData(toPage: 1);
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => fetchData(toPage: 1),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => fetchData(toPage: 1),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget buildItem(Map<String, dynamic> item) {
    final status = _s(item['dlostatus']);
    final isOpen = status.toUpperCase() == 'OPEN';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentOrange.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: darkOrange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _s(item['nomodo']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkOrange,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (status != '-')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOpen ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isOpen ? const Color(0xFFFFB74D) : const Color(0xFF81C784),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isOpen ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv("PO", _s(item['no_po'])),
                _kv("Tanggal", _s(item['dlodate'])),
                _kv("Customer", _s(item['dlocustomer'])),
                _kv("Item Type", _s(item['dloitemtype'])),
                _kv("Qty", "${_s(item['dloitemqty'])} ${_s(item['dloitemuom']) != '-' ? _s(item['dloitemuom']) : ''}".trim()),
                _kv("Locid", _s(item['locid'])),
                _kv("VHCID", _s(item['vhcid'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPager() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: page > 1 && !loading ? () => fetchData(toPage: page - 1) : null,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
            label: const Text("Prev", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Text(
            "Page $page / $totalPages",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          ElevatedButton.icon(
            onPressed: page < totalPages && !loading ? () => fetchData(toPage: page + 1) : null,
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            label: const Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          "View List DO NC",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: loading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: primaryOrange),
                  ))
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text("Tidak ada data", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) => buildItem(items[index]),
                      ),
          ),
          buildPager(),
        ],
      ),
    );
  }
}
