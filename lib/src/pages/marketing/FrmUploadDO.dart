import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'ListOpenDOCemindo.dart';

/// Kolom untuk baca Excel (by header name)
const List<String> _excelColumns = [
  'DLODODETAILNUMBER', 'DLODATE', 'DLOCUSTDODATE', 'DLOORIGINALDONBR', 'DLOCUSTDONBR',
  'DLOLOCID', 'DLOLOCID2', 'ZONE', 'DLOITEMUOM', 'DLOITEMQTY',
  'DLODELIVERYDATE', 'DLOORIGIN', 'STATUS', 'LOCID', 'DLOSTATUS',
  'DLONOTES', 'DLOCUSTOMER', 'DLOITEMTYPE', 'DLODESTINATION', 'VHCID',
];

class FrmUploadDO extends StatefulWidget {
  /// Opsional: param dari item ListOpenDO - semua baris pakai dlododetailnumber yang sama
  final String? dlododetailnumber;
  final String? dlocustdonbr;
  final String? dlooriginaldonbr;

  const FrmUploadDO({
    Key? key,
    this.dlododetailnumber,
    this.dlocustdonbr,
    this.dlooriginaldonbr,
  }) : super(key: key);

  @override
  State<FrmUploadDO> createState() => _FrmUploadDOState();
}

class _FrmUploadDOState extends State<FrmUploadDO> {
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  List<Map<String, dynamic>> _tableData = [];
  String? _selectedFilePath;
  PlatformFile? _pickedFile;
  bool _loading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        setState(() {
          _pickedFile = file;
          _selectedFilePath = file.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File dipilih: ${file.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal pilih file: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih file terlebih dahulu')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.upload_file, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Upload',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengupload file ini?',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    EasyLoading.show(status: 'Memproses file...');
    try {
      List<int>? bytes;
      if (_pickedFile!.bytes != null) {
        bytes = _pickedFile!.bytes;
      } else if (_pickedFile!.path != null) {
        bytes = await File(_pickedFile!.path!).readAsBytes();
      }
      if (bytes == null) {
        throw Exception('Tidak dapat membaca file');
      }

      // Upload ke upload_do_cemindo2.jsp untuk validasi/pengecekan, response masuk ke table
      final url = Uri.parse('${GlobalData.baseUrl}api/do/upload_do_cemindo2.jsp');
      var request = http.MultipartRequest('POST', url);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: _pickedFile!.name,
      ));

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final status = res['status'];
        final message = res['message'] ?? '';
        final data = res['data'];

        if ((status == 1 || status == '1') && data != null && data is List) {
          List<Map<String, dynamic>> rows = [];
          for (var item in data) {
            if (item is Map) {
              rows.add(Map<String, dynamic>.from(
                  item.map((k, v) => MapEntry(k.toString(), v))));
            }
          }
          setState(() => _tableData = rows);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Berhasil load ${rows.length} baris data')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: $message')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error server (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Delete hanya di tabel lokal, tidak ke server
  void _deleteAll() {
    if (_tableData.isEmpty) return;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Semua data di tabel akan dihapus. Lanjutkan?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) setState(() => _tableData = []);
    });
  }

  /// Delete baris hanya di tabel lokal, tidak ke server
  void _deleteRow(int index) {
    setState(() {
      _tableData.removeAt(index);
    });
  }

  String? _getRowValue(Map<String, dynamic> row, String key) {
    final v = row[key] ?? row[key.toLowerCase()];
    final s = v?.toString().trim();
    return (s == null || s.isEmpty || s == 'null') ? null : s;
  }

