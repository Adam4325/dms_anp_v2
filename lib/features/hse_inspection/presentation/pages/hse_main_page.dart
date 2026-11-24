import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_approval_dashboard_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_unlock_driver_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_wizard_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HseMainPage extends StatefulWidget {
  final List<String> initialRoles;
  final HseRepository? repository;

  const HseMainPage({
    Key? key,
    this.initialRoles = const [],
    this.repository,
  }) : super(key: key);

  @override
  State<HseMainPage> createState() => _HseMainPageState();
}

class _HseMainPageState extends State<HseMainPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<HseWizardPageState> _wizardKey =
      GlobalKey<HseWizardPageState>();
  final GlobalKey<HseApprovalDashboardPageState> _listKey =
      GlobalKey<HseApprovalDashboardPageState>();
  final GlobalKey<HseUnlockDriverPageState> _unlockDriverKey =
      GlobalKey<HseUnlockDriverPageState>();

  TabController? _tabController;
  String _username = '';
  bool _isAdmin = false;
  bool _isHd = false;
  bool _isOp = false;
  bool _ready = false;
  bool _confirmingExit = false;

  @override
  void initState() {
    super.initState();
    _initRoles();
  }

  Future<void> _initRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final u = (prefs.getString('username') ?? '').trim().toUpperCase();
    final l = (prefs.getString('loginname') ?? '').trim().toUpperCase();
    final storedRoles =
        prefs.getStringList('akses_pages') ?? widget.initialRoles;
    final roleSet = storedRoles
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toSet();

    final isAdmin = u == 'ADMIN' || l == 'ADMIN' || u.startsWith('ADMIN');
    final isHd = isAdmin || roleSet.contains('HD');
    final isOp = isAdmin || roleSet.contains('OP');

    TabController? controller;
    if (isHd) {
      controller = TabController(length: 3, vsync: this);
    }

    if (!mounted) return;
    setState(() {
      _username = u;
      _isAdmin = isAdmin;
      _isHd = isHd;
      _isOp = isOp;
      _tabController?.dispose();
      _tabController = controller;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  bool get _hasAccess => _isAdmin || _isHd || _isOp;

  void _exitToDashboard() {
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ViewDashboard()),
    );
  }

  Future<void> _handleSystemBack() async {
    if (!_ready || !_hasAccess) {
      _exitToDashboard();
      return;
    }

    // Keep typing inside search/form fields: system back/left-edge gesture
    // first dismisses text focus rather than exiting to ViewDashboard.
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null &&
        focus is! FocusScopeNode &&
        focus.context?.findAncestorStateOfType<EditableTextState>() != null) {
      focus.unfocus();
      return;
    }

    if (_isHd &&
        _tabController?.index == 0 &&
        (_wizardKey.currentState?.handleBackStep() ?? false)) {
      return;
    }

    if (_confirmingExit) return;
    _confirmingExit = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kembali ke Dashboard?'),
        content: const Text(
          'Keluar dari modul HSE Inspeksi dan kembali ke Dashboard Utama?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: HseTheme.btnStyle(HseTheme.primaryOrange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Keluar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    _confirmingExit = false;
    if (confirmed == true && mounted) {
      _exitToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) _handleSystemBack();
        },
        child: const Scaffold(
          backgroundColor: HseTheme.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: HseTheme.primaryOrange),
          ),
        ),
      );
    }

    if (!_hasAccess) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) _handleSystemBack();
        },
        child: Scaffold(
          backgroundColor: HseTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: HseTheme.primaryOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _exitToDashboard,
            ),
            title: const Text('HSE Inspeksi'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock_outline, size: 52, color: HseTheme.lockRed),
                  SizedBox(height: 12),
                  Text(
                    'Akses modul HSE hanya tersedia untuk role ADMIN, HRD (HD), dan OPR (OP).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // HD & ADMIN: 2 Tabs (Buat Temuan + Daftar & Approval)
    if (_isHd && _tabController != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) _handleSystemBack();
        },
        child: Scaffold(
          backgroundColor: HseTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: HseTheme.primaryOrange,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _exitToDashboard,
            ),
            title: const Text(
              'HSE Inspeksi & Lock Finding',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.add_moderator_outlined, size: 20),
                  text: 'Buat Temuan',
                ),
                Tab(
                  icon: Icon(Icons.fact_check_outlined, size: 20),
                  text: 'Daftar & Approval',
                ),
                Tab(
                  icon: Icon(Icons.lock_open_rounded, size: 20),
                  text: 'Unlock Driver',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              HseWizardPage(
                key: _wizardKey,
                username: _username,
                repository: widget.repository,
                onFindingCreated: () {
                  _listKey.currentState?.loadData();
                  _unlockDriverKey.currentState?.loadData();
                },
                onOpenListTab: () {
                  _listKey.currentState?.loadData();
                  _tabController?.animateTo(1);
                },
              ),
              HseApprovalDashboardPage(
                key: _listKey,
                username: _username,
                isOpOnly: false,
                isHdOnly: !_isAdmin && _isHd && !_isOp,
                repository: widget.repository,
              ),
              HseUnlockDriverPage(
                key: _unlockDriverKey,
                username: _username,
                repository: widget.repository,
              ),
            ],
          ),
        ),
      );
    }

    // OP-only: Approval & Monitoring view ONLY (tanpa Buat Temuan)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) _handleSystemBack();
      },
      child: Scaffold(
        backgroundColor: HseTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: HseTheme.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _exitToDashboard,
          ),
          title: const Text(
            'HSE - Approval OPR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _listKey.currentState?.loadData(),
            ),
          ],
        ),
        body: HseApprovalDashboardPage(
          key: _listKey,
          username: _username,
          isOpOnly: true,
          isHdOnly: false,
          repository: widget.repository,
        ),
      ),
    );
  }
}

