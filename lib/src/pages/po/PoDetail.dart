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
        var data = json.decode(res.body);
        setState(() {
          detailList = data;
          qtyControllers = List.generate(
            detailList.length,
                (index) => TextEditingController(
              text: detailList[index]['qty_terima'] ?? '',
            ),
          );
          isLoading = false;
        });
      } else {
        throw Exception("Gagal load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PoHeaderPage()));
  }

  Future<void> updateData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> payload = [];
    var userid = prefs.getString("name") ?? '';
    for (int i = 0; i < detailList.length; i++) {
      if(!qtyControllers[i].text.isEmpty){
        if(int.parse(qtyControllers[i].text)>0){
          if(int.parse(qtyControllers[i].text)<=int.parse(detailList[i]['qty_pesan'])){
            payload.add({
              "method": "receive-po",
              "ponbr": widget.ponbr,
              "itditemid": detailList[i]['itditemid'],
              "partname": detailList[i]['partname'],
              "genuineno": detailList[i]['genuineno'],
              "merk": detailList[i]['merk'],
              "harga": detailList[i]['harga'],
              "qty_pesan": detailList[i]['qty_pesan'],
              "qty_terima": qtyControllers[i].text,
              "userid": userid,
            });
          }
        }
      }

    }
    print(payload);
    try {
      EasyLoading.show(status: 'Updating...');
      var url = Uri.parse(GlobalData.baseUrl + "api/po/update_po_detail.jsp");
      var res = await http.post(url, body: {"data": json.encode(payload)});

      EasyLoading.dismiss();
      if (res.statusCode == 200) {
        var response = json.decode(res.body);
        print(response);
        print(response['status']);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data berhasil diupdate')));
          _goBack(context);
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
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 28),
            SizedBox(width: 8),
            Text(
              "Konfirmasi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin update data ini?",
          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent,
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
            child: Text("Ya"),
          ),
        ],
      ),
    );
  }


  Widget buildRowLabelValue(String label, Widget valueWidget) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Container(width: 140, child: valueWidget),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: Text("Detail PO ${widget.ponbr}",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : detailList.isEmpty
          ? Center(
          child: Text("Tidak ada detail data",
              style: TextStyle(color: Colors.grey)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
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
                      _kv("Item ID", (item['itditemid'] ?? '').toString()),
                      _kv("Genuine No", (item['genuineno'] ?? '').toString()),
                      _kv("Merk", (item['merk'] ?? '').toString()),
                      _kv("Harga", (item['harga'] ?? '').toString()),
                      _kv("Qty Pesan", (item['qty_pesan'] ?? '').toString()),
                      buildRowLabelValue(
                        "Qty Terima:",
                        TextField(
                          controller: qtyControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
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
            margin: EdgeInsets.fromLTRB(12, 12, 12, 60),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: confirmUpdate,
              child: Text("Update", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
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
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(
            width: 10,
            child: Text(":", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 5,
            child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
