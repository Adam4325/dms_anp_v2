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

class _BottomSheetContentVehicle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                "List Vehicle",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: txtSearchVehicle,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                labelText: "Search Vehicle",
                contentPadding: EdgeInsets.all(5.0),
              ),
            ),
          ),

          // Vehicle List
          Expanded(
            child: ListView.builder(
              itemCount: listVehicleId.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Icon(
                        Icons.directions_car,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      title: Text(
                        "${listVehicleId[index]['title']}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.kTextColor,
                        ),
                      ),
                      subtitle: Text(
                        "Vehicle ID: ${listVehicleId[index]['value']}",
                        style: TextStyle(
                          color: ColorConstants.kGreyTextColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        txtVehicleName.text =
                            listVehicleId[index]['value'].toString();
                        txtVehicleIdList.text =
                            listVehicleId[index]['value'].toString();
                      },
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
    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
          return Future.value(false);
        },
        child: Scaffold(
          key: globalScaffoldKey,
          backgroundColor: Colors.orange,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            title: Text("Search History Nopol"),
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
                    color: Theme.of(context).colorScheme.primary,
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
              cursorColor: Theme.of(context).colorScheme.primary,
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
                        Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Search History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.kTextColor,
                          ),
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
                          color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.primary,
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
                        cursorColor: Theme.of(context).colorScheme.primary,
                        style: TextStyle(color: ColorConstants.kTextColor),
                        controller: txtVehicleName,
                        onTap: () {
                          _showModalListVehicle(context);
                        },
                        decoration: InputDecoration(
                          labelText: "Pilih Kendaraan",
                          hintText: "Tap untuk memilih kendaraan",
                          prefixIcon: Icon(
                            Icons.directions_car,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: ColorConstants.ktextFieldBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2),
                          ),
                          filled: true,
                          fillColor: ColorConstants.kWhiteColor,
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
