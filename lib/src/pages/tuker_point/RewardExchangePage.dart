import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/Provider.dart';

class RewardExchangePage extends StatefulWidget {
  final int pts;
  final String drvId;
  final String usr;
  final String loc;

  const RewardExchangePage({
    Key? key,
    this.pts = 0,
    this.drvId = '',
    this.usr = '',
    this.loc = '',
  }) : super(key: key);

  @override
  State<RewardExchangePage> createState() => _RewardExchangePageState();
}

class _RewardExchangePageState extends State<RewardExchangePage> {
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
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
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
      }
    } catch (e) {
      debugPrint("Error loading rewards: $e");
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
      disabledBackgroundColor: Colors.grey.shade400,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  Widget pmBtnLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  InputDecoration softDecoration({
    String? label,
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
    );
  }

  Widget _kv(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ' : ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: isHighlight ? darkOrange : Colors.grey.shade900,
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void confirmRedeem(Map<String, dynamic> reward) {
    quantityController.text = "1";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color: primaryOrange, size: 22),
            const SizedBox(width: 8),
            Text(
              'Konfirmasi Penukaran',
              style: TextStyle(
                color: darkOrange,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentOrange.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward['type'] ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: darkOrange,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Biaya: ${reward['pts']} Poin / item',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              cursorColor: primaryOrange,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: softDecoration(
                label: 'Jumlah Quantity',
                hint: 'Masukkan jumlah (misal: 1)',
                prefixIcon:
                    Icon(Icons.shopping_bag_outlined, color: primaryOrange, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            label: pmBtnLabel('Batal'),
            style: pmBtnStyle(Colors.grey.shade500),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 16),
            label: pmBtnLabel('Ya, Tukar'),
            style: pmBtnStyle(primaryOrange),
            onPressed: () {
              Navigator.pop(ctx);
              redeem(reward);
            },
          ),
        ],
      ),
    );
  }

  Future<void> redeem(Map<String, dynamic> r) async {
    final qtyText = quantityController.text.trim();
    if (qtyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity tidak boleh kosong')),
      );
      return;
    }

    final qty = int.tryParse(qtyText) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity harus >= 1')),
      );
      return;
    }

    final int p = r['pts'] ?? 0;
    final int totalPointsNeeded = p * qty;
    if (widget.pts < totalPointsNeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Poin tidak cukup! Butuh $totalPointsNeeded poin, poin Anda saat ini ${widget.pts}.'),
        ),
      );
      return;
    }

    try {
      final String baseUrl = '${GlobalData.baseUrl}api/points/redeem_reward.jsp';
      final String fullUrl = "$baseUrl?"
          "method=create-point"
          "&id=${r['id']}"
          "&points=${r['pts']}"
          "&qty=${r['qty']}"
          "&driverId=${widget.drvId}"
          "&createdBy=${widget.usr}"
          "&locId=${widget.loc}"
          "&type=${r['type']}"
          "&quantity_beli=$qtyText";

      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status_code'] == 200 || result['status_code'] == '200') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade700,
              content: Text(result['message'] ?? 'Penukaran berhasil diajukan'),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            load();
          }
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade700,
              content: Text(result['message'] ?? 'Penukaran gagal'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Gagal menukar reward: ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Error saat menukar reward: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Banner Poin Driver Saat Ini
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightOrange, cardColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentOrange.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Poin Anda',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.pts} Poin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: darkOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: darkOrange, size: 20),
                  tooltip: 'Muat Ulang',
                  onPressed: load,
                ),
              ],
            ),
          ),

          // List Rewards
          Expanded(
            child: loading
                ? Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  )
                : rewards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_giftcard_outlined,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada reward yang tersedia',
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
                          padding: const EdgeInsets.only(bottom: 24, top: 4),
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final r = rewards[index];
                            final bool isAvailable = r['enabled'] == true;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: accentOrange.withValues(alpha: 0.45)),
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
                                        Icon(
                                          Icons.card_giftcard,
                                          color: isAvailable
                                              ? primaryOrange
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            r['type'] ?? '-',
                                            style: TextStyle(
                                              color: isAvailable
                                                  ? darkOrange
                                                  : Colors.grey.shade700,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? primaryOrange.withValues(alpha: 0.15)
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${r['pts']} Pts',
                                            style: TextStyle(
                                              color: isAvailable
                                                  ? darkOrange
                                                  : Colors.grey.shade600,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _kv('Biaya Poin',
                                                  '${r['pts']} Point',
                                                  isHighlight: true),
                                              _kv('Stok',
                                                  '${r['qty']} ${r['uom']}'),
                                              _kv('Status',
                                                  isAvailable
                                                      ? 'Tersedia'
                                                      : 'Stok Habis / Nonaktif'),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.swap_horiz,
                                              size: 16, color: Colors.white),
                                          label: pmBtnLabel('Tukar'),
                                          style: pmBtnStyle(isAvailable
                                              ? primaryOrange
                                              : Colors.grey.shade400),
                                          onPressed: isAvailable
                                              ? () => confirmRedeem(r)
                                              : null,
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
          ),
        ],
      ),
    );
  }
}
