import 'dart:async';
import 'dart:convert';

import 'package:dms_anp/features/hse_inspection/data/datasources/hse_remote_datasource.dart';
import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/features/hse_inspection/presentation/controllers/hse_wizard_notifier.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_finding_detail_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_main_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_unlock_driver_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/entity_search_step.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHseRepo implements HseRepository {
  final HseFindingItem finding;
  final List<EntityPreviewModel> drivers;
  final List<LockedDriverItem> lockedDrivers;
  bool unlockCalled = false;

  _FakeHseRepo({
    required this.finding,
    required this.drivers,
    this.lockedDrivers = const [],
  });

  @override
  Future<List<ViolationTypeModel>> fetchViolationTypes(String entityType) async =>
      const [];

  @override
  Future<List<String>> fetchSanctionTypes(String entityType) async =>
      HseEntityType.sanctionOptions(entityType);

  @override
  Future<List<EntityPreviewModel>> searchEntities(
    String entityType,
    String query,
  ) async =>
      drivers;

  @override
  Future<EntityPreviewModel> lookupEntity(String entityType, String id) async =>
      drivers.first;

  @override
  Future<Map<String, dynamic>> createFinding(
          FindingSubmissionModel payload) async =>
      const {};

  @override
  Future<HseListResult> listFindings({
    required String username,
    String statusFlow = 'ALL',
    String entityType = 'ALL',
    String query = '',
  }) async =>
      HseListResult(
        summary: const HseSummaryModel(),
        items: [finding],
      );

  @override
  Future<HseFindingItem> detailFinding({
    required String username,
    required String findingNo,
  }) async =>
      finding;

  @override
  Future<String> submitRepair({
    required String username,
    required String findingNo,
    required String repairActionNote,
    required String evidenceAfterBase64,
  }) async =>
      'OK';

  @override
  Future<String> verifyShe({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  }) async =>
      'OK';

  @override
  Future<String> approveBp({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  }) async =>
      'OK';

  @override
  Future<String> finalApprove({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  }) async =>
      'OK';

  @override
  Future<List<LockedDriverItem>> listLockedDrivers({
    required String username,
    String query = '',
  }) async =>
      lockedDrivers;

  @override
  Future<String> unlockDriver({
    required String username,
    required String drvid,
    String notes = '',
  }) async {
    unlockCalled = true;
    return 'Driver $drvid dibuka menjadi Active';
  }
}

