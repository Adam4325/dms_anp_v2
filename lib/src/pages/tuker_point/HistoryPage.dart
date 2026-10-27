import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dms_anp/src/Helper/Provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Warna tema sesuai design_tab.md & design_list.md
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  List<Map<String, dynamic>> rewards = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final drvid = prefs.getString('drvid') ?? '';
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse(
            '${GlobalData.baseUrl}api/points/reward_list.jsp?method=list-reward-history&drvid=$drvid'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        rewards = data
            .map((item) => {
                  "id": item['id'],
                  "reward_number": item['reward_number'],
                  "date": item['date'],
                  "points": item['points'],
                  "status": item['status'],
                  "approved_user": item['approved_user'],
                  "created_date": item['created_date'],
                  "updated_date": item['updated_date'],
                  "reward_name": item['reward_name'],
                })
            .toList();
      }
    } catch (e) {
      debugPrint("Error loading reward history: $e");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  ButtonStyle pmBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget pmBtnLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget _kv(String label, String value, {bool dense = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 1.5 : 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: dense ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ' : ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: dense ? 11 : 12,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: dense ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDetailKuponDialog(BuildContext context, String rwdnbr) async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/points/list_detail_riwayat_kupon.jsp?rwdnbr=$rwdnbr');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: cardColor,
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            title: Row(
              children: [
                Icon(Icons.confirmation_number_outlined,
                    color: primaryOrange, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Detail Kupon",
                  style: TextStyle(
                    color: darkOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 380,
              child: jsonData.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada kupon tersedia',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: jsonData.length,
                      itemBuilder: (context, index) {
                        final item = jsonData[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: accentOrange.withValues(alpha: 0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.stars,
                                      color: primaryOrange, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Kupon #${index + 1}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: darkOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 12),
                              _kv("Nomor Kupon", item['kpnnbr'] ?? '-',
                                  dense: true),
                              _kv("Tanggal", item['kpndate'] ?? '-',
                                  dense: true),
                              _kv("Jumlah", "${item['kpnqty'] ?? 1}",
                                  dense: true),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                label: pmBtnLabel('Tutup'),
                style: pmBtnStyle(accentOrange),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching kupon detail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : rewards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada riwayat penukaran',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryOrange,
                  onRefresh: load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final status =
                          reward['status'].toString().trim().toUpperCase();
                      final bool isClosed = status == 'CLOSE';

                      final String statusText =
                          isClosed ? 'Selesai' : 'Menunggu Approval';
                      final String rewardName = reward['reward_name'] ?? '-';
                      final bool isKupon =
                          rewardName.toUpperCase().contains("KUPON");

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: accentOrange.withValues(alpha: 0.45)),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: lightOrange,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.card_giftcard,
                                      color: primaryOrange, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rewardName,
                                      style: TextStyle(
                                        color: darkOrange,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isClosed
                                          ? Colors.green.shade50
                                          : accentOrange.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isClosed
                                            ? Colors.green.shade400
                                            : accentOrange,
                                      ),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: isClosed
                                            ? Colors.green.shade800
                                            : darkOrange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Body Card
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _kv('No. Reward',
                                            reward['reward_number'] ?? '-'),
                                        _kv('Tanggal', reward['date'] ?? '-'),
                                        _kv('Poin Dipakai',
                                            '${reward['points'] ?? 0} Pts'),
                                      ],
                                    ),
                                  ),
                                  if (isKupon)
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                          Icons.confirmation_number_outlined,
                                          size: 15,
                                          color: Colors.white),
                                      label: pmBtnLabel('Detail Kupon'),
                                      style: pmBtnStyle(accentOrange),
                                      onPressed: () {
                                        final rwdnbr = reward['reward_number'];
                                        if (rwdnbr != null) {
                                          showDetailKuponDialog(
                                              context, rwdnbr);
                                        }
                                      },
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
    );
  }
}
