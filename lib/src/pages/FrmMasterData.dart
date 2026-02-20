import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
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

  // Customer tab
  final TextEditingController txtCpyId = TextEditingController();
  final TextEditingController txtCpyname = TextEditingController();
  final TextEditingController txtCpyaddress = TextEditingController();
  final TextEditingController txtCpynpwp = TextEditingController();
  final TextEditingController txtCpycontactperson = TextEditingController();
  String _customerStatus = 'Active';
  List<Map<String, dynamic>> _listCustomer = [];

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
  static const String _destinationType = 'SPECIFIC';

  // Item Type tab
  final TextEditingController txtItpid = TextEditingController();
  final TextEditingController txtItpdescr = TextEditingController();
  final TextEditingController txtItpalias = TextEditingController();
  List<Map<String, dynamic>> _listItemType = [];

  // Client tab
  final TextEditingController txtLocid = TextEditingController();
  final TextEditingController txtLocationtype = TextEditingController();
  final TextEditingController txtLocname = TextEditingController();
  final TextEditingController txtLocaddress1 = TextEditingController();
  final TextEditingController txtLocaddress2 = TextEditingController();
  final TextEditingController txtLocprovince = TextEditingController();
  static const List<Map<String, String>> _clientLocationTypeOptions = [
    {'value': 'BENGKEL', 'title': 'BENGKEL - BENGKEL'},
    {'value': 'CUSTOMER', 'title': 'CUSTOMER - CUSTOMER'},
    {'value': 'INTERNAL', 'title': 'INTERNAL - INTERNAL'},
    {'value': 'VENDOR', 'title': 'VENDOR - VENDOR'},
  ];
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
  int? _selectedZoneIndex;

  int? _selectedCustomerIndex;
  int? _selectedOriginIndex;
  int? _selectedDestinationIndex;
  int? _selectedItemTypeIndex;

  bool getAkses(akses) {
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == akses);
    return isOK != null && isOK.length > 0;
  }

  bool _hasAccess() {
    return username == "ADMIN" || getAkses("HTRD");
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final ctx = globalScaffoldKey.currentContext;
    if (ctx == null) return false;
    final result = await showDialog<bool>(
      context: ctx,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    return result == true;
  }

  // --- Customer Tab ---
  static const String _customerListApi = 'api/master/refference_api.jsp';
  static const String _customerSaveApi =
      'api/master/save_new_customer_api2.jsp';

  Future<void> getListCustomer() async {
    try {
      EasyLoading.show();
      final baseURL = '${GlobalData.baseUrlOri}$_customerListApi?method=customer';
      print(baseURL);
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
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data customer: $e", "error");
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
      alert(globalScaffoldKey.currentContext!, 0,
          "Contact Person tidak boleh kosong", "error");
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
      print(url);
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetCustomerForm();
        getListCustomer();
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
    setState(() => _customerStatus = 'Active');
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

  // --- Origin Tab ---
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

  Future<void> _searchOsmAddress(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() { _osmAddressSuggestions = []; _osmSearching = false; });
      return;
    }
    setState(() => _osmSearching = true);
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}api/osm_address.jsp?query=${Uri.encodeComponent(q)}');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _osmAddressSuggestions = decoded is List ? List.from(decoded) : [];
          _osmSearching = false;
        });
      } else {
        setState(() { _osmAddressSuggestions = []; _osmSearching = false; });
      }
    } catch (_) {
      setState(() { _osmAddressSuggestions = []; _osmSearching = false; });
    }
  }

  void _onOsmAddressSelected(Map<String, dynamic> item) {
    final lat = item['lat']?.toString() ?? '';
    final lon = item['lon']?.toString() ?? '';
    final name = item['display_name'] ?? item['name'] ?? txtOsmAddress.text;
    txtOsmAddress.text = name is String ? name : txtOsmAddress.text;
    txtLat.text = lat;
    txtLon.text = lon;
    setState(() => _osmAddressSuggestions = []);
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
      print(url);
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (EasyLoading.isShow) EasyLoading.dismiss();
      final map = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final statusCode = map['status_code']?.toString() ?? '';
      final message = map['message']?.toString() ?? 'Unknown';
      if (statusCode == '200') {
        alert(globalScaffoldKey.currentContext!, 1, message, "success");
        resetOriginForm();
        getListOrigin();
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

  // --- Destination Tab ---
  static const String _destinationSaveApi = 'api/master/save_new_destination.jsp';

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
    try {
      final url = Uri.parse('${GlobalData.baseUrlOri}api/osm_address.jsp?query=${Uri.encodeComponent(q)}');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _osmDestSuggestions = decoded is List ? List.from(decoded) : [];
          _osmDestSearching = false;
        });
      } else {
        setState(() { _osmDestSuggestions = []; _osmDestSearching = false; });
      }
    } catch (_) {
      setState(() { _osmDestSuggestions = []; _osmDestSearching = false; });
    }
  }

  void _onOsmDestSelected(Map<String, dynamic> item) {
    final lat = item['lat']?.toString() ?? '';
    final lon = item['lon']?.toString() ?? '';
    final name = item['display_name'] ?? item['name'] ?? txtDestOsmAddress.text;
    txtDestOsmAddress.text = name is String ? name : txtDestOsmAddress.text;
    txtDestLat.text = lat;
    txtDestLon.text = lon;
    setState(() => _osmDestSuggestions = []);
  }
