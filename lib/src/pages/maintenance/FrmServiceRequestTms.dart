import 'dart:async';
import 'dart:convert';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:http/http.dart' as http;
import '../../flusbar.dart';
import '../../../choices.dart' as choices;
import 'package:dms_anp/src/Helper/globals.dart' as globals;

var is_edit_req = false;
var srnumber = "";
String btnSubmitText = "Save Request";
List collectionDriver = [];
List collectionVehicle = [];
List listDriverId = [];
List listBanTms = [];
List listBanTmsQC = [];
List dummylistBanTms = [];
List dummylistBanTmsQC = [];
List listMechanicId = [];
List dummySearchList = [];
List dummySearchList2 = [];
List dummySearchListCabang = [];
List listVehicleId = [];
List dataSRType = [];
List listLocid = [];
List dummySearchListMcn = [];
TextEditingController txtDriverName = new TextEditingController();
TextEditingController txtVehicleName = new TextEditingController();
TextEditingController txtDriverIdList = new TextEditingController();
TextEditingController txtVehicleIdList = new TextEditingController();
TextEditingController txtCabangName = new TextEditingController();
TextEditingController txtCabangId = new TextEditingController();
TextEditingController txtSrType = new TextEditingController();
TextEditingController txtSrTypeId = new TextEditingController();

TextEditingController txtSearchCabangName = new TextEditingController();
TextEditingController txtSearchMechanic = new TextEditingController();
TextEditingController txtSearchDriver = new TextEditingController();
TextEditingController txtSearchVehicle = new TextEditingController();
TextEditingController txtNotesAlert = new TextEditingController();
TextEditingController txtWorkedBy = new TextEditingController();
TextEditingController txtWorkedById = new TextEditingController();

