import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';


List listVehicleIdCHK = [];
List dummySearchListCHK = [];
List listLocidCHK = [];
List dummySearchListCabangCHK = [];
TextEditingController txtSearchVehicleCHK = new TextEditingController();
TextEditingController txtVehicleNameCHK = new TextEditingController();
TextEditingController txtVHCIDCHK = new TextEditingController();
TextEditingController txtVehicleIdListCHK = new TextEditingController();
TextEditingController txtSearchCabangNameCHK = new TextEditingController();
TextEditingController txtCabangNameCHK = new TextEditingController();
TextEditingController txtCabangIdCHK = new TextEditingController();
TextEditingController txtJenisTypeCHK = new TextEditingController();
TextEditingController txtKMCHK = new TextEditingController();

class _BottomSheetContentVehicleCHK extends StatelessWidget {
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
                      txtCabangNameCHK.text = listLocidCHK[index]['text'].toString();
                      txtCabangIdCHK.text = listLocidCHK[index]['id'].toString();
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

class FrmCHK extends StatefulWidget {
  @override
  _FrmCHKState createState() => _FrmCHKState();
}

class _FrmCHKState extends State<FrmCHK> {
  late SharedPreferences sharedPreferences;
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> data = [];
  List listChecklistValue = [];
  String status_code = "";
  String message = "";
  String loginname = "";
  String drvid = "";
  String vhcid = "";
  String mechanicid = "";
  String username = "";
  String name = "";
  String nick_name = "";
  String locid = "";
  String cpyname = "";

  TextEditingController txtInput = new TextEditingController();

