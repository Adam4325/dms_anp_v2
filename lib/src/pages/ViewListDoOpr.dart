

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/GenerateTokenAuth.dart';
import 'package:dms_anp/src/pages/AdvanceSearchDoOp.dart';
import 'package:dms_anp/src/pages/LiveMaps.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Helper//globals.dart' as globals;
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/FromCloseDoByOpr.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../flusbar.dart';

class ViewListDoOpr extends StatefulWidget {
  @override
  _ViewListDoOprState createState() => _ViewListDoOprState();
}

class _ViewListDoOprState extends State<ViewListDoOpr> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;
  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  TextEditingController _bujdate = new TextEditingController();
  TextEditingController _search = new TextEditingController();
  TextEditingController _search_vhcid = new TextEditingController();
  String _valueChanged1 = "";
  String _valueToValidate1 = '';
  String _valueSaved1 = '';
  late List data;
  String status_code = "";
  String messageAPI = "";
  String dlocustdonbr = "";
  String current_date = "";

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
  String arrayLocid = "";
  List<String> arrLocid = [];

  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow

  Future<String> getJSONData() async {
    try{
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? locid = "";
      String vehicleid = "";
      setState(() {
        locid = _chosenValue.toString() == "" || _chosenValue == null
            ? prefs.getString("locid")
            : (_chosenValue.toString().toLowerCase() == "all"
            ? prefs.getString("locid")
            : _chosenValue.toString());

        vehicleid = _search_vhcid.value.text.toString() == "" ||
            _search_vhcid.value.text == null
            ? ""
            : _search_vhcid.value.text.toString();
      });
      print(locid);
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/list_do_operasional.jsp?method=list_do_opr&locid=" +
              locid.toString() +
              "&vhcid=" +
              vehicleid.toString() +
              "&dlocustdonbr=" +
              dlocustdonbr +
              "&current_date=" +
              current_date);
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        // Get the JSON data
        prefs.setString("sLOCID", "");
        prefs.setString("sVHCID", "");
        data = json.decode(response.body)["data"];
        print(data);
        if (data == null || data.length == 0 || data == "") {
          _showOrangeAlert(
              context, "Tidak ada data DO", "warning");
        }
      });
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
    }catch($e){
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
    }
    //EasyLoading.dismiss();
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
        alertIcon = Icons.warning_outlined;
        alertColor = accentOrange;
        break;
      case "success":
        alertIcon = Icons.check_circle_outline;
        alertColor = Colors.green.shade400;
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
          backgroundColor: cardColor,
          title: Row(
            children: [
              Icon(alertIcon, color: alertColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Information',
                style: TextStyle(
                  color: darkOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 2.0,
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
    var listData = new LastPostionEasyGo(
        "", "", 0, 0, "", "", "", "", "", "", "", 0, 0, "", "");
    try {
      Uri myUri = Uri.parse(GlobalData.baseUrlAPIEASYGO +
          "Vehicle/LastUpdateByNopol?nopol=$vhcid");
      print(myUri);
      var response = await http.post(myUri,
          headers: {"Accept": "application/json", "Authorization": token});
      if (response.statusCode == 200) {
        print(json.decode(response.body)['data']);
        List dataLast = [];
        dataLast = json.decode(response.body)['data'];
        print(dataLast);
        if (dataLast.length > 0 && dataLast != []) {
          //print("dataLast[0] "+dataLast[0]['nopol']);
          nopol = dataLast[0]["nopol"];
          acc = dataLast[0]["acc"];
          gps_time = dataLast[0]["gps_time"];
          gps_sn = dataLast[0]["gps_sn"];
          addr = dataLast[0]["addr"];
          speed = dataLast[0]["speed"];
          direction = dataLast[0]["direction"];
          lon = dataLast[0]["lon"];
          lat = dataLast[0]["lat"];
          no_do = dataLast[0]["no_do"];
          ket_status_do = dataLast[0]["ket_status_do"];
          driver_nm = dataLast[0]["driver_nm"];
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
      listData.message = "Error $e";
      print("Auth Error$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true);

    pr?.style(
      message: 'Wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return new WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                _goBack(context);
              },
            ),
            centerTitle: true,
            title: Text(
              'Form List DO',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            )),
        body: new Container(
          key: globalScaffoldKey,
          margin: const EdgeInsets.only(top: 8.0),
          constraints: new BoxConstraints.expand(),
          color: backgroundColor,
          child: new Stack(
            children: <Widget>[_buildFormSearch(context), _buildListView()],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Container(
        margin: const EdgeInsets.only(top: 280),
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildDMSMenuDO(data[index], index);
            }));
  }

  Widget _buildFormSearch(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header
          // Container(
          //   padding: EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: lightOrange,
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(16),
          //       topRight: Radius.circular(16),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(Icons.search, color: primaryOrange, size: 24),
          //       SizedBox(width: 12),
          //       Text(
          //         'Pencarian DO',
          //         style: TextStyle(
          //           color: darkOrange,
          //           fontSize: 16,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Form Content
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Date and Branch Row
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: DateTimePicker(
                          dateMask: 'd MMM, yyyy',
                          controller: _bujdate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          icon: Icon(Icons.event, color: primaryOrange),
                          dateLabelText: 'Date',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Date",
                            fillColor: Colors.white,
                            filled: true,
                            isDense: true,
                            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryOrange, width: 2),
                            ),
                          ),
                          selectableDayPredicate: (date) {
                            if (date.weekday == 6 || date.weekday == 7) {
                              return false;
                            }
                            return true;
                          },
                          onChanged: (val) => setState(() => _valueChanged1 = val),
                          validator: (val) {
                            setState(() => _valueToValidate1 = val ?? '');
                            return null;
                          },
                          onSaved: (val) => setState(() => _valueSaved1 = val ?? ''),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: DropdownButton<String>(
                          value: _chosenValue,
                          isExpanded: true,
                          underline: SizedBox(),
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          items: arrLocid.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          hint: Text(
                            "Cabang",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          onChanged: (String? value) async {
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            setState(() {
                              _chosenValue = value;
                              globals.locid = _chosenValue;
                              prefs.setString("sLOCID", globals.locid!);
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                // Search DO Field
                Container(
                  child: TextField(
                    cursorColor: primaryOrange,
                    controller: _search,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search By No DO',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryOrange, width: 2),
                      ),
                      prefixIcon: Icon(Icons.assignment, color: primaryOrange),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Search Nopol Field
                Container(
                  child: TextField(
                    cursorColor: primaryOrange,
                    controller: _search_vhcid,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by Nopol',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryOrange, width: 2),
                      ),
                      prefixIcon: Icon(Icons.directions_car, color: primaryOrange),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 22.0,
                          ),
                          label: Text(
                            "Refresh",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () async {
                            dlocustdonbr = "";
                            current_date = "";
                            _bujdate = TextEditingController(text: "");
                            _search = TextEditingController(text: "");
                            _search_vhcid = TextEditingController(text: "");
                            //_chosenValue="";
                            await getJSONData();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3.0,
                            backgroundColor: accentOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 22.0,
                          ),
                          label: Text(
                            "Search",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () async {
                            var date = _bujdate.value.text;
                            var doSearch = _search.value.text;
                            if (doSearch != "" && doSearch != null) {
                              dlocustdonbr = doSearch;
                              current_date = "";
                              await getJSONData();
                            } else {
                              dlocustdonbr = doSearch;
                              current_date = date;
                              await getJSONData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3.0,
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDMSMenuDO(dynamic item, int index) {
    var gps_name = item['vhcgps'] == null ||
        item['vhcgps'] == "" ||
        item['vhcgps'] == 'null'
        ? "[NO GPS VENDOR]"
        : '(${item['vhcgps'].toString()})';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header with BUJNBR
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.assignment, color: primaryOrange, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "BUJNBR: ${item['bujnbr']}",
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard("NOPOL", "${item['vhcid']}", Icons.directions_car, primaryOrange),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard("LOCID", "${item['locid']}", Icons.location_city, accentOrange),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // GPS Info
                _buildInfoCard("GPS", gps_name, Icons.gps_fixed, Colors.blue.shade400),
                SizedBox(height: 8),
                // Quantity Info
                _buildInfoCard("DLO UOM", "${item['dloitemuom']}, QTY: ${item['bujitemqty']}", Icons.inventory, Colors.green.shade400),
                SizedBox(height: 8),
                // DO Number
                _buildInfoCard("DLOCUSTDONBR", "${item['dlocustdonbr']}", Icons.receipt_long, Colors.purple[400]!),
                SizedBox(height: 8),
                // Origin and Destination
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard("ORIGIN", "${item['origin_name']}", Icons.place, Colors.green.shade400),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard("DESTINATION", "${item['destination_name']}", Icons.flag, Colors.red.shade400),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Status
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['bujstatus']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(item['bujstatus']).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: _getStatusColor(item['bujstatus']),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "STATUS: ${item['bujstatus']}",
                        style: TextStyle(
                          color: _getStatusColor(item['bujstatus']),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    label: Text("Close DO"),
                    onPressed: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      setState(() {
                        prefs.setString("bujnbrOPR", item['bujnbr']);
                        prefs.setString(
                            "dlocustdonbrOPR", item['dlocustdonbr']);
                        prefs.setString("advbujnbrOPR", item['bujnbr']);
                        prefs.setString("vhcidOPR", item['vhcid']);
                        prefs.setString("originOPR", item['idorigin']);
                        prefs.setString("origin_nameOPR", item['origin_name']);
                        prefs.setString(
                            "destinationOPR", item['iddestination']);
                        prefs.setString(
                            "destination_nameOPR", item['destination_name']);
                        prefs.setString("tarifuomOPR", item['dloitemuom']);
                        prefs.setString("qtyOPR", item['bujitemqty']);
                        prefs.setString("locidOPR", item['locid']);
                        prefs.setString("odometerOPR", item["bujinmtr"]);
                        prefs.setString("odometerOutOPR", item["bujoutmtr"]);
                        prefs.setString("imageDo", "");
                      });
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Loading...",
                                      style: TextStyle(
                                        color: darkOrange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                      Timer(Duration(seconds: 1), () {
                        // 5s over, navigate to a new page
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FrmCloseDoByOpr()));
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    label: Text("View"),
                    onPressed: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      var gpsName = item['vhcgps'].toString();
                      var vhCID = item['vhcid'].toString();
                      prefs.setString("page", "another");
                      var _tokens = "";
                      print(gpsName);
                      print(vhCID);
                      if (gpsName != "" &&
                          gpsName != null &&
                          gpsName != "null") {
                        if (gpsName
                            .toString()
                            .toLowerCase()
                            .replaceAll(" ", "") ==
                            "easygo") {
                          var tokenAuth = new GenerateTokenAuth();
                          _tokens = await tokenAuth.GetTokenEasyGo(
                              gpsName.toString(), pr!);
                          if (_tokens != "") {
                            setState(() {
                              prefs.setString("vhcgps", item['vhcgps']);
                              prefs.setString("vhcidOPR", item['vhcid']);
                              prefs.setString("tokeneasygo", _tokens);
                            });
                            await GetLastPositionFirst(_tokens, item['vhcid']); //"B 9646 YM/TR DP-2"
                            //await GetLastPositionFirst(_tokens,"B 9319 YU"); //"B 9646 YM/TR DP-2"
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
                            print("GPSN SN ${gps_sn}");
                            print("GPSN SN ${messageAPI}");
                            if (messageAPI == "200") {
                              prefs.remove("dataLast");
                              prefs.setStringList("dataLast", lstLast);
                            } else {
                              pr?.hide();
                              // alert(globalScaffoldKey.currentContext!, 0,
                              //     messageAPI, "error");
                              prefs.setStringList("dataLast", lstLast);
                            }
                            //print(lstLast);
                            var is_driver = 'false;';
                            if(prefs.getString("loginname")=="DRIVER"){
                              is_driver = 'true';
                            }
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LiveMaps(is_driver:is_driver)));
                          } else {
                            pr?.hide();
                            _showOrangeAlert(context, "Token Not Valid", "error");
                          }
                        }else{
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
                          prefs.setString("dlocustdonbrOPR", item['dlocustdonbr']);
                          prefs.setString("statusDlocustdonbrOPR", item['bujstatus']);
                          var is_driver = 'false;';
                          if(prefs.getString("loginname")=="DRIVER"){
                            is_driver = 'true';
                          }
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LiveMaps(is_driver:is_driver)));
                        }
                      } else {
                        pr?.hide();
                        _showOrangeAlert(context, "Gps Vendor name Kosong", "warning");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600
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

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green.shade600;
      case 'pending':
      case 'waiting':
        return Colors.orange.shade600;
      case 'cancelled':
      case 'cancel':
        return Colors.red.shade600;
      case 'in progress':
      case 'ongoing':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  getDataPreference() async {
    SharedPreferences resPreps = await SharedPreferences.getInstance();
    setState(() {
      arrayLocid = resPreps.getString("locid")!;
      if (arrayLocid.toString().split(",").length > 0) {
        arrayLocid = "ALL,$arrayLocid";
        arrLocid = arrayLocid.toString().split(",");
      } else {
        arrLocid = arrayLocid.toString().split(",");
      }
      print(arrLocid);
    });
  }

  @override
  void initState() {
    setState(() {
      _bujdate = TextEditingController(text: ""); //DateTime.now().toString()
      _search = TextEditingController(text: "");
      _search_vhcid = TextEditingController(text: "");
      dlocustdonbr = "";
      current_date = "";
    });
    getDataPreference();
    this.getJSONData();
    globals.locid = "";
    globals.vhcid = "";
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}