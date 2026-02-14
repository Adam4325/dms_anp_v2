import 'dart:async';
import 'package:dms_anp/src/pages/ViewListDoOpr.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper//globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import '../flusbar.dart';

class AdvanceSearchDoOp extends StatefulWidget {
  @override
  _AdvanceSearchDoOpState createState() => _AdvanceSearchDoOpState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();
class _AdvanceSearchDoOpState extends State<AdvanceSearchDoOp> {
  TextEditingController _locid = new TextEditingController();
  TextEditingController _vhcid = new TextEditingController();
  late String _chosenValue;
  String arrayLocid ="";
  List<String> arrLocid = [];

  @override
  void initState() {
    super.initState();
    getDataPreference();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewListDoOpr()));
        return Future.value(false);
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
            title: Text('More Search')),
        body: new Container(
          key: globalScaffoldKey,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[_buildFormSearch(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSearch(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        height: 200.0,
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
            new DropdownButton<String>(
              value: _chosenValue,
              style: TextStyle(color: Colors.black),
              items: arrLocid.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Text(
                "Pilih Cabang Lokasi",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onChanged: (String? value) async{
                SharedPreferences prefs =await SharedPreferences.getInstance();
                setState(() {
                  _chosenValue = value!;
                  globals.locid=_chosenValue;
                  prefs.setString("sLOCID", globals.locid!) ;
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 0),
              child: TextField(
                cursorColor: Colors.black,
                controller: _vhcid,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  fillColor: Colors.black12,
                  filled: true,
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                  EdgeInsets.only(left: 5, bottom: 11, top: 0, right: 5),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        label: Text("Search"),
                        onPressed: () async{
                          SharedPreferences prefs =await SharedPreferences.getInstance();
                          globals.vhcid = _vhcid.value.text;
                          if(globals.vhcid=="" && globals.locid==""){
                            alert(
                                globalScaffoldKey.currentContext!,
                                2,
                                "Pencarian teks tidak boleh kosong",
                                "warning");
                          }else{
                            prefs.setString("sVHCID", _vhcid.value.text) ;
                            _goBack(context);
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
                ])
            )
          ],
        ));
  }

  getDataPreference() async {
    SharedPreferences resPreps = await SharedPreferences.getInstance();
    setState(() {
      arrayLocid= resPreps.getString("locid")!;
      if(arrayLocid.toString().split(",").length>0){
        arrayLocid = "ALL,$arrayLocid";
        arrLocid  =arrayLocid.toString().split(",");
      }else{
        arrLocid  =arrayLocid.toString().split(",");
      }
      print(arrLocid);
    });
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewListDoOpr()));
  }
}