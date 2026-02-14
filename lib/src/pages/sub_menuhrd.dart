
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/pages/DetailMenu.dart';
import 'package:dms_anp/src/pages/driver/ListDriver.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWo.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../flusbar.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;

class SubMenuHrd extends StatefulWidget {
  @override
  _SubMenuHrdState createState() => _SubMenuHrdState();
}

class _SubMenuHrdState extends State<SubMenuHrd> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DetailMenu()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
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
          title: Text('Sub Menu HRD')),
      body: Container(
        key: globalScaffoldKey,
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[ImgHeader1(context), buildMenu(context)],
        ),
      ),
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
                          onTap: () async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            var loginname = prefs.get("loginname");
                            print(loginname);
                            var isOK = globals.akses_pages == null
                                ? globals.akses_pages
                                : globals.akses_pages.where((x) => x == "HR" || x == "HD" || x=="UA");
                            if(isOK!=null){
                              if (isOK.length > 0) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ListDriver()));
                              }else{
                                alert(globalScaffoldKey.currentContext!,0,"Anda tidak punya akses","error");
                              }
                            }
                          },
                          child: Column(children: <Widget>[
                            ListTile( title: Text("List Driver"),leading: Icon(Icons.book),trailing: Icon(Icons.arrow_right)),
                          ]))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



}