  void _showModalListVehicleCHK(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentVehicleCHK();
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
          var dtC = dummySearchListCHK[i]['value'].toLowerCase().toString();
          print("${dtC} => ${txtSearchVehicleCHK.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchVehicleCHK.text.toLowerCase().toString())) {
            print(dtC);
            dummyListData2.add({
              "value": dummySearchListCHK[i]['value'].toString(),
              "title": dummySearchListCHK[i]['title']
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
    if (txtSearchCabangNameCHK.text != "" && txtSearchCabangNameCHK.text != null) {
      if (txtSearchCabangNameCHK.text.length >= 3) {
        for (var i = 0; i < dummySearchListCHK.length; i++) {
          var dtC = dummySearchListCabangCHK[i]['value'].toLowerCase().toString();
          print(
              "${dtC} => ${txtSearchCabangNameCHK.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchCabangNameCHK.text.toLowerCase().toString())) {
            print(dtC);
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
      print(listLocidCHK);
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
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver",
          "error");
      print(e.toString());
    }
  }

  @override
  void initState() {
    getDataPreference();
    getJSONDataCHK();
    getVehicleListCHK();
    //getVehicleList();
    txtSearchVehicleCHK.addListener(_searchVehicleNameCHK);
    txtSearchCabangNameCHK.addListener(_searchCabangNameCHK);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    setState(() {
      txtVHCIDCHK.text="";
      txtCabangIdCHK.text="";
      txtKMCHK.text="0";
      txtJenisTypeCHK.text="";
    });
    super.initState();
  }


  var number_indexs = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          if (this.mounted) {
            DeleteDraft();
          }
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        },
        child: Scaffold(
            backgroundColor: Colors.white54,
            appBar: AppBar(
                backgroundColor: Colors.blue,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 20.0,
                  onPressed: () {
                    _goBack(context);
                  },
                ),
                //elevation: 0.0,
                centerTitle: true,
                title: Text('Form Chekclist')),
            body: Container(
              key: globalScaffoldKey,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black12, //
                        width: 10.0,
                      )
                    ),
                    child: Column(
                      children:[
                        Container(
                          margin: EdgeInsets.all(0.0),
                          child: TextField(
                            cursorColor: Colors.black,
                            style: TextStyle(color: Colors.grey.shade800),
                            controller: txtVHCIDCHK,
                            onTap: () {
                              _showModalListVehicleCHK(context);
                              if(txtVHCIDCHK.text!=null && txtVHCIDCHK.text!=''){
                                var dt = listVehicleIdCHK.where((o) => o['vhcid']==txtVHCIDCHK.text);
                                setState(() {
                                  var locid = '';
                                  var vhttype = '';
                                 if(dt!=null){
                                   dt.forEach((v) {
                                     locid = v['locid'];
                                     vhttype = v['vhttype'];
                                   });
                                 }
                                 txtCabangIdCHK.text=locid;
                                 txtJenisTypeCHK.text=vhttype;
                                });
                              }
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
                  Expanded(
                    child: GroupedListView<dynamic, String>(
                      elements: data,
                      groupBy: (element) => element['nama_group'],
                      groupComparator: (value1, value2) =>
                          value2.compareTo(value1),
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
                          elevation: 8.0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            " ${element['seq']}. ${element['question']}"),
                                      ],
                                    ),
                                  ],
                                ),
                                Wrap(
                                  //1 baik, 2 tidak baik, 3, tidak ada
                                  children: [
                                    if (element['baik'] == "1" &&
                                        element['type'] == "1") ...[
                                      Radio(
                                        value: "baik$element['index']",
                                        groupValue: listChecklistValue[
                                            element['index']],
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.black),
                                        onChanged: (val) {
                                          setState(() {
                                            listChecklistValue[
                                                    element['index']] =
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
                                      Radio(
                                        value: "tidak_baik$element['index']",
                                        groupValue: listChecklistValue[
                                            element['index']],
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.black),
                                        onChanged: (val) {
                                          setState(() {
                                            listChecklistValue[
                                                    element['index']] =
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
                                      Radio(
                                        value: "tidak_ada$element['index']",
                                        groupValue: listChecklistValue[
                                            element['index']],
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.black),
                                        onChanged: (val) {
                                          setState(() {
                                            listChecklistValue[
                                                    element['index']] =
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
                                          controller: txtInput,
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                      )
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
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
                        )
                    ),
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(5),
                    child: Row(children: <Widget>[
                      Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.camera,
                              color: Colors.white,
                              size: 15.0,
                            ),
                            label: Text("Submit"),
                            onPressed: () async{
                              if(txtCabangIdCHK.text==null || txtCabangIdCHK.text==''){
                                alert(globalScaffoldKey.currentContext!, 2,
                                    "Cabang tidak boleh kosong", "warning");
                              }else if(txtVHCIDCHK.text==null || txtVHCIDCHK.text==''){
                                alert(globalScaffoldKey.currentContext!, 2,
                                    "Nopol tidak boleh kosong", "warning");
                              }else if(txtJenisTypeCHK.text==null || txtJenisTypeCHK.text==''){
                                alert(globalScaffoldKey.currentContext!, 2,
                                    "Type Kendaraan tidak boleh kosong", "warning");
                              }else if(txtKMCHK.text==null || txtKMCHK.text==''){
                                alert(globalScaffoldKey.currentContext!, 2,
                                    "Milage/KM Kendaraan tidak boleh kosong", "warning");
                              }else if(int.parse(txtKMCHK.text)<=0){
                                alert(globalScaffoldKey.currentContext!, 2,
                                    "Milage/KM Kendaraan tidak boleh kosong", "warning");
                              }else{
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                if (prefs.getString("trxnumber_form_check") == null) {
                                  alert(globalScaffoldKey.currentContext!, 2,
                                      "Anda belum memilih form checklist", "warning");
                                }else{
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
                                            Navigator.of(context, rootNavigator: true).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor: Colors.blue,
                                              padding:
                                              EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                              textStyle: TextStyle(
                                                  fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        SizedBox(width: 10),
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.info,
                                            color: Colors.white,
                                            size: 24.0,
                                          ),
                                          label: Text("Ok"),
                                          onPressed: () async{
                                            Navigator.of(context, rootNavigator: true).pop();
                                            await UpdateAll();
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
                                }
                                print('Save');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blue,
                                padding:
                                EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          )),
                    ]),
                  )
                ],
              ),
            )));
  }

  var dataOject = [];
  void getJSONDataCHK() async {
    try{
      EasyLoading.show();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=list-question-form");
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        // Get the JSON data
        data = json.decode(response.body);
        if (data != null && data.length > 0) {
          for (var i = 0; i < data.length; i++) {
            listChecklistValue.add(i.toString());
          }
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
    print('prefs.getString("trxnumber_form_check") ${prefs.getString("trxnumber_form_check")}' );
    if( prefs.getString("trxnumber_form_check")!=null){
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

  Future UpdateAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var vhcid = txtVHCIDCHK.text;
    var locid = txtCabangIdCHK.text;
    var vhtalias = txtJenisTypeCHK.text;
    var odometer = txtKMCHK.text;
    var trxnumber = prefs.getString("trxnumber_form_check");
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=update-form-cheklist&trxnumber=${trxnumber}"
            "&vhcid=${vhcid}&locid=${locid}&vhtalias=${vhtalias}&odometer=${odometer}");
    print(myUri.toString());
    var response =
    await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      var status_code = json.decode(response.body)["status_code"];
      var message = json.decode(response.body)["message"];
      if(int.parse(status_code)==200){
        resetTeks();
        if(prefs.getString("trxnumber_form_check")!=null){
          prefs.remove("trxnumber_form_check");
        }
        alert(globalScaffoldKey.currentContext!, 1, message, "Success");
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          // 5s over, navigate to a new page
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewDashboard()));
        });
      }else{
        alert(globalScaffoldKey.currentContext!, 2, message, "Warning");
      }
      print(message);
    });
  }

  void resetTeks(){
    setState(() {
      txtVHCIDCHK.text="";
      txtCabangIdCHK.text="";
      txtKMCHK.text="0";
      txtJenisTypeCHK.text="";
      data = [];
    });
    getJSONDataCHK();
  }
  _goBack(BuildContext context) {
    if (this.mounted) {
      DeleteDraft();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  getDataPreference() async {
    SharedPreferences resPreps = await SharedPreferences.getInstance();
    setState(() {
      try {
        loginname = sharedPreferences.getString("loginname")! == null
            ? ""
            : sharedPreferences.getString("loginname")!;
      } catch ($e) {
        loginname = "";
      }
      drvid = resPreps.getString("drvid")!;
      vhcid = resPreps.getString("vhcid")!;
      mechanicid = resPreps.getString("mechanicid")!;
      username = resPreps.getString("username")!;
      name = resPreps.getString("name")!;
      locid = resPreps.getString("locid")!;
      cpyname = resPreps.getString("cpyname")!;
      print('login name ${loginname}');
    });
  }
}
