import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import '../../../choices.dart' as choices;
import 'package:dms_anp/src/pages/maintenance/FrmServiceRequestOpr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';

import '../flusbar.dart';

class ViewListMcnDetail extends StatefulWidget {
  @override
  _ViewListMcnDetailState createState() => _ViewListMcnDetailState();
}

class _ViewListMcnDetailState extends State<ViewListMcnDetail> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  TextEditingController txtNotes = new TextEditingController();
  int _selectedIndex = 0;
  late List data;
  String status_code = "";
  String message = "";
  late List<Map<String, dynamic>> lstMechanicID = [];
  var mechanicID = "";
  var jobsID = "start";
  var items_drop_down = ['start', 'stop'];
  Future<String> getListMechanicID(String wonumber) async {
    EasyLoading.show();
    print('get list mehanic');
    String status = "";
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/sr/list_mechanicid.jsp?method=list-mechanicid-master&wonumber=${wonumber}";
      print(urlData);
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
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
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return status;
  }

  String wodsvcreqnbr = "";
  String wodwonbr = "";
  Future<String> getJSONData() async {
    EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    wodwonbr = prefs.getString("wo_mcn_detail")!;
    wodsvcreqnbr = prefs.getString("srnumber_mcn_detail")!;
    print("${wodwonbr}, ${wodsvcreqnbr}");
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/maintenance/sr/list_mechanicid_detail_jobs.jsp?method=list-mechanicid-detail&wodwonbr=${wodwonbr}&wosvcreqnbr=${wodsvcreqnbr}");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      data = json.decode(response.body);
      print(data);
      if (data == null || data.length == 0 || data == "") {
        alert(globalScaffoldKey.currentContext!, 0, "List Mechanic belum ada",
            "error");
      }
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    return "Successfull";
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => FrmServiceRequestOpr()));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => FrmServiceRequestOpr()));
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('Form List Mechanic')),
        body: new Container(
          key: globalScaffoldKey2,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[
              _buildListView(globalScaffoldKey2.currentContext!)
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 56,
          margin: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.greenAccent,
                  child: InkWell(
                      child: Text("Add Mechanic",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String wonumber = prefs.getString("wo_mcn_detail")!;
                        String wodsvcreqnbr =
                            prefs.getString("srnumber_mcn_detail")!;
                        print("value of your text");
                        var userid = prefs.getString("username")!;
                        await getListMechanicID(wonumber);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: new Text("Add mechanic?"),
                                  content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SmartSelect<String?>.single(
                                          title: 'New Mechanic',
                                          selectedValue: mechanicID,
                                          placeholder: 'Pilih satu',
                                          onChange: (selected) {
                                            print(
                                                'selected.value ${selected.value}');
                                            setState(() {
                                              mechanicID = selected.value!;
                                            });
                                          },
                                          choiceItems:
                                              S2Choice.listFrom<String, Map>(
                                                  source: lstMechanicID,
                                                  value: (index, item) =>
                                                      item['value'],
                                                  title: (index, item) =>
                                                      item['title']),
                                          //choiceGrouped: true,
                                          modalFilter: true,
                                          modalFilterAuto: true,
                                        ),
                                        // SingleChildScrollView(
                                        //     scrollDirection: Axis.horizontal,
                                        //     child: new DropdownButton(
                                        //       // Initial Value
                                        //       isExpanded: true,
                                        //       value: jobsID,
                                        //       // Down Arrow Icon
                                        //       icon: const Icon(
                                        //           Icons.keyboard_arrow_down),
                                        //       items: items_drop_down
                                        //           .map((String items) {
                                        //         return DropdownMenuItem(
                                        //           value: items,
                                        //           child: Text(items),
                                        //         );
                                        //       }).toList(),
                                        //       onChanged: (String newValue) {
                                        //         setState(() {
                                        //           jobsID = newValue;
                                        //         });
                                        //       },
                                        //     )),
                                        // SmartSelect<String>.single(
                                        //   title: 'Start/Stop',
                                        //   value: jobsID,
                                        //   onChange: (selected) {
                                        //     setState(() => jobsID = selected.value);
                                        //   },
                                        //   choiceType: S2ChoiceType.radios,
                                        //   choiceItems: choices.cStartStop,
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
                                          margin: EdgeInsets.all(10.0),
                                          child: TextField(
                                            cursorColor: Colors.black,
                                            style: TextStyle(
                                                color: Colors.grey.shade800),
                                            controller: txtNotes,
                                            keyboardType: TextInputType.text,
                                            decoration: new InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              isDense: true,
                                              labelText: "Notes",
                                              contentPadding:
                                                  EdgeInsets.all(5.0),
                                            ),
                                          ),
                                        ),
                                      ]),
                                  actions: <Widget>[
                                    // usually buttons at the bottom of the dialog
                                    new TextButton(
                                      child: new Text("Close"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    new TextButton(
                                      onPressed: () async {
                                        Navigator.of(globalScaffoldKey.currentContext!)
                                            .pop(false);
                                        showDialog(
                                          context:
                                              globalScaffoldKey.currentContext!,
                                          builder: (context) => new AlertDialog(
                                            title: new Text(
                                                'Add mechanic ${wonumber}?'),
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
                                                  Navigator.of(globalScaffoldKey.currentContext!)
                                                      .pop(false);
                                                  print(txtNotes.text);
                                                  if (mechanicID == null ||
                                                      mechanicID == '') {
                                                    alert(
                                                        globalScaffoldKey.currentContext!,
                                                        2,
                                                        "Mehanic tidak boleh kosong",
                                                        "error");
                                                  } else if (wonumber == null ||
                                                      wonumber.toString() ==
                                                          '') {
                                                    alert(
                                                        globalScaffoldKey.currentContext!,
                                                        2,
                                                        "WO Number tidak boleh kosong",
                                                        "error");
                                                  } else if (wodsvcreqnbr ==
                                                          null ||
                                                      wodsvcreqnbr.toString() ==
                                                          '') {
                                                    alert(
                                                        globalScaffoldKey.currentContext!,
                                                        2,
                                                        "SR Number tidak boleh kosong",
                                                        "error");
                                                  } else if (jobsID == null ||
                                                      jobsID.toString() == '') {
                                                    alert(
                                                        globalScaffoldKey.currentContext!,
                                                        2,
                                                        "Start/Stop tidak boleh kosong",
                                                        "error");
                                                  } else {
                                                    await UpdateMechanic(
                                                        "add",
                                                        wonumber,
                                                        srnumber,
                                                        mechanicID,
                                                        "",
                                                        "0",
                                                        "DETAIL",
                                                        txtNotes.text,
                                                        userid,
                                                        jobsID);
                                                    await getJSONData();
                                                  }
                                                },
                                                child: new Text('Submit'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: new Text('Add'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
        onRefresh: getJSONData,
        child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildListDetail(data[index], index);
            }));
  }

  Future UpdateMechanic(
      String mode,
      String wonumber,
      String srnumber,
      String mcid,
      String mechanic_id_detail,
      String seqnumber,
      String header_name,
      String notes,
      String userid,
      String event_name) async {
    try {
      EasyLoading.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String wodsvcreqnbr = prefs.getString("srnumber_mcn_detail")!;
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/sr/create_or_update_mekanik.jsp?method=update-mechanic-v1&mode=${mode}&wonumber=${wonumber}&srnumber=${wodsvcreqnbr}&mcid=${mcid}&mechanic_id_detail=${mechanic_id_detail}&seqnumber=${seqnumber}&header_name=${header_name}&notes=${notes}&event_name=${event_name}&userid=${userid.toUpperCase()}";
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
          setState(() {
            mechanicID = "";
            txtNotes.text = '';
          });
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
          print(json.decode(response.body)["message"]);
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
        alert(globalScaffoldKey.currentContext!, 0, "Gagal update mechanic",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Client, Failed update mechanic", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget _buildListDetail(dynamic value, int index) {
    //print(value["drvid"]);
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            //decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  title: Text(
                    "Mechanic ID ${index + 1} : ${value['mechanicid']}"
                    "\nMechanic Name : ${value['mechanicname']}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(bottom: 5.0, right: 5.0, left: 5.0),
            //decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: new ElevatedButton.icon(
                icon: Icon(
                  Icons.edit,
                  color: Colors.black45,
                  size: 24.0,
                ),
                label: Text("Edit", style: TextStyle(color: Colors.black45)),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var mode = "edit";
                  var wonumber = wodwonbr;
                  var srnumber = wodsvcreqnbr;//value['wodsvcreqnbr'];
                  var mcid = "";//mechanicID;// value['mechanicid'];
                  var mechanic_id_detail =value['mechanicid'];// value['mechanic_id_detail'];
                  var seqnumber = value['sequencenbr'];
                  var header_name = value['tablename'];
                  var notes = txtNotes.text;
                  var userid = prefs.getString("username");

                  await getListMechanicID(wonumber);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            title: new Text(
                                "Edit Mechanich ${value['mechanicname']}?"),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(10.0),
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      style: TextStyle(color: Colors.grey.shade800),
                                      //controller: txtNotes,
                                      keyboardType: TextInputType.text,
                                      decoration: new InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        labelText:
                                            "Old Mechanic Name: ${value['mechanicname']}",
                                        contentPadding: EdgeInsets.all(5.0),
                                      ),
                                    ),
                                  ),
                                  SmartSelect<String>.single(
                                    title: 'New Mechanic',
                                    selectedValue: mechanicID,
                                    placeholder: 'Pilih satu',
                                    onChange: (selected) {
                                      print('selected.value ${selected.value}');
                                      setState(() {
                                        mechanicID = selected.value;
                                      });
                                    },
                                    choiceItems: S2Choice.listFrom<String, Map>(
                                        source: lstMechanicID,
                                        value: (index, item) => item['value'],
                                        title: (index, item) => item['title']),
                                    //choiceGrouped: true,
                                    modalFilter: true,
                                    modalFilterAuto: true,
                                  ),
                                  // Container(
                                  //   margin: EdgeInsets.all(10.0),
                                  //   child: TextField(
                                  //     cursorColor: Colors.black,
                                  //     style:
                                  //         TextStyle(color: Colors.grey.shade800),
                                  //     controller: txtNotes,
                                  //     keyboardType: TextInputType.text,
                                  //     decoration: new InputDecoration(
                                  //       fillColor: Colors.white,
                                  //       filled: true,
                                  //       isDense: true,
                                  //       labelText: "Notes",
                                  //       contentPadding: EdgeInsets.all(5.0),
                                  //     ),
                                  //   ),
                                  // ),
                                ]),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new TextButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              new TextButton(
                                onPressed: () async {
                                  Navigator.of(globalScaffoldKey.currentContext!)
                                      .pop(false);
                                  showDialog(
                                    context: globalScaffoldKey.currentContext!,
                                    builder: (context) => new AlertDialog(
                                      title: new Text('Edit mechanic?'),
                                      actions: <Widget>[
                                        new TextButton(
                                            onPressed: () async {
                                              Navigator.of(globalScaffoldKey.currentContext!)
                                                  .pop(false);
                                            },
                                            child: new Text('No')),
                                        new TextButton(
                                          onPressed: () async {
                                            Navigator.of(globalScaffoldKey.currentContext!)
                                                .pop(false);
                                            print(txtNotes.text);
                                            if (mechanicID == null ||
                                                mechanicID == '') {
                                              alert(
                                                  globalScaffoldKey.currentContext!,
                                                  2,
                                                  "Mehanic tidak boleh kosong",
                                                  "error");
                                            } else if (mechanic_id_detail == mechanicID) {
                                              alert(
                                                  globalScaffoldKey.currentContext!,
                                                  2,
                                                  "Silahkan pilih mechanic yang lain",
                                                  "error");
                                            } else if (value['wodwonbr'] ==
                                                    null ||
                                                value['wodwonbr'].toString() ==
                                                    '') {
                                              alert(
                                                  globalScaffoldKey.currentContext!,
                                                  2,
                                                  "WO Number tidak boleh kosong",
                                                  "error");
                                            } else if (value['wodsvcreqnbr'] ==
                                                    null ||
                                                value['wodsvcreqnbr']
                                                        .toString() ==
                                                    '') {
                                              alert(
                                                  globalScaffoldKey.currentContext!,
                                                  2,
                                                  "SR Number tidak boleh kosong",
                                                  "error");
                                            } else {
                                              print("mcid ${mechanic_id_detail}");
                                              print("mechanic_id_detail ${mcid}");
                                              await UpdateMechanic(
                                                  mode,
                                                  wonumber,
                                                  srnumber,
                                                  mechanicID,
                                                  mechanic_id_detail,
                                                  seqnumber,
                                                  header_name,
                                                  notes,
                                                  userid!,
                                                  "");
                                              await getJSONData();
                                            }
                                          },
                                          child: new Text('Submit'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: new Text('Update'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    this.getJSONData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
