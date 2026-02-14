// File: lib/src/widgets/NotificationOverlay.dart
import 'package:dms_anp/src/model/NotificationData.dart';
import 'package:dms_anp/src/widgets/NotificationCard.dart';
import 'package:flutter/material.dart';

class NotificationOverlay extends StatelessWidget {
  final List<NotificationData>? notifications;
  final void Function(NotificationData)? onNotificationTap;

  const NotificationOverlay({
    Key? key,
    this.notifications,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifications == null || notifications!.isEmpty) {
      return Container();
    }

    final items = notifications!;

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Column(
        children: items.map((notification) {
          return NotificationCard(
            notification: notification,
            onTap: () => onNotificationTap?.call(notification),
          );
        }).toList(),
      ),
    );
  }
}