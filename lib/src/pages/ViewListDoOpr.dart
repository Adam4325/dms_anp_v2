import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:dms_anp/src/Helper/GenerateTokenAuth.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/pages/FromCloseDoByOpr.dart';
import 'package:dms_anp/src/pages/LiveMaps.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';

class ViewListDoOpr extends StatefulWidget {
  @override
  _ViewListDoOprState createState() => _ViewListDoOprState();
}

class _ViewListDoOprState extends State<ViewListDoOpr> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;
  TextEditingController _bujdate = TextEditingController();
  TextEditingController _search = TextEditingController();
  TextEditingController _search_vhcid = TextEditingController();

  List data = [];
  String status_code = "";
  String messageAPI = "";
  String dlocustdonbr = "";
  String current_date = "";

  String username = "";
  String loginname = "";
  bool isAdminOrOp = true; // Default true so Close DO is hidden for Admin/OP
  bool _isFilterExpanded = false;

  String vhcid = "";
  String vhcgps = "";
  double lat = 0;
  double lon = 0;
  String addr = "";
  String no_do = "";
  String ket_status_do = "";
  String driver_nm = "";
  String nopol = "";
  String gps_sn = "";
  String gps_time = "";
  int speed = 0;
  int acc = 0;
  String direction = "0";

  String? _chosenValue;
  List<String> arrLocid = [];

  // Material Design Orange Theme Colors
  final Color primaryOrange = const Color(0xFFFF6600);
  final Color darkOrange = const Color(0xFFD95500);
  final Color lightOrange = const Color(0xFFFFF3E0);
  final Color accentOrange = const Color(0xFFFF8C00);
  final Color bgSlate = const Color(0xFFF1F5F9);

  bool get _hasActiveSecondaryFilters =>
      _search_vhcid.text.trim().isNotEmpty ||
      _bujdate.text.trim().isNotEmpty ||
      (_chosenValue != null &&
          _chosenValue != "ALL" &&
          _chosenValue!.isNotEmpty);

  Future<String> getJSONData() async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String locid = "";
      String vehicleid = _search_vhcid.text.trim();

      String savedLocid = prefs.getString("locid") ?? "";
      if (_chosenValue == null ||
          _chosenValue == "" ||
          _chosenValue!.toLowerCase() == "all") {
        locid = (savedLocid.toLowerCase() == "all") ? "" : savedLocid;
      } else {
        locid = _chosenValue!;
      }

      print(
          "ViewListDoOpr query -> locid: '$locid', vhcid: '$vehicleid', do: '$dlocustdonbr', date: '$current_date'");

      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/list_do_operasional.jsp?method=list_do_opr" +
              "&locid=" +
              locid +
              "&vhcid=" +
              vehicleid +
              "&dlocustdonbr=" +
              dlocustdonbr +
              "&current_date=" +
              current_date);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        prefs.setString("sLOCID", "");
        prefs.setString("sVHCID", "");
        final decoded = json.decode(response.body);
        data = decoded["data"] ?? [];
        print("Total DO fetched: ${data.length}");
        if (data.isEmpty) {
          _showOrangeAlert(context, "Tidak ada data DO", "warning");
        }
      });
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return "Successfull";
  }

  void _showOrangeAlert(BuildContext context, String message, String type) {
    IconData alertIcon;
    Color alertColor;

    switch (type) {
      case "error":
        alertIcon = Icons.error_outline;
        alertColor = Colors.red.shade400;
        break;
      case "warning":
        alertIcon = Icons.warning_amber_rounded;
        alertColor = accentOrange;
        break;
      case "success":
        alertIcon = Icons.check_circle_outline;
        alertColor = Colors.green.shade500;
        break;
      default:
        alertIcon = Icons.info_outline;
        alertColor = primaryOrange;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(alertIcon, color: alertColor, size: 26),
              const SizedBox(width: 10),
              Text(
                'Informasi',
                style: TextStyle(
                  color: darkOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 1.5,
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<String?> GetLastPositionFirst(String token, String vhcid) async {
    try {
      Uri myUri = Uri.parse(GlobalData.baseUrlAPIEASYGO +
          "Vehicle/LastUpdateByNopol?nopol=$vhcid");
      var response = await http.post(myUri,
          headers: {"Accept": "application/json", "Authorization": token});
      if (response.statusCode == 200) {
        List dataLast = json.decode(response.body)['data'] ?? [];
        if (dataLast.isNotEmpty) {
          nopol = dataLast[0]["nopol"] ?? "";
          acc = dataLast[0]["acc"] ?? 0;
          gps_time = dataLast[0]["gps_time"] ?? "";
          gps_sn = dataLast[0]["gps_sn"] ?? "";
          addr = dataLast[0]["addr"] ?? "";
          speed = dataLast[0]["speed"] ?? 0;
          direction = (dataLast[0]["direction"] ?? "0").toString();
          lon = (dataLast[0]["lon"] as num?)?.toDouble() ?? 0;
          lat = (dataLast[0]["lat"] as num?)?.toDouble() ?? 0;
          no_do = dataLast[0]["no_do"] ?? "";
          ket_status_do = dataLast[0]["ket_status_do"] ?? "";
          driver_nm = dataLast[0]["driver_nm"] ?? "";
          messageAPI = "200";
        } else {
          messageAPI = "No Data";
        }
      } else {
        var dataError = json.decode(response.body);
        messageAPI = dataError['message'].toString();
      }
      return "Success";
    } catch (e) {
      print("Auth Error $e");
      return null;
    }
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    if (_bujdate.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_bujdate.text);
      } catch (_) {}
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _bujdate.text = DateFormat('yyyy-MM-dd').format(picked);
        current_date = _bujdate.text;
      });
      await getJSONData();
    }
  }

  Future<void> _executeSearch() async {
    FocusScope.of(context).unfocus();
    setState(() {
      dlocustdonbr = _search.text.trim();
      current_date = _bujdate.text.trim();
    });
    await getJSONData();
  }

  Future<void> _resetFilters() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _search.clear();
      _search_vhcid.clear();
      _bujdate.clear();
      _chosenValue = "ALL";
      dlocustdonbr = "";
      current_date = "";
    });
    await getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true);
    pr?.style(
      message: 'Memuat data...',
      borderRadius: 12.0,
      backgroundColor: Colors.white,
      elevation: 8.0,
      progressTextStyle: const TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(
          color: Color(0xFF1E293B), fontSize: 16.0, fontWeight: FontWeight.bold),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        backgroundColor: bgSlate,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.white),
            onPressed: () => _goBack(context),
          ),
          centerTitle: true,
          title: const Text(
            'Form List DO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          key: globalScaffoldKey,
          constraints: const BoxConstraints.expand(),
          color: bgSlate,
          child: Column(
            children: [
              _buildFormSearch(context),
              _buildSummaryHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: primaryOrange,
                  onRefresh: () => getJSONData(),
                  child: _buildListView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            '${data.length} DO Ditemukan',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            (_chosenValue != null && _chosenValue != "ALL")
                ? 'Cabang: $_chosenValue'
                : 'Semua Cabang',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (data.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment_outlined,
                      size: 52, color: primaryOrange),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak ada data DO operasional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Silakan ubah kata kunci atau reset filter pencarian',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    "Refresh Data",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  onPressed: () => getJSONData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildDMSMenuDO(data[index], index);
      },
    );
  }

  Widget _buildFormSearch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Search No. DO Input + Filter Toggle + Search Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _executeSearch(),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        hintText: "Cari No. DO...",
                        hintStyle: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 19, color: primaryOrange),
                        suffixIcon: _search.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _search.clear();
                                    dlocustdonbr = "";
                                  });
                                  getJSONData();
                                },
                                child: Icon(Icons.cancel_rounded,
                                    size: 17, color: Colors.grey.shade400),
                              )
                            : null,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Filter toggle icon button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: (_isFilterExpanded || _hasActiveSecondaryFilters)
                          ? lightOrange
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _hasActiveSecondaryFilters
                            ? primaryOrange
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 19,
                          color: (_isFilterExpanded || _hasActiveSecondaryFilters)
                              ? primaryOrange
                              : Colors.grey.shade700,
                        ),
                        if (_hasActiveSecondaryFilters)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Search Button (White Font)
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _executeSearch,
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.search, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "Cari",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Active filter chips (compact indicator)
            if (_hasActiveSecondaryFilters && !_isFilterExpanded) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_search_vhcid.text.trim().isNotEmpty)
                      _buildFilterChip(
                        label: 'Nopol: ${_search_vhcid.text}',
                        onDeleted: () {
                          setState(() {
                            _search_vhcid.clear();
                          });
                          getJSONData();
                        },
                      ),
                    if (_chosenValue != null &&
                        _chosenValue != "ALL" &&
                        _chosenValue!.isNotEmpty)
                      _buildFilterChip(
                        label: 'Cabang: $_chosenValue',
                        onDeleted: () {
                          setState(() {
                            _chosenValue = "ALL";
                          });
                          getJSONData();
                        },
                      ),
                    if (_bujdate.text.trim().isNotEmpty)
                      _buildFilterChip(
                        label: 'Tgl: ${_bujdate.text}',
                        onDeleted: () {
                          setState(() {
                            _bujdate.clear();
                            current_date = "";
                          });
                          getJSONData();
                        },
                      ),
                  ],
                ),
              ),
            ],

            // Expandable section for Nopol, Cabang, Date & Reset
            if (_isFilterExpanded) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),

              // Row 2: Nopol & Cabang Dropdown
              Row(
                children: [
                  // Nopol Field
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: TextField(
                        controller: _search_vhcid,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          hintText: "Nopol Kendaraan",
                          hintStyle: TextStyle(
                              fontSize: 12, color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.directions_car_outlined,
                              size: 16, color: primaryOrange),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Cabang Dropdown
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _chosenValue,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down,
                              color: primaryOrange, size: 20),
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF1E293B)),
                          hint: Text(
                            "Cabang",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          items: arrLocid.map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              _chosenValue = value;
                              globals.locid = _chosenValue;
                              prefs.setString("sLOCID", globals.locid ?? "");
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3: Date Picker & Reset Button
              Row(
                children: [
                  // Date Picker Container
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 15, color: primaryOrange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _bujdate.text.isNotEmpty
                                    ? _bujdate.text
                                    : "Pilih Tanggal DO",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _bujdate.text.isNotEmpty
                                      ? const Color(0xFF1E293B)
                                      : Colors.grey.shade400,
                                  fontWeight: _bujdate.text.isNotEmpty
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_bujdate.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _bujdate.clear();
                                    current_date = "";
                                  });
                                  getJSONData();
                                },
                                child: Icon(Icons.cancel_rounded,
                                    size: 15, color: Colors.grey.shade400),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Reset Button (White Font)
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 15, color: Colors.white),
                      label: const Text(
                        "Reset",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        backgroundColor: const Color(0xFF64748B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onDeleted}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: lightOrange,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: darkOrange,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(Icons.close_rounded, size: 13, color: darkOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildDMSMenuDO(dynamic item, int index) {
    final bujNbr = item['bujnbr']?.toString().trim() ?? '-';
    final nopol = item['vhcid']?.toString().trim() ?? '-';
    final locId = item['locid']?.toString().trim() ?? '-';
    final status =
        (item['bujstatus']?.toString().trim() ?? 'UNKNOWN').toUpperCase();
    final origin = item['origin_name']?.toString().trim() ?? '-';
    final destination = item['destination_name']?.toString().trim() ?? '-';
    final doNbr = item['dlocustdonbr']?.toString().trim() ?? '-';
    final qty = item['bujitemqty']?.toString().trim() ?? '0';
    final uom = item['dloitemuom']?.toString().trim() ?? '';
    final gpsRaw = item['vhcgps']?.toString().trim() ?? '';
    final hasGps = gpsRaw.isNotEmpty && gpsRaw.toLowerCase() != 'null';
    final gpsVendor = hasGps ? gpsRaw : 'NO GPS';

    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: BUJ Number + Nopol Plate Badge + Status Chip
          Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                // BUJ Number Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: primaryOrange.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 14, color: darkOrange),
                      const SizedBox(width: 4),
                      Text(
                        '#$bujNbr',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: darkOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Nopol Plate
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        nopol,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withOpacity(0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Route Timeline (Origin -> Destination)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.radio_button_checked,
                          size: 16, color: Color(0xFF16A34A)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORIGIN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            origin,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Connector line
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Container(
                    width: 2,
                    height: 12,
                    color: Colors.grey.shade300,
                  ),
                ),

                // Destination
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on,
                          size: 16, color: Color(0xFFE11D48)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESTINATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            destination,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Compact Metadata Grid (No DO, Qty, Cabang, GPS)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No. DO Customer',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doNbr,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 26, color: Colors.grey.shade300),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muatan',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$qty $uom',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 26, color: Colors.grey.shade300),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cabang • GPS',
                        style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            locId,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'GPS: $gpsVendor',
                            child: Icon(
                              hasGps ? Icons.gps_fixed : Icons.gps_off,
                              size: 12,
                              color: hasGps
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 4. Action Buttons (Close DO is hidden for ADMIN & OP; Font color is ALWAYS White)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
            child: isAdminOrOp
                ? SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map_outlined,
                          color: Colors.white, size: 18),
                      label: const Text(
                        "Lacak / Lihat Peta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _handleViewTracking(item),
                      style: ElevatedButton.styleFrom(
                        elevation: 1.5,
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // Close DO button (ONLY shown if not Admin/OP)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cancel_outlined,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "Close DO",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _handleCloseDo(item),
                            style: ElevatedButton.styleFrom(
                              elevation: 1.5,
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // View button
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map_outlined,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _handleViewTracking(item),
                            style: ElevatedButton.styleFrom(
                              elevation: 1.5,
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCloseDo(dynamic item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("bujnbrOPR", item['bujnbr'] ?? '');
      prefs.setString("dlocustdonbrOPR", item['dlocustdonbr'] ?? '');
      prefs.setString("advbujnbrOPR", item['bujnbr'] ?? '');
      prefs.setString("vhcidOPR", item['vhcid'] ?? '');
      prefs.setString("originOPR", item['idorigin'] ?? '');
      prefs.setString("origin_nameOPR", item['origin_name'] ?? '');
      prefs.setString("destinationOPR", item['iddestination'] ?? '');
      prefs.setString("destination_nameOPR", item['destination_name'] ?? '');
      prefs.setString("tarifuomOPR", item['dloitemuom'] ?? '');
      prefs.setString("qtyOPR", item['bujitemqty'] ?? '');
      prefs.setString("locidOPR", item['locid'] ?? '');
      prefs.setString("odometerOPR", item["bujinmtr"] ?? '');
      prefs.setString("odometerOutOPR", item["bujoutmtr"] ?? '');
      prefs.setString("imageDo", "");
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                ),
                const SizedBox(height: 16),
                Text(
                  "Membuka Form...",
                  style: TextStyle(
                    color: darkOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Timer(const Duration(milliseconds: 600), () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FrmCloseDoByOpr()),
      );
    });
  }

  Future<void> _handleViewTracking(dynamic item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var gpsName = (item['vhcgps'] ?? '').toString().trim();
    var vhCID = (item['vhcid'] ?? '').toString().trim();
    prefs.setString("page", "another");
    var _tokens = "";
    print("Tracking GPS: $gpsName, VHC: $vhCID");

    if (gpsName.isNotEmpty && gpsName != "null") {
      if (gpsName.toLowerCase().replaceAll(" ", "") == "easygo") {
        var tokenAuth = GenerateTokenAuth();
        _tokens = await tokenAuth.GetTokenEasyGo(gpsName, pr!);
        if (_tokens.isNotEmpty) {
          setState(() {
            prefs.setString("vhcgps", item['vhcgps'] ?? '');
            prefs.setString("vhcidOPR", item['vhcid'] ?? '');
            prefs.setString("tokeneasygo", _tokens);
          });
          await GetLastPositionFirst(_tokens, item['vhcid'] ?? '');
          List<String> lstLast = [
            gps_sn, //0
            nopol, //1
            gps_time, //2
            acc.toString(), //3
            addr, //4
            speed.toString(), //5
            direction, //6
            lat.toString(), //7
            lon.toString(), //8
            no_do, //9
            ket_status_do, //10
            driver_nm, //11
            "easygo" //12
          ];
          if (messageAPI == "200") {
            prefs.remove("dataLast");
            prefs.setStringList("dataLast", lstLast);
          } else {
            pr?.hide();
            prefs.setStringList("dataLast", lstLast);
          }
          var is_driver = 'false;';
          if (prefs.getString("loginname") == "DRIVER") {
            is_driver = 'true';
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LiveMaps(is_driver: is_driver)),
          );
        } else {
          pr?.hide();
          _showOrangeAlert(context, "Token Not Valid", "error");
        }
      } else {
        List<String> lstLast = [
          "", //0
          vhCID, //1
          "", //2
          "", //3
          "", //4
          "", //5
          "", //6
          "", //7
          "", //8
          "", //9
          "", //10
          "", //11
          "izzy" //12
        ];
        prefs.remove("dataLast");
        prefs.setStringList("dataLast", lstLast);
        prefs.setString("dlocustdonbrOPR", item['dlocustdonbr'] ?? '');
        prefs.setString("statusDlocustdonbrOPR", item['bujstatus'] ?? '');
        var is_driver = 'false;';
        if (prefs.getString("loginname") == "DRIVER") {
          is_driver = 'true';
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LiveMaps(is_driver: is_driver)),
        );
      }
    } else {
      pr?.hide();
      _showOrangeAlert(context, "GPS vendor tidak tersedia", "warning");
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'DONE':
      case 'CLOSED':
        return const Color(0xFF16A34A);
      case 'ONGOING':
      case 'IN PROGRESS':
      case 'DELIVERING':
        return const Color(0xFF0284C7);
      case 'PENDING':
      case 'WAITING':
      case 'ANTRIAN':
        return const Color(0xFFD97706);
      case 'CANCELLED':
      case 'CANCEL':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  getDataPreference() async {
    SharedPreferences resPreps = await SharedPreferences.getInstance();
    setState(() {
      username = (resPreps.getString("username") ?? "").trim();
      loginname = (resPreps.getString("loginname") ?? "").trim();

      bool hasOpAccess = globals.akses_pages.any((x) =>
          x == "OP" || x == "OK" || x == "OT" || x == "UA");

      isAdminOrOp = username.toUpperCase() == "ADMIN" ||
          loginname.toUpperCase() == "ADMIN" ||
          loginname.toUpperCase() == "DISPATCH" ||
          loginname.toUpperCase() == "OPERASIONAL" ||
          hasOpAccess;

      String rawLocid = resPreps.getString("locid") ?? "";
      List<String> list = ["ALL"];
      if (rawLocid.isNotEmpty) {
        for (var item in rawLocid.split(",")) {
          String trimmed = item.trim();
          if (trimmed.isNotEmpty &&
              trimmed.toUpperCase() != "ALL" &&
              !list.contains(trimmed)) {
            list.add(trimmed);
          }
        }
      }
      arrLocid = list;
      _chosenValue ??= "ALL";
    });
  }

  @override
  void initState() {
    super.initState();
    _bujdate = TextEditingController(text: "");
    _search = TextEditingController(text: "");
    _search_vhcid = TextEditingController(text: "");
    dlocustdonbr = "";
    current_date = "";

    getDataPreference();
    getJSONData();
    globals.locid = "";
    globals.vhcid = "";
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    _bujdate.dispose();
    _search.dispose();
    _search_vhcid.dispose();
    super.dispose();
  }
}