  Future<void> _submit() async {
    if (_tableData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk disubmit')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Konfirmasi Submit'),
        content: Text(
          'Submit ${_tableData.length} baris data ke database?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ya', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('name') ?? '';
    String imeiid = prefs.getString('imei') ?? '';

    EasyLoading.show(status: 'Submit ke database...');
    try {
      final dlododetailnumber = widget.dlododetailnumber ?? '';
      List<Map<String, dynamic>> dataList = [];
      for (final row in _tableData) {
        dataList.add({
          'dlododetailnumber': dlododetailnumber,
          'dlodate': _getRowValue(row, 'DLODATE') ?? _getRowValue(row, 'dlodate'),
          'dlocustdodate': _getRowValue(row, 'DLOCUSTDODATE') ?? _getRowValue(row, 'dlocustdodate'),
          'dlodeliverydate': _getRowValue(row, 'DLODELIVERYDATE') ?? _getRowValue(row, 'dlodeliverydate'),
          'dlostatus': _getRowValue(row, 'DLOSTATUS') ?? _getRowValue(row, 'dlostatus') ?? 'OPEN',
          'dlocustomer': _getRowValue(row, 'DLOCUSTOMER') ?? _getRowValue(row, 'dlocustomer'),
          'dlolocid': _getRowValue(row, 'DLOLOCID') ?? _getRowValue(row, 'dlolocid'),
          'dlocustdonbr': _getRowValue(row, 'DLOCUSTDONBR') ?? _getRowValue(row, 'dlocustdonbr'),
          'dloitemtype': _getRowValue(row, 'DLOITEMTYPE') ?? _getRowValue(row, 'dloitemtype'),
          'dloitemqty': _getRowValue(row, 'DLOITEMQTY') ?? _getRowValue(row, 'dloitemqty') ?? '0',
          'dloorigin': _getRowValue(row, 'DLOORIGIN') ?? _getRowValue(row, 'dloorigin'),
          'dlodestination': _getRowValue(row, 'DLODESTINATION') ?? _getRowValue(row, 'dlodestination'),
          'dlooriginaldonbr': _getRowValue(row, 'DLOORIGINALDONBR') ?? _getRowValue(row, 'dlooriginaldonbr'),
          'dlonotes': _getRowValue(row, 'DLONOTES') ?? _getRowValue(row, 'dlonotes'),
          'dloorgitemqty': _getRowValue(row, 'DLOORGITEMQTY') ?? _getRowValue(row, 'dloorgitemqty') ??
              _getRowValue(row, 'DLOITEMQTY') ?? _getRowValue(row, 'dloitemqty') ?? '0',
          'locid': _getRowValue(row, 'LOCID') ?? _getRowValue(row, 'locid'),
          'zone': _getRowValue(row, 'ZONE') ?? _getRowValue(row, 'zone'),
          'dlolocid2': _getRowValue(row, 'DLOLOCID2') ?? _getRowValue(row, 'dlolocid2'),
          'dloitemuom': _getRowValue(row, 'DLOITEMUOM') ?? _getRowValue(row, 'dloitemuom'),
          'vhcid': _getRowValue(row, 'VHCID') ?? _getRowValue(row, 'vhcid'),
          'drvid': _getRowValue(row, 'DRVID') ?? _getRowValue(row, 'drvid') ?? '',
          'status': _getRowValue(row, 'STATUS') ?? _getRowValue(row, 'status') ?? 'NORMAL',
          'userid': user,
        });
      }

      final url = Uri.parse('${GlobalData.baseUrl}api/do/create_do_upload.jsp');
      final body = jsonEncode({
        'method': 'submit_do',
        'imeiid': imeiid,
        'user': user,
        'data': dataList,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );

      EasyLoading.dismiss();
      if (mounted) {
        if (response.statusCode == 200) {
          try {
            final res = jsonDecode(response.body);
            final status = res['status'] ?? '';
            final message = res['message'] ?? '';
            final successCount = res['success_count'] ?? 0;
            final errorCount = res['error_count'] ?? 0;

            if (status == 'OK') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Submit berhasil: $message')),
              );
              setState(() => _tableData = []);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ListOpenDOCemindo()),
              );
            } else if (status == 'PARTIAL') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$message')),
              );
              setState(() => _tableData = []);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ListOpenDOCemindo()),
              );
            } else {
              final errors = res['errors'];
              final errMsg = errors is List ? errors.join('; ') : message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal: $errMsg')),
              );
            }
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error parsing response: ${response.body}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Submit gagal (${response.statusCode}): ${response.body}')),
          );
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal submit: $e')),
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
          MaterialPageRoute(builder: (_) => ListOpenDOCemindo()),
        );
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          title: const Text(
            'Upload Delivery Order',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          elevation: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ListOpenDOCemindo()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEMPLATE UPLOAD DO HARIAN LOCO & FRANCO.xlsx',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFile,
                            icon: Icon(Icons.folder_open, color: primaryOrange, size: 20),
                            label: Text(
                              'Pilih File',
                              style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryOrange,
                              side: BorderSide(color: primaryOrange),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _uploadFile,
                            icon: const Icon(Icons.upload, color: Colors.white, size: 20),
                            label: const Text(
                              'Upload',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedFilePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'File: $_selectedFilePath',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _tableData.isEmpty ? null : _deleteAll,
                      icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 20),
                      label: const Text(
                        'Delete All',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _tableData.isEmpty ? null : _submit,
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      label: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Table
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _buildTable(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (_tableData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Belum ada data. Pilih file Excel lalu klik Upload.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    const cols = ['NO', ..._excelColumns, ''];
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.green.shade50),
      columnSpacing: 16,
      horizontalMargin: 12,
      columns: cols.map((h) => DataColumn(
        label: Text(
          h,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 11,
          ),
        ),
      )).toList(),
      rows: List.generate(_tableData.length, (i) {
        final row = _tableData[i];
        return DataRow(
          cells: [
            DataCell(Text('${i + 1}', style: const TextStyle(color: Colors.black87, fontSize: 12))),
            ..._excelColumns.map((c) => DataCell(
              Text(
                _getRowValue(row, c) ?? '-',
                style: const TextStyle(color: Colors.black87, fontSize: 11),
              ),
            )),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _deleteRow(i),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
