import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> rewards = [];
  bool loading = false;

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var drvid = prefs.getString('drvid');
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse('${GlobalData.baseUrl}api/points/reward_list.jsp?method=list-reward-history&drvid=${drvid}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        rewards = data.map((item) => {
          "id": item['id'],
          "reward_number": item['reward_number'],
          "date": item['date'],
          "points": item['points'],
          "status": item['status'],
          "approved_user": item['approved_user'],
          "created_date": item['created_date'],
          "updated_date": item['updated_date'],
          "reward_name": item['reward_name']
        }).toList();
        print('Rewards \n$rewards');
      }
    } catch (e) {
      print("Error loading rewards: \n$e");
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void showDetailKuponDialog(BuildContext context, String rwdnbr) async {
    final url = Uri.parse('${GlobalData.baseUrl}api/points/list_detail_riwayat_kupon.jsp?rwdnbr=$rwdnbr');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Detail Kupon"),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: jsonData.length,
                itemBuilder: (context, index) {
                  final item = jsonData[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Kupon",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // _buildDetailRow("Nomor Reward", item['rwdnbr']),
                          _buildDetailRow("Nomor Kupon", item['kpnnbr']),
                          _buildDetailRow("Tanggal Kupon", item['kpndate']),
                          _buildDetailRow("Jumlah Kupon", item['kpnqty']),
                          _buildDetailRow("Tipe Reward", item['rewardtype']),
                          _buildDetailRow("Nama Driver", item['rwdto']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Tutup"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Gagal"),
            content: Text("Gagal mengambil data (${response.statusCode})"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Tutup"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Terjadi kesalahan: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Riwayat Penukaran')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          final status = reward['status'].toString().toUpperCase();
          final bool isClosed = status == 'CLOSE';

          final Color statusColor = isClosed ? Colors.green : Colors.blue;
          final Color backgroundColor = isClosed ? Colors.green.shade100 : Colors.blue.shade100;
          final String statusText = isClosed ? 'Selesai' : 'Menunggu';
          final String detailRiwayat = reward['reward_name']!= null && reward['reward_name'].toString().toUpperCase().contains("KUPON")?"Detail":"";
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon di kiri
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.card_giftcard, color: statusColor),
                  ),
                  // Konten utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward['reward_name'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('No. Reward: ${reward['reward_number'] ?? '-'}'),
                        Text('Tanggal: ${reward['date'] ?? '-'}'),
                        Text('Poin: ${reward['points'] ?? 0}'),
                      ],
                    ),
                  ),
                  // Status dan tombol detail
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (detailRiwayat.isNotEmpty)
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Tambahkan aksi tombol detail di sini
                            final rwdnbr = reward['reward_number'];
                            showDetailKuponDialog(context, rwdnbr);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: statusColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: const Size(0, 0), // Supaya kecil dan rapat
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
