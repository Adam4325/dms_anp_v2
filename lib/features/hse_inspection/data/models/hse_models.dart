import 'package:dms_anp/src/Helper/Provider.dart';

class HseEntityType {
  static const String karyawan = 'KARYAWAN';
  static const String driver = 'DRIVER';
  static const String mobil = 'MOBIL';

  static const List<String> all = [karyawan, driver, mobil];

  static String label(String type) {
    switch (type.toUpperCase()) {
      case karyawan:
        return 'Karyawan';
      case driver:
        return 'Driver';
      case mobil:
        return 'Mobil / Unit';
      default:
        return type;
    }
  }

  static String searchLabel(String type) {
    switch (type.toUpperCase()) {
      case karyawan:
        return 'ID Karyawan (NIP) / Nama';
      case driver:
        return 'ID Driver / No SIM / Nama';
      case mobil:
        return 'No Polisi / No Lambung';
      default:
        return 'ID Target';
    }
  }

  static List<String> sanctionOptions(String type) {
    switch (type.toUpperCase()) {
      case karyawan:
        return [
          'Teguran Lisan',
          'Surat Peringatan 1 (SP1)',
          'Surat Peringatan 2 (SP2)',
          'Surat Peringatan 3 (SP3)',
          'PHK / Rujuk HRD',
        ];
      case driver:
        return [
          'Teguran',
          'Surat Peringatan (SP)',
          'Skorsing Jalan',
          'Pelatihan Refreshment DDT',
        ];
      case mobil:
        return [
          'Minor Repair',
          'Grounded / Pool Stop',
          'Perbaikan Bengkel Luar',
        ];
      default:
        return ['Teguran'];
    }
  }

  static String lockEffectHint(String type) {
    switch (type.toUpperCase()) {
      case karyawan:
        return 'Temuan berstatus ONGOING; setelah di-Approve HRD/ADMIN status KRYSTATUS menjadi BP hingga Final Unlock.';
      case driver:
        return 'Temuan berstatus ONGOING; setelah di-Approve OPR/ADMIN status DRVSTATUS menjadi BP hingga Final Unlock.';
      case mobil:
        return 'Temuan berstatus ONGOING; setelah di-Approve OPR/ADMIN status VHCSTATUS menjadi BP hingga Final Unlock.';
      default:
        return '';
    }
  }
}

class ViolationTypeModel {
  final String violationId;
  final String entityTarget;
  final String categoryName;
  final String severityLevel;

  const ViolationTypeModel({
    required this.violationId,
    required this.entityTarget,
    required this.categoryName,
    required this.severityLevel,
  });

