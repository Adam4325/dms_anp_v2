import 'dart:async';
import 'dart:io';

import 'package:dms_anp/src/pages/driver/ListDriverInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ApprovedDailyCheckScreenP2H extends StatefulWidget {
  @override
  _ApprovedDailyCheckScreenP2HState createState() => _ApprovedDailyCheckScreenP2HState();
}

class _ApprovedDailyCheckScreenP2HState extends State<ApprovedDailyCheckScreenP2H> {
  List<dynamic> inspections = [];
  Map<String, String> selectedValues =
      {}; // key: inspeksi_id, value: 'ya'/'tidak'
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);

  final TextEditingController kilometerController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController notesVerifikasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInspectionData();
  }

  void fetchInspectionDataOld() async {
    var urlBase =
        'https://apps.tuluatas.com/trucking/mobile/api/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&vhcid=${globals.p2hVhcid.toString()}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);
    if (response.statusCode == 200) {
      setState(() {
        inspections = json.decode(response.body);
      });
    } else {
      print('Failed to load data');
    }
  }

  void fetchInspectionData() async {
    var urlBase =
        'https://apps.tuluatas.com/trucking/mobile/api/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&vhcid=${globals.p2hVhcid.toString()}';
    final response = await http.get(Uri.parse(urlBase));
    print(urlBase);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        inspections = data;

        if (data.isNotEmpty) {
          // Ambil nilai km dan notes dari elemen pertama
          kilometerController.text = data[0]['km'] ?? '';
          notesController.text = data[0]['notes'] ?? '';
        } else {
          kilometerController.clear();
          notesController.clear();
          notesVerifikasiController.clear();
        }
      });
    } else {
      print('Failed to load data');
    }
  }


  void handleSubmit() async {
    // Cek apakah semua inspeksi sudah dipilih
    if(inspections.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada yang akan di approved"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }
    if(notesVerifikasiController.text.isEmpty){
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
    final uniqueIds = inspections.map((e) => e['id']).toSet();

    //final incomplete = uniqueIds.any((id) => selectedValues[id] == null);

    print('VHCID ${globals.p2hVhcid}');
    print('LOCID ${globals.p2hVhclocid}');
    if (globals.p2hVhcid==null || globals.p2hVhcid=='') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Vehicle ID tidak di temukan.'),
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

    // Jika valid, lanjutkan proses
    List<Map<String, dynamic>> result = [];

    final grouped = <String, String>{};
    for (var item in inspections) {
      grouped[item['id']] = item['inspeksi_name'];
    }

    grouped.forEach((id, name) {
      final value = selectedValues[id];
      result.add({
        "id": id,
        "inspeksi_name": name,
        "inspeksi": value == "ya" ? 1 : 0,
      });
    });

    final data = {
      "method": "approved",
      "p2hnumber": globals.p2hNumber.toString(),
      "vhcid": globals.p2hVhcid.toString(),
      "locid": globals.p2hVhclocid.toString(),
      "userid": username,
      "notes_verifikasi":notesVerifikasiController.text
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // Kirim data ke server via POST
    var urlBase = 'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2_new.jsp';
    //var urlBase = 'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2new.jsp';
    print("URLBASE ${urlBase}");
    final response = await http.post(
      Uri.parse(urlBase),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      print("RESPONSE BODY: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            // sukses
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
                  MaterialPageRoute(
                      builder: (context) =>
                          ListDriverInspeksiV2()));
            });

          } else {
            // gagal dari sisi server
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Gagal'),
                content: Text(
                    'Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
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
              content: const Text(
                  'Respon dari server tidak bisa diproses (bukan JSON).'),
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
        print("Server returned empty response");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Server tidak mengembalikan data apapun.'),
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
  }


  void handleCancel() async {
    // Cek apakah semua inspeksi sudah dipilih
    if(inspections.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada yang akan di approved"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("name");
    if (globals.p2hVhcid==null || globals.p2hVhcid=='') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: const Text('Vehicle ID tidak di temukan.'),
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

    // Jika valid, lanjutkan proses
    List<Map<String, dynamic>> result = [];

    final grouped = <String, String>{};
    for (var item in inspections) {
      grouped[item['id']] = item['inspeksi_name'];
    }

    grouped.forEach((id, name) {
      final value = selectedValues[id];
      result.add({
        "id": id,
        "inspeksi_name": name,
        "inspeksi": value == "ya" ? 1 : 0,
      });
    });

    final data = {
      "method": "cancel",
      "vhcid": globals.p2hVhcid.toString(),
      "p2hnumber": globals.p2hNumber.toString(),
      "locid": globals.p2hVhclocid.toString(),
      "userid": username,
      "notes_verifikasi":notesVerifikasiController.text
    };

    final jsonString = jsonEncode(data);
    print("Data to submit: $jsonString");

    // Kirim data ke server via POST
    final response = await http.post(
      Uri.parse(
          'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2_new.jsp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      print("RESPONSE BODY: ${response.body}");

      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == 'success') {
            // sukses
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sukses'),
                content: const Text('Cancel/Rejected inspeksi berhasil!.'),
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
                  MaterialPageRoute(
                      builder: (context) =>
                          ListDriverInspeksiV2()));
            });
          } else {
            // gagal dari sisi server
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Gagal'),
                content: Text(
                    'Pesan dari server: ${responseData['message'] ?? 'Tidak diketahui'}'),
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
              content: const Text(
                  'Respon dari server tidak bisa diproses (bukan JSON).'),
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
        print("Server returned empty response");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Server tidak mengembalikan data apapun.'),
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
  }

  void handleCancelOld() {
    setState(() {
      selectedValues.clear();
      kilometerController.clear();
      notesController.clear();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ListDriverInspeksiV2()));
    });
  }

  Future<void> _generateAndSharePdf() async {
    if (inspections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data inspeksi untuk dicetak')),
      );
      return;
    }

    final Map<String, List<dynamic>> grouped = {};
    for (var item in inspections) {
      final groupId = item['id'];
      (grouped[groupId] ??= []).add(item);
    }

    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final noPolisi = globals.p2hVhcid ?? '';
    final nomorP2h = globals.p2hNumber ?? '';
    final catatan = notesController.text;

    // Font yang punya glyph ✓ dan ✗ agar tidak jadi kotak/X
    pw.Font? checkFont;
    try {
      final fontData = await rootBundle.load('fonts/Montserrat-Regular.ttf');
      checkFont = pw.Font.ttf(fontData);
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'FORM DAILY CHECK BEFORE RIDING',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'INSPEKSI KENDARAAN',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('No Polisi : $noPolisi',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 2),
                      pw.Text('Tanggal : $dateStr',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 2),
                      pw.Text('Nomor P2h : $nomorP2h',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            ...grouped.entries.toList().asMap().entries.map((sectionEntry) {
              final sectionIndex = sectionEntry.key + 1;
              final entry = sectionEntry.value;
              final items = entry.value;
              final sectionTitle =
                  (items.isNotEmpty ? items.first['inspeksi_name'] : '') ?? '';
              final isYes = items.isNotEmpty && items.first['point'] == '1';
              final rows = <pw.TableRow>[
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(width: 0.5),
                      left: pw.BorderSide(width: 0.5),
                      right: pw.BorderSide(width: 0.5),
                      top: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  children: [
                    _cell('No', bold: true),
                    _cell('Item', bold: true),
                    _cell('Ya', bold: true),
                    _cell('Tidak', bold: true),
                  ],
                ),
              ];
              final subItems = items
                  .where((item) =>
                      item['subs_inspeksi_name'] != null &&
                      item['subs_inspeksi_name'].toString() != '-')
                  .toList();
              if (subItems.isEmpty) {
                rows.add(_dataRow('1', sectionTitle, isYes, checkFont));
              } else {
                for (var i = 0; i < subItems.length; i++) {
                  final sub = subItems[i];
                  final name =
                      (sub['subs_inspeksi_name'] ?? sectionTitle).toString();
                  rows.add(_dataRow('${i + 1}', name, isYes, checkFont));
                }
              }
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$sectionIndex. $sectionTitle',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(0.8),
                      1: const pw.FlexColumnWidth(4),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1.2),
                    },
                    children: rows,
                  ),
                  pw.SizedBox(height: 12),
                ],
              );
            }),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Catatan / Temuan :',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(width: 0.5),
                      ),
                    ),
                    child: pw.Text(catatan.isEmpty ? ' ' : catatan,
                        style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Diperiksa Oleh',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 24),
                          pw.Container(
                            width: 120,
                            height: 1,
                            color: PdfColors.black,
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Disetujui Oleh',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 24),
                          pw.Container(
                            width: 120,
                            height: 1,
                            color: PdfColors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final safeName = 'daily_check_p2h_${nomorP2h}_$dateStr.pdf'
          .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Form Daily Check Before Riding - $nomorP2h',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('PDF siap dibagikan'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        print('Gagal membuat PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal membuat PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  pw.TableRow _dataRow(String no, String item, bool isYa, pw.Font? checkFont) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 0.5),
          left: pw.BorderSide(width: 0.5),
          right: pw.BorderSide(width: 0.5),
        ),
      ),
      children: [
        _cell(no),
        _cell(item),
        _cell(isYa ? '✓' : '', color: isYa ? PdfColors.blue : null, font: checkFont),
        _cell(isYa ? '' : '✗', color: isYa ? null : PdfColors.red, font: checkFont),
      ],
    );
  }

  pw.Widget _cell(String text, {bool bold = false, PdfColor? color, pw.Font? font}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
          font: font,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> grouped = {};

    for (var item in inspections) {
      final groupId = item['id'];
      (grouped[groupId] ??= []).add(item);
    }

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ListDriverInspeksiV2()),
          );
        },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: darkOrange,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            iconSize: 20.0,
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListDriverInspeksiV2()));
            },
          ),
          //backgroundColor: Colors.transparent,
          title: Text('Approved Inspeksi ${globals.p2hVhcid.toString()}',
              style: TextStyle(color: Colors.white))),
      body: inspections.isEmpty
          ? const Center(child: Text("Tidak ada data inspeksi"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("Daily Check Before Riding",
                        style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 16),
                  ...grouped.entries.map((entry) {
                    final groupId = entry.key;
                    final items = entry.value;
                    final groupTitle = items.first['inspeksi_name'];
                    final isYes = items.first['point'];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                isYes == "1" ? Icons.check_box : Icons.close,
                                size: 20,
                                color: isYes == "1" ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                groupTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Divider(),
                          ...items
                              .where((item) =>
                                  item['subs_inspeksi_name'] != null &&
                                  item['subs_inspeksi_name'].toString() != "-")
                              .map((item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle, size: 6),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child:
                                              Text(item['subs_inspeksi_name']),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    );
                  }).toList(),

                  // --- Kilometer input
                  const SizedBox(height: 16),
                  TextField(
                    controller: kilometerController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kilometer',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Notes input
                  TextField(
                    controller: notesController,
                    readOnly: true,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 80), // spacing for bottom button
                ],
              ),
            ),
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top:12,left: 12,right: 12,bottom: 50),
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
                    backgroundColor: darkOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.check),
                label: const Text("Approved",style: TextStyle(color: Colors.white),),//BUTTON APPROVE
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _generateAndSharePdf(),
                icon: const Icon(Icons.picture_as_pdf),
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
                label: const Text("Print",style: TextStyle(color: Colors.black)),
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
                        title: Text("Notes Cancel Verifikasi"),
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
                icon: const Icon(Icons.refresh),
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
                label: const Text("Cancel",style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
