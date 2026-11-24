import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';

abstract class HseRepository {
  Future<List<ViolationTypeModel>> fetchViolationTypes(String entityType);

  Future<List<String>> fetchSanctionTypes(String entityType);

  Future<List<EntityPreviewModel>> searchEntities(
    String entityType,
    String query,
  );

  Future<EntityPreviewModel> lookupEntity(String entityType, String id);

  Future<Map<String, dynamic>> createFinding(FindingSubmissionModel payload);

  Future<HseListResult> listFindings({
    required String username,
    String statusFlow = 'ALL',
    String entityType = 'ALL',
    String query = '',
  });

  Future<HseFindingItem> detailFinding({
    required String username,
    required String findingNo,
  });

  Future<String> submitRepair({
    required String username,
    required String findingNo,
    required String repairActionNote,
    required String evidenceAfterBase64,
  });

  Future<String> verifyShe({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  });

  Future<String> approveBp({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  });

  Future<String> finalApprove({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  });

  Future<List<LockedDriverItem>> listLockedDrivers({
    required String username,
    String query = '',
  });

  Future<String> unlockDriver({
    required String username,
    required String drvid,
    String notes = '',
  });
}

