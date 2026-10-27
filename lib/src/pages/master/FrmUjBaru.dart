import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/master/ListUjBaru.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrmUjBaru extends StatefulWidget {
  final Map<String, dynamic>? editItem;

  FrmUjBaru({this.editItem});

  @override
  _FrmUjBaruState createState() => _FrmUjBaruState();
}

class _FrmUjBaruState extends State<FrmUjBaru> {
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  final _tariffCtrl = TextEditingController();
  final _ruteCtrl = TextEditingController();
  final _effDateCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();

  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _origins = [];
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _aliases = [];
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _uoms = [];
  List<Map<String, dynamic>> _typeUj = [];

  String? _cpyid;
  String? _origin;
  String? _destination;
  String? _vhtalias;
  String? _itemtype;
  String? _uom;
  String? _ritase;
  String _ctpid = '';
  bool _loadingLookups = true;
  bool get _isEdit => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _effDateCtrl.text = today;
    if (_isEdit) {
      final m = widget.editItem!;
      _numberCtrl.text = _s(m['cusnbr']);
      _ctpid = _s(m['ctpid']);
      _cpyid = _s(m['cpyid']);
      _origin = _s(m['origin']);
      _destination = _s(m['destination']);
      _vhtalias = _s(m['vhtalias']);
      _itemtype = _s(m['itemtype']);
      _uom = _s(m['uom']);
      _ritase = _s(m['ritase']);
      _tariffCtrl.text = _s(m['tariff']);
      _ruteCtrl.text = _s(m['rute']);
      final eff = _s(m['effective_date']);
      if (eff.isNotEmpty) {
        _effDateCtrl.text = eff.length >= 10 ? eff.substring(0, 10) : eff;
      }
    }
    _loadLookups();
  }

  @override
  void dispose() {
    _tariffCtrl.dispose();
    _ruteCtrl.dispose();
    _effDateCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  String _s(dynamic v) {
    if (v == null) return '';
    final t = v.toString().trim();
    if (t.isEmpty || t == 'null') return '';
    return t;
  }

  Future<List<Map<String, dynamic>>> _fetchLookup(String method) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/master/refference_uj_baru.jsp?method=$method',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) return [];
    final decoded = json.decode(res.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _loadLookups() async {
    setState(() => _loadingLookups = true);
    try {
      final results = await Future.wait([
        _fetchLookup('list_customer'),
        _fetchLookup('list_origin'),
        _fetchLookup('list_destination'),
        _fetchLookup('list_vehicle_alias'),
        _fetchLookup('list_item_type'),
        _fetchLookup('list_uom'),
        _fetchLookup('list_typeuj'),
      ]);
      setState(() {
        _customers = results[0];
        _origins = results[1];
        _destinations = results[2];
        _aliases = results[3];
        _items = results[4];
        _uoms = results[5];
        _typeUj = results[6];
        _cpyid = _ensureInList(_cpyid, _customers);
        _origin = _ensureInList(_origin, _origins);
        _destination = _ensureInList(_destination, _destinations);
        _vhtalias = _ensureInList(_vhtalias, _aliases);
        _itemtype = _ensureInList(_itemtype, _items);
        _uom = _ensureInList(_uom, _uoms);
        _ritase = _ensureInList(_ritase, _typeUj);
        _loadingLookups = false;
      });
    } catch (e) {
      setState(() => _loadingLookups = false);
      if (mounted) {
        alert(context, 0, 'Gagal load lookup: $e', 'error');
      }
    }
  }

  String? _ensureInList(String? value, List<Map<String, dynamic>> list) {
    if (value == null || value.isEmpty) return null;
    final exists = list.any((e) => _s(e['id']) == value);
    return exists ? value : value;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initial = now;
    try {
      initial = DateTime.parse(_effDateCtrl.text);
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _effDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  InputDecoration softDecoration({
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    );
  }

  ButtonStyle ntBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget ntBtnLabel(String text, {double size = 13}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lightOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: darkOrange, size: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Berhasil',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: darkOrange,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.5,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ntBtnStyle(primaryOrange),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ListUjBaru()),
                );
              },
              child: ntBtnLabel('OK, Kembali ke List', size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_origin == null || _origin!.isEmpty) {
      alert(context, 0, 'Origin wajib diisi', 'error');
      return;
    }
    if (_destination == null || _destination!.isEmpty) {
      alert(context, 0, 'Destination wajib diisi', 'error');
      return;
    }
    if (_cpyid == null || _cpyid!.isEmpty) {
      alert(context, 0, 'Customer wajib diisi', 'error');
      return;
    }
    if (_vhtalias == null || _vhtalias!.isEmpty) {
      alert(context, 0, 'Vehicle Type Alias wajib diisi', 'error');
      return;
    }
    if (_ritase == null || _ritase!.isEmpty) {
      alert(context, 0, 'Type UJ wajib diisi', 'error');
      return;
    }
    if (_tariffCtrl.text.trim().isEmpty) {
      alert(context, 0, 'Tariff wajib diisi', 'error');
      return;
    }
    if (_uom == null || _uom!.isEmpty) {
      alert(context, 0, 'Tariff UOM wajib diisi', 'error');
      return;
    }
    if (_effDateCtrl.text.trim().isEmpty) {
      alert(context, 0, 'Effective Date wajib diisi', 'error');
      return;
    }

    try {
      EasyLoading.show(status: 'Saving...');
      final prefs = await SharedPreferences.getInstance();
      final userid =
          prefs.getString('name') ?? prefs.getString('username') ?? '';
      final url =
          Uri.parse('${GlobalData.baseUrl}api/master/save_uj_baru.jsp');
      final body = <String, String>{
        'method': _isEdit ? 'update' : 'add',
        'userid': userid,
        'cusnbr': _numberCtrl.text.trim(),
        'ctpid': _ctpid,
        'destination': _destination!,
        'cpyid': _cpyid!,
        'tariff': _tariffCtrl.text.trim(),
        'uom': _uom!,
        'currency': 'IDR',
        'effective_date': _effDateCtrl.text.trim(),
        'vhtalias': _vhtalias!,
        'origin': _origin!,
        'ritase': _ritase!,
        'rute': _ruteCtrl.text.trim(),
        'itemtype': _itemtype ?? '',
      };
      final res = await http.post(url, body: body);
      EasyLoading.dismiss();
      if (!mounted) return;
      if (res.statusCode == 200) {
        final resp = json.decode(res.body);
        if (resp['status'] == 'success') {
          final msg = (resp['message'] ?? 'Data berhasil disimpan').toString();
          final cusnbr = (resp['cusnbr'] ?? '').toString();
          final notif = cusnbr.isNotEmpty ? '$msg\nNo: $cusnbr' : msg;
          await _showSuccessDialog(notif);
        } else {
          alert(context, 0, resp['message'] ?? 'Gagal simpan', 'error');
        }
      } else {
        alert(context, 0, 'Gagal simpan', 'error');
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        alert(context, 0, 'Error: $e', 'error');
      }
    }
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    var choiceSource = List<Map<String, dynamic>>.from(items);
    if (value != null &&
        value.isNotEmpty &&
        !choiceSource.any((e) => _s(e['id']) == value)) {
      choiceSource = [
        {'id': value, 'text': value},
        ...choiceSource,
      ];
    }

    final choices = choiceSource
        .map((e) => S2Choice<String>(
              value: _s(e['id']),
              title: _s(e['text']).isEmpty ? _s(e['id']) : _s(e['text']),
            ))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          AbsorbPointer(
            absorbing: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.65,
              child: Container(
                decoration: BoxDecoration(
                  color: enabled ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: SmartSelect<String?>.single(
                  title: label,
                  selectedValue: (value == null || value.isEmpty) ? null : value,
                  choiceItems: choices,
                  onChange: (s) => onChanged(s.value),
                  modalHeader: true,
                  modalConfig: S2ModalConfig(
                    type: S2ModalType.bottomSheet,
                    useFilter: true,
                    filterAuto: true,
                    filterHint: 'Cari $label...',
                  ),
                  tileBuilder: (context, state) {
                    return S2Tile.fromState(
                      state,
                      dense: true,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      trailing: Icon(Icons.search, color: primaryOrange, size: 20),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextField(
            controller: controller,
            readOnly: readOnly || onTap != null,
            onTap: onTap,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: softDecoration(
              hint: hint ?? 'Masukkan $label...',
              readOnly: readOnly,
              suffixIcon: onTap != null
                  ? Icon(Icons.calendar_today, color: primaryOrange, size: 18)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          _isEdit ? 'Edit UJ Baru' : 'Add UJ Baru',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loadingLookups
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x59FFB347)),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: lightOrange,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_outlined, color: primaryOrange, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            _isEdit ? 'Edit Form Uang Jalan (UJ Baru)' : 'Form Tambah Uang Jalan (UJ Baru)',
                            style: TextStyle(
                              color: darkOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEdit)
                            _textField(
                              label: 'Number (CUSNBR)',
                              controller: _numberCtrl,
                              readOnly: true,
                            ),
                          if (!_isEdit)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: lightOrange,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0x59FFB347)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: darkOrange, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Nomor UJ akan digenerate otomatis (TL...) saat data disimpan.',
                                      style: TextStyle(
                                        color: darkOrange,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _dropdown(
                            label: 'Customer *',
                            value: _cpyid,
                            items: _customers,
                            onChanged: (v) => setState(() => _cpyid = v),
                          ),
                          _dropdown(
                            label: 'Origin *',
                            value: _origin,
                            items: _origins,
                            enabled: !_isEdit,
                            onChanged: (v) => setState(() => _origin = v),
                          ),
                          _dropdown(
                            label: 'Destination *',
                            value: _destination,
                            items: _destinations,
                            onChanged: (v) => setState(() => _destination = v),
                          ),
                          _dropdown(
                            label: 'Vehicle Type Alias *',
                            value: _vhtalias,
                            items: _aliases,
                            enabled: !_isEdit,
                            onChanged: (v) => setState(() => _vhtalias = v),
                          ),
                          _dropdown(
                            label: 'Item Type',
                            value: _itemtype,
                            items: _items,
                            onChanged: (v) => setState(() => _itemtype = v),
                          ),
                          _dropdown(
                            label: 'Type UJ *',
                            value: _ritase,
                            items: _typeUj,
                            onChanged: (v) => setState(() => _ritase = v),
                          ),
                          _textField(
                            label: 'Tariff *',
                            controller: _tariffCtrl,
                            keyboardType: TextInputType.number,
                            hint: 'Masukkan nominal tarif...',
                          ),
                          _dropdown(
                            label: 'Tariff UOM *',
                            value: _uom,
                            items: _uoms,
                            onChanged: (v) => setState(() => _uom = v),
                          ),
                          _textField(
                            label: 'Effective Date *',
                            controller: _effDateCtrl,
                            onTap: _pickDate,
                          ),
                          _textField(
                            label: 'Rute',
                            controller: _ruteCtrl,
                            maxLines: 2,
                            hint: 'Masukkan keterangan rute...',
                          ),
                          const SizedBox(height: 12),
                          // Action Buttons inside form container
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                ),
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save, color: Colors.white, size: 16),
                                label: ntBtnLabel(_isEdit ? 'Update UJ' : 'Simpan UJ'),
                                style: ntBtnStyle(primaryOrange),
                                onPressed: _loadingLookups ? null : _save,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