void main() {
  testWidgets(
      'Status OPEN renders APPROVED (SET BP) when authorized',
      (tester) async {
    final openFinding = HseFindingItem.fromJson({
      'finding_no': 'FND-20261111-0099',
      'entity_type': 'KARYAWAN',
      'entity_id': '1184-020118.81',
      'entity_name': 'ARIF SARIFUDIN',
      'entity_subtitle': 'IT',
      'entity_master_status': 'Active',
      'incident_date': '2026-11-11',
      'violation_category': 'Tidak Menggunakan APD Lengkap',
      'sanction_level': 'Teguran Lisan',
      'description': 'apd',
      'status_flow': 'OPEN',
      'is_locked': false,
      'final_approver_role': 'HRD',
      'created_by': 'ADMIN',
      'created_at': '2026-11-11 13:13:00',
      'can_approve_bp': true,
      'can_repair': false,
      'can_verify_she': false,
      'can_final_approve': false,
    });

    final repo = _FakeHseRepo(finding: openFinding, drivers: const []);
    await tester.pumpWidget(
      MaterialApp(
        home: HseFindingDetailPage(
          initialItem: openFinding,
          username: 'ADMIN',
          repository: repo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('APPROVED'), 300);
    await tester.pumpAndSettle();

    expect(find.text('APPROVED'), findsOneWidget);
    expect(find.text('Input Tindakan Perbaikan (After)'), findsNothing);
  });

  testWidgets(
      'Status BP renders Input Tindakan Perbaikan (After)',
      (tester) async {
    final bpFinding = HseFindingItem.fromJson({
      'finding_no': 'FND-20261111-0100',
      'entity_type': 'DRIVER',
      'entity_id': '0036-05.2001.22.11.61',
      'entity_name': 'DRIVER TEST',
      'entity_subtitle': 'CBT',
      'entity_master_status': 'BP',
      'incident_date': '2026-11-11',
      'violation_category': 'Melanggar Batas Kecepatan / GPS Overspeed',
      'sanction_level': 'Teguran Lisan',
      'description': 'overspeed',
      'status_flow': 'BP',
      'is_locked': true,
      'final_approver_role': 'OPR',
      'created_by': 'ADMIN',
      'created_at': '2026-11-11 14:00:00',
      'can_approve_bp': false,
      'can_repair': true,
      'can_verify_she': false,
      'can_final_approve': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HseFindingDetailPage(
          initialItem: bpFinding,
          username: 'ADMIN',
          repository: _FakeHseRepo(finding: bpFinding, drivers: const []),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('Input Tindakan Perbaikan (After)'), 300);
    await tester.pumpAndSettle();
    expect(find.text('Input Tindakan Perbaikan (After)'), findsOneWidget);
  });

  testWidgets(
      'Status WAITING_FINAL renders APPROVED & UNLOCK',
      (tester) async {
    final waitingFinalFinding = HseFindingItem.fromJson({
      'finding_no': 'FND-20261111-0101',
      'entity_type': 'MOBIL',
      'entity_id': 'B 9001 KIN',
      'entity_name': 'B 9001 KIN',
      'entity_subtitle': 'CBT',
      'entity_master_status': 'BP',
      'incident_date': '2026-11-11',
      'violation_category': 'Ban Botak / Aus / Tidak Layak Jalan',
      'sanction_level': 'Minor Repair',
      'description': 'ban aus',
      'status_flow': 'WAITING_FINAL',
      'is_locked': true,
      'final_approver_role': 'OPR',
      'created_by': 'ADMIN',
      'created_at': '2026-11-11 14:00:00',
      'can_approve_bp': false,
      'can_repair': false,
      'can_verify_she': false,
      'can_final_approve': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HseFindingDetailPage(
          initialItem: waitingFinalFinding,
          username: 'MAJID',
          repository:
              _FakeHseRepo(finding: waitingFinalFinding, drivers: const []),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('APPROVED & UNLOCK'), 300);
    await tester.pumpAndSettle();
    expect(find.text('APPROVED & UNLOCK'), findsOneWidget);
  });

  testWidgets('Driver list shows DRVID before SIM even if subtitle omits it',
      (tester) async {
    const driverItem = EntityPreviewModel(
      entityType: 'DRIVER',
      id: '1125-06.2013.08.02.79',
      title: 'A. JUNAEDI',
      subtitle: 'SIM: 790213220289 | Status: Active',
      detail: 'Pool: CILEGON | TRAILER',
      division: 'TRAILER',
      position: 'DRIVER',
      branchOrPool: 'CILEGON',
      phone: '',
      statusMaster: 'Active',
      photoUrl: '',
      isLocked: false,
    );
    final repo = _FakeHseRepo(
      finding: HseFindingItem.fromJson({}),
      drivers: const [driverItem],
    );
    final notifier = HseWizardNotifier(repository: repo, username: 'ADMIN');
    await notifier.init();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EntitySearchStep(notifier: notifier),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
          'DRVID: 1125-06.2013.08.02.79 | SIM: 790213220289 | Status: Active'),
      findsOneWidget,
    );
  });

  test('HseRemoteDataSource searchEntities retries once on TimeoutException',
      () async {
    int attempts = 0;
    final mockClient = MockClient((request) async {
      attempts++;
      if (attempts == 1) {
        throw TimeoutException('Simulated timeout');
      }
      return http.Response(
        json.encode({
          'status_code': 200,
          'message': 'OK',
          'data': [
            {
              'entity_type': 'DRIVER',
              'id': '6821-11.2022.18.08.78',
              'title': 'AGUS JUNAEDI B KISUT',
              'subtitle':
                  'DRVID: 6821-11.2022.18.08.78 | SIM: 780813282227 | Status: BP',
              'detail': 'Pool: KARAWANG JSI | LT',
              'status_master': 'BP',
              'is_locked': true,
              'active_lock_ticket': '',
            }
          ],
        }),
        200,
      );
    });

    final ds = HseRemoteDataSource(client: mockClient);
    final results = await ds.searchEntities('DRIVER', 'JUNAEDI B KISUT');
    expect(attempts, 2);
    expect(results, hasLength(1));
    expect(results.first.title, 'AGUS JUNAEDI B KISUT');
  });

  testWidgets(
      'System back unfocuses Driver search before confirming exit in HseMainPage',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'username': 'ADMIN',
      'akses_pages': ['HD', 'OP'],
    });
    const driverItem = EntityPreviewModel(
      entityType: 'DRIVER',
      id: '6821-11.2022.18.08.78',
      title: 'AGUS JUNAEDI B KISUT',
      subtitle:
          'DRVID: 6821-11.2022.18.08.78 | SIM: 780813282227 | Status: BP',
      detail: 'Pool: KARAWANG JSI | LT',
      division: 'LT',
      position: 'DRIVER',
      branchOrPool: 'KARAWANG JSI',
      phone: '',
      statusMaster: 'BP',
      photoUrl: '',
      isLocked: true,
    );
    final repo = _FakeHseRepo(
      finding: HseFindingItem.fromJson({'finding_no': 'FND-TEST-1'}),
      drivers: const [driverItem],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HseMainPage(
          initialRoles: const ['HD', 'OP'],
          repository: repo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fieldFinder = find.byType(TextField).first;
    await tester.tap(fieldFinder);
    await tester.enterText(fieldFinder, 'JUNAEDI B KISUT');
    await tester.pump();

    // First system back only unfocuses TextField and keeps HseMainPage open.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('HSE Inspeksi & Lock Finding'), findsOneWidget);
    expect(find.text('Kembali ke Dashboard?'), findsNothing);

    // Second system back asks confirmation instead of silently dropping out.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Kembali ke Dashboard?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('HSE Inspeksi & Lock Finding'), findsOneWidget);
  });

  testWidgets(
      'Status ONGOING renders APPROVED (SET BP) and badge displays ONGOING',
      (tester) async {
    final ongoingFinding = HseFindingItem.fromJson({
      'finding_no': 'FND-20261118-0001',
      'entity_type': 'KARYAWAN',
      'entity_id': '1184-020118.81',
      'entity_name': 'RIZAL TEST',
      'entity_subtitle': 'HRD',
      'entity_master_status': 'Active',
      'incident_date': '2026-11-18',
      'violation_category': 'Tidak Menggunakan APD Lengkap',
      'sanction_level': 'Teguran Lisan',
      'description': 'apd',
      'status_flow': 'ONGOING',
      'is_locked': false,
      'final_approver_role': 'HRD',
      'created_by': 'ADMIN',
      'created_at': '2026-11-18 13:13:00',
      'can_approve_bp': true,
      'can_repair': false,
      'can_verify_she': false,
      'can_final_approve': false,
    });

    final repo = _FakeHseRepo(finding: ongoingFinding, drivers: const []);
    await tester.pumpWidget(
      MaterialApp(
        home: HseFindingDetailPage(
          initialItem: ongoingFinding,
          username: 'ADMIN',
          repository: repo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ONGOING'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('APPROVED'), 300);
    await tester.pumpAndSettle();
    expect(find.text('APPROVED'), findsOneWidget);
  });

  testWidgets(
      'HseUnlockDriverPage displays locked driver and executes unlock to Active',
      (tester) async {
    final lockedDrv = LockedDriverItem.fromJson({
      'drvid': '0036-05.2001.22.11.61',
      'drvname': 'BAMBANG DRIVER',
      'cabang': 'JAKARTA',
      'drvlicensenbr': '1234567890',
      'drvlicensetype': 'B2 UMUM',
      'drvstatus': 'BP',
      'finding_no': 'FND-20261118-0002',
      'incident_date': '2026-11-18',
      'violation_category': 'Overspeed',
      'sanction_level': 'Teguran',
      'description': 'kecepatan tinggi',
      'is_locked': true,
    });

    final repo = _FakeHseRepo(
      finding: HseFindingItem.fromJson({'finding_no': 'FND-TEST-1'}),
      drivers: const [],
      lockedDrivers: [lockedDrv],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HseUnlockDriverPage(
            username: 'RIZAL',
            repository: repo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BAMBANG DRIVER'), findsOneWidget);
    expect(find.text('Buka Status Driver (Set Active)'), findsOneWidget);

    await tester.tap(find.text('Buka Status Driver (Set Active)'));
    await tester.pumpAndSettle();

    expect(find.text('Buka Status Driver?'), findsOneWidget);
    await tester.tap(find.text('Ya, Buka Status'));
    await tester.pumpAndSettle();

    expect(repo.unlockCalled, isTrue);
  });
}
