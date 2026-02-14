import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'HistoryPage.dart';

class RewardExchangePage extends StatefulWidget {
  final int pts;
  final String drvId;
  final String usr;
  final String loc;

  const RewardExchangePage({
    this.pts = 0,
    this.drvId = '',
    this.usr = '',
    this.loc = '',
  });

  @override
  State<RewardExchangePage> createState() => _RewardExchangePageState();
}

class _RewardExchangePageState extends State<RewardExchangePage> {
  List<Map<String, dynamic>> rewards = [];
  bool loading = false;
  TextEditingController quantityController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      final response = await http.get(Uri.parse(
          '${GlobalData.baseUrl}api/points/reward_list.jsp?method=list-reward'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        rewards = data
            .map((item) => {
                  "id": item['id'],
                  "type": item['rewardtype'],
                  "pts": item['points'],
                  "qty": item['qty'],
                  "uom": item['uom'],
                  "enabled": item['isenabled'] == 1 && item['qty'] > 0,
                })
            .toList();
        print('Rewards \n${rewards}');
      }
    } catch (e) {
      print("Error loading rewards: \n$e");
    }

    setState(() => loading = false);
  }

  Future<void> redeemOld(Map<String, dynamic> r) async {
    int p = r['pts'];

    if (widget.pts < p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Poin tidak cukup untuk menukar hadiah ini')),
      );
      return;
    }

    String nbr = "RWD${DateTime.now().millisecondsSinceEpoch}";
    Map<String, dynamic> trx = {
      "RWDNBR": nbr,
      "RWDDATE": DateTime.now().toIso8601String(),
      "RWDTYPEID": "DRIVER",
      "RWDPOINTS": p,
      "RWDQTY": r['qty'],
      "RWDSTATUS": "OPEN",
      "DRVID": widget.drvId,
      "RWDPRINT": "N",
      "RWDTO": r['type'],
      "LOCID": widget.loc,
      "RWDVNOTE": "",
      "CREATED_DATETIME": DateTime.now().toIso8601String(),
      "CREATED_USER": widget.usr,
      "APV_USER": "",
      "APV_DATETIME": null,
    };

    print("Transaksi disimpan: \n$trx");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Penukaran berhasil diajukan')),
    );
  }

  // Panggil dialog konfirmasi dulu sebelum redeem
  void confirmRedeem(Map<String, dynamic> reward) {
    quantityController.text = "1";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Penukaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin menukar reward "${reward['type']}" dengan ${reward['pts']} poin per item?',
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Ya, Tukar'),
            onPressed: () {
              Navigator.pop(context);
              final qty = int.tryParse(quantityController.text) ?? 1;
              print(reward);
              redeem(reward); // panggil fungsi dengan qty
            },
          ),
        ],
      ),
    );
  }

  // Fungsi redeem update untuk kirim ke API, cek poin dll
  Future<void> redeem(Map<String, dynamic> r) async {
    int p = r['pts'];
    int qty = int.parse(quantityController.text);
    print("widget.drvId \n${widget.drvId} {${r['type']}}");
    if (quantityController.text == null || quantityController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity tidak boleh kosong')),
      );
      return;
    }

    if (int.parse(quantityController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity harus >=1')),
      );
      return;
    }

    int totalPointsBeli = p * qty;
    if (widget.pts < p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Poin tidak cukup untuk menukar hadiah ini')),
      );
      return;
    }

    // Contoh kirim ke API pakai POST dengan id, points, qty
    try {
      String baseUrl = '${GlobalData.baseUrl}api/points/redeem_reward.jsp';
      String fullUrl = "$baseUrl?"
          "method=create-point"
          "&id=${r['id']}"
          "&points=${r['pts']}"
          "&qty=${r['qty']}"
          "&driverId=${widget.drvId}"
          "&createdBy=${widget.usr}"
          "&locId=${widget.loc}"
          "&type=${r['type']}"
          "&quantity_beli=${quantityController.text}";

      print("Calling URL: $fullUrl");

      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result);
        print(result['status_code'] == 200);
        if (result['status_code'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Penukaran berhasil')),
          );
          await Future.delayed(Duration(seconds: 2));
          Navigator.pop(context);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => ViewDashboard()),
          // );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Penukaran gagal')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menukar reward: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat menukar reward: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final r = rewards[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  shadowColor: Colors.blueAccent.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        r['type'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Point: ${r['pts']}\nQTY: ${r['qty']}\nUOM: ${r['uom']}',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 18),
                          elevation: 4,
                        ),
                        onPressed: r['enabled'] ? () => confirmRedeem(r) : null,
                        //onPressed: r['enabled'] ? () => redeem(r) : null,
                        child: Text(
                          'Tukar',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
