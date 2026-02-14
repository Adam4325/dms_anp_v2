import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewListMcnDetail.dart';
import 'package:dms_anp/src/pages/maintenance/FrmServiceRequestTms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../flusbar.dart';
// import 'package:qrscan/qrscan.dart' as scanner; // removed - migrate to mobile_scanner
import '../../../choices.dart' as choices;
import 'package:dms_anp/src/Helper/globals.dart' as globals;

String scanResult = '';
var is_edit_req = false;
var srnumber = "";

List<dynamic> dataCHK = [];
List listChecklistValueCHK = [];
List listVehicleIdCHK = [];
List listWONumberCHK = [];
List dummySearchListCHK = [];
List listLocidCHK = [];
List dummySearchListCabangCHK = [];
TextEditingController txtSearchVehicleCHK = new TextEditingController();
TextEditingController txtSearchWOCHK = new TextEditingController();
TextEditingController txtVehicleNameCHK = new TextEditingController();
TextEditingController txtVHCIDCHK = new TextEditingController();
TextEditingController txtVehicleIdListCHK = new TextEditingController();
TextEditingController txtSearchCabangNameCHK = new TextEditingController();
TextEditingController txtCabangNameCHK = new TextEditingController();
TextEditingController txtCabangIdCHK = new TextEditingController();
TextEditingController txtWOCHK = new TextEditingController();
TextEditingController txtJenisTypeCHK = new TextEditingController();
TextEditingController txtKMCHK = new TextEditingController();
TextEditingController txtInputCHK = new TextEditingController();

String btnSubmitText = "Save Request";
String btnSubmitTextBanLuar = "Next";
List collectionDriver = [];
List collectionVehicle = [];
List listDriverId = [];
List listBanSR = [];
List dummylistBanSR = [];
List listMechanicId = [];
List dummySearchListMcn = [];
List dummySearchList = [];
List dummySearchList2 = [];
List dummySearchListCabang2 = [];
List dummySearchListCabang = [];
List dummySearchListBengkel = [];
List listVehicleId = [];
List dataSRType = [];
List listLocid = [];
List listBengkel = [];
TextEditingController txtDriverName = new TextEditingController();
TextEditingController txtVehicleName = new TextEditingController();
TextEditingController txtDriverIdList = new TextEditingController();
TextEditingController txtVehicleIdList = new TextEditingController();
TextEditingController txtCabangName = new TextEditingController();
TextEditingController txtBengkelName = new TextEditingController();
TextEditingController txtCabangId = new TextEditingController();
TextEditingController txtBengkelId = new TextEditingController();
TextEditingController txtSrType = new TextEditingController();
TextEditingController txtSrTypeId = new TextEditingController();

TextEditingController txtSearchDriver = new TextEditingController();
TextEditingController txtSearchVehicleSr = new TextEditingController();
TextEditingController txtSearchPartname = new TextEditingController();
TextEditingController txtSearchItem = new TextEditingController();
TextEditingController txtSearchVehicle = new TextEditingController();
TextEditingController txtSearchCabangName = new TextEditingController();
TextEditingController txtSearchBengkelName = new TextEditingController();
TextEditingController txtSearchMechanic = new TextEditingController();
TextEditingController txtNotesAlert = new TextEditingController();
TextEditingController txtWorkedBy = new TextEditingController();
TextEditingController txtWorkedById = new TextEditingController();

TextEditingController txtWorkedBy2 = new TextEditingController();
TextEditingController txtWorkedById2 = new TextEditingController();

TextEditingController txtWorkedByIdStart = new TextEditingController();
TextEditingController txtWorkedByStart = new TextEditingController();

TextEditingController txtWorkedByIdStop = new TextEditingController();
TextEditingController txtWorkedByStop = new TextEditingController();

TextEditingController txtOpnameVHCID = new TextEditingController();
TextEditingController txtOpnameWONUMBER = new TextEditingController();

// class Debouncer {
//   final Duration delay;
//   Timer _timer;
//
//   Debouncer({this.delay});
//
//   run(Function action) {
//     _timer?.cancel();
//     _timer = Timer(delay, action);
//   }
// }

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
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
                      txtVehicleNameCHK.text =
                          listVehicleIdCHK[index]['vhcid'].toString();
                      txtVehicleIdListCHK.text =
                          listVehicleIdCHK[index]['vhcid'].toString();
                      txtVHCIDCHK.text =
                          listVehicleIdCHK[index]['vhcid'].toString();
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

class _BottomSheetContentCabangCHK extends StatelessWidget {
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // onChanged: (value) {
              //   //filterSearchResultsDriver(value);
              // },
              controller: txtSearchCabangNameCHK,
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
              itemCount: listLocidCHK == null ? 0 : listLocidCHK.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtCabangNameCHK.text =
                          listLocidCHK[index]['text'].toString();
                      txtCabangIdCHK.text =
                          listLocidCHK[index]['id'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listLocidCHK[index]['text']}"),
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

class listBanFitTyre {
  String genuino;
  String fitpost;

  listBanFitTyre({required this.genuino, required this.fitpost});

  Map<String, dynamic> toMap() {
    return {'genuino': genuino, 'fitpost': fitpost};
  }

