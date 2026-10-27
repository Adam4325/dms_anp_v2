import 'dart:async';
import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmKoordinat.dart';
import 'package:dms_anp/src/pages/master/FrmMasterMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FrmMasterData extends StatefulWidget {
  @override
  _FrmMasterDataState createState() => _FrmMasterDataState();
}

class _FrmMasterDataState extends State<FrmMasterData>
    with SingleTickerProviderStateMixin {
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  String username = '';
  String userid = '';
  late TabController _tabController;

  // Theme Colors (Soft Orange Pastel)
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  // Sub-modes per category: 0 = Daftar (List), 1 = Form Input/Edit
  // 0: Customer, 1: Origin, 2: Destination, 3: Item Type, 4: Client, 5: Zone
  final List<int> _subModes = [0, 0, 0, 0, 0, 0];

  // Search controllers for lists
  final TextEditingController _searchCustomerCtrl = TextEditingController();
  final TextEditingController _searchOriginCtrl = TextEditingController();
  final TextEditingController _searchDestCtrl = TextEditingController();
  final TextEditingController _searchItemTypeCtrl = TextEditingController();
  final TextEditingController _searchClientCtrl = TextEditingController();
  final TextEditingController _searchZoneCtrl = TextEditingController();

  // Customer tab
  final TextEditingController txtCpyId = TextEditingController();
  final TextEditingController txtCpyname = TextEditingController();
  final TextEditingController txtCpyaddress = TextEditingController();
  final TextEditingController txtCpynpwp = TextEditingController();
  final TextEditingController txtCpycontactperson = TextEditingController();
  String _customerStatus = 'Active';
  List<Map<String, dynamic>> _listCustomer = [];
  int? _selectedCustomerIndex;

  // Origin tab
  final TextEditingController txtCtyId = TextEditingController();
  final TextEditingController txtCtyname = TextEditingController();
  final TextEditingController txtOsmAddress = TextEditingController();
  final TextEditingController txtLat = TextEditingController();
  final TextEditingController txtLon = TextEditingController();
  String? _originCtyalias;
  String? _originType;
  List<Map<String, dynamic>> _listOriginAlias = [];
  List<Map<String, dynamic>> _listOrigin = [];
  List<dynamic> _osmAddressSuggestions = [];
  bool _osmSearching = false;
  Timer? _osmSearchDebounce;
  int? _selectedOriginIndex;

  static const List<Map<String, String>> _originTypeOptions = [
    {'value': '', 'label': 'Pilih Origin Type'},
    {'value': '1', 'label': 'Normal'},
    {'value': '2', 'label': 'Bag (40)'},
    {'value': '3', 'label': 'Bag (50)'},
    {'value': '6', 'label': 'Rdt (DP-2)'},
    {'value': '7', 'label': 'Giga (DP -4)'},
    {'value': '4', 'label': 'Solar Dalam (NB)'},
    {'value': '5', 'label': 'Normal (1 Way)'},
    {'value': '8', 'label': 'Rdt (1 Way)'},
    {'value': '9', 'label': 'Giga (1 Way)'},
    {'value': '10', 'label': 'Rdt 28T'},
    {'value': '11', 'label': 'Giga 28T'},
    {'value': '12', 'label': 'Rdt 28T (1 Way)'},
    {'value': '13', 'label': 'Giga 28T (1 Way)'},
    {'value': '14', 'label': 'Normal (2 balikan)'},
  ];

  // Destination tab
  final TextEditingController txtDestCtyId = TextEditingController();
  final TextEditingController txtDestCtyname = TextEditingController();
  final TextEditingController txtDestOsmAddress = TextEditingController();
  final TextEditingController txtDestLat = TextEditingController();
  final TextEditingController txtDestLon = TextEditingController();
  final TextEditingController txtDestType = TextEditingController(text: 'SPECIFIC');
  List<Map<String, dynamic>> _listDestination = [];
  List<dynamic> _osmDestSuggestions = [];
  bool _osmDestSearching = false;
  Timer? _osmDestSearchDebounce;
  int? _selectedDestinationIndex;
  static const String _destinationType = 'SPECIFIC';

  // Item Type tab
  final TextEditingController txtItpid = TextEditingController();
  final TextEditingController txtItpdescr = TextEditingController();
  final TextEditingController txtItpalias = TextEditingController();
  List<Map<String, dynamic>> _listItemType = [];
  int? _selectedItemTypeIndex;

  // Client tab
  final TextEditingController txtLocid = TextEditingController();
  final TextEditingController txtLocationtype = TextEditingController();
  final TextEditingController txtLocname = TextEditingController();
  final TextEditingController txtLocaddress1 = TextEditingController();
  final TextEditingController txtLocaddress2 = TextEditingController();
  final TextEditingController txtLocprovince = TextEditingController();
  String? _clientZone;
  List<Map<String, dynamic>> _listZoneOptions = [];
  final TextEditingController txtLoccompany = TextEditingController(text: 'AN');
  final TextEditingController txtLoccontactperson = TextEditingController();
  final TextEditingController txtLocphone1 = TextEditingController();
  final TextEditingController txtLocphone2 = TextEditingController();
  final TextEditingController txtLocfax1 = TextEditingController();
  final TextEditingController txtLocfax2 = TextEditingController();
  String _clientStatus = 'Active';
  List<Map<String, dynamic>> _listClient = [];
  int? _selectedClientIndex;
  List<Map<String, dynamic>> _clientCompanyOptions = [];

  static const List<String> _clientProvinceOptions = [
    'Aceh (NAD)',
    'Sumatra Utara',
    'Riau',
    'Sumatra Barat',
    'Jambi',
    'Sumatra Selatan',
    'Bengkulu',
    'Lampung',
    'Jawa Timur',
    'Jawa Tengah',
    'Yogyakarta (DIY)',
    'Jakarta (DKI)',
    'Jawa Barat',
    'Banten',
    'Kalimantan Selatan',
    'Kalimantan Timur',
    'Kalimantan Tengah',
    'Kalimantan Barat',
    'Sulawesi Selatan',
    'Sulawesi Tengah',
    'Sulawesi Tenggara',
    'Sulawesi Utara',
    'Nusa Tenggara Timur',
    'Nusa Tenggara Barat',
    'Bali',
    'Maluku',
    'Papua',
  ];

  // Zone tab
  final TextEditingController txtZoneid = TextEditingController();
  final TextEditingController txtZonename = TextEditingController();
  String? _zoneDefaultZone;
  final TextEditingController txtZonetype = TextEditingController();
  String? _zoneVhtype;
  String? _zoneOrigin;
  final TextEditingController txtZonetarif = TextEditingController();
  String _zoneStatus = 'Active';
  List<Map<String, dynamic>> _listZone = [];
  List<Map<String, dynamic>> _listVhtypeOptions = [];
  List<Map<String, dynamic>> _listDefaultZoneOptions = [];
  int? _selectedZoneIndex;

  bool getAkses(String akses) {
    return globals.akses_pages.contains(akses);
  }

  bool _hasAccess() {
    return true;
  }

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FrmMasterMenu()),
    );
  }

  // --- MD Styling Helpers ---

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
    String? label,
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? helperText,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 11),
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

  Widget _buildStatusBadge(String status) {
    Color statusBg = lightOrange;
    Color statusText = darkOrange;
    Color statusBorder = accentOrange;

    final s = status.toUpperCase().trim();
    if (s == 'ACTIVE' || s == 'AKTIF' || s == 'APPROVED' || s == 'SELESAI') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade800;
      statusBorder = Colors.green.shade200;
    } else if (s == 'INACTIVE' || s == 'NONAKTIF' || s == 'CANCEL' || s == 'BATAL') {
      statusBg = Colors.red.shade50;
      statusText = Colors.red.shade800;
      statusBorder = Colors.red.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusBorder),
      ),
      child: Text(
        s.isEmpty ? 'ACTIVE' : s,
        style: TextStyle(
          color: statusText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _ntListCard({
    required String title,
    Widget? trailing,
    required List<Widget> rows,
    Widget? actions,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x73FFB347)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
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
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: actions,
            ),
        ],
      ),
    );
  }

  Widget _buildSubTabBar({
    required String entityName,
    required int tabIndex,
    required int itemCount,
    required VoidCallback onAdd,
  }) {
    final mode = _subModes[tabIndex];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lightOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x59FFB347)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _subModes[tabIndex] = 0),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: mode == 0 ? primaryOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: mode == 0
                      ? [BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_list_bulleted,
                      size: 16,
                      color: mode == 0 ? Colors.white : darkOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daftar $entityName ($itemCount)',
                      style: TextStyle(
                        color: mode == 0 ? Colors.white : darkOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                if (mode != 1) {
                  onAdd();
                }
              },
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: mode == 1 ? primaryOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: mode == 1
                      ? [BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 18,
                      color: mode == 1 ? Colors.white : darkOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Form $entityName',
                      style: TextStyle(
                        color: mode == 1 ? Colors.white : darkOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: accentOrange),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smartSelectContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: child,
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final ctx = globalScaffoldKey.currentContext;
    if (ctx == null) return false;
    final result = await showDialog<bool>(
      context: ctx,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        title: Text(
          title,
          style: TextStyle(color: darkOrange, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ntBtnStyle(primaryOrange),
            onPressed: () => Navigator.of(context).pop(true),
            child: ntBtnLabel('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
    return result == true;
  }

  // =========================================================================
  // --- Customer Tab Logic & UI ---
  // =========================================================================
  static const String _customerListApi = 'api/master/refference_api.jsp';
  static const String _customerSaveApi = 'api/master/save_new_customer_api2.jsp';

  Future<void> getListCustomer() async {
    try {
      EasyLoading.show();
      final baseURL = '${GlobalData.baseUrlOri}$_customerListApi?method=customer';
      final url = Uri.parse(baseURL);
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = response.body.trim();
        List<dynamic> decoded = [];
        if (body.isNotEmpty && body != 'Data not found') {
          try {
            decoded = jsonDecode(body) is List
                ? jsonDecode(body) as List
                : (jsonDecode(body) as Map)['data'] as List? ?? [];
          } catch (_) {}
        }
        setState(() {
          _listCustomer = decoded
              .map((e) => (e is Map ? e : {}) as Map<String, dynamic>)
              .toList();
          _selectedCustomerIndex = null;
        });
      } else {
        setState(() => _listCustomer = []);
      }
    } catch (e) {
      if (mounted) {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "Gagal load data customer: $e", "error");
        }
      }
      setState(() => _listCustomer = []);
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _saveOrUpdateCustomer() async {
    final cpyname = txtCpyname.text.trim();
    final cpycontactperson = txtCpycontactperson.text.trim();
    if (cpyname.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Cust Name tidak boleh kosong", "error");
      return;
    }
    if (cpycontactperson.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Contact Person tidak boleh kosong", "error");
      return;
    }
    final cpyid = txtCpyId.text.trim();
    final method = cpyid.isEmpty ? 'add' : 'update';
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_customerSaveApi').replace(
        queryParameters: {
          'method': method,
          'cpyname': cpyname,
          'cpyid': cpyid,
          'cpyaddress': txtCpyaddress.text,
          'cpynpwp': txtCpynpwp.text,
          'cpycontcatperson': cpycontactperson,
          'status': _customerStatus,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetCustomerForm();
        await getListCustomer();
        setState(() => _subModes[0] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  void resetCustomerForm() {
    txtCpyId.clear();
    txtCpyname.clear();
    txtCpyaddress.clear();
    txtCpynpwp.clear();
    txtCpycontactperson.clear();
    setState(() {
      _customerStatus = 'Active';
      _selectedCustomerIndex = null;
    });
  }

  void _onCustomerRowTap(Map<String, dynamic> item, int index) {
    txtCpyId.text = item['cpyid'] ?? item['CPYID'] ?? '';
    txtCpyname.text = item['cpyname'] ?? item['CPYNAME'] ?? '';
    txtCpyaddress.text = item['cpyaddress'] ?? item['cpyaddress1'] ?? item['CPYADDRESS1'] ?? '';
    txtCpynpwp.text = item['cpynpwp'] ?? item['cpynpwp '] ?? item['CPYNPWP'] ?? '';
    txtCpycontactperson.text = item['cpycontactperson'] ?? item['cpyaccountnbr'] ?? item['cpycontcatperson'] ?? item['CPYACCOUNTNBR'] ?? '';
    setState(() {
      _customerStatus = item['status'] ?? item['cpystatus'] ?? item['CPYSTATUS'] ?? 'Active';
      _selectedCustomerIndex = index;
    });
  }

  Widget _buildCustomerList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        // Search bar & Add Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCustomerCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: softDecoration(
                    hint: 'Cari customer, ID, atau alamat...',
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                    suffixIcon: _searchCustomerCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchCustomerCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ntBtnStyle(primaryOrange),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: ntBtnLabel('Tambah'),
                onPressed: () {
                  resetCustomerForm();
                  setState(() => _subModes[0] = 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: getListCustomer,
            child: items.isEmpty
                ? _buildEmptyState('Tidak ada data Customer.\nTarik ke bawah untuk refresh.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final cpyid = item['cpyid'] ?? item['CPYID'] ?? '';
                      final cpyname = item['cpyname'] ?? item['CPYNAME'] ?? '';
                      final addr = item['cpyaddress'] ?? item['cpyaddress1'] ?? item['CPYADDRESS1'] ?? '';
                      final contact = item['cpycontactperson'] ?? item['cpyaccountnbr'] ?? item['cpycontcatperson'] ?? item['CPYACCOUNTNBR'] ?? '';
                      final npwp = item['cpynpwp'] ?? item['cpynpwp '] ?? item['CPYNPWP'] ?? '';
                      final st = item['status'] ?? item['cpystatus'] ?? item['CPYSTATUS'] ?? 'Active';

                      return _ntListCard(
                        title: 'Cust ID: $cpyid',
                        trailing: _buildStatusBadge(st.toString()),
                        rows: [
                          _kv('Nama Customer', cpyname.toString(), valueWeight: FontWeight.w700),
                          _kv('Alamat', addr.toString()),
                          _kv('NPWP', npwp.toString()),
                          _kv('Singkatan / Kontak', contact.toString()),
                        ],
                        actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ntBtnStyle(primaryOrange),
                              icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                              label: ntBtnLabel('Edit Data'),
                              onPressed: () {
                                _onCustomerRowTap(item, index);
                                setState(() => _subModes[0] = 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerForm() {
    final isEdit = txtCpyId.text.trim().isNotEmpty || _selectedCustomerIndex != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                  Icon(Icons.person_outline, color: primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Data Customer' : 'Tambah Customer Baru',
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Form Fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Customer ID'),
                  TextField(
                    controller: txtCpyId,
                    readOnly: true,
                    decoration: softDecoration(
                      hint: 'Otomatis di-generate sistem',
                      helperText: '* Auto-generate oleh sistem',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Nama Customer *'),
                  TextField(
                    controller: txtCpyname,
                    decoration: softDecoration(hint: 'Masukkan nama customer...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Alamat Customer'),
                  TextField(
                    controller: txtCpyaddress,
                    maxLines: 2,
                    decoration: softDecoration(hint: 'Masukkan alamat customer...'),
                  ),
                  const SizedBox(height: 12),
                  _label('NPWP Customer'),
                  TextField(
                    controller: txtCpynpwp,
                    decoration: softDecoration(hint: 'Masukkan NPWP...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Singkatan Customer / Contact Person *'),
                  TextField(
                    controller: txtCpycontactperson,
                    decoration: softDecoration(hint: 'Masukkan singkatan atau kontak...'),
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
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
                        onPressed: () {
                          resetCustomerForm();
                          setState(() => _subModes[0] = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(accentOrange),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: ntBtnLabel('Reset'),
                        onPressed: resetCustomerForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(primaryOrange),
                        icon: const Icon(Icons.save, size: 16, color: Colors.white),
                        label: ntBtnLabel(isEdit ? 'Update' : 'Simpan'),
                        onPressed: () async {
                          final msg = isEdit ? 'Update data Customer?' : 'Simpan data Customer?';
                          if (await _showConfirmDialog('Konfirmasi', msg)) {
                            _saveOrUpdateCustomer();
                          }
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

  Widget _buildCustomerTab() {
    final query = _searchCustomerCtrl.text.trim().toLowerCase();
    final filtered = _listCustomer.where((item) {
      if (query.isEmpty) return true;
      final id = (item['cpyid'] ?? item['CPYID'] ?? '').toString().toLowerCase();
      final name = (item['cpyname'] ?? item['CPYNAME'] ?? '').toString().toLowerCase();
      final contact = (item['cpycontactperson'] ?? item['cpyaccountnbr'] ?? item['cpycontcatperson'] ?? '').toString().toLowerCase();
      final addr = (item['cpyaddress'] ?? item['cpyaddress1'] ?? '').toString().toLowerCase();
      return id.contains(query) || name.contains(query) || contact.contains(query) || addr.contains(query);
    }).toList();

    return Column(
      children: [
        _buildSubTabBar(
          entityName: 'Customer',
          tabIndex: 0,
          itemCount: filtered.length,
          onAdd: () {
            resetCustomerForm();
            setState(() => _subModes[0] = 1);
          },
        ),
        Expanded(
          child: _subModes[0] == 0
              ? _buildCustomerList(filtered)
              : _buildCustomerForm(),
        ),
      ],
    );
  }

  // =========================================================================
  // --- Origin Tab Logic & UI ---
  // =========================================================================
  static const String _refApi = 'api/master/refference_api.jsp';
  static const String _originSaveApi = 'api/master/save_new_origin_api.jsp';

  Future<void> getListOriginAlias() async {
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=id_origin_alias');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200 && response.body.trim() != 'Data not found') {
        try {
          final decoded = jsonDecode(response.body) as List;
          setState(() {
            _listOriginAlias = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          });
        } catch (_) {
          setState(() => _listOriginAlias = []);
        }
      } else {
        setState(() => _listOriginAlias = []);
      }
    } catch (_) {
      setState(() => _listOriginAlias = []);
    }
  }

  Future<void> getListOrigin() async {
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=origin');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = response.body.trim();
        List<dynamic> decoded = [];
        if (body.isNotEmpty && body != 'Data not found') {
          try {
            decoded = jsonDecode(body) is List ? jsonDecode(body) as List : [];
          } catch (_) {}
        }
        setState(() {
          _listOrigin = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          _selectedOriginIndex = null;
        });
      } else {
        setState(() => _listOrigin = []);
      }
    } catch (e) {
      if (mounted) alert(globalScaffoldKey.currentContext!, 0, "Gagal load data origin: $e", "error");
      setState(() => _listOrigin = []);
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOsmSuggestions(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    Future<List<Map<String, dynamic>>> parseList(String body) async {
      final trimmed = body.trim();
      if (trimmed.isEmpty || trimmed == '[]') return [];
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is! List) return [];
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } catch (_) {
        return [];
      }
    }

    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}api/osm_address.jsp').replace(
        queryParameters: {'query': q},
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        final list = await parseList(response.body);
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}

    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'q': q,
          'format': 'json',
          'addressdetails': '0',
          'limit': '8',
          'countrycodes': 'id',
        },
      );
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "User-Agent": "DMS-ANP-MasterData/1.0 (Flutter; contact: admin@tuluatas.com)",
      });
      if (response.statusCode == 200) {
        return await parseList(response.body);
      }
    } catch (_) {}

    return [];
  }

  Future<void> _searchOsmAddress(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() { _osmAddressSuggestions = []; _osmSearching = false; });
      return;
    }
    setState(() => _osmSearching = true);
    final list = await _fetchOsmSuggestions(q);
    if (!mounted) return;
    setState(() {
      _osmAddressSuggestions = list;
      _osmSearching = false;
    });
    if (list.isEmpty && q.length >= 2) {
      alert(globalScaffoldKey.currentContext!, 0, "Alamat tidak ditemukan. Coba kata kunci lain.", "error");
    }
  }

  void _onOsmAddressSelected(Map<String, dynamic> item) {
    final lat = item['lat']?.toString() ?? '';
    final lon = item['lon']?.toString() ?? '';
    final name = item['display_name'] ?? item['name'] ?? txtOsmAddress.text;
    setState(() {
      txtOsmAddress.text = name is String ? name : txtOsmAddress.text;
      txtLat.text = lat;
      txtLon.text = lon;
      _osmAddressSuggestions = [];
    });
  }

  Future<void> _saveOrUpdateOrigin() async {
    final ctyname = txtCtyname.text.trim();
    if (ctyname.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Nama Origin tidak boleh kosong", "error");
      return;
    }
    if (_originType == null || _originType!.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Origin Type tidak boleh kosong", "error");
      return;
    }
    final ctyid = txtCtyId.text.trim();
    final method = ctyid.isEmpty ? 'add' : 'update';
    final ctyalias = _originCtyalias ?? '';
    final lat = txtLat.text.trim().isEmpty ? '0' : txtLat.text.trim();
    final lon = txtLon.text.trim().isEmpty ? '0' : txtLon.text.trim();
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_originSaveApi').replace(
        queryParameters: {
          'method': method,
          'ctyid': ctyid,
          'ctyname': ctyname,
          'originType': _originType!,
          'ctyalias': ctyalias,
          'lat': lat,
          'lon': lon,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetOriginForm();
        await getListOrigin();
        setState(() => _subModes[1] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  void resetOriginForm() {
    txtCtyId.clear();
    txtCtyname.clear();
    txtOsmAddress.clear();
    txtLat.clear();
    txtLon.clear();
    setState(() {
      _originCtyalias = null;
      _originType = null;
      _selectedOriginIndex = null;
    });
  }

  void _onOriginRowTap(Map<String, dynamic> item, int index) {
    txtCtyId.text = item['ctyid'] ?? item['CTYID'] ?? '';
    txtCtyname.text = item['ctyname'] ?? item['CTYNAME'] ?? '';
    setState(() {
      _originCtyalias = item['ctyalias'] ?? item['CTYALIAS'];
      _selectedOriginIndex = index;
    });
    txtLat.text = item['lat']?.toString() ?? item['LOCID5'] ?? '';
    txtLon.text = item['lon']?.toString() ?? item['LOCID6'] ?? '';
    txtOsmAddress.text = '';
  }

  Widget _buildOsmSuggestionList({
    required List<dynamic> suggestions,
    required bool searching,
    required void Function(Map<String, dynamic> item) onSelected,
  }) {
    if (searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
          ),
        ),
      );
    }
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, i) {
          final raw = suggestions[i];
          final item = (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});
          final name = item['display_name'] ?? item['name'] ?? '';
          return ListTile(
            dense: true,
            leading: Icon(Icons.place, color: primaryOrange, size: 20),
            title: Text(
              name is String ? name : '$name',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => onSelected(item),
          );
        },
      ),
    );
  }

  Widget _buildOriginList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchOriginCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: softDecoration(
                    hint: 'Cari origin, ID, atau alias...',
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                    suffixIcon: _searchOriginCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchOriginCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ntBtnStyle(primaryOrange),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: ntBtnLabel('Tambah'),
                onPressed: () {
                  resetOriginForm();
                  setState(() => _subModes[1] = 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: () async {
              await getListOriginAlias();
              await getListOrigin();
            },
            child: items.isEmpty
                ? _buildEmptyState('Tidak ada data Origin.\nTarik ke bawah untuk refresh.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final ctyid = item['ctyid'] ?? item['CTYID'] ?? '';
                      final ctyname = item['ctyname'] ?? item['CTYNAME'] ?? '';
                      final ctyalias = item['ctyalias'] ?? item['CTYALIAS'] ?? '';
                      final lat = item['lat']?.toString() ?? item['LOCID5'] ?? '';
                      final lon = item['lon']?.toString() ?? item['LOCID6'] ?? '';

                      return _ntListCard(
                        title: 'ID Origin: $ctyid',
                        trailing: ctyalias.toString().isNotEmpty
                            ? _buildStatusBadge(ctyalias.toString())
                            : null,
                        rows: [
                          _kv('Nama Origin', ctyname.toString(), valueWeight: FontWeight.w700),
                          _kv('Cty Alias', ctyalias.toString()),
                          _kv('Latitude', lat.toString()),
                          _kv('Longitude', lon.toString()),
                        ],
                        actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ntBtnStyle(primaryOrange),
                              icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                              label: ntBtnLabel('Edit Data'),
                              onPressed: () {
                                _onOriginRowTap(item, index);
                                setState(() => _subModes[1] = 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginForm() {
    final isEdit = txtCtyId.text.trim().isNotEmpty || _selectedOriginIndex != null;
    final aliasChoices = _listOriginAlias
        .map((e) => S2Choice<String>(
            value: e['value'] ?? e['text'] ?? '',
            title: e['text'] ?? e['value'] ?? ''))
        .toList();
    final originTypeChoices = _originTypeOptions
        .map((e) => S2Choice<String>(value: e['value']!, title: e['label']!))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                  Icon(Icons.place_outlined, color: primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Data Origin' : 'Tambah Origin Baru',
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
                  _label('ID Origin'),
                  TextField(
                    controller: txtCtyId,
                    readOnly: true,
                    decoration: softDecoration(
                      hint: 'Otomatis di-generate sistem',
                      helperText: '* Auto-generate oleh sistem',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Nama Origin *'),
                  TextField(
                    controller: txtCtyname,
                    decoration: softDecoration(hint: 'Masukkan nama origin...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Cty Alias'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Cty Alias',
                      selectedValue: _originCtyalias,
                      choiceItems: aliasChoices,
                      onChange: (s) => setState(() => _originCtyalias = s.value),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Cty Alias...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Origin Type *'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Origin Type',
                      selectedValue: _originType,
                      choiceItems: originTypeChoices,
                      onChange: (s) => setState(() => _originType = s.value),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Origin Type...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Cari Alamat (OpenStreetMap)'),
                  TextField(
                    controller: txtOsmAddress,
                    textInputAction: TextInputAction.search,
                    onChanged: (q) {
                      _osmSearchDebounce?.cancel();
                      _osmSearchDebounce = Timer(const Duration(milliseconds: 500), () {
                        _searchOsmAddress(q);
                      });
                    },
                    onSubmitted: (q) => _searchOsmAddress(q),
                    decoration: softDecoration(
                      hint: 'Ketik alamat pencarian...',
                      helperText: 'Ketik alamat lalu pilih hasil, atau ambil dari peta',
                      suffixIcon: IconButton(
                        icon: _osmSearching
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
                              )
                            : Icon(Icons.search, color: primaryOrange),
                        onPressed: _osmSearching ? null : () => _searchOsmAddress(txtOsmAddress.text),
                      ),
                    ),
                  ),
                  _buildOsmSuggestionList(
                    suggestions: _osmAddressSuggestions,
                    searching: _osmSearching,
                    onSelected: _onOsmAddressSelected,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x59FFB347)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.map, color: primaryOrange),
                      title: Text(
                        'Ambil koordinat dari peta',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkOrange),
                      ),
                      trailing: Icon(Icons.chevron_right, color: primaryOrange),
                      onTap: () async {
                        final initLat = double.tryParse(txtLat.text);
                        final initLon = double.tryParse(txtLon.text);
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FrmKoordinat(initialLat: initLat, initialLon: initLon),
                          ),
                        );
                        if (res is Map) {
                          setState(() {
                            txtLat.text = (res['lat'] ?? '').toString();
                            txtLon.text = (res['lon'] ?? '').toString();
                            final addr = res['address']?.toString();
                            if (addr != null && addr.isNotEmpty) {
                              txtOsmAddress.text = addr;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Latitude'),
                            TextField(
                              controller: txtLat,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: softDecoration(hint: '-6.xxxx'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Longitude'),
                            TextField(
                              controller: txtLon,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: softDecoration(hint: '106.xxxx'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: () {
                          resetOriginForm();
                          setState(() => _subModes[1] = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(accentOrange),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: ntBtnLabel('Reset'),
                        onPressed: resetOriginForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(primaryOrange),
                        icon: const Icon(Icons.save, size: 16, color: Colors.white),
                        label: ntBtnLabel(isEdit ? 'Update' : 'Simpan'),
                        onPressed: () async {
                          final msg = isEdit ? 'Update data Origin?' : 'Simpan data Origin?';
                          if (await _showConfirmDialog('Konfirmasi', msg)) {
                            _saveOrUpdateOrigin();
                          }
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

  Widget _buildOriginTab() {
    final query = _searchOriginCtrl.text.trim().toLowerCase();
    final filtered = _listOrigin.where((item) {
      if (query.isEmpty) return true;
      final id = (item['ctyid'] ?? item['CTYID'] ?? '').toString().toLowerCase();
      final name = (item['ctyname'] ?? item['CTYNAME'] ?? '').toString().toLowerCase();
      final alias = (item['ctyalias'] ?? item['CTYALIAS'] ?? '').toString().toLowerCase();
      return id.contains(query) || name.contains(query) || alias.contains(query);
    }).toList();

    return Column(
      children: [
        _buildSubTabBar(
          entityName: 'Origin',
          tabIndex: 1,
          itemCount: filtered.length,
          onAdd: () {
            resetOriginForm();
            setState(() => _subModes[1] = 1);
          },
        ),
        Expanded(
          child: _subModes[1] == 0
              ? _buildOriginList(filtered)
              : _buildOriginForm(),
        ),
      ],
    );
  }

  // =========================================================================
  // --- Destination Tab Logic & UI ---
  // =========================================================================
  static const String _destinationSaveApi = 'api/master/save_new_destination_api.jsp';

  Future<void> getListDestination() async {
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=destination');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = response.body.trim();
        List<dynamic> decoded = [];
        if (body.isNotEmpty && body != 'Data not found') {
          try {
            decoded = jsonDecode(body) is List ? jsonDecode(body) as List : [];
          } catch (_) {}
        }
        setState(() {
          _listDestination = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          _selectedDestinationIndex = null;
        });
      } else {
        setState(() => _listDestination = []);
      }
    } catch (e) {
      if (mounted) alert(globalScaffoldKey.currentContext!, 0, "Gagal load data destination: $e", "error");
      setState(() => _listDestination = []);
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _searchOsmAddressDest(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() { _osmDestSuggestions = []; _osmDestSearching = false; });
      return;
    }
    setState(() => _osmDestSearching = true);
    final list = await _fetchOsmSuggestions(q);
    if (!mounted) return;
    setState(() {
      _osmDestSuggestions = list;
      _osmDestSearching = false;
    });
    if (list.isEmpty && q.length >= 2) {
      alert(globalScaffoldKey.currentContext!, 0, "Alamat tidak ditemukan. Coba kata kunci lain.", "error");
    }
  }

  void _onOsmDestSelected(Map<String, dynamic> item) {
    final lat = item['lat']?.toString() ?? '';
    final lon = item['lon']?.toString() ?? '';
    final name = item['display_name'] ?? item['name'] ?? txtDestOsmAddress.text;
    setState(() {
      txtDestOsmAddress.text = name is String ? name : txtDestOsmAddress.text;
      txtDestLat.text = lat;
      txtDestLon.text = lon;
      _osmDestSuggestions = [];
    });
  }

  Future<void> _saveOrUpdateDestination() async {
    final ctyname = txtDestCtyname.text.trim();
    if (ctyname.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Nama Proyek/Tujuan tidak boleh kosong", "error");
      return;
    }
    final ctyid = txtDestCtyId.text.trim();
    final method = ctyid.isEmpty ? 'add' : 'update';
    final lat = txtDestLat.text.trim().isEmpty ? '0' : txtDestLat.text.trim();
    final lon = txtDestLon.text.trim().isEmpty ? '0' : txtDestLon.text.trim();
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_destinationSaveApi').replace(
        queryParameters: {
          'method': method,
          'ctyid': ctyid,
          'ctyname': ctyname,
          'destionationType': _destinationType,
          'lat': lat,
          'lon': lon,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetDestinationForm();
        await getListDestination();
        setState(() => _subModes[2] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  void resetDestinationForm() {
    txtDestCtyId.clear();
    txtDestCtyname.clear();
    txtDestOsmAddress.clear();
    txtDestLat.clear();
    txtDestLon.clear();
    setState(() => _selectedDestinationIndex = null);
  }

  void _onDestinationRowTap(Map<String, dynamic> item, int index) {
    txtDestCtyId.text = item['ctyid'] ?? item['CTYID'] ?? '';
    txtDestCtyname.text = item['ctyname'] ?? item['CTYNAME'] ?? '';
    txtDestLat.text = item['lat']?.toString() ?? item['LOCID5'] ?? '';
    txtDestLon.text = item['lon']?.toString() ?? item['LOCID6'] ?? '';
    txtDestOsmAddress.text = '';
    setState(() => _selectedDestinationIndex = index);
  }

  Widget _buildDestinationList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchDestCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: softDecoration(
                    hint: 'Cari destination, ID, atau nama...',
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                    suffixIcon: _searchDestCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchDestCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ntBtnStyle(primaryOrange),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: ntBtnLabel('Tambah'),
                onPressed: () {
                  resetDestinationForm();
                  setState(() => _subModes[2] = 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: getListDestination,
            child: items.isEmpty
                ? _buildEmptyState('Tidak ada data Destination.\nTarik ke bawah untuk refresh.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final ctyid = item['ctyid'] ?? item['CTYID'] ?? '';
                      final ctyname = item['ctyname'] ?? item['CTYNAME'] ?? '';
                      final ctytype = item['ctytype'] ?? item['CTYTYPE'] ?? '';
                      final lat = item['lat']?.toString() ?? item['LOCID5'] ?? '';
                      final lon = item['lon']?.toString() ?? item['LOCID6'] ?? '';

                      return _ntListCard(
                        title: 'ID Destination: $ctyid',
                        trailing: ctytype.toString().isNotEmpty
                            ? _buildStatusBadge(ctytype.toString())
                            : null,
                        rows: [
                          _kv('Nama Proyek / Tujuan', ctyname.toString(), valueWeight: FontWeight.w700),
                          _kv('Type', ctytype.toString()),
                          _kv('Latitude', lat.toString()),
                          _kv('Longitude', lon.toString()),
                        ],
                        actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ntBtnStyle(primaryOrange),
                              icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                              label: ntBtnLabel('Edit Data'),
                              onPressed: () {
                                _onDestinationRowTap(item, index);
                                setState(() => _subModes[2] = 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationForm() {
    final isEdit = txtDestCtyId.text.trim().isNotEmpty || _selectedDestinationIndex != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                  Icon(Icons.navigation_outlined, color: primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Data Destination' : 'Tambah Destination Baru',
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
                  _label('ID Destination'),
                  TextField(
                    controller: txtDestCtyId,
                    decoration: softDecoration(
                      hint: 'Otomatis di-generate sistem atau diisi manual',
                      helperText: 'Generate otomatis jika dikosongkan',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Nama Proyek / Tujuan *'),
                  TextField(
                    controller: txtDestCtyname,
                    decoration: softDecoration(hint: 'Masukkan nama proyek atau tujuan...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Cari Alamat (OpenStreetMap)'),
                  TextField(
                    controller: txtDestOsmAddress,
                    onChanged: (q) {
                      _osmDestSearchDebounce?.cancel();
                      _osmDestSearchDebounce = Timer(const Duration(milliseconds: 500), () {
                        _searchOsmAddressDest(q);
                      });
                    },
                    decoration: softDecoration(
                      hint: 'Ketik alamat pencarian...',
                      helperText: 'Ketik alamat lalu pilih hasil, atau ambil dari peta',
                      suffixIcon: IconButton(
                        icon: _osmDestSearching
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
                              )
                            : Icon(Icons.search, color: primaryOrange),
                        onPressed: _osmDestSearching ? null : () => _searchOsmAddressDest(txtDestOsmAddress.text),
                      ),
                    ),
                  ),
                  _buildOsmSuggestionList(
                    suggestions: _osmDestSuggestions,
                    searching: _osmDestSearching,
                    onSelected: _onOsmDestSelected,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x59FFB347)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.map, color: primaryOrange),
                      title: Text(
                        'Ambil koordinat dari peta',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkOrange),
                      ),
                      trailing: Icon(Icons.chevron_right, color: primaryOrange),
                      onTap: () async {
                        final initLat = double.tryParse(txtDestLat.text);
                        final initLon = double.tryParse(txtDestLon.text);
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FrmKoordinat(initialLat: initLat, initialLon: initLon),
                          ),
                        );
                        if (res is Map) {
                          setState(() {
                            txtDestLat.text = (res['lat'] ?? '').toString();
                            txtDestLon.text = (res['lon'] ?? '').toString();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Latitude'),
                            TextField(
                              controller: txtDestLat,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: softDecoration(hint: '-6.xxxx'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Longitude'),
                            TextField(
                              controller: txtDestLon,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: softDecoration(hint: '106.xxxx'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: () {
                          resetDestinationForm();
                          setState(() => _subModes[2] = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(accentOrange),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: ntBtnLabel('Reset'),
                        onPressed: resetDestinationForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(primaryOrange),
                        icon: const Icon(Icons.save, size: 16, color: Colors.white),
                        label: ntBtnLabel(isEdit ? 'Update' : 'Simpan'),
                        onPressed: () async {
                          final msg = isEdit ? 'Update data Destination?' : 'Simpan data Destination?';
                          if (await _showConfirmDialog('Konfirmasi', msg)) {
                            _saveOrUpdateDestination();
                          }
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

  Widget _buildDestinationTab() {
    final query = _searchDestCtrl.text.trim().toLowerCase();
    final filtered = _listDestination.where((item) {
      if (query.isEmpty) return true;
      final id = (item['ctyid'] ?? item['CTYID'] ?? '').toString().toLowerCase();
      final name = (item['ctyname'] ?? item['CTYNAME'] ?? '').toString().toLowerCase();
      return id.contains(query) || name.contains(query);
    }).toList();

    return Column(
      children: [
        _buildSubTabBar(
          entityName: 'Destination',
          tabIndex: 2,
          itemCount: filtered.length,
          onAdd: () {
            resetDestinationForm();
            setState(() => _subModes[2] = 1);
          },
        ),
        Expanded(
          child: _subModes[2] == 0
              ? _buildDestinationList(filtered)
              : _buildDestinationForm(),
        ),
      ],
    );
  }

  // =========================================================================
  // --- Item Type Tab Logic & UI ---
  // =========================================================================
  static const String _itemTypeSaveApi = 'api/master/save_new_item_api.jsp';

  Future<void> getListItemType() async {
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=item');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = response.body.trim();
        List<dynamic> decoded = [];
        if (body.isNotEmpty && body != 'Data not found') {
          try {
            decoded = jsonDecode(body) is List ? jsonDecode(body) as List : [];
          } catch (_) {}
        }
        setState(() {
          _listItemType = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          _selectedItemTypeIndex = null;
        });
      } else {
        setState(() => _listItemType = []);
      }
    } catch (e) {
      if (mounted) alert(globalScaffoldKey.currentContext!, 0, "Gagal load data Item Type: $e", "error");
      setState(() => _listItemType = []);
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _saveOrUpdateItemType() async {
    final itpid = txtItpid.text.trim();
    final itpdescr = txtItpdescr.text.trim();
    if (itpid.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Item ID tidak boleh kosong", "error");
      return;
    }
    if (itpdescr.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Item Name tidak boleh kosong", "error");
      return;
    }
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_itemTypeSaveApi').replace(
        queryParameters: {
          'method': 'add',
          'itpid': itpid,
          'itpdescr': itpdescr,
          'itpalias': txtItpalias.text,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetItemTypeForm();
        await getListItemType();
        setState(() => _subModes[3] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  Future<void> _updateItemType() async {
    final itpid = txtItpid.text.trim();
    final itpdescr = txtItpdescr.text.trim();
    if (itpid.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Item ID tidak boleh kosong", "error");
      return;
    }
    if (itpdescr.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Item Name tidak boleh kosong", "error");
      return;
    }
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_itemTypeSaveApi').replace(
        queryParameters: {
          'method': 'update',
          'itpid': itpid,
          'itpdescr': itpdescr,
          'itpalias': txtItpalias.text,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetItemTypeForm();
        await getListItemType();
        setState(() => _subModes[3] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  void resetItemTypeForm() {
    txtItpid.clear();
    txtItpdescr.clear();
    txtItpalias.clear();
    setState(() => _selectedItemTypeIndex = null);
  }

  void _onItemTypeRowTap(Map<String, dynamic> item, int index) {
    txtItpid.text = item['itpid'] ?? item['ITPID'] ?? '';
    txtItpdescr.text = item['itpdescr'] ?? item['ITPDESCR'] ?? '';
    txtItpalias.text = item['itpalias'] ?? item['ITPALIAS'] ?? '';
    setState(() => _selectedItemTypeIndex = index);
  }

  Widget _buildItemTypeList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchItemTypeCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: softDecoration(
                    hint: 'Cari item type, ID, atau nama...',
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                    suffixIcon: _searchItemTypeCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchItemTypeCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ntBtnStyle(primaryOrange),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: ntBtnLabel('Tambah'),
                onPressed: () {
                  resetItemTypeForm();
                  setState(() => _subModes[3] = 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: getListItemType,
            child: items.isEmpty
                ? _buildEmptyState('Tidak ada data Item Type.\nTarik ke bawah untuk refresh.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itpid = item['itpid'] ?? item['ITPID'] ?? '';
                      final itpdescr = item['itpdescr'] ?? item['ITPDESCR'] ?? '';
                      final itpalias = item['itpalias'] ?? item['ITPALIAS'] ?? '';

                      return _ntListCard(
                        title: 'Item ID: $itpid',
                        trailing: itpalias.toString().isNotEmpty
                            ? _buildStatusBadge(itpalias.toString())
                            : null,
                        rows: [
                          _kv('Item Name', itpdescr.toString(), valueWeight: FontWeight.w700),
                          _kv('Alias', itpalias.toString()),
                        ],
                        actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ntBtnStyle(primaryOrange),
                              icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                              label: ntBtnLabel('Edit Data'),
                              onPressed: () {
                                _onItemTypeRowTap(item, index);
                                setState(() => _subModes[3] = 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTypeForm() {
    final isEdit = _selectedItemTypeIndex != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                  Icon(Icons.category_outlined, color: primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Item Type' : 'Tambah Item Type Baru',
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
                  _label('Item ID *'),
                  TextField(
                    controller: txtItpid,
                    readOnly: isEdit,
                    decoration: softDecoration(
                      hint: 'Masukkan Item ID...',
                      readOnly: isEdit,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Item Name *'),
                  TextField(
                    controller: txtItpdescr,
                    decoration: softDecoration(hint: 'Masukkan nama item...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Alias'),
                  TextField(
                    controller: txtItpalias,
                    decoration: softDecoration(hint: 'Masukkan alias...'),
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: () {
                          resetItemTypeForm();
                          setState(() => _subModes[3] = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(accentOrange),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: ntBtnLabel('Reset'),
                        onPressed: resetItemTypeForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(primaryOrange),
                        icon: const Icon(Icons.save, size: 16, color: Colors.white),
                        label: ntBtnLabel(isEdit ? 'Update' : 'Simpan'),
                        onPressed: () async {
                          final msg = isEdit ? 'Update data Item Type?' : 'Simpan data Item Type?';
                          if (await _showConfirmDialog('Konfirmasi', msg)) {
                            if (isEdit) {
                              _updateItemType();
                            } else {
                              _saveOrUpdateItemType();
                            }
                          }
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

  Widget _buildItemTypeTab() {
    final query = _searchItemTypeCtrl.text.trim().toLowerCase();
    final filtered = _listItemType.where((item) {
      if (query.isEmpty) return true;
      final id = (item['itpid'] ?? item['ITPID'] ?? '').toString().toLowerCase();
      final desc = (item['itpdescr'] ?? item['ITPDESCR'] ?? '').toString().toLowerCase();
      final alias = (item['itpalias'] ?? item['ITPALIAS'] ?? '').toString().toLowerCase();
      return id.contains(query) || desc.contains(query) || alias.contains(query);
    }).toList();

    return Column(
      children: [
        _buildSubTabBar(
          entityName: 'Item Type',
          tabIndex: 3,
          itemCount: filtered.length,
          onAdd: () {
            resetItemTypeForm();
            setState(() => _subModes[3] = 1);
          },
        ),
        Expanded(
          child: _subModes[3] == 0
              ? _buildItemTypeList(filtered)
              : _buildItemTypeForm(),
        ),
      ],
    );
  }

  // =========================================================================
  // --- Client Tab Logic & UI ---
  // =========================================================================
  static const String _clientSaveApi = 'api/master/save_new_client_api.jsp';

  Future<void> getListZoneOptions() async {
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=zone');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200 && response.body.trim() != 'Data not found') {
        try {
          final decoded = jsonDecode(response.body) as List;
          setState(() {
            _listZoneOptions = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          });
        } catch (_) {
          setState(() => _listZoneOptions = []);
        }
      } else {
        setState(() => _listZoneOptions = []);
      }
    } catch (_) {
      setState(() => _listZoneOptions = []);
    }
  }

  Future<void> getListCompanyClient() async {
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=company-client');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200 && response.body.trim() != 'Data not found') {
        try {
          final decoded = jsonDecode(response.body) as List;
          setState(() {
            _clientCompanyOptions = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          });
        } catch (_) {
          setState(() => _clientCompanyOptions = []);
        }
      } else {
        setState(() => _clientCompanyOptions = []);
      }
    } catch (_) {
      setState(() => _clientCompanyOptions = []);
    }
  }

  Future<void> getListClient() async {
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=list-client');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = response.body.trim();
        List<dynamic> decoded = [];
        if (body.isNotEmpty && body != 'Data not found') {
          try {
            decoded = jsonDecode(body) is List ? jsonDecode(body) as List : [];
          } catch (_) {}
        }
        setState(() {
          _listClient = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          _selectedClientIndex = null;
        });
      } else {
        setState(() => _listClient = []);
      }
    } catch (e) {
      if (mounted) alert(globalScaffoldKey.currentContext!, 0, "Gagal load data Client: $e", "error");
      setState(() => _listClient = []);
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _saveOrUpdateClient() async {
    final locid = txtLocid.text.trim();
    final locname = txtLocname.text.trim();
    if (locname.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Nama tidak boleh kosong", "error");
      return;
    }
    final method = locid.isEmpty ? 'add' : 'update';
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_clientSaveApi').replace(
        queryParameters: {
          'method': method,
          'locid': locid,
          'locationtype': txtLocationtype.text,
          'locname': locname,
          'locaddress1': txtLocaddress1.text,
          'locaddress2': txtLocaddress2.text,
          'locprovince': txtLocprovince.text,
          'loczone': _clientZone ?? '',
          'loccompany': txtLoccompany.text.isEmpty ? 'AN' : txtLoccompany.text,
          'loccontactperson': txtLoccontactperson.text,
          'locphone1': txtLocphone1.text,
          'locphone2': txtLocphone2.text,
          'locfax1': txtLocfax1.text,
          'locfax2': txtLocfax2.text,
          'status': _clientStatus,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetClientForm();
        await getListClient();
        setState(() => _subModes[4] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  void resetClientForm() {
    txtLocid.clear();
    txtLocationtype.clear();
    txtLocname.clear();
    txtLocaddress1.clear();
    txtLocaddress2.clear();
    txtLocprovince.clear();
    setState(() => _clientZone = null);
    txtLoccompany.text = 'AN';
    txtLoccontactperson.clear();
    txtLocphone1.clear();
    txtLocphone2.clear();
    txtLocfax1.clear();
    txtLocfax2.clear();
    setState(() {
      _clientStatus = 'Active';
      _selectedClientIndex = null;
    });
  }

  void _onClientRowTap(Map<String, dynamic> item, int index) {
    txtLocid.text = item['locid'] ?? item['LOCID'] ?? '';
    txtLocationtype.text = item['locationtype'] ?? item['LOCATIONTYPE'] ?? '';
    txtLocname.text = item['locname'] ?? item['LOCNAME'] ?? '';
    txtLocaddress1.text = item['locaddress1'] ?? item['LOCADDRESS1'] ?? '';
    txtLocaddress2.text = item['locaddress2'] ?? item['LOCADDRESS2'] ?? '';
    txtLocprovince.text = item['locprovince'] ?? item['LOCPROVINCE'] ?? '';
    txtLoccompany.text = item['loccompany'] ?? item['LOCCOMPANY'] ?? 'AN';
    txtLoccontactperson.text = item['loccontactperson'] ?? item['LOCCONTACTPERSON'] ?? '';
    txtLocphone1.text = item['locphone1'] ?? item['LOCPHONE1'] ?? '';
    txtLocphone2.text = item['locphone2'] ?? item['LOCPHONE2'] ?? '';
    txtLocfax1.text = item['locfax1'] ?? item['LOCFAX1'] ?? '';
    txtLocfax2.text = item['locfax2'] ?? item['LOCFAX2'] ?? '';
    setState(() {
      _clientZone = item['loczone']?.toString() ?? item['LOCZONE']?.toString();
      _clientStatus = item['status'] ?? item['STATUS'] ?? 'Active';
      _selectedClientIndex = index;
    });
  }

  Widget _buildClientList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchClientCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: softDecoration(
                    hint: 'Cari client, CID, nama, kontak...',
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                    suffixIcon: _searchClientCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchClientCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ntBtnStyle(primaryOrange),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: ntBtnLabel('Tambah'),
                onPressed: () {
                  resetClientForm();
                  setState(() => _subModes[4] = 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: () async {
              await getListZoneOptions();
              await getListCompanyClient();
              await getListClient();
            },
            child: items.isEmpty
                ? _buildEmptyState('Tidak ada data Client.\nTarik ke bawah untuk refresh.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final locid = item['locid'] ?? item['LOCID'] ?? '';
                      final locname = item['locname'] ?? item['LOCNAME'] ?? '';
                      final addr = item['locaddress1'] ?? item['LOCADDRESS1'] ?? '';
                      final contact = item['loccontactperson'] ?? item['LOCCONTACTPERSON'] ?? '';
                      final phone = item['locphone1'] ?? item['LOCPHONE1'] ?? '';
                      final st = item['status'] ?? item['STATUS'] ?? 'Active';

                      return _ntListCard(
                        title: 'CID: $locid',
                        trailing: _buildStatusBadge(st.toString()),
                        rows: [
                          _kv('Nama Client', locname.toString(), valueWeight: FontWeight.w700),
                          _kv('Alamat', addr.toString()),
                          _kv('Contact Person', contact.toString()),
                          _kv('Phone', phone.toString()),
                        ],
                        actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ntBtnStyle(primaryOrange),
                              icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                              label: ntBtnLabel('Edit Data'),
                              onPressed: () {
                                _onClientRowTap(item, index);
                                setState(() => _subModes[4] = 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientForm() {
    final isEdit = txtLocid.text.trim().isNotEmpty || _selectedClientIndex != null;
    final zoneChoices = _listZoneOptions
        .map((e) => S2Choice<String>(
            value: e['value']?.toString() ?? e['text']?.toString() ?? '',
            title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    final companyChoices = _clientCompanyOptions
        .map((e) => S2Choice<String>(
            value: (e['value'] ?? e['text'] ?? '').toString(),
            title: (e['text'] ?? e['value'] ?? '').toString()))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                  Icon(Icons.business_outlined, color: primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Data Client' : 'Tambah Client Baru',
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
                  _label('Location ID'),
                  TextField(
                    controller: txtLocid,
                    readOnly: true,
                    decoration: softDecoration(
                      hint: 'Otomatis di-generate sistem',
                      helperText: '* Auto-generate oleh sistem',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Nama Client *'),
                  TextField(
                    controller: txtLocname,
                    decoration: softDecoration(hint: 'Masukkan nama client...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Alamat 1'),
                  TextField(
                    controller: txtLocaddress1,
                    decoration: softDecoration(hint: 'Masukkan alamat utama...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Alamat 2'),
                  TextField(
                    controller: txtLocaddress2,
                    decoration: softDecoration(hint: 'Masukkan alamat tambahan...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Provinsi'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Provinsi',
                      selectedValue: txtLocprovince.text.isEmpty ? null : txtLocprovince.text,
                      choiceItems: _clientProvinceOptions.map((v) => S2Choice<String>(value: v, title: v)).toList(),
                      onChange: (s) => setState(() => txtLocprovince.text = s.value ?? ''),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Provinsi...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Zone'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Zone',
                      selectedValue: _clientZone,
                      choiceItems: zoneChoices,
                      onChange: (s) => setState(() => _clientZone = s.value),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Zone...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Company'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Company',
                      selectedValue: txtLoccompany.text.isEmpty ? null : txtLoccompany.text,
                      choiceItems: companyChoices,
                      onChange: (s) => setState(() => txtLoccompany.text = s.value ?? ''),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Company...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Contact Person'),
                  TextField(
                    controller: txtLoccontactperson,
                    decoration: softDecoration(hint: 'Masukkan nama contact person...'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Phone 1'),
                            TextField(
                              controller: txtLocphone1,
                              keyboardType: TextInputType.phone,
                              decoration: softDecoration(hint: '08xxxx'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Phone 2'),
                            TextField(
                              controller: txtLocphone2,
                              keyboardType: TextInputType.phone,
                              decoration: softDecoration(hint: '08xxxx'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Fax 1'),
                            TextField(
                              controller: txtLocfax1,
                              decoration: softDecoration(hint: 'Nomor fax...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Fax 2'),
                            TextField(
                              controller: txtLocfax2,
                              decoration: softDecoration(hint: 'Nomor fax...'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: () {
                          resetClientForm();
                          setState(() => _subModes[4] = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(accentOrange),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: ntBtnLabel('Reset'),
                        onPressed: resetClientForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(primaryOrange),
                        icon: const Icon(Icons.save, size: 16, color: Colors.white),
                        label: ntBtnLabel(isEdit ? 'Update' : 'Simpan'),
                        onPressed: () async {
                          final msg = isEdit ? 'Update data Client?' : 'Simpan data Client?';
                          if (await _showConfirmDialog('Konfirmasi', msg)) {
                            _saveOrUpdateClient();
                          }
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

  Widget _buildClientTab() {
    final query = _searchClientCtrl.text.trim().toLowerCase();
    final filtered = _listClient.where((item) {
      if (query.isEmpty) return true;
      final id = (item['locid'] ?? item['LOCID'] ?? '').toString().toLowerCase();
      final name = (item['locname'] ?? item['LOCNAME'] ?? '').toString().toLowerCase();
      final contact = (item['loccontactperson'] ?? item['LOCCONTACTPERSON'] ?? '').toString().toLowerCase();
      final addr = (item['locaddress1'] ?? item['LOCADDRESS1'] ?? '').toString().toLowerCase();
      return id.contains(query) || name.contains(query) || contact.contains(query) || addr.contains(query);
    }).toList();

    return Column(
      children: [
        _buildSubTabBar(
          entityName: 'Client',
          tabIndex: 4,
          itemCount: filtered.length,
          onAdd: () {
            resetClientForm();
            setState(() => _subModes[4] = 1);
          },
        ),
        Expanded(
          child: _subModes[4] == 0
              ? _buildClientList(filtered)
              : _buildClientForm(),
        ),
      ],
    );
  }

  // =========================================================================
  // --- Zone Tab Logic & UI ---
  // =========================================================================
  static const String _zoneSaveApi = 'api/master/save_new_zone_api.jsp';

  Future<void> getListVhtypeOptions() async {
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=vhtalias-zone');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200 && response.body.trim() != 'Data not found') {
        try {
          final decoded = jsonDecode(response.body) as List;
          setState(() {
            _listVhtypeOptions = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          });
        } catch (_) {
          setState(() => _listVhtypeOptions = []);
        }
      } else {
        setState(() => _listVhtypeOptions = []);
      }
    } catch (_) {
      setState(() => _listVhtypeOptions = []);
    }
  }

  Future<void> getListDefaultZoneOptions() async {
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=default-zone');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200 && response.body.trim() != 'Data not found') {
        try {
          final decoded = jsonDecode(response.body) as List;
          setState(() {
            _listDefaultZoneOptions = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          });
        } catch (_) {
          setState(() => _listDefaultZoneOptions = []);
        }
      } else {
        setState(() => _listDefaultZoneOptions = []);
      }
    } catch (_) {
      setState(() => _listDefaultZoneOptions = []);
    }
  }

  Future<void> getListZoneMasterList() async {
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_refApi?method=zone-master-list');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = response.body.trim();
        List<dynamic> decoded = [];
        if (body.isNotEmpty && body != 'Data not found') {
          try {
            decoded = jsonDecode(body) is List ? jsonDecode(body) as List : [];
          } catch (_) {}
        }
        setState(() {
          _listZone = decoded.map((e) => (e is Map ? e : {}) as Map<String, dynamic>).toList();
          _selectedZoneIndex = null;
        });
      } else {
        setState(() => _listZone = []);
      }
    } catch (e) {
      if (mounted) alert(globalScaffoldKey.currentContext!, 0, "Gagal load data Zone: $e", "error");
      setState(() => _listZone = []);
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _saveOrUpdateZone() async {
    final zoneid = txtZoneid.text.trim();
    final zonename = txtZonename.text.trim();
    if (zonename.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Zone Name tidak boleh kosong", "error");
      return;
    }
    final method = zoneid.isEmpty ? 'add' : 'update';
    if (method == 'update' && zoneid.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Zone ID tidak boleh kosong untuk Update", "error");
      return;
    }
    if (method == 'add') {
      if (_zoneDefaultZone == null || _zoneDefaultZone!.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0, "Default Zone tidak boleh kosong", "error");
        return;
      }
      if (_zoneOrigin == null || _zoneOrigin!.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0, "Origin tidak boleh kosong", "error");
        return;
      }
      if (_zoneVhtype == null || _zoneVhtype!.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0, "Vehicle Type tidak boleh kosong", "error");
        return;
      }
    }
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_zoneSaveApi').replace(
        queryParameters: {
          'method': method,
          'zoneid': zoneid,
          'zonename': zonename,
          'default_zone': _zoneDefaultZone ?? '',
          'vhtype': _zoneVhtype ?? '',
          'origin': _zoneOrigin ?? '',
          'status': _zoneStatus,
          'userid': userid,
        },
      );
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetZoneForm();
        await getListZoneMasterList();
        setState(() => _subModes[5] = 0); // Switch to list view
      } else {
        alert(globalScaffoldKey.currentContext!, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(globalScaffoldKey.currentContext!, 0, "Error: $e", "error");
    }
  }

  void resetZoneForm() {
    txtZoneid.clear();
    txtZonename.clear();
    txtZonetype.clear();
    txtZonetarif.clear();
    setState(() {
      _zoneDefaultZone = null;
      _zoneVhtype = null;
      _zoneOrigin = null;
      _zoneStatus = 'Active';
      _selectedZoneIndex = null;
    });
  }

  void _onZoneRowTap(Map<String, dynamic> item, int index) {
    txtZoneid.text = item['zoneid'] ?? item['ZONEID'] ?? '';
    txtZonename.text = item['zonename'] ?? item['ZONENAME'] ?? '';
    final defaultZone = item['default_zone'] ?? item['DEFAULT_ZONE'] ?? '';
    setState(() {
      _zoneDefaultZone = defaultZone;
      _zoneVhtype = item['vhctype']?.toString() ?? item['VHCTYPE']?.toString();
      _zoneOrigin = item['origin']?.toString() ?? item['ORIGIN']?.toString();
      _zoneStatus = item['status'] ?? item['STATUS'] ?? 'Active';
      _selectedZoneIndex = index;
    });
  }

  Widget _buildZoneList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchZoneCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: softDecoration(
                    hint: 'Cari zone, ID, nama, origin...',
                    prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
                    suffixIcon: _searchZoneCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchZoneCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ntBtnStyle(primaryOrange),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: ntBtnLabel('Tambah'),
                onPressed: () {
                  resetZoneForm();
                  setState(() => _subModes[5] = 1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: RefreshIndicator(
            color: primaryOrange,
            onRefresh: () async {
              await getListZoneOptions();
              await getListOriginAlias();
              await getListVhtypeOptions();
              await getListZoneMasterList();
            },
            child: items.isEmpty
                ? _buildEmptyState('Tidak ada data Zone.\nTarik ke bawah untuk refresh.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 2),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final zoneid = item['zoneid'] ?? item['ZONEID'] ?? '';
                      final zonename = item['zonename'] ?? item['ZONENAME'] ?? '';
                      final defaultZone = item['default_zone'] ?? item['DEFAULT_ZONE'] ?? '';
                      final vhctype = item['vhctype'] ?? item['VHCTYPE'] ?? '';
                      final origin = item['origin'] ?? item['ORIGIN'] ?? '';

                      return _ntListCard(
                        title: 'Zone ID: $zoneid',
                        trailing: defaultZone.toString().isNotEmpty
                            ? _buildStatusBadge(defaultZone.toString())
                            : null,
                        rows: [
                          _kv('Nama Zone', zonename.toString(), valueWeight: FontWeight.w700),
                          _kv('Default Zone', defaultZone.toString()),
                          _kv('VHC Type', vhctype.toString()),
                          _kv('Origin', origin.toString()),
                        ],
                        actions: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ntBtnStyle(primaryOrange),
                              icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                              label: ntBtnLabel('Edit Data'),
                              onPressed: () {
                                _onZoneRowTap(item, index);
                                setState(() => _subModes[5] = 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneForm() {
    final isEdit = txtZoneid.text.trim().isNotEmpty || _selectedZoneIndex != null;
    final vhtypeChoices = _listVhtypeOptions
        .map((e) => S2Choice<String>(
            value: e['value']?.toString() ?? e['text']?.toString() ?? '',
            title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    final originChoices = _listOriginAlias
        .map((e) => S2Choice<String>(
            value: e['value']?.toString() ?? e['text']?.toString() ?? '',
            title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    final defaultZoneChoices = _listDefaultZoneOptions
        .map((e) => S2Choice<String>(
            value: (e['value'] ?? e['text'] ?? '').toString(),
            title: (e['text'] ?? e['value'] ?? '').toString()))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                  Icon(Icons.map_outlined, color: primaryOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'Edit Data Zone' : 'Tambah Zone Baru',
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
                  _label('Zone ID'),
                  TextField(
                    controller: txtZoneid,
                    decoration: softDecoration(
                      hint: 'Otomatis di-generate sistem atau diisi manual',
                      helperText: 'Generate otomatis jika dikosongkan',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Zone Name *'),
                  TextField(
                    controller: txtZonename,
                    decoration: softDecoration(hint: 'Masukkan nama zone...'),
                  ),
                  const SizedBox(height: 12),
                  _label('Default Zone *'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Default Zone',
                      selectedValue: _zoneDefaultZone,
                      choiceItems: defaultZoneChoices,
                      onChange: (s) => setState(() => _zoneDefaultZone = s.value),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Default Zone...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Origin *'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Origin',
                      selectedValue: _zoneOrigin,
                      choiceItems: originChoices,
                      onChange: (s) => setState(() => _zoneOrigin = s.value),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Origin...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _label('Vehicle Type *'),
                  _smartSelectContainer(
                    child: SmartSelect<String?>.single(
                      title: 'Pilih Vehicle Type',
                      selectedValue: _zoneVhtype,
                      choiceItems: vhtypeChoices,
                      onChange: (s) => setState(() => _zoneVhtype = s.value),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Vehicle Type...',
                      ),
                      tileBuilder: (context, state) => S2Tile.fromState(
                        state,
                        dense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: () {
                          resetZoneForm();
                          setState(() => _subModes[5] = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(accentOrange),
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: ntBtnLabel('Reset'),
                        onPressed: resetZoneForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ntBtnStyle(primaryOrange),
                        icon: const Icon(Icons.save, size: 16, color: Colors.white),
                        label: ntBtnLabel(isEdit ? 'Update' : 'Simpan'),
                        onPressed: () async {
                          final msg = isEdit ? 'Update data Zone?' : 'Simpan data Zone?';
                          if (await _showConfirmDialog('Konfirmasi', msg)) {
                            _saveOrUpdateZone();
                          }
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

  Widget _buildZoneTab() {
    final query = _searchZoneCtrl.text.trim().toLowerCase();
    final filtered = _listZone.where((item) {
      if (query.isEmpty) return true;
      final id = (item['zoneid'] ?? item['ZONEID'] ?? '').toString().toLowerCase();
      final name = (item['zonename'] ?? item['ZONENAME'] ?? '').toString().toLowerCase();
      final defZone = (item['default_zone'] ?? item['DEFAULT_ZONE'] ?? '').toString().toLowerCase();
      final origin = (item['origin'] ?? item['ORIGIN'] ?? '').toString().toLowerCase();
      final vhc = (item['vhctype'] ?? item['VHCTYPE'] ?? '').toString().toLowerCase();
      return id.contains(query) || name.contains(query) || defZone.contains(query) || origin.contains(query) || vhc.contains(query);
    }).toList();

    return Column(
      children: [
        _buildSubTabBar(
          entityName: 'Zone',
          tabIndex: 5,
          itemCount: filtered.length,
          onAdd: () {
            resetZoneForm();
            setState(() => _subModes[5] = 1);
          },
        ),
        Expanded(
          child: _subModes[5] == 0
              ? _buildZoneList(filtered)
              : _buildZoneForm(),
        ),
      ],
    );
  }

  // =========================================================================
  // --- Lifecycle & Build ---
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false && _hasAccess()) {
        if (_tabController.index == 0) getListCustomer();
        if (_tabController.index == 1) {
          getListOriginAlias();
          getListOrigin();
        }
        if (_tabController.index == 2) {
          getListDestination();
        }
        if (_tabController.index == 3) {
          getListItemType();
        }
        if (_tabController.index == 4) {
          getListZoneOptions();
          getListCompanyClient();
          getListClient();
        }
        if (_tabController.index == 5) {
          getListZoneOptions();
          getListOriginAlias();
          getListVhtypeOptions();
          getListDefaultZoneOptions();
          getListZoneMasterList();
        }
      }
    });
    _checkAccess();
  }

  @override
  void dispose() {
    _osmSearchDebounce?.cancel();
    _osmDestSearchDebounce?.cancel();
    _tabController.dispose();
    _searchCustomerCtrl.dispose();
    _searchOriginCtrl.dispose();
    _searchDestCtrl.dispose();
    _searchItemTypeCtrl.dispose();
    _searchClientCtrl.dispose();
    _searchZoneCtrl.dispose();
    txtCpyId.dispose();
    txtCpyname.dispose();
    txtCpyaddress.dispose();
    txtCpynpwp.dispose();
    txtCpycontactperson.dispose();
    txtCtyId.dispose();
    txtCtyname.dispose();
    txtOsmAddress.dispose();
    txtLat.dispose();
    txtLon.dispose();
    txtDestCtyId.dispose();
    txtDestCtyname.dispose();
    txtDestOsmAddress.dispose();
    txtDestLat.dispose();
    txtDestLon.dispose();
    txtDestType.dispose();
    txtItpid.dispose();
    txtItpdescr.dispose();
    txtItpalias.dispose();
    txtLocid.dispose();
    txtLocationtype.dispose();
    txtLocname.dispose();
    txtLocaddress1.dispose();
    txtLocaddress2.dispose();
    txtLocprovince.dispose();
    txtLoccompany.dispose();
    txtLoccontactperson.dispose();
    txtLocphone1.dispose();
    txtLocphone2.dispose();
    txtLocfax1.dispose();
    txtLocfax2.dispose();
    txtZoneid.dispose();
    txtZonename.dispose();
    txtZonetype.dispose();
    txtZonetarif.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? '';
    userid = prefs.getString("userid") ?? prefs.getString("username") ?? '';
    if (!mounted) return;
    if (!_hasAccess()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && globalScaffoldKey.currentContext != null) {
          alert(
            globalScaffoldKey.currentContext!,
            0,
            "Akses ditolak. Hanya HTRD dan ADMIN yang dapat mengakses halaman ini.",
            "error",
          );
          _goBack(context);
        }
      });
    } else {
      getListCustomer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If in Form mode, pressing back goes back to List mode
        final currentTab = _tabController.index;
        if (_subModes[currentTab] == 1) {
          setState(() => _subModes[currentTab] = 0);
          return;
        }
        _goBack(context);
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
            iconSize: 20.0,
            onPressed: () {
              final currentTab = _tabController.index;
              if (_subModes[currentTab] == 1) {
                setState(() => _subModes[currentTab] = 0);
                return;
              }
              _goBack(context);
            },
          ),
          centerTitle: true,
          title: const Text(
            'Master Data Lainnya',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          bottom: _hasAccess()
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Customer'),
                    Tab(text: 'Origin'),
                    Tab(text: 'Destination'),
                    Tab(text: 'Item Type'),
                    Tab(text: 'Client'),
                    Tab(text: 'Zone'),
                  ],
                )
              : null,
        ),
        body: _hasAccess()
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildCustomerTab(),
                  _buildOriginTab(),
                  _buildDestinationTab(),
                  _buildItemTypeTab(),
                  _buildClientTab(),
                  _buildZoneTab(),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
