import 'package:flutter/material.dart';

class RewardDetailPage extends StatelessWidget {
  final Map<String, dynamic> reward;

  const RewardDetailPage({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reward['rewardtype'] ?? 'Detail Reward')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Poin: \n${reward['points']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Qty: \n${reward['qty']} \n${reward['uom']}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Fungsi tukar reward dari detail
              },
              child: Text('Tukar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