  listBanFitTyre.fromMap(Map<String, dynamic> tyreFitMaps)
      : genuino = tyreFitMaps["genuino"],
        fitpost = tyreFitMaps["fitpost"];
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
                    onTap: () async {
                      Navigator.of(context).pop();
                      txtVehicleName.text =
                          listVehicleId[index]['title'].toString();
                      txtVehicleIdList.text =
                          listVehicleId[index]['value'].toString();
                      txtOpnameVHCID.text =
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // onChanged: (value) {
              //   //filterSearchResultsDriver(value);
              // },
              controller: txtSearchCabangName,
              decoration: InputDecoration(
                  labelText: "Search cabang",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listLocid == null ? 0 : listLocid.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtCabangName.text = listLocid[index]['text'].toString();
                      txtCabangId.text = listLocid[index]['id'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listLocid[index]['text']}"),
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

class _BottomSheetContentBengkel extends StatelessWidget {
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
                "List Bengkel",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                //filterSearchResultsDriver(value);
              },
              controller: txtSearchBengkelName,
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
              itemCount: listBengkel == null ? 0 : listBengkel.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtBengkelName.text =
                          listBengkel[index]['text'].toString();
                      txtBengkelId.text = listBengkel[index]['id'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${listBengkel[index]['text']}"),
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
              //   List dummyListData2 = [];
              //   if (value != "" && value != null) {
              //     print(value);
              //     if (value.length >= 3) {
              //       for (var i = 0; i < dummySearchListMcn.length; i++) {
              //         var dtC = dummySearchListMcn[i]['title'].toLowerCase().toString();
              //         print("${dtC} => ${value.toLowerCase().toString()}");
              //         if (dtC.contains(value.toLowerCase().toString())) {
              //           print(dtC);
              //           dummyListData2.add({
              //             "value": dummySearchListMcn[i]['value'].toString(),
              //             "title": dummySearchListMcn[i]['title']
              //           });
              //         }
              //       }
              //     }
              //     if (dummyListData2.length > 0) {
              //       listMechanicId = [];
              //       listMechanicId = dummyListData2;
              //     }
              //     //return;
              //   }
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

class _BottomSheetContentMechanicStart extends StatelessWidget {
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
                      txtWorkedByIdStart.text =
                          listMechanicId[index]['value'].toString();
                      txtWorkedByStart.text =
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

class _BottomSheetContentMechanicStop extends StatelessWidget {
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
                      txtWorkedByIdStop.text =
                          listMechanicId[index]['value'].toString();
                      txtWorkedByStop.text =
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

class _BottomSheetContentMechanic2 extends StatelessWidget {
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
                      txtWorkedById2.text =
                          listMechanicId[index]['value'].toString();
                      txtWorkedBy2.text =
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
                      //print(txtSrTypeId.text);
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

class FrmServiceRequestOpr extends StatefulWidget {
  @override
  _FrmServiceRequestOprState createState() => _FrmServiceRequestOprState();
}

class _FrmServiceRequestOprState extends State<FrmServiceRequestOpr>
    with SingleTickerProviderStateMixin {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  bool _buttonActive = false;
  ProgressDialog? pr;
  var id_header = 0;
  var wonumberopname = "";
  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  final String BASE_URL =
      GlobalData.baseUrl; // "http://apps.tuluatas.com:8080/trucking";
  int status_code = 0;
  int lengTabs = 6;
  late WebViewController _controllerWeb;
  var mechanicID;
  var listItemApprove = [];
  String selMechanicProses = '';
  List<Map<String, dynamic>> lstMechanicID = [];
  String message = "";
  FocusNode myFocusNode = FocusNode();
  late TabController _tabController;
  TextEditingController txtVehicleId = new TextEditingController();
  TextEditingController txtDriverId = new TextEditingController();

  TextEditingController txtDate = new TextEditingController();
  TextEditingController txtSRNumber = new TextEditingController();
  TextEditingController txtStatus = new TextEditingController();
  TextEditingController txtFromLocid = new TextEditingController();
  TextEditingController txtToLocid = new TextEditingController();
  TextEditingController txtNotes = new TextEditingController();
  TextEditingController txtWodNotes = new TextEditingController();
  TextEditingController txtNotesStart = new TextEditingController();
  TextEditingController txtMCIDStart = new TextEditingController();
  TextEditingController txtNotesStop = new TextEditingController();
  TextEditingController txtMCIDStop = new TextEditingController();
  TextEditingController txtWodCloseNotes = new TextEditingController();
  TextEditingController txtWodCloseNotesQC = new TextEditingController();
  TextEditingController txtApprNotes = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  //extEditingController txtSearchVehicle = new TextEditingController();
  TextEditingController txtSearchVehicleFinish = new TextEditingController();
  TextEditingController txtSearchVehicleQC = new TextEditingController();
  TextEditingController txtSearchVehicleStart = new TextEditingController();
  TextEditingController txtSearchListBan = new TextEditingController();
  TextEditingController txtSearchListBanFinish = new TextEditingController();
  TextEditingController txtSearchListBanQC = new TextEditingController();
  TextEditingController txtGenuinoFinish = new TextEditingController();
  TextEditingController txtGenuino = new TextEditingController();
  TextEditingController txtGenuinoQC = new TextEditingController();
  TextEditingController txtfitPost = new TextEditingController();
  TextEditingController txtEstimasi = new TextEditingController();
  List<S2Choice<String>> listStatusRequest = [];

  List<Map<String, dynamic>> collOpnameDetails = [];
  List<Map<String, dynamic>> collTyreFit = [];
  List<Map<String, dynamic>> collTyreNumber = [];
  List<Map<String, dynamic>> dataListTyreFit = [];
  List<Map<String, dynamic>> dataListTyreFitQC = [];
  List<Map<String, dynamic>> dataListOpnameDetail = [];
  List<Map<String, dynamic>> dataListSrOpname = [];
  List<Map<String, dynamic>> dataListItemSearch = [];
  List<Map<String, dynamic>> dataListMechanicProses = [];

  TextEditingController txtCatalog = new TextEditingController();
  TextEditingController txtItemID = new TextEditingController();
  TextEditingController txtPartName = new TextEditingController();
  TextEditingController txtItemSize = new TextEditingController();
  TextEditingController txtTypeID = new TextEditingController();
  TextEditingController txtTypeAccess = new TextEditingController();
  TextEditingController txtGenuineNoOpname = new TextEditingController();
  TextEditingController txtOpnameMerk = new TextEditingController();
  TextEditingController txtOpnameQty = new TextEditingController();
  TextEditingController txtOpnameQtyEditProses = new TextEditingController();
  TextEditingController txtOpnameQtyEditQC = new TextEditingController();
  //TextEditingController txtOpnameEstimasi = new TextEditingController();
  String selKatalog = "";
  String selEstimasi = "";
  List<Map<String, dynamic>> lstVKatalog = [];

  void _showModalListVehicleCHK(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentVehicleCHK();
      },
    );
  }

  void _showModalListWOCHK(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentWONumberCHK();
      },
    );
  }

  void _showModalListCabangCHK(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentCabangCHK();
      },
    );
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

  void _searchCabangNameCHK() {
    List dummyListData2 = [];
    if (txtSearchCabangNameCHK.text != "" &&
        txtSearchCabangNameCHK.text != null) {
      if (txtSearchCabangNameCHK.text.length >= 3) {
        for (var i = 0; i < dummySearchListCHK.length; i++) {
          var dtC =
              dummySearchListCabangCHK[i]['value'].toLowerCase().toString();
          //print("${dtC} => ${txtSearchCabangNameCHK.text.toLowerCase().toString()}");
          if (dtC
              .contains(txtSearchCabangNameCHK.text.toLowerCase().toString())) {
            //print(dtC);
            dummyListData2.add({
              "value": dummySearchListCabangCHK[i]['value'].toString(),
              "title": dummySearchListCabangCHK[i]['title']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listLocidCHK = [];
            listLocidCHK = dummyListData2;
          });
        }
      }
      return;
    }
  }

  Future getListCabangCHK() async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/maintenance/sr/refferencce_mcn.jsp?method=list_cabang");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      listLocidCHK = json.decode(response.body);
      //print(listLocidCHK);
      if (listLocidCHK.length == 0 && listLocidCHK == []) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal Load data list cabang", "error");
      } else {
        listLocidCHK = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        dummySearchListCabangCHK = listLocidCHK;
      }
    } else {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal Load data Type List Cabang", "error");
    }
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

  void saveOrUpdateTest(String id, String group_name, String nama_form_check,
      int pilihan, String input, int is_multiple) async {
    print('test');
  }

  void saveOrUpdate(String id, String group_name, String nama_form_check,
      int pilihan, String input, int is_multiple) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String vhcid = txtVHCIDCHK.text;
    var uuid = Uuid();
    var userid = prefs.getString("username") ?? "";
    if (prefs.getString("trxnumber_form_check") == null) {
      prefs.setString("trxnumber_form_check", uuid.v1());
    }
    var trxnumber = prefs.getString("trxnumber_form_check") ?? "";
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
      var trxnumber = prefs.getString("trxnumber_form_check") ?? "";
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

  Future UpdateAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var vhcid = txtVHCIDCHK.text;
    var locid = txtCabangIdCHK.text;
    var vhtalias = txtJenisTypeCHK.text;
    var odometer = txtKMCHK.text;
    var wodwonumber = txtWOCHK.text;
    var trxnumber = prefs.getString("trxnumber_form_check") ?? "";
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

  Future<String> getListMechanicID(String wonumber) async {
    String status = "";
    var urlData =
        "${BASE_URL}api/maintenance/sr/list_mechanicid.jsp?method=list-mechanicid&wonumber=${wonumber}";
    print(urlData);
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstMechanicID = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
      }
    });
    return status;
  }

  void loopData() {
    for (var i = 0; i < 10; i++) {
      collTyreFit.add({"genuino": i.toString(), "fitpost": i.toString()});
    }

    collTyreFit.removeWhere((element) => element["genuino"] == "1");
    for (var i = 0; i < collTyreFit.length; i++) {
      //print(collTyreFit[i]);
    }
  }

  List dataListOprsStart = []; //FOREMAN
  List dataListOprsFinish = [];
  List dataListOprsQC = [];
  List dataListOprsFinishDummy = [];
  List dataListOprsQCDummy = [];
  List dataListOprsStartDummy = [];
  List<String> selFitPost = [];
  String selFitPostName = '';
  var selFitPostId = "";
  var selFitPostIdFinish = "";
  var selFitPostIdQC = "";
  var selStatusItem = "";
  var selStatusItemEditProses = "";
  var selStatusItemEditQC = "";
  List<String> collectionTyreFit = [];
  int _currentIndex = 0;
  String bSave = "Save Request";
  String bUpdate = "Update Request";
  String bUpdateFOREMAN = "Update Foreman";

  //VARIABLE FRIT
  // TBLTYREFIT = SNTYRE_STATUS
  // FITTYREID = ITDITEMID
  // FITSERIALNO = TYRENUMBER
  // STARTDATE = CURDATE
  // STARTKM = KM MOBIL TERAKHIR (TBLVEHICLE/VHCKM)
  // TYREBRAND = MERK
  // TYREPATTERN =  ITMALIAS
  // TYREPRICE = ITDUNITCOST
  // GENUINENO = ORIGINAL_SN
  String METHOD_DETAIL = '';
  String fnVHCID = '';
  String fnVHCIDQC = '';
  String fnFITTYREID = '';
  String fnFITSERIALNO = '';
  String fnSTARTDATE = '';
  String fnSTARTKM = '0';
  String fnSTARTKMQC = '0';
  String fnTYREBRAND = '';
  String fnTYREPATTERN = '';
  String fnTYREPRICE = '';
  String fnGENUINENO = '';
  String fnFitPost = '';
  String fnWONUMBER = '';
  String fnSRNUMBER = '';
  String fnWONUMBERQC = '';

  //
  _goBack(BuildContext context) {
    if (this.mounted) {
      DeleteDraft();
    }
    resetTeks();
    btnSubmitText = bSave;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
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
    fnWONUMBERQC = '';
    selFitPostIdFinish = '';
    selFitPostIdQC = '';
    //List<String> collectionTyreFitFinish = [];
  }

  void resetTeks() {
    setState(() {
      selFitPostName = '';
      status_code = 0;
      message = "";
      txtDate.text = "";
      txtSRNumber.text = "";
      txtKM.text = "0";
      txtWodNotes.text = "";
      txtWodCloseNotes.text = "";
      txtWodCloseNotesQC.text = "";
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
      selFitPost = [];
      selFitPostId = '';
      txtfitPost.text = "";
      txtGenuino.text = "";
      txtGenuinoQC.text = "";
      selFitPostId = "";
      collTyreFit = [];
      collTyreNumber = [];
      selFitPostName = '';
      txtNotesStart.text = '';
      txtWorkedByStart.text = '';
      txtWorkedByIdStart.text = '';

      txtNotesStop.text = '';
      txtWorkedByStop.text = '';
      txtWorkedByIdStop.text = '';

      btnSubmitText = bSave;
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

  void _showModalListMechanicStart(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentMechanicStart();
      },
    );
  }

  void _showModalListMechanicStop(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentMechanicStop();
      },
    );
  }

  void _showModalListMechanic2(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentMechanic2();
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

  void _showModalListBengkel(BuildContext context) {
    if (is_edit_req == false) {
      showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return _BottomSheetContentBengkel();
        },
      );
    }
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

  //Future<String> getVehicleType() async {
  Future<String> getMenuKatalog() async {
    String status = "";
    var urlData =
        "${BASE_URL}api/maintenance/sr/menu_opname.jsp?method=menu-sr";

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
      }
    });
    return status;
  }

  Future getListBanTMS(bool isload, String search) async {
    try {
      if (isload) {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
      }

      var urlData = search == null || search == ''
          ? "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-ban-sr"
          : "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-ban-sr&search=${search}";
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
          //print('loaded ban tms ${listBanTms.length}');
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

  Future getListBanTMSQC(bool isload, String search) async {
    try {
      if (isload) {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
      }

      var urlData = search == null || search == ''
          ? "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-qc-sr"
          : "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-qc-sr&search=${search}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listBanTmsQC = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          //print('loaded qc tms ${listBanTmsQC.length}');
          dummylistBanTmsQC = listBanTmsQC;
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
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver $e",
          "error");
      print(e.toString());
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
      //print(dataSRType);
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

  Future getListCabang() async {
    Uri myUri = Uri.parse(
        "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list_cabang");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      listLocid = json.decode(response.body);
      listBengkel = listLocid;
      //print(listLocid);
      if (listLocid.length == 0 && listLocid == []) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal Load data list cabang", "error");
      } else {
        listLocid = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
        listBengkel = listLocid;
        dummySearchListCabang = listBengkel;
        dummySearchListBengkel = listLocid;
      }
    } else {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal Load data Type List Cabang", "error");
    }
  }

  void getVehicleList(String cabangId) async {
    if (is_edit_req == true) return;
    try {
      var urlData =
          "${BASE_URL}api/maintenance/sr/list_vehicle.jsp?method=lookup-vehicle-v1&locid=" +
              cabangId;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
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

  Future scanQRCode() async {
    // TODO: Migrate to mobile_scanner - qrscan package removed
    alert(globalScaffoldKey.currentContext!, 2,
        "Fitur scan QR perlu migrasi ke mobile_scanner", "warning");
  }

  void updateButtonState(String text) {
    // if text field has a value and button is inactive
    if (text != null && text.length > 0 && !_buttonActive) {
      setState(() {
        _buttonActive = true;
        getItemByText(text);
      });
    } else if ((text == null || text.length == 0) && _buttonActive) {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  Future getItemByText(String itemIDs) async {
    setState(() {
      var itemID = itemIDs;
      var url =
          "${BASE_URL}api/inventory/list_item_barcode_mobile.jsp?method=list-items-v1&warehouseid=${globals.from_ware_house}&search=$itemID&is_barcode=1";
      getItemBarcode(url, itemIDs);
    });
  }

  void saveFitPost() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (fnVHCID == null || fnVHCID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (id_header == 0) {
        alert(
            globalScaffoldKey.currentContext!,
            0,
            "Opname number tidak boleh kosong, silahkan di buat terlebih dahulu, create Opname",
            "error");
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
        EasyLoading.show();
        print('SAVE GENUINE DETAIL');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_delete_tyre_fit.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        print('txtfitPost.text ${txtfitPost.text}');
        var data = {
          'method': "create-item-fitpost-v2",
          'wonumber': fnWONUMBER,
          'id_header': id_header,
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
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void saveFitPostQC() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (fnVHCID == null || fnVHCID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      } else if (id_header == 0) {
        alert(
            globalScaffoldKey.currentContext!,
            0,
            "Opname number tidak boleh kosong, silahkan di buat terlebih dahulu, create Opname",
            "error");
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
        EasyLoading.show();
        print('SAVE GENUINE DETAIL');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_delete_tyre_fit.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        print('txtfitPost.text ${txtfitPost.text}');
        var data = {
          'method': "create-item-fitpost-v2",
          'wonumber': fnWONUMBER,
          'id_header': id_header,
          'vhcid': fnVHCIDQC,
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
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
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

  void DeleteOpnameSrDetail(int id_header, int id_detail) async {
    try {
      if (id_header <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "ID tidak boleh kosong",
            "error");
      } else if (id_detail <= 0) {
        alert(globalScaffoldKey.currentContext!, 0,
            "ID Detail tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_opname_sr.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': "delete-opname-detail",
          'id_header': id_header.toString(),
          'id_detail': id_detail.toString(),
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

  void createOpnameDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (txtOpnameVHCID.text == null || txtOpnameVHCID.text == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "VEHICLE ID tidak boleh kosong", "error");
      }
      // else if (selEstimasi == null || selEstimasi == "") {
      //   alert(globalScaffoldKey.currentContext!, 0,
      //       "Estimasi tidak boleh kosong", "error");
      // }
      else if (txtOpnameQty.text == null || txtOpnameQty.text == "") {
        alert(globalScaffoldKey.currentContext!, 0, "QTY tidak boleh kosong",
            "error");
      } else if (int.parse(txtOpnameQty.text) <= 0 &&
          selStatusItem != 'Perbaikan') {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else {
        EasyLoading.show();
        print('Create New OPNAME');
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_opname_sr_detail.jsp");
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
      } else if (int.parse(txtOpnameQty.text) <= 0) {
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
      } else if (int.parse(txtOpnameQty.text) <= 0) {
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

  Future DeleteTyreFit(bool isload, String wonumber, String id) async {
    try {
      EasyLoading.show();

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

  Future DeleteViewProses(bool isload, String wonumber, String id) async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var urlData =
          "${BASE_URL}api/maintenance/sr/create_delete_tyre_fit.jsp?method=delete-item-view-proses-v1&wonumber=${wonumber}&id=${id}&userid=${userid.toUpperCase()}";
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
          await getListViewProses(true, wonumber);
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
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data list",
            "error");
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

  Future DeleteViewQC(bool isload, String wonumber, String id) async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var urlData =
          "${BASE_URL}api/maintenance/sr/create_delete_tyre_fit.jsp?method=delete-item-view-proses-v1&wonumber=${wonumber}&id=${id}&userid=${userid.toUpperCase()}";
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
          await getListViewQC(true, wonumber);
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
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data list",
            "error");
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

  Future DeleteTyreFitQC(bool isload, String wonumber, String id) async {
    try {
      EasyLoading.show();

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

  Future CreateStartStop(bool isload, String mechanic_id, String notes,
      String event_name, String wonumber, String srnumber) async {
    try {
      EasyLoading.show();
      //var mcid = '';
      // if (mechanicID == 'MechanicID 1') {
      //   mcid = '1';
      // }
      // if (mechanicID == 'MechanicID 2') {
      //   mcid = '2';
      // }
      var urlData =
          "${BASE_URL}api/maintenance/sr/create_or_update.jsp?method=create-start-stop-v2&wonumber=${wonumber}&srnumber=${srnumber}&event_name=${event_name}&mechanic_id=${mechanic_id}&notes=${notes}&mcid=${mechanicID}&userid=${userid.toUpperCase()}";
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
          if (event_name == 'start') {
            setState(() {
              txtWorkedByIdStart.text = '';
              txtWorkedByStart.text = '';
              txtNotesStart.text = '';
            });
          }

          if (event_name == 'stop') {
            setState(() {
              txtWorkedByIdStop.text = '';
              txtWorkedByStop.text = '';
              txtNotesStop.text = '';
            });
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
        alert(globalScaffoldKey.currentContext!, 0, "Gagal create start/ stop",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, create start/ stop",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future DeleteOpnameDetail(bool isload, String vehicle_id, String id) async {
    try {
      EasyLoading.show();
      //"${BASE_URL}api/maintenance/sr/delete_opname_sr_detail.jsp?method=delete-detail&vhcid=${vehicle_id}&id=${id}&userid=${userid.toUpperCase()}";
      var urlData =
          "${BASE_URL}api/maintenance/sr/delete_opname_sr_detail.jsp?method=delete-detail&vhcid=${vehicle_id}&id=${id}&userid=${userid.toUpperCase()}";
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

  Future getListTyreFit(bool isload, String wonumber) async {
    try {
      EasyLoading.show();

      var urlData =
          "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-tyre-fit-by-wo&wonumber=${wonumber}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
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

  Future getListViewProses(bool isload, String wonumber) async {
    try {
      EasyLoading.show();

      var urlData =
          "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-view-proses-by-wo&wonumber=${wonumber}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
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

  Future getListViewQC(bool isload, String wonumber) async {
    try {
      EasyLoading.show();

      var urlData =
          "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-view-qc-by-wo&wonumber=${wonumber}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListTyreFitQC = (jsonDecode(response.body) as List)
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

  Future getListTyreFitQC(bool isload, String wonumber) async {
    try {
      EasyLoading.show();

      var urlData =
          "${BASE_URL}api/maintenance/sr/refferencce_mcn.jsp?method=list-tyre-fit-by-wo-qc&wonumber=${wonumber}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListTyreFitQC = (jsonDecode(response.body) as List)
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

  Future getListDataOpnameDetail(
      bool isload, String id_header, String vehicle_id) async {
    try {
      EasyLoading.show();

      var urlData =
          "${BASE_URL}api/maintenance/sr/list_opname_sr_detail.jsp?method=list-opname-sr-detail&id_header=${id_header}&vhcid=${vehicle_id}";
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

  Future getListDataSr(bool isload, String search) async {
    try {
      EasyLoading.show();

      var urlData = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-oprs-v1&search=" +
              search);
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

  Future getListDataSrForeman(bool isload, String search) async {
    try {
      EasyLoading.show();

      var urlData = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-oprs-v1&search=" +
              search);
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

  Future getListDataItem(bool isload, String search, int is_barcode) async {
    try {
      EasyLoading.show();

      var url =
          "${BASE_URL}api/inventory/list_item_sr_katalog.jsp?method=list-items-v1&warehouseid=${globals.from_ware_house}&search=${search}&katalog=${selKatalog}&is_barcode=${is_barcode}&status_apr=${status_apr}";

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

  Future getListDataListMechanic(String wodwonumber) async {
    try {
      EasyLoading.show();
      dataListMechanicProses = [];
      var url =
          "${BASE_URL}api/maintenance/sr/list_mechanicid_detail_jobs.jsp?method=list-mechanicid-detail-proses&wodwonbr=${wodwonumber}";

      var urlData = Uri.parse(url);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListMechanicProses = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
        if (dataListMechanicProses.length <= 0) {
          alert(globalScaffoldKey.currentContext!, 2,
              "List Detail Mechanic belum ada", "Warning");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list mechanic", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data mechanic",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  void saveRequestService(
      String methods,
      String isBanLuar,
      String fittyreid,
      String fitserialno,
      String startdate,
      String startkm,
      String tyrebrand,
      String tyrepattern,
      String tyreprice,
      String genuino) async {
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
      var bengkelid = txtBengkelId.text;

      var resultFitPost = selFitPostName;
      //var resultFitPost = selFitPost.join(';');
      //print(resultFitPost);
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
      }
      // else if (isBanLuar == 'yes' && (fittyreid == null || fittyreid == "")) {
      //   alert(globalScaffoldKey.currentContext!, 0,
      //       "ID ITEMID tidak boleh kosong", "error");
      // } else if (isBanLuar == 'yes' &&
      //     (fitserialno == null || fitserialno == "")) {
      //   alert(globalScaffoldKey.currentContext!, 0,
      //       "Tyre Number tidak boleh kosong", "error");
      // } else if (isBanLuar == 'yes' && (startdate == null || startdate == "")) {
      //   alert(globalScaffoldKey.currentContext!, 0,
      //       "Start Date tidak boleh kosong", "error");
      // } else if (isBanLuar == 'yes' && (tyrebrand == null || tyrebrand == "")) {
      //   alert(globalScaffoldKey.currentContext!, 0, "Merk tidak boleh kosong",
      //       "error");
      // } else if (isBanLuar == 'yes' &&
      //     (tyrepattern == null || tyrepattern == "")) {
      //   alert(globalScaffoldKey.currentContext!, 0,
      //       "Item Alias tidak boleh kosong", "error");
      // }
      else if (isBanLuar == 'yes' &&
          (resultFitPost == null || resultFitPost == "")) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Fit Post tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        //print('txtfitPost.text ${txtfitPost.text} ${is_edit_req} ${methods}');
        var method = is_edit_req == false && methods == "save"
            ? 'create-request-sr-v2'
            : 'update-request-sr-v2';
        var data = {
          'method': method,
          'srnumber': srnumber,
          'vhcid': vehicleId,
          'drvid': driverId,
          'date': date,
          'status': status,
          'locid': locid,
          'bengkelid': bengkelid,
          'userid': userid.toUpperCase(),
          'srTypeId': txtSrTypeId.text,
          'totalKM': txtKM.text,
          'notes': notes,
          'is_banluar': isBanLuar,
          'fittyreid': fittyreid,
          'fitserialno': fitserialno,
          'startdate': startdate,
          'startkm': txtKM.text, //startkm,
          'tyrebrand': tyrebrand,
          'tyrepattern': tyrepattern,
          'tyreprice': tyreprice,
          'genuino': genuino,
          'fitpost': resultFitPost,
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

  void startRequestService(
      String stSRNumber,
      String wodWONBR,
      String workedby,
      String workedby2,
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
          'woworkedby2': workedby2,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'totalKM': totalKM,
          'userid': userid.toUpperCase(),
          'wodnotes': wodnotes,
          'company': 'AN',
          "next": "approve",
          "srTypeId": _srTypeId,
        };
        //(data);
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

  void startRequestServiceForeman(
      String stSRNumber,
      String wodWONBR,
      String workedby,
      String workedby2,
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
      }
      // else if (_srTypeId == null || _srTypeId == "") {
      //   alert(globalScaffoldKey.currentContext!, 0,
      //       "Service ID tidak boleh kosong", "error");
      // }
      else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'start-request-sr-foreman-v1';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'wodwonumber': wodWONBR,
          'woworkedby': workedby,
          'woworkedby2': workedby2,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'totalKM': totalKM,
          'userid': userid.toUpperCase(),
          'wodnotes': wodnotes,
          'company': 'AN',
          "next": "approve",
          "srTypeId": _srTypeId,
        };
        //print(data);
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

  void closeWoRequestService(String stSRNumber, String stWODNbr, String stVHCID,
      stDRVID, String woPrint, String wodNotes) async {
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
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'close-request-sr-v2';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'wodnumber': stWODNbr,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'woprint': woPrint,
          'wodnotes': wodNotes,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        //print(data);
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

  void closeWoRequestServicePROSES(String stSRNumber, String stWODNbr,
      String stVHCID, stDRVID, String woPrint, String wodNotes) async {
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
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'close-request-sr-proses-v2';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'wodnumber': stWODNbr,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'woprint': woPrint,
          'wodnotes': wodNotes,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        //print(data);
        //EasyLoading.show();
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

  void closeWoRequestServiceQC(String stSRNumber, String stWODNbr,
      String stVHCID, stDRVID, String woPrint, String wodNotes) async {
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
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'close-request-sr-qc-v2';
        var data = {
          'method': method,
          'srnumber': stSRNumber,
          'wodnumber': stWODNbr,
          'vhcid': stVHCID,
          'drvid': stDRVID,
          'woprint': woPrint,
          'wodnotes': wodNotes,
          'userid': userid.toUpperCase(),
          'company': 'AN'
        };
        //print(data);
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
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            //print(response);
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

  void cancelRequestServiceForeman(
      String stSRNumber, String stVHCID, stDRVID) async {
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
        //print(data);
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
        //print(data);
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
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            //print(response);
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

  void UpdateDetailProses(String detail_id, String item_id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var qty = txtOpnameQtyEditProses.text;
      var status_item = selStatusItemEditProses;
      if (detail_id == null || detail_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Detail ID tidak boleh kosong", "error");
      } else if (item_id == null || item_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "ITEM ID tidak boleh kosong", "error");
      } else if (selStatusItemEditProses == null ||
          selStatusItemEditProses == "") {
        alert(globalScaffoldKey.currentContext!, 0, "STatus tidak boleh kosong",
            "error");
      } else if (qty == null || qty == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "ITEM ID tidak boleh kosong", "error");
      } else if (int.parse(detail_id) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "Detail ID tidak boleh 0",
            "error");
      } else if (int.parse(detail_id) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "Detail ID tidak boleh 0",
            "error");
      } else if (int.parse(qty) <= 0) {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': "update-proses-detail",
          'id_detail': detail_id,
          'item_id': item_id,
          'status_item': selStatusItemEditProses,
          'qty': qty,
          'userid': userid
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
                        setState(() {
                          selStatusItemEditProses = "";
                          txtOpnameQtyEditProses.text = "";
                        });
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

  void UpdateDetailQC(String detail_id, String item_id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var qty = txtOpnameQtyEditQC.text;
      var status_item = selStatusItemEditQC;
      if (detail_id == null || detail_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Detail ID tidak boleh kosong", "error");
      } else if (item_id == null || item_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "ITEM ID tidak boleh kosong", "error");
      } else if (selStatusItemEditProses == null ||
          selStatusItemEditProses == "") {
        alert(globalScaffoldKey.currentContext!, 0, "STatus tidak boleh kosong",
            "error");
      } else if (qty == null || qty == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "ITEM ID tidak boleh kosong", "error");
      } else if (int.parse(detail_id) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "Detail ID tidak boleh 0",
            "error");
      } else if (int.parse(detail_id) <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "Detail ID tidak boleh 0",
            "error");
      } else if (int.parse(qty) <= 0) {
        alert(
            globalScaffoldKey.currentContext!, 0, "QTY tidak boleh 0", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${BASE_URL}api/maintenance/sr/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': "update-qc-detail",
          'id_detail': detail_id,
          'item_id': item_id,
          'status_item': selStatusItemEditQC,
          'qty': qty,
          'userid': userid
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
                        setState(() {
                          selStatusItemEditQC = "";
                          txtOpnameQtyEditQC.text = "";
                        });
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

  var username = "";
  var userid = "";
  var locid = "";

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";
    userid = prefs.getString("name") ?? "";
    locid = prefs.getString("locid") ?? "";
    //listLocid = locid.split(',');
    //print(listLocid);
  }

  //FOREMAN
  Future<String> getJSONData(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        EasyLoading.show();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-oprs-foreman-v1&search=" +
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
        //print(dataListOprsStart);
        if (dataListOprsStart == null || dataListOprsStart.length == 0) {
          if (search == '' || search == null) {
            alert(globalScaffoldKey.currentContext!, 2,
                "Data Request Foreman tidak di temukan", "error");
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

  //PROSES
  Future<String> getJSONDataFinish(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (getAkses("FO")) {
        if (isloading == true) {
          EasyLoading.show();
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        Uri myUri = Uri.parse(
            "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-oprs-prosess-v1&search=" +
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
      } else {
        alert(globalScaffoldKey.currentContext!, 2, "Anda tidak punya akses",
            "warning");
      }
    } catch (e) {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
    }
    return "Successfull";
  }

  Future<String> getJSONDataQC(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (getAkses("FO")) {
        if (isloading == true) {
          EasyLoading.show();
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        Uri myUri = Uri.parse(
            "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-request-oprs-qc-v1&search=" +
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
          dataListOprsQC = json.decode(response.body);
          if (dataListOprsQCDummy.length == 0) {
            dataListOprsQCDummy = dataListOprsQC;
          }

          if (dataListOprsQC == null || dataListOprsQC.length == 0) {
            if (search != '' && search != null) {
              alert(globalScaffoldKey.currentContext!, 2,
                  "Tidak ada data yang ditemukan", "warning");
            } else {}
          }
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 2, "Anda tidak punya akses",
            "warning");
      }
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

  void _searchDriverName() {
    List dummyListData = [];
    if (txtSearchDriver.text != "" && txtSearchDriver.text != null) {
      if (txtSearchDriver.text.length >= 3) {
        for (var i = 0; i < dummySearchList.length; i++) {
          var dtC = dummySearchList[i]['title'].toLowerCase().toString();
          //print(dtC.contains(txtSearchDriver.text));
          if (dtC.contains(txtSearchDriver.text.toLowerCase().toString())) {
            //print(dtC);
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
          //print("${dtC} => ${txtSearchVehicle.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchVehicle.text.toLowerCase().toString())) {
            //print(dtC);
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

  void _searchCabangName() {
    List dummyListData2 = [];
    if (txtSearchCabangName.text != "" && txtSearchCabangName.text != null) {
      if (txtSearchCabangName.text.length >= 3) {
        print('txtSearchCabangName ${txtSearchCabangName.text}');
        for (var i = 0; i < dummySearchListCabang.length; i++) {
          var dtC = dummySearchListCabang[i]['text'].toLowerCase().toString();
          print(
              "${dtC} => ${txtSearchCabangName.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchCabangName.text.toLowerCase().toString())) {
            //print("dtC");
            //(dtC);
            dummyListData2.add({
              "id": dummySearchListCabang[i]['id'].toString(),
              "text": dummySearchListCabang[i]['text']
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
    } else {
      listLocid = [];
      listLocid = dummySearchListCabang;
    }
  }

  void _searchBengkelName() {
    List dummyListData2 = [];
    if (txtSearchBengkelName.text != "" && txtSearchBengkelName.text != null) {
      if (txtSearchBengkelName.text.length >= 3) {
        print('txtSearchBengkelName ${txtSearchBengkelName.text}');
        for (var i = 0; i < dummySearchListBengkel.length; i++) {
          var dtC = dummySearchListBengkel[i]['text'].toLowerCase().toString();
          print(
              "${dtC} => ${txtSearchBengkelName.text.toLowerCase().toString()}");
          if (dtC
              .contains(txtSearchBengkelName.text.toLowerCase().toString())) {
            //print("dtC");
            //(dtC);
            dummyListData2.add({
              "id": dummySearchListBengkel[i]['id'].toString(),
              "text": dummySearchListBengkel[i]['text']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listBengkel = [];
            listBengkel = dummyListData2;
          });
        }
      }
      return;
    } else {
      listBengkel = [];
      listBengkel = dummySearchListBengkel;
    }
  }

  void _searchMechanic() {
    List dummyListData2 = [];
    if (txtSearchMechanic.text != "" && txtSearchMechanic.text != null) {
      if (txtSearchMechanic.text.length >= 3) {
        for (var i = 0; i < dummySearchListMcn.length; i++) {
          var dtC = dummySearchListMcn[i]['title'].toLowerCase().toString();
          //print("${dtC} => ${txtSearchMechanic.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchMechanic.text.toLowerCase().toString())) {
            //print(dtC);
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
      listMechanicId = [];
      listMechanicId = dummySearchListMcn;
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

  void _changeButtonSave() {
    if (txtSrTypeId.text.contains("BAN LUAR") ||
        txtSrTypeId.text.contains("BAN-LUAR") ||
        txtSrTypeId.text.contains("BANLUAR")) {
      setState(() {
        btnSubmitText = "Next";
        print(btnSubmitText);
      });
    } else {
      print('BUKAN BAN LUAR');
      setState(() {
        btnSubmitText = bSave;
      });
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

  void _loadDataVehicle() {
    if (txtCabangId.text != "" && txtCabangId.text != null) {
      if (txtCabangId.text.length > 3) {
        //listVehicleId = [];
        getVehicleList(txtCabangId.text);
      }
    }
  }

  Future<int> getIdHeader(String nopol) async {
    int id = 0;
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/sr/get_id_header_opname.jsp?method=by-vhcid&vhcid=" +
              nopol;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        if (id_header <= 0) {
          var a = json.decode(response.body)["id_header"];
          setState(() {
            id_header = a;
            print('id_header ${id_header}');
          });
        }
      }
    } catch (e) {
      id = 0;
    }
    return id;
  }

  void _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      print('_tabController.index ${_tabController.index}');
      switch (_tabController.index) {
        case 0:
          if (getAkses('OP')) {
            print('CREATE tab');
          }

          break;
        case 1:
          if (getAkses('SA')) {
            setState(() {
              dataCHK = [];
            });
            print('dataCHK ${dataCHK}');
            getJSONDataCHK();
            getVehicleListCHK();
          }
          break;
        case 2:
          if (getAkses('SA')) {
            print('OPNAME');
          }
          break;
        case 3:
          if (getAkses('FO')) {
            Future.delayed(Duration(milliseconds: 50));
            setState(() {
              getJSONData(true, '');
            });
          }
          break;
        case 4:
          if (getAkses('FO')) {
            Future.delayed(Duration(milliseconds: 50));
            setState(() {
              getJSONDataFinish(true, "");
            });
          }
          break;
        case 5:
          if (getAkses('FO')) {
            Future.delayed(Duration(milliseconds: 50));
            setState(() {
              getJSONDataQC(true, "");
            });
          }
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    //txtSearchDriver.dispose();
    super.dispose();
  }

  bool getAkses(akses) {
    //print(globals.akses_pages);
    var isAkses = false;
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == akses);
    //print("isOK ${isOK}");
    //print("isOK.length ${isOK.length}");
    if (isOK != null) {
      if (isOK.length > 0) {
        //print(isOK);
        isAkses = true;
      }
    }
    return isAkses;
  }

  bool getAksesMk() {
    var isAkses = false;
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "MK" || x == "ADMIN");
    if (isOK != null) {
      if (isOK.length > 0) {
        isAkses = true;
      }
    }
    return isAkses;
  }

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _tabController = new TabController(vsync: this, length: lengTabs);
    txtSearchVehicleCHK.addListener(_searchVehicleNameCHK);
    txtSearchCabangNameCHK.addListener(_searchCabangNameCHK);
    txtSearchBengkelName.addListener(_searchBengkelName);
    //loopData();
    setState(() {
      txtVHCIDCHK.text = "";
      txtCabangIdCHK.text = "";
      txtKMCHK.text = "0";
      txtJenisTypeCHK.text = "";
    });
    setState(() {
      mechanicID = null;
      resetTeks();
      getSession();
      getListSR();
      getListCabang();
      getDriverById();
      getListMechanicStaff();
      getMenuKatalog();
    });
    _tabController.addListener(_handleTabSelection);
    txtSearchDriver.addListener(_searchDriverName);
    txtSearchVehicle.addListener(_searchVehicleName);
    //txtSearchVehicleFinish.addListener(_searchVehicleNameFinish);
    //txtSearchVehicleStart.addListener(_searchVehicleNameStart);
    txtSearchMechanic.addListener(_searchMechanic);
    txtSearchCabangName.addListener(_searchCabangName);
    txtCabangId.addListener(_loadDataVehicle);
    txtSrTypeId.addListener(_changeButtonSave);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  Widget buildButtonAddBan(BuildContext context, dynamic item) {
    // if (getAkses("OP") || username == "ADMIN") {
    // } else {
    //   return Container();
    // }
    txtGenuino.text = item["original_sn"] == null ||
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
      label: Text("Pilih item"),
      onPressed: () async {
        // print(collTyreNumber
        //     .where((x) => x['tyrenumber'] == item['tyrenumber'])
        //     .isEmpty);
        var isTyreNumberExists =
            collTyreNumber.where((x) => x['tyrenumber'] == item['tyrenumber']);
        print("isTyreNumberExists : ${isTyreNumberExists}");
        if (isTyreNumberExists.isEmpty) {
          Navigator.of(globalScaffoldKey.currentContext!).pop(false);
          collTyreNumber = [];
          collTyreNumber.add({
            'tyrenumber': item["tyrenumber"],
            'curdate': item["curdate"],
            'iditemid': item["iditemid"],
            'partname': item["partname"],
            'merk': item["merk"],
            'genuino': item["genuino"],
            'itmalias': item["itmalias"],
            'itdunitcost': item["itdunitcost"]
          });
          //print(collTyreNumber);
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
                    margin: EdgeInsets.only(
                        top: 5, bottom: 0.0, left: 10, right: 10),
                    child: Text("Tyre Number : ${item['tyrenumber']}",
                        style: TextStyle(color: Colors.black)),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 5, bottom: 0.0, left: 10, right: 10),
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
                  SmartSelect<String>.single(
                    title: 'FIT POST',
                    selectedValue: selFitPostId,
                    onChange: (selected) {
                      setState(() => selFitPostId = selected.value);
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text("Add Ban"),
                  onPressed: () async {
                    var isOK = globals.akses_pages == null
                        ? globals.akses_pages
                        : globals.akses_pages.where((x) => x == "OP");
                    if (isOK != null) {
                      if (isOK.length > 0) {
                        //collTyreFit = [];
                        if (txtGenuino.text == null || txtGenuino.text == '') {
                          alert(globalScaffoldKey.currentContext!, 2,
                              "Genuine Number tidak boleh kosong", "warning");
                        } else if (txtGenuino.text.contains("|")) {
                          alert(
                              globalScaffoldKey.currentContext!,
                              2,
                              "Genuine Number Tidak boleh mengandung karakter '|' ",
                              "warning");
                        } else if (selFitPostId == null || selFitPostId == '') {
                          alert(globalScaffoldKey.currentContext!, 2,
                              "Fit Post tidak boleh kosong", "warning");
                        } else if (selFitPostId.contains("|")) {
                          alert(
                              globalScaffoldKey.currentContext!,
                              2,
                              "Fit Post Tidak boleh mengandung karakter '|' ",
                              "warning");
                        } else {
                          // collTyreNumber.add({'tyrenumber':item["tyrenumber"],'curdate':item["curdate"],'iditemid':item["iditemid"],'genuino':item["genuino"],'itmalias':item["itmalias"],'itdunitcost':item["itdunitcost"]});
                          // print(collTyreNumber);
                          var dataItmeTyre = collTyreNumber;
                          if (dataItmeTyre.length <= 0) {
                            alert(globalScaffoldKey.currentContext!, 2,
                                "Item belum ada yang di pilih", "warning");
                          } else {
                            var dataFit = collTyreFit.where((x) =>
                                x['fittyreid'] ==
                                dataItmeTyre[0]['tyrenumber']);
                            var fitDesc = choices.collFitPost
                                .singleWhere((x) => x.value == selFitPostId);
                            if (dataFit.isEmpty) {
                              fnVHCID = txtVehicleId.text;
                              //print(fnVHCID);
                              collTyreFit.add({
                                "fittyreid": dataItmeTyre[0]['tyrenumber'],
                                "fitserialno": dataItmeTyre[0]['tyrenumber'],
                                "startdate": dataItmeTyre[0]['curdate'],
                                "tyrebrand": dataItmeTyre[0]['merk'],
                                "partname": dataItmeTyre[0]['partname'],
                                "tyrepattern": dataItmeTyre[0]['itmalias'],
                                "tyreprice": dataItmeTyre[0]['itdunitcost'],
                                "genuino": txtGenuino.text,
                                "fitpost": selFitPostId.toString(),
                                "fitpost_desc": fitDesc.title
                              });
                              setState(() {
                                txtGenuino.text = '';
                                selFitPostId = '';
                              });
                              //print(collTyreFit);
                              await Future.delayed(Duration(seconds: 1));
                              Navigator.of(context).pop(false);
                            } else {
                              alert(
                                  globalScaffoldKey.currentContext!,
                                  2,
                                  "Tyre Number ${dataItmeTyre[0]['tyrenumber']} tersebut sudah ada,silahkan gunakan yang lain",
                                  "warning");
                            }
                          }
                        }
                      }
                    } else {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Anda tidak dapat melakukan transaksi ini", "error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text("Submit"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    var isOK = globals.akses_pages == null
                        ? globals.akses_pages
                        : globals.akses_pages.where((x) => x == "OP");
                    if (isOK != null) {
                      if (isOK.length > 0) {
                        //collTyreFit = [];
                        if (collTyreFit.length > 0) {
                          //collTyreFit.add({"genuino": txtGenuino.text,"fitpost": selFitPostId.toString()});
                          selFitPostName = '';
                          for (var i = 0; i < collTyreFit.length; i++) {
                            var fitArr = i == (collTyreFit.length - 1)
                                ? "${collTyreFit[i]['fittyreid']};${collTyreFit[i]['fitserialno']};${collTyreFit[i]['startdate']};${collTyreFit[i]['tyrebrand']};${collTyreFit[i]['tyrepattern']};${collTyreFit[i]['tyreprice']};${collTyreFit[i]['genuino']};${collTyreFit[i]['fitpost']}"
                                : "${collTyreFit[i]['fittyreid']};${collTyreFit[i]['fitserialno']};${collTyreFit[i]['startdate']};${collTyreFit[i]['tyrebrand']};${collTyreFit[i]['tyrepattern']};${collTyreFit[i]['tyreprice']};${collTyreFit[i]['genuino']};${collTyreFit[i]['fitpost']}<=>";
                            selFitPostName += fitArr;
                          }
                          is_edit_req = false;
                          saveRequestService(
                              'save',
                              'yes',
                              item["iditemid"],
                              item["tyrenumber"],
                              item["curdate"],
                              '',
                              item["merk"],
                              item["itmalias"],
                              item["itdunitcost"],
                              item["original_sn"]);
                        }
                      }
                    } else {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Anda tidak dapat melakukan transaksi ini", "error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          alert(globalScaffoldKey.currentContext!, 2,
              "Item tyre Number sudah ada", "warning");
        }

        // showDialog(
        //     context: context,
        //     builder: (_) => new AlertDialog(
        //       shape: RoundedRectangleBorder(
        //           borderRadius:
        //           BorderRadius.all(
        //               Radius.circular(10.0))),
        //       content: Builder(
        //         builder: (context) {
        //           // Get available height and width of the build area of this widget. Make a choice depending on the size.
        //           var height = MediaQuery.of(context).size.height;
        //           var width = MediaQuery.of(context).size.width;
        //
        //           return Container(
        //             height: height - 10,
        //             width: width - 10,
        //             child: ,
        //           );
        //         },
        //       ),
        //     )
        // );
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ));
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
      label: Text("Pilih"),
      onPressed: () async {
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
        //print("${fnFITTYREID},${fnFITSERIALNO},${fnSTARTDATE},${fnSTARTKM},${fnTYREBRAND},${fnTYREPATTERN},${fnTYREPRICE},${fnGENUINENO},${fnFitPost},${fnWONUMBER}");
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
                SmartSelect<String>.single(
                  title: 'FIT POST',
                  selectedValue: selFitPostIdFinish,
                  onChange: (selected) {
                    setState(() => selFitPostIdFinish = selected.value);
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
                  var isOK = globals.akses_pages == null
                      ? globals.akses_pages
                      : globals.akses_pages.where((x) => x == "OP");
                  if (isOK != null) {
                    if (isOK.length > 0) {
                      fnGENUINENO = txtGenuinoFinish.text;
                      fnFitPost = selFitPostIdFinish;
                      //print("${fnFITTYREID},${fnFITSERIALNO},${fnSTARTDATE},${fnSTARTKM},${fnTYREBRAND},${fnTYREPATTERN},${fnTYREPRICE},${fnGENUINENO},${fnFitPost},${fnWONUMBER}");
                      saveFitPost();
                    }
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

  Widget buildButtonAddBanQC(BuildContext context, dynamic item) {
    txtGenuinoQC.text = item["original_sn"] == null ||
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
      label: Text("Pilih"),
      onPressed: () async {
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
        //print("${fnFITTYREID},${fnFITSERIALNO},${fnSTARTDATE},${fnSTARTKM},${fnTYREBRAND},${fnTYREPATTERN},${fnTYREPRICE},${fnGENUINENO},${fnFitPost},${fnWONUMBER}");
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
                    controller: txtGenuinoQC,
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
                SmartSelect<String>.single(
                  title: 'FIT POST',
                  selectedValue: selFitPostIdQC,
                  onChange: (selected) {
                    setState(() => selFitPostIdQC = selected.value);
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
                  var isOK = globals.akses_pages == null
                      ? globals.akses_pages
                      : globals.akses_pages.where((x) => x == "OP");
                  if (isOK != null) {
                    if (isOK.length > 0) {
                      fnGENUINENO = txtGenuinoQC.text;
                      fnFitPost = selFitPostIdQC;
                      //print("${fnFITTYREID},${fnFITSERIALNO},${fnSTARTDATE},${fnSTARTKM},${fnTYREBRAND},${fnTYREPATTERN},${fnTYREPRICE},${fnGENUINENO},${fnFitPost},${fnWONUMBER}");
                      saveFitPost();
                    }
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

  String listSRNumberOpnameDetail = '';
  String status_apr = '';
  String listOpnameVHCID = '';
  String item_id_apr = '';
  Widget buildButtonOpnameDetail(BuildContext context, dynamic item) {
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.add,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Add"),
      onPressed: () async {
        Navigator.of(globalScaffoldKey.currentContext!).pop(false);
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
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
                  margin: EdgeInsets.all(10.0),
                  child: Text("Add data?"),
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("Add"),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  setState(() {
                    txtItemID.text = "";
                    txtPartName.text = "";
                    txtItemSize.text = "";
                    txtTypeID.text = "";
                    txtTypeAccess.text = "";
                    txtGenuineNoOpname.text = "";
                    txtOpnameMerk.text = "";
                    txtOpnameWONUMBER.text = listSRNumberOpnameDetail;
                    txtOpnameVHCID.text = listOpnameVHCID;
                    print(item[0]['id_header']);
                    id_header = int.parse(item[0]['id_header'].toString());
                    item_id_apr = item[0]['item_id'].toString();
                    //txtItemID.text = item_id_apr;
                    METHOD_DETAIL = 'OPNAME';
                    status_apr = 'APR';
                  });
                  _tabController.animateTo(2);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.orangeAccent,
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

  Widget buildButtonDeleteBan(BuildContext context, dynamic item) {
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.delete,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Delete"),
      onPressed: () async {
        Navigator.of(globalScaffoldKey.currentContext!).pop(false);
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
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
                  margin: EdgeInsets.all(10.0),
                  child: Text("Delete this data?"),
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("Delete Ban"),
                onPressed: () async {
                  //Navigator.of(context).pop(false);
                  var isOK = globals.akses_pages == null
                      ? globals.akses_pages
                      : globals.akses_pages.where((x) => x == "OP");
                  if (isOK != null) {
                    if (isOK.length > 0) {
                      collTyreFit.removeWhere((x) =>
                          x['genuino'] == item['genuino'] &&
                          x['fitpost'] == item['fitpost']);
                      var isExists = collTyreFit.where((x) =>
                          x['genuino'] == item['genuino'] &&
                          x['fitpost'] == item['fitpost']);
                      //print(item);
                      collTyreNumber.removeWhere(
                          (x) => x['tyrenumber'] == item['fittyreid']);
                      //print(collTyreNumber.length);
                      //print(collTyreFit.length);
                      if (isExists.length > 0) {
                        alert(globalScaffoldKey.currentContext!, 0,
                            "Gagal delete this row", "error");
                      } else {
                        Navigator.of(context).pop(false);
                        alert(globalScaffoldKey.currentContext!, 1,
                            "Delete this row success", "success");
                      }
                    }
                  } else {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Anda tidak dapat melakukan transaksi ini", "error");
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.orangeAccent,
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
                label: Text("Close"),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.orangeAccent,
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

  Widget buildButtonDeleteDetailOpname(dynamic item) {
    return Container(
        child: Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
          icon: Icon(
            Icons.remove_circle,
            color: Colors.white,
            size: 15.0,
          ),
          label: Text("Delete"),
          onPressed: () async {
            Navigator.of(globalScaffoldKey.currentContext!).pop(false);
            showDialog(
              context: context,
              builder: (context) => new AlertDialog(
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
                      margin: EdgeInsets.all(10.0),
                      child: Text("Delete this data ?"),
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
                    label: Text("Submit"),
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                      setState(() {
                        var idheader = int.parse(item['id_header'].toString());
                        var iddetail = int.parse(item['id_detail'].toString());
                        print(idheader);
                        print(iddetail);
                        DeleteOpnameSrDetail(idheader, iddetail);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
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
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
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
        ))
      ],
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

  Widget buildButtonCancelBanQC(BuildContext context) {
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
        dummylistBanTmsQC = [];
        txtWodCloseNotesQC.text = "";
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

  Widget _buildDListTempBan(dynamic item, int index) {
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
                  "GenuineNo : ${item['genuino']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Tyre Number : ${item['fittyreid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("Partname : ${item['partname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text(
                      "Item Alias/Merk : ${item['tyrepattern']}/ ${item['tyrebrand']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("ID FitPOST : ${item['fitpost']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("FitPOST Desc. : ${item['fitpost_desc']}",
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
              child:
                  Row(children: <Widget>[buildButtonDeleteBan(context, item)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDListTempOpnameDetails(dynamic item, int index) {
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
                  "Item ID : ${item['item_id']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Partname : ${item['part_name']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("Qty : ${item['quantity']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("Merk : ${item['part_name']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("IDType. : ${item['type']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("Accessories. : ${item['accessories']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 2,
                  ),
                  Text("Genuine No. : ${item['genuine_no']}",
                      style: TextStyle(color: Colors.black)),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          buildButtonDeleteDetailOpname(item)
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

//PROSESS
  Widget _buildDListTyreFitDetailFinish(dynamic item, int index) {
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
                  Text("ItemID : ${item['item_id']}",
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
                  Text("IDAccess: ${item['idaccess']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Status Item: ${item['status_item']}",
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
              child: Row(children: <Widget>[
                buildDeleteProses(context, item),
                SizedBox(
                  width: 5,
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
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Edit"),
                  onPressed: () async {
                    print('Edit Proses');
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                    var item_id_edit = "${item['item_id']}";
                    var id_detail = "${item['id_detail']}";
                    setState(() {
                      selStatusItemEditProses = item['status_item'];
                      txtOpnameQtyEditProses.text = item['qty'];
                    });
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Update Detail Item'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              //position
                              mainAxisSize: MainAxisSize.min,
                              // wrap content in flutter
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, top: 10, right: 10, bottom: 10),
                                  child: TextField(
                                    readOnly: false,
                                    cursorColor: Colors.black,
                                    style:
                                        TextStyle(color: Colors.grey.shade800),
                                    controller: txtOpnameQtyEditProses,
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
                                SmartSelect<String>.single(
                                  title: 'Status Item',
                                  selectedValue: selStatusItemEditProses,
                                  onChange: (selected) {
                                    setState(() => selStatusItemEditProses =
                                        selected.value);
                                  },
                                  choiceType: S2ChoiceType.radios,
                                  choiceItems: choices.collStatusItemOpname,
                                  modalType: S2ModalType.popupDialog,
                                  modalHeader: false,
                                  modalConfig: const S2ModalConfig(
                                    style: S2ModalStyle(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(230, 232, 238, .9)),
                                  child: Container(
                                    child: Row(children: <Widget>[
                                      Expanded(
                                          child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Close"),
                                        onPressed: () async {
                                          Navigator.of(globalScaffoldKey
                                                  .currentContext!)
                                              .pop(false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                          child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Update"),
                                        onPressed: () async {
                                          print('Edit Proses');
                                          Navigator.of(globalScaffoldKey
                                                  .currentContext!)
                                              .pop(false);
                                          //print(id_detail);
                                          //print(item_id_edit);
                                          UpdateDetailProses(
                                              id_detail, item_id_edit);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orangeAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ))
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDListTyreFitDetailQC(dynamic item, int index) {
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
                  Text("ItemID : ${item['itemid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Partname : ${item['partname']}",
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
                  Text("ID Access: ${item['idaccess']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Status Item: ${item['status_item']}",
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
                buildDeleteQC(context, item),
                SizedBox(
                  width: 5,
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
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.redAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Edit"),
                  onPressed: () async {
                    print('Edit QC');
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                    var item_id_edit = "${item['item_id']}";
                    var id_detail = "${item['id_detail']}";
                    setState(() {
                      selStatusItemEditProses = item['status_item'];
                      txtOpnameQtyEditProses.text = item['qty'];
                    });
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Update Detail Item'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              //position
                              mainAxisSize: MainAxisSize.min,
                              // wrap content in flutter
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, top: 10, right: 10, bottom: 10),
                                  child: TextField(
                                    readOnly: false,
                                    cursorColor: Colors.black,
                                    style:
                                        TextStyle(color: Colors.grey.shade800),
                                    controller: txtOpnameQtyEditProses,
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
                                SmartSelect<String>.single(
                                  title: 'Status Item 2',
                                  selectedValue: selStatusItemEditQC,
                                  onChange: (selected) {
                                    setState(() =>
                                        selStatusItemEditQC = selected.value);
                                  },
                                  choiceType: S2ChoiceType.radios,
                                  choiceItems: choices.collStatusItemOpname,
                                  modalType: S2ModalType.popupDialog,
                                  modalHeader: false,
                                  modalConfig: const S2ModalConfig(
                                    style: S2ModalStyle(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(230, 232, 238, .9)),
                                  child: Container(
                                    child: Row(children: <Widget>[
                                      Expanded(
                                          child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Close"),
                                        onPressed: () async {
                                          Navigator.of(globalScaffoldKey
                                                  .currentContext!)
                                              .pop(false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                          child: ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 15.0,
                                        ),
                                        label: Text("Update"),
                                        onPressed: () async {
                                          print('Edit Proses');
                                          Navigator.of(globalScaffoldKey
                                                  .currentContext!)
                                              .pop(false);
                                          //print(id_detail);
                                          //print(item_id_edit);
                                          UpdateDetailQC(
                                              id_detail, item_id_edit);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orangeAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ))
              ]),
            ),
          ),
        ],
      ),
    );
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
                  label: Text("Add"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    txtOpnameVHCID.text = item['vhcid'].toString();
                    txtOpnameWONUMBER.text = item['srnumber'].toString();
                    wonumberopname = item['wodwonbr'].toString();
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
                              child: Text("Save Opname ?"),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: Text("Save Opname ?"),
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              print('save opname');
                              createOpname();
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: Text("Close"),
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              setState(() {
                                wonumberopname = "";
                                txtOpnameVHCID.text = "";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.orangeAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildDListDetailItem(dynamic item, int index) {
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
                  label: Text("Pilih"),
                  onPressed: () async {
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                    //print(item);
                    txtItemID.text = item['item_id'];
                    txtPartName.text = item['part_name'];
                    txtItemSize.text = item['item_size'];
                    txtTypeID.text = item['type'];
                    txtTypeAccess.text = item['accessories'];
                    txtGenuineNoOpname.text = item['genuine_no'];
                    txtOpnameMerk.text = item['merk'];
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

  Widget _buildDListDetailMechanicProses(dynamic item, int index) {
    return Card(
      elevation: 0.0,
      margin: new EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey, spreadRadius: 1),
              ],
            ),
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            //decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              color: Colors.white60,
              padding: EdgeInsets.all(10),
              child: Text(
                  "WOD Number: ${item['wodwonbr']}\n"
                  "MechanicID: ${item['mechanicid']}\n"
                  "MechanicName: ${item['mechanicname']}\n"
                  "Start Date: ${item['startdate']}\n"
                  "Start Note: ${item['start_notes']}\n"
                  "Stop Date: ${item['stopdate']}\n"
                  "Stop Note: ${item['stop_notes']}\n",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
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

  Widget buildDeleteProses(BuildContext context, dynamic item) {
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
                    await DeleteViewProses(true, item['wonumber'], item['id']);
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

  Widget buildDeleteQC(BuildContext context, dynamic item) {
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
                    await DeleteViewQC(true, item['wonumber'], item['id']);
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

  Widget _buildDListBanTmsQC(dynamic item, int index) {
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
                buildButtonCancelBanQC(context)
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainerTyreFitFinish(BuildContext context) {
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
                    return _buildDListTyreFitDetailFinish(
                        dataListTyreFit[index], index);
                  }))
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainerViewQC(BuildContext context) {
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
                      dataListTyreFitQC == null ? 0 : dataListTyreFitQC.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListTyreFitDetailQC(
                        dataListTyreFitQC[index], index);
                  }))
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
                  padding: const EdgeInsets.all(2.0),
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
                        var vhcid =
                            txtSearchVehicleSr.text.split('/')[0].toString();
                        print(vhcid);
                        await getListDataSr(true, vhcid);
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

  Widget listDataSearchItem(BuildContext context) {
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
                  padding: const EdgeInsets.all(2.0),
                  itemCount: dataListItemSearch == null
                      ? 0
                      : dataListItemSearch.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailItem(
                        dataListItemSearch[index], index);
                  }))
        ],
      ),
    );
  }

  Widget listDataMechanicProses(BuildContext context) {
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
                  itemCount: dataListMechanicProses == null
                      ? 0
                      : dataListMechanicProses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailMechanicProses(
                        dataListMechanicProses[index], index);
                  }))
        ],
      ),
    );
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

  Widget setupAlertDialoadContainerQC(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: txtSearchListBanQC,
              onChanged: (value) async {
                if (value != '' && value != null) {
                  if (value.length > 2) {
                    await getListBanTMSQC(false, txtSearchListBanQC.text);
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
                        if (txtSearchListBanQC.text.length > 0) {
                          txtSearchListBanQC.text = "";
                          listBanTmsQC = [];
                          dummylistBanTmsQC = [];
                          await getListBanTMSQC(true, '');
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
                  itemCount: listBanTmsQC == null ? 0 : listBanTmsQC.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListBanTmsQC(listBanTmsQC[index], index);
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
                        if (txtSearchListBan.text.length > 0) {
                          txtSearchListBan.text = "";
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

  Widget setupAlertDialoadContainerTempBan(BuildContext context) {
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
                  itemCount: collTyreFit == null ? 0 : collTyreFit.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListTempBan(collTyreFit[index], index);
                  }))
        ],
      ),
    );
  }

  Widget setupAlertDialoagContainerOpnamDetail(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                buildButtonOpnameDetail(context, dataListItemSearch)
              ]),
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
                  itemCount: dataListItemSearch == null
                      ? 0
                      : dataListItemSearch.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListTempOpnameDetails(
                        dataListItemSearch[index], index);
                  })),
        ],
      ),
    );
  }

  //int selectedPage=1;
  //_RegisterNewDriverState(this.selectedPage);
  Widget _buildListViewCREATE(BuildContext context) {
    if (getAkses("OP")) {
      return Container(
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
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtSRNumber,
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
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtDate,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "SR DateTime",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  readOnly: is_edit_req == true ? true : false,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtCabangId,
                  onTap: () {
                    setState(() {
                      print('is_edit_req ${is_edit_req}');
                      if (is_edit_req == null || is_edit_req == false) {
                        _showModalListCabang(context);
                        print('load cabang');
                      } else {
                        print('not load cabang');
                      }
                    });
                  },
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: is_edit_req == true
                        ? HexColor("FFF6F1BF")
                        : HexColor("FFFFFFFF"),
                    filled: true,
                    isDense: true,
                    labelText: "LOCID",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  readOnly: is_edit_req == true ? true : false,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtBengkelId,
                  onTap: () {
                    setState(() {
                      print('is_edit_req ${is_edit_req}');
                      if (is_edit_req == null || is_edit_req == false) {
                        _showModalListBengkel(context);
                        print('load bengkel');
                      } else {
                        print('not load bengkel');
                      }
                    });
                  },
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: is_edit_req == true
                        ? HexColor("FFF6F1BF")
                        : HexColor("FFFFFFFF"),
                    filled: true,
                    isDense: true,
                    labelText: "Bengkel",
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
                  controller: txtVehicleName,
                  // onChanged: (value){
                  // print(value);
                  //   if(value!=null && value!=''){
                  //     setState(() {
                  //       id_header=0;
                  //      txtOpnameWONUMBER.text="";
                  //      txtOpnameVHCID.text="";
                  //     });
                  //   }
                  // },
                  onTap: () {
                    setState(() {
                      print('is_edit_req ${is_edit_req}');
                      if (is_edit_req == null || is_edit_req == false) {
                        _showModalListVehicle(context);
                        print('load vehicle');
                      } else {
                        print('not load vehicle');
                      }
                    });
                    //_showModalListVehicle(context);
                  },
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "Vehicle Name",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  readOnly:
                      is_edit_req != null && is_edit_req == true ? true : false,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtDriverName,
                  onTap: () {
                    if (is_edit_req == null || is_edit_req == false) {
                      _showModalListDriver(context);
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "Driver Name",
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
                  controller: txtSrType,
                  // onChanged: (value){
                  //   print(value);
                  //   if(value!=null && value!=''){
                  //     if(value.toString().contains("BAN LUAR") || value.toString().contains("BANLUAR") || value.toString().contains("BAN-LUAR")){
                  //       print('Show Button');
                  //     }
                  //   }
                  // },
                  onTap: () {
                    _showModalListSR(context);
                  },
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "Service Type",
                    contentPadding: EdgeInsets.all(5.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  //readOnly: true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.grey.shade800),
                  controller: txtKM,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                    //fillColor: HexColor("FFF6F1BF"),
                    filled: true,
                    isDense: true,
                    labelText: "KM",
                    contentPadding: EdgeInsets.all(5.0),
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
                margin: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                  SizedBox(width: 5),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("${btnSubmitText}"),
                    onPressed: () async {
                      if (is_edit_req != null && is_edit_req == true) {
                        showDialog(
                          context: context,
                          builder: (context) => new AlertDialog(
                            title: new Text('Information'),
                            content: new Text("${bUpdate}?"),
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
                                  var isOK = globals.akses_pages == null
                                      ? globals.akses_pages
                                      : globals.akses_pages.where((x) =>
                                          x == "OP" || username == "ADMIN");
                                  if (isOK != null) {
                                    if (isOK.length > 0) {
                                      saveRequestService('update', 'no', '', '',
                                          '', '', '', '', '', '');
                                    }
                                  } else {
                                    alert(
                                        globalScaffoldKey.currentContext!,
                                        0,
                                        "Anda tidak dapat melakukan transaksi ini",
                                        "error");
                                  }
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
                        print(txtSrTypeId.text);
                        //SHOW MODAL LIST BAN
                        if (txtSrTypeId.text.contains("BAN LUAR") ||
                            txtSrTypeId.text.contains("BANLUAR") ||
                            txtSrTypeId.text.contains("BAN-LUAR")) {
                          if (collTyreFit.length > 0) {
                            showDialog(
                              context: globalScaffoldKey.currentContext!,
                              builder: (context) => new AlertDialog(
                                title: new Text('Information'),
                                content: new Text("Save/ pilih item kembali?"),
                                actions: <Widget>[
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24.0,
                                    ),
                                    label: Text("pilih"),
                                    onPressed: () async {
                                      //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                                      Navigator.of(
                                              globalScaffoldKey.currentContext!)
                                          .pop(false);
                                      await Future.delayed(
                                          Duration(seconds: 1));
                                      fnVHCID = txtVehicleId.text;
                                      print("VEHICL ID ${fnVHCID}");
                                      await getListBanTMS(true, '');
                                      showDialog(
                                          context:
                                              globalScaffoldKey.currentContext!,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  Text('List Ban Create SR '),
                                              content:
                                                  setupAlertDialoadContainer(
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 24.0,
                                    ),
                                    label: Text("Save"),
                                    onPressed: () {
                                      fnVHCID = txtVehicleId.text;
                                      print("VEHICL ID ${fnVHCID}");
                                      Navigator.of(
                                              globalScaffoldKey.currentContext!)
                                          .pop(false);
                                      selFitPostName = '';
                                      for (var i = 0;
                                          i < collTyreFit.length;
                                          i++) {
                                        var fitArr = i ==
                                                (collTyreFit.length - 1)
                                            ? "${collTyreFit[i]['fittyreid']};${collTyreFit[i]['fitserialno']};${collTyreFit[i]['startdate']};${collTyreFit[i]['tyrebrand']};${collTyreFit[i]['tyrepattern']};${collTyreFit[i]['tyreprice']};${collTyreFit[i]['genuino']};${collTyreFit[i]['fitpost']}"
                                            : "${collTyreFit[i]['fittyreid']};${collTyreFit[i]['fitserialno']};${collTyreFit[i]['startdate']};${collTyreFit[i]['tyrebrand']};${collTyreFit[i]['tyrepattern']};${collTyreFit[i]['tyreprice']};${collTyreFit[i]['genuino']};${collTyreFit[i]['fitpost']}<=>";
                                        selFitPostName += fitArr;
                                      }
                                      //print(selFitPostName);
                                      is_edit_req = false;
                                      saveRequestService('save', 'yes', '', '',
                                          '', '', '', '', '', '');
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
                          } else {
                            await getListBanTMS(true, '');
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('List Ban Create SR'),
                                    content:
                                        setupAlertDialoadContainer(context),
                                  );
                                });
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              title: new Text('Information'),
                              content: new Text("Save new request service?"),
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
                                    var isOK = globals.akses_pages == null
                                        ? globals.akses_pages
                                        : globals.akses_pages
                                            .where((x) => x == "OP");
                                    if (isOK != null) {
                                      if (isOK.length > 0) {
                                        is_edit_req = false;
                                        saveRequestService('save', 'no', '', '',
                                            '', '', '', '', '', '');
                                      }
                                    } else {
                                      alert(
                                          globalScaffoldKey.currentContext!,
                                          0,
                                          "Anda tidak dapat melakukan transaksi ini",
                                          "error");
                                    }
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                  SizedBox(width: 5),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.details_outlined,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Detail List Ban"),
                    onPressed: () async {
                      var value = txtSrTypeId.text;
                      if (value != null && value != '') {
                        if (value.toString().contains("BAN LUAR") ||
                            value.toString().contains("BANLUAR") ||
                            value.toString().contains("BAN-LUAR")) {
                          if (collTyreFit.length > 0) {
                            print('List total fit post ${collTyreFit.length}');
                            // collTyreFit.add({"genuino": i.toString(),"fitpost": i.toString()});
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('List Ban'),
                                    content: setupAlertDialoadContainerTempBan(
                                        context),
                                  );
                                });
                          } else {
                            alert(
                                globalScaffoldKey.currentContext!,
                                2,
                                "Maaf,Tidak ada data, silahkan add terlebih dahulu",
                                "warning");
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
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

  void reloadWebView() {
    _controllerWeb.reload();
  }

  final _debouncer = Debouncer(delay: const Duration(seconds: 1));

  Widget _buildListViewCHKUNITS(BuildContext context) {
    // if (getAkses("SA")) {
    //
    // } else {
    //   return Container(
    //       child: Center(
    //     child: Text(
    //       "Anda tidak punya akses",
    //       textAlign: TextAlign.center,
    //     ),
    //   ));
    // }
    // return Container(
    //     margin: EdgeInsets.all(10.0),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10),
    //       color: Colors.white,
    //       boxShadow: [
    //         BoxShadow(color: Colors.blue, spreadRadius: 1),
    //       ],
    //     ),
    //     height: MediaQuery.of(context).size.height,
    //     child: WebView(
    //         onWebViewCreated: (controller) {
    //           _controllerWeb = controller;
    //         },
    //         initialUrl:
    //             'http://apps.tuluatas.com:8080/trucking/mobile/portal/form_checklist_kendaraan.jsp?method=check-kendaraan&vhcid=${txtOpnameVHCID.text}&wonumber=${txtOpnameWONUMBER.text}&userid=${username}',
    //         gestureRecognizers: Set()
    //           ..add(
    //             Factory<VerticalDragGestureRecognizer>(
    //               () => VerticalDragGestureRecognizer(),
    //             ), // or null
    //           ),
    //         key: Key("webview1"),
    //         debuggingEnabled: true,
    //         javascriptMode: JavascriptMode.unrestricted));

    return Container(
      //FORM CHK
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: Colors.black12, //
              width: 10.0,
            )),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(0.0),
                  child: TextField(
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtVHCIDCHK,
                    // onChanged: (val){
                    //
                    // },
                    onTap: () {
                      _showModalListVehicleCHK(context);
                    },
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelText: "Nopol",
                      contentPadding: EdgeInsets.all(5.0),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0.0),
                  child: TextField(
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtCabangIdCHK,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelText: "Locid",
                      contentPadding: EdgeInsets.all(5.0),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0.0),
                  child: TextField(
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtJenisTypeCHK,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelText: "Jenis Type/Kendaraan",
                      contentPadding: EdgeInsets.all(5.0),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0.0),
                  child: TextField(
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtWOCHK,
                    onTap: () {
                      _showModalListWOCHK(context);
                    },
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelText: "WO Number",
                      contentPadding: EdgeInsets.all(5.0),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0.0),
                  child: TextField(
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtKMCHK,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelText: "Millage/KM",
                      contentPadding: EdgeInsets.all(5.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              //height: 30,
              padding: const EdgeInsets.all(18.0),
              margin: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.black12, //
                width: 10.0,
              )),
              child: Row(
                children: [
                  Text('Note: Baik'),
                  Radio(
                    value: "0",
                    //groupValue:
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => Colors.green),
                  ),
                  Text('Tidak Baik'),
                  Radio(
                    value: "0",
                    //groupValue:
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => Colors.orange),
                  ),
                  Text('Tidak Ada'),
                  Radio(
                    value: "0",
                    //groupValue:
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.red),
                  )
                ],
              )),
          SizedBox(height: 10),
          Expanded(
            child: GroupedListView<dynamic, String>(
              elements: dataCHK,
              groupBy: (element) => element['nama_group'],
              groupComparator: (value1, value2) => value2.compareTo(value1),
              itemComparator: (item1, item2) =>
                  item1['nama_group'].compareTo(item2['nama_group']),
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: false,
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
                //var indexs =element['id']==null?0: int.parse(element['id'])-1;
                //print('index ${element['index']}');
                return Card(
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -4),
                        //leading: Icon(Icons.album),
                        title:
                            Text("${element['seq']}. ${element['question']}"),
                        //subtitle: Text(element['note']!=null && element['note']!="null"?element['note']:""),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0, bottom: 0.0, left: 18, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            if (element['baik'] == "1" &&
                                element['type'] == "1") ...[
                              //Text("Baik"),
                              Radio(
                                value: "baik$element['index']",
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
                              )
                            ],
                            if (element['tidak_baik'] == "1" &&
                                element['type'] == "1") ...[
                              //Text("Tidak Baik"),
                              Radio(
                                value: "tidak_baik$element['index']",
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
                              )
                            ],
                            if (element['tidak_ada'] == "1" &&
                                element['type'] == "1") ...[
                              //Text("Tidak Ada"),
                              Radio(
                                value: "tidak_ada$element['index']",
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
                              )
                            ],
                            if (element['type'] == "2") ...[
                              Container(
                                child: TextField(
                                  controller: txtInputCHK,
                                  onChanged: (val) {
                                    if (val != null && val != '') {
                                      saveOrUpdate(
                                          element['id_question'],
                                          element['nama_group'],
                                          element['question'],
                                          0,
                                          val.toString(),
                                          0);
                                    }
                                  },
                                  decoration: InputDecoration(
                                      hintText: element['question']),
                                ),
                                width: MediaQuery.of(context).size.width * 0.5,
                              )
                            ]
                          ],
                        ),
                      ),
                      if (element['note'] != null &&
                          element['note'] != "null") ...[
                        ListTile(
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: -4),
                            title: Text("Note: ${element['note']}")),
                      ]
                    ],
                  ),
                );
                // return Card(
                //   elevation: 8.0,
                //   margin: const EdgeInsets.symmetric(
                //       horizontal: 3.0, vertical: 3.0),
                //   child: SizedBox(
                //     child: Row(
                //       //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Container(
                //           child: Text(
                //               " ${element['seq']}. ${element['question']}"),
                //         ),
                //         Expanded(
                //           //1 baik, 2 tidak baik, 3, tidak ada
                //           child: Column(
                //             children: [
                //               if (element['baik'] == "1" &&
                //                   element['type'] == "1") ...[
                //                 Text("B"),
                //                 Radio(
                //                   value: "baik$element['index']",
                //                   groupValue: listChecklistValueCHK[
                //                   element['index']],
                //                   fillColor:
                //                   MaterialStateColor.resolveWith(
                //                           (states) => Colors.black),
                //                   onChanged: (val) {
                //                     setState(() {
                //                       listChecklistValueCHK[
                //                       element['index']] =
                //                           val.toString();
                //                     });
                //                     saveOrUpdate(
                //                         element['id_question'],
                //                         element['nama_group'],
                //                         element['question'],
                //                         1,
                //                         '',
                //                         1);
                //                   },
                //                 )
                //               ],
                //               if (element['tidak_baik'] == "1" &&
                //                   element['type'] == "1") ...[
                //                 Text("T.B"),
                //                 Radio(
                //                   value: "tidak_baik$element['index']",
                //                   groupValue: listChecklistValueCHK[
                //                   element['index']],
                //                   fillColor:
                //                   MaterialStateColor.resolveWith(
                //                           (states) => Colors.black),
                //                   onChanged: (val) {
                //                     setState(() {
                //                       listChecklistValueCHK[
                //                       element['index']] =
                //                           val.toString();
                //                     });
                //                     saveOrUpdate(
                //                         element['id_question'],
                //                         element['nama_group'],
                //                         element['question'],
                //                         2,
                //                         '',
                //                         1);
                //                   },
                //                 )
                //               ],
                //               if (element['tidak_ada'] == "1" &&
                //                   element['type'] == "1") ...[
                //                 Text("T.A"),
                //                 Radio(
                //                   value: "tidak_ada$element['index']",
                //                   groupValue: listChecklistValueCHK[
                //                   element['index']],
                //                   fillColor:
                //                   MaterialStateColor.resolveWith(
                //                           (states) => Colors.black),
                //                   onChanged: (val) {
                //                     setState(() {
                //                       listChecklistValueCHK[
                //                       element['index']] =
                //                           val.toString();
                //                     });
                //                     saveOrUpdate(
                //                         element['id_question'],
                //                         element['nama_group'],
                //                         element['question'],
                //                         3,
                //                         '',
                //                         1);
                //                   },
                //                 )
                //               ],
                //               if (element['type'] == "2") ...[
                //                 Container(
                //                   child: TextField(
                //                     controller: txtInputCHK,
                //                     onChanged: (val) {
                //                       if (val != null && val != '') {
                //                         saveOrUpdate(
                //                             element['id_question'],
                //                             element['nama_group'],
                //                             element['question'],
                //                             0,
                //                             val.toString(),
                //                             0);
                //                       }
                //                     },
                //                     decoration: InputDecoration(
                //                         hintText: element['question']),
                //                   ),
                //                   width:
                //                   MediaQuery.of(context).size.width *
                //                       0.5,
                //                 )
                //               ]
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              },
            ),
          ),
          Container(
            //height: 150,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.grey,
                Colors.black12,
              ],
            )),
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(5),
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
                  await DeleteDraft();
                  print('Delete');
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )),
              SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton.icon(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 15.0,
                ),
                label: Text("Submit"),
                onPressed: () async {
                  if (txtCabangIdCHK.text == null ||
                      txtCabangIdCHK.text == '') {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Cabang tidak boleh kosong", "warning");
                  } else if (txtVHCIDCHK.text == null ||
                      txtVHCIDCHK.text == '') {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Nopol tidak boleh kosong", "warning");
                  } else if (txtJenisTypeCHK.text == null ||
                      txtJenisTypeCHK.text == '') {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Type Kendaraan tidak boleh kosong", "warning");
                  } else if (txtKMCHK.text == null || txtKMCHK.text == '') {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Milage/KM Kendaraan tidak boleh kosong", "warning");
                  } else if (int.parse(txtKMCHK.text) <= 0) {
                    alert(globalScaffoldKey.currentContext!, 2,
                        "Milage/KM Kendaraan tidak boleh kosong", "warning");
                  } else {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (prefs.getString("trxnumber_form_check") == null) {
                      alert(globalScaffoldKey.currentContext!, 2,
                          "Anda belum memilih form checklist", "warning");
                    } else {
                      showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Save data form checklist?"),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
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
                            SizedBox(width: 10),
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
                                await UpdateAll();
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
                    print('Save');
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildListViewOPNAME(BuildContext context) {
    if (getAkses("SA")) {
      print('view list');
      return Container(
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
                        print('clicked');
                        // if (txtOpnameVHCID.text == null ||
                        //     txtOpnameVHCID.text == '') {
                        //   alert(globalScaffoldKey.currentContext!, 0,
                        //       "Vehicle ID tidak boleh kosong", "error");
                        // } else {
                        //   await createOpname();
                        //   // id_header =
                        //   //     await getIdHeader(txtOpnameVHCID.text);
                        // }
                        print(METHOD_DETAIL);
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
                  controller: txtOpnameWONUMBER,
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
              SmartSelect<String>.single(
                title: 'Katalog',
                selectedValue: selKatalog,
                placeholder: 'Pilih satu',
                onChange: (selected) async {
                  // Navigator.of(context,
                  //     rootNavigator: true)
                  //     .pop();
                  setState(() {
                    selKatalog = selected.value;
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
                // onChange: (selected) =>
                //     setState(() => {
                //       selKatalog = selected.value
                //     }),
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
                                  //getItemByPartname();
                                  // if (selKatalog == null ||
                                  //     selKatalog == '') {
                                  //   alert(globalScaffoldKey.currentContext!, 0,
                                  //       "Katalog tidak boleh kosong", "error");
                                  // }else{
                                  //
                                  // }
                                  txtPartName.text = "";
                                  // if(status_apr=="APR"){
                                  //   getListDataItem(true, item_id_apr, 0);
                                  //   await Future.delayed(
                                  //       Duration(milliseconds: 1));
                                  //   if (dataListItemSearch.length > 0) {
                                  //     print(dataListItemSearch[0]);
                                  //     setState(() {
                                  //       txtItemID.text = dataListItemSearch[0]['item_id'];
                                  //       txtPartName.text = dataListItemSearch[0]['part_name'];
                                  //       txtItemSize.text = dataListItemSearch[0]['item_size'];
                                  //       txtTypeID.text = dataListItemSearch[0]['type'];
                                  //       txtTypeAccess.text = dataListItemSearch[0]['accessories'];
                                  //       txtGenuineNoOpname.text = dataListItemSearch[0]['genuine_no'];
                                  //       txtOpnameMerk.text = dataListItemSearch[0]['merk'];
                                  //     });
                                  //   }else{
                                  //     alert(globalScaffoldKey.currentContext!, 2,
                                  //         "Data part tidak di temukan", "warning");
                                  //   }
                                  // }else{
                                  //
                                  // }
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
              SmartSelect<String>.single(
                title: 'Status Item',
                selectedValue: selStatusItem,
                onChange: (selected) {
                  setState(() => selStatusItem = selected.value);
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
                    label: Text("Create"),
                    onPressed: () async {
                      print(fnWONUMBER);
                      print("METHOD_DETAIL ${METHOD_DETAIL}");
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
                                    createOpnameDetail(); //TEST
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
                      Icons.book,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("List Detail"),
                    onPressed: () async {
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
                                                    txtOpnameVHCID.text == '') {
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
                                                            margin:
                                                                EdgeInsets.all(
                                                                    10.0),
                                                            child: Text(
                                                                "Approve this data?"),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: <Widget>[
                                                        new ElevatedButton.icon(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 20.0,
                                                          ),
                                                          label:
                                                              Text("Approve"),
                                                          onPressed: () async {
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
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        new ElevatedButton.icon(
                                                          icon: Icon(
                                                            Icons.save,
                                                            color: Colors.white,
                                                            size: 20.0,
                                                          ),
                                                          label: Text("Close"),
                                                          onPressed: () async {
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
                                                                  fontSize: 10,
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
                                                    horizontal: 5, vertical: 0),
                                                textStyle: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                        ],
                                      ),
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
              )
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

  List<Map<String, dynamic>> dataListItemForeman = [];
  TextEditingController txtSearchPartnameForeman = new TextEditingController();
  Future getListDataItemForeman(String wonumber_detail) async {
    try {
      EasyLoading.show();

      var url =
          "${BASE_URL}api/inventory/list_inventory_trans.jsp?method=list-inventory-trans2-v1&wonumber=${wonumber_detail}";

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

  Widget _buildListViewStartFOREMAN(BuildContext context) {
    //if (getAkses("MT") || username == "ADMIN") {
    //print("getAkses('FO') ${getAkses("FO")}");
    if (getAkses("FO")) {
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        getJSONData(true, txtSearchVehicleStart.text);
                      },
                      icon: Icon(Icons.search),
                    ),
                    //prefixIcon: Icon(Icons.search),
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
                      return _buildDListRequestOprsStartFOREMAN(
                          dataListOprsStart[index], index);
                    }))
          ],
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

  Widget _buildListViewFinish(BuildContext context) {
    // print(getAkses("MT"));
    // print(username);
    //if (getAkses("MT") || username == "ADMIN") {
    //if (getAkses("FO") || getAkses("OP")) {
    if (getAkses("FO")) {
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
                      suffixIcon: IconButton(
                        onPressed: () {
                          getJSONDataFinish(false, txtSearchVehicleFinish.text);
                        },
                        icon: Icon(Icons.search),
                      ),
                      //prefixIcon: Icon(Icons.search),
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
                      //PROSES
                      return _buildDListRequestOprsFinish(
                          dataListOprsFinish[index], index);
                    }),
              )
            ],
          ));
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

  Widget _buildListViewQC(BuildContext context) {
    // print(getAkses("MT"));
    // print(username);
    // if (getAkses("MT") || username == "ADMIN") {
    if (getAkses("FO")) {
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
                  controller: txtSearchVehicleQC,
                  decoration: InputDecoration(
                      labelText: "Search",
                      hintText: "Search nopol/wo/sr number",
                      suffixIcon: IconButton(
                        onPressed: () {
                          getJSONDataQC(true, txtSearchVehicleQC.text);
                        },
                        icon: Icon(Icons.search),
                      ),
                      //prefixIcon: Icon(Icons.search),
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
                        dataListOprsQC == null ? 0 : dataListOprsQC.length,
                    itemBuilder: (context, index) {
                      return _buildDListRequestOprQC(
                          dataListOprsQC[index], index);
                    }),
              )
            ],
          ));
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

  Widget _buildDListRequestOprsStartFOREMAN(dynamic item, int index) {
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
          _ButtonListSrForeman(globalScaffoldKey.currentContext!, item)
        ],
      ),
    );
  }

  Widget _ButtonListSrForeman(BuildContext context, dynamic item) {
    if (getAkses("FO")) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
        child: Container(
          child: Row(children: <Widget>[
            Expanded(
                child: ElevatedButton.icon(
              icon: Icon(
                Icons.list,
                color: Colors.white,
                size: 15.0,
              ),
              label: Text("Opname Detail"),
              onPressed: () async {
                print('OPNAME FOREMAN ${item['wodwonbr']}');
                await getListDataItemForeman(item["wodwonbr"]);
                if (dataListItemSearch.length > 0) {
                  print("item ${item['id_header'].toString()}");
                  listSRNumberOpnameDetail = item['srnumber'];
                  listOpnameVHCID = item['vhcid'];
                  //print(dataListItemSearch);

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('List Item'),
                          content:
                              setupAlertDialoagContainerOpnamDetail(context),
                        );
                      });
                }
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )),
            SizedBox(width: 2),
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
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )),
            SizedBox(width: 2),
            Expanded(
                child: ElevatedButton.icon(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
                size: 15.0,
              ),
              label: Text("WO Start"),
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
                          print("Start Foremman ${userid.toUpperCase()}");
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
                                        labelText: "Mechanic ID 1",
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
                                      controller: txtWorkedBy2,
                                      onTap: () {
                                        _showModalListMechanic2(context);
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        labelText: "Mechanic ID 2",
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
                                              var workedby2 =
                                                  txtWorkedById2.text;
                                              print(txtWodNotes.text);
                                              startRequestServiceForeman(
                                                  item['srnumber'],
                                                  item['wodwonbr'],
                                                  workedby,
                                                  workedby2,
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
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
      );
    } else {
      if (getAkses("OP") || username == "ADMIN") {
        return Container(
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
                label: Text("Edit"),
                onPressed: () async {
                  showDialog(
                    context: globalScaffoldKey.currentContext!,
                    builder: (context) => new AlertDialog(
                      title: new Text('Information'),
                      content: new Text("Edit data ${item['srnumber']}"),
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
                            setState(() {
                              is_edit_req = true;
                              txtSRNumber.text = item['srnumber'];
                              txtDate.text = item['requestdate'];
                              txtSrType.text = item['srtypeiddesc'];
                              txtSrTypeId.text = item['srtypeid'];
                              txtDriverIdList.text = item['drvid'];
                              txtVehicleIdList.text = item['vhcid'];
                              txtVehicleName.text = item['vhcid'];
                              txtDriverName.text = item['drvname'];
                              txtNotes.text = item['srnotes'];
                              txtKM.text = item['srkm'];
                              srnumber = item['srnumber'];
                              txtCabangId.text = item['srlocid'];
                              btnSubmitText = bUpdate;
                            });
                            Navigator.of(globalScaffoldKey.currentContext!)
                                .pop(false);
                            await Future.delayed(Duration(milliseconds: 50));
                            _tabController.animateTo(0);
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
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )),
            ]),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  Widget _ButtonListSr(BuildContext context, dynamic item) {
    if (getAkses("OP") || username == "ADMIN") {
      return Container(
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
              label: Text("Edit"),
              onPressed: () async {
                showDialog(
                  context: globalScaffoldKey.currentContext!,
                  builder: (context) => new AlertDialog(
                    title: new Text('Information'),
                    content: new Text("Edit data ${item['srnumber']}"),
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
                          setState(() {
                            is_edit_req = true;
                            txtSRNumber.text = item['srnumber'];
                            txtDate.text = item['requestdate'];
                            txtSrType.text = item['srtypeiddesc'];
                            txtSrTypeId.text = item['srtypeid'];
                            txtDriverIdList.text = item['drvid'];
                            txtVehicleIdList.text = item['vhcid'];
                            txtVehicleName.text = item['vhcid'];
                            txtDriverName.text = item['drvname'];
                            txtNotes.text = item['srnotes'];
                            txtKM.text = item['srkm'];
                            srnumber = item['srnumber'];
                            txtCabangId.text = item['srlocid'];
                            btnSubmitText = bUpdate;
                          });
                          Navigator.of(globalScaffoldKey.currentContext!)
                              .pop(false);
                          await Future.delayed(Duration(milliseconds: 50));
                          _tabController.animateTo(0);
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
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )),
            SizedBox(width: 10),
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
                                        labelText: "Mechanic ID 1",
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
                                      controller: txtWorkedBy2,
                                      onTap: () {
                                        _showModalListMechanic2(context);
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        labelText: "Mechanic ID 2",
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
                                              var workedby2 =
                                                  txtWorkedById2.text;
                                              print(txtWodNotes.text);
                                              startRequestServiceForeman(
                                                  item['srnumber'],
                                                  item['wodwonbr'],
                                                  workedby,
                                                  workedby2,
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
      if (getAkses("OP") || username == "ADMIN") {
        return Container(
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
                label: Text("Edit"),
                onPressed: () async {
                  showDialog(
                    context: globalScaffoldKey.currentContext!,
                    builder: (context) => new AlertDialog(
                      title: new Text('Information'),
                      content: new Text("Edit data ${item['srnumber']}"),
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
                            setState(() {
                              is_edit_req = true;
                              txtSRNumber.text = item['srnumber'];
                              txtDate.text = item['requestdate'];
                              txtSrType.text = item['srtypeiddesc'];
                              txtSrTypeId.text = item['srtypeid'];
                              txtDriverIdList.text = item['drvid'];
                              txtVehicleIdList.text = item['vhcid'];
                              txtVehicleName.text = item['vhcid'];
                              txtDriverName.text = item['drvname'];
                              txtNotes.text = item['srnotes'];
                              txtKM.text = item['srkm'];
                              srnumber = item['srnumber'];
                              txtCabangId.text = item['srlocid'];
                              btnSubmitText = bUpdate;
                            });
                            Navigator.of(globalScaffoldKey.currentContext!)
                                .pop(false);
                            await Future.delayed(Duration(milliseconds: 50));
                            _tabController.animateTo(0);
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
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )),
            ]),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  //PROSES
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
            padding: EdgeInsets.only(bottom: 0, top: 0, left: 10, right: 10),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new ElevatedButton.icon(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    label: Text("Add Or Update Mechanic"), //PROSESS
                    onPressed: () async {
                      mechanicID = null;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("wo_mcn_detail", item['wodwonbr']);
                      prefs.setString("srnumber_mcn_detail", item['srnumber']);
                      print(item['wodwonbr']);
                      print(item['srnumber']);
                      EasyLoading.show();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewListMcnDetail()));
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 43),
                  new ElevatedButton.icon(
                    icon: Icon(
                      Icons.details_outlined,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Detail List"), //PROSESS
                    onPressed: () async {
                      // showDialog(
                      //   context: globalScaffoldKey.currentContext!,
                      //   builder: (context) => new AlertDialog(
                      //     title: new Text('Information Proses'),
                      //     content: new Text("Add/ view detail?"),
                      //     actions: <Widget>[
                      //       new ElevatedButton.icon(
                      //         icon: Icon(
                      //           Icons.check,
                      //           color: Colors.white,
                      //           size: 24.0,
                      //         ),
                      //         label: Text("Add Detail Proses"),
                      //         onPressed: () async {
                      //           //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                      //           Navigator.of(globalScaffoldKey.currentContext!)
                      //               .pop(false);
                      //           await Future.delayed(Duration(seconds: 1));
                      //           //(item);
                      //           print(id_header);
                      //           METHOD_DETAIL = 'PROSES';
                      //           fnVHCID = item['vhcid'];
                      //           fnSTARTKM = item['vhckm'];
                      //           fnWONUMBER = item['wodwonbr'];
                      //           fnSRNUMBER = item['srnumber'];
                      //           setState(() {
                      //             txtOpnameWONUMBER.text = fnSRNUMBER;
                      //             txtOpnameVHCID.text = fnVHCID;
                      //           });
                      //           _tabController.animateTo(1);
                      //           // await getListBanTMS(true, '');
                      //           // showDialog(
                      //           //     context: globalScaffoldKey.currentContext!,
                      //           //     builder: (BuildContext context) {
                      //           //       return AlertDialog(
                      //           //         title: Text('List Data'),
                      //           //         content: setupAlertDialoadContainerFinish(
                      //           //             context),
                      //           //       );
                      //           //     });
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //             elevation: 0.0,
                      //             backgroundColor: Colors.green,
                      //             padding: EdgeInsets.symmetric(
                      //                 horizontal: 5, vertical: 0),
                      //             textStyle: TextStyle(
                      //                 fontSize: 14, fontWeight: FontWeight.bold)),
                      //       ),
                      //       new ElevatedButton.icon(
                      //         icon: Icon(
                      //           Icons.save,
                      //           color: Colors.white,
                      //           size: 24.0,
                      //         ),
                      //         label: Text("View"),
                      //         onPressed: () async {
                      //           print('show');
                      //           //print("${dataListTyreFit}");
                      //           METHOD_DETAIL = '';
                      //           await getListViewProses(true, item['wodwonbr']);
                      //           if (dataListTyreFit.length > 0) {
                      //             Navigator.of(context).pop(false);
                      //             await Future.delayed(Duration(milliseconds: 1));
                      //             print("dataListTyreFit");
                      //             //print(dataListTyreFit);
                      //             showDialog(
                      //                 context: context,
                      //                 builder: (BuildContext context) {
                      //                   return AlertDialog(
                      //                     title: Text('List Item'),
                      //                     content:
                      //                         setupAlertDialoadContainerTyreFitFinish(
                      //                             context),
                      //                   );
                      //                 });
                      //           } else {
                      //             Navigator.of(context).pop(false);
                      //             await Future.delayed(Duration(milliseconds: 1));
                      //             alert(
                      //                 context,
                      //                 2,
                      //                 "tidak ada data yang di temukan",
                      //                 "warning");
                      //           }
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //             elevation: 0.0,
                      //             backgroundColor: Colors.blue,
                      //             padding: EdgeInsets.symmetric(
                      //                 horizontal: 5, vertical: 0),
                      //             textStyle: TextStyle(
                      //                 fontSize: 14, fontWeight: FontWeight.bold)),
                      //       ),
                      //     ],
                      //   ),
                      // );
                      await getListDataListMechanic(item['wodwonbr']);
                      await Future.delayed(Duration(milliseconds: 1));
                      if (dataListMechanicProses.length > 0) {
                        showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('List Detail Mechanic'),
                                content: listDataMechanicProses(context),
                              );
                            });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ]),
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(bottom: 0, top: 0, left: 10, right: 10),
              decoration:
                  BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
              child: new ElevatedButton.icon(
                icon: Icon(
                  Icons.details_outlined,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("Opname Detail"), //PROSESS
                onPressed: () async {
                  print('OPNAME FOREMAN ${item['wodwonbr']}');
                  await getListDataItemForeman(item["wodwonbr"]);
                  if (dataListItemSearch.length > 0) {
                    listSRNumberOpnameDetail = item['srnumber'];
                    listOpnameVHCID = item['vhcid'];
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('List Item'),
                            content:
                                setupAlertDialoagContainerOpnamDetail(context),
                          );
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }

  Widget _buildDListRequestOprQC(dynamic item, int index) {
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
                buildButtonApproveQC(
                    context,
                    item['srnumber'],
                    item['wodwonbr'],
                    item['vhcid'],
                    item['drvid'],
                    item['woprint']),
                SizedBox(width: 5),
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.details_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text("Detail List"), //AS LIST DETAIL QC
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
                            label: Text("Add Detail QC"),
                            onPressed: () async {
                              //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                              Navigator.of(globalScaffoldKey.currentContext!)
                                  .pop(false);
                              await Future.delayed(Duration(seconds: 1));
                              METHOD_DETAIL = 'QC';
                              fnVHCIDQC = item['vhcid'];
                              fnSTARTKMQC = item['vhckm'];
                              fnWONUMBERQC = item['wodwonbr'];
                              fnSRNUMBER = item['srnumber'];
                              setState(() {
                                txtOpnameWONUMBER.text = fnSRNUMBER;
                                txtOpnameVHCID.text = fnVHCIDQC;
                              });
                              _tabController.animateTo(1);
                              // await getListBanTMSQC(true, '');
                              // showDialog(
                              //     context: globalScaffoldKey.currentContext!,
                              //     builder: (BuildContext context) {
                              //       return AlertDialog(
                              //         title: Text('List Data'),
                              //         content:
                              //             setupAlertDialoadContainerQC(context),
                              //       );
                              //     });
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
                              //print("${dataListTyreFitQC}");
                              METHOD_DETAIL = '';
                              await getListViewQC(true, item['wodwonbr']);
                              if (dataListTyreFitQC.length > 0) {
                                Navigator.of(context).pop(false);
                                await Future.delayed(Duration(milliseconds: 1));
                                print("dataListTyreFit QC");
                                //(dataListTyreFitQC);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('List Item'),
                                        content:
                                            setupAlertDialoadContainerViewQC(
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

  Widget _sizeBoxApprove(BuildContext context) {
    if (getAkses("OP") || username == "ADMIN") {
      return SizedBox(
        width: 10,
      );
    } else {
      return Container();
    }
  }

  Widget buildButtonApprove(BuildContext context, String appSrnumber,
      String wodNumber, String appVhcid, String appDrvid, String woPrint) {
    //if (username == "ADI" || username == "MAJID" || username == "ADMIN") {
    if (getAkses("OP")) {
      return Expanded(
          child: ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Approve"),
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
                    child: Text("Close WO data ${appSrnumber}"),
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
                      closeWoRequestService(appSrnumber, wodNumber, appVhcid,
                          appDrvid, woPrint, txtWodCloseNotes.text);
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

  Widget buildButtonApprovePROSES(BuildContext context, String appSrnumber,
      String wodNumber, String appVhcid, String appDrvid, String woPrint) {
    if (getAkses("FO")) {
      return Expanded(
          child: ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Approve"),
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
                    child: Text("Close WO data ${appSrnumber}"),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtWodCloseNotesQC,
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
                      closeWoRequestServicePROSES(appSrnumber, wodNumber,
                          appVhcid, appDrvid, woPrint, txtWodCloseNotesQC.text);
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

  Widget buildButtonApproveQC(BuildContext context, String appSrnumber,
      String wodNumber, String appVhcid, String appDrvid, String woPrint) {
    //if (username == "ADI" || username == "MAJID" || username == "ADMIN") {
    if (getAkses("FO")) {
      return Expanded(
          child: ElevatedButton.icon(
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 15.0,
        ),
        label: Text("Approve"),
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
                    child: Text("Close WO data ${appSrnumber}"),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtWodCloseNotesQC,
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
                      closeWoRequestServiceQC(appSrnumber, wodNumber, appVhcid,
                          appDrvid, woPrint, txtWodCloseNotesQC.text);
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

  @override
  Widget build(BuildContext context) {
    var isOP = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "OP");

    var isSA = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "SA");

    var isQC = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "QC");

    var isFO = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "FO");

    return DefaultTabController(
      length: lengTabs,
      child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ViewDashboard()));
            }
          },
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
                  Tab(icon: Icon(Icons.car_repair), child: Text('CREATE SR')),
                  Tab(
                      icon: Icon(Icons.car_repair),
                      child: Text('SERAH TERIMA')),
                  Tab(icon: Icon(Icons.list), child: Text('OPNAME')),
                  Tab(icon: Icon(Icons.list), child: Text('FOREMAN')),
                  Tab(icon: Icon(Icons.list), child: Text('PROSES')),
                  Tab(icon: Icon(Icons.list), child: Text('QC')),
                ],
                //tabs:getTabBarList(),
              ),
              title: Text('Service Request'),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              key: globalScaffoldKey,
              controller: _tabController,
              children: [
                _buildListViewCREATE(context),
                _buildListViewCHKUNITS(context),
                _buildListViewOPNAME(context),
                _buildListViewStartFOREMAN(context), //FOREMAN
                _buildListViewFinish(context), //PROSES
                _buildListViewQC(context), //QC
              ],
            ),
          )),
    );
  }
}
