import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/po/PoHeaderPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Warna tema
final Color primaryOrange = Color(0xFFFF8C69);
final Color lightOrange = Color(0xFFFFF4E6);
final Color accentOrange = Color(0xFFFFB347);
final Color darkOrange = Color(0xFFE07B39);
final Color backgroundColor = Color(0xFFFFFAF5);
final Color cardColor = Color(0xFFFFF8F0);
final Color shadowColor = Color(0x20FF8C69);

class PoDetail extends StatefulWidget {
  final String ponbr;

  PoDetail({Key? key, required this.ponbr}) : super(key: key);

  @override
  _PoDetailState createState() => _PoDetailState();
}

class _PoDetailState extends State<PoDetail> {
  List detailList = [];
  bool isLoading = true;
  List<TextEditingController> qtyControllers = [];

  @override
  void initState() {
    super.initState();
    fetchDetailData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchDetailData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var baseUrl = GlobalData.baseUrl + "api/po/detail_po_header.jsp?method=list-po-detail&ponbr=${widget.ponbr}";
      print(baseUrl);
      var url = Uri.parse(baseUrl);
      var res = await http.get(url);

      if (res.statusCode == 200) {
        var body = res.body.trim();
        print('detail_po_header body: $body');
        if (body.isEmpty) {
          setState(() {
            detailList = [];
            qtyControllers = [];
            isLoading = false;
          });
          return;
        }
        var data = json.decode(body);
        setState(() {
          detailList = _normalizeDetailList(data);
          qtyControllers = List.generate(
            detailList.length,
                (index) => TextEditingController(
              text: (detailList[index]['qty_terima'] ?? '0').toString(),
            ),
          );
          isLoading = false;
        });
      } else {
        throw Exception("Gagal load data");
      }
    } catch (e) {
      print('fetchDetailData error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    return int.tryParse(v.toString().split('.').first) ?? 0;
  }

  /// qty_pesan = sisa (asli - sudah terima); qty_terima input = 0 jika masih outstanding
  List _normalizeDetailList(dynamic data) {
    if (data is! List) return [];
    final List result = [];
    for (final raw in data) {
      try {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);
        int sisa;
        if (item['qty_pesan_asli'] != null) {
          sisa = _toInt(item['qty_pesan_asli']) - _toInt(item['qty_sudah_terima'] ?? 0);
        } else if (item['qty_sudah_terima'] != null) {
          sisa = _toInt(item['qty_pesan']);
        } else {
          sisa = _toInt(item['qty_pesan']) - _toInt(item['qty_terima']);
        }
        if (sisa < 0) sisa = 0;
        item['qty_pesan'] = sisa.toString();
        item['qty_terima'] = sisa > 0 ? '0' : _toInt(item['qty_sudah_terima'] ?? item['qty_terima']).toString();
        result.add(item);
      } catch (e) {
        print('normalize item error: $e');
      }
    }
    return result;
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PoHeaderPage()));
  }

  Future<void> updateData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> payload = [];
    var userid = prefs.getString("name") ?? '';

    // Hanya baris yang qty terima > 0 yang di-update; kosong/0 di-skip
    for (int i = 0; i < detailList.length; i++) {
      final rawQty = qtyControllers[i].text.trim();
      if (rawQty.isEmpty) continue;

      final qtyTerima = int.tryParse(rawQty) ?? 0;
      if (qtyTerima <= 0) continue; // skip baris tanpa perubahan

      final qtyPesan = _toInt(detailList[i]['qty_pesan']);
      if (qtyTerima > qtyPesan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Qty terima baris ${i + 1} melebihi qty pesan ($qtyPesan)',
            ),
          ),
        );
        return;
      }

      payload.add({
        "method": "receive-po",
        "ponbr": widget.ponbr,
        "itditemid": detailList[i]['itditemid'],
        "partname": detailList[i]['partname'],
        "genuineno": detailList[i]['genuineno'],
        "merk": detailList[i]['merk'],
        "harga": detailList[i]['harga'],
        "qty_pesan": detailList[i]['qty_pesan'],
        "qty_terima": qtyTerima.toString(),
        "userid": userid,
      });
    }

    print("payload");
    print(payload);
    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak ada baris diupdate. Isi Qty Terima > 0 pada baris yang diterima.',
          ),
        ),
      );
      return;
    }

    try {
      EasyLoading.show(status: 'Updating...');
      var url = Uri.parse(GlobalData.baseUrl + "api/po/update_po_detail.jsp");
      var res = await http.post(url, body: {"data": json.encode(payload)});

      EasyLoading.dismiss();
      if (res.statusCode == 200) {
        var response = json.decode(res.body);
        print(response);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Berhasil update ${payload.length} baris. Baris lain di-skip.',
              ),
            ),
          );
          // Refresh detail: pesan sisa berkurang, qty terima kembali 0
          await fetchDetailData();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal update data')));
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void confirmUpdate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: cardColor,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: darkOrange, size: 24),
            const SizedBox(width: 8),
            Text(
              "Konfirmasi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkOrange,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin update data ini?",
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              updateData();
            },
            child: const Text("Ya, Update",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildRowLabelValue(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700)),
          SizedBox(width: 140, child: valueWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: Text("Detail PO ${widget.ponbr}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : detailList.isEmpty
              ? const Center(
                  child: Text("Tidak ada detail data",
                      style: TextStyle(color: Colors.grey)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        itemCount: detailList.length,
                        itemBuilder: (context, index) {
                          var item = detailList[index];
                          final partname =
                              (item['partname'] ?? '').toString();
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0x59FFB347), width: 0.8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x20FF8C69),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF4E6),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    partname.isNotEmpty
                                        ? partname
                                        : 'Item ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE07B39),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _kv("Item ID",
                                          (item['itditemid'] ?? '').toString()),
                                      _kv("Genuine No",
                                          (item['genuineno'] ?? '').toString()),
                                      _kv("Merk",
                                          (item['merk'] ?? '').toString()),
                                      _kv("Harga",
                                          (item['harga'] ?? '').toString()),
                                      _kv(
                                          "Qty Pesan",
                                          (item['qty_pesan'] ?? '')
                                              .toString()),
                                      const SizedBox(height: 4),
                                      buildRowLabelValue(
                                        "Qty Terima:",
                                        TextField(
                                          controller: qtyControllers[index],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Color(0x59FFB347)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Color(0x59FFB347)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: primaryOrange,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_outlined,
                            size: 20, color: Colors.white),
                        label: const Text("Simpan Update",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: confirmUpdate,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _kv(String label, String value) {
    if (value.trim().isEmpty || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700)),
          ),
          const SizedBox(
            width: 10,
            child: Text(":",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            flex: 5,
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
