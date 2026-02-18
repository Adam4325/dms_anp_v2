import 'dart:async';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/driver/ListDriverInspeksiV2.dart';
import 'package:dms_anp/src/pages/mekanik/ListMekanikInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApprovedMekanikDailyCheckScreenP2H extends StatefulWidget {
  @override
  _ApprovedMekanikDailyCheckScreenP2HState createState() => _ApprovedMekanikDailyCheckScreenP2HState();
}

class _ApprovedMekanikDailyCheckScreenP2HState extends State<ApprovedMekanikDailyCheckScreenP2H> {
  List<dynamic> inspections = [];
  Map<String, String> selectedValues =
      {}; // key: inspeksi_id, value: 'ya'/'tidak'
  // Map untuk menyimpan status inspeksi per baris: key = index baris (unik), value = 0/1/2
  // Pakai index karena API bisa mengembalikan id yang sama untuk banyak baris
  Map<String, int> toolStatusMap = {};
  // Urutan baris tabel (sama dengan urutan render) untuk map index -> item
  List<dynamic> _tableRowsOrder = [];
  
  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow
  final TextEditingController notesController = TextEditingController();
  final TextEditingController notesVerifikasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInspectionData();
  }


  void fetchInspectionData() async {
    var urlBase =
       GlobalData.baseUrl + 'api/mekanik/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&p2hnumber=${globals.Mcp2hNumber.toString()}&kryid=${globals.Mckryid}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        inspections = data;
        
        // Urutan baris tabel (sama dengan urutan render: per group)
        final Map<String, List<dynamic>> grouped = {};
        for (var item in data) {
          final groupId = item['groupid'] ?? '';
          if (!grouped.containsKey(groupId)) grouped[groupId] = [];
          grouped[groupId]!.add(item);
        }
        _tableRowsOrder = [];
        for (var entry in grouped.entries) {
          _tableRowsOrder.addAll(entry.value);
        }
        
        // Initialize toolStatusMap dengan index baris (unik per baris)
        toolStatusMap.clear();
        for (var i = 0; i < _tableRowsOrder.length; i++) {
          final item = _tableRowsOrder[i];
          final inspeksi = int.tryParse(item['inspeksi']?.toString() ?? '0') ?? 0;
          toolStatusMap[i.toString()] = inspeksi;
        }

        if (data.isNotEmpty) {
          // Ambil nilai km dan notes dari elemen pertama
          notesController.text = data[0]['notes'] ?? '';
        } else {
          notesController.clear();
          notesVerifikasiController.clear();
        }
      });
    } else {
      print('Failed to load data');
    }
  }


  void handleSubmit() async {
    if (inspections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada yang akan di approved"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    if (notesVerifikasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Notes Verifikasi tidak boleh kosong!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("name");

    if ((globals.Mcp2hNumber==null || globals.Mcp2hNumber=='') && (globals.Mckryid==null || globals.Mckryid=='')) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Mekanik ID tidak ditemukan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if ((notesVerifikasiController.text == null || notesVerifikasiController.text.isEmpty) &&
        (globals.Mckryid == null || globals.Mckryid!.isEmpty)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Note wajib diisi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Siapkan list inspeksi menggunakan toolStatusMap (key = index baris)
    List<Map<String, dynamic>> inspeksiData = [];
    for (var i = 0; i < _tableRowsOrder.length; i++) {
      final item = _tableRowsOrder[i];
      final currentStatus = toolStatusMap[i.toString()] ?? 0;
      final originalStatus =
          int.tryParse(item['inspeksi']?.toString() ?? '0') ?? 0;
      final changed = currentStatus == originalStatus ? 0 : 1;
      inspeksiData.add({
        "id": item['id'],
        "groupid": item['groupid'],
        "nama_tools": item['nama_tools'],
        "qty": item['qty'],
        "inspeksi": currentStatus,
        "changed": changed,
      });
    }

    // Payload JSON
    final data = {
      "method": "approved",
      "p2hnumber": globals.Mcp2hNumber.toString(),
      "kryid": globals.Mckryid.toString(),
      "userid": username,
      "notes_verifikasi": notesVerifikasiController.text,
      "inspeksi_data": inspeksiData,
    };
    print(data);
    //return; //TEST
    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    var urlBase = GlobalData.baseUrl + 'api/mekanik/approved_form_inspeksiv2_mekanik_new.jsp';
    final response = await http.post(
      Uri.parse(urlBase),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sukses'),
              content: const Text('Approved inspeksi berhasil disubmit.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ListMekanikInspeksiV2()),
            );
          });
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Gagal'),
              content: Text('Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print("JSON decode error: $e");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Respon dari server tidak bisa diproses (bukan JSON).'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal'),
          content: const Text('Gagal mengirim data ke server.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void handleCancel() async {
    // Cek apakah data inspeksi kosong
    if (inspections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada data inspeksi untuk dibatalkan."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ambil data dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("name")!;

    // Validasi wajib: kendaraan & mekanik
    if ((globals.Mcp2hNumber == null || globals.Mcp2hNumber!.isEmpty) &&
        (globals.Mckryid == null || globals.Mckryid!.isEmpty)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Mekanik ID tidak ditemukan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if ((notesVerifikasiController.text == null || notesVerifikasiController.text.isEmpty) &&
        (globals.Mckryid == null || globals.Mckryid!.isEmpty)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Note wajib diisi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Persiapan data JSON
    final data = {
      "method": "cancel",
      "p2hnumber": globals.Mcp2hNumber?.toString() ?? '',
      "kryid": globals.Mckryid?.toString() ?? '',
      "userid": username ?? '',
      "notes_verifikasi": notesVerifikasiController.text,
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // Kirim POST ke server
    final response = await http.post(
      Uri.parse(GlobalData.baseUrl + 'api/mekanik/approved_form_inspeksiv2_mekanik.jsp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    // Proses respon server
    if (response.statusCode == 200) {
      print("RESPONSE BODY: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Inspeksi berhasil dibatalkan.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => ListMekanikInspeksiV2()));
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Gagal'),
                content: Text('Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          print("JSON decode error: $e");
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Gagal'),
              content: const Text('Data dari server tidak valid (bukan JSON).'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Server tidak mengembalikan data.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal'),
          content: Text('HTTP Error ${response.statusCode}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  /// Status mapping: Ada = 0, Rusak = 1, Tidak Ada = 2
  static const int _statusAda = 0;
  static const int _statusRusak = 1;
  static const int _statusTidakAda = 2;

  Widget _tableCell(String text, {bool isHeader = false, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: child ??
          Text(
            text,
            style: TextStyle(
              fontSize: isHeader ? 12 : 13,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
    );
  }

  /// Handle click checkbox di header (baris TOOLS) untuk pilih semua baris
  void _handleHeaderCheckboxClick(int statusValue) {
    setState(() {
      bool allSelected = _isAllSelected(statusValue);
      final newStatus = allSelected ? _statusTidakAda : statusValue;
      for (var i = 0; i < _tableRowsOrder.length; i++) {
        toolStatusMap[i.toString()] = newStatus;
      }
    });
  }
  
  /// Handle click checkbox di row untuk mengubah status satu baris saja (rowKey = index baris)
  void _handleRowCheckboxClick(String rowKey, int statusValue) {
    setState(() {
      final currentStatus = toolStatusMap[rowKey] ?? _statusTidakAda;
      if (currentStatus == statusValue) {
        toolStatusMap[rowKey] = _statusTidakAda;
      } else {
        toolStatusMap[rowKey] = statusValue;
      }
    });
  }
  
  /// Cek apakah semua baris sudah dalam status tertentu — untuk tampilan checkbox header
  bool _isAllSelected(int statusValue) {
    if (_tableRowsOrder.isEmpty) return false;
    for (var i = 0; i < _tableRowsOrder.length; i++) {
      if (toolStatusMap[i.toString()] != statusValue) return false;
    }
    return true;
  }

  /// Build baris data tabel dengan rowIndex unik per baris (key untuk toolStatusMap)
  List<TableRow> _buildDataTableRows(Map<String, List<dynamic>> grouped) {
    final List<TableRow> rows = [];
    int rowIndex = 0;
    for (var entry in grouped.entries) {
      final groupId = entry.key;
      final items = entry.value as List<dynamic>;
      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Group ID: $groupId',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const TableCell(child: SizedBox.shrink()),
            const TableCell(child: SizedBox.shrink()),
            const TableCell(child: SizedBox.shrink()),
            const TableCell(child: SizedBox.shrink()),
          ],
        ),
      );
      for (var item in items) {
        final rowKey = rowIndex.toString();
        final nama = item['nama_tools'] ?? '';
        final qty = item['qty']?.toString() ?? '0';
        final currentStatus = toolStatusMap[rowKey] ?? _statusTidakAda;
        final isAda = currentStatus == _statusAda;
        final isRusak = currentStatus == _statusRusak;
        final isTidakAda = currentStatus == _statusTidakAda;
        final key = rowKey; // capture untuk closure
        rows.add(
          TableRow(
            children: [
              TableCell(child: _tableCell(nama, isHeader: false)),
              TableCell(child: _tableCell(qty, isHeader: false)),
              TableCell(
                  child: _tableCell(
                      '',
                      isHeader: false,
                      child: _statusCheckbox(
                          value: isAda,
                          isTidakAda: false,
                          onTap: () => _handleRowCheckboxClick(key, _statusAda)))),
              TableCell(
                  child: _tableCell(
                      '',
                      isHeader: false,
                      child: _statusCheckbox(
                          value: isRusak,
                          isTidakAda: false,
                          onTap: () => _handleRowCheckboxClick(key, _statusRusak)))),
              TableCell(
                  child: _tableCell(
                      '',
                      isHeader: false,
                      child: _statusCheckbox(
                          value: isTidakAda,
                          isTidakAda: true,
                          onTap: () => _handleRowCheckboxClick(key, _statusTidakAda)))),
            ],
          ),
        );
        rowIndex++;
      }
    }
    return rows;
  }

  Widget _statusCheckbox({
    required bool value, 
    bool isTidakAda = false,
    VoidCallback? onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          value ? Icons.check_box : Icons.check_box_outline_blank,
          size: 22,
          color: value
              ? (isTidakAda ? Colors.red : Colors.blue)
              : Colors.grey.shade400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> grouped = {};

    for (var item in inspections) {
      final groupId = item['groupid'] ?? '';
      if (!grouped.containsKey(groupId)) {
        grouped[groupId] = [];
      }
      grouped[groupId]?.add(item);
    }

    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ListMekanikInspeksiV2()),
      );
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: darkOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 20.0,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ListMekanikInspeksiV2()));
          },
        ),
        title: Text('Approved Inspeksi ${globals.McName.toString()}',
            style: const TextStyle(color: Colors.white)),
      ),
      body: inspections.isEmpty
          ? const Center(child: Text("Tidak ada data inspeksi"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "Daily Check Before Riding",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Satu tabel: hanya satu baris header (sejajar TOOLS) yang bisa pilih semua; row lain per row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Table(
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(0.6),
                        2: FlexColumnWidth(0.7),
                        3: FlexColumnWidth(0.8),
                        4: FlexColumnWidth(1.2),
                      },
                      children: [
                        // Satu baris header saja (sejajar TOOLS) — checkbox di sini pilih semua
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                          ),
                          children: [
                            TableCell(child: _tableCell('TOOLS', isHeader: true)),
                            TableCell(child: _tableCell('QTY', isHeader: true)),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'ADA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _statusCheckbox(
                                      value: _isAllSelected(_statusAda),
                                      isTidakAda: false,
                                      onTap: () => _handleHeaderCheckboxClick(_statusAda),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'RUSAK',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _statusCheckbox(
                                      value: _isAllSelected(_statusRusak),
                                      isTidakAda: false,
                                      onTap: () => _handleHeaderCheckboxClick(_statusRusak),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'TIDAK ADA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _statusCheckbox(
                                      value: _isAllSelected(_statusTidakAda),
                                      isTidakAda: true,
                                      onTap: () => _handleHeaderCheckboxClick(_statusTidakAda),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Baris data: pakai index baris (rowKey) supaya tiap baris unik
                        ..._buildDataTableRows(grouped),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 12,left: 12,right: 12,bottom: 50),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (){
                  //handleSubmit
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController _notesController = TextEditingController();

                      return AlertDialog(
                        title: Text("Notes Verifikasi"),
                        content: TextField(
                          controller: notesVerifikasiController,
                          decoration: InputDecoration(
                            hintText: "Masukkan catatan...",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              handleSubmit();

                            },
                          ),
                        ],
                      );
                    },
                  );

                },
                style: ElevatedButton.styleFrom(
                    elevation: 2.0,
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.check),
                label: const Text("Approved"),//BUTTON APPROVE
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController _notesController = TextEditingController();

                      return AlertDialog(
                        title: Text("Notes Verifikasi"),
                        content: TextField(
                          controller: notesVerifikasiController,
                          decoration: InputDecoration(
                            hintText: "Masukkan catatan...",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              handleCancel();

                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                    elevation: 2.0,
                    backgroundColor: shadowColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.refresh),
                label: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
