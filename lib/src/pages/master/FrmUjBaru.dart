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
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);

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
    return exists ? value : value; // keep value even if not in list (edit)
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

  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFFFFAF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lightOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: darkOrange, size: 28),
            ),
            SizedBox(width: 10),
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
            fontSize: 15,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ListUjBaru()),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
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
      padding: EdgeInsets.only(bottom: 12),
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: SmartSelect<String?>.single(
              title: label,
              selectedValue: (value == null || value.isEmpty) ? null : value,
              choiceItems: choices,
              onChange: (s) => onChanged(s.value),
              modalType: S2ModalType.bottomSheet,
              modalFilter: true,
              modalFilterAuto: true,
              modalFilterHint: 'Cari $label...',
              tileBuilder: (context, state) {
                return S2Tile.fromState(
                  state,
                  dense: true,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  trailing: Icon(Icons.search, color: primaryOrange, size: 20),
                );
              },
            ),
          ),
        ),
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly || onTap != null,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: onTap != null
              ? Icon(Icons.calendar_today, color: primaryOrange, size: 18)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryOrange, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        title: Text(
          _isEdit ? 'Edit UJ Baru' : 'Add UJ Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _loadingLookups
          ? Center(child: CircularProgressIndicator(color: primaryOrange))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryOrange.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEdit)
                      _textField(
                        label: 'Number',
                        controller: _numberCtrl,
                        readOnly: true,
                      ),
                    if (!_isEdit)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Number akan digenerate otomatis (TL...) saat Save',
                          style: TextStyle(
                            color: darkOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
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
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: Icon(Icons.save, color: Colors.white),
              label: Text(
                _isEdit ? 'Update' : 'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loadingLookups ? null : _save,
            ),
          ),
        ),
      ),
    );
  }
}
