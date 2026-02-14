import 'dart:async';
import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'FrmOpenDO.dart';
import 'FrmUploadDO.dart';

class ListOpenDO extends StatefulWidget {
  @override
  _ListOpenDOState createState() => _ListOpenDOState();
}

class _ListOpenDOState extends State<ListOpenDO> {
  final Color primaryOrange = const Color(0xFFFF8C69); // Soft orange
  final Color lightOrange = const Color(0xFFFFF4E6); // Very light orange
  final Color accentOrange = const Color(0xFFFFB347); // Peach orange
  final Color darkOrange = const Color(0xFFE07B39); // Darker orange
  final Color backgroundColor = const Color(0xFFFFFAF5); // Cream white
  final Color cardColor = const Color(0xFFFFF8F0); // Light cream
  final Color shadowColor = const Color(0x20FF8C69); // Soft orange shadow

  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> listOpenDO = [];
  List<Map<String, dynamic>> filteredList = [];
  bool loading = false;
  TextEditingController searchController = TextEditingController();

  late Timer _debounce;

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) EasyLoading.dismiss();
    load();
  }

  Future<void> load({String search = ""}) async {
    setState(() => loading = true);

    try {
      var urlBase =
          '${GlobalData.baseUrl}api/marketing/do_detail_avp.jsp?method=list-open-do';
      if (search.isNotEmpty) urlBase += '&search=${Uri.encodeComponent(search)}';

      print("🔍 URL Request: ${urlBase}");
      final response = await http.get(Uri.parse(urlBase));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          List<dynamic> dataList = jsonResponse['data'];
          listOpenDO = dataList.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          filteredList = List.from(listOpenDO);
        } else {
          filteredList = [];
        }
      } else {
        filteredList = [];
      }
    } catch (e) {
      print("⚠️ Error loading Open DO: $e");
      filteredList = [];
    }

    setState(() => loading = false);
  }

  void _filterSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      load(search: query);
    });
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _onUploadDO() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FrmUploadDO(),
      ),
    );
  }

  void _onUploadDOFromItem(Map<String, dynamic> item) {
    if (item == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FrmUploadDO(
          dlododetailnumber: item['dlododetailnumber']?.toString(),
          dlocustdonbr: item['dlocustdonbr']?.toString(),
          dlooriginaldonbr: item['dlooriginaldonbr']?.toString(),
        ),
      ),
    );
  }

  void _onAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FrmOpenDO(item: {}),
      ),
    );
  }

  void _onEdit(Map<String, dynamic> item) {
    if(item==null){
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FrmOpenDO(item: item),
      ),
    );
  }

  Future<void> _cancelData(Map<String, dynamic> item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("name") ?? "unknown";
    if(item==null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Item tidak boleh kosong")),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text(
                "Konfirmasi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin membatalkan data ini?",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
              child: const Text("Tidak"),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent,
                foregroundColor : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "Ya, Batalkan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
      "dlododetailnumber": item['dlododetailnumber'],
      "dlocustdonbr": item['dlocustdonbr'],
      "userid": user,
    };

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res["status"] == "OK") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Data berhasil di cancel")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text("Gagal: ${res["message"] ?? "Error tak diketahui"}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  void _onCancel(Map<String, dynamic> item) {
    _cancelData(item);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Cancel DO ${item['dlododetailnumber']}")),
    // );
  }

  Future<void> _deleteData(Map<String, dynamic> item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("name") ?? "unknown";
    if(item==null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Item tidak boleh kosong")),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text(
                "Konfirmasi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus data ini?",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
              child: const Text("Tidak"),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent,
                foregroundColor : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "Ya, Hapus",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
      "dlododetailnumber": item['dlododetailnumber'],
      "dlocustdonbr": item['dlocustdonbr'],
      "userid": user,
    };

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res["status"] == "OK") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Data berhasil di cancel")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text("Gagal: ${res["message"] ?? "Error tak diketahui"}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  void _onDelete(Map<String, dynamic> item) {
    _deleteData(item);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewDashboard()),
        );
        return false;
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          title: const Text("List Open DO"),
          elevation: 4,
          shadowColor: shadowColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ViewDashboard()),
              );
            },
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'upload_do',
              onPressed: _onUploadDO,
              backgroundColor: primaryOrange,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text("Upload DO",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.extended(
              heroTag: 'add_do',
              onPressed: _onAdd,
              backgroundColor: accentOrange,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add DO",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Cari berdasarkan Nomor DO atau Customer",
                  filled: true,
                  fillColor: lightOrange,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterSearch,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredList.isEmpty
                    ? const Center(child: Text("Tidak ada data"))
                    : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_shipping,
                                    color: darkOrange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['dlododetailnumber'] ?? "-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: darkOrange,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryOrange,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['dlostatus'] ?? "-",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow("Customer", item['cpyname']),
                            _buildDetailRow("DLO Customer", item['dlocustdonbr']),
                            _buildDetailRow("Original DO Number", item['dlooriginaldonbr']),
                            _buildDetailRow("Origin", item['ctyname']),
                            _buildDetailRow("DO Date", item['dlodate']),
                            _buildDetailRow("Qty", item['dloitemqty']),
                            //_buildDetailRow("Driver", item['drvid']),
                            _buildDetailRow("Type Truck", item['vhcid']),
                            _buildDetailRow("UOM", item['dloitemuom']),
                            _buildDetailRow("Locid", item['locid']),
                            _buildDetailRow("Address", item['address']),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                _actionButton(Icons.edit, "Edit",
                                    accentOrange, () => _onEdit(item)),
                                _actionButton(Icons.upload_file, "Upload",
                                    primaryOrange, () => _onUploadDOFromItem(item)),
                                _actionButton(Icons.cancel, "Cancel",
                                    primaryOrange, () => _onCancel(item)),
                                _actionButton(Icons.delete, "Delete",
                                    darkOrange, () => _onDelete(item)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
}
