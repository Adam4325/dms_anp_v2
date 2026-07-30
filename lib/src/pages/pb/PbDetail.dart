import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/pb/PbHeaderPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Warna tema
final Color primaryOrange = Color(0xFFFF8C69);
final Color darkOrange = Color(0xFFE07B39);
final Color backgroundColor = Color(0xFFFFFAF5);
final Color cardColor = Color(0xFFFFF8F0);
final Color shadowColor = Color(0x20FF8C69);

/// Detail PR → Outstanding PO (view-only).
/// Beda dari [PoDetail]: tidak ada edit/update; Qty Terima = hasil receive PO.
class PbDetail extends StatefulWidget {
  final String pbnbr;

  PbDetail({Key? key, required this.pbnbr}) : super(key: key);

  @override
  _PbDetailState createState() => _PbDetailState();
}

class _PbDetailState extends State<PbDetail> {
  List detailList = [];
  bool isLoading = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchDetailData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    return int.tryParse(v.toString().split('.').first) ?? 0;
  }

  /// View-only: Qty Pesan = qty asli; Qty Terima = sudah diterima dari update PO.
  List _normalizeDetailList(dynamic data) {
    if (data is! List) return [];
    final List result = [];
    for (final raw in data) {
      try {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);
        final qtyPesan = item['qty_pesan_asli'] != null
            ? _toInt(item['qty_pesan_asli'])
            : _toInt(item['qty_pesan']);
        final qtyTerima = item['qty_sudah_terima'] != null
            ? _toInt(item['qty_sudah_terima'])
            : _toInt(item['qty_terima']);
        item['qty_pesan'] = qtyPesan.toString();
        item['qty_terima'] = qtyTerima.toString();
        result.add(item);
      } catch (e) {
        print('normalize pb detail error: $e');
      }
    }
    return result;
  }

  Future<void> fetchDetailData() async {
    setState(() {
      isLoading = true;
      _errorMsg = '';
    });

    final nbr = (widget.pbnbr ?? '').toString().trim();
    if (nbr.isEmpty) {
      setState(() {
        detailList = [];
        isLoading = false;
        _errorMsg = 'Nomor PO kosong. Kembali ke list lalu buka Detail lagi.';
      });
      return;
    }

    try {
      final baseUrl = GlobalData.baseUrl +
          "api/pb/detail_pb_header.jsp?method=list-pb-detail&ponbr=${Uri.encodeComponent(nbr)}&pbnbr=${Uri.encodeComponent(nbr)}";
      print('pb detail url: $baseUrl');
      final res = await http.get(Uri.parse(baseUrl));
      print('pb detail status: ${res.statusCode}');
      print('pb detail body: ${res.body}');

      if (res.statusCode == 200) {
        final body = res.body.trim();
        if (body.isEmpty) {
          setState(() {
            detailList = [];
            isLoading = false;
            _errorMsg = 'Response API kosong';
          });
          return;
        }
        final data = json.decode(body);
        final list = _normalizeDetailList(data);
        setState(() {
          detailList = list;
          isLoading = false;
          _errorMsg = list.isEmpty ? 'Tidak ada detail untuk $nbr' : '';
        });
      } else {
        throw Exception("HTTP ${res.statusCode}");
      }
    } catch (e) {
      print('fetchDetailData pb error: $e');
      setState(() {
        detailList = [];
        isLoading = false;
        _errorMsg = 'Gagal load detail: $e';
      });
    }
  }

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PbHeaderPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: Text("Detail PO ${widget.pbnbr}",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchDetailData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : detailList.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMsg.isEmpty
                              ? 'Tidak ada detail data'
                              : _errorMsg,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange),
                          onPressed: fetchDetailData,
                          child: Text('Coba lagi',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 40),
                  itemCount: detailList.length,
                  itemBuilder: (context, index) {
                    var item = detailList[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['partname'] ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkOrange)),
                          SizedBox(height: 6),
                          _kv("Item ID",
                              (item['itditemid'] ?? '').toString()),
                          _kv("Genuine No",
                              (item['genuineno'] ?? '').toString()),
                          _kv("Merk", (item['merk'] ?? '').toString()),
                          _kv("Harga", (item['harga'] ?? '').toString()),
                          _kv("Qty Pesan",
                              (item['qty_pesan'] ?? '').toString()),
                          _kv("Qty Terima",
                              (item['qty_terima'] ?? '0').toString()),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(
            width: 10,
            child: Text(":",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 5,
            child: Text(value,
                textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
