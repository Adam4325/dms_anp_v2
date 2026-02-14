import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;
import 'package:http/http.dart' as http;
import '../../flusbar.dart';

class FrmRequestMovingUnitsOld extends StatefulWidget {
  @override
  _FrmRequestMovingUnitsOldState createState() => _FrmRequestMovingUnitsOldState();
}

class _FrmRequestMovingUnitsOldState extends State<FrmRequestMovingUnitsOld>
    with SingleTickerProviderStateMixin {

  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  final String BASE_URL =
      GlobalData.baseUrl; // "http://apps.tuluatas.com:8080/trucking";
  int status_code = 0;
  int lengTabs = 2;

  var is_edit_req = false;
  var driver_id_req = "";
  var vhcid_req = "";
  var date_req = "";
  var notes_req = "";
  var status_req = "";
  var locid_to_req = "";
  var locid_from_req = "";
  String message = "";
  String btnSubmitText = "Save Request";
  late TabController _tabController;
  TextEditingController txtVehicleId = new TextEditingController();
  TextEditingController txtDriverId = new TextEditingController();
  TextEditingController txtDate = new TextEditingController();
  TextEditingController txtStatus = new TextEditingController();
  TextEditingController txtFromLocid = new TextEditingController();
  TextEditingController txtToLocid = new TextEditingController();
  TextEditingController txtNotes = new TextEditingController();
  List<S2Choice<String>> listStatusRequest = [];
  String _car = '';
  List dataMovingUnits = [];
  List<String> _smartphone = [];

  String selDriverId = '';
  String selVehicleId = '';
  String selStatus = '';
  String selFrom = '';
  String selTo = '';
  String _dateRequest = '';
  List<Map<String, dynamic>> listDriverId = [];
  List<Map<String, dynamic>> listVehicleId = [];
  List<Map<String, dynamic>> listFrom = [];
  List<Map<String, dynamic>> listTo = [];
  int _currentIndex = 0;
  String bSave = "Save Request";
  String bUpdate = "Update Request";
  List<Map<String, dynamic>> lstVheicleType = [];
  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void resetTeks() {
    setState(() {
      status_code = 0;
      message = "";
      txtVehicleId.text = "";
      txtDriverId.text = "";
      txtDate.text = "";
      txtStatus.text = "";
      txtFromLocid.text = "";
      txtToLocid.text = "";
      txtNotes.text = "";

      is_edit_req = false;
      driver_id_req = "";
      vhcid_req = "";
      date_req = "";
      notes_req = "";
      status_req = "";
      locid_to_req = "";
      locid_from_req = "";

      selDriverId = '';
      selVehicleId = '';
      selStatus = '';
      selFrom = '';
      selTo = '';
      _dateRequest = '';
    });
  }

  void getDriverById() async {
    try {
      var urlData = "${BASE_URL}api/gt/list_driver.jsp?method=lookup-driver-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          listDriverId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data detail driver", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
          "error");
      print(e.toString());
    }
  }

  void getVehicleList() async {
    try {
      var urlData =
          "${BASE_URL}api/gt/list_vehicle.jsp?method=lookup-vehicle-v1";
      var encoded = Uri.encodeFull(urlData);
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
              "Gagal load data detail vehcile", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
          "error");
      print(e.toString());
    }
  }

  void getLocidList() async {
    try {
      var urlData = "${BASE_URL}api/gt/list_locid.jsp?method=lookup-locid-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          listFrom = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          listTo = listFrom;
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data detail vehcile", "error");
        }
      });
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
          "error");
      print(e.toString());
    }
  }

  void updateRequestMoving() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var driverId = selDriverId;
      var vehicleId = selVehicleId;
      var status = selStatus;
      var dateRequest = _dateRequest;
      var notes = txtNotes.text;
      if (dateRequest == null || dateRequest == "") {
        //_tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Date Request tidak boleh kosong", "error");
      } else if (driverId == null || driverId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (vehicleId == null || vehicleId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (txtVehicleId == null || txtVehicleId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (status == null || status == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Status tidak boleh kosong",
            "error");
      } else {
        print('SUKSES ${dateRequest}-${driverId}-${vehicleId}-${notes}');
        // await pr.show();
        // var encoded = Uri.encodeFull("${BASE_URL}api/gt/createorupdate.jsp");
        // print(encoded);
        // Uri urlEncode = Uri.parse(encoded);
        // var data = {
        //   'method': 'update-request-gt-v1',
        //   'drvid': driverId,
        //   'vehicleid': vehicleId,
        //   'date': dateRequest,
        //   'status': status,
        //   'note': notes
        // };
        // final response = await http.post(
        //   urlEncode,
        //   body: data,
        //   headers: {
        //     "Content-Type": "application/x-www-form-urlencoded",
        //   },
        //   encoding: Encoding.getByName('utf-8'),
        // );
        // print(response.body);
        // if (pr.isShowing()) {
        //   await pr.hide();
        // }
        // setState(() {
        //   if (response.statusCode == 200) {
        //     status_code = json.decode(response.body)["status_code"];
        //     message = json.decode(response.body)["message"];
        //     print(response);
        //     if (status_code == 200) {
        //       showDialog(
        //         context: globalScaffoldKey.currentContext!,
        //         builder: (context) => new AlertDialog(
        //           title: new Text('Information'),
        //           content: new Text("$message"),
        //           actions: <Widget>[
        //             new ElevatedButton.icon(
        //               icon: Icon(
        //                 Icons.info,
        //                 color: Colors.white,
        //                 size: 24.0,
        //               ),
        //               label: Text("Ok"),
        //               onPressed: () {
        //                 Navigator.of(context, rootNavigator: true).pop();
        //                 resetTeks();
        //                 _tabController.animateTo(0);
        //               },
        //               style: ElevatedButton.styleFrom(
        //                   elevation: 0.0,
        //                   backgroundColor: Colors.blue,
        //                   padding:
        //                   EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        //                   textStyle: TextStyle(
        //                       fontSize: 12, fontWeight: FontWeight.bold)),
        //             ),
        //           ],
        //         ),
        //       );
        //     } else {
        //       alert(globalScaffoldKey.currentContext!, 0,
        //           "Gagal menyimpan ${message}", "error");
        //     }
        //   } else {
        //     alert(globalScaffoldKey.currentContext!, 0,
        //         "Gagal menyimpan ${response.statusCode}", "error");
        //   }
        // });
      }
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, Gagal Update Data",
          "error");
      print(e.toString());
    }
  }

  void saveRequestMoving() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var driverId = selDriverId;
      var vehicleId = selVehicleId;
      var status = selStatus;
      var dateRequest = _dateRequest;
      var notes = txtNotes.text;
      if (dateRequest == null || dateRequest == "") {
        //_tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "Date Request tidak boleh kosong", "error");
      } else if (driverId == null || driverId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (vehicleId == null || vehicleId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (txtVehicleId == null || txtVehicleId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (status == null || status == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Status tidak boleh kosong",
            "error");
      } else {
        print('SUKSES ${dateRequest}-${driverId}-${vehicleId}-${notes}');
        if(!EasyLoading.isShow){
          EasyLoading.show();
        }
        var encoded = Uri.encodeFull("${BASE_URL}api/gt/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'create-request-gt-v1',
          'drvid': driverId,
          'vehicleid': vehicleId,
          'date': dateRequest,
          'status': status,
          'note': notes
        };
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if(EasyLoading.isShow){
          EasyLoading.dismiss();
        }
        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(response);
            if (status_code == 200) {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                        _tabController.animateTo(0);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blue,
                          padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } else {
              alert(globalScaffoldKey.currentContext!, 0,
                  "Gagal menyimpan ${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "Gagal menyimpan ${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (pr!.isShowing()) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, Gagal Menyimpan Data",
          "error");
      print(e.toString());
    }
  }

  void getSession() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var drvID = prefs.getString("driver_id_req");
    // var isEditReq = prefs.getBool("is_edit_req");
    if (is_edit_req == false || is_edit_req == null) {
      if (choices.listStatusRequest.length > 0) {
        listStatusRequest = [S2Choice<String>(value: 'OPEN', title: 'OPEN')];
        btnSubmitText = bSave;
      } else {
        listStatusRequest = [];
        listStatusRequest = choices.listStatusRequest;
        btnSubmitText = bUpdate;
      }
    }
  }

  Future<String> getJSONData(bool isloading) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        if (pr?.isShowing() == false) {
          await pr?.show();
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/gt/list_data_moving.jsp?method=lookup-list-moving-v1");
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      if (isloading == true) {
        if (pr?.isShowing() == true) {
          await pr?.hide();
        }
      }
      setState(() {
        // Get the JSON data
        dataMovingUnits = json.decode(response.body);
        if (dataMovingUnits == null || dataMovingUnits.length == 0) {
          alert(globalScaffoldKey.currentContext!, 0,
              "Data Request Moving tidak di temukan", "error");
        }
      });
    } catch (e) {
      if (isloading == true) {
        if (pr?.isShowing() == true) {
          await pr?.hide();
        }
      }
    }
    return "Successfull";
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 1:
          setState(() {
            if (dataMovingUnits == null || dataMovingUnits.length == 0) {
              getJSONData(true);
            }
          });
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //1
    super.initState();
    _tabController = new TabController(vsync: this, length: lengTabs);
    setState(() {
      getDriverById();
      getVehicleList();
      getLocidList();
      getSession();
    });
    _tabController.addListener(_handleTabSelection);
  }

  //int selectedPage=1;
  //_RegisterNewDriverState(this.selectedPage);
  Widget _buildListView(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 5),
        //onRefresh: getJSONData,
        child: ListView.builder(
            padding: const EdgeInsets.all(5.0),
            itemCount: dataMovingUnits == null ? 0 : dataMovingUnits.length,
            itemBuilder: (context, index) {
              return _buildDListMovingUnits(dataMovingUnits[index], index);
            }));
  }

  Widget _buildDListMovingUnits(dynamic item, int index) {
    //print(value["drvid"]);
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.black45))),
                  child: Icon(Icons.settings_applications, color: Colors.black),
                ),
                title: Text(
                  "GT. Numnber : ${item['gtnumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Date : ${item['gtdate']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("VHCID : ${item['vhcid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("STATUS: ${item['gtstatus']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("GT. TUJUAN: ${item['gttujuan']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("LOCID: ${item['locid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("NOTES: ${item['gtnotes']}",
                      style: TextStyle(color: Colors.black)),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Select"),
                      onPressed: () async {
                        showDialog(
                          context: globalScaffoldKey.currentContext!,
                          builder: (context) => new AlertDialog(
                            title: new Text('Information'),
                            content: new Text("Approve"),
                            actions: <Widget>[
                              new TextButton(
                                  onPressed: () {
                                    Navigator.of(globalScaffoldKey.currentContext!)
                                        .pop(false);
                                    resetTeks();
                                  },
                                  child: new Text('No')),
                              new TextButton(
                                onPressed: ()  async{
                                  Navigator.of(globalScaffoldKey.currentContext!)
                                      .pop(false);
                                  _tabController.animateTo(0);

                                  setState(() {
                                    is_edit_req = true;
                                    driver_id_req = item['drvid'];
                                    vhcid_req = item['vhcid'];
                                    date_req = item['gtdate'];
                                    notes_req = item['gtnotes'];
                                    locid_to_req = item['locid'];
                                    locid_from_req = item['locid_from'];
                                    status_req = item['gtstatus'];

                                    selDriverId = driver_id_req;
                                    selVehicleId = vhcid_req;
                                    txtNotes.text = notes_req;
                                    txtDate.text = date_req;
                                    selTo = locid_to_req;
                                    selFrom = locid_from_req;
                                    selStatus = status_req;
                                    print(selDriverId);
                                    print(selVehicleId);
                                    print(selTo);
                                    print(selFrom);
                                    print(selStatus);
                                    btnSubmitText = bUpdate;
                                  });
                                },
                                child: new Text('Ok'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blueAccent,
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
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

    return DefaultTabController(
      length: lengTabs,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () {
              _goBack(context);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(5), // Creates border
                color: Colors.black38),
            tabs: [
              Tab(icon: Icon(Icons.car_repair), child: Text('Moving Units')),
              Tab(icon: Icon(Icons.list), child: Text('List Request')),
            ],
          ),
          title: Text('Request Moving Units'),
        ),
        body: TabBarView(
          key: globalScaffoldKey,
          controller: _tabController,
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.blue, spreadRadius: 1),
                ],
              ),
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: DateTimePicker(
                        //type: DateTimePickerType.dateTime,
                        dateMask: 'yyyy-MM-dd',
                        controller: txtDate,
                        //initialValue: _initialValue,
                        // use24HourFormat: true,
                        // locale: Locale('en', 'US'),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'Date',
                        selectableDayPredicate: (date) {
                          return true;
                        },
                        onChanged: (val) => setState(() => _dateRequest = val),
                        validator: (val) {
                          setState(() => _dateRequest = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _dateRequest = val ?? ''),
                      ),
                    ),
                    SmartSelect<String?>.single(
                      title: 'Driver Name',
                      selectedValue: selDriverId,
                      placeholder: 'Select',
                      onChange: (selected) => setState(() => selDriverId = selected.value!),
                      // onChange: (selected) =>
                      //     setState(() => selDriverId = selected.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                          source: listDriverId,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['title']),
                      //choiceGrouped: true,
                      modalFilter: true,
                      modalFilterAuto: true,
                    ),
                    SmartSelect<String?>.single(
                      title: 'Vehciel ID',
                      selectedValue: selVehicleId,
                      placeholder: 'Select',
                      onChange: (selected) =>
                          setState(() => selVehicleId = selected.value!),
                      choiceItems: S2Choice.listFrom<String, Map>(
                          source: listVehicleId,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['title']),
                      //choiceGrouped: true,
                      modalFilter: true,
                      modalFilterAuto: true,
                    ),
                    SmartSelect<String?>.single(
                      title: 'Status',
                      selectedValue: selStatus,
                      onChange: (selected) {
                        setState(() => selStatus = selected.value!);
                      },
                      choiceType: S2ChoiceType.radios,
                      choiceItems: listStatusRequest,
                      modalType: S2ModalType.popupDialog,
                      modalHeader: false,
                      modalConfig: const S2ModalConfig(
                        style: S2ModalStyle(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                      ),
                    ),
                    SmartSelect<String?>.single(
                      title: 'From',
                      selectedValue: selFrom,
                      onChange: (selected) {
                        setState(() => selFrom = selected.value!);
                      },
                      choiceType: S2ChoiceType.radios,
                      choiceItems: S2Choice.listFrom<String, Map>(
                          source: listFrom,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['title']),
                      modalType: S2ModalType.popupDialog,
                      modalHeader: false,
                      modalConfig: const S2ModalConfig(
                        style: S2ModalStyle(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                      ),
                    ),
                    SmartSelect<String?>.single(
                      title: 'Moving To',
                      selectedValue: selTo,
                      onChange: (selected) {
                        setState(() => selTo = selected.value!);
                      },
                      choiceType: S2ChoiceType.radios,
                      choiceItems: S2Choice.listFrom<String, Map>(
                          source: listTo,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['title']),
                      modalType: S2ModalType.popupDialog,
                      modalHeader: false,
                      modalConfig: const S2ModalConfig(
                        style: S2ModalStyle(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: TextField(
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.grey.shade800),
                        controller: txtNotes,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          labelText: "Notes",
                          contentPadding: EdgeInsets.all(5.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 10, top: 0, right: 10, bottom: 0),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("Cancel"),
                              onPressed: () async {
                                resetTeks();
                                setState(() {
                                  btnSubmitText = bSave;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            )),
                        SizedBox(width: 10),
                        Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text(btnSubmitText),
                              onPressed: () async {
                                if (is_edit_req != null && is_edit_req == true) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                      title: new Text('Information'),
                                      content: new Text(bUpdate),
                                      actions: <Widget>[
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          label: Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor: Colors.red,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 0),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.save,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          label: Text("Ok"),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                            // var driverID =
                                            //     prefs.getString("driver_id_req");
                                            //updateRequestMoving(driverID);
                                            //
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor: Colors.blue,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 0),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                  print('Update');
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                      title: new Text('Information'),
                                      content:
                                      new Text("Save new request moving units"),
                                      actions: <Widget>[
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          label: Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor: Colors.red,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 0),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.save,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          label: Text("Ok"),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                            saveRequestMoving();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor: Colors.blue,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 0),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                  print('save');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            )),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            _buildListView(context),
          ],
        ),
      ),
    );
  }
}
