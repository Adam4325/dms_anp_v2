import 'dart:async';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/MapPlaybackUnits.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/color_constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FrmPlayBack extends StatefulWidget {
  @override
  FrmPlayBackState createState() => FrmPlayBackState();
}

TextEditingController txtSearchVehicle = TextEditingController();
TextEditingController txtVehicleIdList = TextEditingController();
TextEditingController txtVehicleName = TextEditingController();
List listVehicleId = [];

class _BottomSheetContentVehicle extends StatefulWidget {
  @override
  _BottomSheetContentVehicleState createState() =>
      _BottomSheetContentVehicleState();
}

class _BottomSheetContentVehicleState extends State<_BottomSheetContentVehicle> {
  List<Map<String, dynamic>> _filteredList = [];
  String _selectedCategory = "ALL"; // ALL, MIXER, NON_MIXER

  void _filterList(String query) {
    setState(() {
      final q = query.trim().toLowerCase();
      List<Map<String, dynamic>> baseList =
          List<Map<String, dynamic>>.from(listVehicleId);

      _filteredList = baseList.where((v) {
        final title = (v['title'] ?? '').toString();
        final value = (v['value'] ?? '').toString();
        final isMixer = title.toUpperCase().contains('MIX') ||
            value.toUpperCase().contains('MIX');

        // Filter category
        if (_selectedCategory == "MIXER" && !isMixer) return false;
        if (_selectedCategory == "NON_MIXER" && isMixer) return false;

        // Search text
        if (q.isNotEmpty) {
          final matchesTitle = title.toLowerCase().contains(q);
          final matchesValue = value.toLowerCase().contains(q);
          if (!matchesTitle && !matchesValue) return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _filterList(txtSearchVehicle.text);
    txtSearchVehicle.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterList(txtSearchVehicle.text);
  }

  @override
  void dispose() {
    txtSearchVehicle.removeListener(_onSearchChanged);
    super.dispose();
  }

  Widget _buildCategoryChip(String label, String categoryKey) {
    final isSelected = _selectedCategory == categoryKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = categoryKey;
        });
        _filterList(txtSearchVehicle.text);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : ColorConstants.kTextColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pilih Kendaraan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Total ${listVehicleId.length} armada terdaftar",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: txtSearchVehicle,
              cursorColor: Colors.orange,
              onChanged: (_) => _filterList(txtSearchVehicle.text),
              decoration: InputDecoration(
                hintText: "Cari Nopol atau cabang...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                suffixIcon: txtSearchVehicle.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.cancel,
                            color: Colors.grey.shade400, size: 18),
                        onPressed: () {
                          txtSearchVehicle.clear();
                          _filterList('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
          ),

          // Category Chips & Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildCategoryChip("Semua", "ALL"),
                SizedBox(width: 8),
                _buildCategoryChip("Mixer", "MIXER"),
                SizedBox(width: 8),
                _buildCategoryChip("Non-Mixer", "NON_MIXER"),
                Spacer(),
                Text(
                  "${_filteredList.length} unit",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),

          // Vehicle List
          Expanded(
            child: listVehicleId.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.orange),
                        SizedBox(height: 14),
                        Text(
                          "Memuat data armada...",
                          style: TextStyle(
                            color: ColorConstants.kTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Tidak ada armada ditemukan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.kTextColor,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Coba cari dengan kata kunci lain",
                              style: TextStyle(
                                color: ColorConstants.kGreyTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final item = _filteredList[index];
                          final title = (item['title'] ?? '').toString();
                          final value = (item['value'] ?? '').toString();
                          final isMixer = title.toUpperCase().contains('MIX') ||
                              value.toUpperCase().contains('MIX');
                          final isSelected = txtVehicleName.text
                                  .trim()
                                  .toUpperCase() ==
                              value.trim().toUpperCase();

                          String branch = '';
                          if (title.contains(' - ')) {
                            branch = title
                                .split(' - ')
                                .sublist(1)
                                .join(' - ')
                                .trim();
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.orange.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  txtVehicleName.text = value;
                                  txtVehicleIdList.text = value;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Leading Avatar
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isMixer
                                              ? Colors.orange.shade50
                                              : Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isMixer
                                                ? Colors.orange.shade200
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            isMixer
                                                ? Icons.local_shipping_rounded
                                                : Icons.directions_car_rounded,
                                            color: isMixer
                                                ? Colors.orange.shade800
                                                : Color(0xFF475569),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),

                                      // Middle info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  value.isNotEmpty
                                                      ? value
                                                      : title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1E293B),
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                if (isMixer)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .orange.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      "MIXER",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .orange.shade900,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            if (branch.isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_outlined,
                                                    size: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Expanded(
                                                    child: Text(
                                                      branch,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                "Vehicle ID: $value",
                                                style: TextStyle(
                                                  color: ColorConstants
                                                      .kGreyTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),

                                      // Trailing Button
                                      if (isSelected)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check,
                                                  size: 14,
                                                  color: Colors.white),
                                              SizedBox(width: 4),
                                              Text(
                                                "Dipilih",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.orange.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Pilih",
                                                style: TextStyle(
                                                  color: Colors.orange.shade800,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 10,
                                                color: Colors.orange.shade800,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class FrmPlayBackState extends State<FrmPlayBack> {
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtVHCID = TextEditingController();
  TextEditingController txtStartDate = TextEditingController();
  TextEditingController txtEndDate = TextEditingController();
  TextEditingController txtSearchVehicle = TextEditingController();
  List<Map<String, dynamic>> dataListUnits = [];
  String start_date = "";
  String end_date = "";
  String status_type = "";
  final picker = ImagePicker();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void getVehicleList() async {
    try {
      String urlData =
          "${GlobalData.baseUrl}api/gt/list_vehicle.jsp?method=lookup-vehicle-v1";
      String encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        if (response.statusCode == 200) {
          listVehicleId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data detail vehicle", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data vehicle",
          "error");
      print(e.toString());
    }
  }

  void _showModalListVehicle(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetContentVehicle();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        },
        child: Scaffold(
          key: globalScaffoldKey,
          backgroundColor: Colors.orange,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              color: Colors.white,
              onPressed: () {
                _goBack(context);
              },
            ),
            title: Text("Search History Nopol",style: TextStyle(color:Colors.white)),
            backgroundColor: Colors.orange,
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              color: ColorConstants.kScreebBackColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: FrmSearchPB(context),
          ),
        ));
  }

  Future getListDataUnits(bool isload, String search) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();

      String urlData =
          "${GlobalData.baseUrl}api/nontera/list_vehicle.jsp?method=list_units&vhcid=$search";
      print(urlData);
      Uri myUri = Uri.parse(urlData);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          dataListUnits = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data units",
            "error");
      }

      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data units",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget _buildDListDetailUnits(dynamic item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nopol: ${item['vhcid']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.kTextColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Cabang: ${item['locid']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorConstants.kGreyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    setState(() {
                      txtVHCID.text = item['vhcid'].toString();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Pilih',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listDataUnits(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Vehicle Selection Field
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: TextField(
              readOnly: true,
              cursorColor: Colors.orange,
              style: TextStyle(color: ColorConstants.kTextColor),
              controller: txtVehicleName,
              onTap: () {
                _showModalListVehicle(context);
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                labelText: "Pilih Kendaraan",
                contentPadding: EdgeInsets.all(5.0),
              ),
            ),
          ),

          // Units List
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: dataListUnits.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildDListDetailUnits(dataListUnits[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void reset() {
    setState(() {
      txtStartDate.text = '';
      txtEndDate.text = '';
      txtVehicleName.text = '';
    });
  }

  Widget FrmSearchPB(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            color: Colors.orange.shade700,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.kTextColor,
                              ),
                            ),
                            Text(
                              'Pilih rentang waktu & armada',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorConstants.kGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Start Date
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'yyyy-MM-dd',
                        controller: txtStartDate,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        icon: Icon(
                          Icons.event,
                          color: Colors.orange,
                        ),
                        dateLabelText: 'Start Date',
                        timeLabelText: 'Start Time',
                        selectableDayPredicate: (date) {
                          return true;
                        },
                        onChanged: (val) => setState(() => start_date = val),
                        validator: (val) {
                          setState(() => start_date = val!);
                          return null;
                        },
                        onSaved: (val) => setState(() => start_date = val!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: ColorConstants.ktextFieldBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2),
                          ),
                          filled: true,
                          fillColor: ColorConstants.kWhiteColor,
                        ),
                      ),
                    ),

                    // End Date
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'yyyy-MM-dd',
                        controller: txtEndDate,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        icon: Icon(
                          Icons.event,
                          color: Colors.orange,
                        ),
                        dateLabelText: 'End Date',
                        timeLabelText: 'End Time',
                        selectableDayPredicate: (date) {
                          return true;
                        },
                        onChanged: (val) => setState(() => end_date = val),
                        validator: (val) {
                          setState(() => end_date = val!);
                          return null;
                        },
                        onSaved: (val) => setState(() => end_date = val!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: ColorConstants.ktextFieldBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2),
                          ),
                          filled: true,
                          fillColor: ColorConstants.kWhiteColor,
                        ),
                      ),
                    ),

                    // Vehicle Selection
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      child: TextField(
                        readOnly: true,
                        cursorColor: Colors.orange,
                        style: TextStyle(
                          color: ColorConstants.kTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        controller: txtVehicleName,
                        onTap: () {
                          _showModalListVehicle(context);
                        },
                        decoration: InputDecoration(
                          labelText: "Pilih Kendaraan",
                          labelStyle: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: "Tap untuk memilih kendaraan",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.directions_car_rounded,
                            color: Colors.orange,
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.orange,
                            size: 32,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange.shade300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFBF5),
                        ),
                      ),
                    ),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString("pb_start_date", txtStartDate.text);
                          prefs.setString("pb_end_date", txtEndDate.text);
                          prefs.setString("pb_vhcid", txtVehicleName.text);

                          print('start_date ${txtStartDate.text}');
                          print('end_date ${txtEndDate.text}');
                          print('vhcid ${txtVehicleName.text}');

                          if (!EasyLoading.isShow) {
                            EasyLoading.show();
                          }

                          Timer(Duration(seconds: 1), () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapPlayBackUnits()));
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Search History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  @override
  void initState() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    DateTime now = DateTime.now();
    String formattedDate = "${DateFormat('yyyy-MM-dd').format(now)} 00:00";
    String formattedEndDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
    getVehicleList();
    print(formattedDate);
    setState(() {
      txtStartDate.text = formattedDate;
      txtEndDate.text = formattedEndDate;
    });
    super.initState();
  }
}
