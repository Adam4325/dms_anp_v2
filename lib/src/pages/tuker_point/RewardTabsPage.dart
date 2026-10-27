import 'package:flutter/material.dart';

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

  // Warna tema (sesuai design_tab.md & design_list.md)
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 20.0,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reward Driver',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.card_giftcard, size: 20, color: Colors.white),
              text: 'Tukar Poin',
            ),
            Tab(
              icon: Icon(Icons.history, size: 20, color: Colors.white),
              text: 'Riwayat',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RewardExchangePage(
            pts: widget.driverPoints,
            drvId: widget.driverId,
            usr: widget.createdBy,
            loc: widget.locId,
          ),
          const HistoryPage(),
        ],
      ),
    );
  }
}
