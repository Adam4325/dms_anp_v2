import 'package:flutter/material.dart';

// Import halaman yang sudah ada (sesuaikan path)
import 'RewardExchangePage.dart';
import 'HistoryPage.dart';

class RewardTabsPage extends StatefulWidget {
  final int driverPoints;
  final String driverId;
  final String createdBy;
  final String locId;

  const RewardTabsPage({
    Key? key,
    this.driverPoints = 0,
    this.driverId = '',
    this.createdBy = '',
    this.locId = '',
  }) : super(key: key);

  @override
  State<RewardTabsPage> createState() => _RewardTabsPageState();
}

class _RewardTabsPageState extends State<RewardTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reward Driver'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.card_giftcard), text: 'Tukar Poin'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Kita panggil RewardExchangePage dengan parameter dari sini
          RewardExchangePage(
            pts: widget.driverPoints,
            drvId: widget.driverId,
            usr: widget.createdBy,
            loc: widget.locId,
          ),
          // HistoryPage, kalau mau pass parameter bisa dimodifikasi
          const HistoryPage(),
        ],
      ),
    );
  }
}
