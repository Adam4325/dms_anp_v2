// File: lib/src/model/NotificationData.dart
// Model yang disesuaikan dengan response API Anda

class NotificationData {
  final String id;
  final String p2hnumber;
  final String drvid;
  final String note_verifikasi;
  final String is_read;

  // Additional fields untuk compatibility dengan UI
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  NotificationData({
    required this.id,
    required this.p2hnumber,
    required this.drvid,
    required this.note_verifikasi,
    required this.is_read,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id']?.toString() ?? '',
      p2hnumber: json['p2hnumber']?.toString() ?? '',
      drvid: json['drvid']?.toString() ?? '',
      note_verifikasi: json['note_verifikasi']?.toString() ?? '',
      is_read: json['is_read']?.toString() ?? '',
      title: json['p2hnumber']?.toString() ?? 'P2H Notification',
      message: json['note_verifikasi']?.toString() ?? 'Notifikasi P2H',
      timestamp: DateTime.now(),
      data: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'p2hnumber': p2hnumber,
      'drvid': drvid,
      'note_verifikasi': note_verifikasi,
      'is_read': is_read,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  @override
  String toString() {
    return 'NotificationData{id: $id, p2hnumber: $p2hnumber, drvid: $drvid, note_verifikasi: $note_verifikasi, is_read: $is_read}';
  }
}