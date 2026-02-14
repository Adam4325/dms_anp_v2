import 'dart:convert';
import 'dart:typed_data';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/pages/FrmCloseVehicle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewImageDo extends StatefulWidget {
  @override
  _ViewImageDoState createState() => _ViewImageDoState();
}

final globalScaffoldKey1 = GlobalKey<ScaffoldState>();
class _ViewImageDoState extends State<ViewImageDo> {
String imageDo="";
late SharedPreferences prefsImage;
@override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 20.0,
            onPressed: () {
              _goBack(globalScaffoldKey1.currentContext!);
            },
          ),
          centerTitle: true,
          title: Text('')),
      body: Container(
        key: globalScaffoldKey1,
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[
            _getViewImage(globalScaffoldKey1.currentContext!)
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    getSession();
    super.initState();
  }
  _goBack(BuildContext context) {
    prefsImage.setString("imageDo",imageDo);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FrmCloseVehicle()),
    );
  }
  Widget _getViewImage(BuildContext context)  {
    late Uint8List bytes;
    setState(()  {
      //print(imageDo);
       bytes = base64Decode(imageDo);
    });
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      margin: new EdgeInsets.only(top: 0.0),
      width: double.infinity,
      height: double.infinity,
      child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 14.0,
          shadowColor: Color(0x802196F3),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: new Image.memory(bytes, fit: BoxFit.cover, height: 150)),
    );
  }

  Future getSession() async {
  prefsImage = await SharedPreferences.getInstance();
    setState(() {
      imageDo = prefsImage.getString("imageDO")!;
    });
  }
}