import 'dart:async';
import 'dart:convert';
import 'package:dms_anp/helpers/database_helper.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/tire/tire_lt.dart';
import 'package:dms_anp/src/pages/tire/tire_triller.dart';
import 'package:dms_anp/src/pages/tire/tire_tronton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../flusbar.dart';
import '../../../../choices.dart' as choices;
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

String selKatalog = "";
var nama_katalog = '';
var isCreatePrNumber = false;
String METHOD_DETAIL = '';
TextEditingController txtPrNumber = new TextEditingController();
TextEditingController txtOpnameVHCID = new TextEditingController();
TextEditingController txtOpnameWONUMBER = new TextEditingController();
TextEditingController txtPartName = new TextEditingController();
TextEditingController txtItemID = new TextEditingController();
TextEditingController txtItemSize = new TextEditingController();
TextEditingController txtTypeID = new TextEditingController();
TextEditingController txtTypeAccess = new TextEditingController();
TextEditingController txtGenuineNoOpname = new TextEditingController();
TextEditingController txtOpnameMerk = new TextEditingController();
TextEditingController txtSearchPartname = new TextEditingController();
TextEditingController txtOpnameQty = new TextEditingController();
TextEditingController txtfitPost = new TextEditingController();
TextEditingController txtEstimasi = new TextEditingController();
TextEditingController txtSearchVehicleSr = new TextEditingController();
TextEditingController txtCatalog = new TextEditingController();
TextEditingController txtCabangIdCHK = new TextEditingController();
TextEditingController txtWOCHK = new TextEditingController();
TextEditingController txtJenisTypeCHK = new TextEditingController();
TextEditingController txtKMCHK = new TextEditingController();
TextEditingController txtInputCHK = new TextEditingController();
TextEditingController txtVehicleIdListCHK = new TextEditingController();
TextEditingController txtSearchVehicleCHK = new TextEditingController();
TextEditingController txtVHCIDCHK = new TextEditingController();
TextEditingController txtVehicleNameCHK = new TextEditingController();

List<dynamic> dataCHK = [];
List listWONumberCHK = [];
List listVehicleIdCHK = [];
List dummySearchListCHK = [];
List listChecklistValueCHK = [];
List<Map<String, dynamic>> dataListOpnameDetail = [];

List<Map<String, dynamic>> dataListItemSearch = [];
List<Map<String, dynamic>> lstVKatalog = [];
List<Map<String, dynamic>> lstVKatalogTemp = [];
List<Map<String, dynamic>> dataListSrOpname = [];
FocusNode myFocusNode = FocusNode();
var fnVHCIDQC = '';
var fnSTARTKMQC = '';
var id_header = 0;
var scanResult = '';
var selEstimasi = '';
var fnSRNUMBER = '';
var selStatusItem = "";
var status_apr = "";
var service_typeid = "";
var tab_name = "";
var fnWONUMBERQC = '';
var btnNameCreatePR = "Create PR";
var wonumberopname = "";
var srnumberopname = "";
var pr_number = "";
var pm_merk = '';
var pm_vhttype = '';
var pm_locid = '';

class _BottomSheetContentWONumberCHK extends StatelessWidget {
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
                "List WO Number",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: listWONumberCHK == null ? 0 : listWONumberCHK.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      txtWOCHK.text =
                          listWONumberCHK[index]['wodwonumber'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listWONumberCHK[index]['wodwonumber']}"),
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

class _BottomSheetContentVehicleCHK extends StatelessWidget {
  Future getListWONumberCHK(BuildContext context, String vhcid) async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/maintenance/sr/refferencce_mcn.jsp?method=list-wonumber-by-vhcid&vhcid=${vhcid}");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      listWONumberCHK = json.decode(response.body);
      //print(listLocidCHK);
      if (listWONumberCHK.length == 0 && listWONumberCHK == []) {
        alert(context, 0, "Gagal Load data list wonumber", "error");
      } else {
        listWONumberCHK = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
      }
    } else {
      alert(context, 0, "Gagal Load data Type List wonumber", "error");
    }
  }

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
              controller: txtSearchVehicleCHK,
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
              itemCount: listVehicleIdCHK == null ? 0 : listVehicleIdCHK.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      print('listVehicleIdCHK ${listVehicleIdCHK}');
                      txtVehicleNameCHK.text =
                          listVehicleIdCHK[index]['vhcid'].toString();
                      txtVehicleIdListCHK.text =
                          listVehicleIdCHK[index]['vhcid'].toString();
                      txtVHCIDCHK.text =
                          listVehicleIdCHK[index]['vhcid'].toString();
                      print("txtVHCIDCHK.text");
                      print(txtVHCIDCHK.text);
                      if (txtVHCIDCHK.text != null && txtVHCIDCHK.text != '') {
                        var dt = listVehicleIdCHK
                            .where((o) => o['vhcid'] == txtVHCIDCHK.text);
                        var locid = '';
                        var vhttype = '';
                        if (dt != null) {
                          dt.forEach((v) {
                            locid = v['locid'];
                            vhttype = v['vhttype'];
                          });
                        }
                        txtCabangIdCHK.text = locid;
                        txtJenisTypeCHK.text = vhttype;
                        await getListWONumberCHK(context, txtVHCIDCHK.text);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listVehicleIdCHK[index]['vhcid']}"),
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

class FrmServiceTire extends StatefulWidget {
  @override
  _FrmServiceTireState createState() => _FrmServiceTireState();
}

