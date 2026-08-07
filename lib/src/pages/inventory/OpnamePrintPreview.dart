import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Preview billing-style Stock Opname: share image + print thermal.
class OpnamePrintPreview extends StatefulWidget {
  final Map<String, dynamic> data;

  const OpnamePrintPreview({Key? key, required this.data}) : super(key: key);

  @override
  State<OpnamePrintPreview> createState() => _OpnamePrintPreviewState();
}

class _OpnamePrintPreviewState extends State<OpnamePrintPreview> {
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);

  final GlobalKey _previewKey = GlobalKey();
  bool _busy = false;
  bool _mutasiLoading = false;
  bool _mutasiLoaded = false;
  String _mutasiTitle = '';
  String _mutasiSaldoAwal = '0';
  List<Map<String, dynamic>> _mutasiDetails = [];

  String _s(dynamic v) {
    if (v == null) return '';
    final t = v.toString().trim();
    if (t == 'null') return '';
    return t;
  }

  String get _whId => _s(widget.data['whswarehpuseid']);
  String get _itemId => _s(widget.data['wh_item_id']);
  String get _month {
    final m = _s(widget.data['wh_with_month_month']);
    if (m.isNotEmpty) return m;
    final raw = _s(widget.data['wh_withmonth']);
    final parts = raw.split(RegExp(r'[-/]'));
    if (parts.length >= 2) {
      return int.tryParse(parts[1])?.toString() ?? '';
    }
    return '';
  }

  String get _year {
    final y = _s(widget.data['wh_with_month_year']);
    if (y.isNotEmpty) return y;
    final raw = _s(widget.data['wh_withmonth']);
    final parts = raw.split(RegExp(r'[-/]'));
    if (parts.isNotEmpty) {
      return int.tryParse(parts[0])?.toString() ?? '';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadMutasiForPrint();
  }

  Future<void> _loadMutasiForPrint() async {
    if (_mutasiLoading) return;
    setState(() => _mutasiLoading = true);
    try {
      if (_whId.isEmpty || _itemId.isEmpty || _month.isEmpty || _year.isEmpty) {
        if (mounted) {
          setState(() {
            _mutasiLoaded = true;
            _mutasiLoading = false;
            _mutasiTitle = 'DETAIL MUTASI';
          });
        }
        return;
      }
      final uri = Uri.parse(
              '${GlobalData.baseUrl}api/inventory/list_warehouse_opname_detail_mutasi.jsp')
          .replace(queryParameters: {
        'method': 'list-mutasi-opname-v1',
        'warehouseid': _whId,
        'itemid': _itemId,
        'month': _month,
        'year': _year,
      });
      print('preview mutasi url: $uri');
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final body = json.decode(res.body.trim());
      if (body is! Map) {
        throw Exception('Response tidak valid');
      }
      final detailsRaw = body['details'];
      final List<Map<String, dynamic>> rows = [];
      if (detailsRaw is List) {
        for (final e in detailsRaw) {
          if (e is Map) rows.add(Map<String, dynamic>.from(e));
        }
      }
      if (!mounted) return;
      setState(() {
        _mutasiTitle = (body['title'] ?? 'DETAIL MUTASI').toString();
        _mutasiSaldoAwal = (body['saldo_awal'] ?? '0').toString();
        _mutasiDetails = rows;
        _mutasiLoaded = true;
        _mutasiLoading = false;
      });
    } catch (e) {
      print('preview load mutasi error: $e');
      if (!mounted) return;
      setState(() {
        _mutasiLoaded = true;
        _mutasiLoading = false;
        _mutasiTitle = 'DETAIL MUTASI';
      });
    }
  }

  Future<void> _ensureMutasiReady() async {
    if (_mutasiLoaded) return;
    if (_mutasiLoading) {
      // tunggu loading selesai
      while (_mutasiLoading && mounted) {
        await Future.delayed(Duration(milliseconds: 80));
      }
      return;
    }
    await _loadMutasiForPrint();
  }

  Future<void> _shareAsImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _ensureMutasiReady();
      // tunggu frame setelah setState agar detail ikut ke RepaintBoundary
      await Future.delayed(Duration(milliseconds: 120));
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _previewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Preview belum siap');
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Gagal capture preview');

      final dir = await getTemporaryDirectory();
      final safe = 'stock_opname_${_whId}_${_itemId}'
          .replaceAll(RegExp(r'[/\\:*?"<>| ]'), '_');
      final file = File('${dir.path}/$safe.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Stock Opname $_whId - $_itemId',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal share: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _ensureBluetoothReady() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print thermal hanya tersedia di Android/iOS')),
      );
      return false;
    }
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();
      final denied =
          statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied);
      if (denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin Bluetooth diperlukan untuk print')),
        );
        return false;
      }
    }
    final btOn = await PrintBluetoothThermal.bluetoothEnabled;
    if (!btOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nyalakan Bluetooth terlebih dahulu')),
      );
      return false;
    }
    return true;
  }

  Future<void> _printThermal() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _ensureMutasiReady();
      final ok = await _ensureBluetoothReady();
      if (!ok) return;

      final paired = await PrintBluetoothThermal.pairedBluetooths;
      if (paired.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Tidak ada perangkat Bluetooth. Pair printer thermal di Settings HP dulu.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _busy = false); // allow sheet interaction
      final selected = await showModalBottomSheet<BluetoothInfo>(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Pilih Printer Thermal',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: darkOrange,
                      fontSize: 16,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: paired.length,
                    itemBuilder: (_, i) {
                      final p = paired[i];
                      return ListTile(
                        leading: Icon(Icons.print, color: primaryOrange),
                        title: Text(p.name.isEmpty ? 'Unknown' : p.name),
                        subtitle: Text(p.macAdress),
                        onTap: () => Navigator.pop(ctx, p),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (selected == null) return;

      setState(() => _busy = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menghubungkan ke ${selected.name}...')),
      );
      final connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: selected.macAdress);
      if (!connected) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal connect ke printer')),
        );
        return;
      }

      // pastikan mutasi sudah ada di ticket
      await _ensureMutasiReady();
      final bytes = await _buildOpnameTicket();
      final printed = await PrintBluetoothThermal.writeBytes(bytes);
      await PrintBluetoothThermal.disconnect;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(printed ? 'Print berhasil' : 'Print gagal')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error print: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<List<int>> _buildOpnameTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final d = widget.data;
    List<int> bytes = [];

    bytes += generator.text(
      'STOCK OPNAME',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr();
    bytes += generator.text('WH ID: ${_s(d['whswarehpuseid'])}');
    bytes += generator.text('Item ID: ${_s(d['wh_item_id'])}');
    final qrData = _s(d['wh_item_id']);
    if (qrData.isNotEmpty) {
      bytes += generator.feed(1);
      bytes += generator.qrcode(
        qrData,
        align: PosAlign.center,
        size: QRSize.size5,
        cor: QRCorrection.M,
      );
      bytes += generator.feed(1);
    }
    bytes += generator.text('Part Name: ${_s(d['wh_part_name'])}');
    bytes += generator.text('Item Desc: ${_s(d['wh_item_descr'])}');
    bytes += generator.text('Genuine No: ${_s(d['wh_genuine_no'])}');
    bytes += generator.text('Item Size: ${_s(d['wh_item_size'])}');
    bytes += generator.text('Type: ${_s(d['wh_type'])}');
    bytes += generator.text('Accessories: ${_s(d['wh_access'])}');
    bytes += generator.text('Type PO: ${_s(d['wh_typepo'])}');
    bytes += generator.text('Currency: ${_s(d['wh_curyid'])}');
    bytes += generator.text('Qty On Books: ${_s(d['wh_on_hands'])}');
    bytes += generator.text('Qty On Actual: ${_s(d['wh_on_actual'])}');
    bytes += generator.text('With Month: ${_s(d['wh_withmonth'])}');
    bytes += generator.hr();
    if (_mutasiTitle.isNotEmpty) {
      bytes += generator.text(_mutasiTitle,
          styles: PosStyles(bold: true, align: PosAlign.center));
    } else {
      bytes += generator.text('DETAIL MUTASI',
          styles: PosStyles(bold: true, align: PosAlign.center));
    }
    bytes += generator.text('Saldo Awal: $_mutasiSaldoAwal');
    if (_mutasiDetails.isEmpty) {
      bytes += generator.text('(Tidak ada mutasi)');
    } else {
      bytes += generator.text('Date|In|Out|Saldo|User');
      for (final row in _mutasiDetails) {
        final date = _s(row['date']);
        final din = _s(row['qty_in']);
        final dout = _s(row['qty_out']);
        final saldo = _s(row['saldo_akhir']);
        final user = _s(row['user']);
        bytes += generator.text('$date $din/$dout=$saldo $user');
      }
    }
    bytes += generator.hr();
    bytes += generator.text(
      'DMS ANP',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Widget _buildMutasiSectionForPreview() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentOrange.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              _mutasiTitle.isEmpty ? 'DETAIL MUTASI' : _mutasiTitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: darkOrange,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4, 6, 4, 8),
            child: _mutasiLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Saldo Awal : $_mutasiSaldoAwal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: darkOrange,
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      if (_mutasiDetails.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Tidak ada mutasi di bulan ini',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  headingRowHeight: 30,
                                  dataRowMinHeight: 26,
                                  dataRowMaxHeight: 34,
                                  horizontalMargin: 6,
                                  columnSpacing: 10,
                                  headingRowColor:
                                      WidgetStateProperty.all(lightOrange),
                                  columns: const [
                                    DataColumn(
                                        label: Text('Date',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700))),
                                    DataColumn(
                                        label: Text('In',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700))),
                                    DataColumn(
                                        label: Text('Out',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700))),
                                    DataColumn(
                                        label: Text('Saldo Akhir',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700))),
                                    DataColumn(
                                        label: Text('User',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700))),
                                  ],
                                  rows: _mutasiDetails.map((d) {
                                    return DataRow(cells: [
                                      DataCell(Text(_s(d['date']),
                                          style: TextStyle(fontSize: 10))),
                                      DataCell(Text(_s(d['qty_in']),
                                          style: TextStyle(fontSize: 10))),
                                      DataCell(Text(_s(d['qty_out']),
                                          style: TextStyle(fontSize: 10))),
                                      DataCell(Text(_s(d['saldo_akhir']),
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600))),
                                      DataCell(Text(_s(d['user']),
                                          style: TextStyle(fontSize: 10))),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _billingRow(String label, String value, {bool highlight = false}) {
    final v = value.isEmpty ? '-' : value;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(':  ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? darkOrange : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard() {
    final d = widget.data;
    return RepaintBoundary(
      key: _previewKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, accentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  Text(
                    'DMS ANP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'STOCK OPNAME BARANG',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DETAIL ITEM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 8),
                  _billingRow('WH ID', _s(d['whswarehpuseid']), highlight: true),
                  _billingRow('Item ID', _s(d['wh_item_id']), highlight: true),
                  if (_s(d['wh_item_id']).isNotEmpty) ...[
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accentOrange.withOpacity(0.6)),
                        ),
                        child: QrImageView(
                          data: _s(d['wh_item_id']),
                          version: QrVersions.auto,
                          size: 160,
                          backgroundColor: Colors.white,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: darkOrange,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        _s(d['wh_item_id']),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: darkOrange,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  _billingRow('Part Name', _s(d['wh_part_name'])),
                  _billingRow('Item Desc', _s(d['wh_item_descr'])),
                  _billingRow('Genuine No', _s(d['wh_genuine_no'])),
                  _billingRow('Item Size', _s(d['wh_item_size'])),
                  _billingRow('Type', _s(d['wh_type'])),
                  _billingRow('Accessories', _s(d['wh_access'])),
                  _billingRow('Type PO', _s(d['wh_typepo'])),
                  _billingRow('Currency', _s(d['wh_curyid'])),
                  Divider(height: 20, color: Colors.grey.shade300),
                  Text(
                    'QUANTITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 8),
                  _billingRow('Qty On Books', _s(d['wh_on_hands']),
                      highlight: true),
                  _billingRow('Qty On Actual', _s(d['wh_on_actual']),
                      highlight: true),
                  _billingRow('With Month', _s(d['wh_withmonth'])),
                  _buildMutasiSectionForPreview(),
                ],
              ),
            ),
          ],
        ),
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
        elevation: 0,
        title: Text(
          'Preview Stock Opname',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildBillingCard(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _shareAsImage,
                          icon: Icon(Icons.share, size: 18),
                          label: Text('Share Image'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkOrange,
                            side: BorderSide(color: accentOrange),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _busy ? null : _printThermal,
                          icon: Icon(Icons.print, size: 18, color: Colors.white),
                          label: Text(
                            'Print',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_busy) ...[
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      color: primaryOrange,
                      backgroundColor: lightOrange,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
