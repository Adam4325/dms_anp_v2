import 'dart:async';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/pages/FrmObp.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewListObp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../flusbar.dart';

class DetailMenuObp extends StatefulWidget {
  @override
  _DetailMenuObpState createState() => _DetailMenuObpState();
}

class _DetailMenuObpState extends State<DetailMenuObp> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        onWillPop: () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ViewDashboard()));
      return Future.value(false);
    },
    child: Scaffold(
      backgroundColor: Colors.blueAccent,
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
          title: Text('Detail Menu OBP')),
      body: Container(
        key: globalScaffoldKey,
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[ImgHeader1(context), buildMenu(context)],
        ),
      ))
    );
  }

  Widget ImgHeader1(BuildContext context) {
    return Container(
      child: new Image.asset(
        "assets/img/truck_header.jpg",
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: new BoxConstraints.expand(height: 295.0),
    );
  }

  Widget buildMenu(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: ListView(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 0.0,
              shadowColor: Color(0x802196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(5.0),
                      child: InkWell(
                          onTap: () {
                            EasyLoading.show();
                            Timer(Duration(seconds: 1), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FrmObp()));
                            });
                          },
                          child: Column(children: <Widget>[
                            ListTile(
                                title: Text("BP Laka Tunggal"),
                                leading: Icon(Icons.car_rental),
                                trailing: Icon(Icons.arrow_right)),
                          ]))),
                ],
              ),
            ),
          ),
          Container(
            child: Card(
              elevation: 0.0,
              shadowColor: Color(0x802196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(5.0),
                      child: InkWell(
                          onTap: () {
                            // Navigator.pushReplacement(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => FromObpDouble()));
                          },
                          child: Column(children: <Widget>[
                            ListTile(
                                title: Text("BP Laka Double"),
                                leading: Icon(Icons.people),
                                trailing: Icon(Icons.arrow_right)),
                          ]))),
                ],
              ),
            ),
          ),
          Container(
            child: Card(
              elevation: 0.0,
              shadowColor: Color(0x802196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(5.0),
                      child: InkWell(
                          onTap: () {
                            EasyLoading.show();
                            Timer(Duration(seconds: 1), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewListObp()));
                            });
                          },
                          child: Column(children: <Widget>[
                            ListTile(
                                title: Text("Close OBP"),
                                leading: Icon(Icons.book),
                                trailing: Icon(Icons.arrow_right)),
                          ]))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card listSectionMethod(String title, String subtitle, IconData icon) {
    return new Card(
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          icon,
          color: Colors.blue,
        ),
      ),
    );
  }
}
