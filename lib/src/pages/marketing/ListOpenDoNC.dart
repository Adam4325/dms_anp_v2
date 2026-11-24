import 'dart:async';
import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'FrmOpenDOMP.dart';
import 'FrmUploadDO.dart';
import 'ViewListDoNC.dart';

class ListOpenDoNC extends StatefulWidget {
  const ListOpenDoNC({Key? key}) : super(key: key);

  @override
  _ListOpenDoNCState createState() => _ListOpenDoNCState();
}

class _ListOpenDoNCState extends State<ListOpenDoNC> {
  // Design Tokens (design_list.md & design_tab.md)
  static const Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  static const Color lightOrange = Color(0xFFFFF4E6);   // Very light orange
  static const Color accentOrange = Color(0xFFFFB347);  // Peach orange
  static const Color darkOrange = Color(0xFFE07B39);    // Darker orange
  static const Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  static const Color cardColor = Color(0xFFFFF8F0);     // Light cream
  static const Color shadowColor = Color(0x20FF8C69);   // Soft orange shadow

  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> listOpenDO = [];
  List<Map<String, dynamic>> filteredList = [];
  bool loading = false;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) EasyLoading.dismiss();
    load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> load({String search = ""}) async {
    setState(() => loading = true);

    try {
      var urlBase =
          '${GlobalData.baseUrl}api/marketing/do_detail_avp.jsp?method=list-open-do-nc';
      if (search.isNotEmpty) urlBase += '&search=${Uri.encodeComponent(search)}';

      final response = await http.get(Uri.parse(urlBase));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          List<dynamic> dataList = jsonResponse['data'];
          listOpenDO = dataList
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();
          filteredList = List.from(listOpenDO);
        } else {
          filteredList = [];
        }
      } else {
        filteredList = [];
      }
    } catch (e) {
      filteredList = [];
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _filterSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      load(search: query.trim());
    });
  }

  // --- Design System Helpers (design_list.md) ---
  InputDecoration softDecoration({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
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
    );
  }

  ButtonStyle pmBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  Widget pmBtnLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  String _s(dynamic v) {
    if (v == null) return '-';
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null' || s == 'NULL') return '-';
    return s;
  }

  Widget _kv(String label, String value, {bool dense = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 0 : 2),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(125),
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
                  fontSize: dense ? 11 : 12,
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
                  fontSize: dense ? 11 : 12,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: dense ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _pmListCard({
    required String title,
    required List<Widget> rows,
    Widget? actions,
    Widget? headerTrailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        children: <Widget>[
          Container(
            width: double.infinity,
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
                const Icon(Icons.local_shipping_outlined,
                    color: darkOrange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (headerTrailing != null) headerTrailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
              child: actions,
            ),
        ],
      ),
    );
  }

  void _onUploadDO() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FrmUploadDO()),
    );
  }

  void _onViewListDo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewListDoNC()),
    );
  }

  void _onAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FrmOpenDOMP(item: {})),
    ).then((_) => load());
  }

  void _onEdit(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FrmOpenDOMP(item: item)),
    ).then((_) => load());
  }

  Future<void> _cancelData(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString("name") ?? "unknown";

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: primaryOrange, size: 26),
              SizedBox(width: 8),
              Text(
                "Konfirmasi Cancel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin membatalkan Open DO ${item['dlododetailnumber']}?",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Tidak", style: TextStyle(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Ya, Batalkan"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final url = Uri.parse(
        "${GlobalData.baseUrl}api/marketing/create_update_delete_dodetailavp.jsp");

    final Map<String, String> body = {
      "method": "cancel-data",
      "dlododetailnumber": item['dlododetailnumber']?.toString() ?? '',
      "dlocustdonbr": item['dlocustdonbr']?.toString() ?? '',
      "userid": user,
    };

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res["status"] == "OK") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Data berhasil di-cancel")),
            );
          }
          load();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Gagal: ${res["message"] ?? "Error tidak diketahui"}")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  Future<void> _deleteData(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString("name") ?? "unknown";

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 26),
              const SizedBox(width: 8),
              const Text(
                "Konfirmasi Hapus",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus data Open DO ${item['dlododetailnumber']}?",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Batal", style: TextStyle(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Ya, Hapus"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final url = Uri.parse(
        "${GlobalData.baseUrl}api/marketing/create_update_delete_dodetailavp.jsp");

    final Map<String, String> body = {
      "method": "cancel-data",
      "dlododetailnumber": item['dlododetailnumber']?.toString() ?? '',
      "dlocustdonbr": item['dlocustdonbr']?.toString() ?? '',
      "userid": user,
    };

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res["status"] == "OK") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Data berhasil dihapus")),
            );
          }
          load();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Gagal: ${res["message"] ?? "Error tidak diketahui"}")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewDashboard()),
        );
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ViewDashboard()),
              );
            },
          ),
          title: const Text(
            "List Open DO NC",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.upload_file_outlined, color: Colors.white),
              tooltip: "Upload DO",
              onPressed: _onUploadDO,
            ),
            IconButton(
              icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
              tooltip: "View List DO",
              onPressed: _onViewListDo,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: "Refresh",
              onPressed: () => load(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'add_open_do_nc',
          onPressed: _onAdd,
          backgroundColor: primaryOrange,
          elevation: 2,
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            "Tambah DO NC",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search row (design_list.md Section 2)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              color: backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      cursorColor: primaryOrange,
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      textInputAction: TextInputAction.search,
                      onChanged: _filterSearch,
                      onSubmitted: (v) => load(search: v.trim()),
                      decoration: softDecoration(
                        label: 'Pencarian DO NC',
                        hint: 'Nomor DO / Customer / Original DO...',
                      ).copyWith(
                        prefixIcon: const Icon(Icons.search,
                            color: primaryOrange, size: 20),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  load();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => load(search: searchController.text.trim()),
                    style: pmBtnStyle(primaryOrange),
                    child: pmBtnLabel('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: () => load(search: searchController.text.trim()),
                child: loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: primaryOrange),
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    searchController.text.isNotEmpty
                                        ? 'Data tidak ditemukan untuk "${searchController.text}"'
                                        : 'Tidak ada data Open DO NC',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (searchController.text.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        searchController.clear();
                                        load();
                                      },
                                      icon: const Icon(Icons.clear, size: 14),
                                      label: const Text('Reset Pencarian'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryOrange,
                                        side: const BorderSide(
                                            color: primaryOrange),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 4, bottom: 80),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final status = _s(item['dlostatus']);
                              final isOpen = status.toUpperCase() == 'OPEN';

                              Widget? statusBadge;
                              if (status != '-') {
                                statusBadge = Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isOpen
                                        ? const Color(0xFFFFF3E0)
                                        : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isOpen
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFF81C784),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: isOpen
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }

                              final rows = <Widget>[
                                _kv("Customer", _s(item['cpyname'])),
                                _kv("DLO Customer", _s(item['dlocustdonbr'])),
                                _kv("Original DO",
                                    _s(item['dlooriginaldonbr'])),
                                _kv("Origin", _s(item['ctyname'])),
                                _kv("DO Date", _s(item['dlodate'])),
                                _kv(
                                    "Qty",
                                    "${_s(item['dloitemqty'])} ${_s(item['dloitemuom']) != '-' ? _s(item['dloitemuom']) : ''}"
                                        .trim()),
                                _kv("Type Truck", _s(item['vhcid'])),
                                _kv("Locid", _s(item['locid'])),
                                if (_s(item['address']) != '-')
                                  _kv("Address", _s(item['address'])),
                              ];

                              return _pmListCard(
                                title: _s(item['dlododetailnumber']),
                                headerTrailing: statusBadge,
                                rows: rows,
                                actions: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _onEdit(item),
                                        icon: const Icon(Icons.edit_outlined,
                                            color: Colors.white, size: 15),
                                        label: pmBtnLabel("Edit"),
                                        style: pmBtnStyle(primaryOrange),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _cancelData(item),
                                        icon: const Icon(Icons.cancel_outlined,
                                            color: Colors.white, size: 15),
                                        label: pmBtnLabel("Cancel"),
                                        style: pmBtnStyle(accentOrange),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _deleteData(item),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.white, size: 15),
                                        label: pmBtnLabel("Hapus"),
                                        style: pmBtnStyle(Colors.red.shade400),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
