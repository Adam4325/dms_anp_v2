class AduanItem {
  final int id;
  final String? submitterDrvId;
  final String? submitterKryId;
  final String submitterUsername;
  final String? submitterLoginname;
  final String status;
  final String pesan;
  final String? createdAt;
  final String? closedAt;
  final String? closedByUsername;

  AduanItem({
    required this.id,
    this.submitterDrvId,
    this.submitterKryId,
    required this.submitterUsername,
    this.submitterLoginname,
    required this.status,
    required this.pesan,
    this.createdAt,
    this.closedAt,
    this.closedByUsername,
  });

  bool get isOpen => status.toUpperCase() == 'OPEN';

  factory AduanItem.fromJson(Map<String, dynamic> j) {
    int id = 0;
    final raw = j['id'];
    if (raw is int) {
      id = raw;
    } else if (raw != null) {
      id = int.tryParse(raw.toString()) ?? 0;
    }
    return AduanItem(
      id: id,
      submitterDrvId: j['submitter_drvid']?.toString(),
      submitterKryId: j['submitter_kryid']?.toString(),
      submitterUsername: j['submitter_username']?.toString() ?? '',
      submitterLoginname: j['submitter_loginname']?.toString(),
      status: j['status']?.toString() ?? '',
      pesan: j['pesan']?.toString() ?? '',
      createdAt: j['created_at']?.toString(),
      closedAt: j['closed_at']?.toString(),
      closedByUsername: j['closed_by_username']?.toString(),
    );
  }
}
