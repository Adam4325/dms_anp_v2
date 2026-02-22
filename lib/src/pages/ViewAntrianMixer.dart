import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../flusbar.dart';

class ViewAntrianMixer extends StatefulWidget {
  @override
  _ViewAntrianMixerState createState() => _ViewAntrianMixerState();
}

class _ViewAntrianMixerState extends State<ViewAntrianMixer> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtNotes = new TextEditingController();
  ProgressDialog? pr;
  int limit = 0;
  int offset = 10;
  List data = [];
  List dataAntrian = [];
  String status_code = "";
  String message = "";
  String drvid = "";
  String locid = "";
  String vhcid = "";
  String vhcid_last = "";
  String userid = "";
  bool isAntrian = false;
  String antrian_vhcid = "-";
  String antrian_created_date = "-";
  String antrian_noantrian = "-";

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
            title: Text('List Antrian DO mixer')),
        body: new Container(
          key: globalScaffoldKey,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[
              _buildFormSearch(context),
              _buildListView(context)
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _loadMore() async {
    print("onLoadMore");
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    getJSONData(false);
    return true;
  }

  Future<String?> getAntrianLast() async {
    //EasyLoading.show();
    isAntrian = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    drvid = prefs.getString("drvid")!;
    String _vhcid = "";//prefs.getString("vhcidfromdo");
    print(drvid);
    print("_vhcid-${_vhcid}");
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/do_mixer/last_antrian.jsp?method=get-antrian&drvid=" +
            drvid +
            "&vhcid=" +
            _vhcid);
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      print(response.body);
      var status_code = json.decode(response.body)["status_code"];
      if(status_code=="200"){
        dataAntrian = json.decode(response.body)["data"];
        print(dataAntrian);
        if (dataAntrian != [] && dataAntrian.length > 0) {
          antrian_noantrian = dataAntrian[0]['noantrian'];
          antrian_vhcid = dataAntrian[0]['vhcid'];
          antrian_created_date = dataAntrian[0]['created_date'];
        } else {
          isAntrian = true;
        }
      }else{
        var msg = json.decode(response.body)["message"];
        alert(
            globalScaffoldKey
                .currentContext!,
            0,
            msg,
            "error");
      }

    });
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    return "Successfull";
  }

  Future<String?> getJSONData(bool isloading) async {
    //EasyLoading.show();
    if (isloading == true) {
      if(EasyLoading.isShow==false){
        EasyLoading.show();
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    drvid = prefs.getString("drvid")!;
    locid = prefs.getString("locid")!;
    vhcid = prefs.getString("vhcid")!;
    vhcid_last = (prefs.getString("method")=="new"? prefs.getString("vhcid_last_antrian"):vhcid)!;
    print('vhcid_last ${vhcid_last}');
    if (vhcid_last != "" && vhcid_last != null) {
      print(drvid);//
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/do_mixer/list_do_antrian_mixer.jsp?method=antrianv1&driverid=" +
              drvid.toString() +
              "&locid=" +
              locid.toString() +
              "&vhcid=" +
              vhcid_last +
              "&limit=" +
              limit.toString() +
              "&offset=" +
              offset.toString());
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        // Get the JSON data
        data = json.decode(response.body)["data"];
        print(data);
        if (data == null || data.length == 0) {
          alert(globalScaffoldKey.currentContext!, 0,
              "Anda tidak mempunyai data DO", "error");
        }
      });
    } else {
      data = [];
    }
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    return "Successfull";
  }

  Future<String?> UpdateReceiveLogDo() async {
    try {
      //String _photo = photo!=null && photo!=""?photo.toString().trim():"";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var drVID = prefs.getString("drvid")!;
      String vhCID = prefs.getString("vhcidfromdo")!;
      var dataParam = {
        "method": "update-or-insert-log",
        "drvid": drVID.toString(),
        "vhcid": vhCID.toString(),
        "is_used": "0"
      };
      var urlData = "${GlobalData.baseUrl}api/log_receive_do.jsp";

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      final response = await http.post(
        myUri,
        body: dataParam,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<String?> createAntrianNewDriver(String dlodate, nodo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String km_newDriver = prefs.getString("km_new") ?? "";
    String page_antrian = prefs.getString("page_antrian") ?? "";
    drvid = prefs.getString("drvid") ?? "";
    locid = prefs.getString("locid") ?? "";
    vhcid = prefs.getString("vhcid_last_antrian") ?? "";
    userid = prefs.getString("name") ?? "";
    var bujnumber = (prefs.getString("bujnumber") ?? "");
    print(drvid);
    if(EasyLoading.isShow==false){
      EasyLoading.show();
    }
    try {

      if (bujnumber == null || bujnumber == '') {
        //print("Bujnumber tidak boleh kosong, silahkan terima do terlebih dahulu");
        alert(
            globalScaffoldKey.currentContext!,
            2,
            "Bujnumber tidak boleh kosong, silahkan terima do terlebih dahulu",
            "Warning");
      } else {
        var urlData ="${GlobalData.baseUrl}api/do/do2/create_antrian_new_driver_newp2h.jsp";
        //var urlData ="${GlobalData.baseUrl}api/maintenance/create_antrian_new_driver_newp2h.jsp";
        var dataParam = {
          "method": "create-antrian-new-driver-v1",
          "bujnumber": bujnumber,
          "vhcid": vhcid,
          "vhckm": km_newDriver,
          "locid": locid,
          "dlocustdonbr": nodo,
          "dlodate": dlodate,
          "drvid": drvid,
          "rvhcOil": globals.rvhcOil.toString(), //START PENGECEKAN
          "rvhcOliMesin": globals.rvhcOliMesin.toString(),
          "rvhcOliGardan": globals.rvhcOliGardan.toString(),
          "rvhcOliTransmisi": globals.rvhcOliTransmisi.toString(),
          "rvhcAir": globals.rvhcAir.toString(),
          "rvhcAccu": globals.rvhcAccu.toString(),
          "rvhcOlips": globals.rvhcOLips.toString(),
          "rvhcMrem": globals.rvhcMrem.toString(),
          //"rvhckm": globals.rvhcKm.toString(),
          "rvhcKabin": globals.rvhcKabin.toString(), //KABIN
          "rvhcKaca": globals.rvhcKaca.toString(),
          "rvhcSpion": globals.rvhcSpion.toString(),
          "rvhcSpeedo": globals.rvhcSpeedo.toString(),
          "rvhcWiper": globals.rvhcWiper.toString(),
          //"rvhcStir": globals.rvhcStir.toString(),
          //"rvhcElect": globals.rvhcElect.toString(),
          "rvhcKlak": globals.rvhcKlak.toString(),
          "rvhcJok": globals.rvhcJok.toString(),
          "rvhcSeatBealt": globals.rvhcSeatBealt.toString(),
          "rvhcApar": globals.rvhcApar.toString(),
          "rvhcP3k": globals.rvhcP3k.toString(),
          "rvhcCone": globals.rvhcCone.toString(),
          "rvhcStikerRef": globals.rvhcStikerRef.toString(),
          //"rvhcRStir": globals.rvhcRStir.toString(),
          "rvhcLampd": globals.rvhcLampd.toString(), //ELECTRIC
          "rvhcLampr": globals.rvhcLampr.toString(),
          "rvhcLamps": globals.rvhcLamps.toString(),
          "rvhcLampb": globals.rvhcLampBlk.toString(),
          "rvhcLampm": globals.rvhcLampm.toString(),
          "rvhcLampAlarm": globals.rvhcLampAlarm.toString(),
          "rvhcKopling": globals.rvhcKopling.toString(), //CHASIS
          "rvhcGardan": globals.rvhcGardan.toString(),
          "rvhcParking": globals.rvhcParking.toString(),
          "rvhcFoot": globals.rvhcFoot.toString(),
          "rvhcBautRoda": globals.rvhcBautRoda.toString(),
          "rvhcVelg": globals.rvhcVelg.toString(),
          "rvhcBan": globals.rvhcBan.toString(), //BAN
          "rvhcAngin": globals.rvhcAngin.toString(),
          "rvhcTerpal": globals.rvhcTerpal.toString(), //PERALATAN
          "rvhcWebing": globals.rvhcWebing.toString(),
          "rvhcTambang": globals.rvhcTambang.toString(),
          "rvhcDongkrak": globals.rvhcDongkrak.toString(),
          "rvhcKRoda": globals.rvhcKRoda.toString(),
          "rvhcGBan": globals.rvhcGBan.toString(),
          "rvhcGps": globals.rvhcGps.toString(),
          "rvhcDashCam": globals.rvhcDashCam.toString(),
          "rvhcSurat": globals.rvhcSurat.toString(), //DOKUMENT
          //"rvhcHandrail": globals.rvhcHandrail.toString(),
          //"rvhcAlarm": globals.rvhcAlarm.toString(),
          "rvhcSurat": globals.rvhcSurat.toString(),
          "rvhcKir": globals.rvhcKir.toString(),
          "rvhcSim": globals.rvhcSim.toString(),
          "userid": userid.toString(),
          "vhcnotes": globals.rvhcNotes,
          "vhcposisiban1": globals.vhcposisiban1.toString(),
          "vhcposisiban2": globals.vhcposisiban2.toString(),
          "vhcposisiban3": globals.vhcposisiban3.toString(),
          "vhcposisiban4": globals.vhcposisiban4.toString(),
          "vhcposisiban5": globals.vhcposisiban5.toString(),
          "vhcposisiban6": globals.vhcposisiban6.toString(),
          "vhcposisiban7": globals.vhcposisiban7.toString(),
          "vhcposisiban8": globals.vhcposisiban8.toString(),
          "vhcposisiban9": globals.vhcposisiban9.toString(),
          "vhcposisiban10": globals.vhcposisiban10.toString(),
          "vhcposisiban11": globals.vhcposisiban11.toString(),
          "vhcposisiban12": globals.vhcposisiban12.toString(),
          "vhcposisiban13": globals.vhcposisiban13.toString(),
          "vhcposisiban14": globals.vhcposisiban14.toString(),
          "vhcposisiban15": globals.vhcposisiban15.toString(),
          "vhcposisiban16": globals.vhcposisiban16.toString(),
          "vhcposisiban17": globals.vhcposisiban17.toString(),
          "vhcposisiban18": globals.vhcposisiban18.toString(),
          "vhcposisiban19": globals.vhcposisiban19.toString(),
          "vhcposisiban20": globals.vhcposisiban20.toString(),
          "vhcposisiban21": globals.vhcposisiban21.toString(),
          "vhcposisiban22": globals.vhcposisiban22.toString(),
          "vhcposisiban23": globals.vhcposisiban23.toString(),
          "vhcposisiban24": globals.vhcposisiban24.toString(),
        };
        var encoded = Uri.encodeFull(urlData);
        Uri myUri = Uri.parse(encoded);
        print(myUri);
        // var response =
        //     await http.get(myUri, headers: {"Accept": "application/json"});
        final response = await http.post(
          myUri,
          body: dataParam,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        setState(() {
          print(json.decode(response.body));
          status_code = json.decode(response.body)["status_code"].toString();
          message = json.decode(response.body)["message"];
          if (int.parse(status_code) == 200 || status_code == "200") {
            if(EasyLoading.isShow){
              EasyLoading.dismiss();
            }
            alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
            Timer(Duration(seconds: 1), () {
              // 5s over, navigate to a new page
              //prefs.remove("page_antrian");
              ResetDataInspeksi();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ViewDashboard()));
            });
          } else {
            if(EasyLoading.isShow){
              EasyLoading.dismiss();
            }
            Navigator.of(context).pop(false);
            alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
          }
        });
      }
    } catch (e) {
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  Future<String?> createAntrian(String dlodate, String nodo) async {
    try{
      if(EasyLoading.isShow==false){
        EasyLoading.show();
      }

      var messageData = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String km_newDo = prefs.getString("km_new")!;
      drvid = prefs.getString("drvid")!;
      locid = prefs.getString("locid")!;
      vhcid = prefs.getString("vhcid")!;
      userid = prefs.getString("name")!;
      String page_antrian = prefs.getString("page_antrian")!;
      String? bujnumber = page_antrian!=null && page_antrian!=""? page_antrian:prefs.getString("bujnumber");
      if (bujnumber == null || bujnumber == '') {
        alert(
            globalScaffoldKey.currentContext!,
            2,
            "Bujnumber tidak boleh kosong, silahkan terima do terlebih dahulu",
            "Warning");
      } else {
        var dataParam = {
          "method": "create-v2",
          "bujnumber": bujnumber.toString(),
          "drvid": drvid.toString(),
          "locid": locid.toString().toString(),
          "vhcid": prefs.getString("vhcidfromdo").toString(),
          "vhckm": km_newDo,
          "vhcdate": dlodate.toString(),
          "dlocustdonbr": nodo.toString(),
          "rvhcOil": globals.rvhcOil.toString(), //START PENGECEKAN
          "rvhcOliMesin": globals.rvhcOliMesin.toString(),
          "rvhcOliGardan": globals.rvhcOliGardan.toString(),
          "rvhcOliTransmisi": globals.rvhcOliTransmisi.toString(),
          "rvhcAir": globals.rvhcAir.toString(),
          "rvhcAccu": globals.rvhcAccu.toString(),
          "rvhcOlips": globals.rvhcOLips.toString(),
          "rvhcMrem": globals.rvhcMrem.toString(),
          //"rvhckm": globals.rvhcKm.toString(),
          "rvhcKabin": globals.rvhcKabin.toString(), //KABIN
          "rvhcKaca": globals.rvhcKaca.toString(),
          "rvhcSpion": globals.rvhcSpion.toString(),
          "rvhcSpeedo": globals.rvhcSpeedo.toString(),
          "rvhcWiper": globals.rvhcWiper.toString(),
          //"rvhcStir": globals.rvhcStir.toString(),
          //"rvhcElect": globals.rvhcElect.toString(),
          "rvhcKlak": globals.rvhcKlak.toString(),
          "rvhcJok": globals.rvhcJok.toString(),
          "rvhcSeatBealt": globals.rvhcSeatBealt.toString(),
          "rvhcApar": globals.rvhcApar.toString(),
          "rvhcP3k": globals.rvhcP3k.toString(),
          "rvhcCone": globals.rvhcCone.toString(),
          "rvhcStikerRef": globals.rvhcStikerRef.toString(),
          //"rvhcRStir": globals.rvhcRStir.toString(),
          "rvhcLampd": globals.rvhcLampd.toString(), //ELECTRIC
          "rvhcLampr": globals.rvhcLampr.toString(),
          "rvhcLamps": globals.rvhcLamps.toString(),
          "rvhcLampb": globals.rvhcLampBlk.toString(),
          "rvhcLampm": globals.rvhcLampm.toString(),
          "rvhcLampAlarm": globals.rvhcLampAlarm.toString(),
          "rvhcKopling": globals.rvhcKopling.toString(), //CHASIS
          "rvhcGardan": globals.rvhcGardan.toString(),
          "rvhcParking": globals.rvhcParking.toString(),
          "rvhcFoot": globals.rvhcFoot.toString(),
          "rvhcBautRoda": globals.rvhcBautRoda.toString(),
          "rvhcVelg": globals.rvhcVelg.toString(),
          "rvhcBan": globals.rvhcBan.toString(), //BAN
          "rvhcAngin": globals.rvhcAngin.toString(),
          "rvhcTerpal": globals.rvhcTerpal.toString(), //PERALATAN
          "rvhcWebing": globals.rvhcWebing.toString(),
          "rvhcTambang": globals.rvhcTambang.toString(),
          "rvhcDongkrak": globals.rvhcDongkrak.toString(),
          "rvhcKRoda": globals.rvhcKRoda.toString(),
          "rvhcGBan": globals.rvhcGBan.toString(),
          "rvhcGps": globals.rvhcGps.toString(),
          "rvhcDashCam": globals.rvhcDashCam.toString(),
          "rvhcSurat": globals.rvhcSurat.toString(), //DOKUMENT
          //"rvhcHandrail": globals.rvhcHandrail.toString(),
          //"rvhcAlarm": globals.rvhcAlarm.toString(),
          "rvhcSurat": globals.rvhcSurat.toString(),
          "rvhcKir": globals.rvhcKir.toString(),
          "rvhcSim": globals.rvhcSim.toString(),
          "userid": userid.toString(),
          "vhcnotes": globals.rvhcNotes,
          "vhcposisiban1": globals.vhcposisiban1.toString(),
          "vhcposisiban2": globals.vhcposisiban2.toString(),
          "vhcposisiban3": globals.vhcposisiban3.toString(),
          "vhcposisiban4": globals.vhcposisiban4.toString(),
          "vhcposisiban5": globals.vhcposisiban5.toString(),
          "vhcposisiban6": globals.vhcposisiban6.toString(),
          "vhcposisiban7": globals.vhcposisiban7.toString(),
          "vhcposisiban8": globals.vhcposisiban8.toString(),
          "vhcposisiban9": globals.vhcposisiban9.toString(),
          "vhcposisiban10": globals.vhcposisiban10.toString(),
          "vhcposisiban11": globals.vhcposisiban11.toString(),
          "vhcposisiban12": globals.vhcposisiban12.toString(),
          "vhcposisiban13": globals.vhcposisiban13.toString(),
          "vhcposisiban14": globals.vhcposisiban14.toString(),
          "vhcposisiban15": globals.vhcposisiban15.toString(),
          "vhcposisiban16": globals.vhcposisiban16.toString(),
          "vhcposisiban17": globals.vhcposisiban17.toString(),
          "vhcposisiban18": globals.vhcposisiban18.toString(),
          "vhcposisiban19": globals.vhcposisiban19.toString(),
          "vhcposisiban20": globals.vhcposisiban20.toString(),
          "vhcposisiban21": globals.vhcposisiban21.toString(),
          "vhcposisiban22": globals.vhcposisiban22.toString(),
          "vhcposisiban23": globals.vhcposisiban23.toString(),
          "vhcposisiban24": globals.vhcposisiban24.toString()
        };
        print(dataParam);
        Uri myUri = Uri.parse(
            Uri.encodeFull("${GlobalData.baseUrl}api/maintenance/create_antrian_new_p2h.jsp"));
        print(myUri.toString());
        final response = await http.post(
          myUri,
          body: dataParam,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        if (response.statusCode == 200) {
          status_code = json.decode(response.body)['status_code'];
          messageData = json.decode(response.body)['message'];
          print(status_code);
          print(json.decode(response.body));
          if (int.parse(status_code) == 200) {
            if(EasyLoading.isShow){
              EasyLoading.dismiss();
            }
            print("200");
            showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text('Information'),
                content: new Text("$messageData"),
                actions: <Widget>[
                  new ElevatedButton.icon(
                    icon: Icon(
                      Icons.perm_device_information,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    label: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      getJSONData(false);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          } else {
            if(EasyLoading.isShow){
              EasyLoading.dismiss();
            }
            print("100");
            alert(globalScaffoldKey.currentContext!, 0, messageData, "error");
          }
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Error ${response.statusCode}", "error");
          if(EasyLoading.isShow){
            EasyLoading.dismiss();
          }
        }
      }
    }catch($e){
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0,
          "Error ${$e}", "error");
    }
    return "Successfull";
  }

  Widget _buildFormSearch(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(children: <Widget>[
        Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
            height: 150.0,
            width: double.infinity,
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
                  padding: EdgeInsets.all(10.0),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        "NO Antrian Terakhir",
                        style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontFamily: "NeoSansBold"),
                      ),
                    ],
                  ),
                ),
                new Container(
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No. ANTRIAN: ${antrian_noantrian}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14)),
                              Text('VHCID: ${antrian_vhcid}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14)),
                              Text('DIBUAT TGL : ${antrian_created_date}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12)),
                            ]),
                      ]),
                ),
                new Container(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: Text("Refresh"),
                            onPressed: () async {
                              try {
                                await getAntrianLast();
                                await getJSONData(true);
                                print("isAntrian ${isAntrian}");
                                if (isAntrian == true) {
                                  alert(
                                      globalScaffoldKey.currentContext!,
                                      2,
                                      "Tidak ada nomor antrian terakhir",
                                      "warning");
                                }
                              } catch (e) {
                                print(e);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ))
      ]),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(left: 0, top: 145, right: 0, bottom: 5),
        //onRefresh: getJSONData,
        child: ListView.builder(
            padding: const EdgeInsets.all(5.0),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              return _buildDListDo(data[index], index);
            }));
  }

  Widget _buildDListDo(dynamic item, int index) {
    //print(value["drvid"]);
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
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
                  "CUSTOMER : ${item['cpyname']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("TYPE : ${item['itemtype']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("QTY : ${item['qty']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("UOM: ${item['itemuom']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("ORIGIN: ${item['origin']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("DESTINATION: ${item['destination']}",
                      style: TextStyle(color: Colors.black)),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Submit"),
                  onPressed: () async {
                    showDialog(
                      context: globalScaffoldKey.currentContext!,
                      builder: (context) => new AlertDialog(
                        title: new Text('Information'),
                        content: new Text("Add Antrian Data Do?"),
                        actions: <Widget>[
                          new TextButton(
                              onPressed: () {
                                Navigator.of(globalScaffoldKey.currentContext!)
                                    .pop(false);
                              },
                              child: new Text('No')),
                          new TextButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String km_newDo = prefs.getString("km_new")!;
                              Navigator.of(globalScaffoldKey.currentContext!)
                                  .pop(false);
                              var nodo = item['nodo'];
                              var dlodate = item['customerdate'];
                              if (km_newDo == null || km_newDo == "") {
                                alert(globalScaffoldKey.currentContext!, 0,
                                    "KM tidak boleh kosong", "error");
                              } else if (nodo == null || nodo == '') {
                                alert(globalScaffoldKey.currentContext!, 0,
                                    "No DO tidak boleh kosong", "error");
                              } else if (dlodate == null || dlodate == '') {
                                alert(globalScaffoldKey.currentContext!, 0,
                                    "DO Date tidak boleh kosong", "error");
                              } else {
                                String method = prefs.getString("method") ?? "";
                                print(method);
                                if (method == "new") {
                                  await createAntrianNewDriver(dlodate, nodo);
                                  getAntrianLast();
                                  await UpdateReceiveLogDo();
                                } else {
                                  await createAntrian(dlodate, nodo);
                                  getAntrianLast();
                                  await UpdateReceiveLogDo();
                                }
                                print(status_code);
                                if (status_code.toString() == "200") {
                                  prefs.setString("vhcid_last_antrian", "");
                                  getAntrianLast();
                                  getJSONData(false);
                                }
                                if (status_code.toString() == "403" && method != "new") {
                                  alert(
                                      globalScaffoldKey.currentContext!,
                                      0,
                                      "Antrian tidak bisa di buat,karna sudah ada",
                                      "error");
                                  prefs.setString("vhcid_last_antrian", "");
                                  getJSONData(false);
                                } else {
                                  getJSONData(false);
                                }
                                if(EasyLoading.isShow){
                                  EasyLoading.dismiss();
                                }
                              }
                            },
                            child: new Text('Ok'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDListDoOld(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(children: <Widget>[
        new Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 0.0),
            height: 180.0,
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
                  padding: EdgeInsets.all(10.0),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        "CUSTOMER : ${item['cpyname']}",
                        style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontFamily: "NeoSansBold"),
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("TYPE : ${item['itemtype']}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14)),
                          Text("QTY : ${item['qty']}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14)),
                          Text("UOM : ${item['itemuom']}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14)),
                          Text("ORIGIN : ${item['origin']}",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 14)),
                          Text("DESTINATION : ${item['destination']}",
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: Text("Submit"),
                            onPressed: () {
                              showDialog(
                                context: globalScaffoldKey.currentContext!,
                                builder: (context) => new AlertDialog(
                                  title: new Text('Information'),
                                  content: new Text("Add Antrian Data Do?"),
                                  actions: <Widget>[
                                    new TextButton(
                                        onPressed: () {
                                          Navigator.of(globalScaffoldKey
                                                  .currentContext!)
                                              .pop(false);
                                        },
                                        child: new Text('No')),
                                    new TextButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String km_newDo =
                                            prefs.getString("km_new") ?? "";
                                        Navigator.of(globalScaffoldKey
                                                .currentContext!)
                                            .pop(false);
                                        var nodo = item['nodo'];
                                        var dlodate = item['customerdate'];
                                        if (km_newDo == null ||
                                            km_newDo == "") {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "KM tidak boleh kosong",
                                              "error");
                                        } else if (nodo == null || nodo == '') {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "No DO tidak boleh kosong",
                                              "error");
                                        } else if (dlodate == null ||
                                            dlodate == '') {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "DO Date tidak boleh kosong",
                                              "error");
                                        } else {
                                          String method =
                                              prefs.getString("method") ?? "";
                                          print('method ${method}');
                                          if (method == "new") {
                                             await createAntrianNewDriver(
                                                 dlodate, nodo);
                                            getAntrianLast();
                                          } else {
                                            await createAntrian(dlodate, nodo);
                                            getAntrianLast();
                                          }
                                          if (int.parse(status_code) == 200) {
                                            prefs.setString(
                                                "vhcid_last_antrian", "");
                                            getAntrianLast();
                                            getJSONData(false);
                                          }
                                          if (status_code == "403" &&
                                              method != "new") {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                "Antrian tidak bisa di buat,karna sudah ada",
                                                "error");
                                            prefs.setString(
                                                "vhcid_last_antrian", "");
                                            //getAntrianLast();
                                            getJSONData(false);
                                          } else {
                                            alert(
                                                globalScaffoldKey
                                                    .currentContext!,
                                                0,
                                                message,
                                                "error");
                                            getJSONData(false);
                                          }
                                          if(EasyLoading.isShow){
                                            EasyLoading.dismiss();
                                          }
                                        }
                                      },
                                      child: new Text('Ok'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ))
      ]),
    );
  }

  _goBack(BuildContext context) {
    ResetDataInspeksi();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void ResetDataInspeksi() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("page_antrian");
    prefs.setString("method","");
    prefs.setString("vhcid_last_antrian","");
    globals.page_inspeksi = null;
    globals.p2hVhcid = null;
    globals.p2hVhckm = 0.0;
    globals.p2hVhcdate = null;
    globals.p2hVhcdefaultdriver = null;

    //PERALATAN
    globals.rvhcOil = null;
    globals.rvhcOliMesin = null;
    globals.rvhcOliGardan = null;
    globals.rvhcOliTransmisi = null;
    globals.rvhcAir = null;
    globals.rvhcAccu = null;
    globals.rvhcOLips = null;
    globals.rvhcMrem = null;

    globals.p2hVhcid = null;
    globals.p2hVhckm = 0.0;
    globals.p2hVhcdate = null;
    globals.p2hVhcdefaultdriver = null;

    //KABIN
    globals.rvhcKabin = null;
    globals.rvhcKaca = null;
    globals.rvhcSpion = null;
    globals.rvhcSpeedo = null;
    globals.rvhcWiper = null;
    globals.rvhcKlak = null;
    globals.rvhcJok = null;
    globals.rvhcSeatBealt = null;
    globals.rvhcApar = null;
    globals.rvhcP3k = null;
    globals.rvhcCone = null;
    globals.rvhcStikerRef = null;

    //ELECTTRIC
    globals.rvhcLampd = null;
    globals.rvhcLamps = null;
    globals.rvhcLampBlk = null;
    globals.rvhcLampr = null;
    globals.rvhcLampm = null;
    globals.rvhcLampAlarm = null;

    //CHASIS
    globals.rvhcKopling = null;
    globals.rvhcGardan = null;
    globals.rvhcParking = null;
    globals.rvhcFoot = null;
    globals.rvhcBautRoda = null;
    globals.rvhcVelg = null;

    //BAN
    globals.rvhcBan = null;
    globals.rvhcAngin = null;

    //PERALATAN
    globals.rvhcTerpal = null;
    globals.rvhcWebing = null;
    globals.rvhcTambang = null;
    globals.rvhcDongkrak = null;
    globals.rvhcKRoda = null;
    globals.rvhcGBan = null;
    globals.rvhcGps = null;
    globals.rvhcDashCam = null;

    //DOCUMENT
    globals.rvhcSurat = null;
    globals.rvhcKir = null;
    globals.rvhcSim = null;
    globals.rvhcNotes = "";

    globals.vhcposisiban1 = 0;
    globals.vhcposisiban2 = 0;
    globals.vhcposisiban3 = 0;
    globals.vhcposisiban4 = 0;
    globals.vhcposisiban5 = 0;
    globals.vhcposisiban6 = 0;
    globals.vhcposisiban7 = 0;
    globals.vhcposisiban8 = 0;
    globals.vhcposisiban9 = 0;
    globals.vhcposisiban10 = 0;
    globals.vhcposisiban11 = 0;
    globals.vhcposisiban12 = 0;
    globals.vhcposisiban13 = 0;
    globals.vhcposisiban14 = 0;
    globals.vhcposisiban15 = 0;
    globals.vhcposisiban16 = 0;
    globals.vhcposisiban17 = 0;
    globals.vhcposisiban18 = 0;
    globals.vhcposisiban19 = 0;
    globals.vhcposisiban20 = 0;
    globals.vhcposisiban21 = 0;
    globals.vhcposisiban22 = 0;
    globals.vhcposisiban23 = 0;
    globals.vhcposisiban24 = 0;
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bujnumber = prefs.getString("bujnumber")!;
    print('buj Number ${bujnumber}');
  }

//http://apps.tuluatas.com:8085/cemindo/mobile/api/list_do_antrian.jsp?method=antrianv1&driverid=3416-02.2018.08.06.83&locid=CWD-ANP&vhcid=B%209015%20YN&limit=10&offset=10
  @override
  void initState() {
    //String bujnumber = prefs.getString("bujnumber");
    getSession();
    isAntrian = false;
    setState(() {
      if (limit > 1) {
        limit = limit + offset;
      }
    });
    //getAntrianLast();
    this.getJSONData(false);
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
