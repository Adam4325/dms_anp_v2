
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/DetailMenu.dart';
import 'package:dms_anp/src/pages/FormVerifikasiOBP.dart';
import 'package:dms_anp/src/pages/FrmPreviewObp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewListObp extends StatefulWidget {//
  @override
  _ViewListObpState createState() => _ViewListObpState();
}

class _ViewListObpState extends State<ViewListObp> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  TextEditingController editingController = new TextEditingController();
  late WebViewController _controllerWeb;
  List data = [];
  List duplicateItems = [];
  String status_code = "";
  String message = "";
  final Color primaryOrange = const Color(0xFFFF8A50);
  final Color lightCream = const Color(0xFFFFFCF8);

  final Uri _url = Uri.parse('https://flutter.dev');

  void reloadWebView() {
    _controllerWeb.reload();
  }


  launchUrl(Uri parse) {}

  Future<void> launchUrlStart({String? url}) async {
    if (!await launchUrl(Uri.parse(url!))) {
      throw 'Could not launch $url';
    }
  }

  Future<String?> CloseObp(
      String vhcid,
      String bpnbr,String userid) async {
    EasyLoading.show();
    try {
      //"D:\JAVA PROJECT\Cemindo\web\mobile\api\laka\detail_list_obp.jsp"
      var urlData =
          "${GlobalData.baseUrl}api/laka/close_obp.jsp?method=close-obp-v1" +
              "&vhcid=" +
              vhcid +
              "&bpnbr=" +
              bpnbr +
              "&userid=" +
              userid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
          getJSONData();
        } else {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  Future<String> getJSONData() async {
    EasyLoading.show();
    try{
      var url = "";
      //"D:\JAVA PROJECT\Cemindo\web\mobile\api\laka\detail_list_obp.jsp"
      setState(() {
        url = "${GlobalData.baseUrl}api/laka/detail_list_obp.jsp?method=list-obp-v1";
      });
      Uri myUri = Uri.parse(url);
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        data = json.decode(response.body);
        duplicateItems = [];
        duplicateItems = data;
        print(data);
        if (data == null || data.length == 0 || data == "") {
          alert(globalScaffoldKey.currentContext!, 2, "Anda tidak mempunyai data OBP", "warning");
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
    //EasyLoading.dismiss();
    return "Successfull";
  }

  Future<String> getJSONDataSearch(String query) async {
    EasyLoading.show();
    try{
      var url = "";
      //"D:\JAVA PROJECT\Cemindo\web\mobile\api\laka\detail_list_obp.jsp"
      setState(() {
        url = "${GlobalData.baseUrl}api/laka/detail_list_obp.jsp?method=list-obp-v1&search=${query}";
      });
      Uri myUri = Uri.parse(url);
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        data = json.decode(response.body);
        duplicateItems = [];
        duplicateItems = data;
        print(data);
        if (data == null || data.length == 0 || data == "") {
          alert(globalScaffoldKey.currentContext!, 2, "Anda tidak mempunyai data OBP", "warning");
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
    //EasyLoading.dismiss();
    return "Successfull";
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DetailMenu()));
  }

  void filterSearchResults(String query) {
    print(duplicateItems);
    setState(() {
      data = duplicateItems
          .firstWhere((item) => item['bpnbr'].toLowerCase().contains(query.toLowerCase()) ||
          item['bpvhcid'].toLowerCase().contains(query.toLowerCase())
      );
    });
  }

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DetailMenu()));
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: primaryOrange,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('List OBP',style:TextStyle( color: Colors.white))),
        body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 25,bottom: 8,right: 25,top: 20),
                child: TextField(
                  controller: editingController,
                  decoration: InputDecoration(
                      labelText: "Search",
                      hintText: "Search",
                      //prefixIcon: Icon(Icons.search),
                      suffixIcon: Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(70, 30),
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            // shape: new RoundedRectangleBorder(
                            //   borderRadius: new BorderRadius.circular(30.0),
                            // ),
                          ),
                          child: Text("Search"),
                          onPressed: () {
                            if(editingController.text==null || editingController.text=='') return;
                            getJSONDataSearch(editingController.text);
                          },
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: primaryOrange, width: 1.5),
                      )),
                ),
              ),
              Expanded(
                child: new Stack(
                   children: <Widget>[_buildListView(context)],//
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
        child:ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildViewOBP(data[index], index);
            })
    );
  }

  Widget _buildViewOBP(dynamic value, int index) {
    //print(value["drvid"]);
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      color: lightCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryOrange),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: lightCream),
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
                  "BP. Number : ${value['bpnbr']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Date: ${value['bpdate']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Driver Name: ${value['bpdrivername']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Nopol : ${value['bpvhcid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Amount :  ${value['bpamount']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Status : ${value['bpstatus']}",
                      style: TextStyle(color:value['bpstatus'].toString()=='CLOSE'? Colors.red:Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Locid : ${value['bplocid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Notes : ${value['bpnotes']}",
                      style: TextStyle(color: Colors.black)),
                ]),
              ),
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5.0, right: 15.0, top: 12.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                buildButtonClose(context,value),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Preview"),
                      onPressed: () async {
                        // globals.bpnbr = '';
                        // globals.bpvhcid = '';
                        // globals.bpdrivername = '';
                        // globals.bpnbr = value['bpnbr'];
                        // globals.bpvhcid = value['bpvhcid'];
                        // globals.bpdrivername = value['bpdrivername'];
                        //EasyLoading.show();
                        // var _url = 'http://apps.tuluatas.com:8080/trucking/bp.jsp?method=preview-v1?pbnbr=${value['bpnbr']}';
                        // launch(_url);
                        EasyLoading.show();
                        globals.bpnbr_web_view = value['bpnbr'];
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FrmPreviewObp()));
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget buildButtonClose(BuildContext context,value){
    if(value["bpstatus"].toString().toUpperCase()=='CLOSE'){
      return Container();
    }else{
      return Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 15.0,
            ),
            label: Text("Close/Verrifikasi"),
            onPressed: () async {
              // SharedPreferences prefs = await SharedPreferences
              //     .getInstance(); //SEMENTARA
              // prefs.setString("BPNBR", value['bpnbr']);
              globals.bpnbr = '';
              globals.bpvhcid = '';
              globals.bpdrivername = '';
              globals.bpnbr = value['bpnbr'];
              globals.bpvhcid = value['bpvhcid'];
              globals.bpdrivername = value['bpdrivername'];
              EasyLoading.show();
              Timer(Duration(seconds: 1), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FrmVerifikasiObp()));
              });
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 5, vertical: 10),
                textStyle: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ));
    }

  }
  @override
  void initState() {
    super.initState();
    this.getJSONData();
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
