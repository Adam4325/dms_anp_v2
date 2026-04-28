import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/po/PoHeaderPage.dart'
    show
        backgroundColor,
        cardColor,
        darkOrange,
        primaryOrange,
        shadowColor;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Detail baris PO Receive (V_PORECEIVE_DETAILDMS).
class PoReceiveDetailPage extends StatefulWidget {
  final String itxinvtrannbr;

  const PoReceiveDetailPage({Key? key, required this.itxinvtrannbr})
      : super(key: key);

  @override
  State<PoReceiveDetailPage> createState() => _PoReceiveDetailPageState();
}

class _PoReceiveDetailPageState extends State<PoReceiveDetailPage> {
  List<dynamic> _lines = [];
  bool _loading = true;
  String? _error;

  String _cell(dynamic row, List<String> keys) {
    if (row is! Map) return '';
    final m = Map<String, dynamic>.from(row);
    for (final k in keys) {
      for (final e in m.entries) {
        if (e.key.toUpperCase() == k.toUpperCase()) {
          final v = e.value;
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString();
          }
        }
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('${GlobalData.baseUrl}api/po/po_receive_detail.jsp')
          .replace(queryParameters: {
        'itxinvtrannbr': widget.itxinvtrannbr.trim(),
      });
      final res = await http.get(url);
      if (res.statusCode != 200) {
        setState(() {
          _loading = false;
          _error = 'HTTP ${res.statusCode}';
        });
        return;
      }
      final body = json.decode(res.body);
      if (body is Map && body['data'] is List) {
        setState(() {
          _lines = body['data'] as List;
          _loading = false;
        });
        return;
      }
      if (body is List) {
        setState(() {
          _lines = body;
          _loading = false;
        });
        return;
      }
      setState(() {
        _lines = [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
            ),
          ),
          const Text(':', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
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
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: const Text(
          'PO Receive Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: primaryOrange),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : _lines.isEmpty
                  ? const Center(
                      child: Text('Tidak ada baris detail',
                          style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      color: primaryOrange,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          10,
                          8,
                          10,
                          24 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: _lines.length,
                        itemBuilder: (context, index) {
                          final row = _lines[index];
                          final part = _cell(row, ['PARTNAME', 'partname']);
                          final item = _cell(row, ['ITDITEMID', 'itditemid']);
                          final qty = _cell(row, ['ITDQTY', 'itdqty']);
                          final uom = _cell(row, ['UOMID', 'uomid']);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 12),
                              title: Text(
                                part.isNotEmpty ? part : item,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkOrange,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                '$item · Qty $qty $uom',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              children: [
                                _kv('ITXINVTRANNBR',
                                    _cell(row, ['ITXINVTRANNBR', 'itxinvtrannbr'])),
                                _kv('ITXINVTRANDATE',
                                    _cell(row, ['ITXINVTRANDATE', 'itxinvtrandate'])),
                                _kv('ITDITEMID', item),
                                _kv('PARTNAME', part),
                                _kv('IDTYPE', _cell(row, ['IDTYPE', 'idtype'])),
                                _kv('IDACCESS', _cell(row, ['IDACCESS', 'idaccess'])),
                                _kv('MERK', _cell(row, ['MERK', 'merk'])),
                                _kv('GENUINENO',_cell(row, ['GENUINENO', 'genuineno'])),
                                _kv('ITDQTY', qty),
                                _kv('UOMID', uom),
                                _kv('TOWAREHOUSE',
                                    _cell(row, ['TOWAREHOUSE', 'towarehouse'])),
                                _kv('NOTANUMBER',
                                    _cell(row, ['NOTANUMBER', 'notanumber'])),
                                _kv('PONBR', _cell(row, ['PONBR', 'ponbr'])),
                                _kv('CREATED_USER',
                                    _cell(row, ['CREATED_USER', 'created_user'])),
                                _kv('TYPEPO', _cell(row, ['TYPEPO', 'typepo'])),
                                _kv('PBNBR', _cell(row, ['PBNBR', 'pbnbr'])),
                                _kv('ITDLINENBR',
                                    _cell(row, ['ITDLINENBR', 'itdlinenbr'])),
                                _kv('ITEMSIZE',
                                    _cell(row, ['ITEMSIZE', 'itemsize'])),
                                _kv('VHTID', _cell(row, ['VHTID', 'vhtid'])),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