  factory ViolationTypeModel.fromJson(Map<String, dynamic> json) {
    return ViolationTypeModel(
      violationId: (json['violation_id'] ?? '').toString(),
      entityTarget: (json['entity_target'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      severityLevel: (json['severity_level'] ?? 'MEDIUM').toString(),
    );
  }
}

class EntityPreviewModel {
  final String entityType;
  final String id;
  final String title;
  final String subtitle;
  final String detail;
  final String division;
  final String position;
  final String branchOrPool;
  final String phone;
  final String statusMaster;
  final String photoUrl;
  final bool isLocked;
  final String? activeLockTicket;

  const EntityPreviewModel({
    required this.entityType,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.division,
    required this.position,
    required this.branchOrPool,
    required this.phone,
    required this.statusMaster,
    required this.photoUrl,
    required this.isLocked,
    this.activeLockTicket,
  });

  String get fullPhotoUrl => resolveServerUrl(photoUrl);

  factory EntityPreviewModel.fromJson(Map<String, dynamic> json) {
    final ticketRaw = json['active_lock_ticket'];
    final ticket =
        ticketRaw == null || ticketRaw.toString().trim().isEmpty
            ? null
            : ticketRaw.toString().trim();
    return EntityPreviewModel(
      entityType: (json['entity_type'] ?? '').toString().toUpperCase(),
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      detail: (json['detail'] ?? '').toString(),
      division: (json['division'] ?? '').toString(),
      position: (json['position'] ?? '').toString(),
      branchOrPool: (json['branch_or_pool'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      statusMaster: (json['status_master'] ?? '').toString(),
      photoUrl: (json['photo_url'] ?? '').toString(),
      isLocked: json['is_locked'] == true || json['is_locked'] == 1,
      activeLockTicket: ticket,
    );
  }
}

class FindingSubmissionModel {
  final String entityType;
  final String entityId;
  final String incidentDate;
  final String violationCategory;
  final String sanctionLevel;
  final String description;
  final String evidenceBeforeBase64;
  final String dueDate;
  final String createdBy;

  const FindingSubmissionModel({
    required this.entityType,
    required this.entityId,
    required this.incidentDate,
    required this.violationCategory,
    required this.sanctionLevel,
    required this.description,
    required this.evidenceBeforeBase64,
    required this.dueDate,
    required this.createdBy,
  });

  Map<String, String> toFormMap() {
    return {
      'method': 'create-finding',
      'username': createdBy,
      'created_by': createdBy,
      'entity_type': entityType,
      'entity_id': entityId,
      'incident_date': incidentDate,
      'violation_category': violationCategory,
      'sanction_level': sanctionLevel,
      'description': description,
      'evidence_before': evidenceBeforeBase64,
      'due_date': dueDate,
    };
  }
}

class HseSummaryModel {
  final int totalLocked;
  final int totalOngoing;
  final int totalOpen;
  final int totalBp;
  final int totalWaitingShe;
  final int totalWaitingFinalOpr;
  final int totalWaitingFinalHrd;
  final int totalWaitingFinal;
  final int totalComplete;
  final bool canCreate;
  final bool isAdmin;
  final bool isHd;
  final bool isOp;

  const HseSummaryModel({
    this.totalLocked = 0,
    this.totalOngoing = 0,
    this.totalOpen = 0,
    this.totalBp = 0,
    this.totalWaitingShe = 0,
    this.totalWaitingFinalOpr = 0,
    this.totalWaitingFinalHrd = 0,
    this.totalWaitingFinal = 0,
    this.totalComplete = 0,
    this.canCreate = false,
    this.isAdmin = false,
    this.isHd = false,
    this.isOp = false,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  factory HseSummaryModel.fromJson(Map<String, dynamic> json) {
    final ongoingCount = _toInt(json['total_ongoing'] ?? json['total_open']);
    return HseSummaryModel(
      totalLocked: _toInt(json['total_locked']),
      totalOngoing: ongoingCount,
      totalOpen: ongoingCount,
      totalBp: _toInt(json['total_bp']),
      totalWaitingShe: _toInt(json['total_waiting_she']),
      totalWaitingFinalOpr: _toInt(json['total_waiting_final_opr']),
      totalWaitingFinalHrd: _toInt(json['total_waiting_final_hrd']),
      totalWaitingFinal: _toInt(json['total_waiting_final']),
      totalComplete: _toInt(json['total_complete']),
      canCreate: json['can_create'] == true,
      isAdmin: json['is_admin'] == true,
      isHd: json['is_hd'] == true,
      isOp: json['is_op'] == true,
    );
  }
}

class HseFindingItem {
  final String findingNo;
  final String entityType;
  final String entityId;
  final String entityName;
  final String entitySubtitle;
  final String entityMasterStatus;
  final String kryId;
  final String drvId;
  final String vhcId;

  final String incidentDate;
  final String violationCategory;
  final String sanctionLevel;
  final String description;
  final String evidenceBeforeUrl;
  final String dueDate;

  final String statusFlow;
  final bool isLocked;

  final String repairActionNote;
  final String evidenceAfterUrl;
  final String repairedBy;
  final String repairedDate;

  final bool sheVerified;
  final String sheVerifiedBy;
  final String sheVerifiedDate;
  final String sheNotes;

  final String finalApproverRole;
  final bool finalApproved;
  final String finalApprovedBy;
  final String finalApprovedDate;
  final String finalNotes;

  final String createdBy;
  final String createdAt;

  final bool canApproveBp;
  final bool canRepair;
  final bool canVerifyShe;
  final bool canFinalApprove;

  const HseFindingItem({
    required this.findingNo,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.entitySubtitle,
    required this.entityMasterStatus,
    required this.kryId,
    required this.drvId,
    required this.vhcId,
    required this.incidentDate,
    required this.violationCategory,
    required this.sanctionLevel,
    required this.description,
    required this.evidenceBeforeUrl,
    required this.dueDate,
    required this.statusFlow,
    required this.isLocked,
    required this.repairActionNote,
    required this.evidenceAfterUrl,
    required this.repairedBy,
    required this.repairedDate,
    required this.sheVerified,
    required this.sheVerifiedBy,
    required this.sheVerifiedDate,
    required this.sheNotes,
    required this.finalApproverRole,
    required this.finalApproved,
    required this.finalApprovedBy,
    required this.finalApprovedDate,
    required this.finalNotes,
    required this.createdBy,
    required this.createdAt,
    required this.canApproveBp,
    required this.canRepair,
    required this.canVerifyShe,
    required this.canFinalApprove,
  });

  String get fullBeforeUrl => resolveServerUrl(evidenceBeforeUrl);
  String get fullAfterUrl => resolveServerUrl(evidenceAfterUrl);

  String get statusLabel {
    switch (statusFlow.toUpperCase()) {
      case 'ONGOING':
      case 'OPEN':
        return 'ONGOING (Menunggu Approval BP)';
      case 'BP':
        return 'Status BP (Terkunci)';
      case 'IN_PROGRESS':
        return 'Dalam Perbaikan (BP)';
      case 'WAITING_SHE':
        return 'Menunggu Verifikasi SHE';
      case 'WAITING_FINAL':
        return 'Menunggu Final Unlock $finalApproverRole';
      case 'COMPLETE':
        return 'Selesai (Active / Unlocked)';
      case 'REJECTED':
        return isLocked ? 'Ditolak (Tetap BP)' : 'Ditolak';
      default:
        return statusFlow;
    }
  }

  factory HseFindingItem.fromJson(Map<String, dynamic> json) {
    return HseFindingItem(
      findingNo: (json['finding_no'] ?? '').toString(),
      entityType: (json['entity_type'] ?? '').toString().toUpperCase(),
      entityId: (json['entity_id'] ?? '').toString(),
      entityName: (json['entity_name'] ?? '').toString(),
      entitySubtitle: (json['entity_subtitle'] ?? '').toString(),
      entityMasterStatus: (json['entity_master_status'] ?? '').toString(),
      kryId: (json['kryid'] ?? '').toString(),
      drvId: (json['drvid'] ?? '').toString(),
      vhcId: (json['vhcid'] ?? '').toString(),
      incidentDate: (json['incident_date'] ?? '').toString(),
      violationCategory: (json['violation_category'] ?? '').toString(),
      sanctionLevel: (json['sanction_level'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      evidenceBeforeUrl: (json['evidence_before_url'] ?? '').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
      statusFlow: (json['status_flow'] ?? 'OPEN').toString().toUpperCase(),
      isLocked: json['is_locked'] == true || json['is_locked'] == 1,
      repairActionNote: (json['repair_action_note'] ?? '').toString(),
      evidenceAfterUrl: (json['evidence_after_url'] ?? '').toString(),
      repairedBy: (json['repaired_by'] ?? '').toString(),
      repairedDate: (json['repaired_date'] ?? '').toString(),
      sheVerified: json['she_verified'] == true || json['she_verified'] == 1,
      sheVerifiedBy: (json['she_verified_by'] ?? '').toString(),
      sheVerifiedDate: (json['she_verified_date'] ?? '').toString(),
      sheNotes: (json['she_notes'] ?? '').toString(),
      finalApproverRole: (json['final_approver_role'] ?? '').toString().toUpperCase(),
      finalApproved:
          json['final_approved'] == true || json['final_approved'] == 1,
      finalApprovedBy: (json['final_approved_by'] ?? '').toString(),
      finalApprovedDate: (json['final_approved_date'] ?? '').toString(),
      finalNotes: (json['final_notes'] ?? '').toString(),
      createdBy: (json['created_by'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      canApproveBp: json['can_approve_bp'] == true,
      canRepair: json['can_repair'] == true,
      canVerifyShe: json['can_verify_she'] == true,
      canFinalApprove: json['can_final_approve'] == true,
    );
  }
}

class HseListResult {
  final HseSummaryModel summary;
  final List<HseFindingItem> items;

  const HseListResult({
    required this.summary,
    required this.items,
  });
}

String resolveServerUrl(String rawPath) {
  final p = rawPath.trim();
  if (p.isEmpty) return '';
  if (p.startsWith('http://') || p.startsWith('https://')) {
    return p;
  }
  final base = GlobalData.baseUrlOri.endsWith('/')
      ? GlobalData.baseUrlOri
      : '${GlobalData.baseUrlOri}/';
  final cleaned = p.startsWith('/') ? p.substring(1) : p;
  return '$base$cleaned';
}

class LockedDriverItem {
  final String drvid;
  final String drvname;
  final String drvnickname;
  final String drvlicensenbr;
  final String drvlicensetype;
  final String cabang;
  final String vehicletype;
  final String drvstatus;
  final String phone;
  final String findingNo;
  final String incidentDate;
  final String violationCategory;
  final String sanctionLevel;
  final String description;
  final String evidenceBeforeUrl;
  final String statusFlow;
  final bool isLocked;

  const LockedDriverItem({
    required this.drvid,
    required this.drvname,
    this.drvnickname = '',
    this.drvlicensenbr = '',
    this.drvlicensetype = '',
    this.cabang = '',
    this.vehicletype = '',
    this.drvstatus = 'BP',
    this.phone = '',
    this.findingNo = '',
    this.incidentDate = '',
    this.violationCategory = '',
    this.sanctionLevel = '',
    this.description = '',
    this.evidenceBeforeUrl = '',
    this.statusFlow = '',
    this.isLocked = true,
  });

  String get fullBeforeUrl => resolveServerUrl(evidenceBeforeUrl);

  factory LockedDriverItem.fromJson(Map<String, dynamic> json) {
    return LockedDriverItem(
      drvid: (json['drvid'] ?? '').toString(),
      drvname: (json['drvname'] ?? '').toString(),
      drvnickname: (json['drvnickname'] ?? '').toString(),
      drvlicensenbr: (json['drvlicensenbr'] ?? '').toString(),
      drvlicensetype: (json['drvlicensetype'] ?? '').toString(),
      cabang: (json['cabang'] ?? '').toString(),
      vehicletype: (json['vehicletype'] ?? '').toString(),
      drvstatus: (json['drvstatus'] ?? 'BP').toString(),
      phone: (json['phone'] ?? '').toString(),
      findingNo: (json['finding_no'] ?? '').toString(),
      incidentDate: (json['incident_date'] ?? '').toString(),
      violationCategory: (json['violation_category'] ?? '').toString(),
      sanctionLevel: (json['sanction_level'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      evidenceBeforeUrl: (json['evidence_before_url'] ?? '').toString(),
      statusFlow: (json['status_flow'] ?? '').toString(),
      isLocked: json['is_locked'] == true || json['is_locked'] == 1,
    );
  }
}

