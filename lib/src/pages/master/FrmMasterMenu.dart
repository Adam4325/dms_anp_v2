import 'package:dms_anp/src/pages/FrmMasterData.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/master/ListUjBaru.dart';
import 'package:flutter/material.dart';

/// Hub Master: Master Data Lainnya + Master UJ Baru
class FrmMasterMenu extends StatelessWidget {
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ViewDashboard()),
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentOrange.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Color(0x20FF8C69),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: darkOrange, size: 28),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: primaryOrange),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack(context);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          elevation: 2,
          centerTitle: true,
          title: Text(
            'Master',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _goBack(context),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Text(
              'Pilih menu master',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 14),
            _menuCard(
              context: context,
              icon: Icons.folder_shared_outlined,
              title: 'Master Data Lainnya',
              subtitle: 'Customer, Origin, Destination, Item, dll.',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => FrmMasterData()),
                );
              },
            ),
            _menuCard(
              context: context,
              icon: Icons.payments_outlined,
              title: 'Master UJ Baru',
              subtitle: 'List & form Uang Jalan (UJS Baru)',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ListUjBaru()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
