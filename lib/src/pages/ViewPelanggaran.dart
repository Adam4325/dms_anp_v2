import 'dart:convert';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../flusbar.dart';
import 'ViewDashboard.dart';

class ViewListPelanggaran extends StatefulWidget {
  @override
  _ViewListPelanggaranState createState() => _ViewListPelanggaranState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();
class _ViewListPelanggaranState extends State<ViewListPelanggaran> {
  final formatCurrency = new NumberFormat.simpleCurrency(locale: 'id_ID');
  late SharedPreferences prefs;
  late List data;
  String status_code = "";
  String message = "";
  late int month;
  late int year;
  final monthNow = new DateTime.now().month;
  final yearNow = new DateTime.now().year;
  int yearLast = 0;
  String? selectedValues;
  String? _chosenValue;
  ProgressDialog? pr;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
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
            title: Text('Pelanggaran')),
        body: new Container(
          key: globalScaffoldKey,
          margin: const EdgeInsets.only(top: 10.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _buildFormSearch(context),
              _buildListView()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    getDataPelanggaran();
    setState(() {
      selectedValues = month.toString();
      yearLast = yearNow + 10;
    });
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.initState();

  }

  Future<String> getDataPelanggaran() async {
    try {
      EasyLoading.show();
      prefs = await SharedPreferences.getInstance();
      String drvid = prefs.getString("drvid")!;
      String drvids = "3188-10.2017.23.01.94";
      //4865.12.2019.10.03.65
      if (month == null) {
        month = monthNow;
      }

      if (year == null) {
        year = yearNow;
      }
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrlProd}api/ritase_pelanggaran.jsp?method=pelanggaran&driverid=" +
              drvid.toString() +
              "&month=" +
              month.toString() +
              "&year=" +
              year.toString());
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        // Get the JSON data
        data = json.decode(response.body)["data"];
        print(data.length==0);
        if (data == null || data.length == 0 || data == "") {
          alert(globalScaffoldKey.currentContext!, 0, "Tidak ada data pelanggaran", "error");
        }
      });
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
    } catch (e) {
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
      print(e);
    }
    return "Successfull";
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Widget _buildListView() {
    return Container(
      //onRefresh: getDataRitase,
        margin: const EdgeInsets.only(top: 170),
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildPelanggaran(data[index], index);
            }));
  }

  Widget _buildFormSearch(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        height: 170.0,
        decoration: new BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xfffdfcfc), const Color(0xfffdfcfc)],
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(15.0))),
        child: new Column(
          children: <Widget>[
            new Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new DropdownButton<String>(
                    value: _chosenValue,
                    style: TextStyle(color: Colors.black),
                    items: <String>[
                      "January",
                      "February",
                      "Maret",
                      "April",
                      "Mei",
                      "Juni",
                      "Juli",
                      "Agustus",
                      "September",
                      "Oktober",
                      "November",
                      "Desember"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text(
                      "Pilih Bulan",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _chosenValue = value;
                        if(value=="January"){
                          month = 1;
                        }else if(value=="February"){
                          month = 2;
                        }else if(value=="Maret"){
                          month = 3;
                        }else if(value=="April"){
                          month = 4;
                        }else if(value=="Mei"){
                          month = 5;
                        }else if(value=="Juni"){
                          month = 6;
                        }else if(value=="Juli"){
                          month = 7;
                        }else if(value=="Agustus"){
                          month = 8;
                        }else if(value=="September"){
                          month = 9;
                        }else if(value=="Oktober"){
                          month = 10;
                        }else if(value=="November"){
                          month = 11;
                        }else if(value=="Desember"){
                          month = 12;
                        }else{
                          month=0;
                        }
                        print(month);
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      child: SpinBox(
                        max: double.parse(yearLast.toString()),
                        value: double.parse(yearNow.toString()),
                        step: 1,
                        decimals: 0,
                        decoration: InputDecoration(labelText: 'Year'),
                        onChanged: (value) {
                          setState(() {
                            var sVal = value.toString().split('.');
                            year = int.parse(sVal[0].toString());
                            print(year);
                          });
                        },
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
                child: new Row(children: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      FloatingActionButton.extended(
                        backgroundColor:
                        Colors.blueAccent, //const Color(Colors.blue),
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          try{

                            if(month==null || month==0){
                              alert(globalScaffoldKey.currentContext!,0,'Bulan belum dipilih','error');
                            }else{
                              getDataPelanggaran();
                            }

                          }catch(e){
                            print(e);
                          }
                        },
                        icon: Icon(Icons.search),
                        label: Text('Search'),
                      )
                    ],
                  ),
                ]))
          ],
        ));
  }

  Widget _buildPelanggaran(dynamic item, int index) {
    return new Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        height: 100.0,
        decoration: new BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xfffdfcfc), const Color(0xfffdfcfc)],
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(15.0))),
        child: new Column(
          children: <Widget>[
            new Container(
              padding: EdgeInsets.all(12.0),
              decoration: new BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blueAccent, Colors.blue],
                  ),
                  borderRadius: new BorderRadius.only(
                      topLeft: new Radius.circular(15.0),
                      topRight: new Radius.circular(15.0))),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    "Pelanggaran ${index + 1} ",
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontFamily: "NeoSansBold"),
                  ),
                  new Container(
                    child: new Text(
                      "BP. Date ${item['bpdate']}",
                      style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontFamily: "NeoSansBold"),
                    ),
                  )
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 12.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.only(top: 5.0),
                      ),
                      new Text(
                        "Nilai : ${item['nilai']}",
                        style: TextStyle(color: Colors.black, fontSize: 20.0),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
