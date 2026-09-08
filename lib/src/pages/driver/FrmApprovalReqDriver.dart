import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FrmApprovalReqDriver extends StatefulWidget {
  final String vhcid;
  final String rdtype;
  final String locid;

  const FrmApprovalReqDriver({
    Key? key,
    this.vhcid = '',
    this.rdtype = '',
    this.locid = '',
  }) : super(key: key);

  @override
  _FrmApprovalReqDriverState createState() => _FrmApprovalReqDriverState();
}

class _FrmApprovalReqDriverState extends State<FrmApprovalReqDriver>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Soft Orange Pastel Theme (sama persis dengan FrmNonTera.dart)
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  // Form State
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _submitting = false;
  String _selectedRdtype = '';
  String _selectedVhcid = '';
  String _selectedLocid = '';
  List<Map<String, dynamic>> _vehicleList = [];
  List<Map<String, dynamic>> _locidList = [];
  bool _loadingVehicles = true;
  bool _loadingLocid = true;

  // List State
  late Future<List<Map<String, dynamic>>> _listFuture;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _selectedRdtype =
        (widget.rdtype.isEmpty) ? 'BATANGAN' : widget.rdtype;
    _selectedVhcid = widget.vhcid;
    _selectedLocid = widget.locid;
    _fetchVehicleList();
    _fetchLocidList();
    _listFuture = _fetchApprovedRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  InputDecoration softDecoration({
    String? label,
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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

  AlertDialog ntAlertDialog({
    required String title,
    required Widget content,
    List<Widget> actions = const <Widget>[],
  }) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: cardColor,
      titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Text(
        title,
        style: TextStyle(
          color: darkOrange,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  String _s(dynamic v) {
    if (v == null) return '';
    final t = v.toString().trim();
    if (t.isEmpty || t == 'null') return '';
    return t;
  }

  Widget _kv(
    String label,
    String value, {
    bool dense = false,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 1.5 : 2.5),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: dense ? 11.5 : 12.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor ?? Colors.grey.shade900,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: valueWeight ?? FontWeight.w600,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _ntListCard({
    required String title,
    Widget? trailing,
    required List<Widget> rows,
    Widget? actions,
    bool compact = false,
  }) {
    final m = compact ? 8.0 : 12.0;
    final v = compact ? 4.0 : 6.0;
    final r = compact ? 10.0 : 14.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: m, vertical: v),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: const Color(0x73FFB347)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: compact ? 4 : 8,
            offset: Offset(0, compact ? 1 : 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: compact
                ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
                : const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r),
                topRight: Radius.circular(r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 13 : 14,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(12, 6, 12, 6)
                : const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: compact
                  ? const EdgeInsets.fromLTRB(10, 2, 10, 10)
                  : const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: actions,
            ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.grey.shade800,
      ),
    );
  }

  void goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  // ========================== API METHODS ==========================

  Future<void> _fetchVehicleList() async {
    try {
      final String url = GlobalData.baseUrl +
          'api/driver/master_vehicle.jsp?method=list-vehicle-close';
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int statusCode = responseData['status_code'] ?? 0;

        if (statusCode == 200) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final List<Map<String, dynamic>> vehicles = [];

          for (final item in dataList) {
            vehicles.add({
              'id': _s(item['id']),
              'text': _s(item['text']),
            });
          }

          setState(() {
            _vehicleList = vehicles;
            _loadingVehicles = false;
            if (widget.vhcid.isNotEmpty) {
              final foundVehicle = vehicles.firstWhere(
                (v) => v['id'] == widget.vhcid,
                orElse: () => {'id': '', 'text': ''},
              );
              _selectedVhcid = foundVehicle['id'];
            }
          });
        } else {
          setState(() {
            _vehicleList = [];
            _loadingVehicles = false;
          });
        }
      } else {
        setState(() {
          _loadingVehicles = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingVehicles = false;
      });
    }
  }

  Future<void> _fetchLocidList() async {
    try {
      final String url =
          GlobalData.baseUrl + 'api/driver/master_locid.jsp?method=list-locid';
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int statusCode = responseData['status_code'] ?? 0;

        if (statusCode == 200) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          final List<Map<String, dynamic>> locid = [];

          for (final item in dataList) {
            locid.add({
              'id': _s(item['id']),
              'text': _s(item['text']),
            });
          }

          setState(() {
            _locidList = locid;
            _loadingLocid = false;
            if (widget.locid.isNotEmpty && _selectedLocid.isEmpty) {
              final foundLoc = locid.firstWhere(
                (l) => l['id'] == widget.locid,
                orElse: () => {'id': '', 'text': ''},
              );
              _selectedLocid = foundLoc['id'];
            }
          });
        } else {
          setState(() {
            _locidList = [];
            _loadingLocid = false;
          });
        }
      } else {
        setState(() {
          _loadingLocid = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingLocid = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchApprovedRequests() async {
    try {
      final String url = GlobalData.baseUrl +
          'api/driver/list_driver_oprs_approve.jsp?method=list-driver-oprs';
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Map<String, dynamic>> items = [];
        for (final raw in jsonList) {
          items.add({
            "RDNBR": _s(raw['rdnbr']),
            "RDDATETIME": _s(raw['rddatetime']),
            "VHCID": _s(raw['vhcid']),
            "RDAPVBY": _s(raw['rdapvby']),
            "RDAPVDATETIME": _s(raw['rdapvdatetime']),
            "RDSTATUS": _s(raw['rdstatus']),
            "RDNOTES": _s(raw['rdnotes']),
            "LOCID": _s(raw['locid']),
            "RDTYPE": _s(raw['rdtype']),
          });
        }
        return items;
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      if (e is IOException) {
        alert(globalScaffoldKey.currentContext ?? context, 2,
            "Cek koneksi internet Anda.", "warning");
      }
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _refreshList() async {
    setState(() {
      _listFuture = _fetchApprovedRequests();
    });
  }

  Future<void> _confirmAddRequest() async {
    if (_selectedVhcid.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 2,
          'VHCID tidak boleh kosong', 'warning');
      return;
    }
    if (_selectedRdtype.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 2,
          'Tipe Driver tidak boleh kosong', 'warning');
      return;
    }
    if (_selectedLocid.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 2,
          'LOCID tidak boleh kosong', 'warning');
      return;
    }
    if (_notesController.text.trim().isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 2,
          'Notes tidak boleh kosong', 'warning');
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => ntAlertDialog(
        title: 'Konfirmasi',
        content: const Text('Add request driver ini?'),
        actions: [
          ElevatedButton(
            style: ntBtnStyle(Colors.grey.shade500),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: ntBtnLabel('Tidak'),
          ),
          ElevatedButton(
            style: ntBtnStyle(primaryOrange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: ntBtnLabel('Ya, Simpan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _add_request();
    }
  }

  Future<void> _add_request() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userid = prefs.getString("name") ?? '';
      final String notes = _notesController.text.trim();

      final String url = GlobalData.baseUrl +
          'api/driver/add_request_driver.jsp?method=add-req-driver' +
          '&vhcid=' +
          Uri.encodeComponent(_selectedVhcid) +
          '&rdtype=' +
          Uri.encodeComponent(_selectedRdtype) +
          '&locid=' +
          Uri.encodeComponent(_selectedLocid) +
          '&notes=' +
          Uri.encodeComponent(notes) +
          '&userid=' +
          Uri.encodeComponent(userid);

      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> body;
        try {
          body = json.decode(response.body) as Map<String, dynamic>;
        } catch (_) {
          body = <String, dynamic>{};
        }
        final int statusCode = (body['status_code'] is int)
            ? body['status_code'] as int
            : int.tryParse((body['status_code'] ?? '').toString()) ?? 0;

        if (statusCode == 200) {
          final String rdnbr = (body['rdnbr'] ?? '').toString();
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => ntAlertDialog(
              title: 'Sukses',
              content: Text('Add request driver sukses: $rdnbr'),
              actions: [
                ElevatedButton(
                  style: ntBtnStyle(primaryOrange),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _notesController.clear();
                    setState(() {
                      _selectedVhcid = '';
                      _selectedLocid = '';
                    });
                    _refreshList();
                    _tabController.animateTo(1);
                  },
                  child: ntBtnLabel('OK'),
                ),
              ],
            ),
          );
        } else {
          final String msg = (body['message'] ?? 'Gagal').toString();
          if (mounted) {
            alert(globalScaffoldKey.currentContext ?? context, 2, msg, 'warning');
          }
        }
      } else {
        if (mounted) {
          alert(globalScaffoldKey.currentContext ?? context, 2,
              'Server error: ${response.statusCode}', 'warning');
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is IOException) {
          alert(globalScaffoldKey.currentContext ?? context, 2,
              'Cek koneksi internet Anda.', 'warning');
        } else {
          alert(globalScaffoldKey.currentContext ?? context, 2,
              'Terjadi kesalahan.', 'warning');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _approveRequest(
    String vhcid,
    String rdnbr,
    String rdtype,
    String userid,
    String locid,
  ) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/driver/approved_req_driver.jsp'
      '?method=approve_req_driver'
      '&vhcid=$vhcid'
      '&rdnbr=$rdnbr'
      '&userid=$userid'
      '&locid=$locid'
      '&rdtype=$rdtype',
    );

    try {
      EasyLoading.show(status: 'Memproses Approve...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 1, 'Approve berhasil: ${data['message']}', 'success');
          await _refreshList();
        } else {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 0, 'Approve gagal: ${data['message']}', 'error');
        }
      } else {
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, 'Server error: ${response.statusCode}', 'error');
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext ?? context;
      alert(ctx, 0, 'Exception: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _cancelRequest(
    String vhcid,
    String rdnbr,
    String rdtype,
    String userid,
  ) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/driver/cancel_req_driver.jsp'
      '?method=cancel_req_driver'
      '&vhcid=$vhcid'
      '&rdnbr=$rdnbr'
      '&userid=$userid'
      '&rdtype=$rdtype',
    );

    try {
      EasyLoading.show(status: 'Memproses Cancel...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 1, 'Cancel sukses: ${data['message']}', 'success');
          await _refreshList();
        } else {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 0, 'Cancel gagal: ${data['message']}', 'error');
        }
      } else {
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, 'Server error: ${response.statusCode}', 'error');
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext ?? context;
      alert(ctx, 0, 'Exception: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  // ========================== UI COMPONENTS ==========================

  Widget _vhcidField() {
    if (_loadingVehicles) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: primaryOrange),
            ),
            const SizedBox(width: 12),
            Text(
              'Memuat data kendaraan...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _vehicleList.map((v) => v['id'].toString()).toList();
        }
        final q = textEditingValue.text.toLowerCase();
        return _vehicleList
            .where((v) =>
                v['id'].toString().toLowerCase().contains(q) ||
                v['text'].toString().toLowerCase().contains(q))
            .map((v) => v['id'].toString())
            .toList();
      },
      onSelected: (String selection) {
        setState(() {
          _selectedVhcid = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        if (controller.text.isEmpty && _selectedVhcid.isNotEmpty) {
          controller.text = _selectedVhcid;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: softDecoration(
            hint: 'Pilih atau cari no. polisi...',
            prefixIcon: Icon(Icons.directions_bus_outlined,
                color: primaryOrange, size: 20),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x66FFB347)),
              ),
              constraints:
                  const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  final vehicle = _vehicleList.firstWhere(
                    (v) => v['id'] == option,
                    orElse: () => {'id': option, 'text': ''},
                  );
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Text(
                        '${vehicle['id']} - ${vehicle['text']}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _rdtypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: (_selectedRdtype.isEmpty) ? 'BATANGAN' : _selectedRdtype,
      items: <String>['BATANGAN', 'SEREP']
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedRdtype = val ?? 'BATANGAN';
        });
      },
      decoration: softDecoration(
        hint: 'Pilih Tipe Driver',
        prefixIcon:
            Icon(Icons.badge_outlined, color: primaryOrange, size: 20),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: primaryOrange),
      dropdownColor: Colors.white,
    );
  }

  Widget _locidField() {
    if (_loadingLocid) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: primaryOrange),
            ),
            const SizedBox(width: 12),
            Text(
              'Memuat data lokasi...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _locidList.map((l) => l['id'].toString()).toList();
        }
        final q = textEditingValue.text.toLowerCase();
        return _locidList
            .where((l) =>
                l['id'].toString().toLowerCase().contains(q) ||
                l['text'].toString().toLowerCase().contains(q))
            .map((l) => l['id'].toString())
            .toList();
      },
      onSelected: (String selection) {
        setState(() {
          _selectedLocid = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        if (controller.text.isEmpty && _selectedLocid.isNotEmpty) {
          controller.text = _selectedLocid;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: softDecoration(
            hint: 'Pilih atau cari LOCID...',
            prefixIcon: Icon(Icons.location_on_outlined,
                color: primaryOrange, size: 20),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x66FFB347)),
              ),
              constraints:
                  const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  final loc = _locidList.firstWhere(
                    (l) => l['id'] == option,
                    orElse: () => {'id': option, 'text': ''},
                  );
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Text(
                        '${loc['id']} - ${loc['text']}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ========================== TABS ==========================

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x59FFB347)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
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
                  Icon(Icons.person_add_alt_1_outlined,
                      color: primaryOrange, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Form Request Driver',
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Form Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('VHCID (Kendaraan)'),
                  const SizedBox(height: 6),
                  _vhcidField(),
                  const SizedBox(height: 14),

                  _label('Tipe Driver'),
                  const SizedBox(height: 6),
                  _rdtypeDropdown(),
                  const SizedBox(height: 14),

                  _label('LOCID (Lokasi)'),
                  const SizedBox(height: 6),
                  _locidField(),
                  const SizedBox(height: 14),

                  _label('Notes (Catatan)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: softDecoration(
                      hint: 'Tambahkan catatan request...',
                      prefixIcon: Icon(Icons.note_alt_outlined,
                          color: primaryOrange, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: _submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 18),
                          label: ntBtnLabel(
                              _submitting ? 'Menyimpan...' : 'Submit Request'),
                          style: ntBtnStyle(primaryOrange),
                          onPressed: _submitting ? null : _confirmAddRequest,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt,
                            color: Colors.white, size: 18),
                        label: ntBtnLabel('Lihat List'),
                        style: ntBtnStyle(accentOrange),
                        onPressed: () {
                          _tabController.animateTo(1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab() {
    return Column(
      children: [
        // Search Filter Bar
        Container(
          margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchText = val.trim();
              });
            },
            decoration: softDecoration(
              hint: 'Cari no. polisi / no. request / lokasi...',
              prefixIcon:
                  Icon(Icons.search, color: primaryOrange, size: 20),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchText = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        // List Content
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: _refreshList,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _listFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 44, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Terjadi kesalahan saat memuat data',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _refreshList,
                          style: ntBtnStyle(primaryOrange),
                          child: ntBtnLabel('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 52, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada data request driver',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Filter data
                final filtered = _searchText.isEmpty
                    ? items
                    : items.where((item) {
                        final q = _searchText.toLowerCase();
                        final vhc = _s(item['VHCID']).toLowerCase();
                        final nbr = _s(item['RDNBR']).toLowerCase();
                        final loc = _s(item['LOCID']).toLowerCase();
                        final notes = _s(item['RDNOTES']).toLowerCase();
                        return vhc.contains(q) ||
                            nbr.contains(q) ||
                            loc.contains(q) ||
                            notes.contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          'Tidak ada data yang cocok dengan "$_searchText"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24, top: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildRequestCard(item);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> item) {
    final status = _s(item['RDSTATUS']).toUpperCase();
    Color statusBg = lightOrange;
    Color statusText = darkOrange;
    Color statusBorder = accentOrange;

    if (status == 'APPROVED') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade800;
      statusBorder = Colors.green.shade200;
    } else if (status == 'CANCEL' || status == 'REJECTED') {
      statusBg = Colors.red.shade50;
      statusText = Colors.red.shade800;
      statusBorder = Colors.red.shade200;
    }

    final isActionable = status != 'APPROVED' && status != 'CANCEL';

    return _ntListCard(
      title: "No: ${_s(item['RDNBR'])}",
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusBorder),
        ),
        child: Text(
          status.isEmpty ? 'OPEN' : status,
          style: TextStyle(
            color: statusText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      rows: [
        _kv('Tanggal', _s(item['RDDATETIME']), dense: true),
        _kv('VHCID', _s(item['VHCID']),
            dense: true,
            valueWeight: FontWeight.w700,
            valueColor: darkOrange),
        _kv('Tipe Driver', _s(item['RDTYPE']), dense: true),
        _kv('Lokasi', _s(item['LOCID']), dense: true),
        _kv('Catatan', _s(item['RDNOTES']), dense: true),
        if (_s(item['RDAPVBY']).isNotEmpty)
          _kv('Approve By', _s(item['RDAPVBY']), dense: true),
        if (_s(item['RDAPVDATETIME']).isNotEmpty)
          _kv('Tgl Approve', _s(item['RDAPVDATETIME']), dense: true),
      ],
      actions: isActionable
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 15),
                    label: ntBtnLabel('Cancel', size: 12),
                    style: ntBtnStyle(Colors.redAccent),
                    onPressed: () => _confirmCancel(item),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.check, color: Colors.white, size: 15),
                    label: ntBtnLabel('Approve', size: 12),
                    style: ntBtnStyle(Colors.green.shade600),
                    onPressed: () => _confirmApprove(item),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _confirmCancel(Map<String, dynamic> item) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => ntAlertDialog(
        title: 'Konfirmasi Cancel',
        content:
            Text('Yakin ingin membatalkan request ${_s(item['RDNBR'])}?'),
        actions: [
          ElevatedButton(
            style: ntBtnStyle(Colors.grey.shade500),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: ntBtnLabel('Tidak'),
          ),
          ElevatedButton(
            style: ntBtnStyle(Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: ntBtnLabel('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString("name") ?? '';
      await _cancelRequest(
        _s(item['VHCID']),
        _s(item['RDNBR']),
        _s(item['RDTYPE']),
        username,
      );
    }
  }

  Future<void> _confirmApprove(Map<String, dynamic> item) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => ntAlertDialog(
        title: 'Konfirmasi Approve',
        content: Text('Yakin ingin menyetujui request ${_s(item['RDNBR'])}?'),
        actions: [
          ElevatedButton(
            style: ntBtnStyle(Colors.grey.shade500),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: ntBtnLabel('Tidak'),
          ),
          ElevatedButton(
            style: ntBtnStyle(Colors.green.shade600),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: ntBtnLabel('Ya, Approve'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString("name") ?? '';
      await _approveRequest(
        _s(item['VHCID']),
        _s(item['RDNBR']),
        _s(item['RDTYPE']),
        username,
        _s(item['LOCID']),
      );
    }
  }

  // ========================== BUILD ==========================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        goBack(context);
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => goBack(context),
          ),
          centerTitle: true,
          title: const Text(
            'Request Driver',
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
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(
                icon: Icon(Icons.assignment_add, size: 20),
                text: 'Form Request',
              ),
              Tab(
                icon: Icon(Icons.format_list_bulleted, size: 20),
                text: 'List Request',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFormTab(),
            _buildListTab(),
          ],
        ),
      ),
    );
  }
}
