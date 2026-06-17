import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/services/AduanService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FrmUnitRev extends StatefulWidget {
  const FrmUnitRev({super.key});

  @override
  State<FrmUnitRev> createState() => _FrmUnitRevState();
}

class _FrmUnitRevState extends State<FrmUnitRev> {
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);

  static const int _pageSize = 10;
  static const List<String> _unitStatusOptions = [
    'CLOSE',
    'ONGOING',
    'SERVICE',
  ];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  int _offset = 0;
  int _total = 0;
  String _username = '';
  Set<String> _statusRoleUsers = <String>{};

  int get _totalPages {
    if (_total <= 0) return 1;
    return ((_total - 1) ~/ _pageSize) + 1;
  }

  int get _currentPage => (_offset ~/ _pageSize) + 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initSession();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      _loadMoreUnits();
    }
  }

  Future<void> _loadMoreUnits() async {
    if (_loading || _loadingMore || _currentPage >= _totalPages) return;
    await _fetchUnits(append: true);
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    _statusRoleUsers = await AduanService.fetchRoleAksesNotifUsers();
    await _fetchUnits(resetOffset: true);
  }

  bool _canEditUnitStatus() {
    final u = _username.trim().toUpperCase();
    if (u.isEmpty) return false;
    return _statusRoleUsers.contains(u);
  }

  String _normalizeKmValue(String raw) {
    if (raw.isEmpty || raw == '-') return '';
    return raw.trim();
  }

  String _normalizeUnitStatus(String raw) {
    if (raw.isEmpty || raw == '-') return '';
    final upper = raw.trim().toUpperCase();
    return _unitStatusOptions.contains(upper) ? upper : '';
  }

  String _defaultUnitStatus(Map<String, dynamic> unit) {
    final raw = _cell(unit, ['STATUS', 'status']);
    final normalized = _normalizeUnitStatus(raw);
    if (normalized.isNotEmpty) return normalized;
    if (raw == '-' || raw.trim().isEmpty) return '';
    return raw.trim().toUpperCase();
  }

  String _defaultUnitKm(Map<String, dynamic> unit) {
    return _normalizeKmValue(_cell(unit, ['VHCKM', 'vhckm']));
  }

  String _resolveStatusParam({
    required bool canEditRole,
    required String selectedStatus,
    required String defaultStatus,
  }) {
    if (canEditRole && selectedStatus.isNotEmpty) {
      return selectedStatus;
    }
    return defaultStatus;
  }

  String _resolveKmParam({
    required bool canEditRole,
    required String inputKm,
    required String defaultKm,
  }) {
    if (canEditRole && inputKm.trim().isNotEmpty) {
      return inputKm.trim();
    }
    return defaultKm;
  }

  bool _validateKmInput({
    required String inputKm,
    required String previousKm,
    required void Function(String message) onError,
  }) {
    final trimmed = inputKm.trim();
    final previous = previousKm.trim();
    if (trimmed == previous) {
      return true;
    }
    if (trimmed.isEmpty) {
      onError('KM wajib diisi');
      return false;
    }
    final newKm = int.tryParse(trimmed);
    if (newKm == null) {
      onError('KM harus berupa angka');
      return false;
    }
    final prevKm = int.tryParse(previous) ?? 0;
    if (newKm < prevKm) {
      onError('KM tidak boleh lebih kecil dari KM sebelumnya ($prevKm)');
      return false;
    }
    return true;
  }

  String _cell(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      final v = row[k];
      if (v != null && v.toString().trim().isNotEmpty && v.toString() != 'null') {
        return v.toString();
      }
    }
    return '-';
  }

  void _logApiRequest(String tag, Uri uri) {
    debugPrint('========== FrmUnitRev API [$tag] ==========');
    debugPrint('URL: ${uri.toString()}');
    if (uri.queryParameters.isEmpty) {
      debugPrint('Parameters: (none)');
    } else {
      debugPrint('Parameters:');
      uri.queryParameters.forEach((key, value) {
        debugPrint('  $key = $value');
      });
    }
    debugPrint('==========================================');
  }

  Future<void> _fetchUnits({bool resetOffset = false, bool append = false}) async {
    if (_loading || (_loadingMore && append)) return;
    if (append && _currentPage >= _totalPages) return;

    if (append) {
      _offset += _pageSize;
    } else if (resetOffset) {
      _offset = 0;
    }

    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() => _loading = true);
    }

    try {
      final search = _searchController.text.trim();
      final uri = Uri.parse('${GlobalData.baseUrl}api/units/frm_unit.jsp').replace(
        queryParameters: {
          'method': 'list-row-unit',
          'limit': '$_pageSize',
          'offset': '$_offset',
          if (search.isNotEmpty) 'search': search,
        },
      );
      _logApiRequest(
        append ? 'list-row-unit (load more)' : 'list-row-unit',
        uri,
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final body = _safeJsonDecode(res.body);
      if (body == null) {
        throw Exception('Response API kosong atau bukan JSON');
      }
      if (body is Map && body['status']?.toString() == 'error') {
        throw Exception(body['message']?.toString() ?? 'Gagal load data');
      }
      final data = body is Map ? body['data'] : body;
      _total = body is Map ? _readTotal(body) : 0;
      final pageItems = data is List
          ? data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      if (append) {
        _items.addAll(pageItems);
      } else {
        _items = pageItems;
      }
    } catch (e) {
      if (append) {
        _offset -= _pageSize;
        if (_offset < 0) _offset = 0;
      }
      if (mounted && !append) {
        alert(context, 0, e.toString(), 'error');
        _items = [];
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  dynamic _safeJsonDecode(String body) {
    final raw = body.trim();
    if (raw.isEmpty) {
      return null;
    }
    final objStart = raw.indexOf('{');
    final arrStart = raw.indexOf('[');
    var from = 0;
    if (objStart >= 0 && (arrStart < 0 || objStart < arrStart)) {
      from = objStart;
    } else if (arrStart >= 0) {
      from = arrStart;
    }
    return json.decode(raw.substring(from));//
  }//

  int _readTotal(dynamic body) {
    if (body is! Map) return 0;
    final raw = body['total'] ?? body['TOTAL'] ?? body['cnt'] ?? body['CNT'];
    if (raw == null) return 0;
    return int.tryParse(raw.toString().trim()) ?? 0;
  }

  Future<({List<S2Choice<String>> choices, int total})> _fetchLookupPage({
    required String apiFile,
    required String method,
    required String search,
    required int offset,
    String? ensureValue,
    String? ensureTitle,
  }) async {
    final uri = Uri.parse('${GlobalData.baseUrl}api/units/$apiFile').replace(
      queryParameters: {
        'method': method,
        'limit': '$_pageSize',
        'offset': '$offset',
        if (search.isNotEmpty) 'search': search,
      },
    );
    _logApiRequest('$apiFile / $method', uri);
    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        return (choices: <S2Choice<String>>[], total: 0);
      }
      final body = _safeJsonDecode(res.body);
      if (body is Map && body['status']?.toString() == 'error') {
        throw Exception(body['message']?.toString() ?? 'Gagal load data');
      }
      final data = body is Map ? body['data'] : null;
      final total = _readTotal(body);
      final choices = <S2Choice<String>>[];
      final seen = <String>{};

      if (ensureValue != null &&
          ensureValue.isNotEmpty &&
          !seen.contains(ensureValue)) {
        choices.add(S2Choice(
          value: ensureValue,
          title: (ensureTitle != null && ensureTitle.isNotEmpty)
              ? ensureTitle
              : ensureValue,
        ));
        seen.add(ensureValue);
      }

      if (data is List) {
        for (final raw in data) {
          if (raw is! Map) continue;
          final m = Map<String, dynamic>.from(raw);
          final value =
              _cell(m, ['value', 'VALUE', 'locid', 'LOCID', 'drvid', 'DRVID']);
          final title = _cell(
              m, ['title', 'TITLE', 'drvname', 'DRVNAME', 'locid', 'LOCID']);
          if (value.isEmpty || value == '-' || seen.contains(value)) continue;
          choices.add(
              S2Choice(value: value, title: title == '-' ? value : title));
          seen.add(value);
        }
      }
      return (choices: choices, total: total);
    } on FormatException catch (e) {
      debugPrint('Lookup JSON error [$uri]: $e');
      return (choices: <S2Choice<String>>[], total: 0);
    }
  }

  Future<List<S2Choice<String>>> _fetchPagedChoices({
    required String apiFile,
    required String method,
    required String search,
    required int offset,
    String? ensureValue,
    String? ensureTitle,
  }) async {
    final result = await _fetchLookupPage(
      apiFile: apiFile,
      method: method,
      search: search,
      offset: offset,
      ensureValue: ensureValue,
      ensureTitle: ensureTitle,
    );
    return result.choices;
  }

  Future<void> _updateUnitAndRefresh({
    required String vhcid,
    required String locid,
    required String drvid,
    required String status,
    required String vhckm,
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    EasyLoading.show(status: 'Menyimpan...');
    try {
      final uri = Uri.parse('${GlobalData.baseUrl}api/units/frm_unit.jsp').replace(
        queryParameters: {
          'method': 'update-unit',
          'vhcid': vhcid,
          'locid': locid,
          'drvid': drvid,
          'userid': _username,
          'status': status,
          'vhckm': vhckm,
        },
      );
      _logApiRequest('update-unit', uri);
      final res = await http.get(uri);
      final body = _safeJsonDecode(res.body);
      if (body is Map && body['status']?.toString() == 'success') {
        if (EasyLoading.isShow) EasyLoading.dismiss();
        await _fetchUnits(resetOffset: true);
        if (mounted) {
          alert(context, 1, 'Data unit berhasil diupdate', 'success');
        }
      } else {
        throw Exception(
          body is Map ? body['message']?.toString() ?? 'Gagal update' : 'Gagal update',
        );
      }
    } catch (e) {
      if (mounted) {
        alert(context, 0, e.toString(), 'error');
      }
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Widget _buildPagedSmartSelect({
    required String label,
    required String value,
    required List<S2Choice<String>> choices,
    required ValueChanged<String> onChanged,
    required VoidCallback onReload,
    required VoidCallback? onPrev,
    required VoidCallback? onNext,
    required int currentPage,
    required int totalPages,
    required TextEditingController searchCtrl,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cari...',
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Cari',
                      onPressed: onReload,
                      icon: Icon(Icons.search, color: primaryOrange, size: 20),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
            onSubmitted: (_) => onReload(),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hal $currentPage / $totalPages',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onPrev,
                    icon: Icon(Icons.chevron_left, color: primaryOrange),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onNext,
                    icon: Icon(Icons.chevron_right, color: primaryOrange),
                  ),
                ],
              ),
            ],
          ),
          SmartSelect<String?>.single(
            title: label,
            placeholder: 'Pilih satu',
            selectedValue: value.isEmpty ? null : value,
            onChange: (selected) => onChanged(selected.value ?? ''),
            choiceType: S2ChoiceType.radios,
            choiceItems: choices,
            modalType: S2ModalType.popupDialog,
            modalHeader: true,
            modalFilter: true,
            modalFilterAuto: true,
            modalConfig: S2ModalConfig(
              useHeader: true,
              useFilter: true,
              filterAuto: true,
              filterHint: 'Filter pilihan...',
              style: S2ModalStyle(
                elevation: 8,
                backgroundColor: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            tileBuilder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  title: Text(
                    value.isNotEmpty ? value : 'Pilih satu',
                    style: TextStyle(
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_drop_down, color: primaryOrange),
                  onTap: state.showModal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKmField({
    required TextEditingController controller,
    String? previousKm,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KM',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Masukkan KM',
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryOrange, width: 1.5),
              ),
            ),
          ),
          if (previousKm != null && previousKm.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Min. KM: $previousKm',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                icon: Icon(Icons.arrow_drop_down, color: primaryOrange),
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text(
                      'Pilih Status',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  ..._unitStatusOptions.map(
                    (s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(s),
                    ),
                  ),
                ],
                onChanged: (v) => onChanged(v ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(Map<String, dynamic> unit) async {
    final vhcid = _cell(unit, ['VHCID', 'vhcid']);
    String selLoc = _cell(unit, ['LOCID', 'locid']);
    if (selLoc == '-') selLoc = '';
    String selDrv = _cell(unit, ['VHCDEFAULTDRIVER', 'vhcdefaultdriver']);
    if (selDrv == '-') selDrv = '';
    final canEditRole = _canEditUnitStatus();
    final defaultStatus = _defaultUnitStatus(unit);
    final defaultKm = _defaultUnitKm(unit);
    String selStatus = canEditRole ? defaultStatus : '';
    final kmCtrl = TextEditingController(
      text: canEditRole ? defaultKm : '',
    );

    final locSearchCtrl = TextEditingController();
    final drvSearchCtrl = TextEditingController();
    int locOffset = 0;
    int locTotal = 0;
    int drvOffset = 0;
    int drvTotal = 0;
    bool locLoading = false;
    bool drvLoading = false;
    List<S2Choice<String>> locChoices = [];
    List<S2Choice<String>> drvChoices = [];
    bool showSaveConfirm = false;
    String pendingStatusParam = '';
    String pendingKmParam = '';

    Future<void> loadLoc(
      StateSetter setDlg,
      BuildContext dlgCtx, {
      bool reset = false,
    }) async {
      if (reset) locOffset = 0;
      if (!dlgCtx.mounted) return;
      setDlg(() => locLoading = true);
      try {
        final result = await _fetchLookupPage(
          apiFile: 'reff_location.jsp',
          method: 'list-location',
          search: locSearchCtrl.text.trim(),
          offset: locOffset,
          ensureValue: selLoc.isNotEmpty ? selLoc : null,
          ensureTitle: selLoc,
        );
        locChoices = result.choices;
        locTotal = result.total;
        if (dlgCtx.mounted) setDlg(() => locLoading = false);
      } catch (e) {
        if (dlgCtx.mounted) {
          setDlg(() => locLoading = false);
          alert(dlgCtx, 0, e.toString(), 'error');
        }
      }
    }

    Future<void> loadDrv(
      StateSetter setDlg,
      BuildContext dlgCtx, {
      bool reset = false,
    }) async {
      if (reset) drvOffset = 0;
      if (!dlgCtx.mounted) return;
      setDlg(() => drvLoading = true);
      try {
        final result = await _fetchLookupPage(
          apiFile: 'reff_driver.jsp',
          method: 'list-driver',
          search: drvSearchCtrl.text.trim(),
          offset: drvOffset,
          ensureValue: selDrv.isNotEmpty ? selDrv : null,
        );
        drvChoices = result.choices;
        drvTotal = result.total;
        if (dlgCtx.mounted) setDlg(() => drvLoading = false);
      } catch (e) {
        if (dlgCtx.mounted) {
          setDlg(() => drvLoading = false);
          alert(dlgCtx, 0, e.toString(), 'error');
        }
      }
    }

    int locPages() => locTotal <= 0 ? 1 : ((locTotal - 1) ~/ _pageSize) + 1;
    int drvPages() => drvTotal <= 0 ? 1 : ((drvTotal - 1) ~/ _pageSize) + 1;

    final savePayload = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) {
        var pickerInitialized = false;
        return StatefulBuilder(
          builder: (context, setDlg) {
            if (!pickerInitialized) {
              pickerInitialized = true;
              loadLoc(setDlg, dlgCtx);
              loadDrv(setDlg, dlgCtx);
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.92,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryOrange, darkOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_road, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit Unit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dlgCtx),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _readOnlyField('Vehicle ID', vhcid),
                            const SizedBox(height: 8),
                            if (canEditRole)
                              _buildStatusDropdown(
                                value: selStatus,
                                onChanged: (v) => setDlg(() {
                                  selStatus = v;
                                  showSaveConfirm = false;
                                }),
                              )
                            else
                              _readOnlyField(
                                'Status',
                                _cell(unit, ['STATUS', 'status']),
                              ),
                            if (canEditRole)
                              _buildKmField(
                                controller: kmCtrl,
                                previousKm: defaultKm,
                                onChanged: (_) => setDlg(() {
                                  showSaveConfirm = false;
                                }),
                              )
                            else
                              _readOnlyField('KM', _cell(unit, ['VHCKM', 'vhckm'])),
                            const SizedBox(height: 8),
                            _buildPagedSmartSelect(
                              label: 'Default Location',
                              value: selLoc,
                              choices: locChoices,
                              onChanged: (v) => setDlg(() {
                                selLoc = v;
                                showSaveConfirm = false;
                              }),
                              onReload: () => loadLoc(setDlg, dlgCtx, reset: true),
                              onPrev: locOffset > 0
                                  ? () {
                                      locOffset -= _pageSize;
                                      if (locOffset < 0) locOffset = 0;
                                      loadLoc(setDlg, dlgCtx);
                                    }
                                  : null,
                              onNext: (_currentPageFrom(locOffset) < locPages())
                                  ? () {
                                      locOffset += _pageSize;
                                      loadLoc(setDlg, dlgCtx);
                                    }
                                  : null,
                              currentPage: _currentPageFrom(locOffset),
                              totalPages: locPages(),
                              searchCtrl: locSearchCtrl,
                              isLoading: locLoading,
                            ),
                            _buildPagedSmartSelect(
                              label: 'Default Driver',
                              value: selDrv,
                              choices: drvChoices,
                              onChanged: (v) => setDlg(() {
                                selDrv = v;
                                showSaveConfirm = false;
                              }),
                              onReload: () => loadDrv(setDlg, dlgCtx, reset: true),
                              onPrev: drvOffset > 0
                                  ? () {
                                      drvOffset -= _pageSize;
                                      if (drvOffset < 0) drvOffset = 0;
                                      loadDrv(setDlg, dlgCtx);
                                    }
                                  : null,
                              onNext: (_currentPageFrom(drvOffset) < drvPages())
                                  ? () {
                                      drvOffset += _pageSize;
                                      loadDrv(setDlg, dlgCtx);
                                    }
                                  : null,
                              currentPage: _currentPageFrom(drvOffset),
                              totalPages: drvPages(),
                              searchCtrl: drvSearchCtrl,
                              isLoading: drvLoading,
                            ),
                            if (showSaveConfirm) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.35),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Konfirmasi Simpan',
                                      style: TextStyle(
                                        color: darkOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Simpan perubahan data unit ini?',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Vehicle ID: $vhcid',
                                        style: const TextStyle(fontSize: 13)),
                                    Text('Location: $selLoc',
                                        style: const TextStyle(fontSize: 13)),
                                    Text('Driver: $selDrv',
                                        style: const TextStyle(fontSize: 13)),
                                    if (pendingStatusParam.isNotEmpty)
                                      Text('Status: $pendingStatusParam',
                                          style: const TextStyle(fontSize: 13)),
                                    if (pendingKmParam.isNotEmpty)
                                      Text('KM: $pendingKmParam',
                                          style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showSaveConfirm) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: lightOrange,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.45),
                                  ),
                                ),
                                child: Text(
                                  'Simpan perubahan data unit ini?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setDlg(() {
                                        showSaveConfirm = false;
                                      }),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade700,
                                        side: BorderSide(color: Colors.grey.shade400),
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('No'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dlgCtx, {
                                          'vhcid': vhcid,
                                          'locid': selLoc,
                                          'drvid': selDrv,
                                          'status': pendingStatusParam,
                                          'vhckm': pendingKmParam,
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        foregroundColor: Colors.white,
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Yes'),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(dlgCtx),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: darkOrange,
                                        side: BorderSide(color: primaryOrange),
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Batal'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (selLoc.isEmpty) {
                                          alert(
                                            context,
                                            0,
                                            'Default Location wajib dipilih',
                                            'warning',
                                          );
                                          return;
                                        }
                                        if (selDrv.isEmpty) {
                                          alert(
                                            context,
                                            0,
                                            'Default Driver wajib dipilih',
                                            'warning',
                                          );
                                          return;
                                        }
                                        if (canEditRole) {
                                          if (!_validateKmInput(
                                            inputKm: kmCtrl.text,
                                            previousKm: defaultKm,
                                            onError: (msg) =>
                                                alert(context, 0, msg, 'warning'),
                                          )) {
                                            return;
                                          }
                                        }

                                        setDlg(() {
                                          pendingStatusParam = _resolveStatusParam(
                                            canEditRole: canEditRole,
                                            selectedStatus: selStatus,
                                            defaultStatus: defaultStatus,
                                          );
                                          pendingKmParam = _resolveKmParam(
                                            canEditRole: canEditRole,
                                            inputKm: kmCtrl.text,
                                            defaultKm: defaultKm,
                                          );
                                          showSaveConfirm = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        foregroundColor: Colors.white,
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Simpan',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    locSearchCtrl.dispose();
    drvSearchCtrl.dispose();
    kmCtrl.dispose();

    if (savePayload != null && mounted) {
      await _updateUnitAndRefresh(
        vhcid: savePayload['vhcid'] ?? '',
        locid: savePayload['locid'] ?? '',
        drvid: savePayload['drvid'] ?? '',
        status: savePayload['status'] ?? '',
        vhckm: savePayload['vhckm'] ?? '',
      );
    }
  }

  int _currentPageFrom(int offset) => (offset ~/ _pageSize) + 1;

  Widget _readOnlyField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: lightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryOrange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value == '-' ? '' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: darkOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> item) {
    final vhcid = _cell(item, ['VHCID', 'vhcid']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: primaryOrange.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_shipping, color: darkOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vhcid,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkOrange,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentOrange.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _cell(item, ['VHCSTATUS', 'vhcstatus']),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: darkOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.place_outlined, 'Location', _cell(item, ['LOCID', 'locid'])),
            _infoRow(Icons.speed, 'KM', _cell(item, ['VHCKM', 'vhckm'])),
            _infoRow(Icons.info_outline, 'Status', _cell(item, ['STATUS', 'status'])),
            _infoRow(Icons.notes, 'Notes', _cell(item, ['VHCNOTES', 'vhcnotes'])),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showEditDialog(item),
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text('Edit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryOrange),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: const Text(
          'Units',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: _goBack,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari VHCID...',
                    filled: true,
                    fillColor: lightOrange,
                    prefixIcon: Icon(Icons.search, color: primaryOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _fetchUnits(resetOffset: true),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : () => _fetchUnits(resetOffset: true),
                        icon: const Icon(Icons.search, color: Colors.white, size: 18),
                        label: const Text('Search', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading
                            ? null
                            : () {
                                _searchController.clear();
                                _fetchUnits(resetOffset: true);
                              },
                        icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                        label: const Text('Reset', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_total > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Menampilkan ${_items.length} / $_total data',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkOrange,
                ),
              ),
            ),
          Expanded(
            child: _loading && _items.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryOrange))
                : _items.isEmpty
                    ? RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: () => _fetchUnits(resetOffset: true),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                            ),
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada data unit',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: () => _fetchUnits(resetOffset: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _items.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _items.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: primaryOrange,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              );
                            }
                            return _buildUnitCard(_items[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    ),
    );
  }
}
