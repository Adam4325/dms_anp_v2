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
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

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

  Future<void> fetchData({int? toPage}) async {
    setState(() => loading = true);
    final int p = toPage ?? page;
    final String search = searchController.text.trim();
    final String url =
        "${GlobalData.baseUrl}api/marketing/list_do_non_mp.jsp?method=list"
        "${search.isNotEmpty ? "&search=${Uri.encodeComponent(search)}" : ""}"
        "&page=$p&limit=$limit";
    print(url);
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
      setState(() => loading = false);
    }
  }

  Widget buildHeader() {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "Cari Nomor/PO/Customer",
            filled: true,
            fillColor: lightOrange,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => fetchData(toPage: 1),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => fetchData(toPage: 1),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text("Search", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  searchController.clear();
                  fetchData(toPage: 1);
                },
                icon: const Icon(Icons.clear, color: Colors.white),
                label: const Text("Reset", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: darkOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['nomodo']?.toString() ?? "-",
                    style: TextStyle(fontWeight: FontWeight.bold, color: darkOrange, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    item['dlostatus']?.toString() ?? "-",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [const Text("PO: "), Expanded(child: Text(item['no_po']?.toString() ?? "-"))]),
            Row(children: [const Text("Tanggal: "), Expanded(child: Text(item['dlodate']?.toString() ?? "-"))]),
            Row(children: [const Text("Customer: "), Expanded(child: Text(item['dlocustomer']?.toString() ?? "-"))]),
            Row(children: [const Text("Item Type: "), Expanded(child: Text(item['dloitemtype']?.toString() ?? "-"))]),
            Row(children: [const Text("Qty: "), Expanded(child: Text(item['dloitemqty']?.toString() ?? "-"))]),
            Row(children: [const Text("UOM: "), Expanded(child: Text(item['dloitemuom']?.toString() ?? "-"))]),
            Row(children: [const Text("Locid: "), Expanded(child: Text(item['locid']?.toString() ?? "-"))]),
            Row(children: [const Text("VHCID: "), Expanded(child: Text(item['vhcid']?.toString() ?? "-"))]),
          ],
        ),
      ),
    );
  }

  Widget buildPager() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: page > 1 && !loading ? () => fetchData(toPage: page - 1) : null,
          style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
          child: const Text("Prev"),
        ),
        Text("Page $page / $totalPages"),
        ElevatedButton(
          onPressed: page < totalPages && !loading ? () => fetchData(toPage: page + 1) : null,
          style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
          child: const Text("Next"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        title: const Text("View List DO NC"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text("Tidak ada data"))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) => buildItem(items[index]),
                        ),
            ),
            const SizedBox(height: 8),
            buildPager(),
          ],
        ),
      ),
    );
  }
}
