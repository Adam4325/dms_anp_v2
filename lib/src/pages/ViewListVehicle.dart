import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/RIKeys.dart';
import 'package:dms_anp/src/Helper/utilsF.dart';
import 'package:dms_anp/src/custom_loader.dart';
import 'package:dms_anp/src/pages/FrmCloseVehicle.dart';
import 'package:dms_anp/src/pages/Homeold.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../flusbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class ViewListVehicle extends StatefulWidget {
  //ViewListVehicle({Key key, this.title}) : super(key: key);
  //final String title;

  @override
  _ViewListVehicleState createState() => _ViewListVehicleState();
}

class _ViewListVehicleState extends State<ViewListVehicle> {
  late SharedPreferences sharedPreferences;
  String? spLoginName;
  String? loginname;
  TextEditingController txtKM = new TextEditingController();
  List<TextEditingController> _controllers = [];
  final GlobalKey<ScaffoldState> _scaffoldKeyListVH = new GlobalKey<ScaffoldState>();
  late List data;

  getDataPreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      loginname = sharedPreferences.getString("loginname");
      if(loginname != null) {
        spLoginName = sharedPreferences.getString("loginname");
      } else {
        spLoginName = "Sign in with Google";
      }
    });
  }

  Future<String> generateRandomString(int len) async {
    var random = Random.secure();
    var value = random.nextInt(1000000000);
    return value.toString();
  }
  // Function to get the JSON data
  Future<String> getJSONData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid")!;
    print(drvid);
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/list_vehicle_do.jsp?method=list_do_vehicle");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {

      // Get the JSON data
      data = json.decode(response.body)["data"];
      print(data);
      if (data == null || data.length == 0 || data == "") {
        alert(context, 0, "List Vehicle tidak ditemukan", "error");
      }
      //EasyLoading.dismiss();
    });
    return "Successfull";
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('Form List Vehicle')
        ),
        body: new Container(
          key: RIKeys.riKey1,
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#f0eff4"),
          child: new Stack(
            children: <Widget>[_buildListView()],
          ),
        ),
      );
  }

  Widget _buildListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (context, index) {
          _controllers.add(new TextEditingController());
          return _buildRowListDo(data[index],index);
        });
  }

  Widget _buildRowListDo(dynamic item,int index) {
    return Container(
      padding: EdgeInsets.only(left: 0, top: 50, bottom: 0, right: 0),
      child: Card(
        elevation: 14.0,
        shadowColor: Color(0x802196F3),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("NOPOL: " + item['vhcnopol']),
              subtitle: Text("Cabang: " + item["locid"]),
              //leading: CircleAvatar(backgroundImage: NetworkImage("https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
              //trailing: Icon(Icons.star)
            ),
            ListTile(
              title: Text("Driver Name: " + item["drvname"]),
              subtitle: Text("KM " + item["km"]),
              //leading: CircleAvatar(backgroundImage: NetworkImage("https://miro.medium.com/fit/c/64/64/1*WSdkXxKtD8m54-1xp75cqQ.jpeg")),
              //trailing: Icon(Icons.star)
            ),
            ButtonBar(
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: UniqueKey(),//'btn${item['vhcnopol'].toString().replaceAll(" ", "")}${utilsF.CreateCryptoRandomString(32)}',
                  backgroundColor: Colors.lightBlue, //const Color(Colors.blue),
                  foregroundColor: Colors.white,
                  onPressed: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("frmVhcid", item['vhcnopol'].toString());
                    prefs.setString("frmDrvname", item['drvname'].toString());
                    GlobalData.frmVhcid = item['vhcnopol'];
                    GlobalData.frmDrvName = item['drvname'];
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => FrmCloseVehicle()));
                  },
                  icon: Icon(Icons.save),
                  label: Text('Close'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //
    configLoading();
    //EasyLoading.init();
    this.getJSONData();
  }

  @override
  void dispose() {
    super.dispose();
    _controllers.clear();
  }
}
