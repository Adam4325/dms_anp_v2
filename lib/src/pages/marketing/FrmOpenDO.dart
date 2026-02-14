import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FrmOpenDO extends StatefulWidget {
  final Map<String, dynamic> item; // nullable

  const FrmOpenDO({Key? key, required this.item}) : super(key: key);

  @override
  State<FrmOpenDO> createState() => _FrmOpenDOState();
}

class _FrmOpenDOState extends State<FrmOpenDO>
    with SingleTickerProviderStateMixin {
  // 🎨 Warna
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color backgroundColor = const Color(0xFFFFFAF5);

  late TabController tabController;
  final formKey = GlobalKey<FormState>();

  // 🔹 Controllers
  String zoneId = "";
  String originId = "";
  String destination = "-";
  String statusValue = "OPEN";
  String truckTypeId = "";
  String customerId = "";
  String itemTypeId = "";
  String itemUomId = "";
  String doStatus = "NORMAL";
  String locationId = "";

  final TextEditingController doNumber = TextEditingController();
  final TextEditingController doDate = TextEditingController();
  final TextEditingController subCustomer = TextEditingController();
  final TextEditingController salesOrder = TextEditingController();
  final TextEditingController custDONumber = TextEditingController();
  final TextEditingController custOrderDate = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController deliveryDate = TextEditingController();
  final TextEditingController notes = TextEditingController();

  // 🔸 Dropdown values

  // 🔸 Dropdown list
  final List<String> statusList = ["OPEN", "CLOSE"];
  List<Map<String, String>> truckTypeList = [];
  List<Map<String, String>> companyList = [];
  List<Map<String, String>> itemTypeList = [];
  List<Map<String, String>> itemUomList = [];
  List<Map<String, String>> itemLokasiList = [];
  List<Map<String, String>> itemZoneList = [];
  List<Map<String, String>> originList = [];
  final List<String> destinationList = ["-"];
  final List<String> doStatusList = ["NORMAL", "PENTING", "MALAM", "TUBER"];

  bool isLoading = true;
  bool isLoadingCompany = true;
  void setDataWidget() {
    print(widget.item);
    if (widget.item != null) {
      setState(() {
        doNumber.text = widget.item['dlododetailnumber'] ?? '';

        doDate.text = _formatDate(widget.item['dlodate']);
        customerId = widget.item['dlocustomer'] ?? '';
        subCustomer.text = widget.item['dlolocid2'] ?? '';
        salesOrder.text = widget.item['dlooriginaldonbr'] ?? '';
        custDONumber.text = widget.item['dlocustdonbr'] ?? '';
        custOrderDate.text = _formatDate(widget.item['dlocustdodate']);
        qty.text = widget.item['dloitemqty']?.toString() ?? '';
        originId = widget.item['dloorigin'] ?? '';
        print('doNumber.text 2 ${doNumber.text}');
        // Validasi destination - tidak boleh empty string
        String destTemp = widget.item['dlodestination'];
        if (destTemp != null &&
            destTemp.isNotEmpty &&
            destinationList.contains(destTemp)) {
          destination = destTemp;
        } else {
          destination = '-';
        }

        zoneId = widget.item['zone'] ?? '';
        deliveryDate.text = _formatDate(widget.item['dlodeliverydate']);
        notes.text = widget.item['dlonotes'] ?? '';
        locationId = widget.item['locid'] ?? '';
        print('dlolocid2 ${locationId}');
        // Validasi status value - tidak boleh empty string
        String statusTemp = widget.item['dlostatus'];
        if (statusTemp != null &&
            statusTemp.isNotEmpty &&
            statusList.contains(statusTemp)) {
          statusValue = statusTemp;
        } else {
          statusValue = 'OPEN';
        }

        truckTypeId = widget.item['vhcid'] ?? "";
        itemTypeId = widget.item['dloitemtype'] ?? "";
        itemUomId = widget.item['dloitemuom'] ?? "";

        // Validasi doStatus - tidak boleh empty string
        String doStatusTemp = widget.item['status'];
        if (doStatusTemp != null &&
            doStatusTemp.isNotEmpty &&
            doStatusList.contains(doStatusTemp)) {
          doStatus = doStatusTemp;
        } else {
          doStatus = 'NORMAL';
        }

        print(widget.item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
    tabController = TabController(length: 2, vsync: this);
    setDataWidget();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    try {
      await Future.wait([
        _loadOrigin(),
        _loadTruckTypes(),
        _loadItemTypes(),
        _loadCompanay(),
        _loadUomTypes(),
        _loadILocation(),
        _loadZone(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() {
      isLoading = false;
      isLoadingCompany = false;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // 🔹 Helper function untuk format date yyyy-MM-dd
  String _formatDate(String dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    try {
      // Coba parse berbagai format date yang mungkin dari database
      DateTime date;

      // Format yyyy-MM-dd (sudah benar)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        return dateStr;
      }

      // Format dd/MM/yyyy
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateStr)) {
        date = DateFormat('dd/MM/yyyy').parse(dateStr);
        return DateFormat('yyyy-MM-dd').format(date);
      }

      // Format MM/dd/yyyy
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateStr)) {
        date = DateFormat('MM/dd/yyyy').parse(dateStr);
        return DateFormat('yyyy-MM-dd').format(date);
      }

      // Format yyyy-MM-dd HH:mm:ss (timestamp)
      if (dateStr.contains(' ')) {
        date = DateTime.parse(dateStr);
        return DateFormat('yyyy-MM-dd').format(date);
      }

      // Default: coba parse ISO format
      date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
      return '';
    }
  }

  // 🔹 Ambil data truck type dari API JSP
  Future<List<Map<String, String>>> fetchZone() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-zone-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load zone');
    }
  }

  Future<List<Map<String, String>>> fetchOrigin() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-origin-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load origin');
    }
  }

  Future<List<Map<String, String>>> fetchLocation() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-location-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load lokasi');
    }
  }

  Future<List<Map<String, String>>> fetchItemUom() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-uom-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load item uom');
    }
  }

  Future<List<Map<String, String>>> fetchItemTypes() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-vhtalias-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load item types');
    }
  }

  Future<List<Map<String, String>>> fetchTruckTypes() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-type-truck-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load truck types');
    }
  }

  Future<List<Map<String, String>>> fetchCompany() async {
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/marketing/refference.jsp?method=list-company-an');
    print(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, String>>((item) => {
                'id': item['id'].toString(),
                'text': item['text'].toString(),
              })
          .toList();
    } else {
      throw Exception('Failed to load company');
    }
  }

  Future<void> _loadOrigin() async {
    try {
      final types = await fetchOrigin();
      setState(() {
        originList = types;
      });
    } catch (e) {
      debugPrint('Error loading origin: $e');
    }
  }

  Future<void> _loadItemTypes() async {
    try {
      final types = await fetchItemTypes();
      setState(() {
        itemTypeList = types;
      });
    } catch (e) {
      debugPrint('Error loading item types: $e');
    }
  }

  Future<void> _loadILocation() async {
    try {
      final types = await fetchLocation();
      setState(() {
        itemLokasiList = types;
      });
    } catch (e) {
      debugPrint('Error loading location: $e');
    }
  }

  Future<void> _loadZone() async {
    try {
      final types = await fetchZone();
      setState(() {
        itemZoneList = types;
      });
    } catch (e) {
      debugPrint('Error loading zone: $e');
    }
  }

  Future<void> _loadUomTypes() async {
    try {
      final types = await fetchItemUom();
      setState(() {
        itemUomList = types;
      });
    } catch (e) {
      debugPrint('Error loading uom types: $e');
    }
  }

  Future<void> _loadTruckTypes() async {
    try {
      final types = await fetchTruckTypes();
      setState(() {
        truckTypeList = types;
      });
    } catch (e) {
      debugPrint('Error loading truck types: $e');
    }
  }

  Future<void> _loadCompanay() async {
    try {
      final types = await fetchCompany();
      setState(() {
        companyList = types;
      });
    } catch (e) {
      debugPrint('Error loading company: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // SAFETY CHECK: Pastikan semua dropdown values valid sebelum render
    if (!isLoading) {
      // Pastikan statusValue valid
      if (statusValue.isEmpty || !statusList.contains(statusValue)) {
        statusValue = "OPEN";
      }
      // Pastikan destination valid
      if (destination.isEmpty || !destinationList.contains(destination)) {
        destination = "-";
      }
      // Pastikan doStatus valid
      if (doStatus.isEmpty || !doStatusList.contains(doStatus)) {
        doStatus = "NORMAL";
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        title: const Text("Form Open DO"),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Page 1"),
            Tab(text: "Page 2"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: TabBarView(
                controller: tabController,
                children: [
                  _buildPage1(),
                  _buildPage2(),
                ],
              ),
            ),
    );
  }

  // 📄 PAGE 1
  Widget _buildPage1() {
    // Debug: Print nilai dropdown untuk troubleshooting
    print('DEBUG _buildPage1:');
    print(
        '  statusValue: "$statusValue" (in list: ${statusList.contains(statusValue)})');
    print(
        '  destination: "$destination" (in list: ${destinationList.contains(destination)})');
    print(
        '  doStatus: "$doStatus" (in list: ${doStatusList.contains(doStatus)})');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _inputField2("Delivery Order Number", doNumber),
              _dateField("Delivery Order Date", doDate),
              _dropdownField(
                  "Status",
                  statusValue,
                  statusList,
                  (val) => setState(() => statusValue =
                      (val != null && val.isNotEmpty) ? val : "OPEN")),
              _searchableDropdown(
                "Company",
                customerId,
                companyList,
                (val) => setState(() => customerId = val ?? ""),
              ),
              _inputField("Sub Customer", subCustomer),
              _inputField("Sales Order Number", salesOrder),
              _inputField("Customer Delivery Order Number", custDONumber),
              _dateField("Customer Order Date", custOrderDate),
              _searchableDropdown(
                "Type Truck",
                truckTypeId,
                truckTypeList,
                (val) => setState(() => truckTypeId = val ?? ""),
              ),
              _searchableDropdown(
                "Item Type",
                itemTypeId,
                itemTypeList,
                (val) => setState(() => itemTypeId = val ?? ""),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📄 PAGE 2
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _searchableDropdown(
                "Uom Type",
                itemUomId,
                itemUomList,
                (val) => setState(() => itemUomId = val ?? ""),
              ),
              _inputField("Qty", qty, keyboardType: TextInputType.number),
              _searchableDropdown(
                "Origin",
                originId,
                originList,
                (val) => setState(() => originId = val ?? ""),
              ),
              _dropdownField(
                  "Destination",
                  destination,
                  destinationList,
                  (val) => setState(() => destination =
                      (val != null && val.isNotEmpty) ? val : "-")),
              _searchableDropdown(
                "Zone",
                zoneId,
                itemZoneList,
                (val) => setState(() => zoneId = val ?? ""),
              ),
              _dateField("Delivery Date", deliveryDate),
              _inputField("Notes", notes),
              _dropdownField(
                  "DO Status",
                  doStatus,
                  doStatusList,
                  (val) => setState(() => doStatus =
                      (val != null && val.isNotEmpty) ? val : "NORMAL")),
              _searchableDropdown(
                "Location",
                locationId,
                itemLokasiList,
                (val) => setState(() => locationId = val ?? ""),
              ),
              const SizedBox(height: 20),
              _buttonSimpan(),
            ],
          ),
        ),
      ),
    );
  }

  // 🟠 Input field
  Widget _inputField2(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          TextFormField(
            readOnly: true,
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: lightOrange,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: lightOrange,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // 🟠 Date Picker Field
  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: lightOrange,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon:
                  Icon(Icons.calendar_today, size: 18, color: primaryOrange),
            ),
            onTap: () async {
              DateTime initialDate;
              try {
                if (controller.text.isNotEmpty) {
                  initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
                } else {
                  initialDate = DateTime.now();
                }
              } catch (e) {
                initialDate = DateTime.now();
              }

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: primaryOrange,
                      hintColor: primaryOrange,
                      colorScheme: ColorScheme.light(onPrimary: primaryOrange),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: child ?? Container(),
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  controller.text = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            },
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // 🟠 Dropdown
  Widget _dropdownField(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    // Validasi ketat: value harus ada di items DAN tidak boleh empty string
    String? validValue;
    if (value != null && value.isNotEmpty && items.contains(value)) {
      validValue = value;
    } else {
      validValue = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: validValue,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: lightOrange,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: items
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Wajib dipilih';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // 🟠 Searchable Dropdown
  Widget _searchableDropdown(String label, String selectedId,
      List<Map<String, String>> items, ValueChanged<String> onChanged,
      {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          InkWell(
            onTap: items.isEmpty
                ? null
                : () {
                    _showSearchableDialog(
                      context: context,
                      title: "Pilih $label",
                      items: items,
                      selectedId: selectedId,
                      onSelected: onChanged,
                    );
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: items.isEmpty ? Colors.grey.shade200 : lightOrange,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isRequired && selectedId.isEmpty)
                      ? Colors.red.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      items.isEmpty
                          ? "Loading..."
                          : _getTextFromId(selectedId, items),
                      style: TextStyle(
                        color: selectedId.isEmpty
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTextFromId(String id, List<Map<String, String>> items) {
    if (id.isEmpty) return "Pilih...";
    final item = items.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {'id': '', 'text': 'Pilih...'},
    );
    return item['text']!;
  }

  void _showSearchableDialog({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
    required String selectedId,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SearchableDialog(
          title: title,
          items: items,
          selectedId: selectedId,
          onSelected: onSelected,
          lightOrange: lightOrange,
        );
      },
    );
  }

  Future<void> _simpanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("name") ?? "unknown";
    print('SUBMIT');
    //if (!formKey.currentState.validate()) return;

    // Validasi dropdown
    if (statusValue.isEmpty || !statusList.contains(statusValue)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Status")),
      );
      return;
    }
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Company")),
      );
      return;
    }
    if (truckTypeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Type Truck")),
      );
      return;
    }
    if (itemTypeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Item Type")),
      );
      return;
    }
    if (itemUomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih UOM Type")),
      );
      return;
    }
    if (originId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Origin")),
      );
      return;
    }
    if (!destinationList.contains(destination)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Destination")),
      );
      return;
    }
    if (zoneId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Zone")),
      );
      return;
    }
    if (doStatus.isEmpty || !doStatusList.contains(doStatus)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih DO Status")),
      );
      return;
    }
    if (locationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Silakan pilih Location")),
      );
      return;
    }
    var message ="";
    if(widget.item!=null){
      message = widget.item['dlocustdonbr'] == null ||
          widget.item['dlocustdonbr'].toString() == ""
          ? "simpan"
          : "update";
    }else{
      message="simpan";
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi ${message}"),
        content: Text("Apakah data ini sudah benar dan ingin di ${message} ??"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya")),
        ],
      ),
    );

    if (confirm != true) return;

    final url = Uri.parse(
        "${GlobalData.baseUrl}api/marketing/create_update_delete_dodetailavp.jsp");

    final Map<String, String> body = {
      "method": message == "simpan" || message == "" ? "create-data" : "update-data",
      "dlododetailnumber": doNumber.text,
      "dlodate": doDate.text,
      "dlostatus": statusValue,
      "dlocustomer": customerId,
      "dlosubcustomer": subCustomer.text,
      "dlosalesorder": salesOrder.text,
      "dlocustdonbr": custDONumber.text,
      "dlocustdodate": custOrderDate.text,
      "dloitemtype": itemTypeId,
      "dloitemqty": qty.text,
      "dloorigin": originId,
      "dlodestination": destination,
      "dlodeliverydate": deliveryDate.text,
      "dlonotes": notes.text,
      "zone": zoneId,
      "dloitemuom": itemUomId,
      "dlotype": truckTypeId,
      "vhcid": "", // nanti isi dari dropdown truck
      "drvid": "", // nanti isi dari dropdown driver
      "status": doStatus,
      "dloLocId": locationId,
      "dlooriginaldonbr": salesOrder.text,
      "userid": user,
    };
    print('body');
    print(body);
    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res["status"] == "OK") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Data berhasil di${message}")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("Gagal: ${res["message"] ?? "Error tak diketahui"}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Widget _buttonSimpan() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.save, size: 18, color: Colors.white),
        label: const Text(
          "Submit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        onPressed: _simpanData,
      ),
    );
  }
}

// 🔍 Custom Searchable Dialog Widget
class _SearchableDialog extends StatefulWidget {
  final String title;
  final List<Map<String, String>> items;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final Color lightOrange;

  const _SearchableDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.lightOrange,
  }) : super(key: key);

  @override
  _SearchableDialogState createState() => _SearchableDialogState();
}

class _SearchableDialogState extends State<_SearchableDialog> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where((item) =>
                item['text']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.lightOrange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Cari...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onChanged: _filterItems,
              ),
            ),
            // List Items
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(child: Text("Tidak ada data"))
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = item['id'] == widget.selectedId;
                        return ListTile(
                          title: Text(item['text']!),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          selected: isSelected,
                          onTap: () {
                            widget.onSelected(item['id']!);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
