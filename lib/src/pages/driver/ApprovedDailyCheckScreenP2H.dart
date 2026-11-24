import 'dart:async';
import 'dart:io';

import 'package:dms_anp/src/pages/driver/ListDriverInspeksiV2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  _ApprovedDailyCheckScreenP2HState createState() =>
      _ApprovedDailyCheckScreenP2HState();
}

class _ApprovedDailyCheckScreenP2HState
    extends State<ApprovedDailyCheckScreenP2H> {
  List<dynamic> inspections = [];
  Map<String, String> selectedValues = {};
  bool _isLoading = true;

  // MD Palette
  static const Color primaryOrange = Color(0xFFFF8A50);
  static const Color darkOrange = Color(0xFFE65100);
  static const Color scaffoldBg = Color(0xFFF8FAFC);

  final TextEditingController kilometerController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController notesVerifikasiController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInspectionData();
  }

  @override
  void dispose() {
    kilometerController.dispose();
    notesController.dispose();
    notesVerifikasiController.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ListDriverInspeksiV2()),
    );
  }

  void fetchInspectionData() async {
    setState(() => _isLoading = true);
    var urlBase =
        'https://apps.tuluatas.com/trucking/mobile/api/master_data_inspeksi.jsp?method=list-inspeksi-verifikasi-v2&vhcid=${globals.p2hVhcid.toString()}';

    try {
      final response = await http
          .get(Uri.parse(urlBase))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            inspections = data;
            _isLoading = false;

            if (data.isNotEmpty) {
              kilometerController.text = data[0]['km']?.toString() ?? '';
              notesController.text = data[0]['notes']?.toString() ?? '';
            } else {
              kilometerController.clear();
              notesController.clear();
              notesVerifikasiController.clear();
            }
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showToast("Gagal memuat data inspeksi (${response.statusCode})",
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast("Terjadi kesalahan koneksi: $e", isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showConfirmActionDialog({required bool isApprove}) {
    final note = notesVerifikasiController.text.trim();
    if (note.isEmpty) {
      _showToast(
        "Notes Verifikasi tidak boleh kosong! Silakan isi catatan terlebih dahulu.",
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isApprove
                  ? Icons.check_circle_rounded
                  : Icons.cancel_outlined,
              color: isApprove ? Colors.green.shade600 : Colors.red.shade600,
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              isApprove ? "Konfirmasi Setujui" : "Konfirmasi Tolak",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isApprove
              ? "Apakah Anda yakin ingin menyetujui hasil verifikasi P2H untuk unit ${globals.p2hVhcid ?? '-'}?"
              : "Apakah Anda yakin ingin menolak hasil verifikasi P2H untuk unit ${globals.p2hVhcid ?? '-'}?",
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Batal",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (isApprove) {
                handleSubmit();
              } else {
                handleCancel();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isApprove ? Colors.green.shade600 : Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              isApprove ? "Ya, Setujui" : "Ya, Tolak",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void handleSubmit() async {
    if (inspections.isEmpty) {
      _showToast("Tidak ada data inspeksi yang akan di-approve", isError: true);
      return;
    }
    if (notesVerifikasiController.text.trim().isEmpty) {
      _showToast("Notes Verifikasi tidak boleh kosong!", isError: true);
      return;
    }
    if (globals.p2hVhcid == null || globals.p2hVhcid == '') {
      _showToast("Vehicle ID tidak ditemukan.", isError: true);
      return;
    }

    EasyLoading.show(status: 'Memproses Approved...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("name") ?? "";

    final data = {
      "method": "approved",
      "p2hnumber": globals.p2hNumber.toString(),
      "vhcid": globals.p2hVhcid.toString(),
      "locid": globals.p2hVhclocid.toString(),
      "userid": username,
      "notes_verifikasi": notesVerifikasiController.text.trim(),
    };

    final jsonString = jsonEncode(data);

    try {
      var urlBase =
          'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2_new.jsp';
      final response = await http.post(
        Uri.parse(urlBase),
        headers: {'Content-Type': 'application/json'},
        body: jsonString,
      ).timeout(const Duration(seconds: 30));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            _showToast("Approved inspeksi P2H berhasil disubmit.");
            Timer(const Duration(milliseconds: 800), () {
              if (mounted) _goBack();
            });
          } else {
            _showToast(
              "Gagal: ${responseData['message'] ?? 'Tidak diketahui'}",
              isError: true,
            );
          }
        } catch (e) {
          _showToast("Format respon server tidak valid.", isError: true);
        }
      } else {
        _showToast("Server tidak mengembalikan data (${response.statusCode})",
            isError: true);
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      _showToast("Terjadi kesalahan: $e", isError: true);
    }
  }

  void handleCancel() async {
    if (inspections.isEmpty) {
      _showToast("Tidak ada data inspeksi yang akan di-cancel", isError: true);
      return;
    }
    if (notesVerifikasiController.text.trim().isEmpty) {
      _showToast("Notes Verifikasi tidak boleh kosong!", isError: true);
      return;
    }
    if (globals.p2hVhcid == null || globals.p2hVhcid == '') {
      _showToast("Vehicle ID tidak ditemukan.", isError: true);
      return;
    }

    EasyLoading.show(status: 'Memproses Penolakan...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("name") ?? "";

    final data = {
      "method": "cancel",
      "vhcid": globals.p2hVhcid.toString(),
      "p2hnumber": globals.p2hNumber.toString(),
      "locid": globals.p2hVhclocid.toString(),
      "userid": username,
      "notes_verifikasi": notesVerifikasiController.text.trim(),
    };

    final jsonString = jsonEncode(data);

    try {
      final response = await http.post(
        Uri.parse(
            'https://apps.tuluatas.com/trucking/mobile/api/approved_form_inspeksiv2_new.jsp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonString,
      ).timeout(const Duration(seconds: 30));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            _showToast("Penolakan inspeksi P2H berhasil diproses.");
            Timer(const Duration(milliseconds: 800), () {
              if (mounted) _goBack();
            });
          } else {
            _showToast(
              "Gagal: ${responseData['message'] ?? 'Tidak diketahui'}",
              isError: true,
            );
          }
        } catch (e) {
          _showToast("Format respon server tidak valid.", isError: true);
        }
      } else {
        _showToast("Server tidak mengembalikan data (${response.statusCode})",
            isError: true);
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      _showToast("Terjadi kesalahan: $e", isError: true);
    }
  }

  Future<void> _generateAndSharePdf() async {
    if (inspections.isEmpty) {
      _showToast('Tidak ada data inspeksi untuk dicetak', isError: true);
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
              child: pw.Text(
                'FORM DAILY CHECK BEFORE RIDING',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('No. Polisi : $noPolisi',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Tanggal : $dateStr',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('No. P2H   : $nomorP2h',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text('KM        : ${kilometerController.text} KM',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 14),
            ...grouped.entries.map((entry) {
              final items = entry.value;
              final groupTitle = items.first['inspeksi_name'] ?? '';
              final isYa = items.first['point'] == "1";

              final rows = <pw.TableRow>[
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border(
                      top: pw.BorderSide(width: 0.5),
                      left: pw.BorderSide(width: 0.5),
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  children: [
                    _cell('NO', bold: true),
                    _cell('ITEM PEMERIKSAAN', bold: true),
                    _cell('YA', bold: true),
                    _cell('TIDAK', bold: true),
                  ],
                ),
                _dataRow('1', groupTitle, isYa, checkFont),
              ];

              int no = 2;
              for (var item in items) {
                final sub = item['subs_inspeksi_name'];
                if (sub != null && sub.toString() != '-') {
                  rows.add(_dataRow('$no', '   $sub', isYa, checkFont));
                  no++;
                }
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Table(
                    columnWidths: const {
                      0: pw.FixedColumnWidth(28),
                      1: pw.FlexColumnWidth(),
                      2: pw.FixedColumnWidth(36),
                      3: pw.FixedColumnWidth(42),
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
                    decoration: const pw.BoxDecoration(
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
      _showToast('PDF siap dibagikan');
    } catch (e) {
      _showToast('Gagal membuat PDF: $e', isError: true);
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
        _cell(isYa ? '✓' : '',
            color: isYa ? PdfColors.blue : null, font: checkFont),
        _cell(isYa ? '' : '✗',
            color: isYa ? null : PdfColors.red, font: checkFont),
      ],
    );
  }

  pw.Widget _cell(String text,
      {bool bold = false, PdfColor? color, pw.Font? font}) {
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
        _goBack();
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _goBack,
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, darkOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                'Verifikasi P2H',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Unit: ${globals.p2hVhcid ?? '-'} | No: ${globals.p2hNumber ?? '-'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              tooltip: 'Cetak / Bagikan PDF',
              onPressed: _generateAndSharePdf,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryOrange),
              )
            : inspections.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              size: 36,
                              color: primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Tidak Ada Data Inspeksi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Data pemeriksaan P2H untuk unit ini tidak ditemukan atau telah diproses.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: _goBack,
                            icon: const Icon(Icons.arrow_back_rounded, size: 16),
                            label: const Text('Kembali ke Daftar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryOrange,
                              side: const BorderSide(color: primaryOrange),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Info Card (MD3)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: primaryOrange.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping_rounded,
                                      color: darkOrange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          globals.p2hVhcid ?? "-",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        Text(
                                          "Daily Check Before Riding",
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.orange.shade200),
                                    ),
                                    child: Text(
                                      globals.p2hNumber ?? "-",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 10),

                              // Info Grid: Cabang & KM
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 16,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "CABANG",
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                globals.p2hVhclocid ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E293B),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 26,
                                    color: Colors.grey.shade300,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.speed_rounded,
                                            size: 16,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "KILOMETER",
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            Text(
                                              "${kilometerController.text.isNotEmpty ? kilometerController.text : '0'} KM",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Driver Note if present
                              if (notesController.text.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.amber.shade200),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.info_outline_rounded,
                                          size: 15,
                                          color: Colors.amber.shade900),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Catatan Driver: ${notesController.text}",
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.amber.shade900,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Section Title: Item Hasil Pemeriksaan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.checklist_rounded,
                                    size: 17, color: darkOrange),
                                SizedBox(width: 6),
                                Text(
                                  "Hasil Pemeriksaan Unit",
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryOrange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${grouped.length} Bagian",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: darkOrange,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Inspection Items Group List
                        ...grouped.entries.map((entry) {
                          final items = entry.value;
                          final groupTitle = items.first['inspeksi_name'] ?? '';
                          final isYes = items.first['point']?.toString() == "1";

                          final subItems = items
                              .where((item) =>
                                  item['subs_inspeksi_name'] != null &&
                                  item['subs_inspeksi_name'].toString() != "-")
                              .toList();

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isYes
                                    ? Colors.grey.shade200
                                    : Colors.red.shade100,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isYes
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      size: 18,
                                      color: isYes
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        groupTitle,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isYes
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isYes ? "BAIK" : "KENDALA",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isYes
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (subItems.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: subItems.map((sub) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5.0),
                                                child: Icon(Icons.circle,
                                                    size: 4,
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  sub['subs_inspeksi_name']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 16),

                        // Notes Verifikasi Input Card (Required)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.rate_review_outlined,
                                      size: 18, color: darkOrange),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Catatan Hasil Verifikasi",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Text(
                                    " *Wajib",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: notesVerifikasiController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      "Tuliskan catatan evaluasi hasil verifikasi P2H di sini...",
                                  hintStyle: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.all(12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: primaryOrange, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 90), // Bottom bar spacing
                      ],
                    ),
                  ),

        // Modern Bottom Action Bar
        bottomNavigationBar: inspections.isEmpty
            ? null
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Print / PDF Button
                      Expanded(
                        flex: 3,
                        child: OutlinedButton.icon(
                          onPressed: _generateAndSharePdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined,
                              size: 16),
                          label: const Text(
                            "PDF",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkOrange,
                            side: const BorderSide(color: darkOrange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Cancel / Reject Button
                      Expanded(
                        flex: 3,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showConfirmActionDialog(isApprove: false),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text(
                            "Tolak",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Approve Button
                      Expanded(
                        flex: 4,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showConfirmActionDialog(isApprove: true),
                          icon: const Icon(Icons.check_circle_rounded,
                              size: 16, color: Colors.white),
                          label: const Text(
                            "Setujui P2H",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
