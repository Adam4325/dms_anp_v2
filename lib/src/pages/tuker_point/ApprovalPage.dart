import 'package:flutter/material.dart';


class ApprovalPage extends StatelessWidget {
  const ApprovalPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approval HRD')),
      body: Center(child: Text('Transaksi menunggu persetujuan')),
    );
  }
}