
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/custom_loader.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ViewListDo.dart';

class PageResponseMessage extends StatefulWidget {
  @override
  _PageResponseMessageState createState() => _PageResponseMessageState();
}
class _PageResponseMessageState extends State<PageResponseMessage> {
  late SharedPreferences sharedPreferences;
  String route_pages="";
  String route_pages_message="";
  @override
  void initState() {
    super.initState();
    configLoading();
    getDataPreference();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
          backgroundColor: Color(0xFFFF1744),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 20.0,
            onPressed: () {
              _goBack(context,1);
            },
          ),
          //backgroundColor: Colors.transparent,
          //elevation: 0.0,
          centerTitle: true,
          title: Text('')),
      body: Container(
        //key: _scaffoldKeyListVH,
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[
            _getContent(context),
          ],
        ),
      ),
    );
  }


  _goBack(BuildContext context,int id) {
    print(route_pages);
    if(route_pages!=null && route_pages!=""){
      sharedPreferences.remove("route_pages");
      sharedPreferences.remove("route_pages_message");
    }

    if(id==1){
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewListDo()));
    }else{
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewDashboard()));
    }

  }

  getDataPreference() async{
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      route_pages= sharedPreferences.getString("route_pages")!;
      route_pages_message= sharedPreferences.getString("route_pages_message")!;
    });
    print("MESSAGE ${route_pages_message}");
  }
  Widget _getContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: ListView(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 14.0,
              shadowColor: Color(0x802196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Message",style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),),
                    subtitle: Text("${route_pages_message}",style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FloatingActionButton.extended(
                        backgroundColor:
                        Colors.redAccent, //const Color(Colors.blue),
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          if(route_pages=="view_list_do"){
                            _goBack(context,1);
                          }else{
                            _goBack(context,0);
                          }

                        },
                        icon: Icon(Icons.backpack),
                        label: Text('Ok'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
