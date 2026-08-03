import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Fetch + tampilkan detail mutasi stock opname (collapse / always open).
class OpnameMutasiPanel extends StatefulWidget {
  final String warehouseId;
  final String itemId;
  final String month;
  final String year;
  final bool initiallyExpanded;
  final bool alwaysExpanded;
  final Color primaryOrange;
  final Color lightOrange;
  final Color accentOrange;
  final Color darkOrange;

  const OpnameMutasiPanel({
    Key? key,
    required this.warehouseId,
    required this.itemId,
    required this.month,
    required this.year,
    this.initiallyExpanded = false,
    this.alwaysExpanded = false,
    this.primaryOrange = const Color(0xFFFF8C69),
    this.lightOrange = const Color(0xFFFFF4E6),
    this.accentOrange = const Color(0xFFFFB347),
    this.darkOrange = const Color(0xFFE07B39),
  }) : super(key: key);

  @override
  State<OpnameMutasiPanel> createState() => _OpnameMutasiPanelState();
}

class _OpnameMutasiPanelState extends State<OpnameMutasiPanel> {
  bool _loading = false;
  bool _loaded = false;
  String _error = '';
  String _title = '';
  String _saldoAwal = '0';
  List<Map<String, dynamic>> _details = [];

  @override
  void initState() {
    super.initState();
    if (widget.alwaysExpanded || widget.initiallyExpanded) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    final wh = widget.warehouseId.trim();
    final item = widget.itemId.trim();
    final month = widget.month.trim();
    final year = widget.year.trim();
    if (wh.isEmpty || item.isEmpty || month.isEmpty || year.isEmpty) {
      setState(() {
        _error = 'Data gudang/item/bulan tidak lengkap';
        _loaded = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final uri = Uri.parse(
              '${GlobalData.baseUrl}api/inventory/list_warehouse_opname_detail_mutasi.jsp')
          .replace(queryParameters: {
        'method': 'list-mutasi-opname-v1',
        'warehouseid': wh,
        'itemid': item,
        'month': month,
        'year': year,
      });
      print('opname mutasi url: $uri');
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
          if (e is Map) {
            rows.add(Map<String, dynamic>.from(e));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _title = (body['title'] ?? 'DETAIL').toString();
        _saldoAwal = (body['saldo_awal'] ?? '0').toString();
        _details = rows;
        _loaded = true;
        _loading = false;
        if ((body['status'] ?? '') == 'error') {
          _error = (body['message'] ?? 'Gagal load detail').toString();
        }
      });
    } catch (e) {
      print('opname mutasi error: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loaded = true;
        _loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.primaryOrange,
            ),
          ),
        ),
      );
    }
    if (_error.isNotEmpty && _details.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Text(_error,
            style: TextStyle(fontSize: 11, color: Colors.red.shade700)),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'Saldo Awal : $_saldoAwal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.darkOrange,
              ),
            ),
          ),
          SizedBox(height: 6),
          if (_details.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('Tidak ada mutasi di bulan ini',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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
                          WidgetStateProperty.all(widget.lightOrange),
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
                      rows: _details.map((d) {
                        return DataRow(cells: [
                          DataCell(Text((d['date'] ?? '-').toString(),
                              style: TextStyle(fontSize: 10))),
                          DataCell(Text((d['qty_in'] ?? '0').toString(),
                              style: TextStyle(fontSize: 10))),
                          DataCell(Text((d['qty_out'] ?? '0').toString(),
                              style: TextStyle(fontSize: 10))),
                          DataCell(Text((d['saldo_akhir'] ?? '0').toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600))),
                          DataCell(Text((d['user'] ?? '-').toString(),
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
    );
  }

  String get _headerTitle {
    if (_title.isNotEmpty) return _title;
    final m = widget.month.padLeft(2, '0');
    final y = widget.year;
    return 'DETAIL : $m $y';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alwaysExpanded) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.accentOrange.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.lightOrange,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                _headerTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: widget.darkOrange,
                  fontSize: 13,
                ),
              ),
            ),
            _buildBody(),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.accentOrange.withOpacity(0.45)),
        ),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          childrenPadding: EdgeInsets.zero,
          iconColor: widget.darkOrange,
          collapsedIconColor: widget.darkOrange,
          title: Text(
            _loaded ? _headerTitle : 'Detail Mutasi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: widget.darkOrange,
              fontSize: 13,
            ),
          ),
          onExpansionChanged: (open) {
            if (open && !_loaded && !_loading) {
              _load();
            }
          },
          children: [_buildBody()],
        ),
      ),
    );
  }
}