//
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
        getListDestination();
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
    setState(() {});
  }

  void _onDestinationRowTap(Map<String, dynamic> item, int index) {
    txtDestCtyId.text = item['ctyid'] ?? item['CTYID'] ?? '';
    txtDestCtyname.text = item['ctyname'] ?? item['CTYNAME'] ?? '';
    txtDestLat.text = item['lat']?.toString() ?? item['LOCID5'] ?? '';
    txtDestLon.text = item['lon']?.toString() ?? item['LOCID6'] ?? '';
    txtDestOsmAddress.text = '';
    setState(() => _selectedDestinationIndex = index);
  }

  // --- Item Type Tab ---
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
    final method = 'add';
    try {
      EasyLoading.show();
      final url = Uri.parse('${GlobalData.baseUrlOri}$_itemTypeSaveApi').replace(
        queryParameters: {
          'method': method,
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
        getListItemType();
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
        getListItemType();
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
    setState(() {});
  }

  void _onItemTypeRowTap(Map<String, dynamic> item, int index) {
    txtItpid.text = item['itpid'] ?? item['ITPID'] ?? '';
    txtItpdescr.text = item['itpdescr'] ?? item['ITPDESCR'] ?? '';
    txtItpalias.text = item['itpalias'] ?? item['ITPALIAS'] ?? '';
    setState(() => _selectedItemTypeIndex = index);
  }

  // --- Client Tab ---
  static const String _clientSaveApi = 'api/master/save_new_client_api.jsp';

  // --- Zone Tab ---
  static const String _zoneSaveApi = 'api/master/save_new_zone_api.jsp';

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
          'zonetype': txtZonetype.text,
          'vhtype': _zoneVhtype ?? '',
          'origin': _zoneOrigin ?? '',
          'zonetarif': txtZonetarif.text,
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
        getListZoneMasterList();
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
    });
  }

  void _onZoneRowTap(Map<String, dynamic> item, int index) {
    txtZoneid.text = item['zoneid'] ?? item['ZONEID'] ?? '';
    txtZonename.text = item['zonename'] ?? item['ZONENAME'] ?? '';
    txtZonetype.text = item['zonetype'] ?? item['ZONETYPE'] ?? '';
    txtZonetarif.text = item['zonetarif']?.toString() ?? item['ZONETARIF']?.toString() ?? '';
    final defaultZone = item['default_zone'] ?? item['DEFAULT_ZONE'] ?? '';
    setState(() {
      _zoneDefaultZone = defaultZone == '1171' ? 'CEMINDO' : (defaultZone == '1240' ? 'HOLCIM' : defaultZone);
      _zoneVhtype = item['vhctype']?.toString() ?? item['VHCTYPE']?.toString();
      _zoneOrigin = item['origin']?.toString() ?? item['ORIGIN']?.toString();
      _zoneStatus = item['status'] ?? item['STATUS'] ?? 'Active';
      _selectedZoneIndex = index;
    });
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
        getListClient();
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
    setState(() => _clientStatus = 'Active');
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

  Widget _buildCustomerTab() {
    return RefreshIndicator(
      onRefresh: getListCustomer,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Form Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: txtCpyId,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Cust ID',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('* generate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtCpyname,
                      decoration: InputDecoration(
                        labelText: 'Cust Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtCpyaddress,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Cust Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtCpynpwp,
                      decoration: InputDecoration(
                        labelText: 'Cust. NPWP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtCpycontactperson,
                      decoration: InputDecoration(
                        labelText: 'Singkatan Customer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _customerStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Active'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _customerStatus = v ?? 'Active'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: resetCustomerForm,
                          child: Text('Reset'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (txtCpyId.text.isEmpty && await _showConfirmDialog('Konfirmasi', 'Simpan data Customer?')) {
                              _saveOrUpdateCustomer();
                            }
                          },
                          child: Text('Save'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () async {
                            if (txtCpyId.text.isNotEmpty && await _showConfirmDialog('Konfirmasi', 'Update data Customer?')) {
                              _saveOrUpdateCustomer();
                            }
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Daftar Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _listCustomer.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Data kosong. Tarik untuk refresh.'),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: [
                          DataColumn(label: Text('CustID', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Cust Name', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Contact Person', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        rows: _listCustomer.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          final cpyid = item['cpyid'] ?? item['CPYID'] ?? '';
                          final cpyname = item['cpyname'] ?? item['CPYNAME'] ?? '';
                          final addr = item['cpyaddress'] ?? item['cpyaddress1'] ?? item['CPYADDRESS1'] ?? '';
                          final contact = item['cpycontactperson'] ?? item['cpyaccountnbr'] ?? item['cpycontcatperson'] ?? item['CPYACCOUNTNBR'] ?? '';
                          final st = item['status'] ?? item['cpystatus'] ?? item['CPYSTATUS'] ?? '';
                          return DataRow(
                            color: MaterialStateProperty.resolveWith((_) => _selectedCustomerIndex == index ? Colors.orange.withOpacity(0.25) : null),
                            cells: [
                              DataCell(GestureDetector(
                                onTap: () => _onCustomerRowTap(item, index),
                                child: Text(cpyid),
                              )),
                              DataCell(GestureDetector(
                                onTap: () => _onCustomerRowTap(item, index),
                                child: Text(cpyname),
                              )),
                              DataCell(GestureDetector(
                                onTap: () => _onCustomerRowTap(item, index),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 180),
                                  child: Text(addr, overflow: TextOverflow.ellipsis),
                                ),
                              )),
                              DataCell(GestureDetector(
                                onTap: () => _onCustomerRowTap(item, index),
                                child: Text(contact),
                              )),
                              DataCell(GestureDetector(
                                onTap: () => _onCustomerRowTap(item, index),
                                child: Text(st),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginTab() {
    final aliasChoices = _listOriginAlias
        .map((e) => S2Choice<String>(value: e['value'] ?? e['text'] ?? '', title: e['text'] ?? e['value'] ?? ''))
        .toList();
    final originTypeChoices = _originTypeOptions
        .map((e) => S2Choice<String>(value: e['value']!, title: e['label']!))
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        await getListOriginAlias();
        await getListOrigin();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Form Origin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    // TextField(
                    //   readOnly: true,
                    //   controller: txtCtyId,
                    //   decoration: InputDecoration(
                    //     labelText: 'ID Origin *',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: txtCtyId,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'ID Origin',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('* generate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtCtyname,
                      decoration: InputDecoration(
                        labelText: 'Nama Origin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Cty Alias',
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
                    ),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Origin Type',
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
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtOsmAddress,
                      decoration: InputDecoration(
                        labelText: 'OSM Address',
                        hintText: 'Ketik address, pilih untuk isi Lat/Lon',
                        border: OutlineInputBorder(),
                        suffixIcon: _osmSearching ? Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                      ),
                      onChanged: (v) {
                        if (v.length >= 2) _searchOsmAddress(v);
                        else setState(() => _osmAddressSuggestions = []);
                      },
                    ),
                    if (_osmAddressSuggestions.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        constraints: BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _osmAddressSuggestions.length,
                          itemBuilder: (context, i) {
                            final item = _osmAddressSuggestions[i] is Map ? _osmAddressSuggestions[i] as Map<String, dynamic> : <String, dynamic>{};
                            final name = item['display_name'] ?? item['name'] ?? '';
                            return ListTile(
                              dense: true,
                              title: Text(name is String ? name : '$name', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                              onTap: () => _onOsmAddressSelected(item),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtLat,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtLon,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: resetOriginForm, child: Text('Reset')),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (txtCtyId.text.isEmpty && await _showConfirmDialog('Konfirmasi', 'Simpan data Origin?')) {
                              _saveOrUpdateOrigin();
                            }
                          },
                          child: Text('Save'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () async {
                            if (txtCtyId.text.isNotEmpty && await _showConfirmDialog('Konfirmasi', 'Update data Origin?')) {
                              _saveOrUpdateOrigin();
                            }
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Daftar Origin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _listOrigin.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Data kosong. Tarik untuk refresh.')))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: [
                          DataColumn(label: Text('ID Origin', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Nama Origin', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Cty Alias', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Lat', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Lon', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        rows: _listOrigin.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          final ctyid = item['ctyid'] ?? item['CTYID'] ?? '';
                          final ctyname = item['ctyname'] ?? item['CTYNAME'] ?? '';
                          final ctyalias = item['ctyalias'] ?? item['CTYALIAS'] ?? '';
                          final lat = item['lat']?.toString() ?? item['LOCID5'] ?? '';
                          final lon = item['lon']?.toString() ?? item['LOCID6'] ?? '';
                          return DataRow(
                            color: MaterialStateProperty.resolveWith((_) => _selectedOriginIndex == index ? Colors.orange.withOpacity(0.25) : null),
                            cells: [
                              DataCell(GestureDetector(onTap: () => _onOriginRowTap(item, index), child: Text(ctyid))),
                              DataCell(GestureDetector(onTap: () => _onOriginRowTap(item, index), child: Text(ctyname))),
                              DataCell(GestureDetector(onTap: () => _onOriginRowTap(item, index), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: Text(ctyalias, overflow: TextOverflow.ellipsis)))),
                              DataCell(GestureDetector(onTap: () => _onOriginRowTap(item, index), child: Text(lat))),
                              DataCell(GestureDetector(onTap: () => _onOriginRowTap(item, index), child: Text(lon))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationTab() {
    return RefreshIndicator(
      onRefresh: getListDestination,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Form Destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    TextField(
                      controller: txtDestCtyId,
                      decoration: InputDecoration(
                        labelText: 'ID Destination',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtDestCtyname,
                      decoration: InputDecoration(
                        labelText: 'Nama Proyek/Tujuan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      readOnly: true,
                      controller: txtDestType,
                      decoration: InputDecoration(
                        labelText: 'Destination Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtDestOsmAddress,
                      decoration: InputDecoration(
                        labelText: 'OSM Address',
                        hintText: 'Ketik address, pilih untuk isi Lat/Lon',
                        border: OutlineInputBorder(),
                        suffixIcon: _osmDestSearching ? Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                      ),
                      onChanged: (v) {
                        if (v.length >= 2) _searchOsmAddressDest(v);
                        else setState(() => _osmDestSuggestions = []);
                      },
                    ),
                    if (_osmDestSuggestions.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        constraints: BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _osmDestSuggestions.length,
                          itemBuilder: (context, i) {
                            final item = _osmDestSuggestions[i] is Map ? _osmDestSuggestions[i] as Map<String, dynamic> : <String, dynamic>{};
                            final name = item['display_name'] ?? item['name'] ?? '';
                            return ListTile(
                              dense: true,
                              title: Text(name is String ? name : '$name', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                              onTap: () => _onOsmDestSelected(item),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtDestLat,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Lat', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtDestLon,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Lon', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: resetDestinationForm, child: Text('Reset')),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (txtDestCtyId.text.isEmpty && await _showConfirmDialog('Konfirmasi', 'Simpan data Destination?')) {
                              _saveOrUpdateDestination();
                            }
                          },
                          child: Text('Save'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () async {
                            if (txtDestCtyId.text.isNotEmpty && await _showConfirmDialog('Konfirmasi', 'Update data Destination?')) {
                              _saveOrUpdateDestination();
                            }
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Daftar Destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _listDestination.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Data kosong. Tarik untuk refresh.')))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: [
                          DataColumn(label: Text('ID Destination', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Nama Proyek/Tujuan', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Lat', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Lon', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        rows: _listDestination.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          final ctyid = item['ctyid'] ?? item['CTYID'] ?? '';
                          final ctyname = item['ctyname'] ?? item['CTYNAME'] ?? '';
                          final ctytype = item['ctytype'] ?? item['CTYTYPE'] ?? '';
                          final lat = item['lat']?.toString() ?? item['LOCID5'] ?? '';
                          final lon = item['lon']?.toString() ?? item['LOCID6'] ?? '';
                          return DataRow(
                            color: MaterialStateProperty.resolveWith((_) => _selectedDestinationIndex == index ? Colors.orange.withOpacity(0.25) : null),
                            cells: [
                              DataCell(GestureDetector(onTap: () => _onDestinationRowTap(item, index), child: Text(ctyid))),
                              DataCell(GestureDetector(onTap: () => _onDestinationRowTap(item, index), child: Text(ctyname))),
                              DataCell(GestureDetector(onTap: () => _onDestinationRowTap(item, index), child: Text(ctytype))),
                              DataCell(GestureDetector(onTap: () => _onDestinationRowTap(item, index), child: Text(lat))),
                              DataCell(GestureDetector(onTap: () => _onDestinationRowTap(item, index), child: Text(lon))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTypeTab() {
    return RefreshIndicator(
      onRefresh: getListItemType,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Form Item Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    TextField(
                      controller: txtItpid,
                      decoration: InputDecoration(
                        labelText: 'Item ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtItpdescr,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtItpalias,
                      decoration: InputDecoration(
                        labelText: 'Alias',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: resetItemTypeForm, child: Text('Reset')),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (await _showConfirmDialog('Konfirmasi', 'Simpan data Item Type?')) {
                              _saveOrUpdateItemType();
                            }
                          },
                          child: Text('Save'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () async {
                            if (await _showConfirmDialog('Konfirmasi', 'Update data Item Type?')) {
                              _updateItemType();
                            }
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Daftar Item Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _listItemType.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Data kosong. Tarik untuk refresh.')))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: [
                          DataColumn(label: Text('Item ID', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Alias', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        rows: _listItemType.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          final itpid = item['itpid'] ?? item['ITPID'] ?? '';
                          final itpdescr = item['itpdescr'] ?? item['ITPDESCR'] ?? '';
                          final itpalias = item['itpalias'] ?? item['ITPALIAS'] ?? '';
                          return DataRow(
                            color: MaterialStateProperty.resolveWith((_) => _selectedItemTypeIndex == index ? Colors.orange.withOpacity(0.25) : null),
                            cells: [
                              DataCell(GestureDetector(onTap: () => _onItemTypeRowTap(item, index), child: Text(itpid))),
                              DataCell(GestureDetector(onTap: () => _onItemTypeRowTap(item, index), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 180), child: Text(itpdescr, overflow: TextOverflow.ellipsis)))),
                              DataCell(GestureDetector(onTap: () => _onItemTypeRowTap(item, index), child: Text(itpalias))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTab() {
    final zoneChoices = _listZoneOptions
        .map((e) => S2Choice<String>(value: e['value']?.toString() ?? e['text']?.toString() ?? '', title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        await getListZoneOptions();
        await getListClient();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Form Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    TextField(controller: txtLocid, decoration: InputDecoration(labelText: 'CID', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Type',
                      selectedValue: txtLocationtype.text.isEmpty ? null : txtLocationtype.text,
                      choiceItems: _clientLocationTypeOptions.map((e) => S2Choice<String>(value: e['value']!, title: e['title']!)).toList(),
                      onChange: (s) => setState(() => txtLocationtype.text = s.value ?? ''),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Type...',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(controller: txtLocname, decoration: InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLocaddress1, decoration: InputDecoration(labelText: 'Address 1', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLocaddress2, decoration: InputDecoration(labelText: 'Address 2', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Provinsi', //SEL
                      selectedValue: txtLocprovince.text.isEmpty ? null : txtLocprovince.text,
                      choiceItems: _clientProvinceOptions.map((v) => S2Choice<String>(value: v, title: v)).toList(),
                      onChange: (s) => setState(() => txtLocprovince.text = s.value ?? ''),
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Provinsi...',//LIST
                      ),
                    ),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Zone',
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
                    ),
                    SizedBox(height: 8),
                    TextField(controller: txtLoccompany, readOnly: true, decoration: InputDecoration(labelText: 'Company', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLoccontactperson, decoration: InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLocphone1, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone 1', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLocphone2, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone 2', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLocfax1, decoration: InputDecoration(labelText: 'Fax 1', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    TextField(controller: txtLocfax2, decoration: InputDecoration(labelText: 'Fax 2', border: OutlineInputBorder())),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _clientStatus,
                      decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Active', 'Not Active'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _clientStatus = v ?? 'Active'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: resetClientForm, child: Text('Reset')),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (await _showConfirmDialog('Konfirmasi', 'Simpan data Client?')) _saveOrUpdateClient();
                          },
                          child: Text('Save'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () async {
                            if (await _showConfirmDialog('Konfirmasi', 'Update data Client?')) _saveOrUpdateClient();
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Daftar Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _listClient.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Data kosong. Tarik untuk refresh.')))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: [
                          DataColumn(label: Text('CID', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Nama', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Address 1', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Contact Person', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Phone 1', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        rows: _listClient.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          final locid = item['locid'] ?? item['LOCID'] ?? '';
                          final locname = item['locname'] ?? item['LOCNAME'] ?? '';
                          final addr = item['locaddress1'] ?? item['LOCADDRESS1'] ?? '';
                          final contact = item['loccontactperson'] ?? item['LOCCONTACTPERSON'] ?? '';
                          final phone = item['locphone1'] ?? item['LOCPHONE1'] ?? '';
                          final st = item['status'] ?? item['STATUS'] ?? '';
                          return DataRow(
                            color: MaterialStateProperty.resolveWith((_) => _selectedClientIndex == index ? Colors.orange.withOpacity(0.25) : null),
                            cells: [
                              DataCell(GestureDetector(onTap: () => _onClientRowTap(item, index), child: Text(locid))),
                              DataCell(GestureDetector(onTap: () => _onClientRowTap(item, index), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 120), child: Text(locname, overflow: TextOverflow.ellipsis)))),
                              DataCell(GestureDetector(onTap: () => _onClientRowTap(item, index), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150), child: Text(addr, overflow: TextOverflow.ellipsis)))),
                              DataCell(GestureDetector(onTap: () => _onClientRowTap(item, index), child: Text(contact))),
                              DataCell(GestureDetector(onTap: () => _onClientRowTap(item, index), child: Text(phone))),
                              DataCell(GestureDetector(onTap: () => _onClientRowTap(item, index), child: Text(st))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneTab() {
    final zoneIdChoices = _listZoneOptions
        .map((e) => S2Choice<String>(value: e['value']?.toString() ?? e['text']?.toString() ?? '', title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    final vhtypeChoices = _listVhtypeOptions
        .map((e) => S2Choice<String>(value: e['value']?.toString() ?? e['text']?.toString() ?? '', title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    final originChoices = _listOriginAlias
        .map((e) => S2Choice<String>(value: e['value']?.toString() ?? e['text']?.toString() ?? '', title: e['text']?.toString() ?? e['value']?.toString() ?? ''))
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        await getListZoneOptions();
        await getListOriginAlias();
        await getListVhtypeOptions();
        await getListZoneMasterList();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Form Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    SmartSelect<String?>.single(
                      title: 'Zone ID',
                      selectedValue: txtZoneid.text.isEmpty ? null : txtZoneid.text,
                      choiceItems: zoneIdChoices,
                      onChange: (s) {
                        txtZoneid.text = s.value ?? '';
                        final idx = _listZone.indexWhere((z) => (z['zoneid'] ?? z['ZONEID'] ?? '').toString() == (s.value ?? ''));
                        if (idx >= 0) _onZoneRowTap(_listZone[idx], idx);
                        setState(() {});
                      },
                      modalHeader: true,
                      modalConfig: S2ModalConfig(
                        type: S2ModalType.bottomSheet,
                        useFilter: true,
                        filterAuto: true,
                        filterHint: 'Cari Zone ID...',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtZonename,
                      decoration: InputDecoration(labelText: 'Zone Name', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      value: _zoneDefaultZone,
                      decoration: InputDecoration(labelText: 'Default Zone', border: OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Pilih Default Zone')),
                        DropdownMenuItem(value: 'CEMINDO', child: Text('CEMINDO')),
                        DropdownMenuItem(value: 'HOLCIM', child: Text('HOLCIM')),
                      ],
                      onChanged: (v) => setState(() => _zoneDefaultZone = v),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtZonetype,
                      decoration: InputDecoration(labelText: 'Zone Type (optional)', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Vehicle Type',
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
                    ),
                    SizedBox(height: 8),
                    SmartSelect<String?>.single(
                      title: 'Origin',
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
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: txtZonetarif,
                      decoration: InputDecoration(labelText: 'Zone Tarif (optional)', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _zoneStatus,
                      decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Active', 'Not Active'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _zoneStatus = v ?? 'Active'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: resetZoneForm, child: Text('Reset')),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            if (await _showConfirmDialog('Konfirmasi', 'Simpan data Zone?')) _saveOrUpdateZone();
                          },
                          child: Text('Save'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () async {
                            if (await _showConfirmDialog('Konfirmasi', 'Update data Zone?')) _saveOrUpdateZone();
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Daftar Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _listZone.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Data kosong. Tarik untuk refresh.')))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        columns: [
                          DataColumn(label: Text('Zone ID', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Zone Name', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Default Zone', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Zone Type', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('VHC Type', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Origin', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Zone Tarif', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        rows: _listZone.asMap().entries.map((e) {
                          final index = e.key;
                          final item = e.value;
                          final zoneid = item['zoneid'] ?? item['ZONEID'] ?? '';
                          final zonename = item['zonename'] ?? item['ZONENAME'] ?? '';
                          final defaultZone = item['default_zone'] ?? item['DEFAULT_ZONE'] ?? '';
                          final zonetype = item['zonetype'] ?? item['ZONETYPE'] ?? '';
                          final vhctype = item['vhctype'] ?? item['VHCTYPE'] ?? '';
                          final origin = item['origin'] ?? item['ORIGIN'] ?? '';
                          final zonetarif = item['zonetarif']?.toString() ?? item['ZONETARIF']?.toString() ?? '';
                          final status = item['status'] ?? item['STATUS'] ?? '';
                          return DataRow(
                            color: MaterialStateProperty.resolveWith((_) => _selectedZoneIndex == index ? Colors.orange.withOpacity(0.25) : null),
                            cells: [
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(zoneid))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 140), child: Text(zonename, overflow: TextOverflow.ellipsis)))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(defaultZone))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(zonetype))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(vhctype))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(origin))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(zonetarif))),
                              DataCell(GestureDetector(onTap: () => _onZoneRowTap(item, index), child: Text(status))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String title, IconData icon) {
    return Container(
      constraints: BoxConstraints.expand(),
      color: Theme.of(context).colorScheme.onPrimary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.orange.shade300),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

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
          getListClient();
        }
        if (_tabController.index == 5) {
          getListZoneOptions();
          getListOriginAlias();
          getListVhtypeOptions();
          getListZoneMasterList();
        }
      }
    });
    _checkAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          alert(globalScaffoldKey.currentContext!, 0,
              "Akses ditolak. Hanya HTRD dan ADMIN yang dapat mengakses halaman ini.",
              "error");
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
        if (!didPop) {
          _goBack(context);
        }
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          backgroundColor: Colors.orange.shade700,
          elevation: 2,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 20.0,
            onPressed: () => _goBack(context),
          ),
          centerTitle: true,
          title: Text('Master Data',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          bottom: _hasAccess()
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
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
            : SizedBox.shrink(),
      ),
    );
  }
}