class _FrmServiceTireState extends State<FrmServiceTire>
    with SingleTickerProviderStateMixin {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  final String BASE_URL =
      GlobalData.baseUrl; // "http://apps.tuluatas.com:8080/trucking";
  int status_code = 0;
  int lengTabs = 4;
  var iShowLocid = false;
  String message = "";

  // Soft Orange Pastel Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
  final Color accentOrange = Color(0xFFFFB347); // Peach orange
  final Color darkOrange = Color(0xFFE07B39); // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  final Color cardColor = Color(0xFFFFF8F0); // Light cream
  final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow

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
  //TextEditingController txtVHCIDCHK = new TextEditingController();
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

  void getVehicleListCHK() async {
    try {
      var urlData =
          "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=list-vehicle-form";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        listVehicleIdCHK = [];
        listVehicleIdCHK = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        dummySearchListCHK = [];
        dummySearchListCHK = listVehicleIdCHK;
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data detail vehcile", "error");
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data question",
          "error");
      print(e.toString());
    }
  }

  void _searchVehicleNameCHK() {
    List dummyListData2 = [];
    if (txtSearchVehicleCHK.text != "" && txtSearchVehicleCHK.text != null) {
      if (txtSearchVehicleCHK.text.length >= 3) {
        for (var i = 0; i < dummySearchListCHK.length; i++) {
          var dtC = dummySearchListCHK[i]['vhcid'].toLowerCase().toString();
          //print("${dtC} => ${txtSearchVehicleCHK.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchVehicleCHK.text.toLowerCase().toString())) {
            //print(dtC);
            dummyListData2.add({
              "vhcid": dummySearchListCHK[i]['vhcid'].toString(),
              "vhcid": dummySearchListCHK[i]['vhcid']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listVehicleIdCHK = [];
            listVehicleIdCHK = dummyListData2;
          });
        }
      }
      return;
    }
  }

  void saveOrUpdate(String id, String group_name, String nama_form_check,
      int pilihan, String input, int is_multiple) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String vhcid = txtVHCIDCHK.text;
    var uuid = Uuid();
    var userid = prefs.getString("username");
    if (prefs.getString("trxnumber_form_check") == null) {
      prefs.setString("trxnumber_form_check", uuid.v1());
    }
    var trxnumber = prefs.getString("trxnumber_form_check");
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=save-or-update&trxnumber=${trxnumber}&id=${id}"
        "&vhcid=${vhcid}&nama_group=${group_name}&nama_form_check=${nama_form_check}&pilihan=${pilihan}&input=${input}&is_multiple=${is_multiple}&userid=${userid}");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      var message = json.decode(response.body);
      print(message);
    });
  }

  Future DeleteDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        'prefs.getString("trxnumber_form_check") ${prefs.getString("trxnumber_form_check")}');
    if (prefs.getString("trxnumber_form_check") != null) {
      var trxnumber = prefs.getString("trxnumber_form_check");
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=delete-draft-form-cheklist&trxnumber=${trxnumber}");
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        var message = json.decode(response.body);
        print(message);
      });
      prefs.remove("trxnumber_form_check");
    }
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
    username = prefs.getString("username")!;
    userid = prefs.getString("name")!;
    locid = prefs.getString("locid")!;
    if (prefs.getString("tire_vhttype") != null &&
        prefs.getString("tire_vhttype")!.toString() != "") {
      _tabController.animateTo(1);
    }
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
          // if (getAkses("TY") || username == "ADMIN") {
          //   Future.delayed(Duration(milliseconds: 1));
          //   setState(() {
          //     getJSONData(true, '');
          //     getJSONDataCHK();
          //     getVehicleListCHK();
          //   });
          // }
          print('TEST');
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
    txtSearchVehicleCHK.addListener(_searchVehicleNameCHK);
    setState(() {
      resetTeks();
      getSession();
      getListSR();
      getListCabang();
      getDriverById();
      getListMechanicStaff();
      getMenuKatalog();
      //getVehicleListCHK();
    });
    if (getAkses("TY") || username == "ADMIN") {
      Future.delayed(Duration(milliseconds: 1));
      setState(() {
        getJSONData(true, '');
        getJSONDataCHK();
        getVehicleListCHK();
      });
    }
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

  Future getListDataItem(bool isload, String search, int is_barcode) async {
    try {
      EasyLoading.show();
      var urlBase = "";
      if (METHOD_DETAIL == "PURCHASE-ORDER") {
        urlBase =
            "${BASE_URL}api/inventory/list_item_sr_katalog.jsp?method=list-purchase-order-v1&warehouseid=${globals.from_ware_house}&search=${search}&katalog=${selKatalog}&is_barcode=${is_barcode}&status_apr=${status_apr}&service_typeid=${service_typeid}&merk=${pm_merk}&vhttype=${pm_vhttype}&wonumber=${wonumberopname}&srnumber=${srnumberopname}";
      } else {
        urlBase =
            "${BASE_URL}api/inventory/list_item_sr_katalog.jsp?method=list-items-v1&warehouseid=${globals.from_ware_house}&search=${search}&katalog=${selKatalog}&is_barcode=${is_barcode}&status_apr=${status_apr}&service_typeid=${service_typeid}&merk=${pm_merk}&vhttype=${pm_vhttype}&wonumber=${wonumberopname}&srnumber=${srnumberopname}";
      }
      var url = urlBase;

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListItemSearch = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data item",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data item",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget listDataSrOpname(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: TextField(
              readOnly: false,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.grey.shade800),
              controller: txtSearchVehicleSr,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  suffixIcon: IconButton(
                    icon: new Image.asset(
                      "assets/img/search.png",
                      width: 32.0,
                      height: 32.0,
                    ),
                    onPressed: () async {
                      if (txtSearchVehicleSr.text != null &&
                          txtSearchVehicleSr.text != "" &&
                          METHOD_DETAIL == '') {
                        await getListDataSr(true, txtSearchVehicleSr.text);
                      }
                    },
                  ),
                  fillColor: HexColor("FFF6F1BF"),
                  filled: true,
                  isDense: true,
                  labelText: "VHCID",
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
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
                  itemCount:
                      dataListSrOpname == null ? 0 : dataListSrOpname.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailOpnameSr(
                        dataListSrOpname[index], index);
                  }))
        ],
      ),
    );
  }

  Widget _buildListViewSerahTerima(BuildContext context) {
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

  void _showModalListWOCHK(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentWONumberCHK();
      },
    );
  }

  void _showModalListVehicleCHK(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentVehicleCHK();
      },
    );
  }

  void resetTeksFinishOpname() {
    txtCatalog.text = "";
    txtItemID.text = "";
    txtPartName.text = "";
    txtOpnameMerk.text = "";
    txtTypeID.text = "";
    txtTypeAccess.text = "";
    txtGenuineNoOpname.text = "";
    txtOpnameQty.text = "";
    METHOD_DETAIL = '';
    fnVHCIDQC = '';
    fnSTARTKMQC = '';
    fnWONUMBERQC = '';
    fnWONUMBER = '';
    fnSRNUMBER = '';
    //selEstimasi="";
    //selKatalog="";
    //selStatusItem="";
  }

  var dataOject = [];
  void getJSONDataCHK() async {
    try {
      EasyLoading.show();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=list-question-form");
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        // Get the JSON data
        listChecklistValueCHK = [];
        dataCHK = json.decode(response.body);
        if (dataCHK != null && dataCHK.length > 0) {
          for (var i = 0; i < dataCHK.length; i++) {
            listChecklistValueCHK.add(i.toString());
          }
        }
      });
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future UpdateAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var vhcid = txtVHCIDCHK.text;
    var locid = txtCabangIdCHK.text;
    var vhtalias = txtJenisTypeCHK.text;
    var odometer = txtKMCHK.text;
    var wodwonumber = txtWOCHK.text;
    var trxnumber = prefs.getString("trxnumber_form_check");
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=update-form-cheklist&trxnumber=${trxnumber}"
        "&vhcid=${vhcid}&locid=${locid}&vhtalias=${vhtalias}&odometer=${odometer}&wodwonumber=${wodwonumber}");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      var status_code = json.decode(response.body)["status_code"];
      var message = json.decode(response.body)["message"];
      if (int.parse(status_code) == 200) {
        resetTeks();
        if (prefs.getString("trxnumber_form_check") != null) {
          prefs.remove("trxnumber_form_check");
        }
        alert(globalScaffoldKey.currentContext!, 1, message, "Success");
        Timer(Duration(seconds: 1), () {
          // 5s over, navigate to a new page
          getJSONDataCHK();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 2, message, "Warning");
      }
      print(message);
    });
  }

  void resetTeksFinishOpnameDetail() {
    txtCatalog.text = "";
    txtItemID.text = "";
    txtPartName.text = "";
    txtOpnameMerk.text = "";
    txtTypeID.text = "";
    txtTypeAccess.text = "";
    txtGenuineNoOpname.text = "";
    txtOpnameQty.text = "";
    txtItemSize.text = "";
    tab_name = "";
    status_apr = "NEW";
  }

  Future DeleteOpnameDetail(bool isload, String vehicle_id, String id) async {
    try {
      EasyLoading.show();
      //"${BASE_URL}api/maintenance/sr/delete_opname_sr_detail.jsp?method=delete-detail&vhcid=${vehicle_id}&id=${id}&userid=${userid.toUpperCase()}";
      var urlData =
          "${BASE_URL}api/maintenance/sr/delete_opname_sr_detail.jsp?method=delete-detail&vhcid=${vehicle_id}&id_header=${id_header}&id=${id}&userid=${userid.toUpperCase()}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      //var isTest =true;
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
                    if (EasyLoading.isShow) {
                      EasyLoading.dismiss();
                    }
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
          await Future.delayed(Duration(milliseconds: 1));
          await getListDataOpnameDetail(true, id_header.toString(), vehicle_id);
        } else {
          print(json.decode(response.body)["status_code"]);
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
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
            "Gagal load data list detail opname", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Client, Load data detail opname", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget _buildDListDetailOpname(dynamic item, int index) {
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
                  "Katalog : ${item['katalog']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("ItemID : ${item['itemid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("TypID : ${item['idtype']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Genuino: ${item['genuineno']}",
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
                  Text("Partname: ${item['partname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Item Size: ${item['item_size']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("QTY: ${item['qty']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  )
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
              child: Row(
                children: <Widget>[
                  buildDeleteOpnameDetail(context, item),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Close"),
                    onPressed: () async {
                      Navigator.of(globalScaffoldKey.currentContext!)
                          .pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getMenuKatalog() async {
    String status = "";
    var urlData =
        "${BASE_URL}api/maintenance/sr/menu_opname_tire.jsp?method=menu-sr&service_typeid=$service_typeid&merk=$pm_merk&vhttype=$pm_vhttype";

    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstVKatalog = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        lstVKatalogTemp = lstVKatalog;
      }
    });
    return status;
  }

  Widget buildDeleteOpnameDetail(BuildContext context, dynamic item) {
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
            content: new Text("Delete this data?"), //DELETE OPNAME
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
                  print(item['id']);
                  if (item['id'] == '' || item['id'] == null) {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Id tidak boleh kosong", "warning");
                  } else {
                    await DeleteOpnameDetail(true, item['vhcid'], item['id']);
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
          backgroundColor: Colors.redAccent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ));
  }

  void createOpname() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (txtOpnameVHCID.text == null || txtOpnameVHCID.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (wonumberopname == null || wonumberopname == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Wo Number tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_opname_sr.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        print('txtfitPost.text ${txtfitPost.text}');
        var data = {
          'method': "create-header",
          'vhcid': txtOpnameVHCID.text,
          'wonumber': wonumberopname,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        //print(data); //DEMO
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        //print(response.body);

        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            //print(response);
            if (status_code == 200) {
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
                var a = json.decode(response.body)["id_header"];
                id_header = int.parse(a);
                METHOD_DETAIL = 'OPNAME';
                alert(
                    globalScaffoldKey.currentContext!, 3, "${message}", "info");
              }
            } else {
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
              alert(globalScaffoldKey.currentContext!, 3, "${message}", "info");
            }
          } else {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
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

  Future ApproveOpnameDetail(bool isload, String vehicle_id, String id) async {
    try {
      EasyLoading.show();
      var estimasi = selEstimasi.toString() + ":00";
      var urlData =
          "${BASE_URL}api/maintenance/sr/approve_opname_sr_detail.jsp?method=approve-detail&vhcid=${vehicle_id}&id_header=${id}&estimasi=${estimasi}";
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
          await getListDataOpnameDetail(true, id_header.toString(), vehicle_id);
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
            "Gagal load data list detail opname", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Client, Load data detail opname", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  void SavePurchaseOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var locid = prefs.getString("locid");
      if (id_header <= 0) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Silahkan create opname terlebih dahulu", "error");
      } else if (txtPrNumber.text == null || txtPrNumber.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (txtOpnameVHCID.text == null || txtOpnameVHCID.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (txtOpnameQty.text == null || txtOpnameQty.text == "") {
        alert(globalScaffoldKey.currentContext!, 0, "QTY tidak boleh kosong",
            "error");
      } else if (double.parse(txtOpnameQty.text) <= 0 &&
          selStatusItem != 'Perbaikan') {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_opname_sr_detail_new.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        print('txtfitPost.text ${txtfitPost.text}');
        var data = {
          'method': "create-detail-pr",
          'pbnbr': txtPrNumber.text,
          'id_header': id_header.toString(),
          'kode_katalog': selKatalog,
          'vhcid': txtOpnameVHCID.text,
          'status_apr': status_apr,
          'itemid': txtItemID.text,
          'genuineno': txtGenuineNoOpname.text,
          'merk': txtOpnameMerk.text,
          'qty': txtOpnameQty.text == null || txtOpnameQty.text == ""
              ? "0"
              : txtOpnameQty.text,
          'estimasi': selEstimasi.toString() + ":00",
          'idtype': txtTypeID.text,
          'partname': txtPartName.text,
          'item_size': txtItemSize.text,
          'idaccess': txtTypeAccess.text,
          'status_item': selStatusItem,
          'service_typeid': service_typeid,
          'pm_merk': pm_merk,
          'pm_vhttype': pm_vhttype,
          'pm_locid': pm_locid,
          'userid': userid.toUpperCase(),
          //'locid': userid.toUpperCase(),
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
        //print(response.body);

        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(message);
            if (status_code == 200) {
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
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
                        resetTeksFinishOpnameDetail();
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
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
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

  Future CreatePurchaseRequest() async {
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("username");
      var locid = prefs.getString("locid");
      var notes = txtSRNumber.text;

      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/inventory/permintaan_opr.jsp?method=create-pr-v1&userid=${userid}&locid=${locid}&notes=${notes}");
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      var status_code = json.decode(response.body)["status_code"];
      var message = json.decode(response.body)["message"];
      var prNumber = json.decode(response.body)["returnnum"];
      if (response.statusCode == 200) {
        if (status_code == 200) {
          alert(globalScaffoldKey.currentContext!, 1, message, "success");
          pr_number = prNumber;
          txtPrNumber.text = prNumber;
          setState(() {
            btnNameCreatePR = "Save PR";
            METHOD_DETAIL = "PURCHASE-ORDER";
          });
        } else {
          alert(globalScaffoldKey.currentContext!, 3, message, "error");
        }
      }

      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      print($e);
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<dynamic> fetchItemsLogsAndProcess() async {
    final List<Map<String, dynamic>> items =
        await DatabaseHelper.instance.fetchItemsLogs();

    // Create a list to hold the results
    List<dynamic> result = [];

    // Iterate through each item in the fetched items
    items.forEach((item) {
      // Process each item and add to the result list
      result.add({
        'id_tire': item['id_tire'],
        'vhcid': item['vhcid'],
        'serial_no': item['serial_no'],
        'pattern': item['pattern'],
        'pattern': item['pattern'],
        'in_depth': item['in_depth'],
        'out_dept': item['out_dept'],
        'mid1_depth': item['mid1_depth'],
        'mid2_depth': item['mid2_depth'],
        'tekanan_angin': item['tekanan_angin'],
        'fitpost': item['fitpost'],
        'note': item['note'],
        'casing_yes': item['casing_yes'],
        'casing_no': item['casing_no'],
      });
    });

    // Return the result as a dynamic value
    return result;
  }

  Future<int> CreateLogsTire(
      String tire_serial_no,
      String tire_vhcid,
      String tire_pattern,
      String tire_in_depth,
      String tire_out_dept,
      String mid1_depth,
      String mid2_depth,
      String tekanan_angin,
      String tire_fitpost,
      String tire_note,
      String srnumber,
      String _casing_yes,
      String _casing_no,
      String alasan_unit,
      String status_unit,
      String kerusakan_ban,
      String masalah_unit,
      String photo_ban,
      String photo_tapak,
      String photo_damage,
      String userid) async {
    //print('inserr log');
    var encodedLogs = Uri.encodeFull(
        "${BASE_URL}api/maintenance/sr/create_opname_sr_detail_tire.jsp");
    var dataLogs = {
      'method': "create-tire-logs",
      'tire_serial_no': tire_serial_no,
      'tire_vhcid': tire_vhcid,
      'tire_pattern': tire_pattern,
      'tire_in_depth': tire_in_depth,
      'tire_out_dept': tire_out_dept,
      'mid1_depth': mid1_depth,
      'mid2_depth': mid2_depth,
      'tekanan_angin': tekanan_angin,
      'tire_fitpost': tire_fitpost,
      'tire_note': tire_note,
      'tire_srnumber': srnumber,
      'casing_no': _casing_no,
      'casing_yes': _casing_yes,
      'alasan_unit': alasan_unit,
      'status_unit': status_unit,
      'kerusakan_ban': kerusakan_ban,
      'masalah_unit': masalah_unit,
      'photo_ban': photo_ban.toString(),
      'photo_tapak': photo_tapak.toString(),
      'photo_damage': photo_damage.toString(),
      'userid': userid
    };
    Uri urlEncodeLogs = Uri.parse(encodedLogs);
    final response = await http.post(
      urlEncodeLogs,
      body: dataLogs,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
    );
    print("response ${response}");
    if (response.statusCode == 200) {
      status_code = json.decode(response.body)["status_code"];
      if (status_code == 200) {
        return 1;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<int> GetTotalBan(String tire_vhcid) async {
    var encodedLogs =
        Uri.encodeFull("${BASE_URL}api/maintenance/sr/detail_ban_tire.jsp");
    var dataLogs = {
      'method': "get-total-tire-ban-v1",
      'tire_vhcid': tire_vhcid
    };
    Uri urlEncodeLogs = Uri.parse(encodedLogs);
    final response = await http.post(
      urlEncodeLogs,
      body: dataLogs,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
    );
    print("response ${response}");
    if (response.statusCode == 200) {
      var total = json.decode(response.body)["total"];
      var message_json = json.decode(response.body)["message"];
      if (message_json == "Success") {
        return int.parse(total);
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  void createOpnameDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var tire_vhttype = prefs.getString("tire_vhttype");
      var count = await DatabaseHelper.instance.countTableTire();
      var totalBan = 0;
      if (txtOpnameVHCID.text != null && txtOpnameVHCID.text != "") {
        totalBan = await GetTotalBan(txtOpnameVHCID.text);
      }

      //assert(count==0,'Database kosong pada table tir');
      if (totalBan == 0) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Total ban yang akan di inspection tidak ada", "error");
      } else if (txtOpnameVHCID.text == null || txtOpnameVHCID.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (txtOpnameQty.text == null || txtOpnameQty.text == "") {
        alert(globalScaffoldKey.currentContext!, 0, "QTY tidak boleh kosong",
            "error");
      } else if (double.parse(txtOpnameQty.text) <= 0 &&
          selStatusItem != 'Perbaikan') {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else if (count <= 0) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Inspection Tire tidak boleh 0", "error");
      } else if (count != totalBan && tire_vhttype == "LT") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Inspection Tire harus semua, cek dalam draft inspection", "error");
      } else if (count != totalBan && tire_vhttype == "TRAIL") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Inspection Tire harus semua, cek dalam draft inspection", "error");
      } else if (count != totalBan && tire_vhttype == "TR") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Inspection Tire harus semua, cek dalam draft inspection", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var dataLogs = await fetchItemsLogsAndProcess();

        //assert(dataLogs != null, "Variable is not null");
        var numInsert = 0;
        for (var item in dataLogs) {
          print(item);
          var inserted = await CreateLogsTire(
              item['serial_no'].toString(),
              item['vhcid'].toString(),
              item['pattern'].toString(),
              item['in_depth'].toString(),
              item['out_dept'].toString(),
              item['mid1_depth'].toString(),
              item['mid2_depth'].toString(),
              item['tekanan_angin'].toString(),
              item['fitpost'].toString(),
              item['note'].toString(),
              txtOpnameWONUMBER.text,
              item['casing_yes'].toString(),
              item['casing_no'].toString(),
              item['alasan_unit'].toString(),
              item['status_unit'].toString(),
              item['kerusakan_ban'].toString(),
              item['masalah_unit'].toString(),
              item['photo_ban'].toString(),
              item['photo_tapak'].toString(),
              item['photo_damage'].toString(),
              prefs.getString("name")!);
          if (inserted == 1) {
            numInsert++;
          }
        }
        if (numInsert > 0) {
          var encoded = Uri.encodeFull(
              "${BASE_URL}api/maintenance/sr/create_opname_sr_detail_tire.jsp");
          print(encoded);
          Uri urlEncode = Uri.parse(encoded);
          print('txtfitPost.text ${txtfitPost.text}');
          var data = {
            'method': "create-detail",
            'id_header': id_header.toString(),
            'kode_katalog': selKatalog,
            'vhcid': txtOpnameVHCID.text,
            'status_apr': status_apr,
            'itemid': txtItemID.text,
            'genuineno': txtGenuineNoOpname.text,
            'merk': txtOpnameMerk.text,
            'qty': txtOpnameQty.text == null || txtOpnameQty.text == ""
                ? "0"
                : txtOpnameQty.text,
            'estimasi': selEstimasi.toString() + ":00",
            'idtype': txtTypeID.text,
            'partname': txtPartName.text,
            'item_size': txtItemSize.text,
            'idaccess': txtTypeAccess.text,
            'status_item': selStatusItem,
            'service_typeid': service_typeid,
            'pm_merk': pm_merk,
            'pm_vhttype': pm_vhttype,
            'pm_locid': pm_locid,
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
          //print(response.body);

          setState(() {
            if (response.statusCode == 200) {
              status_code = json.decode(response.body)["status_code"];
              message = json.decode(response.body)["message"];
              print(message);
              if (status_code == 200) {
                if (EasyLoading.isShow) {
                  EasyLoading.dismiss();
                }
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
                          await DatabaseHelper.instance.deleteItemLogsAll();
                          resetTeksFinishOpnameDetail();
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
              } else {
                if (EasyLoading.isShow) {
                  EasyLoading.dismiss();
                }
                alert(globalScaffoldKey.currentContext!, 0, "${message}",
                    "error");
              }
            } else {
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
              alert(globalScaffoldKey.currentContext!, 0,
                  "${response.statusCode}", "error");
            }
          });
        } else {
          //no data inspection inserted
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          alert(globalScaffoldKey.currentContext!, 0,
              "no data inspection inserted", "error");
        }
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      print(e);
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
    }
  }

  void createOpnameDetailProses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (fnWONUMBER == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "WO NUMBER tidak boleh kosong", "error");
      } else if (txtOpnameVHCID.text == null || txtOpnameVHCID.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (selEstimasi == null || selEstimasi == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Estimasi tidak boleh kosong", "error");
      } else if (txtOpnameQty.text == null || txtOpnameQty.text == "") {
        alert(globalScaffoldKey.currentContext!, 0, "QTY tidak boleh kosong",
            "error");
      } else if (double.parse(txtOpnameQty.text) <= 0) {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_opname_sr_detail.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': "create-detail-proses_qc",
          'wonumber_detail': fnWONUMBER.toString(),
          'kode_katalog': selKatalog,
          'vhcid': txtOpnameVHCID.text,
          'itemid': txtItemID.text,
          'genuineno': txtGenuineNoOpname.text,
          'merk': txtOpnameMerk.text,
          'qty': txtOpnameQty.text == null || txtOpnameQty.text == ""
              ? "0"
              : txtOpnameQty.text,
          'estimasi': selEstimasi.toString() + ":00",
          'idtype': txtTypeID.text,
          'partname': txtPartName.text,
          'idaccess': txtTypeAccess.text,
          'status_item': selStatusItem,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        //print(data); //DEMO
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        //print(response.body);

        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            //print(response);
            if (status_code == 200) {
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
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
                        resetTeksFinishOpname();
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
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
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

  void createOpnameDetailQC() async {
    print('create detail opname 1');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (fnWONUMBER == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "WO NUMBER tidak boleh kosong", "error");
      } else if (txtOpnameVHCID.text == null || txtOpnameVHCID.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (selEstimasi == null || selEstimasi == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Estimasi tidak boleh kosong", "error");
      } else if (txtOpnameQty.text == null || txtOpnameQty.text == "") {
        alert(globalScaffoldKey.currentContext!, 0, "QTY tidak boleh kosong",
            "error");
      } else if (double.parse(txtOpnameQty.text) <= 0) {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_opname_sr_detail.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': "create-detail-proses_qc",
          'wonumber_detail': fnWONUMBER.toString(),
          'kode_katalog': selKatalog,
          'vhcid': txtOpnameVHCID.text,
          'itemid': txtItemID.text,
          'genuineno': txtGenuineNoOpname.text,
          'merk': txtOpnameMerk.text,
          'qty': txtOpnameQty.text == null || txtOpnameQty.text == ""
              ? "0"
              : txtOpnameQty.text,
          'estimasi': selEstimasi.toString() + ":00",
          'idtype': txtTypeID.text,
          'partname': txtPartName.text,
          'idaccess': txtTypeAccess.text,
          'status_item': selStatusItem,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        //print(data); //DEMO
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);

        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            //print(response);
            if (status_code == 200) {
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
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
                        resetTeksFinishOpname();
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
              if (EasyLoading.isShow) {
                EasyLoading.dismiss();
              }
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
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

  Future getListDataOpnameDetail(
      bool isload, String id_header, String vehicle_id) async {
    try {
      EasyLoading.show();
      var urlBase = "";
      urlBase =
          "${BASE_URL}api/maintenance/sr/list_opname_sr_detail.jsp?method=list-opname-sr-detail&id_header=${id_header}&vhcid=${vehicle_id}&pbnbr=${pr_number}&method_detail=${METHOD_DETAIL}";
      var urlData = urlBase;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListOpnameDetail = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list detail opname", "error");
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

  Future scanQRCode() async {
    // TODO: Migrate to mobile_scanner - qrscan package removed
    alert(globalScaffoldKey.currentContext!, 2,
        "Fitur scan QR perlu migrasi ke mobile_scanner", "warning");
  }

  void getItemBarcode(String url, String itemid) async {
    //print("getItemBarcode ${getItemBarcode}");
    var urlData = url;
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    http.Response response = await http.get(myUri);
    print("Data katalog");
    //print(response.body.toString());
    setState(() {
      if (response.statusCode == 200) {
        List result = json.decode(response.body);
        //print(result.length);
        if (result != null && result.length > 0) {
          txtItemID.text = itemid;
          txtPartName.text = result[0]['part_name'];
          txtTypeID.text = result[0]['type'];
          txtTypeAccess.text = result[0]['accessories'];
          txtGenuineNoOpname.text = result[0]['genuine_no'];
          txtOpnameMerk.text = result[0]['merk'];
          myFocusNode.requestFocus();
        } else {
          alert(globalScaffoldKey.currentContext!, 2,
              "Data inventory tidak ditemukan", "warning");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Error,Response server ${response.statusCode}", "error");
      }
    });
  }

  Widget _buildDListDetailOpnameSr(dynamic item, int index) {
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
                // leading: Container(
                //   padding: EdgeInsets.only(right: 12.0),
                //   decoration: new BoxDecoration(
                //       border: new Border(
                //           right: new BorderSide(
                //               width: 1.0, color: Colors.black45))),
                //   child: Icon(Icons.settings_applications, color: Colors.black),
                // ),
                title: Text(
                  "SR Number : ${item['srnumber']}",
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
                  // Text("Original SR Number : ${item['orisrnumber']}",
                  //     style: TextStyle(color: Colors.black)),
                  // Divider(
                  //   color: Colors.transparent,
                  //   height: 0,
                  // ),
                  Text("VHCID : ${item['vhcid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("MERK : ${item['manufacturer']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("VHTTYPE : ${item['vhttype']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("SERVICE TYPE : ${item['srtypeid']}",
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
                  Text("NOTES: ${item['srnotes']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  )
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
                    Icons.edit,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Add"), //ADD TIRE
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    Navigator.of(context).pop(false);
                    //FOR DEV
                    // service_typeid = "PM1";
                    // txtOpnameVHCID.text = "B 9744 YU";//
                    // if(service_typeid=="PM1"){
                    //   pm_merk= "ISUZU";
                    //   pm_vhttype="LT";
                    //
                    // }
                    //print(item);
                    service_typeid = item['srtypeid'].toString();
                    pm_locid = item['srlocid'].toString();
                    txtOpnameVHCID.text = item['vhcid'].toString();
                    prefs.setString("tire_vhcid", item['vhcid'].toString());
                    prefs.setString("tire_drvid", item['drvid'].toString());
                    print(
                        "item['vhttype'].toString()  ${item['vhttype'].toString()}");
                    var tireType = item['vhttype'].toString() != null &&
                            item['vhttype'].toString() != "" &&
                            item['vhttype'].toString() != 'null'
                        ? item['vhttype'].toString().toUpperCase()
                        : "";
                    //tireType = "LT";
                    if (tireType.contains("TRAILLER")) {
                      if (tireType.substring(0, tireType.length - 3) ==
                          "TRAIL") {
                        prefs.setString("tire_vhttype", "TRAIL");
                      }
                    } else {
                      if (tireType.substring(0, 2) == "TR") {
                        prefs.setString("tire_vhttype", "TR");
                      } else if (tireType.substring(0, 2) == "LT") {
                        prefs.setString("tire_vhttype", "LT");
                      } else {
                        prefs.setString("tire_vhttype", "");
                      }
                    }

                    pm_merk = '';
                    pm_vhttype = '';
                    if (service_typeid == "PM1" ||
                        service_typeid == "PM2" ||
                        service_typeid == "PM3") {
                      pm_merk = item['manufacturer'].toString();
                      pm_vhttype = item['vhttype'].toString();
                    }
                    print(pm_merk);
                    print(pm_vhttype);
                    txtOpnameWONUMBER.text = item['srnumber'].toString();
                    print(
                        'wonumberopname ${item['wodwonbr'].toString()} ${wonumberopname}');
                    wonumberopname = item['wodwonbr'].toString();
                    srnumberopname = item['srnumber'].toString();
                    await getMenuKatalog();
                    Timer(Duration(seconds: 1), () {
                      showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(10.0),
                                child: Text("Save Opname?"),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("Save Opname"),
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                                createOpname();
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
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("Close"),
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                                setState(() {
                                  wonumberopname = "";
                                  srnumberopname = "";
                                  txtOpnameVHCID.text = "";
                                  txtOpnameWONUMBER.text = "";
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Close"),
                  onPressed: () async {
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orangeAccent,
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

  Widget listDataOpnameDetail(BuildContext context) {
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
                  padding: const EdgeInsets.only(
                      left: 2.0, right: 2.0, top: 2.0, bottom: 250),
                  itemCount: dataListOpnameDetail == null
                      ? 0
                      : dataListOpnameDetail.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailOpname(
                        dataListOpnameDetail[index], index);
                  }))
        ],
      ),
    );
  }

  Widget listDataSearchItem(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 2, top: 2, left: 2, right: 2),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: TextField(
              readOnly: false,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.grey.shade800),
              controller: txtSearchPartname,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  suffixIcon: IconButton(
                    icon: new Image.asset(
                      "assets/img/search.png",
                      width: 32.0,
                      height: 32.0,
                    ),
                    onPressed: () async {
                      if (txtSearchPartname.text != null &&
                          txtSearchPartname.text != "") {
                        await getListDataItem(true, txtSearchPartname.text, 0);
                      }
                    },
                  ),
                  fillColor: HexColor("FFF6F1BF"),
                  filled: true,
                  isDense: true,
                  labelText: "Partname",
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
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
                  padding: const EdgeInsets.only(
                      left: 2, right: 2, top: 2, bottom: 2),
                  itemCount: dataListItemSearch == null
                      ? 0
                      : dataListItemSearch.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailItem(
                        dataListItemSearch[index], index);
                  })),
          SizedBox(height: 100)
        ],
      ),
    );
  }

  dateTimePickerWidget(BuildContext context) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'dd MMMM yyyy HH:mm',
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(3000),
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime, List<int> index) {
        print('Done');
        DateTime selectdate = dateTime;
        selEstimasi = DateFormat('yyyy-MM-dd HH:mm').format(selectdate);
        print(selEstimasi);
        setState(() {
          txtEstimasi.text = selEstimasi.toString() + ":00";
        });
      },
    );
  }

  Future getListDataSr(bool isload, String search) async {
    try {
      EasyLoading.show();
      var urlBase = "";
      // if(METHOD_DETAIL=="PURCHASE-ORDER"){
      //   urlBase = "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-purchase-request-oprs-v1&search=" + search;
      // }else{
      //   urlBase = "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-oprs-v1&search=" + search;
      // }

      urlBase =
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr_tire.jsp?method=lookup-list-request-oprs-v1&search=" +
              search;
      var urlData = Uri.parse(urlBase);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListSrOpname = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data list sr",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data sr",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<String> GetTotalKM(bool isload, String search) async {
    String ret = "0";
    try {
      EasyLoading.show();
      var urlBase = "";

      urlBase =
          "${GlobalData.baseUrl}api/maintenance/sr/refference_tyre.jsp?method=lookup-list-total-km-v1&search=" +
              search;
      var urlData = Uri.parse(urlBase);
      //var encoded = Uri.encodeFull(urlData);
      print("total KM ${urlData}");
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          ret = jsonDecode(response.body)["value"];
        });
        print("TOTAL KM ${ret}");
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load total KM",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data total KM",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return ret;
  }

  Widget _buildDListDetailItem(dynamic item, int index) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Column(
            children: <Widget>[
              Container(
                width:
                    MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
                decoration:
                    BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
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
                      child: Icon(Icons.settings_applications,
                          color: Colors.black),
                    ),
                    title: Text(
                      "Item ID : ${item['item_id']}",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Wrap(children: <Widget>[
                      Text("Partname : ${item['part_name']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("Type : ${item['type']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("Merk : ${item['merk']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("QTY : ${item['quantity']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("ID ACCESS : ${item['accessories']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("UOM: ${item['uom_id']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("ITEM SIZE: ${item['item_size']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("VHTID: ${item['vhtid']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("LOCID: ${item['ware_house']}",
                          style: TextStyle(color: Colors.black)),
                      Divider(
                        color: Colors.transparent,
                        height: 0,
                      ),
                      Text("GENUINO: ${item['genuine_no']}",
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
                decoration:
                    BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
                child: Container(
                  child: Row(children: <Widget>[
                    Expanded(
                        child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Pilih"),
                      onPressed: () async {
                        Navigator.of(globalScaffoldKey.currentContext!)
                            .pop(false);
                        //print(item);
                        if (service_typeid == "PM1" ||
                            service_typeid == "PM2" ||
                            service_typeid == "PM3") {
                          txtOpnameQty.text = item['quantity'];
                        }
                        txtItemID.text = item['item_id'];
                        txtPartName.text = item['part_name'];
                        txtItemSize.text = item['item_size'];
                        txtTypeID.text = item['type'];
                        txtTypeAccess.text = item['accessories'];
                        txtGenuineNoOpname.text = item['genuine_no'];
                        txtOpnameMerk.text = item['merk'];
                        var itpid = item['itpid'];
                        selKatalog = itpid;
                        print('itpid ${itpid}');
                        if (tab_name == "FORMAN_OR_PROSES") {
                          status_apr = "APR";
                        } else {
                          status_apr = "NEW";
                        }

                        var nKatalog = lstVKatalog
                            .where((e) => e['value'] == selKatalog)
                            .single;

                        setState(() {
                          nama_katalog = "(${nKatalog['title']})";
                        });
                        print(status_apr);
                        print(nKatalog['title']);
                        //print(lstVKatalog);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    )),
                    SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Close"),
                      onPressed: () async {
                        Navigator.of(globalScaffoldKey.currentContext!)
                            .pop(false);
                        setState(() {
                          nama_katalog = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.orangeAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    )),
                  ]),
                ),
              ),
            ],
          ),
        ));
  }

  final TextEditingController _kmAwalController = TextEditingController();
  final TextEditingController _kmAkhirController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _submitDataKM(String vhcids) async {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(); // Tutup dialog sebelum submit
      var sr_number = txtOpnameWONUMBER.text;

      String kmAwal = _kmAwalController.text;
      String kmAkhir = _kmAkhirController.text;

      String apiUrl =
          "${GlobalData.baseUrl}api/maintenance/sr/update_km_tyre.jsp?method=update-km-last&vhcid=${vhcids}&km_awal=${kmAwal}&km_akhir=${kmAkhir}&sr_number=${sr_number}";
      print(apiUrl);
      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          print(jsonResponse["status_code"]);
          if (jsonResponse["status_code"] == 200) {
            _showSnackBar("✅ Success update KM", Colors.green);
            _kmAkhirController.text = "";
            _kmAwalController.text = "";
          } else {
            _showSnackBar("❌ Gagal update KM", Colors.red);
          }
        } else {
          _showSnackBar(
              "⚠️ Server Error (${response.statusCode})", Colors.orange);
        }
      } catch (e) {
        _showSnackBar("❌ Error: $e", Colors.red);
      }
    } else {
      print('Test');
    }
  }

  void _showInputDialogUpdateKM(String kmawal, String vhcids) {
    _kmAwalController.text = kmawal;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Input KM Awal & KM Akhir"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  readOnly: true,
                  controller: _kmAwalController,
                  decoration: const InputDecoration(labelText: "KM Awal"),
                  validator: (value) => value == null || value.isEmpty
                      ? "KM Awal wajib diisi"
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _kmAkhirController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "KM Akhir"),
                  validator: (value) => value == null || value.isEmpty
                      ? "KM Akhir wajib diisi"
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _kmAkhirController.text = "";
                _kmAwalController.text = "";
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                print('vhcids ${vhcids}');
                await _submitDataKM(vhcids);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListViewOPNAME(BuildContext context) {
    if (getAkses("SA")) {
      return Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blue,
              spreadRadius: 1,
              blurRadius: 0,
              offset: Offset(0, 0),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              if (isCreatePrNumber) ...[
                Container(
                  margin:
                      EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                  child: TextField(
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtPrNumber,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      fillColor: Colors.black12,
                      filled: true,
                      labelText: 'PR Number',
                      isDense: true,
                      contentPadding: EdgeInsets.all(2.0),
                    ),
                  ),
                )
              ],
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtOpnameVHCID,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    suffixIcon: IconButton(
                      icon: new Image.asset(
                        "assets/img/search.png",
                        width: 32.0,
                        height: 32.0,
                      ),
                      onPressed: () async {
                        // if (txtOpnameVHCID.text == null ||
                        //     txtOpnameVHCID.text == '') {
                        //   alert(globalScaffoldKey.currentContext!, 0,
                        //       "Vehicle ID tidak boleh kosong", "error");
                        // } else {
                        //   await createOpname();
                        //   // id_header =
                        //   //     await getIdHeader(txtOpnameVHCID.text);
                        // }
                        //txtOpnameVHCID.text='';
                        if (METHOD_DETAIL == '') {
                          await getListDataSr(true, txtOpnameVHCID.text);
                        }

                        await Future.delayed(Duration(milliseconds: 1));
                        if (dataListSrOpname.length > 0) {
                          print('OK load data');
                          //await Future.delayed(Duration(milliseconds: 2));
                          Timer(Duration(seconds: 1), () {
                            showDialog(
                                context: globalScaffoldKey.currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('List Detail SR'),
                                    content: listDataSrOpname(context),
                                  );
                                });
                          });
                        }
                      },
                    ),
                    fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "Search VHCID by list Sr",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtOpnameWONUMBER, //as srnumber kebalik
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "SR Number",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(
              //           left: 16.0), // Add padding to the left
              //       child: ElevatedButton(
              //         onPressed: () async {
              //           SharedPreferences prefs =
              //           await SharedPreferences.getInstance();
              //           Timer(Duration(seconds: 1), () async {
              //             // 5s over, navigate to a new page
              //             var tireType =
              //             prefs.getString("tire_vhttype").toString();
              //             //prefs.setString("tire_total_km",(txtKM.text == null ? "0":txtKM.text)).toString();
              //             //print(" tireType ${tireType}");
              //             //tireType = 'LT';//DEV
              //             //prefs.setString("tire_vhttype",tireType).toString();//DEV
              //             //prefs.setString("tire_vhcid","B 9293 YU/B 9293 YU").toString();//DEV
              //             var total_km = await GetTotalKM(true,prefs.getString("tire_vhcid").toString());
              //             prefs.setString("tire_total_km",total_km).toString();
              //             if (tireType == "TRAIL") {
              //               Navigator.pushReplacement(
              //                   context,
              //                   MaterialPageRoute(
              //                       builder: (context) => TireTriller()));
              //             }
              //             if (tireType == "TR") {
              //               Navigator.pushReplacement(
              //                   context,
              //                   MaterialPageRoute(
              //                       builder: (context) => TireTronton()));
              //             }
              //             if (tireType == "LT") {
              //               Navigator.pushReplacement(
              //                   context,
              //                   MaterialPageRoute(
              //                       builder: (context) => TireLT()));
              //             }
              //           });
              //         },
              //         child: Text('Add Tire Inspection'),
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(
              //           left: 16.0), // Add padding to the left
              //       child: ElevatedButton(
              //         onPressed: () async {
              //           SharedPreferences prefs =
              //           await SharedPreferences.getInstance();
              //           //prefs.setString("tire_vhcid","B 9293 YU/B 9293 YU").toString();//DEV DIALOG
              //           var vhcids = prefs.getString("tire_vhcid").toString();
              //           var total_km = await GetTotalKM(true,vhcids);
              //
              //           print('TOTAL KM ${total_km}');
              //           _showInputDialogUpdateKM(total_km,vhcids);
              //         },
              //         child: Text('Update KM'),
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 8.0), // Spasi antar tombol
                      child: TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          Timer(Duration(seconds: 1), () async {
                            var tireType =
                                prefs.getString("tire_vhttype").toString();

                            //tireType = 'LT';//DEV
                            //prefs.setString("tire_vhttype",tireType).toString();//DEV
                            //prefs.setString("tire_vhcid","B 9293 YU/B 9293 YU").toString();//DEV
                            if (tireType == null || tireType == "") return;
                            var total_km = await GetTotalKM(
                                true, prefs.getString("tire_vhcid").toString());

                            //prefs.setString("tire_total_km", total_km).toString();

                            if (tireType == "TRAIL") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TireTriller()));
                            }
                            if (tireType == "TR") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TireTronton()));
                            }
                            if (tireType == "LT") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TireLT()));
                            }
                          });
                        },
                        child: Text('Add Tire Inspection',
                            style: TextStyle(fontSize: 16, color: Colors.blue)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 16.0), // Spasi antar tombol
                      child: TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var vhcids = prefs.getString("tire_vhcid").toString();
                          if (vhcids == null || vhcids == "") return;
                          //print('vhcids ${vhcids}');
                          var total_km = await GetTotalKM(true, vhcids);

                          print('TOTAL KM $total_km');
                          _showInputDialogUpdateKM(total_km, vhcids);
                        },
                        child: Text('Update KM',
                            style: TextStyle(fontSize: 16, color: Colors.blue)),
                      ),
                    ),
                  ),
                ],
              ),
              SmartSelect<String?>.single(
                title: 'Katalog ${nama_katalog}',
                selectedValue: selKatalog,
                placeholder: 'Pilih satu',
                onChange: (selected) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  // Navigator.of(context,
                  //     rootNavigator: true)
                  //     .pop();

                  setState(() {
                    selKatalog = selected.value!;
                    nama_katalog = "";
                  });
                  if (selKatalog == null || selKatalog == '') {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Katalog ID Kosong", "error");
                  } else {
                    getListDataItem(true, txtPartName.text, 0);
                    await Future.delayed(Duration(milliseconds: 1));
                    if (dataListItemSearch.length > 0) {
                      Timer(Duration(seconds: 1), () {
                        showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('List Detail Mechanic'),
                                content: listDataSearchItem(context),
                              );
                            });
                      });
                    }
                  }
                },

                choiceItems: S2Choice.listFrom<String, Map>(
                    source: lstVKatalog,
                    value: (index, item) => item['value'],
                    title: (index, item) => item['title']),
                //choiceGrouped: true,
                modalFilter: true,
                modalFilterAuto: true,
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtItemID,
                  keyboardType: TextInputType.text,
                  // onChanged: (value) {
                  //   updateButtonState(value);
                  // },
                  decoration: new InputDecoration(
                    suffixIcon: IconButton(
                      icon: new Image.asset(
                        "assets/img/search.png",
                        width: 32.0,
                        height: 32.0,
                      ),
                      onPressed: () {
                        if (txtItemID.text == null || txtItemID.text == "") {
                        } else {
                          print(txtItemID.text);
                        }
                        showDialog(
                          context: globalScaffoldKey.currentContext!,
                          builder: (BuildContext context) => new AlertDialog(
                            title: new Text('Information'),
                            content:
                                new Text("Search Partname/ Item By Scan Code"),
                            actions: <Widget>[
                              new ElevatedButton.icon(
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                label: Text("Searh Partname"),
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  txtPartName.text = "";
                                  getListDataItem(true, txtPartName.text, 0);
                                  await Future.delayed(
                                      Duration(milliseconds: 1));
                                  if (dataListItemSearch.length > 0) {
                                    Timer(Duration(seconds: 1), () {
                                      print('Show dialog');
                                      showDialog(
                                          context:
                                              globalScaffoldKey.currentContext!,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('List Detail Item'),
                                              content:
                                                  listDataSearchItem(context),
                                            );
                                          });
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.blueAccent,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                              new SizedBox(width: 5),
                              new ElevatedButton.icon(
                                icon: Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                label: Text("Scan Code"),
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  if (selKatalog == null || selKatalog == '') {
                                    alert(globalScaffoldKey.currentContext!, 0,
                                        "Katalog tidak boleh kosong", "error");
                                  } else {
                                    scanQRCode();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'Item ID',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtPartName,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'Part Name',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtItemSize,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'Item Size',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtTypeID,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'Type ID',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtTypeAccess,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'IDACCESS',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtGenuineNoOpname,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'GENUINENO',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtOpnameMerk,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    labelText: 'Merk',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  readOnly: false,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtOpnameQty,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    //fillColor: Colors.black12,
                    filled: true,
                    labelText: 'QTY',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              SmartSelect<String?>.single(
                title: 'Status Item',
                selectedValue: selStatusItem,
                onChange: (selected) {
                  setState(() => selStatusItem = selected.value!);
                },
                choiceType: S2ChoiceType.radios,
                choiceItems: choices.collStatusItemOpname,
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
              // SmartSelect<String>.single(
              //   title: 'Estimasi',
              //   value: selEstimasi,
              //   onChange: (selected) {
              //     setState(() => selEstimasi = selected.value);
              //   },
              //   choiceType: S2ChoiceType.radios,
              //   choiceItems: choices.collEstimasi,
              //   modalType: S2ModalType.popupDialog,
              //   modalHeader: false,
              //   modalConfig: const S2ModalConfig(
              //     style: S2ModalStyle(
              //       elevation: 3,
              //       shape: RoundedRectangleBorder(
              //         borderRadius:
              //         BorderRadius.all(Radius.circular(20.0)),
              //       ),
              //     ),
              //   ),
              // ),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                child: TextField(
                  onTap: () {
                    dateTimePickerWidget(context);
                  },
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtEstimasi,
                  keyboardType: TextInputType.datetime,
                  decoration: new InputDecoration(
                    //fillColor: Colors.black12,
                    filled: true,
                    labelText: 'Estimasi',
                    isDense: true,
                    contentPadding: EdgeInsets.all(2.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
                child: Row(children: <Widget>[
                  // Expanded(
                  //     child: ElevatedButton.icon(
                  //   icon: Icon(
                  //     Icons.cancel,
                  //     color: Colors.white,
                  //     size: 15.0,
                  //   ),
                  //   label: Text("Cancel"),
                  //   onPressed: () async {
                  //     print('cancel');
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //       elevation: 0.0,
                  //       backgroundColor: Colors.orangeAccent,
                  //       padding: EdgeInsets.symmetric(
                  //           horizontal: 5, vertical: 0),
                  //       textStyle: TextStyle(
                  //           fontSize: 12, fontWeight: FontWeight.bold)),
                  // )),
                  // SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Create"), //CREATE OPNAME
                    onPressed: () async {
                      print(fnWONUMBER);
                      print("METHOD_DETAIL ${METHOD_DETAIL}");
                      if (METHOD_DETAIL == "PURCHASE-ORDER") {
                        setState(() {
                          METHOD_DETAIL = 'OPNAME';
                        });
                      }
                      print(id_header);
                      if (txtOpnameVHCID.text == null ||
                          txtOpnameVHCID.text == '') {
                        alert(globalScaffoldKey.currentContext!, 0,
                            "Vehicle ID tidak boleh kosong", "error");
                      } else {
                        if (id_header > 0 && METHOD_DETAIL != '') {
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              title: new Text('Information'),
                              content: new Text("Create new detail opname?"),
                              actions: <Widget>[
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Cancel"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.orangeAccent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                new SizedBox(width: 10),
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Ok"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    createOpnameDetail(); //HERE SAVE OPNAME
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }

                        if (fnWONUMBER != '' && METHOD_DETAIL == 'PROSES') {
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              title: new Text('Information'),
                              content: new Text("Create new detail opname?"),
                              actions: <Widget>[
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Cancel"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.orangeAccent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                new SizedBox(width: 10),
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Ok"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    createOpnameDetailProses();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }

                        if (fnWONUMBERQC != '' && METHOD_DETAIL == 'QC') {
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              title: new Text('Information'),
                              content: new Text("Create new detail opname?"),
                              actions: <Widget>[
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Cancel"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.orangeAccent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                new SizedBox(width: 10),
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Ok"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    createOpnameDetailQC();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }
                        print('save detail opname');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  )),
                  SizedBox(width: 5),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text(btnNameCreatePR),
                    onPressed: () async {
                      //Navigator.of(context, rootNavigator: false).pop();
                      print('Create PR Number');
                      //id_header  =20;//for dev
                      if (id_header <= 0) return;
                      if (METHOD_DETAIL == "OPNAME") {
                        setState(() {
                          METHOD_DETAIL = 'PURCHASE-ORDER';
                        });
                      }
                      if (btnNameCreatePR.toUpperCase() == "CREATE PR") {
                        showDialog(
                          context: globalScaffoldKey.currentContext!,
                          builder: (context) => new AlertDialog(
                            title: new Text('Information'),
                            content: new Text("Create purchase order"),
                            actions: <Widget>[
                              new ElevatedButton.icon(
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                label: Text("Close"),
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.orange,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 10),
                              new ElevatedButton.icon(
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                label: Text("Submit"),
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  setState(() {
                                    isCreatePrNumber = true;
                                  });
                                  await CreatePurchaseRequest();
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        );
                      }
                      if (btnNameCreatePR.toUpperCase() == "SAVE PR") {
                        print("SAVE PR");
                        SavePurchaseOrder();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  )),
                  SizedBox(width: 5),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("List Detail"),
                    onPressed: () async {
                      print("METHOD ${METHOD_DETAIL}");
                      print("Button List Detail Opname");
                      //txtOpnameVHCID.text = 'B 9474 YU/B 9474 YU'; //DEV
                      //id_header = 3740;
                      if (txtOpnameVHCID.text == null ||
                          txtOpnameVHCID.text == '') {
                        alert(globalScaffoldKey.currentContext!, 0,
                            "Vehicle ID tidak boleh kosong", "error");
                      } else {
                        dataListOpnameDetail = [];
                        await getListDataOpnameDetail(
                            true, id_header.toString(), txtOpnameVHCID.text);

                        await Future.delayed(Duration(milliseconds: 1));
                        if (dataListOpnameDetail.length > 0) {
                          //Navigator.of(context).pop(false);
                          await Future.delayed(Duration(milliseconds: 1));
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: Text('List Detail'),
                                    content: listDataOpnameDetail(context),
                                    actions: <Widget>[
                                      if (METHOD_DETAIL !=
                                          'PURCHASE-ORDER') ...[
                                        Flex(
                                          direction: Axis.horizontal,
                                          children: [
                                            Expanded(
                                                child: ElevatedButton.icon(
                                              icon: Icon(
                                                Icons.book,
                                                color: Colors.white,
                                                size: 15.0,
                                              ),
                                              label: Text(
                                                  "Approve"), //Approve Opname
                                              onPressed: () async {
                                                //selEstimasi = "1";
                                                //id_header=88;
                                                //print('getAkses("FO") ${getAkses("FO")}');
                                                if (username == "ADMIN" ||
                                                    getAkses("SA")) {
                                                  if (txtOpnameVHCID.text ==
                                                          null ||
                                                      txtOpnameVHCID.text ==
                                                          '') {
                                                    alert(
                                                        globalScaffoldKey
                                                            .currentContext!,
                                                        0,
                                                        "Vehicle ID tidak boleh kosong",
                                                        "error");
                                                  } else if (id_header <= 0) {
                                                    alert(
                                                        globalScaffoldKey
                                                            .currentContext!,
                                                        0,
                                                        "ID Opname tidak boleh kosong",
                                                        "error");
                                                  } else if (selEstimasi ==
                                                          null ||
                                                      selEstimasi == "") {
                                                    alert(
                                                        globalScaffoldKey
                                                            .currentContext!,
                                                        0,
                                                        "Estimasi tidak boleh kosong 2",
                                                        "error");
                                                  } else {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          new AlertDialog(
                                                        title: new Text(
                                                            'Information'),
                                                        //content:
                                                        //new Text("Save new request service?"),
                                                        content: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          //position
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          // wrap content in flutter
                                                          children: <Widget>[
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .all(10.0),
                                                              child: Text(
                                                                  "Approve this data?"),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: <Widget>[
                                                          new ElevatedButton
                                                              .icon(
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.white,
                                                              size: 20.0,
                                                            ),
                                                            label:
                                                                Text("Approve"),
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                              await Future.delayed(
                                                                  Duration(
                                                                      milliseconds:
                                                                          1));
                                                              await ApproveOpnameDetail(
                                                                  true,
                                                                  txtOpnameVHCID
                                                                      .text,
                                                                  id_header
                                                                      .toString());
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                    Colors.blue,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            0),
                                                                textStyle: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          new ElevatedButton
                                                              .icon(
                                                            icon: Icon(
                                                              Icons.save,
                                                              color:
                                                                  Colors.white,
                                                              size: 20.0,
                                                            ),
                                                            label:
                                                                Text("Close"),
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                    Colors
                                                                        .orangeAccent,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            0),
                                                                textStyle: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  alert(
                                                      globalScaffoldKey
                                                          .currentContext!,
                                                      0,
                                                      "Anda tidak punya izin untuk melakukan approval",
                                                      "error");
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Colors.blue,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 0),
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )),
                                          ],
                                        )
                                      ],
                                    ]);
                              });
                        } else {
                          //Navigator.of(context).pop(false);
                          await Future.delayed(Duration(milliseconds: 1));
                          alert(context, 2, "tidak ada data yang di temukan",
                              "warning");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  )),
                  //SizedBox(width: 5),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Clear"),
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteItemLogsAll();
                      setState(() {
                        btnNameCreatePR = "Create PR";
                        isCreatePrNumber = false;
                        txtPrNumber.text = "";
                        id_header = 0;
                        wonumberopname = "";
                        txtOpnameVHCID.text = "";
                        txtOpnameMerk.text = "";
                        txtOpnameWONUMBER.text = "";
                        txtGenuineNoOpname.text = "";
                        txtItemID.text = "";
                        txtPartName.text = "";
                        selKatalog = "";
                        selStatusItem = "";
                        txtTypeID.text = "";
                        txtTypeAccess.text = "";
                        txtEstimasi.text = "";
                        selEstimasi = "";
                        METHOD_DETAIL = '';
                        fnVHCID = '';
                        fnSTARTKM = '';
                        fnWONUMBER = '';
                        fnSRNUMBER = '';
                        fnWONUMBERQC = '';
                        nama_katalog = '';
                        status_apr = 'NEW';
                        tab_name = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  )),
                ]),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
          child: Center(
        child: Text(
          "Anda tidak punya akses",
          textAlign: TextAlign.center,
        ),
      ));
    }
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
      child: SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            Container(
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
                  Icon(Icons.car_repair, color: primaryOrange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Data Service Tire',
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(12.0),
              child: TextField(
                cursorColor: primaryOrange,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                controller: txtVHCIDCHK,
                onTap: () => _showModalListVehicleCHK(context),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true,
                  labelText: "Nopol",
                  labelStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: primaryOrange),
                    onPressed: () => _showModalListVehicleCHK(context),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12.0),
              child: TextField(
                readOnly: true,
                cursorColor: primaryOrange,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                controller: txtCabangIdCHK,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true,
                  labelText: "Locid",
                  labelStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12.0),
              child: TextField(
                readOnly: true,
                cursorColor: primaryOrange,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                controller: txtJenisTypeCHK,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true,
                  labelText: "Jenis Type/Kendaraan",
                  labelStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12.0),
              child: TextField(
                readOnly: true,
                cursorColor: primaryOrange,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                controller: txtWOCHK,
                onTap: () => _showModalListWOCHK(context),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true,
                  labelText: "WO Number",
                  labelStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12.0),
              child: TextField(
                cursorColor: primaryOrange,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                controller: txtKMCHK,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  isDense: true,
                  labelText: "Millage/KM",
                  labelStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.all(12.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note Status',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: "0",
                              groupValue: "",
                              onChanged: (value) {},
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green),
                            ),
                            Text('Baik'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: "1",
                              groupValue: "",
                              onChanged: (value) {},
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => primaryOrange),
                            ),
                            Text('Tdk Baik'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: "2",
                              groupValue: "",
                              onChanged: (value) {},
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.red),
                            ),
                            Text('Tdk Ada'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Grouped List ---
            GroupedListView<dynamic, String>(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              elements: dataCHK,
              groupBy: (element) => element['nama_group'],
              groupComparator: (a, b) => b.compareTo(a),
              itemComparator: (a, b) =>
                  a['nama_group'].compareTo(b['nama_group']),
              order: GroupedListOrder.DESC,
              groupSeparatorBuilder: (String value) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (c, element) {
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -4),
                        title:
                            Text("${element['seq']}. ${element['question']}"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 18),
                        child: Row(
                          children: [
                            if (element['baik'] == "1" &&
                                element['type'] == "1")
                              Radio(
                                value: "baik${element['index']}",
                                groupValue:
                                    listChecklistValueCHK[element['index']],
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.green),
                                onChanged: (val) {
                                  setState(() {
                                    listChecklistValueCHK[element['index']] =
                                        val.toString();
                                  });
                                  saveOrUpdate(
                                      element['id_question'],
                                      element['nama_group'],
                                      element['question'],
                                      1,
                                      '',
                                      1);
                                },
                              ),
                            if (element['tidak_baik'] == "1" &&
                                element['type'] == "1")
                              Radio(
                                value: "tidak_baik${element['index']}",
                                groupValue:
                                    listChecklistValueCHK[element['index']],
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.orange),
                                onChanged: (val) {
                                  setState(() {
                                    listChecklistValueCHK[element['index']] =
                                        val.toString();
                                  });
                                  saveOrUpdate(
                                      element['id_question'],
                                      element['nama_group'],
                                      element['question'],
                                      2,
                                      '',
                                      1);
                                },
                              ),
                            if (element['tidak_ada'] == "1" &&
                                element['type'] == "1")
                              Radio(
                                value: "tidak_ada${element['index']}",
                                groupValue:
                                    listChecklistValueCHK[element['index']],
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.red),
                                onChanged: (val) {
                                  setState(() {
                                    listChecklistValueCHK[element['index']] =
                                        val.toString();
                                  });
                                  saveOrUpdate(
                                      element['id_question'],
                                      element['nama_group'],
                                      element['question'],
                                      3,
                                      '',
                                      1);
                                },
                              ),
                            if (element['type'] == "2")
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: TextField(
                                  controller: txtInputCHK,
                                  onChanged: (val) {
                                    if (val.isNotEmpty) {
                                      saveOrUpdate(
                                          element['id_question'],
                                          element['nama_group'],
                                          element['question'],
                                          0,
                                          val,
                                          0);
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: element['question']),
                                ),
                              )
                          ],
                        ),
                      ),
                      if (element['note'] != null && element['note'] != "null")
                        ListTile(
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: -4),
                          title: Text("Note: ${element['note']}"),
                        )
                    ],
                  ),
                );
              },
            ),
            // Button Container
            Container(
              margin: EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      label: Text("Cancel"),
                      onPressed: () async {
                        await DeleteDraft();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 2.0,
                        backgroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      label: Text("Submit"),
                      onLongPress: () async {
                        if (txtCabangIdCHK.text.isEmpty) {
                          alert(context, 2, "Cabang tidak boleh kosong",
                              "warning");
                        } else if (txtVHCIDCHK.text.isEmpty) {
                          alert(context, 2, "Nopol tidak boleh kosong",
                              "warning");
                        } else if (txtJenisTypeCHK.text.isEmpty) {
                          alert(context, 2, "Type Kendaraan tidak boleh kosong",
                              "warning");
                        } else if (txtKMCHK.text.isEmpty ||
                            int.parse(txtKMCHK.text) <= 0) {
                          alert(
                              context,
                              2,
                              "Milage/KM Kendaraan tidak boleh kosong",
                              "warning");
                        } else {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getString("trxnumber_form_check") == null) {
                            alert(context, 2,
                                "Anda belum memilih form checklist", "warning");
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: cardColor,
                                title: Text('Information',
                                    style: TextStyle(
                                      color: darkOrange,
                                      fontWeight: FontWeight.w600,
                                    )),
                                content: Text("Save data form checklist?"),
                                actions: [
                                  ElevatedButton(
                                    child: Text("Cancel"),
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 2.0,
                                      backgroundColor: Colors.grey.shade500,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    child: Text("Ok"),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await UpdateAll();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 2.0,
                                      backgroundColor: primaryOrange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 2.0,
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
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
                  "SR Number: ${item['srnumber']}",
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
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: DefaultTabController(
        length: lengTabs,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange,
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
                Tab(icon: Icon(Icons.list), child: Text('SERAH TERIMA')),
                Tab(icon: Icon(Icons.list), child: Text('OPNAME')),
                Tab(icon: Icon(Icons.list), child: Text('LIST TMS')),
                Tab(icon: Icon(Icons.list), child: Text('FINISH TMS')),
              ],
            ),
            title: Text('Tire Managament'),
          ),
          body: TabBarView(
            key: globalScaffoldKey,
            controller: _tabController,
            children: [
              _buildListViewTmsTyre(context),
              _buildListViewOPNAME(context),
              _buildListViewStart(context),
              _buildListViewFinish(context),
            ],
          ),
        ),
      ),
    );
  }
}
