import 'dart:async';
import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/driver/ListDriverInspeksi.dart';
import 'package:dms_anp/src/pages/maintenance/ViewCarLT.dart';
import 'package:dms_anp/src/pages/maintenance/ViewCarTR.dart';
import 'package:dms_anp/src/pages/maintenance/ViewCarTRAILLER.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../../../choices.dart' as choices;

class FrmInspeksiVehicleP2H extends StatefulWidget {
  @override
  _FrmInspeksiVehicleP2HState createState() => _FrmInspeksiVehicleP2HState();
}

//GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
bool isShowCheck = false;
//PENGECEKAN DASAR
enum vhcOil { tidakAda, tersedia, perluPerbaikan }
enum vhcOliMesin { tidakAda, tersedia, perluPerbaikan }
enum vhcOliGardan { tidakAda, tersedia, perluPerbaikan }
enum vhcOliTransmisi { tidakAda, tersedia, perluPerbaikan }
enum vhcAir { tidakAda, tersedia, perluPerbaikan } //Air Radiator
enum vhcAccu { tidakAda, tersedia, perluPerbaikan } //Air AKI
enum vhcMrem { tidakAda, tersedia, perluPerbaikan } //Minyak Rem
enum vhcOLips { tidakAda, tersedia, perluPerbaikan } //Oli Power Steering

//KABIN
enum vhcKabin { tidakAda, tersedia, perluPerbaikan }
enum vhcKaca { tidakAda, tersedia, perluPerbaikan }
enum vhcSpion { tidakAda, tersedia, perluPerbaikan }
enum vhcSpeedo { tidakAda, tersedia, perluPerbaikan }
enum vhcWiper { tidakAda, tersedia, perluPerbaikan } //WIPER
enum vhcKlak { tidakAda, tersedia, perluPerbaikan }
enum vhcJok { tidakAda, tersedia, perluPerbaikan }
enum vhcSeatBealt { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcApar { tidakAda, tersedia, perluPerbaikan }
enum vhcP3k { tidakAda, tersedia, perluPerbaikan }
enum vhcCone { tidakAda, tersedia, perluPerbaikan }
enum vhcStikerRef { tidakAda, tersedia, perluPerbaikan }

//ELECTRIK
enum vhcLampd { tidakAda, tersedia, perluPerbaikan }
enum vhcLamps { tidakAda, tersedia, perluPerbaikan } //LAMPU SEN
enum vhcLampBlk { tidakAda, tersedia, perluPerbaikan } //ADD LAMPU Belakang
enum vhcLampr { tidakAda, tersedia, perluPerbaikan }
enum vhcLampm { tidakAda, tersedia, perluPerbaikan }
enum vhcLampAlarm { tidakAda, tersedia, perluPerbaikan }

//Chasis
enum vhcKopling { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcGardan { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcParking { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcFoot { tidakAda, tersedia, perluPerbaikan }
enum vhcBautRoda { tidakAda, tersedia, perluPerbaikan }
enum vhcVelg { tidakAda, tersedia, perluPerbaikan } //ADD

//BAN
enum vhcBan { tidakAda, tersedia, perluPerbaikan }
enum vhcAngin { tidakAda, tersedia, perluPerbaikan }

//PERLATAN
enum vhcTerpal { tidakAda, tersedia, perluPerbaikan }
enum vhcWebing { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcTambang { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcDongkrak { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcKRoda { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcGBan { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcGps { tidakAda, tersedia, perluPerbaikan }
enum vhcDashCam { tidakAda, tersedia, perluPerbaikan } //ADD

//DOKUMEN
enum vhcSurat { tidakAda, tersedia, perluPerbaikan }
enum vhcKir { tidakAda, tersedia, perluPerbaikan } //ADD
enum vhcSim { tidakAda, tersedia, perluPerbaikan } //ADD

class _FrmInspeksiVehicleP2HState extends State<FrmInspeksiVehicleP2H> {
  GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtNotes = new TextEditingController();
  TextEditingController txtKm = new TextEditingController();
  ProgressDialog? pr;
  List<String> selBan = [];
  String type_truck = "";
  String status_code = "";
  String status_code_img = "";
  String message = "";
  String image_url = "";
  double iconSize = 40;

  //PENGECEKAN DASAR
  vhcOil rvhcOil = vhcOil.tidakAda;
  vhcOliMesin rvhcOliMesin = vhcOliMesin.tidakAda;
  vhcOliGardan rvhcOliGardan = vhcOliGardan.tidakAda;
  vhcOliTransmisi rvhcOliTransmisi = vhcOliTransmisi.tidakAda;
  vhcAir rvhcAir = vhcAir.tidakAda;
  vhcAccu rvhcAccu = vhcAccu.tidakAda;
  vhcMrem rvhcMrem = vhcMrem.tidakAda;
  vhcOLips rvhcOLips = vhcOLips.tidakAda;

  //KABIN
  vhcKabin rvhcKabin = vhcKabin.tidakAda;
  vhcKaca rvhcKaca = vhcKaca.tidakAda;
  vhcSpion rvhcSpion = vhcSpion.tidakAda;
  vhcSpeedo rvhcSpeedo = vhcSpeedo.tidakAda;
  vhcWiper rvhcWiper = vhcWiper.tidakAda;
  vhcKlak rvhcKlak = vhcKlak.tidakAda;
  vhcJok rvhcJok = vhcJok.tidakAda;
  vhcSeatBealt rvhcSeatBealt = vhcSeatBealt.tidakAda;
  vhcApar rvhcApar = vhcApar.tidakAda;
  vhcP3k rvhcP3k = vhcP3k.tidakAda;
  vhcCone rvhcCone = vhcCone.tidakAda;
  vhcStikerRef rvhcStikerRef = vhcStikerRef.tidakAda;
  //END

  //ELECTRIC
  vhcLampd rvhcLampd = vhcLampd.tidakAda;
  vhcLamps rvhcLamps = vhcLamps.tidakAda;
  vhcLampBlk rvhcLampBlk = vhcLampBlk.tidakAda;
  vhcLampr rvhcLampr = vhcLampr.tidakAda;
  vhcLampm rvhcLampm = vhcLampm.tidakAda;
  vhcLampAlarm rvhcLampAlarm = vhcLampAlarm.tidakAda;
  //END

  //Chasis
  vhcKopling rvhcKopling = vhcKopling.tidakAda;
  vhcGardan rvhcGardan = vhcGardan.tidakAda;
  vhcParking rvhcParking = vhcParking.tidakAda;
  vhcFoot rvhcFoot = vhcFoot.tidakAda;
  vhcBautRoda rvhcBautRoda = vhcBautRoda.tidakAda;
  vhcVelg rvhcVelg = vhcVelg.tidakAda;
  //END

  //BAN
  vhcBan rvhcBan = vhcBan.tidakAda;
  vhcAngin rvhcAngin = vhcAngin.tidakAda;
  //end

  //PERALATAN
  vhcTerpal rvhcTerpal = vhcTerpal.tidakAda;
  vhcWebing rvhcWebing = vhcWebing.tidakAda;
  vhcTambang rvhcTambang = vhcTambang.tidakAda;
  vhcDongkrak rvhcDongkrak = vhcDongkrak.tidakAda;
  vhcKRoda rvhcKRoda = vhcKRoda.tidakAda;
  vhcGBan rvhcGBan = vhcGBan.tidakAda;
  vhcGps rvhcGps = vhcGps.tidakAda;
  vhcDashCam rvhcDashCam = vhcDashCam.tidakAda;

  //DOKUMEN
  vhcSurat rvhcSurat = vhcSurat.tidakAda;
  vhcKir rvhcKir = vhcKir.tidakAda;
  vhcSim rvhcSim = vhcSim.tidakAda;

  String vhcNotes = "";

  bool isPengecekanDasar1 = false;
  bool isPengecekanDasar2 = false;
  bool isPengecekanDasar3 = false;

  bool isKabin1 = false;
  bool isKabin2 = false;
  bool isKabin3 = false;

  bool isElektrik1 = false;
  bool isElektrik2 = false;
  bool isElektrik3 = false;

  bool isChasis1 = false;
  bool isChasis2 = false;
  bool isChasis3 = false;

  bool isBan1 = false;
  bool isBan2 = false;
  bool isBan3 = false;

  bool isPeralatan1 = false;
  bool isPeralatan2 = false;
  bool isPeralatan3 = false;

  bool isDokumen1 = false;
  bool isDokumen2 = false;
  bool isDokumen3 = false;

  //bool bTasPP = false;
  _goBack(BuildContext context) {
    ResetCheckBox();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ListDriverInspeksi()));
  }

  void getTypeTruck() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    String vhcidType = globals.p2hVhcid!;
    var urlData = "${GlobalData.baseUrl}api/vehicle/type_vehicle.jsp";
    var dataParam = {"method": "get-vehicle-type-v1", "vhcid": vhcidType};
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(myUri);
    final response = await http.post(
      myUri,
      body: dataParam,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
    );

    setState(() {
      status_code_img = json.decode(response.body)["status_code"].toString();
      globals.image_typr_truck_url = json.decode(response.body)["image_url"];
      type_truck = json.decode(response.body)["type"];
      if (status_code_img == "200") {
        print('Ok');
      } else {
        globals.image_typr_truck_url = "";
        type_truck = "";
      }
    });
  }