class _BottomSheetContentDriver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "List Driver",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // onChanged: (value) {
              //   //filterSearchResultsDriver(value);
              // },
              controller: txtSearchDriver,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listDriverId == null ? 0 : listDriverId.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtDriverName.text =
                          listDriverId[index]['title'].toString();
                      txtDriverIdList.text =
                          listDriverId[index]['value'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listDriverId[index]['title']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContentVehicle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "List Vehicle",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // onChanged: (value) {
              //   //filterSearchResultsDriver(value);
              // },
              controller: txtSearchVehicle,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listVehicleId == null ? 0 : listVehicleId.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtVehicleName.text =
                          listVehicleId[index]['title'].toString();
                      txtVehicleIdList.text =
                          listVehicleId[index]['value'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listVehicleId[index]['title']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContentCabang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "List Cabang",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: listLocid == null ? 0 : listLocid.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtCabangName.text = listLocid[index].toString();
                      txtCabangId.text = listLocid[index].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listLocid[index]}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContentMechanic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "List Mechanic",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // onChanged: (value) {
              //   //filterSearchResultsDriver(value);
              // },
              controller: txtSearchMechanic,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listMechanicId == null ? 0 : listMechanicId.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtWorkedById.text =
                          listMechanicId[index]['value'].toString();
                      txtWorkedBy.text =
                          listMechanicId[index]['title'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listMechanicId[index]['title']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContentTypeSR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Center(
              child: Text(
                "List Type Service",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: dataSRType == null ? 0 : dataSRType.length,
              itemBuilder: (context, index) {
                var icon = new Image.asset("assets/img/no-image.jpg",
                    height: 30.00, width: 30.00);
                var srType =
                    dataSRType[index]['id'].toString().replaceAll("\\s", "");
                if (srType == "BODY-REPAIRE" || srType == "BODY - REPAIRE") {
                  icon = new Image.asset('assets/img/body-repair.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "BOOKING") {
                  icon = new Image.asset('assets/img/booking.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "BAN-VELG" || srType == "BAN - VELG") {
                  icon = new Image.asset('assets/img/ban.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "REPAIR") {
                  icon = new Image.asset('assets/img/repair.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "KELENGKAPAN") {
                  icon = new Image.asset('assets/img/kelengkapan.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "SERVICE") {
                  icon = new Image.asset('assets/img/service.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "STORING") {
                  icon = new Image.asset('assets/img/storing.png',
                      height: 30.00, width: 30.00);
                } else {
                  icon = new Image.asset("assets/img/no-image.jpg",
                      height: 30.00, width: 30.00);
                }

                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtSrTypeId.text = dataSRType[index]['id'].toString();
                      txtSrType.text = dataSRType[index]['text'].toString();
                      print(txtSrTypeId.text);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: icon,
                        title: Text("${dataSRType[index]['text']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FrmServiceRequestTms extends StatefulWidget {
  @override
  _FrmServiceRequestTmsState createState() => _FrmServiceRequestTmsState();
}

class _FrmServiceRequestTmsState extends State<FrmServiceRequestTms>
    with SingleTickerProviderStateMixin {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  final String BASE_URL =
      GlobalData.baseUrl; // "http://apps.tuluatas.com:8080/trucking";
  int status_code = 0;
  int lengTabs = 2;
  var iShowLocid = false;
  String message = "";

  late TabController _tabController;
  TextEditingController txtVehicleId = new TextEditingController();
  TextEditingController txtDriverId = new TextEditingController();

  TextEditingController txtDate = new TextEditingController();
  TextEditingController txtSRNumber = new TextEditingController();
  TextEditingController txtStatus = new TextEditingController();
  TextEditingController txtFromLocid = new TextEditingController();
  TextEditingController txtToLocid = new TextEditingController();
  TextEditingController txtNotes = new TextEditingController();
  TextEditingController txtOrginalSn = new TextEditingController();
  TextEditingController txtWodNotes = new TextEditingController();
  TextEditingController txtWodCloseNotes = new TextEditingController();
  TextEditingController txtGenuino = new TextEditingController();
  TextEditingController txtApprNotes = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  //extEditingController txtSearchVehicle = new TextEditingController();
  TextEditingController txtSearchVehicleFinish = new TextEditingController();
  TextEditingController txtSearchVehicleTyreTms = new TextEditingController();
  TextEditingController txtSearchVehicleStart = new TextEditingController();
  TextEditingController txtSearchListBan = new TextEditingController();
  TextEditingController txtSearchListBanFinish = new TextEditingController();
  TextEditingController txtGenuinoFinish = new TextEditingController();
  List<S2Choice<String>> listStatusRequest = [];
  String _car = '';
  List dataListOprsStart = [];
  List dataListTyreTms = [];
  List dataListOprsFinish = [];
  List dataListOprsFinishDummy = [];
  List dataListOprsStartDummy = [];
  List dataListTmsTyreDummy = [];

  List dataListTyreFit = [];
  int _currentIndex = 0;
  String bSave = "Save Request";
  String bUpdate = "Update Request";

  String fnVHCID = '';
  String fnFITTYREID = '';
  String fnFITSERIALNO = '';
  String fnSTARTDATE = '';
  String fnSTARTKM = '0';
  String fnTYREBRAND = '';
  String fnTYREPATTERN = '';
  String fnTYREPRICE = '';
  String fnGENUINENO = '';
  String fnFitPost = '';
  String fnWONUMBER = '';
  String selFitPostIdFinish = '';

  _goBack(BuildContext context) {
    resetTeks();
    btnSubmitText = bSave;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void resetTeksFinish() {
    fnVHCID = '';
    fnFITTYREID = '';
    fnFITSERIALNO = '';
    fnSTARTDATE = '';
    fnSTARTKM = '0';
    fnTYREBRAND = '';
    fnTYREPATTERN = '';
    fnTYREPRICE = '';
    fnGENUINENO = '';
    fnFitPost = '';
    fnWONUMBER = '';
    selFitPostIdFinish = '';
    //List<String> collectionTyreFitFinish = [];
  }

  void resetTeks() {
    setState(() {
      status_code = 0;
      message = "";
      txtDate.text = "";
      txtSRNumber.text = "";
      txtKM.text = "0";
      txtWodNotes.text = "";
      txtWodCloseNotes.text = "";
      txtApprNotes.text = "";
      srnumber = "";
      txtNotesAlert.text = "";
      txtSrType.text = "";
      txtSrTypeId.text = "";
      txtDriverName.text = "";
      txtVehicleName.text = "";
      txtDriverIdList.text = "";
      txtVehicleIdList.text = "";
      txtCabangName.text = "";
      txtCabangId.text = "";
      txtSearchVehicle.text = "";
      txtSearchDriver.text = "";
      txtWorkedById.text = "";
      txtWorkedBy.text = "";
      txtNotes.text = "";
      txtWodNotes.text = "";
      txtSearchDriver.text = '';
      txtSearchVehicle.text = '';
      txtDriverName.text = '';
      is_edit_req = false;
    });
  }

  void _showModalListSR(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentTypeSR();
      },
    );
  }

  void _showModalListMechanic(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentMechanic();
      },
    );
  }

  void _showModalListDriver(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentDriver();
      },
    );
  }

  void _showModalListVehicle(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentVehicle();
      },
    );
  }

  void _showModalListCabang(BuildContext context) {
    if (is_edit_req == false) {
      showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return _BottomSheetContentCabang();
        },
      );
    }
  }

  Future getListMechanicStaff() async {
    Uri myUri = Uri.parse(
        "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=mechanic-list&jabatan=STAFF");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      print('loaded mechanic');
      setState(() {
        listMechanicId = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        dummySearchListMcn = listMechanicId;
      });
    } else {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal load data detail mechanic", "error");
    }
  }

  void getDriverById() async {
    try {
      var urlData =
          "${BASE_URL}api/maintenance/sr/list_driver.jsp?method=lookup-driver-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          print('loaded driver');
          listDriverId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchList = listDriverId;
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

  Future getListBanTMS(bool isload, String search) async {
    try {
      if (isload) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }

      var urlData = search == null || search == ''
          ? "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-ban-tms"
          : "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-ban-tms&search=${search}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listBanTms = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          print('loaded ban tms ${listBanTms.length}');
          dummylistBanTms = listBanTms;
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data detail ban", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data ban",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListTyreFit(bool isload, String wonumber) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-tyre-fit-by-wo&wonumber=${wonumber}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          dataListTyreFit = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list tyre fit", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data ban",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future DeleteTyreFit(bool isload, String wonumber, String id) async {
    try {
      if (isload) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }

      var urlData =
          "${BASE_URL}api/maintenance/sr/create_delete_tyre_fit.jsp?method=delete-item-fitpost-v1&wonumber=${wonumber}&id=${id}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        if (json.decode(response.body)["status_code"] == 200) {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          await showDialog(
            context: globalScaffoldKey.currentContext!,
            builder: (context) => new AlertDialog(
              title: new Text('Success'),
              content: new Text(json.decode(response.body)["message"]),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
          await Future.delayed(Duration(milliseconds: 1));
          await getListTyreFit(true, wonumber);
        } else {
          print(json.decode(response.body)["status_code"]);
          await Future.delayed(Duration(milliseconds: 1));
          await showDialog(
            context: globalScaffoldKey.currentContext!,
            builder: (context) => new AlertDialog(
              title: new Text('Alert'),
              content: new Text(json.decode(response.body)["message"]),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list tyre fit", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data ban",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListCabang() async {
    Uri myUri = Uri.parse(
        "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list_cabang");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      listLocid = json.decode(response.body);
      print(listLocid);
      if (listLocid.length == 0 && listLocid == []) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal Load data list cabang", "error");
      } else {
        listLocid = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        dummySearchListCabang = listLocid;
      }
    } else {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal Load data Type List Cabang", "error");
    }
  }

  Future getListSR() async {
    Uri myUri = Uri.parse(
        "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list_typeservice");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      dataSRType = json.decode(response.body);
      print(dataSRType);
      if (dataSRType.length == 0 && dataSRType == []) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal Load data Type Service", "error");
      } else {
        dataSRType = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
      }
    } else {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal Load data Type Service", "error");
    }
  }

  void getVehicleList(String cabangId) async {
    try {
      var urlData =
          "${BASE_URL}api/maintenance/sr/list_vehicle.jsp?method=lookup-vehicle-v1&locid=" +
              cabangId;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          listVehicleId = [];
          listVehicleId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchList2 = [];
          dummySearchList2 = listVehicleId;
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

  // void getLocidList() async {
  //   try {
  //     var urlData =
  //         "${BASE_URL}api/maintenance/sr/list_locid.jsp?method=lookup-locid-v1";
  //     var encoded = Uri.encodeFull(urlData);
  //     print(urlData);
  //     Uri myUri = Uri.parse(encoded);
  //     var response =
  //         await http.get(myUri, headers: {"Accept": "application/json"});
  //     setState(() {
  //       if (response.statusCode == 200) {
  //         listFrom = (jsonDecode(response.body) as List)
  //             .map((dynamic e) => e as Map<String, dynamic>)
  //             .toList();
  //         listTo = listFrom;
  //       } else {
  //         alert(globalScaffoldKey.currentContext!, 0,
  //             "Gagal load data detail vehcile", "error");
  //       }
  //     });
  //   } catch (e) {
  //     alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
  //         "error");
  //     print(e.toString());
  //   }
  // }

  void saveFitPost() async {
    print('save');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (fnVHCID == null || fnVHCID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (fnWONUMBER == null || fnWONUMBER == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "WONUMBER tidak boleh kosong", "error");
      } else if (fnGENUINENO == null || fnGENUINENO == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Genuine Number/Sn tidak boleh kosong", "error");
      } else if (fnFitPost == null || fnFitPost == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Fit POST tidak boleh kosong", "error");
      } else if (fnFITTYREID == null || fnFITTYREID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "ITEM ID tidak boleh kosong", "error");
      } else if (fnFITSERIALNO == null || fnFITSERIALNO == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "FIT Serial Number tidak boleh kosong", "error");
      } else if (fnSTARTKM == null || fnSTARTKM == "") {
        alert(globalScaffoldKey.currentContext!, 0, "KM tidak boleh kosong",
            "error");
      } else if (int.parse(fnSTARTKM) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "KM tidak boleh 1000",
            "error");
      } else if (fnTYREPRICE == null || fnTYREPRICE == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Price tidak boleh kosong",
            "error");
      } else if (int.parse(fnTYREPRICE) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "Price tidak boleh 1000",
            "error");
      } else {
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_delete_tyre_fit.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        //print('txtfitPost.text ${txtfitPost.text}');
        var data = {
          'method': "create-item-fitpost-v1",
          'wonumber': fnWONUMBER,
          'vhcid': fnVHCID,
          'fittyreid': fnFITTYREID,
          'fitserialno': fnFITSERIALNO,
          'startdate': fnSTARTDATE,
          'startkm': fnSTARTKM,
          'tyrebrand': fnTYREBRAND,
          'tyrepattern': fnTYREPATTERN,
          'tyreprice': fnTYREPRICE,
          'genuineno': fnGENUINENO,
          'fitpost': fnFitPost,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        print(data); //DEMO
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
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
                        resetTeksFinish();
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
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void saveRequestService() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var driverId = txtDriverIdList.text;
      var vehicleId = txtVehicleIdList.text;
      var status = "OPEN";
      var date = txtDate.text;
      var notes = txtNotes.text;
      var km = txtKM.text;
      var _txtSrType = txtSrType.text;
      var _typeSrId = txtSrTypeId.text;
      var locid = txtCabangId.text;

      if (is_edit_req == true && (srnumber == null || srnumber == "")) {
        //_tabController.animateTo(0);
        alert(globalScaffoldKey.currentContext!, 0,
            "SR Number tidak boleh kosong", "error");
      } else if (driverId == null || driverId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (vehicleId == null || vehicleId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (vehicleId == null || vehicleId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (status == null || status == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Status tidak boleh kosong",
            "error");
      } else if (is_edit_req == false && (locid == null || locid == "")) {
        alert(globalScaffoldKey.currentContext!, 0, "Locid tidak boleh kosong",
            "error");
      } else if (_typeSrId == null || _typeSrId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Service type tidak boleh kosong", "error");
      } else if (km == null || km == "") {
        alert(globalScaffoldKey.currentContext!, 0, "KM tidak boleh kosong",
            "error");
      } else if (int.parse(km) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "KM tidak boleh 1000",
            "error");
      } else {
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = is_edit_req == false
            ? 'create-request-sr-v1'
            : 'update-request-sr-v1';
        var data = {
          'method': method,
          'srnumber': srnumber,
          'vhcid': vehicleId,
          'drvid': driverId,
          'date': date,
          'status': status,
          'locid': locid,
          'userid': userid.toUpperCase(),
          'srTypeId': txtSrTypeId.text,
          'totalKM': txtKM.text,
          'notes': notes,
          'company': 'AN'
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
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
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void startRequestService(
      String stSRNumber,
      String wodWONBR,
      String workedby,
      String stVHCID,
      String stDRVID,
      String totalKM,
      String wodnotes,
      String _srTypeId) async {
    try {
      if (stSRNumber == null || stSRNumber == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "SR Number tidak boleh kosong", "error");
      } else if (stVHCID == null || stVHCID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (stDRVID == null || stDRVID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (workedby == null || workedby == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Mechanic ID tidak boleh kosong", "error");
      } else if (_srTypeId == null || _srTypeId == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Service ID tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'start-request-sr-v1';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'wodwonumber': wodWONBR,
          'woworkedby': workedby,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'totalKM': totalKM,
          'userid': userid.toUpperCase(),
          'wodnotes': wodnotes,
          'company': 'AN',
          "next": "approve",
          "srTypeId": _srTypeId,
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
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
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                        await getJSONData(true, '');
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
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void closeWoRequestService(
      String stSRNumber,
      String stWODNbr,
      String stVHCID,
      stDRVID,
      String woPrint,
      String wodNotes,
      String fittyreid,
      String fitserialno,
      String startdate,
      String startkm,
      String tyrebrand,
      String tyrepattern,
      String tyreprice,
      String genuino) async {
    try {
      if (stSRNumber == null || stSRNumber == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "SR Number tidak boleh kosong", "error");
      } else if (stWODNbr == null || stWODNbr == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "WOD Number tidak boleh kosong", "error");
      } else if (stVHCID == null || stVHCID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (stDRVID == null || stDRVID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else if (fittyreid == null || fittyreid == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "ID ITEMID tidak boleh kosong", "error");
      } else if (fitserialno == null || fitserialno == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Tyre Number tidak boleh kosong", "error");
      } else if (startdate == null || startdate == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Start Date tidak boleh kosong", "error");
      } else if (tyrebrand == null || tyrebrand == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Merk tidak boleh kosong",
            "error");
      } else if (tyrepattern == null || tyrepattern == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Item Alias boleh kosong",
            "error");
      } else if (tyreprice == null || tyreprice == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Price tidak boleh kosong",
            "error");
      } else if (startkm == null || startkm == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Start KM tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'close-request-tms-v3';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'wodnumber': stWODNbr,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'woprint': woPrint,
          'wodnotes': wodNotes,
          'fittyreid': fittyreid,
          'fitserialno': fitserialno,
          'startdate': startdate,
          'startkm': startkm,
          'tyrebrand': tyrebrand,
          'tyrepattern': tyrepattern,
          'tyreprice': tyreprice,
          'genuino': genuino,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
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
                        getJSONDataFinish(true, "");
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
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void updateSnTyre(String tyrenumber, original_sn, notes) async {
    try {
      if (tyrenumber == null || tyrenumber == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Tyre Number tidak boleh kosong", "error");
      }
      if (original_sn == null || original_sn == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "SN Tyre tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/update_tyre_number.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'update-sn-tyre-v1';
        var data = {
          'method': method,
          'tyrenumber': tyrenumber,
          'original_sn': original_sn,
          'userid': userid.toUpperCase(),
          'notes': notes,
          'company': 'AN'
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
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
                        getJSONDataTyre(true, "");
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
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void cancelRequestService(String stSRNumber, String stVHCID, stDRVID) async {
    try {
      if (stSRNumber == null || stSRNumber == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "SR Number tidak boleh kosong", "error");
      } else if (stVHCID == null || stVHCID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Vehicle ID tidak boleh kosong", "error");
      } else if (stDRVID == null || stDRVID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Driver ID tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'cancel-request-sr-v1';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
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
                        getJSONData(true, '');
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
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  var username = "";
  var userid = "";
  var locid = "";

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";
    userid = prefs.getString("name") ?? "";
    locid = prefs.getString("locid") ?? "";
    listLocid = locid.split(',');
    print(listLocid);
  }

  Future<String> getJSONData(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-tms-v1&search=" +
              search);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
      setState(() {
        // Get the JSON data
        dataListOprsStart = json.decode(response.body);
        print(dataListOprsStart);
        if (dataListOprsStart == null || dataListOprsStart.length == 0) {
          if (search == '' || search == null) {
            alert(globalScaffoldKey.currentContext!, 2,
                "Data Request TMS tidak di temukan", "error");
          }
        } else {
          dataListOprsStartDummy = dataListOprsStart;
        }
      });
    } catch (e) {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
    }
    return "Successfull";
  }

  Future<String> getJSONDataTyre(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-tire-tms-v1&search=" +
              search);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
      setState(() {
        // Get the JSON data
        dataListTyreTms = json.decode(response.body);
        print(dataListTyreTms);
        if (dataListTyreTms == null || dataListTyreTms.length == 0) {
          if (search == '' || search == null) {
            alert(globalScaffoldKey.currentContext!, 2,
                "Data Tyre TMS tidak di temukan", "error");
          }
        } else {
          dataListTmsTyreDummy = dataListTyreTms;
        }
      });
    } catch (e) {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
    }
    return "Successfull";
  }

  Future<String> getJSONDataFinish(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        EasyLoading.show();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-tms-finish-v1&search=" +
              search);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
      setState(() {
        // Get the JSON data
        //dataListOprsFinish = [];
        dataListOprsFinish = json.decode(response.body);
        if (dataListOprsFinishDummy.length == 0) {
          dataListOprsFinishDummy = dataListOprsFinish;
        }

        if (dataListOprsFinish == null || dataListOprsFinish.length == 0) {
          if (search != '' && search != null) {
            alert(globalScaffoldKey.currentContext!, 2,
                "Tidak ada data yang ditemukan", "warning");
          } else {}
        }
      });
    } catch (e) {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
    }
    return "Successfull";
  }

  // var isLoadData = false;
  // void _dateTimeChange() {
  //   if (txtDate.text != "" && txtDate.text != null) {
  //     if (username == "ADI" || username == "MAJID" || username == "ADMIN") {
  //       alert(globalScaffoldKey.currentContext!, 0,
  //           "Anda tidak dapat melakukan transaksi ini", "error");
  //     }else{
  //       if (isLoadData == false) {
  //         setState(() {
  //           getDriverById();
  //           getVehicleList();
  //           getLocidList();
  //           isLoadData = true;
  //         });
  //       }
  //     }
  //
  //   }
  // }

  void _searchMechanic() {
    List dummyListData2 = [];
    if (txtSearchMechanic.text != "" && txtSearchMechanic.text != null) {
      if (txtSearchMechanic.text.length >= 3) {
        for (var i = 0; i < dummySearchListMcn.length; i++) {
          var dtC = dummySearchListMcn[i]['title'].toLowerCase().toString();
          print("${dtC} => ${txtSearchMechanic.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchMechanic.text.toLowerCase().toString())) {
            print(dtC);
            dummyListData2.add({
              "value": dummySearchListMcn[i]['value'].toString(),
              "title": dummySearchListMcn[i]['title']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listMechanicId = [];
            listMechanicId = dummyListData2;
          });
        }
      }
      return;
    } else {
      setState(() {
        listMechanicId = dummySearchListMcn;
      });
    }
  }

  void _searchDriverName() {
    List dummyListData = [];
    if (txtSearchDriver.text != "" && txtSearchDriver.text != null) {
      if (txtSearchDriver.text.length >= 3) {
        for (var i = 0; i < dummySearchList.length; i++) {
          var dtC = dummySearchList[i]['title'].toLowerCase().toString();
          print(dtC.contains(txtSearchDriver.text));
          if (dtC.contains(txtSearchDriver.text.toLowerCase().toString())) {
            print(dtC);
            dummyListData.add({
              "value": dummySearchList[i]['value'].toString(),
              "title": dummySearchList[i]['title']
            });
          }
        }
      }
      if (dummyListData.length > 0) {
        if (mounted) {
          setState(() {
            listDriverId = [];
            listDriverId = dummyListData;
          });
        }
      }
      return;
    } //else {
    // print('else');
    // if (mounted) {
    //   if(listDriverId.length<=0){
    //     setState(() {
    //       listDriverId = [];
    //       listDriverId = dummySearchList;
    //     });
    //   }
    // }
    // return;
    //}
  }

  void _searchVehicleName() {
    List dummyListData2 = [];
    if (txtSearchVehicle.text != "" && txtSearchVehicle.text != null) {
      if (txtSearchVehicle.text.length >= 3) {
        for (var i = 0; i < dummySearchList2.length; i++) {
          var dtC = dummySearchList2[i]['value'].toLowerCase().toString();
          print("${dtC} => ${txtSearchVehicle.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchVehicle.text.toLowerCase().toString())) {
            print(dtC);
            dummyListData2.add({
              "value": dummySearchList2[i]['value'].toString(),
              "title": dummySearchList2[i]['title']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listVehicleId = [];
            listVehicleId = dummyListData2;
          });
        }
      }
      return;
    }
  }

  void _searchVehicleNameFinish() {
    if (txtSearchVehicleFinish.text != "" &&
        txtSearchVehicleFinish.text != null) {
      if (txtSearchVehicleFinish.text.length >= 3) {
        print(txtSearchVehicleFinish.text);
        getJSONDataFinish(false, txtSearchVehicleFinish.text);
      } else {
        dataListOprsFinish = dataListOprsFinishDummy;
        return;
      }
    } else {
      dataListOprsFinish = dataListOprsFinishDummy;
      return;
    }
  }

  void _searchVehicleNameStart() {
    if (txtSearchVehicleStart.text != "" &&
        txtSearchVehicleStart.text != null) {
      if (txtSearchVehicleStart.text.length >= 3) {
        print(txtSearchVehicleStart.text);
        getJSONData(false, txtSearchVehicleStart.text);
      } else {
        dataListOprsStart = dataListOprsStartDummy;
        return;
      }
    } else {
      dataListOprsStart = dataListOprsStartDummy;
      return;
    }
  }

  void _searchCabangName() {
    List dummyListData2 = [];
    if (txtSearchCabangName.text != "" && txtSearchCabangName.text != null) {
      if (txtSearchCabangName.text.length >= 3) {
        for (var i = 0; i < dummySearchList2.length; i++) {
          var dtC = dummySearchListCabang[i]['value'].toLowerCase().toString();
          print(
              "${dtC} => ${txtSearchCabangName.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchCabangName.text.toLowerCase().toString())) {
            print(dtC);
            dummyListData2.add({
              "value": dummySearchListCabang[i]['value'].toString(),
              "title": dummySearchListCabang[i]['title']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listLocid = [];
            listLocid = dummyListData2;
          });
        }
      }
      return;
    }
  }

  void _searchVehicleNameTyreTms() {
    if (txtSearchVehicleTyreTms.text != "" &&
        txtSearchVehicleTyreTms.text != null) {
      if (txtSearchVehicleTyreTms.text.length >= 3) {
        print(txtSearchVehicleTyreTms.text);
        getJSONDataTyre(false, txtSearchVehicleTyreTms.text);
      } else {
        dataListTyreTms = dataListTmsTyreDummy;
        return;
      }
    } else {
      dataListTyreTms = dataListTmsTyreDummy;
      return;
    }
  }

  void _loadDataVehicle() {
    if (txtCabangId.text != "" && txtCabangId.text != null) {
      if (txtCabangId.text.length > 3) {
        //listVehicleId = [];
        getVehicleList(txtCabangId.text);
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        // case 0:
        //   if(getAkses("OP") || username=="ADMIN"){
        //     Future.delayed(Duration(milliseconds: 50));
        //     setState(() {
        //       getJSONDataTyre(true, "");
        //     });
        //   }
        //   break;
        case 0:
          if (getAkses("TY") || username == "ADMIN") {
            Future.delayed(Duration(milliseconds: 50));
            setState(() {
              getJSONData(true, '');
            });
          }
          break;
        case 1:
          if (getAkses("TY") || username == "ADMIN") {
            Future.delayed(Duration(milliseconds: 50));
            setState(() {
              getJSONDataFinish(true, "");
            });
          }
          break;
      }
    }
  }

  bool getAkses(akses) {
    var isAkses = false;
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == akses);
    if (isOK != null) {
      if (isOK.length > 0) {
        isAkses = true;
      }
    }
    return isAkses;
  }

  @override
  void dispose() {
    _tabController.dispose();
    //txtSearchDriver.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //ANSR22006693
    _tabController = new TabController(vsync: this, length: lengTabs);

    setState(() {
      resetTeks();
      getSession();
      getListSR();
      getListCabang();
      getDriverById();
      getListMechanicStaff();
    });
    Future.delayed(Duration(milliseconds: 50));
    getJSONData(false, "");
    _tabController.addListener(_handleTabSelection);
    txtSearchDriver.addListener(_searchDriverName);
    txtSearchVehicle.addListener(_searchVehicleName);
    txtSearchVehicleFinish.addListener(_searchVehicleNameFinish);
    txtSearchVehicleStart.addListener(_searchVehicleNameStart);
    txtSearchVehicleTyreTms.addListener(_searchVehicleNameTyreTms);
    txtSearchMechanic.addListener(_searchMechanic);
    txtSearchCabangName.addListener(_searchCabangName);
    txtCabangId.addListener(_loadDataVehicle);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  //int selectedPage=1;
  //_RegisterNewDriverState(this.selectedPage);
  Widget _buildDListBanTmsFinish(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
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
                  "Tyre Number : ${item['tyrenumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("ID ItemID : ${item['iditemid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("PartName : ${item['partname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Genuino: ${item['genuino']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Merk: ${item['merk']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Item Alias: ${item['itmalias']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("ID Unit Cost: ${item['itdunitcost']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Original SN: ${item['original_sn']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("WH: ${item['wh']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
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
                buildButtonAddBanFinish(context, item),
                SizedBox(width: 10.0),
                buildButtonCancelBan(context)
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainerTyreFit(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount:
                      dataListTyreFit == null ? 0 : dataListTyreFit.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListTyreFit(dataListTyreFit[index], index);
                  }))
        ],
      ),
    );
  }

  Widget _buildDListTyreFit(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
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
                  "VHCID : ${item['vhcid']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("ITEMID : ${item['fittyreid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Tyre Number : ${item['fitserialno']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("CurDate: ${item['startdate']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("START KM: ${item['startkm']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "MERK/ ITMALIAS: ${item['tyrebrand']}/${item['tyrepattern']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("PRICE: ${item['tyreprice']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("SN/ GENUINENO: ${item['genuineno']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("FIT POST: ${item['fitpost']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
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
              child: Row(children: <Widget>[buildDeleteTyreFit(context, item)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDeleteTyreFit(BuildContext context, dynamic item) {
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.cancel,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Delete"),
      onPressed: () async {
        Navigator.of(globalScaffoldKey.currentContext!).pop(false);
        showDialog(
          context: globalScaffoldKey.currentContext!,
          builder: (context) => new AlertDialog(
            title: new Text('Information'),
            content: new Text("Delete this data?"),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24.0,
                ),
                label: Text("Close"),
                onPressed: () async {
                  //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                  Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24.0,
                ),
                label: Text("Delete"),
                onPressed: () async {
                  print('show');
                  Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                  //await Future.delayed(Duration(milliseconds: 1));
                  print(item['wonumber']);
                  print(item['id']);
                  if (item['id'] == '' || item['id'] == null) {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Id tidak boleh kosong", "warning");
                  } else if (item['wonumber'] == '' ||
                      item['wonumber'] == null) {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "WO NUMBER tidak boleh kosong", "warning");
                  } else {
                    await DeleteTyreFit(true, item['wonumber'], item['id']);
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.orangeAccent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ));
  }

  Widget setupAlertDialoadContainerFinish(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: txtSearchListBanFinish,
              onChanged: (value) async {
                if (value != '' && value != null) {
                  if (value.length > 2) {
                    await getListBanTMS(false, txtSearchListBanFinish.text);
                  }
                }
              },
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search partname/ ID...",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        if (txtSearchListBanFinish.text.length > 0) {
                          txtSearchListBanFinish.text = "";
                          listBanTms = [];
                          dummylistBanTms = [];
                          await getListBanTMS(true, '');
                        }
                      }),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)))),
            ),
          ),
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: listBanTms == null ? 0 : listBanTms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListBanTmsFinish(listBanTms[index], index);
                  }))
        ],
      ),
    );
    // return Container(
    //   height: MediaQuery.of(context).size.height, // Change as per your requirement
    //   width: MediaQuery.of(context).size.width, // Change as per your requirement
    //   child: ListView.builder(
    //     shrinkWrap: true,
    //     itemCount: listBanTms.length==0?0:listBanTms.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return _buildDListBanTms(
    //           listBanTms[index], index);
    //     },
    //   ),
    // );
  }

  Widget setupAlertDialoadContainer(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: txtSearchListBan,
              onChanged: (value) async {
                if (value != '' && value != null) {
                  if (value.length > 2) {
                    await getListBanTMS(false, txtSearchListBan.text);
                  }
                }
              },
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search partname/ ID...",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        txtSearchListBan.text = "";
                        listBanTms = [];
                        dummylistBanTms = [];
                        await getListBanTMS(true, '');
                      }),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)))),
            ),
          ),
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: listBanTms == null ? 0 : listBanTms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListBanTms(listBanTms[index], index);
                  }))
        ],
      ),
    );
    // return Container(
    //   height: MediaQuery.of(context).size.height, // Change as per your requirement
    //   width: MediaQuery.of(context).size.width, // Change as per your requirement
    //   child: ListView.builder(
    //     shrinkWrap: true,
    //     itemCount: listBanTms.length==0?0:listBanTms.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return _buildDListBanTms(
    //           listBanTms[index], index);
    //     },
    //   ),
    // );
  }

  Widget _buildListViewStart(BuildContext context) {
    if (getAkses("TY") || username == "ADMIN") {
      return SingleChildScrollView(
        //shrinkWrap: true,
        padding: EdgeInsets.all(2.0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: txtSearchVehicleStart,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search nopol/locid",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Container(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.all(5.0),
                    itemCount: dataListOprsStart == null
                        ? 0
                        : dataListOprsStart.length,
                    itemBuilder: (context, index) {
                      return _buildDListRequestOprsStart(
                          dataListOprsStart[index], index);
                    }))
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildListViewFinish(BuildContext context) {
    if (getAkses("TY") || username == "ADMIN") {
      return SingleChildScrollView(
          //shrinkWrap: true,
          padding: EdgeInsets.all(2.0),
          clipBehavior: Clip.antiAlias,
          //margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 5),
          //onRefresh: getJSONData,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                  controller: txtSearchVehicleFinish,
                  decoration: InputDecoration(
                      labelText: "Search",
                      hintText: "Search nopol/wo/sr number",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              Container(
                //padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.all(5.0),
                    itemCount: dataListOprsFinish == null
                        ? 0
                        : dataListOprsFinish.length,
                    itemBuilder: (context, index) {
                      return _buildDListRequestOprsFinish(
                          dataListOprsFinish[index], index);
                    }),
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _buildListViewTmsTyre(BuildContext context) {
    if (getAkses("TY") || username == "ADMIN") {
      return SingleChildScrollView(
          //shrinkWrap: true,
          padding: EdgeInsets.all(2.0),
          clipBehavior: Clip.antiAlias,
          //margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 5),
          //onRefresh: getJSONData,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                child: TextField(
                  controller: txtSearchVehicleTyreTms,
                  decoration: InputDecoration(
                      labelText: "Search",
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              Container(
                //padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.all(5.0),
                    itemCount:
                        dataListTyreTms == null ? 0 : dataListTyreTms.length,
                    itemBuilder: (context, index) {
                      return _buildDListRequestTmsTyre(
                          dataListTyreTms[index], index);
                    }),
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _buildDListRequestOprsStart(dynamic item, int index) {
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
                  "SR : ${item['srnumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text(
                      "SR DateTime : ${DateFormat("yyyy-MM-dd HH:mm:ss").parse(item['requestdate'], false)}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Original SR Number : ${item['orisrnumber']}",
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
                  Text("LOCID : ${item['srlocid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("DRV. NAME: ${item['drvname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Notes: ${item['srnotes']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          _ButtonListSr(globalScaffoldKey.currentContext!, item)
        ],
      ),
    );
  }

  Widget _ButtonListSr(BuildContext context, dynamic item) {
    if (getAkses("TY") || username == "ADMIN") {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
        child: Container(
          child: Row(children: <Widget>[
            Expanded(
                child: ElevatedButton.icon(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 15.0,
              ),
              label: Text("Cancel"),
              onPressed: () async {
                showDialog(
                  context: globalScaffoldKey.currentContext!,
                  builder: (context) => new AlertDialog(
                    title: new Text('Information'),
                    content: new Text("Cancel data ${item['srnumber']}"),
                    actions: <Widget>[
                      new TextButton(
                          onPressed: () {
                            Navigator.of(globalScaffoldKey.currentContext!)
                                .pop(false);
                          },
                          child: new Text('No')),
                      new TextButton(
                        onPressed: () async {
                          //_tabController.animateTo(0);
                          Navigator.of(globalScaffoldKey.currentContext!)
                              .pop(false);
                          cancelRequestService(
                              item['srnumber'], item['vhcid'], item['drvid']);
                          //
                        },
                        child: new Text('Ok'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )),
            SizedBox(width: 10),
            Expanded(
                child: ElevatedButton.icon(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
                size: 15.0,
              ),
              label: Text("Start"),
              onPressed: () async {
                showDialog(
                  context: globalScaffoldKey.currentContext!,
                  builder: (context) => new AlertDialog(
                    title: new Text('Information'),
                    content: new Text("Start data ${item['srnumber']}"),
                    actions: <Widget>[
                      new TextButton(
                          onPressed: () {
                            Navigator.of(globalScaffoldKey.currentContext!)
                                .pop(false);
                            resetTeks();
                          },
                          child: new Text('No')),
                      new TextButton(
                        onPressed: () async {
                          //_tabController.animateTo(0);
                          Navigator.of(globalScaffoldKey.currentContext!)
                              .pop(false);
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              //title: new Text('Start '),
                              //content: new Text("Cancel data ini?"),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                //position
                                mainAxisSize: MainAxisSize.min,
                                // wrap content in flutter
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(10.0),
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      style: TextStyle(
                                          color: Colors.grey.shade800),
                                      controller: txtWorkedBy,
                                      onTap: () {
                                        _showModalListMechanic(context);
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        labelText: "Mechanic ID",
                                        contentPadding: EdgeInsets.all(5.0),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(10.0),
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      style: TextStyle(
                                          color: Colors.grey.shade800),
                                      controller: txtWodNotes,
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
                                ],
                              ),
                              actions: <Widget>[
                                new TextButton(
                                    onPressed: () async {
                                      Navigator.of(
                                              globalScaffoldKey.currentContext!)
                                          .pop(false);
                                    },
                                    child: new Text('No')),
                                new TextButton(
                                  onPressed: () async {
                                    Navigator.of(
                                            globalScaffoldKey.currentContext!)
                                        .pop(false);
                                    showDialog(
                                      context:
                                          globalScaffoldKey.currentContext!,
                                      builder: (context) => new AlertDialog(
                                        title: new Text(
                                            'Information: Start this data?'),
                                        //content: new Text("Cancel data ini?"),

                                        actions: <Widget>[
                                          new TextButton(
                                              onPressed: () async {
                                                Navigator.of(globalScaffoldKey
                                                        .currentContext!)
                                                    .pop(false);
                                              },
                                              child: new Text('No')),
                                          new TextButton(
                                            onPressed: () async {
                                              Navigator.of(globalScaffoldKey
                                                      .currentContext!)
                                                  .pop(false);
                                              var workedby = txtWorkedById.text;
                                              print(txtWodNotes.text);
                                              startRequestService(
                                                  item['srnumber'],
                                                  item['wodwonbr'],
                                                  workedby,
                                                  item['vhcid'],
                                                  item['drvid'],
                                                  item['srkm'],
                                                  txtWodNotes.text,
                                                  item['srtypeid']);
                                            },
                                            child: new Text('Ok'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: new Text('Ok'),
                                ),
                              ],
                            ),
                          );
                          //
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
      );
    } else {
      return Container();
      // if (getAkses("TY") || username == "ADMIN") {
      //   return Container(
      //     width: MediaQuery.of(context).size.width,
      //     padding: EdgeInsets.all(10.0),
      //     decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
      //     child: Container(
      //       child: Row(children: <Widget>[
      //         Expanded(
      //             child: ElevatedButton.icon(
      //           icon: Icon(
      //             Icons.edit,
      //             color: Colors.white,
      //             size: 15.0,
      //           ),
      //           label: Text("Edit"),
      //           onPressed: () async {
      //             showDialog(
      //               context: globalScaffoldKey.currentContext!,
      //               builder: (context) => new AlertDialog(
      //                 title: new Text('Information'),
      //                 content: new Text("Edit data ${item['srnumber']}"),
      //                 actions: <Widget>[
      //                   new TextButton(
      //                       onPressed: () {
      //                         Navigator.of(globalScaffoldKey.currentContext!)
      //                             .pop(false);
      //                         resetTeks();
      //                       },
      //                       child: new Text('No')),
      //                   new TextButton(
      //                     onPressed: () async {
      //                       //_tabController.animateTo(0);
      //                       setState(() {
      //                         is_edit_req = true;
      //                         txtSRNumber.text = item['srnumber'];
      //                         txtDate.text = item['requestdate'];
      //                         txtSrType.text = item['srtypeiddesc'];
      //                         txtSrTypeId.text = item['srtypeid'];
      //                         txtDriverIdList.text = item['drvid'];
      //                         txtVehicleIdList.text = item['vhcid'];
      //                         txtVehicleName.text = item['vhcid'];
      //                         txtDriverName.text = item['drvname'];
      //                         txtNotes.text = item['srnotes'];
      //                         txtKM.text = item['srkm'];
      //                         srnumber = item['srnumber'];
      //                         txtCabangId.text = item['srlocid'];
      //                         btnSubmitText = bUpdate;
      //                       });
      //                       Navigator.of(globalScaffoldKey.currentContext!)
      //                           .pop(false);
      //                       await Future.delayed(Duration(milliseconds: 50));
      //                       _tabController.animateTo(0);
      //                       //
      //                     },
      //                     child: new Text('Ok'),
      //                   ),
      //                 ],
      //               ),
      //             );
      //           },
      //           style: ElevatedButton.styleFrom(
      //               elevation: 0.0,
      //               backgroundColor: Colors.orangeAccent,
      //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      //               textStyle:
      //                   TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      //         )),
      //       ]),
      //     ),
      //   );
      // } else {
      //   return Container();
      // }
    }
  }

  Widget _buildDListRequestOprsFinish(dynamic item, int index) {
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
                  "SR Number : ${item['srnumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("WO Number : ${item['wodwonbr']}",
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
                  Text("DRV. NAME: ${item['drvname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Notes: ${item['srnotes']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
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
                buildButtonApprove(context, item),
                SizedBox(width: 5),
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.details_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text("Detail List Ban"),
                  onPressed: () async {
                    showDialog(
                      context: globalScaffoldKey.currentContext!,
                      builder: (context) => new AlertDialog(
                        title: new Text('Information'),
                        content: new Text("Add/ view detail?"),
                        actions: <Widget>[
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text("Add"),
                            onPressed: () async {
                              //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                              Navigator.of(globalScaffoldKey.currentContext!)
                                  .pop(false);
                              await Future.delayed(Duration(seconds: 1));
                              fnVHCID = item['vhcid'];
                              fnSTARTKM = item['vhckm'];
                              fnWONUMBER = item['wodwonbr'];
                              await getListBanTMS(true, '');
                              showDialog(
                                  context: globalScaffoldKey.currentContext!,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('List Ban SR'),
                                      content: setupAlertDialoadContainerFinish(
                                          context),
                                    );
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text("View"),
                            onPressed: () async {
                              print('show');
                              // Navigator.of(context)
                              //     .pop(false);
                              // await Future.delayed(Duration(milliseconds: 1));
                              await getListTyreFit(true, item['wodwonbr']);
                              if (dataListTyreFit.length > 0) {
                                Navigator.of(context).pop(false);
                                await Future.delayed(Duration(milliseconds: 1));
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('List Item Tyre FIT'),
                                        content:
                                            setupAlertDialoadContainerTyreFit(
                                                context),
                                      );
                                    });
                              } else {
                                Navigator.of(context).pop(false);
                                await Future.delayed(Duration(milliseconds: 1));
                                alert(
                                    context,
                                    2,
                                    "tidak ada data yang di temukan",
                                    "warning");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDListBanTms(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
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
                  "Tyre Number : ${item['tyrenumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("ID ItemID : ${item['iditemid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("PartName : ${item['partname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Genuino: ${item['genuino']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Merk: ${item['merk']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Item Alias: ${item['itmalias']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("ID Unit Cost: ${item['itdunitcost']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Original SN: ${item['original_sn']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("WH: ${item['wh']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
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
                buildButtonAddBan(context, item),
                SizedBox(width: 10.0),
                buildButtonCancelBan(context)
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDListRequestTmsTyre(dynamic item, int index) {
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
                  "Tyre Number : ${item['tyrenumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Status : ${item['tyrestatus']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Po. Number : ${item['ponumber']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("IV. Number: ${item['ivnumber']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "Original SN: ${item['original_sn'] == null ? '[Not Set]' : item['original_sn']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
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
                buildButtonUpdateSn(context, item['tyrenumber']),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sizeBoxApprove(BuildContext context) {
    if (getAkses("TY") || username == "ADMIN") {
      return SizedBox(
        width: 10,
      );
    } else {
      return Container();
    }
  }

  var listItemApprove = [];
  Widget buildButtonApprove(BuildContext context, dynamic item) {
    if (getAkses("TY") || username == "ADMIN") {
      return Expanded(
          child: ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Approve"),
        onPressed: () async {
          print("dummylistBanTms.length");
          print(dummylistBanTms.length);
          if (dummylistBanTms.length == 0) {
            await getListBanTMS(true, '');
          }
          listItemApprove = [];
          listItemApprove = [
            item['srnumber'],
            item['wodwonbr'],
            item['vhcid'],
            item['drvid'],
            item['woprint'],
            item['vhckm']
          ];
          //item['srnumber'], item['wodwonbr'],
          //                     item['vhcid'], item['drvid'], item['woprint']
          //String appSrnumber,
          //       String wodNumber, String appVhcid, String appDrvid, String woPrint
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('List Ban TMS'),
                  content: setupAlertDialoadContainer(context),
                );
              });
        },
        style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ));
    } else {
      return Container();
    }
  }

  Widget buildButtonAddBan(BuildContext context, dynamic item) {
    if (getAkses("TY") || username == "ADMIN") {
      return Expanded(
          child: ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Pilih"),
        onPressed: () async {
          Navigator.of(globalScaffoldKey.currentContext!).pop(false);
          print(item['wh']);
          txtWodCloseNotes.text = "";
          txtGenuino.text = item['original_sn'] == null ||
                  item['original_sn'] == '' ||
                  item['original_sn'] == 'null'
              ? ''
              : item['original_sn'];
          if (listItemApprove.length > 0) {
            showDialog(
              context: globalScaffoldKey.currentContext!,
              builder: (context) => new AlertDialog(
                title: new Text('Information'),
                //content: new Text("Close WO data ${appSrnumber}"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //position
                  mainAxisSize: MainAxisSize.min,
                  // wrap content in flutter
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: Text("Close WO data ${listItemApprove[0]}"),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: TextField(
                        readOnly: true,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.grey.shade800),
                        controller: txtGenuino,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                          fillColor: Colors.yellow,
                          filled: true,
                          isDense: true,
                          labelText: "GENUINENO/ SN BAN",
                          contentPadding: EdgeInsets.all(5.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: TextField(
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.grey.shade800),
                        controller: txtWodCloseNotes,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          labelText: "Notes...",
                          contentPadding: EdgeInsets.all(5.0),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  new TextButton(
                      onPressed: () {
                        Navigator.of(globalScaffoldKey.currentContext!)
                            .pop(false);
                        resetTeks();
                      },
                      child: new Text('No')),
                  new ElevatedButton.icon(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Finish"),
                      onPressed: () async {
                        Navigator.of(globalScaffoldKey.currentContext!)
                            .pop(false);
                        print(item['tyrenumber']);
                        print(listItemApprove[0]);
                        //TBLTYREFIT = SNTYRE_STATUS
                        var fittyreid = item['iditemid'];
                        var fitserialno = item['tyrenumber'];
                        var startdate = item['curdate'];
                        var startkm = listItemApprove[
                            5]; //KM MOBIL TERAKHIR (TBLVEHICLE/VHCKM)
                        var tyrebrand = item['merk'];
                        var tyrepattern = item['itmalias'];
                        var tyreprice = item['itdunitcost'];
                        var genuino = item['original_sn'];
                        closeWoRequestService(
                            listItemApprove[0],
                            listItemApprove[1],
                            listItemApprove[2],
                            listItemApprove[3],
                            listItemApprove[4],
                            txtWodCloseNotes.text,
                            fittyreid,
                            fitserialno,
                            startdate,
                            startkm,
                            tyrebrand,
                            tyrepattern,
                            tyreprice,
                            genuino);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold))),
                ],
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ));
    } else {
      return Container();
    }
  }

  Widget buildButtonAddBanFinish(BuildContext context, dynamic item) {
    txtGenuinoFinish.text = item["original_sn"] == null ||
            item["original_sn"] == '' ||
            item["original_sn"] == 'null'
        ? ''
        : item["original_sn"];
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.save,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Pilih Item"),
      onPressed: () async {
        print(item['iditemid']);
        Navigator.of(globalScaffoldKey.currentContext!).pop(false);
        fnFITTYREID = item['iditemid'];
        fnFITSERIALNO = item['tyrenumber'];
        fnSTARTDATE = item['curdate'];
        //fnSTARTKM = '0';
        fnTYREBRAND = item['merk'];
        fnTYREPATTERN = item['itmalias'];
        fnTYREPRICE = item['itdunitcost'];
        //fnGENUINENO = '';
        //fnFitPost = '';
        //fnWONUMBER='';
        await Future.delayed(Duration(seconds: 1));
        print(
            "${fnFITTYREID},${fnFITSERIALNO},${fnSTARTDATE},${fnSTARTKM},${fnTYREBRAND},${fnTYREPATTERN},${fnTYREPRICE},${fnGENUINENO},${fnFitPost},${fnWONUMBER}");
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            scrollable: true,
            title: new Text('Information'),
            //content:
            //new Text("Save new request service?"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              // wrap content in flutter
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 5, bottom: 0.0, left: 10, right: 10),
                  child: Text("Tyre Number : ${item['tyrenumber']}",
                      style: TextStyle(color: Colors.black)),
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: 5, bottom: 0.0, left: 10, right: 10),
                  child: Text(
                      "Part Name : ${item['partname']}- ${item['merk']}",
                      style: TextStyle(color: Colors.black)),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextField(
                    readOnly: false,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtGenuinoFinish,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      fillColor: Colors.yellow,
                      filled: true,
                      isDense: true,
                      labelText: "GENUINENO/ SN BAN",
                      contentPadding: EdgeInsets.all(5.0),
                    ),
                  ),
                ),
                SmartSelect<String?>.single(
                  title: 'FIT POST',
                  selectedValue: selFitPostIdFinish,
                  onChange: (selected) {
                    setState(() => selFitPostIdFinish = selected.value!);
                  },
                  choiceType: S2ChoiceType.radios,
                  choiceItems: choices.collFitPost,
                  modalType: S2ModalType.popupDialog,
                  modalHeader: false,
                  modalConfig: const S2ModalConfig(
                    style: S2ModalStyle(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("Save"),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  if (getAkses("TY") || username == "ADMIN") {
                    fnGENUINENO = txtGenuinoFinish.text;
                    fnFitPost = selFitPostIdFinish;
                    print(
                        "${fnFITTYREID},${fnFITSERIALNO},${fnSTARTDATE},${fnSTARTKM},${fnTYREBRAND},${fnTYREPATTERN},${fnTYREPRICE},${fnGENUINENO},${fnFitPost},${fnWONUMBER}");
                    saveFitPost();
                  } else {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Anda tidak dapat melakukan transaksi ini", "error");
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ));
  }

  Widget buildButtonCancelBan(BuildContext context) {
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.cancel,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Cancel"),
      onPressed: () async {
        listItemApprove = [];
        dummylistBanTms = [];
        txtWodCloseNotes.text = "";
        txtGenuino.text = "";
        Navigator.of(globalScaffoldKey.currentContext!).pop(false);
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.orangeAccent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ));
  }

  Widget buildButtonUpdateSn(BuildContext context, String tyrenumber) {
    print("username ${username}");
    if (getAkses("TY") || username == "ADMIN") {
      return Expanded(
          child: ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Update SN"),
        onPressed: () async {
          showDialog(
            context: globalScaffoldKey.currentContext!,
            builder: (context) => new AlertDialog(
              title: new Text('Information'),
              //content: new Text("Close WO data ${appSrnumber}"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //position
                mainAxisSize: MainAxisSize.min,
                // wrap content in flutter
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Text("Update SN ${tyrenumber}"),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtOrginalSn,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        isDense: true,
                        labelText: "Set original SN",
                        contentPadding: EdgeInsets.all(5.0),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                new TextButton(
                    onPressed: () {
                      Navigator.of(globalScaffoldKey.currentContext!)
                          .pop(false);
                      resetTeks();
                    },
                    child: new Text('No')),
                new ElevatedButton.icon(
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Update"),
                    onPressed: () async {
                      Navigator.of(globalScaffoldKey.currentContext!)
                          .pop(false);
                      updateSnTyre(tyrenumber, txtOrginalSn.text, "");
                      txtOrginalSn.text = "";
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ));
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        }
      },
      child: DefaultTabController(
        length: lengTabs,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(globalScaffoldKey.currentContext!);
              },
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), // Creates border
                  color: Colors.black38),
              tabs: [
                //Tab(icon: Icon(Icons.car_repair), child: Text('List Tire')),
                Tab(icon: Icon(Icons.list), child: Text('List TMS')),
                Tab(icon: Icon(Icons.list), child: Text('Finish TMS')),
              ],
            ),
            title: Text('TMS Service Request'),
          ),
          body: TabBarView(
            key: globalScaffoldKey,
            controller: _tabController,
            children: [
              //_buildListViewTmsTyre(context),
              _buildListViewStart(context),
              _buildListViewFinish(context),
            ],
          ),
        ),
      ),
    );
  }
}