  Future<String?> createFormInspeksi(String userid) async {
    if ((pr?.isShowing() ?? false) == false) {
      await pr?.show();
    }
    try {
      var urlData =
          "${GlobalData.baseUrlOri}api/vehicle/create_form_inspeksi_vehicle3.jsp";
      var dataParam = {
        "method": "create-form-inspeksi-v1",
        "vhcid": globals.p2hVhcid.toString(),
        "vhckm": txtKm.text,
        "locid": globals.p2hVhclocid.toString(),
        "vhcdate": globals.p2hVhcdate.toString(),
        "drvid": globals.p2hVhcdefaultdriver.toString(),
        "rvhcOil": globals.rvhcOil.toString(), //START PENGECEKAN
        "rvhcOliMesin": globals.rvhcOliMesin.toString(), //START PENGECEKAN
        "rvhcOliGardan": globals.rvhcOliGardan.toString(), //START PENGECEKAN
        "rvhcOliTransmisi":globals.rvhcOliTransmisi.toString(), //START PENGECEKAN
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
        //"rvhcSurat": globals.rvhcSurat.toString(),
        "rvhcKir": globals.rvhcKir.toString(),
        "rvhcSim": globals.rvhcSim.toString(),
        "userid": userid.toString(),
        "vhcnotes": txtNotes.text,
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
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
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
        if (status_code == "200") {
          if (pr?.isShowing() ?? false) {
            pr?.hide();
          }
          ResetCheckBox();
          alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
          Timer(Duration(seconds: 1), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ListDriverInspeksi()));
          });
        } else {
          if (pr?.isShowing() ?? false) {
            pr?.hide();
          }
          Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (pr?.isShowing() ?? false) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  void ResetCheckBox() {
    setState(() {
      txtKm.text = '0';
      txtNotes.text = '';
      //PENGECEKAN DASAR
      rvhcOil = vhcOil.tidakAda;
      rvhcOliMesin = vhcOliMesin.tidakAda;
      rvhcOliGardan = vhcOliGardan.tidakAda;
      rvhcOliTransmisi = vhcOliTransmisi.tidakAda;
      rvhcAir = vhcAir.tidakAda;
      rvhcAccu = vhcAccu.tidakAda;
      rvhcOLips = vhcOLips.tidakAda;
      rvhcMrem = vhcMrem.tidakAda;

      //KABIN
      rvhcKabin = vhcKabin.tidakAda;
      rvhcKaca = vhcKaca.tidakAda;
      rvhcSpion = vhcSpion.tidakAda;
      rvhcSpeedo = vhcSpeedo.tidakAda;
      rvhcWiper = vhcWiper.tidakAda;
      rvhcKlak = vhcKlak.tidakAda;
      rvhcJok = vhcJok.tidakAda;
      rvhcSeatBealt = vhcSeatBealt.tidakAda;
      rvhcApar = vhcApar.tidakAda;
      rvhcP3k = vhcP3k.tidakAda;
      rvhcCone = vhcCone.tidakAda;
      rvhcStikerRef = vhcStikerRef.tidakAda;

      //ELECTRIC
      rvhcLampd = vhcLampd.tidakAda;
      rvhcLamps = vhcLamps.tidakAda;
      rvhcLampBlk = vhcLampBlk.tidakAda;
      rvhcLampr = vhcLampr.tidakAda;
      rvhcLampm = vhcLampm.tidakAda;
      rvhcLampAlarm = vhcLampAlarm.tidakAda;

      //Chasis
      rvhcKopling = vhcKopling.tidakAda;
      rvhcGardan = vhcGardan.tidakAda;
      rvhcParking = vhcParking.tidakAda;
      rvhcFoot = vhcFoot.tidakAda;
      rvhcBautRoda = vhcBautRoda.tidakAda;
      rvhcVelg = vhcVelg.tidakAda;

      //BAN
      rvhcBan = vhcBan.tidakAda;
      rvhcAngin = vhcAngin.tidakAda;

      //PERALATAN
      rvhcTerpal = vhcTerpal.tidakAda;
      rvhcWebing = vhcWebing.tidakAda;
      rvhcTambang = vhcTambang.tidakAda;
      rvhcDongkrak = vhcDongkrak.tidakAda;
      rvhcKRoda = vhcKRoda.tidakAda;
      rvhcGBan = vhcGBan.tidakAda;
      rvhcGps = vhcGps.tidakAda;
      rvhcDashCam = vhcDashCam.tidakAda;

      //DOKUMEN
      rvhcSurat = vhcSurat.tidakAda;
      rvhcKir = vhcKir.tidakAda;
      rvhcSim = vhcSim.tidakAda;

      isPengecekanDasar1 = false;
      isPengecekanDasar2 = false;
      isPengecekanDasar3 = false;

      isKabin1 = false;
      isKabin2 = false;
      isKabin3 = false;

      isElektrik1 = false;
      isElektrik2 = false;
      isElektrik3 = false;

      isChasis1 = false;
      isChasis2 = false;
      isChasis3 = false;

      isBan1 = false;
      isBan2 = false;
      isBan3 = false;

      isPeralatan1 = false;
      isPeralatan2 = false;
      isPeralatan3 = false;

      isDokumen1 = false;
      isDokumen2 = false;
      isDokumen3 = false;

      //PERALATAN
      globals.rvhcOil = "";
      globals.rvhcOliMesin = "";
      globals.rvhcOliGardan = "";
      globals.rvhcOliTransmisi = "";
      globals.rvhcAir = "";
      globals.rvhcAccu = "";
      globals.rvhcOLips = "";
      globals.rvhcMrem = "";

      globals.p2hVhcid = "";
      globals.p2hVhckm = 0.0;
      globals.p2hVhcdate = "";
      globals.p2hVhcdefaultdriver = "";

      //KABIN
      globals.rvhcKabin = "";
      globals.rvhcKaca = "";
      globals.rvhcSpion = "";
      globals.rvhcSpeedo = "";
      globals.rvhcWiper = "";
      globals.rvhcKlak = "";
      globals.rvhcJok = "";
      globals.rvhcSeatBealt = "";
      globals.rvhcApar = "";
      globals.rvhcP3k = "";
      globals.rvhcCone = "";
      globals.rvhcStikerRef = "";

      //ELECTTRIC
      globals.rvhcLampd = "";
      globals.rvhcLamps = "";
      globals.rvhcLampBlk = "";
      globals.rvhcLampr = "";
      globals.rvhcLampm = "";
      globals.rvhcLampAlarm = "";

      //CHASIS
      globals.rvhcKopling = "";
      globals.rvhcGardan = "";
      globals.rvhcParking = "";
      globals.rvhcFoot = "";
      globals.rvhcBautRoda = "";
      globals.rvhcVelg = "";

      //BAN
      globals.rvhcBan = "";
      globals.rvhcAngin = "";

      //PERALATAN
      globals.rvhcTerpal = "";
      globals.rvhcWebing = "";
      globals.rvhcTambang = "";
      globals.rvhcDongkrak = "";
      globals.rvhcKRoda = "";
      globals.rvhcGBan = "";
      globals.rvhcGps = "";
      globals.rvhcDashCam = "";

      //DOCUMENT
      globals.rvhcSurat = "";
      globals.rvhcKir = "";
      globals.rvhcSim = "";

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
    });
  }

  void isFinish() {
    setState(() {
      globals.rvhcOil = rvhcOil != null ? rvhcOil.index.toString() : null;
      globals.rvhcOliMesin =
          rvhcOliMesin != null ? rvhcOliMesin.index.toString() : null;
      globals.rvhcOliGardan =
          rvhcOliGardan != null ? rvhcOliGardan.index.toString() : null;
      globals.rvhcOliTransmisi =
          rvhcOliTransmisi != null ? rvhcOliTransmisi.index.toString() : null;
      globals.rvhcAir = rvhcAir != null ? rvhcAir.index.toString() : null;
      globals.rvhcAccu = rvhcAccu != null ? rvhcAccu.index.toString() : null;
      globals.rvhcOLips = rvhcOLips != null ? rvhcOLips.index.toString() : null;
      globals.rvhcMrem = rvhcMrem != null ? rvhcMrem.index.toString() : null;

      // globals.p2hVhcid = p2hVhcid != null ? p2hVhcid.index.toString() : null;
      // globals.p2hVhckm = 0.0;
      // globals.p2hVhcdate = rvhcKabin != null ? rvhcKabin.index.toString() : null;
      // globals.p2hVhcdefaultdriver = p2hVhcdefaultdriver != null ? p2hVhcdefaultdriver.index.toString() : null;

      //KABIN
      globals.rvhcKabin = rvhcKabin != null ? rvhcKabin.index.toString() : null;
      globals.rvhcKaca = rvhcKaca != null ? rvhcKaca.index.toString() : null;
      globals.rvhcSpion = rvhcSpion != null ? rvhcSpion.index.toString() : null;
      globals.rvhcSpeedo =
          rvhcSpeedo != null ? rvhcSpeedo.index.toString() : null;
      globals.rvhcWiper = rvhcWiper != null ? rvhcWiper.index.toString() : null;
      globals.rvhcKlak = rvhcKlak != null ? rvhcKlak.index.toString() : null;
      globals.rvhcJok = rvhcJok != null ? rvhcJok.index.toString() : null;
      globals.rvhcSeatBealt =
          rvhcSeatBealt != null ? rvhcSeatBealt.index.toString() : null;
      globals.rvhcApar = rvhcApar != null ? rvhcApar.index.toString() : null;
      globals.rvhcP3k = rvhcP3k != null ? rvhcP3k.index.toString() : null;
      globals.rvhcCone = rvhcCone != null ? rvhcCone.index.toString() : null;
      globals.rvhcStikerRef =
          rvhcStikerRef != null ? rvhcStikerRef.index.toString() : null;

      //ELECTTRIC
      globals.rvhcLampd = rvhcLampd != null ? rvhcLampd.index.toString() : null;
      globals.rvhcLamps = rvhcLamps != null ? rvhcLamps.index.toString() : null;
      globals.rvhcLampBlk =
          rvhcLampBlk != null ? rvhcLampBlk.index.toString() : null;
      globals.rvhcLampr = rvhcLampr != null ? rvhcLampr.index.toString() : null;
      globals.rvhcLampm = rvhcLampm != null ? rvhcLampm.index.toString() : null;
      globals.rvhcLampAlarm =
          rvhcLampAlarm != null ? rvhcLampAlarm.index.toString() : null;

      //CHASIS
      globals.rvhcKopling =
          rvhcKopling != null ? rvhcKopling.index.toString() : null;
      globals.rvhcGardan =
          rvhcGardan != null ? rvhcGardan.index.toString() : null;
      globals.rvhcParking =
          rvhcParking != null ? rvhcParking.index.toString() : null;
      globals.rvhcFoot = rvhcFoot != null ? rvhcFoot.index.toString() : null;
      globals.rvhcBautRoda =
          rvhcBautRoda != null ? rvhcBautRoda.index.toString() : null;
      globals.rvhcVelg = rvhcVelg != null ? rvhcVelg.index.toString() : null;

      //BAN
      globals.rvhcBan = rvhcBan != null ? rvhcBan.index.toString() : null;
      globals.rvhcAngin = rvhcAngin != null ? rvhcAngin.index.toString() : null;

      //PERALATAN
      globals.rvhcTerpal =
          rvhcTerpal != null ? rvhcTerpal.index.toString() : null;
      globals.rvhcWebing =
          rvhcWebing != null ? rvhcWebing.index.toString() : null;
      globals.rvhcTambang =
          rvhcTambang != null ? rvhcTambang.index.toString() : null;
      globals.rvhcDongkrak =
          rvhcDongkrak != null ? rvhcDongkrak.index.toString() : null;
      globals.rvhcKRoda = rvhcKRoda != null ? rvhcKRoda.index.toString() : null;
      globals.rvhcGBan = rvhcGBan != null ? rvhcGBan.index.toString() : null;
      globals.rvhcGps = rvhcGps != null ? rvhcGps.index.toString() : null;
      globals.rvhcDashCam =
          rvhcDashCam != null ? rvhcDashCam.index.toString() : null;

      //DOCUMENT
      globals.rvhcSurat = rvhcSurat != null ? rvhcSurat.index.toString() : null;
      globals.rvhcKir = rvhcKir != null ? rvhcKir.index.toString() : null;
      globals.rvhcSim = rvhcSim != null ? rvhcSim.index.toString() : null;
      globals.rvhcNotes = txtNotes.text;
    });
  }

  void isLoadcheked() {
    setState(() {
      // globals.rvhcKm = rvhcKm != null ? rvhcKm.index.toString() : null;
      txtNotes.text = globals.rvhcNotes.toString() == "null"
          ? ""
          : globals.rvhcNotes.toString();
      txtKm.text = "0";
      //PENGECEKAN
      if (globals.rvhcOil != null) {
        rvhcOil = (int.parse(globals.rvhcOil!) == 0
            ? vhcOil.tidakAda
            : int.parse(globals.rvhcOil!) == 1
                ? vhcOil.tersedia
                : int.parse(globals.rvhcOil!) == 2
                    ? vhcOil.perluPerbaikan
                    : null)!;
      }

      if (globals.rvhcOliMesin != null) {
        rvhcOliMesin = (int.parse(globals.rvhcOliMesin!) == 0
            ? vhcOliMesin.tidakAda
            : int.parse(globals.rvhcOliMesin!) == 1
                ? vhcOliMesin.tersedia
                : int.parse(globals.rvhcOliMesin!) == 2
                    ? vhcOliMesin.perluPerbaikan
                    : null)!;
      }

      if (globals.rvhcOliGardan != null) {
        rvhcOliGardan = (int.parse(globals.rvhcOliGardan!) == 0
            ? vhcOliGardan.tidakAda
            : int.parse(globals.rvhcOliGardan!) == 1
                ? vhcOliGardan.tersedia
                : int.parse(globals.rvhcOliGardan!) == 2
                    ? vhcOliGardan.perluPerbaikan
                    : null)!;
      }

      if (globals.rvhcOliTransmisi != null) {
        rvhcOliTransmisi = (int.parse(globals.rvhcOliTransmisi!) == 0
            ? vhcOliTransmisi.tidakAda
            : int.parse(globals.rvhcOliTransmisi!) == 1
                ? vhcOliTransmisi.tersedia
                : int.parse(globals.rvhcOliTransmisi!) == 2
                    ? vhcOliTransmisi.perluPerbaikan
                    : null)!;
      }

      if (globals.rvhcAir != null) {
        rvhcAir = (int.parse(globals.rvhcAir!) == 0
            ? vhcAir.tidakAda
            : int.parse(globals.rvhcAir!) == 1
                ? vhcAir.tersedia
                : int.parse(globals.rvhcAir!) == 2
                    ? vhcAir.perluPerbaikan
                    : null)!;
      }

      if (globals.rvhcAccu != null) {
        rvhcAccu = (int.parse(globals.rvhcAccu!) == 0
            ? vhcAccu.tidakAda
            : int.parse(globals.rvhcAccu!) == 1
                ? vhcAccu.tersedia
                : int.parse(globals.rvhcAccu!) == 2
                    ? vhcAccu.perluPerbaikan
                    : null)!;
      }

      if (globals.rvhcMrem != null) {
        rvhcMrem = (int.parse(globals.rvhcMrem!) == 0
            ? vhcMrem.tidakAda
            : int.parse(globals.rvhcMrem!) == 1
                ? vhcMrem.tersedia
                : int.parse(globals.rvhcMrem!) == 2
                    ? vhcMrem.perluPerbaikan
                    : null)!;
      }
      //KABIN
      if (globals.rvhcKabin != null) {
        rvhcKabin = (int.parse(globals.rvhcKabin!) == 0
            ? vhcKabin.tidakAda
            : int.parse(globals.rvhcKabin!) == 1
                ? vhcKabin.tersedia
                : int.parse(globals.rvhcKabin!) == 2
                    ? vhcKabin.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcKaca != null) {
        rvhcKaca = (int.parse(globals.rvhcKaca!) == 0
            ? vhcKaca.tidakAda
            : int.parse(globals.rvhcKaca!) == 1
                ? vhcKaca.tersedia
                : int.parse(globals.rvhcKaca!) == 2
                    ? vhcKaca.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcSpion != null) {
        rvhcSpion = (int.parse(globals.rvhcSpion!) == 0
            ? vhcSpion.tidakAda
            : int.parse(globals.rvhcSpion!) == 1
                ? vhcSpion.tersedia
                : int.parse(globals.rvhcSpion!) == 2
                    ? vhcSpion.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcSpeedo != null) {
        rvhcSpeedo = (int.parse(globals.rvhcSpeedo!) == 0
            ? vhcSpeedo.tidakAda
            : int.parse(globals.rvhcSpeedo!) == 1
                ? vhcSpeedo.tersedia
                : int.parse(globals.rvhcSpeedo!) == 2
                    ? vhcSpeedo.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcWiper != null) {
        rvhcWiper = (int.parse(globals.rvhcWiper!) == 0
            ? vhcWiper.tidakAda
            : int.parse(globals.rvhcWiper!) == 1
                ? vhcWiper.tersedia
                : int.parse(globals.rvhcWiper!) == 2
                    ? vhcWiper.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcKlak != null) {
        rvhcKlak = (int.parse(globals.rvhcKlak!) == 0
            ? vhcKlak.tidakAda
            : int.parse(globals.rvhcKlak!) == 1
                ? vhcKlak.tersedia
                : int.parse(globals.rvhcKlak!) == 2
                    ? vhcKlak.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcJok != null) {
        rvhcJok = (int.parse(globals.rvhcJok!) == 0
            ? vhcJok.tidakAda
            : int.parse(globals.rvhcJok!) == 1
                ? vhcJok.tersedia
                : int.parse(globals.rvhcJok!) == 2
                    ? vhcJok.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcSeatBealt != null) {
        rvhcSeatBealt = (int.parse(globals.rvhcSeatBealt!) == 0
            ? vhcSeatBealt.tidakAda
            : int.parse(globals.rvhcSeatBealt!) == 1
                ? vhcSeatBealt.tersedia
                : int.parse(globals.rvhcSeatBealt!) == 2
                    ? vhcSeatBealt.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcApar != null) {
        rvhcApar = (int.parse(globals.rvhcApar!) == 0
            ? vhcApar.tidakAda
            : int.parse(globals.rvhcApar!) == 1
                ? vhcApar.tersedia
                : int.parse(globals.rvhcApar!) == 2
                    ? vhcApar.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcP3k != null) {
        rvhcP3k = (int.parse(globals.rvhcP3k!) == 0
            ? vhcP3k.tidakAda
            : int.parse(globals.rvhcP3k!) == 1
                ? vhcP3k.tersedia
                : int.parse(globals.rvhcP3k!) == 2
                    ? vhcP3k.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcCone != null) {
        rvhcCone = (int.parse(globals.rvhcCone!) == 0
            ? vhcCone.tidakAda
            : int.parse(globals.rvhcCone!) == 1
                ? vhcCone.tersedia
                : int.parse(globals.rvhcCone!) == 2
                    ? vhcCone.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcStikerRef != null) {
        rvhcStikerRef = (int.parse(globals.rvhcStikerRef!) == 0
            ? vhcStikerRef.tidakAda
            : int.parse(globals.rvhcStikerRef!) == 1
                ? vhcStikerRef.tersedia
                : int.parse(globals.rvhcStikerRef!) == 2
                    ? vhcStikerRef.perluPerbaikan
                    : null)!;
      }
      //ELECTRIC
      if (globals.rvhcLampd != null) {
        rvhcLampd = (int.parse(globals.rvhcLampd!) == 0
            ? vhcLampd.tidakAda
            : int.parse(globals.rvhcLampd!) == 1
                ? vhcLampd.tersedia
                : int.parse(globals.rvhcLampd!) == 2
                    ? vhcLampd.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcLamps != null) {
        rvhcLamps = (int.parse(globals.rvhcLamps!) == 0
            ? vhcLamps.tidakAda
            : int.parse(globals.rvhcLamps!) == 1
                ? vhcLamps.tersedia
                : int.parse(globals.rvhcLamps!) == 2
                    ? vhcLamps.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcLampBlk != null) {
        rvhcLampBlk = (int.parse(globals.rvhcLampBlk!) == 0
            ? vhcLampBlk.tidakAda
            : int.parse(globals.rvhcLampBlk!) == 1
                ? vhcLampBlk.tersedia
                : int.parse(globals.rvhcLampBlk!) == 2
                    ? vhcLampBlk.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcLampr != null) {
        rvhcLampr = (int.parse(globals.rvhcLampr!) == 0
            ? vhcLampr.tidakAda
            : int.parse(globals.rvhcLampr!) == 1
                ? vhcLampr.tersedia
                : int.parse(globals.rvhcLampr!) == 2
                    ? vhcLampr.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcLampm != null) {
        rvhcLampm = (int.parse(globals.rvhcLampm!) == 0
            ? vhcLampm.tidakAda
            : int.parse(globals.rvhcLampm!) == 1
                ? vhcLampm.tersedia
                : int.parse(globals.rvhcLampm!) == 2
                    ? vhcLampm.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcLampAlarm != null) {
        rvhcLampAlarm = (int.parse(globals.rvhcLampAlarm!) == 0
            ? vhcLampAlarm.tidakAda
            : int.parse(globals.rvhcLampAlarm!) == 1
                ? vhcLampAlarm.tersedia
                : int.parse(globals.rvhcLampAlarm!) == 2
                    ? vhcLampAlarm.perluPerbaikan
                    : null)!;
      }
      //CHASIS
      if (globals.rvhcKopling != null) {
        rvhcKopling = (int.parse(globals.rvhcKopling!) == 0
            ? vhcKopling.tidakAda
            : int.parse(globals.rvhcKopling!) == 1
                ? vhcKopling.tersedia
                : int.parse(globals.rvhcKopling!) == 2
                    ? vhcKopling.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcGardan != null) {
        rvhcGardan = (int.parse(globals.rvhcGardan!) == 0
            ? vhcGardan.tidakAda
            : int.parse(globals.rvhcGardan!) == 1
                ? vhcGardan.tersedia
                : int.parse(globals.rvhcGardan!) == 2
                    ? vhcGardan.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcParking != null) {
        rvhcParking = (int.parse(globals.rvhcParking!) == 0
            ? vhcParking.tidakAda
            : int.parse(globals.rvhcParking!) == 1
                ? vhcParking.tersedia
                : int.parse(globals.rvhcParking!) == 2
                    ? vhcParking.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcFoot != null) {
        rvhcFoot = (int.parse(globals.rvhcFoot!) == 0
            ? vhcFoot.tidakAda
            : int.parse(globals.rvhcFoot!) == 1
                ? vhcFoot.tersedia
                : int.parse(globals.rvhcFoot!) == 2
                    ? vhcFoot.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcBautRoda != null) {
        rvhcBautRoda = (int.parse(globals.rvhcBautRoda!) == 0
            ? vhcBautRoda.tidakAda
            : int.parse(globals.rvhcBautRoda!) == 1
                ? vhcBautRoda.tersedia
                : int.parse(globals.rvhcBautRoda!) == 2
                    ? vhcBautRoda.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcVelg != null) {
        rvhcVelg = (int.parse(globals.rvhcVelg!) == 0
            ? vhcVelg.tidakAda
            : int.parse(globals.rvhcVelg!) == 1
                ? vhcVelg.tersedia
                : int.parse(globals.rvhcVelg!) == 2
                    ? vhcVelg.perluPerbaikan
                    : null)!;
      }
      //BAN
      if (globals.rvhcBan != null) {
        rvhcBan = (int.parse(globals.rvhcBan!) == 0
            ? vhcBan.tidakAda
            : int.parse(globals.rvhcBan!) == 1
                ? vhcBan.tersedia
                : int.parse(globals.rvhcBan!) == 2
                    ? vhcBan.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcAngin != null) {
        rvhcAngin = (int.parse(globals.rvhcAngin!) == 0
            ? vhcAngin.tidakAda
            : int.parse(globals.rvhcAngin!) == 1
                ? vhcAngin.tersedia
                : int.parse(globals.rvhcAngin!) == 2
                    ? vhcAngin.perluPerbaikan
                    : null)!;
      }
      //PERALATAN
      if (globals.rvhcTerpal != null) {
        rvhcTerpal = (int.parse(globals.rvhcTerpal!) == 0
            ? vhcTerpal.tidakAda
            : int.parse(globals.rvhcTerpal!) == 1
                ? vhcTerpal.tersedia
                : int.parse(globals.rvhcTerpal!) == 2
                    ? vhcTerpal.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcWebing != null) {
        rvhcWebing = (int.parse(globals.rvhcWebing!) == 0
            ? vhcWebing.tidakAda
            : int.parse(globals.rvhcWebing!) == 1
                ? vhcWebing.tersedia
                : int.parse(globals.rvhcWebing!) == 2
                    ? vhcWebing.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcTambang != null) {
        rvhcTambang = (int.parse(globals.rvhcTambang!) == 0
            ? vhcTambang.tidakAda
            : int.parse(globals.rvhcTambang!) == 1
                ? vhcTambang.tersedia
                : int.parse(globals.rvhcTambang!) == 2
                    ? vhcTambang.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcDongkrak != null) {
        rvhcDongkrak = (int.parse(globals.rvhcDongkrak!) == 0
            ? vhcDongkrak.tidakAda
            : int.parse(globals.rvhcDongkrak!) == 1
                ? vhcDongkrak.tersedia
                : int.parse(globals.rvhcDongkrak!) == 2
                    ? vhcDongkrak.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcKRoda != null) {
        rvhcKRoda = (int.parse(globals.rvhcKRoda!) == 0
            ? vhcKRoda.tidakAda
            : int.parse(globals.rvhcKRoda!) == 1
                ? vhcKRoda.tersedia
                : int.parse(globals.rvhcKRoda!) == 2
                    ? vhcKRoda.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcGBan != null) {
        rvhcGBan = (int.parse(globals.rvhcGBan!) == 0
            ? vhcGBan.tidakAda
            : int.parse(globals.rvhcGBan!) == 1
                ? vhcGBan.tersedia
                : int.parse(globals.rvhcGBan!) == 2
                    ? vhcGBan.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcGps != null) {
        rvhcGps = (int.parse(globals.rvhcGps!) == 0
            ? vhcGps.tidakAda
            : int.parse(globals.rvhcGps!) == 1
                ? vhcGps.tersedia
                : int.parse(globals.rvhcGps!) == 2
                    ? vhcGps.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcDashCam != null) {
        rvhcDashCam = (int.parse(globals.rvhcDashCam!) == 0
            ? vhcDashCam.tidakAda
            : int.parse(globals.rvhcDashCam!) == 1
                ? vhcDashCam.tersedia
                : int.parse(globals.rvhcDashCam!) == 2
                    ? vhcDashCam.perluPerbaikan
                    : null)!;
      }
      //DOKUMEN
      if (globals.rvhcSurat != null) {
        rvhcSurat = (int.parse(globals.rvhcSurat!) == 0
            ? vhcSurat.tidakAda
            : int.parse(globals.rvhcSurat!) == 1
                ? vhcSurat.tersedia
                : int.parse(globals.rvhcSurat!) == 2
                    ? vhcSurat.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcKir != null) {
        rvhcKir = (int.parse(globals.rvhcKir!) == 0
            ? vhcKir.tidakAda
            : int.parse(globals.rvhcKir!) == 1
                ? vhcKir.tersedia
                : int.parse(globals.rvhcKir!) == 2
                    ? vhcKir.perluPerbaikan
                    : null)!;
      }
      if (globals.rvhcSim != null) {
        rvhcSim = (int.parse(globals.rvhcSim!) == 0
            ? vhcSim.tidakAda
            : int.parse(globals.rvhcSim!) == 1
                ? vhcSim.tersedia
                : int.parse(globals.rvhcSim!) == 2
                    ? vhcSim.perluPerbaikan
                    : null)!;
      }
    });
  }

  void selectUnselect(String event, int index) {
    setState(() {
      if (event == "pengecekan-dasar") {
        rvhcOil = index == 0
            ? vhcOil.tidakAda
            : index == 1
                ? vhcOil.tersedia
                : index == 2
                    ? vhcOil.perluPerbaikan
                    : vhcOil.tidakAda;
        rvhcOliMesin = index == 0
            ? vhcOliMesin.tidakAda
            : index == 1
                ? vhcOliMesin.tersedia
                : index == 2
                    ? vhcOliMesin.perluPerbaikan
                    : vhcOliMesin.tidakAda;
        rvhcOliGardan = index == 0
            ? vhcOliGardan.tidakAda
            : index == 1
                ? vhcOliGardan.tersedia
                : index == 2
                    ? vhcOliGardan.perluPerbaikan
                    : vhcOliGardan.tidakAda;
        rvhcOliTransmisi = index == 0
            ? vhcOliTransmisi.tidakAda
            : index == 1
                ? vhcOliTransmisi.tersedia
                : index == 2
                    ? vhcOliTransmisi.perluPerbaikan
                    : vhcOliTransmisi.tidakAda;
        rvhcAir = index == 0
            ? vhcAir.tidakAda
            : index == 1
                ? vhcAir.tersedia
                : index == 2
                    ? vhcAir.perluPerbaikan
                    : vhcAir.tidakAda;
        rvhcAccu = index == 0
            ? vhcAccu.tidakAda
            : index == 1
                ? vhcAccu.tersedia
                : index == 2
                    ? vhcAccu.perluPerbaikan
                    : vhcAccu.tidakAda;
        rvhcOLips = index == 0
            ? vhcOLips.tidakAda
            : index == 1
                ? vhcOLips.tersedia
                : index == 2
                    ? vhcOLips.perluPerbaikan
                    : vhcOLips.tidakAda;
        rvhcMrem = index == 0
            ? vhcMrem.tidakAda
            : index == 1
                ? vhcMrem.tersedia
                : index == 2
                    ? vhcMrem.perluPerbaikan
                    : vhcMrem.tidakAda;
      }
      if (event == "kabin") {
        rvhcKabin = index == 0
            ? vhcKabin.tidakAda
            : index == 1
                ? vhcKabin.tersedia
                : index == 2
                    ? vhcKabin.perluPerbaikan
                    : vhcKabin.tidakAda;
        rvhcKaca = index == 0
            ? vhcKaca.tidakAda
            : index == 1
                ? vhcKaca.tersedia
                : index == 2
                    ? vhcKaca.perluPerbaikan
                    : vhcKaca.tidakAda;
        rvhcSpion = index == 0
            ? vhcSpion.tidakAda
            : index == 1
                ? vhcSpion.tersedia
                : index == 2
                    ? vhcSpion.perluPerbaikan
                    : vhcSpion.tidakAda;
        rvhcSpeedo = index == 0
            ? vhcSpeedo.tidakAda
            : index == 1
                ? vhcSpeedo.tersedia
                : index == 2
                    ? vhcSpeedo.perluPerbaikan
                    : vhcSpeedo.tidakAda;
        rvhcWiper = index == 0
            ? vhcWiper.tidakAda
            : index == 1
                ? vhcWiper.tersedia
                : index == 2
                    ? vhcWiper.perluPerbaikan
                    : vhcWiper.tidakAda;
        rvhcKlak = index == 0
            ? vhcKlak.tidakAda
            : index == 1
                ? vhcKlak.tersedia
                : index == 2
                    ? vhcKlak.perluPerbaikan
                    : vhcKlak.tidakAda;
        rvhcJok = index == 0
            ? vhcJok.tidakAda
            : index == 1
                ? vhcJok.tersedia
                : index == 2
                    ? vhcJok.perluPerbaikan
                    : vhcJok.tidakAda;
        rvhcSeatBealt = index == 0
            ? vhcSeatBealt.tidakAda
            : index == 1
                ? vhcSeatBealt.tersedia
                : index == 2
                    ? vhcSeatBealt.perluPerbaikan
                    : vhcSeatBealt.tidakAda;
        rvhcApar = index == 0
            ? vhcApar.tidakAda
            : index == 1
                ? vhcApar.tersedia
                : index == 2
                    ? vhcApar.perluPerbaikan
                    : vhcApar.tidakAda;
        rvhcP3k = index == 0
            ? vhcP3k.tidakAda
            : index == 1
                ? vhcP3k.tersedia
                : index == 2
                    ? vhcP3k.perluPerbaikan
                    : vhcP3k.tidakAda;
        rvhcCone = index == 0
            ? vhcCone.tidakAda
            : index == 1
                ? vhcCone.tersedia
                : index == 2
                    ? vhcCone.perluPerbaikan
                    : vhcCone.tidakAda;
        rvhcStikerRef = index == 0
            ? vhcStikerRef.tidakAda
            : index == 1
                ? vhcStikerRef.tersedia
                : index == 2
                    ? vhcStikerRef.perluPerbaikan
                    : vhcStikerRef.tidakAda;
      }
      if (event == "electric") {
        rvhcLampd = index == 0
            ? vhcLampd.tidakAda
            : index == 1
                ? vhcLampd.tersedia
                : index == 2
                    ? vhcLampd.perluPerbaikan
                    : vhcLampd.tidakAda;
        rvhcLamps = index == 0
            ? vhcLamps.tidakAda
            : index == 1
                ? vhcLamps.tersedia
                : index == 2
                    ? vhcLamps.perluPerbaikan
                    : vhcLamps.tidakAda;
        rvhcLampBlk = index == 0
            ? vhcLampBlk.tidakAda
            : index == 1
                ? vhcLampBlk.tersedia
                : index == 2
                    ? vhcLampBlk.perluPerbaikan
                    : vhcLampBlk.tidakAda;
        rvhcLampr = index == 0
            ? vhcLampr.tidakAda
            : index == 1
                ? vhcLampr.tersedia
                : index == 2
                    ? vhcLampr.perluPerbaikan
                    : vhcLampr.tidakAda;
        rvhcLampm = index == 0
            ? vhcLampm.tidakAda
            : index == 1
                ? vhcLampm.tersedia
                : index == 2
                    ? vhcLampm.perluPerbaikan
                    : vhcLampm.tidakAda;
        rvhcLampAlarm = index == 0
            ? vhcLampAlarm.tidakAda
            : index == 1
                ? vhcLampAlarm.tersedia
                : index == 2
                    ? vhcLampAlarm.perluPerbaikan
                    : vhcLampAlarm.tidakAda;
      }
      if (event == "chasis") {
        rvhcKopling = index == 0
            ? vhcKopling.tidakAda
            : index == 1
                ? vhcKopling.tersedia
                : index == 2
                    ? vhcKopling.perluPerbaikan
                    : vhcKopling.tidakAda;
        rvhcGardan = index == 0
            ? vhcGardan.tidakAda
            : index == 1
                ? vhcGardan.tersedia
                : index == 2
                    ? vhcGardan.perluPerbaikan
                    : vhcGardan.tidakAda;
        rvhcParking = index == 0
            ? vhcParking.tidakAda
            : index == 1
                ? vhcParking.tersedia
                : index == 2
                    ? vhcParking.perluPerbaikan
                    : vhcParking.tidakAda;
        rvhcFoot = index == 0
            ? vhcFoot.tidakAda
            : index == 1
                ? vhcFoot.tersedia
                : index == 2
                    ? vhcFoot.perluPerbaikan
                    : vhcFoot.tidakAda;
        rvhcBautRoda = index == 0
            ? vhcBautRoda.tidakAda
            : index == 1
                ? vhcBautRoda.tersedia
                : index == 2
                    ? vhcBautRoda.perluPerbaikan
                    : vhcBautRoda.tidakAda;
        rvhcVelg = index == 0
            ? vhcVelg.tidakAda
            : index == 1
                ? vhcVelg.tersedia
                : index == 2
                    ? vhcVelg.perluPerbaikan
                    : vhcVelg.tidakAda;
      }
      if (event == "ban") {
        rvhcBan = index == 0
            ? vhcBan.tidakAda
            : index == 1
                ? vhcBan.tersedia
                : index == 2
                    ? vhcBan.perluPerbaikan
                    : vhcBan.tidakAda;
        rvhcAngin = index == 0
            ? vhcAngin.tidakAda
            : index == 1
                ? vhcAngin.tersedia
                : index == 2
                    ? vhcAngin.perluPerbaikan
                    : vhcAngin.tidakAda;
      }
      if (event == "peralatan") {
        rvhcTerpal = index == 0
            ? vhcTerpal.tidakAda
            : index == 1
                ? vhcTerpal.tersedia
                : index == 2
                    ? vhcTerpal.perluPerbaikan
                    : vhcTerpal.tidakAda;
        rvhcWebing = index == 0
            ? vhcWebing.tidakAda
            : index == 1
                ? vhcWebing.tersedia
                : index == 2
                    ? vhcWebing.perluPerbaikan
                    : vhcWebing.tidakAda;
        rvhcTambang = index == 0
            ? vhcTambang.tidakAda
            : index == 1
                ? vhcTambang.tersedia
                : index == 2
                    ? vhcTambang.perluPerbaikan
                    : vhcTambang.tidakAda;
        rvhcDongkrak = index == 0
            ? vhcDongkrak.tidakAda
            : index == 1
                ? vhcDongkrak.tersedia
                : index == 2
                    ? vhcDongkrak.perluPerbaikan
                    : vhcDongkrak.tidakAda;
        rvhcKRoda = index == 0
            ? vhcKRoda.tidakAda
            : index == 1
                ? vhcKRoda.tersedia
                : index == 2
                    ? vhcKRoda.perluPerbaikan
                    : vhcKRoda.tidakAda;
        rvhcGBan = index == 0
            ? vhcGBan.tidakAda
            : index == 1
                ? vhcGBan.tersedia
                : index == 2
                    ? vhcGBan.perluPerbaikan
                    : vhcGBan.tidakAda;
        rvhcGps = index == 0
            ? vhcGps.tidakAda
            : index == 1
                ? vhcGps.tersedia
                : index == 2
                    ? vhcGps.perluPerbaikan
                    : vhcGps.tidakAda;
        rvhcDashCam = index == 0
            ? vhcDashCam.tidakAda
            : index == 1
                ? vhcDashCam.tersedia
                : index == 2
                    ? vhcDashCam.perluPerbaikan
                    : vhcDashCam.tidakAda;
      }

      if (event == "document") {
        rvhcSurat = index == 0
            ? vhcSurat.tidakAda
            : index == 1
                ? vhcSurat.tersedia
                : index == 2
                    ? vhcSurat.perluPerbaikan
                    : vhcSurat.tidakAda;
        rvhcKir = index == 0
            ? vhcKir.tidakAda
            : index == 1
                ? vhcKir.tersedia
                : index == 2
                    ? vhcKir.perluPerbaikan
                    : vhcKir.tidakAda;
        rvhcSim = index == 0
            ? vhcSim.tidakAda
            : index == 1
                ? vhcSim.tersedia
                : index == 2
                    ? vhcSim.perluPerbaikan
                    : vhcSim.tidakAda;
      }
    });
  }

  Widget buildSelectTruck(BuildContext context) {
    return SmartSelect<String>.multiple(
      title: 'Ban Type $type_truck',
      selectedValue: selBan,
      onChange: (selected) {
        setState(() => selBan = selected.value);
      },
      choiceItems: type_truck == "TR"
          ? choices.collBanTR
          : (type_truck == "LT" ? choices.collBanLT : choices.collBanTRAILLER),
      modalType: S2ModalType.popupDialog,
      modalConfirm: true,
      modalValidation: (value) {
        return value.length > 0 ? '0' : 'Select at least one';
      },
      modalHeaderStyle: S2ModalHeaderStyle(
        backgroundColor: Theme.of(context).cardColor,
      ),
      tileBuilder: (context, state) {
        return S2Tile.fromState(
          state,
          isTwoLine: true,
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.shopping_cart),
          ),
        );
      },
      modalActionsBuilder: (context, state) {
        return <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: state.choiceSelectorAll,
          )
        ];
      },
      modalDividerBuilder: (context, state) {
        return const Divider(height: 1);
      },
      modalFooterBuilder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 7.0,
          ),
          child: Row(
            children: <Widget>[
              const Spacer(),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  state.selection?.clear();
                  state.closeModal(confirmed: false);
                  setState(() {
                    selBan = [];
                  });
                },
              ),
              const SizedBox(width: 5),
              TextButton(
                onPressed: state.mounted
                    ? () => state.closeModal(confirmed: true)
                    : null,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    isLoadcheked();
    getTypeTruck();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true);

    pr?.style(
      message: 'Wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              //backgroundColor: Color(0xFFFF1744),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(context);
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
              title: Text('Form Inspeksi ${globals.p2hVhcid.toString()}',
                  style: TextStyle(color: Colors.black))),
          body: Container(
              key: globalScaffoldKey,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text("Daily Check Before Riding",
                          style: TextStyle(fontSize: 25)),
                    ),
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Table(
                            columnWidths: {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(4),
                              2: FlexColumnWidth(4),
                            },
                            //border: TableBorder.all(),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent),
                                      Text('= Tidak Ada',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold))
                                    ]),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check,
                                          size: 20, color: Colors.green),
                                      Text('= Tersedia',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold))
                                    ]),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent),
                                      Text('= Perlu Perbaikan',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold))
                                    ])
                              ]),
                            ])),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Table(
                        columnWidths: {
                          0: FlexColumnWidth(4),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        border: TableBorder.all(),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('Pengecekan Dasar ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent),
                                  if (isShowCheck) ...[
                                    Checkbox(
                                        value: isPengecekanDasar1,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isPengecekanDasar1 = newValue ?? false;
                                            if (newValue == true) {
                                              selectUnselect(
                                                  "pengecekan-dasar", 0);
                                              isPengecekanDasar3 = false;
                                              isPengecekanDasar2 = false;
                                            } else {
                                              selectUnselect(
                                                  "pengecekan-dasar", -1);
                                            }
                                          });
                                        }),
                                    Icon(Icons.close,
                                        size: 20, color: Colors.redAccent)
                                  ]
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green),
                                  if (isShowCheck) ...[
                                    Checkbox(
                                        value: isPengecekanDasar2,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isPengecekanDasar2 = newValue ?? false;
                                            if (newValue == true) {
                                              selectUnselect(
                                                  "pengecekan-dasar", 1);
                                              isPengecekanDasar1 = false;
                                              isPengecekanDasar3 = false;
                                            } else {
                                              selectUnselect(
                                                  "pengecekan-dasar", -1);
                                            }
                                          });
                                        }),
                                    Icon(Icons.check_circle,
                                        size: 20, color: Colors.green)
                                  ]
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent),
                                  if (isShowCheck) ...[
                                    Checkbox(
                                        value: isPengecekanDasar3,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isPengecekanDasar3 = newValue ?? false;
                                            if (newValue == true) {
                                              selectUnselect(
                                                  "pengecekan-dasar", 2);
                                              isPengecekanDasar1 = false;
                                              isPengecekanDasar2 = false;
                                            } else {
                                              selectUnselect(
                                                  "pengecekan-dasar", -1);
                                            }
                                          });
                                        }),
                                    Icon(Icons.handyman,
                                        size: 20, color: Colors.redAccent)
                                  ]
                                ]),
                              ]), //HEADER PENGECEKAN
                          // TableRow(children: [
                          //   Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Text(' OLI', style: TextStyle(fontSize: 14))
                          //       ]),
                          //   Column(children: [
                          //     Radio<vhcOil>(
                          //       value: vhcOil.tidakAda,
                          //       groupValue: rvhcOil,
                          //       onChanged: (vhcOil value) {
                          //         setState(() {
                          //           rvhcOil = value;
                          //         });
                          //       },
                          //     )
                          //   ]),
                          //   Column(children: [
                          //     Radio<vhcOil>(
                          //       value: vhcOil.tersedia,
                          //       groupValue: rvhcOil,
                          //       onChanged: (vhcOil value) {
                          //         setState(() {
                          //           rvhcOil = value;
                          //         });
                          //       },
                          //     )
                          //   ]),
                          //   Column(children: [
                          //     Radio<vhcOil>(
                          //       value: vhcOil.perluPerbaikan,
                          //       groupValue: rvhcOil,
                          //       onChanged: (vhcOil value) {
                          //         setState(() {
                          //           rvhcOil = value;
                          //         });
                          //       },
                          //     )
                          //   ]),
                          // ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Oli Mesin',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcOliMesin>(
                                value: vhcOliMesin.tidakAda,
                                groupValue: rvhcOliMesin,
                                onChanged: (vhcOliMesin? value) {
                                  if (value != null)
                                    setState(() => rvhcOliMesin = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOliMesin>(
                                value: vhcOliMesin.tersedia,
                                groupValue: rvhcOliMesin,
                                onChanged: (vhcOliMesin? value) {
                                  if (value != null)
                                    setState(() => rvhcOliMesin = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOliMesin>(
                                value: vhcOliMesin.perluPerbaikan,
                                groupValue: rvhcOliMesin,
                                onChanged: (vhcOliMesin? value) {
                                  if (value != null)
                                    setState(() => rvhcOliMesin = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Oli Gardan',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcOliGardan>(
                                value: vhcOliGardan.tidakAda,
                                groupValue: rvhcOliGardan,
                                onChanged: (vhcOliGardan? value) {
                                  if (value != null)
                                    setState(() => rvhcOliGardan = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOliGardan>(
                                value: vhcOliGardan.tersedia,
                                groupValue: rvhcOliGardan,
                                onChanged: (vhcOliGardan? value) {
                                  if (value != null)
                                    setState(() => rvhcOliGardan = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOliGardan>(
                                value: vhcOliGardan.perluPerbaikan,
                                groupValue: rvhcOliGardan,
                                onChanged: (vhcOliGardan? value) {
                                  if (value != null)
                                    setState(() => rvhcOliGardan = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Oli Transmisi',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcOliTransmisi>(
                                value: vhcOliTransmisi.tidakAda,
                                groupValue: rvhcOliTransmisi,
                                onChanged: (vhcOliTransmisi? value) {
                                  if (value != null)
                                    setState(() => rvhcOliTransmisi = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOliTransmisi>(
                                value: vhcOliTransmisi.tersedia,
                                groupValue: rvhcOliTransmisi,
                                onChanged: (vhcOliTransmisi? value) {
                                  if (value != null)
                                    setState(() => rvhcOliTransmisi = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOliTransmisi>(
                                value: vhcOliTransmisi.perluPerbaikan,
                                groupValue: rvhcOliTransmisi,
                                onChanged: (vhcOliTransmisi? value) {
                                  if (value != null)
                                    setState(() => rvhcOliTransmisi = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Air Radiator',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcAir>(
                                value: vhcAir.tidakAda,
                                groupValue: rvhcAir,
                                onChanged: (vhcAir? value) {
                                  if (value != null)
                                    setState(() => rvhcAir = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcAir>(
                                value: vhcAir.tersedia,
                                groupValue: rvhcAir,
                                onChanged: (vhcAir? value) {
                                  if (value != null)
                                    setState(() => rvhcAir = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcAir>(
                                value: vhcAir.perluPerbaikan,
                                groupValue: rvhcAir,
                                onChanged: (vhcAir? value) {
                                  if (value != null)
                                    setState(() => rvhcAir = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Air Aki',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcAccu>(
                                value: vhcAccu.tidakAda,
                                groupValue: rvhcAccu,
                                onChanged: (vhcAccu? value) {
                                  if (value != null)
                                    setState(() => rvhcAccu = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcAccu>(
                                value: vhcAccu.tersedia,
                                groupValue: rvhcAccu,
                                onChanged: (vhcAccu? value) {
                                  if (value != null)
                                    setState(() => rvhcAccu = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcAccu>(
                                value: vhcAccu.perluPerbaikan,
                                groupValue: rvhcAccu,
                                onChanged: (vhcAccu? value) {
                                  if (value != null)
                                    setState(() => rvhcAccu = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Minyak Rem',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcMrem>(
                                value: vhcMrem.tidakAda,
                                groupValue: rvhcMrem,
                                onChanged: (vhcMrem? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcMrem = value;
                                      print(globals.rvhcMrem);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcMrem>(
                                value: vhcMrem.tersedia,
                                groupValue: rvhcMrem,
                                onChanged: (vhcMrem? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcMrem = value;
                                      print(globals.rvhcMrem);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcMrem>(
                                value: vhcMrem.perluPerbaikan,
                                groupValue: rvhcMrem,
                                onChanged: (vhcMrem? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcMrem = value;
                                      print(rvhcMrem);
                                    });
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Oli Power Steering',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcOLips>(
                                value: vhcOLips.tidakAda,
                                groupValue: rvhcOLips,
                                onChanged: (vhcOLips? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcOLips = value;
                                      print(globals.rvhcOLips);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOLips>(
                                value: vhcOLips.tersedia,
                                groupValue: rvhcOLips,
                                onChanged: (vhcOLips? value) {
                                  if (value != null)
                                    setState(() => rvhcOLips = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcOLips>(
                                value: vhcOLips.perluPerbaikan,
                                groupValue: rvhcOLips,
                                onChanged: (vhcOLips? value) {
                                  if (value != null)
                                    setState(() => rvhcOLips = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('KABIN',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isKabin1,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isKabin1 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("kabin", 0);
                                  //           isKabin3 = false;
                                  //           isKabin2 = false;
                                  //         } else {
                                  //           selectUnselect("kabin", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.close,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green)
                                  // Checkbox(
                                  //     value: isKabin2,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isKabin2 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("kabin", 1);
                                  //           isKabin1 = false;
                                  //           isKabin3 = false;
                                  //         } else {
                                  //           selectUnselect("kabin", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.check_circle,
                                  //     size: 20, color: Colors.green)
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isKabin3,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isKabin3 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("kabin", 2);
                                  //           isKabin1 = false;
                                  //           isKabin2 = false;
                                  //         } else {
                                  //           selectUnselect("kabin", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.handyman,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                              ]), //HEADER KABIN
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Body Kabin',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcKabin>(
                                value: vhcKabin.tidakAda,
                                groupValue: rvhcKabin,
                                onChanged: (vhcKabin? value) {
                                  if (value != null)
                                    setState(() => rvhcKabin = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKabin>(
                                value: vhcKabin.tersedia,
                                groupValue: rvhcKabin,
                                onChanged: (vhcKabin? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcKabin = value;
                                      print(rvhcKabin);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKabin>(
                                value: vhcKabin.perluPerbaikan,
                                groupValue: rvhcKabin,
                                onChanged: (vhcKabin? value) {
                                  if (value != null)
                                    setState(() => rvhcKabin = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Kaca', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcKaca>(
                                value: vhcKaca.tidakAda,
                                groupValue: rvhcKaca,
                                onChanged: (vhcKaca? value) {
                                  if (value != null)
                                    setState(() => rvhcKaca = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKaca>(
                                value: vhcKaca.tersedia,
                                groupValue: rvhcKaca,
                                onChanged: (vhcKaca? value) {
                                  if (value != null)
                                    setState(() => rvhcKaca = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKaca>(
                                value: vhcKaca.perluPerbaikan,
                                groupValue: rvhcKaca,
                                onChanged: (vhcKaca? value) {
                                  if (value != null)
                                    setState(() => rvhcKaca = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Spion', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcSpion>(
                                value: vhcSpion.tidakAda,
                                groupValue: rvhcSpion,
                                onChanged: (vhcSpion? value) {
                                  if (value != null)
                                    setState(() => rvhcSpion = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSpion>(
                                value: vhcSpion.tersedia,
                                groupValue: rvhcSpion,
                                onChanged: (vhcSpion? value) {
                                  if (value != null)
                                    setState(() => rvhcSpion = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSpion>(
                                value: vhcSpion.perluPerbaikan,
                                groupValue: rvhcSpion,
                                onChanged: (vhcSpion? value) {
                                  if (value != null)
                                    setState(() => rvhcSpion = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Speedometer',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcSpeedo>(
                                value: vhcSpeedo.tidakAda,
                                groupValue: rvhcSpeedo,
                                onChanged: (vhcSpeedo? value) {
                                  if (value != null)
                                    setState(() => rvhcSpeedo = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSpeedo>(
                                value: vhcSpeedo.tersedia,
                                groupValue: rvhcSpeedo,
                                onChanged: (vhcSpeedo? value) {
                                  if (value != null)
                                    setState(() => rvhcSpeedo = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSpeedo>(
                                value: vhcSpeedo.perluPerbaikan,
                                groupValue: rvhcSpeedo,
                                onChanged: (vhcSpeedo? value) {
                                  if (value != null)
                                    setState(() => rvhcSpeedo = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Wiper', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcWiper>(
                                value: vhcWiper.tidakAda,
                                groupValue: rvhcWiper,
                                onChanged: (vhcWiper? value) {
                                  if (value != null)
                                    setState(() => rvhcWiper = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcWiper>(
                                value: vhcWiper.tersedia,
                                groupValue: rvhcWiper,
                                onChanged: (vhcWiper? value) {
                                  if (value != null)
                                    setState(() => rvhcWiper = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcWiper>(
                                value: vhcWiper.perluPerbaikan,
                                groupValue: rvhcWiper,
                                onChanged: (vhcWiper? value) {
                                  if (value != null)
                                    setState(() => rvhcWiper = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Klakson',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcKlak>(
                                value: vhcKlak.tidakAda,
                                groupValue: rvhcKlak,
                                onChanged: (vhcKlak? value) {
                                  if (value != null)
                                    setState(() => rvhcKlak = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKlak>(
                                value: vhcKlak.tersedia,
                                groupValue: rvhcKlak,
                                onChanged: (vhcKlak? value) {
                                  if (value != null)
                                    setState(() => rvhcKlak = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKlak>(
                                value: vhcKlak.perluPerbaikan,
                                groupValue: rvhcKlak,
                                onChanged: (vhcKlak? value) {
                                  if (value != null)
                                    setState(() => rvhcKlak = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Jok', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcJok>(
                                value: vhcJok.tidakAda,
                                groupValue: rvhcJok,
                                onChanged: (vhcJok? value) {
                                  if (value != null)
                                    setState(() => rvhcJok = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcJok>(
                                value: vhcJok.tersedia,
                                groupValue: rvhcJok,
                                onChanged: (vhcJok? value) {
                                  if (value != null)
                                    setState(() => rvhcJok = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcJok>(
                                value: vhcJok.perluPerbaikan,
                                groupValue: rvhcJok,
                                onChanged: (vhcJok? value) {
                                  if (value != null)
                                    setState(() => rvhcJok = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Sabuk Pengaman',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcSeatBealt>(
                                value: vhcSeatBealt.tidakAda,
                                groupValue: rvhcSeatBealt,
                                onChanged: (vhcSeatBealt? value) {
                                  if (value != null)
                                    setState(() => rvhcSeatBealt = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSeatBealt>(
                                value: vhcSeatBealt.tersedia,
                                groupValue: rvhcSeatBealt,
                                onChanged: (vhcSeatBealt? value) {
                                  if (value != null)
                                    setState(() => rvhcSeatBealt = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSeatBealt>(
                                value: vhcSeatBealt.perluPerbaikan,
                                groupValue: rvhcSeatBealt,
                                onChanged: (vhcSeatBealt? value) {
                                  if (value != null)
                                    setState(() => rvhcSeatBealt = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Apar', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcApar>(
                                value: vhcApar.tidakAda,
                                groupValue: rvhcApar,
                                onChanged: (vhcApar? value) {
                                  if (value != null)
                                    setState(() => rvhcApar = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcApar>(
                                value: vhcApar.tersedia,
                                groupValue: rvhcApar,
                                onChanged: (vhcApar? value) {
                                  if (value != null)
                                    setState(() => rvhcApar = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcApar>(
                                value: vhcApar.perluPerbaikan,
                                groupValue: rvhcApar,
                                onChanged: (vhcApar? value) {
                                  if (value != null)
                                    setState(() => rvhcApar = value);
                                },
                              )
                            ]),
                          ]), //
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' P3K', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcP3k>(
                                value: vhcP3k.tidakAda,
                                groupValue: rvhcP3k,
                                onChanged: (vhcP3k? value) {
                                  if (value != null)
                                    setState(() => rvhcP3k = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcP3k>(
                                value: vhcP3k.tersedia,
                                groupValue: rvhcP3k,
                                onChanged: (vhcP3k? value) {
                                  if (value != null)
                                    setState(() => rvhcP3k = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcP3k>(
                                value: vhcP3k.perluPerbaikan,
                                groupValue: rvhcP3k,
                                onChanged: (vhcP3k? value) {
                                  if (value != null)
                                    setState(() => rvhcP3k = value);
                                },
                              )
                            ]),
                          ]), //
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Segitiga Pengaman',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcCone>(
                                value: vhcCone.tidakAda,
                                groupValue: rvhcCone,
                                onChanged: (vhcCone? value) {
                                  if (value != null)
                                    setState(() => rvhcCone = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcCone>(
                                value: vhcCone.tersedia,
                                groupValue: rvhcCone,
                                onChanged: (vhcCone? value) {
                                  if (value != null)
                                    setState(() => rvhcCone = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcCone>(
                                value: vhcCone.perluPerbaikan,
                                groupValue: rvhcCone,
                                onChanged: (vhcCone? value) {
                                  if (value != null)
                                    setState(() => rvhcCone = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Stiker Reflektor',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcStikerRef>(
                                value: vhcStikerRef.tidakAda,
                                groupValue: rvhcStikerRef,
                                onChanged: (vhcStikerRef? value) {
                                  if (value != null)
                                    setState(() => rvhcStikerRef = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcStikerRef>(
                                value: vhcStikerRef.tersedia,
                                groupValue: rvhcStikerRef,
                                onChanged: (vhcStikerRef? value) {
                                  if (value != null)
                                    setState(() => rvhcStikerRef = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcStikerRef>(
                                value: vhcStikerRef.perluPerbaikan,
                                groupValue: rvhcStikerRef,
                                onChanged: (vhcStikerRef? value) {
                                  if (value != null)
                                    setState(() => rvhcStikerRef = value);
                                },
                              )
                            ]),
                          ]), //
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('Elektrik',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isElektrik1,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isElektrik1 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("electric", 0);
                                  //           isElektrik2 = false;
                                  //           isElektrik3 = false;
                                  //         } else {
                                  //           selectUnselect("electric", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.close,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green)
                                  // Checkbox(
                                  //     value: isElektrik2,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isElektrik2 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("electric", 1);
                                  //           isElektrik1 = false;
                                  //           isElektrik3 = false;
                                  //         } else {
                                  //           selectUnselect("electric", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.check_circle,
                                  //     size: 20, color: Colors.green)
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isElektrik3,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isElektrik3 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("electric", 2);
                                  //           isElektrik1 = false;
                                  //           isElektrik2 = false;
                                  //         } else {
                                  //           selectUnselect("electric", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.handyman,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                              ]), //HEADER ELEKTRIk
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Lampu Depan',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcLampd>(
                                value: vhcLampd.tidakAda,
                                groupValue: rvhcLampd,
                                onChanged: (vhcLampd? value) {
                                  if (value != null)
                                    setState(() => rvhcLampd = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampd>(
                                value: vhcLampd.tersedia,
                                groupValue: rvhcLampd,
                                onChanged: (vhcLampd? value) {
                                  if (value != null)
                                    setState(() => rvhcLampd = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampd>(
                                value: vhcLampd.perluPerbaikan,
                                groupValue: rvhcLampd,
                                onChanged: (vhcLampd? value) {
                                  if (value != null)
                                    setState(() => rvhcLampd = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Lampu Sign',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcLamps>(
                                value: vhcLamps.tidakAda,
                                groupValue: rvhcLamps,
                                onChanged: (vhcLamps? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcLamps = value;
                                      print(rvhcLamps.index);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLamps>(
                                value: vhcLamps.tersedia,
                                groupValue: rvhcLamps,
                                onChanged: (vhcLamps? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcLamps = value;
                                      print(rvhcLamps.index);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLamps>(
                                value: vhcLamps.perluPerbaikan,
                                groupValue: rvhcLamps,
                                onChanged: (vhcLamps? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcLamps = value;
                                      print(rvhcLamps.index);
                                    });
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Lampu Belakang',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcLampBlk>(
                                value: vhcLampBlk.tidakAda,
                                groupValue: rvhcLampBlk,
                                onChanged: (vhcLampBlk? value) {
                                  if (value != null)
                                    setState(() => rvhcLampBlk = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampBlk>(
                                value: vhcLampBlk.tersedia,
                                groupValue: rvhcLampBlk,
                                onChanged: (vhcLampBlk? value) {
                                  if (value != null)
                                    setState(() => rvhcLampBlk = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampBlk>(
                                value: vhcLampBlk.perluPerbaikan,
                                groupValue: rvhcLampBlk,
                                onChanged: (vhcLampBlk? value) {
                                  if (value != null)
                                    setState(() => rvhcLampBlk = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Lampu Rotary',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcLampr>(
                                value: vhcLampr.tidakAda,
                                groupValue: rvhcLampr,
                                onChanged: (vhcLampr? value) {
                                  if (value != null)
                                    setState(() => rvhcLampr = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampr>(
                                value: vhcLampr.tersedia,
                                groupValue: rvhcLampr,
                                onChanged: (vhcLampr? value) {
                                  if (value != null)
                                    setState(() => rvhcLampr = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampr>(
                                value: vhcLampr.perluPerbaikan,
                                groupValue: rvhcLampr,
                                onChanged: (vhcLampr? value) {
                                  if (value != null)
                                    setState(() => rvhcLampr = value);
                                },
                              )
                            ]),
                          ]), //rotary
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Lampu Mundur',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcLampm>(
                                value: vhcLampm.tidakAda,
                                groupValue: rvhcLampm,
                                onChanged: (vhcLampm? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcLampm = value;
                                      print(rvhcLampm.index);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampm>(
                                value: vhcLampm.tersedia,
                                groupValue: rvhcLampm,
                                onChanged: (vhcLampm? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcLampm = value;
                                      print(rvhcLampm.index);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampm>(
                                value: vhcLampm.perluPerbaikan,
                                groupValue: rvhcLampm,
                                onChanged: (vhcLampm? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcLampm = value;
                                      print(rvhcLampm.index);
                                    });
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Lampu Alarm',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcLampAlarm>(
                                value: vhcLampAlarm.tidakAda,
                                groupValue: rvhcLampAlarm,
                                onChanged: (vhcLampAlarm? value) {
                                  if (value != null)
                                    setState(() => rvhcLampAlarm = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampAlarm>(
                                value: vhcLampAlarm.tersedia,
                                groupValue: rvhcLampAlarm,
                                onChanged: (vhcLampAlarm? value) {
                                  if (value != null)
                                    setState(() => rvhcLampAlarm = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcLampAlarm>(
                                value: vhcLampAlarm.perluPerbaikan,
                                groupValue: rvhcLampAlarm,
                                onChanged: (vhcLampAlarm? value) {
                                  if (value != null)
                                    setState(() => rvhcLampAlarm = value);
                                },
                              )
                            ]),
                          ]), //END HEADER ELEKTRIK
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('Chasis',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isChasis1,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isChasis1 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("chasis", 0);
                                  //           isChasis2 = false;
                                  //           isChasis3 = false;
                                  //         } else {
                                  //           selectUnselect("chasis", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.close,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green)
                                  // Checkbox(
                                  //     value: isChasis2,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isChasis2 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("chasis", 1);
                                  //           isChasis1 = false;
                                  //           isChasis3 = false;
                                  //         } else {
                                  //           selectUnselect("chasis", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.check_circle,
                                  //     size: 20, color: Colors.green)
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isChasis3,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isChasis3 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("chasis", 2);
                                  //           isChasis1 = false;
                                  //           isChasis2 = false;
                                  //         } else {
                                  //           selectUnselect("chasis", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.handyman,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                              ]), //HEADER CHASIS
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Transmisi/Kopling',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcKopling>(
                                value: vhcKopling.tidakAda,
                                groupValue: rvhcKopling,
                                onChanged: (vhcKopling? value) {
                                  if (value != null)
                                    setState(() => rvhcKopling = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKopling>(
                                value: vhcKopling.tersedia,
                                groupValue: rvhcKopling,
                                onChanged: (vhcKopling? value) {
                                  if (value != null)
                                    setState(() => rvhcKopling = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKopling>(
                                value: vhcKopling.perluPerbaikan,
                                groupValue: rvhcKopling,
                                onChanged: (vhcKopling? value) {
                                  if (value != null)
                                    setState(() => rvhcKopling = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Gardan',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcGardan>(
                                value: vhcGardan.tidakAda,
                                groupValue: rvhcGardan,
                                onChanged: (vhcGardan? value) {
                                  if (value != null)
                                    setState(() => rvhcGardan = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcGardan>(
                                value: vhcGardan.tersedia,
                                groupValue: rvhcGardan,
                                onChanged: (vhcGardan? value) {
                                  if (value != null)
                                    setState(() => rvhcGardan = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcGardan>(
                                value: vhcGardan.perluPerbaikan,
                                groupValue: rvhcGardan,
                                onChanged: (vhcGardan? value) {
                                  if (value != null)
                                    setState(() => rvhcGardan = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Rem Tangan',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcParking>(
                                value: vhcParking.tidakAda,
                                groupValue: rvhcParking,
                                onChanged: (vhcParking? value) {
                                  if (value != null)
                                    setState(() => rvhcParking = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcParking>(
                                value: vhcParking.tersedia,
                                groupValue: rvhcParking,
                                onChanged: (vhcParking? value) {
                                  if (value != null)
                                    setState(() => rvhcParking = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcParking>(
                                value: vhcParking.perluPerbaikan,
                                groupValue: rvhcParking,
                                onChanged: (vhcParking? value) {
                                  if (value != null)
                                    setState(() => rvhcParking = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Rem Kaku',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcFoot>(
                                value: vhcFoot.tidakAda,
                                groupValue: rvhcFoot,
                                onChanged: (vhcFoot? value) {
                                  if (value != null)
                                    setState(() => rvhcFoot = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcFoot>(
                                value: vhcFoot.tersedia,
                                groupValue: rvhcFoot,
                                onChanged: (vhcFoot? value) {
                                  if (value != null)
                                    setState(() => rvhcFoot = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcFoot>(
                                value: vhcFoot.perluPerbaikan,
                                groupValue: rvhcFoot,
                                onChanged: (vhcFoot? value) {
                                  if (value != null)
                                    setState(() => rvhcFoot = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Baut Roda',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcBautRoda>(
                                value: vhcBautRoda.tidakAda,
                                groupValue: rvhcBautRoda,
                                onChanged: (vhcBautRoda? value) {
                                  if (value != null)
                                    setState(() => rvhcBautRoda = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcBautRoda>(
                                value: vhcBautRoda.tersedia,
                                groupValue: rvhcBautRoda,
                                onChanged: (vhcBautRoda? value) {
                                  if (value != null)
                                    setState(() => rvhcBautRoda = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcBautRoda>(
                                value: vhcBautRoda.perluPerbaikan,
                                groupValue: rvhcBautRoda,
                                onChanged: (vhcBautRoda? value) {
                                  if (value != null)
                                    setState(() => rvhcBautRoda = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Velg', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcVelg>(
                                value: vhcVelg.tidakAda,
                                groupValue: rvhcVelg,
                                onChanged: (vhcVelg? value) {
                                  if (value != null)
                                    setState(() => rvhcVelg = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcVelg>(
                                value: vhcVelg.tersedia,
                                groupValue: rvhcVelg,
                                onChanged: (vhcVelg? value) {
                                  if (value != null)
                                    setState(() => rvhcVelg = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcVelg>(
                                value: vhcVelg.perluPerbaikan,
                                groupValue: rvhcVelg,
                                onChanged: (vhcVelg? value) {
                                  if (value != null)
                                    setState(() => rvhcVelg = value);
                                },
                              )
                            ]),
                          ]), // END OTHER
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('Ban',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isBan1,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isBan1 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("ban", 0);
                                  //           // isKabin1=false;
                                  //           // isKabin2=false;
                                  //           // isKabin3=false;
                                  //           // isElektrik1 =false;
                                  //           // isElektrik2 =false;
                                  //           // isElektrik3 =false;
                                  //           // isOthers1 =false;
                                  //           // isOthers2 =false;
                                  //           // isOthers3 =false;
                                  //           isBan2 = false;
                                  //           isBan3 = false;
                                  //         } else {
                                  //           selectUnselect("ban", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.close,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green)
                                  // Checkbox(
                                  //     value: isBan2,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isBan2 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("ban", 1);
                                  //           // isKabin1=false;
                                  //           // isKabin2=false;
                                  //           // isKabin3=false;
                                  //           // isElektrik1 =false;
                                  //           // isElektrik2 =false;
                                  //           // isElektrik3 =false;
                                  //           // isOthers1 =false;
                                  //           // isOthers2 =false;
                                  //           // isOthers3 =false;
                                  //           isBan1 = false;
                                  //           isBan3 = false;
                                  //         } else {
                                  //           selectUnselect("ban", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.check_circle,
                                  //     size: 20, color: Colors.green)
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isBan3,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isBan3 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("ban", 2);
                                  //           // isKabin1=false;
                                  //           // isKabin2=false;
                                  //           // isKabin3=false;
                                  //           // isElektrik1 =false;
                                  //           // isElektrik2 =false;
                                  //           // isElektrik3 =false;
                                  //           // isOthers1 =false;
                                  //           // isOthers2 =false;
                                  //           // isOthers3 =false;
                                  //           isBan1 = false;
                                  //           isBan2 = false;
                                  //         } else {
                                  //           selectUnselect("ban", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.handyman,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                              ]), //HEADER BAN
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Kondisi Ban',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcBan>(
                                value: vhcBan.tidakAda,
                                groupValue: rvhcBan,
                                onChanged: (vhcBan? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcBan = value;
                                      print(rvhcBan);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcBan>(
                                value: vhcBan.tersedia,
                                groupValue: rvhcBan,
                                onChanged: (vhcBan? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcBan = value;
                                      print(rvhcBan);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcBan>(
                                value: vhcBan.perluPerbaikan,
                                groupValue: rvhcBan,
                                onChanged: (vhcBan? value) {
                                  setState(() {
                                    rvhcBan = value!;
                                    print(rvhcBan.index);
                                    print(type_truck);
                                    if (rvhcBan != null) {
                                      if (rvhcBan.index == 2) {
                                        isFinish();
                                        if (type_truck == "TRAILLER") {
                                          //Navigator.
                                          globals.page_inspeksi = "opr";
                                          Navigator.push(
                                              globalScaffoldKey.currentContext!,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewCarTRAILLER()));
                                        }
                                        if (type_truck == "TR") {
                                          globals.page_inspeksi = "opr";
                                          Navigator.push(
                                              globalScaffoldKey.currentContext!,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewCarTR()));
                                        }
                                        if (type_truck == "LT") {
                                          globals.page_inspeksi = "opr";
                                          Navigator.push(
                                              globalScaffoldKey.currentContext!,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewCarLT()));
                                        }
                                      }
                                    }
                                  });
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Tekanan Angin',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcAngin>(
                                value: vhcAngin.tidakAda,
                                groupValue: rvhcAngin,
                                onChanged: (vhcAngin? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcAngin = value;
                                      print(rvhcAngin.index);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcAngin>(
                                value: vhcAngin.tersedia,
                                groupValue: rvhcAngin,
                                onChanged: (vhcAngin? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcAngin = value;
                                      print(rvhcAngin.index);
                                    });
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcAngin>(
                                value: vhcAngin.perluPerbaikan,
                                groupValue: rvhcAngin,
                                onChanged: (vhcAngin? value) {
                                  if (value != null)
                                    setState(() {
                                      rvhcAngin = value;
                                      print(rvhcAngin.index);
                                    });
                                },
                              )
                            ]),
                          ]),
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('Peralatan',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isPeralatan1,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isPeralatan1 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("peralatan", 0);
                                  //           isPeralatan2 = false;
                                  //           isPeralatan3 = false;
                                  //         } else {
                                  //           selectUnselect("peralatan", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.close,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green)
                                  // Checkbox(
                                  //     value: isPeralatan2,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isPeralatan2 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("peralatan", 1);
                                  //           isPeralatan1 = false;
                                  //           isPeralatan3 = false;
                                  //         } else {
                                  //           selectUnselect("peralatan", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.check_circle,
                                  //     size: 20, color: Colors.green)
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isPeralatan3,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isPeralatan3 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("peralatan", 2);
                                  //           isPeralatan1 = false;
                                  //           isPeralatan2 = false;
                                  //         } else {
                                  //           selectUnselect("peralatan", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.handyman,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                              ]), //HEADDR Peralatan
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Terpal',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcTerpal>(
                                value: vhcTerpal.tidakAda,
                                groupValue: rvhcTerpal,
                                onChanged: (vhcTerpal? value) {
                                  if (value != null)
                                    setState(() => rvhcTerpal = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcTerpal>(
                                value: vhcTerpal.tersedia,
                                groupValue: rvhcTerpal,
                                onChanged: (vhcTerpal? value) {
                                  if (value != null)
                                    setState(() => rvhcTerpal = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcTerpal>(
                                value: vhcTerpal.perluPerbaikan,
                                groupValue: rvhcTerpal,
                                onChanged: (vhcTerpal? value) {
                                  if (value != null)
                                    setState(() => rvhcTerpal = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Webing',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcWebing>(
                                value: vhcWebing.tidakAda,
                                groupValue: rvhcWebing,
                                onChanged: (vhcWebing? value) {
                                  if (value != null)
                                    setState(() => rvhcWebing = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcWebing>(
                                value: vhcWebing.tersedia,
                                groupValue: rvhcWebing,
                                onChanged: (vhcWebing? value) {
                                  if (value != null)
                                    setState(() => rvhcWebing = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcWebing>(
                                value: vhcWebing.perluPerbaikan,
                                groupValue: rvhcWebing,
                                onChanged: (vhcWebing? value) {
                                  if (value != null)
                                    setState(() => rvhcWebing = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Tambang',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcTambang>(
                                value: vhcTambang.tidakAda,
                                groupValue: rvhcTambang,
                                onChanged: (vhcTambang? value) {
                                  if (value != null)
                                    setState(() => rvhcTambang = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcTambang>(
                                value: vhcTambang.tersedia,
                                groupValue: rvhcTambang,
                                onChanged: (vhcTambang? value) {
                                  if (value != null)
                                    setState(() => rvhcTambang = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcTambang>(
                                value: vhcTambang.perluPerbaikan,
                                groupValue: rvhcTambang,
                                onChanged: (vhcTambang? value) {
                                  if (value != null)
                                    setState(() => rvhcTambang = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Dongkrak',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcDongkrak>(
                                value: vhcDongkrak.tidakAda,
                                groupValue: rvhcDongkrak,
                                onChanged: (vhcDongkrak? value) {
                                  if (value != null)
                                    setState(() => rvhcDongkrak = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcDongkrak>(
                                value: vhcDongkrak.tersedia,
                                groupValue: rvhcDongkrak,
                                onChanged: (vhcDongkrak? value) {
                                  if (value != null)
                                    setState(() => rvhcDongkrak = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcDongkrak>(
                                value: vhcDongkrak.perluPerbaikan,
                                groupValue: rvhcDongkrak,
                                onChanged: (vhcDongkrak? value) {
                                  if (value != null)
                                    setState(() => rvhcDongkrak = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Kunci Roda',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcKRoda>(
                                value: vhcKRoda.tidakAda,
                                groupValue: rvhcKRoda,
                                onChanged: (vhcKRoda? value) {
                                  if (value != null)
                                    setState(() => rvhcKRoda = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKRoda>(
                                value: vhcKRoda.tersedia,
                                groupValue: rvhcKRoda,
                                onChanged: (vhcKRoda? value) {
                                  if (value != null)
                                    setState(() => rvhcKRoda = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKRoda>(
                                value: vhcKRoda.perluPerbaikan,
                                groupValue: rvhcKRoda,
                                onChanged: (vhcKRoda? value) {
                                  if (value != null)
                                    setState(() => rvhcKRoda = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Ganjal Ban',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcGBan>(
                                value: vhcGBan.tidakAda,
                                groupValue: rvhcGBan,
                                onChanged: (vhcGBan? value) {
                                  if (value != null)
                                    setState(() => rvhcGBan = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcGBan>(
                                value: vhcGBan.tersedia,
                                groupValue: rvhcGBan,
                                onChanged: (vhcGBan? value) {
                                  if (value != null)
                                    setState(() => rvhcGBan = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcGBan>(
                                value: vhcGBan.perluPerbaikan,
                                groupValue: rvhcGBan,
                                onChanged: (vhcGBan? value) {
                                  if (value != null)
                                    setState(() => rvhcGBan = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' GPS', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcGps>(
                                value: vhcGps.tidakAda,
                                groupValue: rvhcGps,
                                onChanged: (vhcGps? value) {
                                  if (value != null)
                                    setState(() => rvhcGps = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcGps>(
                                value: vhcGps.tersedia,
                                groupValue: rvhcGps,
                                onChanged: (vhcGps? value) {
                                  if (value != null)
                                    setState(() => rvhcGps = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcGps>(
                                value: vhcGps.perluPerbaikan,
                                groupValue: rvhcGps,
                                onChanged: (vhcGps? value) {
                                  if (value != null)
                                    setState(() => rvhcGps = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' DashCam',
                                      style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcDashCam>(
                                value: vhcDashCam.tidakAda,
                                groupValue: rvhcDashCam,
                                onChanged: (vhcDashCam? value) {
                                  if (value != null)
                                    setState(() => rvhcDashCam = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcDashCam>(
                                value: vhcDashCam.tersedia,
                                groupValue: rvhcDashCam,
                                onChanged: (vhcDashCam? value) {
                                  if (value != null)
                                    setState(() => rvhcDashCam = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcDashCam>(
                                value: vhcDashCam.perluPerbaikan,
                                groupValue: rvhcDashCam,
                                onChanged: (vhcDashCam? value) {
                                  if (value != null)
                                    setState(() => rvhcDashCam = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text('Dokumen',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                Column(children: [
                                  Icon(Icons.close,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isDokumen1,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isDokumen1 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("document", 0);
                                  //           isDokumen2 = false;
                                  //           isDokumen3 = false;
                                  //         } else {
                                  //           selectUnselect("document", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.close,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                                Column(children: [
                                  Icon(Icons.check_circle,
                                      size: 20, color: Colors.green)
                                  // Checkbox(
                                  //     value: isDokumen2,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isDokumen2 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("document", 1);
                                  //           isDokumen1 = false;
                                  //           isDokumen3 = false;
                                  //         } else {
                                  //           selectUnselect("document", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.check_circle,
                                  //     size: 20, color: Colors.green)
                                ]),
                                Column(children: [
                                  Icon(Icons.handyman,
                                      size: 20, color: Colors.redAccent)
                                  // Checkbox(
                                  //     value: isDokumen3,
                                  //     onChanged: (bool? newValue) {
                                  //       setState(() {
                                  //         isDokumen3 = newValue;
                                  //         if (newValue == true) {
                                  //           selectUnselect("document", 2);
                                  //           isDokumen1 = false;
                                  //           isDokumen2 = false;
                                  //         } else {
                                  //           selectUnselect("document", -1);
                                  //         }
                                  //       });
                                  //     }),
                                  // Icon(Icons.handyman,
                                  //     size: 20, color: Colors.redAccent)
                                ]),
                              ]), //HEADER DOKUMENT
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' STNK', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcSurat>(
                                value: vhcSurat.tidakAda,
                                groupValue: rvhcSurat,
                                onChanged: (vhcSurat? value) {
                                  if (value != null)
                                    setState(() => rvhcSurat = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSurat>(
                                value: vhcSurat.tersedia,
                                groupValue: rvhcSurat,
                                onChanged: (vhcSurat? value) {
                                  if (value != null)
                                    setState(() => rvhcSurat = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSurat>(
                                value: vhcSurat.perluPerbaikan,
                                groupValue: rvhcSurat,
                                onChanged: (vhcSurat? value) {
                                  if (value != null)
                                    setState(() => rvhcSurat = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' Kir', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcKir>(
                                value: vhcKir.tidakAda,
                                groupValue: rvhcKir,
                                onChanged: (vhcKir? value) {
                                  if (value != null)
                                    setState(() => rvhcKir = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKir>(
                                value: vhcKir.tersedia,
                                groupValue: rvhcKir,
                                onChanged: (vhcKir? value) {
                                  if (value != null)
                                    setState(() => rvhcKir = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcKir>(
                                value: vhcKir.perluPerbaikan,
                                groupValue: rvhcKir,
                                onChanged: (vhcKir? value) {
                                  if (value != null)
                                    setState(() => rvhcKir = value);
                                },
                              )
                            ]),
                          ]),
                          TableRow(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(' SIM', style: TextStyle(fontSize: 14))
                                ]),
                            Column(children: [
                              Radio<vhcSim>(
                                value: vhcSim.tidakAda,
                                groupValue: rvhcSim,
                                onChanged: (vhcSim? value) {
                                  if (value != null)
                                    setState(() => rvhcSim = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSim>(
                                value: vhcSim.tersedia,
                                groupValue: rvhcSim,
                                onChanged: (vhcSim? value) {
                                  if (value != null)
                                    setState(() => rvhcSim = value);
                                },
                              )
                            ]),
                            Column(children: [
                              Radio<vhcSim>(
                                value: vhcSim.perluPerbaikan,
                                groupValue: rvhcSim,
                                onChanged: (vhcSim? value) {
                                  if (value != null)
                                    setState(() => rvhcSim = value);
                                },
                              )
                            ]),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: TextField(
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.grey.shade800),
                        controller: txtKm,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          labelText: "Kilometer",
                          contentPadding: EdgeInsets.all(5.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: TextField(
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.grey.shade800),
                        controller: txtNotes,
                        onChanged: (value) {
                          if (value != null && value != "") {
                            globals.rvhcNotes = value;
                          }
                        },
                        maxLength: 100,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          labelText: "Notes",
                          contentPadding: EdgeInsets.all(5.0),
                        ),
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(10.0),
                        child: Row(children: <Widget>[
                          Expanded(
                            child: _builButtonReset(context),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: _builButtonNext(context),
                          ),
                        ]))
                  ])))),
    );
  }

  Widget _builButtonReset(BuildContext context) {
    return new ElevatedButton.icon(
      icon: Icon(
        Icons.reset_tv,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Reset"),
      onPressed: () async {
        ResetCheckBox();
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _builButtonNext(BuildContext context) {
    return new ElevatedButton.icon(
      icon: Icon(
        Icons.save,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text("Submit"),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Information'),
            content: new Text("Create Form Inspeksi ${globals.p2hVhcid}"),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text("Ok"),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var username = prefs.getString("name");
                  isFinish();
                  print(globals.rvhcMrem);
                  print("globals.rvhcOliMesin ${globals.rvhcOliMesin}");
                  if (globals.p2hVhcid == null || globals.p2hVhcid == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Vehicle ID tidak boleh kosong", "error");
                  } else if (txtKm.text == null || txtKm.text == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "KIlometer tidak boleh kosong", "error");
                  } else if (int.parse(txtKm.text) <= 0) {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "KIlometer tidak boleh <= 0", "error");
                  } else if (globals.rvhcOliMesin == null || globals.rvhcOliMesin == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli mesin tidak boleh kosong", "error");
                  }else if (globals.rvhcOliGardan == null || globals.rvhcOliGardan == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli gardan tidak boleh kosong", "error");
                  }else if (globals.rvhcOliTransmisi == null || globals.rvhcOliTransmisi == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli transmisi tidak boleh kosong", "error");
                  } else if (globals.rvhcAir == null || globals.rvhcAir == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Radiator tidak boleh kosong", "error");
                  } else if (globals.rvhcAccu == null ||
                      globals.rvhcAccu == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Accu tidak boleh kosong", "error");
                  } else if (globals.rvhcMrem == null ||
                      globals.rvhcMrem == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Minyak rem tidak boleh kosong", "error");
                  } else if (globals.rvhcOLips == null ||
                      globals.rvhcOLips == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli Power steering tidak boleh kosong", "error");
                  } else if (globals.rvhcKabin == null ||
                      globals.rvhcKabin == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Kabin steering tidak boleh kosong", "error");
                  } else if (globals.rvhcKaca == null ||
                      globals.rvhcKaca == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Kaca tidak boleh kosong", "error");
                  } else if (globals.rvhcSpion == null ||
                      globals.rvhcSpion == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Spion tidak boleh kosong", "error");
                  } else if (globals.rvhcSpeedo == null ||
                      globals.rvhcSpeedo == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Speedometer tidak boleh kosong", "error");
                  } else if (globals.rvhcWiper == null ||
                      globals.rvhcWiper == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Wiper tidak boleh kosong", "error");
                  } else if (globals.rvhcKlak == null ||
                      globals.rvhcKlak == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Klakson tidak boleh kosong", "error");
                  } else if (globals.rvhcJok == null || globals.rvhcJok == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Jok tidak boleh kosong", "error");
                  } else if (globals.rvhcSeatBealt == null ||
                      globals.rvhcSeatBealt == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Seat Bealt tidak boleh kosong", "error");
                  } else if (globals.rvhcApar == null ||
                      globals.rvhcApar == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "APAR tidak boleh kosong", "error");
                  } else if (globals.rvhcP3k == null || globals.rvhcP3k == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "P3K tidak boleh kosong", "error");
                  } else if (globals.rvhcCone == null ||
                      globals.rvhcCone == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Segitiga pengaman tidak boleh kosong", "error");
                  }else if (globals.rvhcStikerRef == null ||
                      globals.rvhcStikerRef == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Stiker Reflektor tidak boleh kosong", "error");
                  } else if (globals.rvhcLampd == null ||
                      globals.rvhcLampd == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Lampu depan tidak boleh kosong", "error");
                  } else if (globals.rvhcLamps == null ||
                      globals.rvhcLamps == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Lampu sign tidak boleh kosong", "error");
                  } else if (globals.rvhcLampBlk == null ||
                      globals.rvhcLampBlk == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Lampu belakang tidak boleh kosong", "error");
                  } else if (globals.rvhcLampr == null ||
                      globals.rvhcLampr == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Lampu Rotary tidak boleh kosong", "error");
                  } else if (globals.rvhcLampm == null ||
                      globals.rvhcLampm == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Lampu mundur tidak boleh kosong", "error");
                  } else if (globals.rvhcLampAlarm == null ||
                      globals.rvhcLampAlarm == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Lampu Alarm tidak boleh kosong", "error");
                  } else if (globals.rvhcKopling == null ||
                      globals.rvhcKopling == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Transmisi kopling tidak boleh kosong", "error");
                  } else if (globals.rvhcGardan == null ||
                      globals.rvhcGardan == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Gardan kopling tidak boleh kosong", "error");
                  } else if (globals.rvhcParking == null ||
                      globals.rvhcParking == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Rem tangan tidak boleh kosong", "error");
                  } else if (globals.rvhcFoot == null ||
                      globals.rvhcFoot == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Rem kaki tidak boleh kosong", "error");
                  } else if (globals.rvhcBautRoda == null ||
                      globals.rvhcBautRoda == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Baut roda tidak boleh kosong", "error");
                  } else if (globals.rvhcVelg == null ||
                      globals.rvhcVelg == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Velg tidak boleh kosong", "error");
                  } else if (globals.rvhcBan == null || globals.rvhcBan == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Ban tidak boleh kosong", "error");
                  } else if (globals.rvhcAngin == null ||
                      globals.rvhcAngin == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Angin tidak boleh kosong", "error");
                  } else if (globals.rvhcTerpal == null ||
                      globals.rvhcTerpal == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Terpal tidak boleh kosong", "error");
                  } else if (globals.rvhcWebing == null ||
                      globals.rvhcWebing == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Webing tidak boleh kosong", "error");
                  } else if (globals.rvhcTambang == null ||
                      globals.rvhcTambang == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Tambang tidak boleh kosong", "error");
                  } else if (globals.rvhcDongkrak == null ||
                      globals.rvhcDongkrak == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Dongkrak tidak boleh kosong", "error");
                  } else if (globals.rvhcKRoda == null ||
                      globals.rvhcKRoda == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Kunci Roda tidak boleh kosong", "error");
                  } else if (globals.rvhcGBan == null ||
                      globals.rvhcGBan == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Ganjal ban tidak boleh kosong", "error");
                  } else if (globals.rvhcGps == null || globals.rvhcGps == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "GPS tidak boleh kosong", "error");
                  } else if (globals.rvhcDashCam == null ||
                      globals.rvhcDashCam == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Dash Camera tidak boleh kosong", "error");
                  } else if (globals.rvhcSurat == null ||
                      globals.rvhcSurat == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "STNK tidak boleh kosong", "error");
                  } else if (globals.rvhcKir == null || globals.rvhcKir == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "KIR tidak boleh kosong", "error");
                  } else if (globals.rvhcSim == null || globals.rvhcSim == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "SIM tidak boleh kosong", "error");
                  } else if (int.parse(txtKm.text) <= 0) {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Kilometer tidak boleh kosong", "error");
                  } else {
                    print("globals.rvhcOliMesin");
                    print(globals.rvhcOliMesin);
                    createFormInspeksi(username!);
                  }
                  // Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => ViewAntrian()));
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      style: ElevatedButton.styleFrom(
          elevation: 0.0,
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}
