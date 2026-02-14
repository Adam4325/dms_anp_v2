import 'dart:async';
import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmSetKmByDriver.dart';
import 'package:dms_anp/src/pages/ViewAntrian.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewService.dart';
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
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;

class FrmInspeksiVehicle extends StatefulWidget {
  @override
  _FrmInspeksiVehicleState createState() => _FrmInspeksiVehicleState();
}

//GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
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

class _FrmInspeksiVehicleState extends State<FrmInspeksiVehicle> {
  GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtNotes = new TextEditingController();
  ProgressDialog? pr;
  List<String> selBan = [];
  String type_truck = "";
  String status_code = "";
  String status_code_img = "";
  String message = "";
  String image_url = "";
  double iconSize = 40;

  //PENGECEKAN DASAR
  vhcOil? rvhcOil;
  vhcOliMesin? rvhcOliMesin;
  vhcOliGardan? rvhcOliGardan;
  vhcOliTransmisi? rvhcOliTransmisi;
  vhcAir? rvhcAir;
  vhcAccu? rvhcAccu;
  vhcMrem? rvhcMrem;
  vhcOLips? rvhcOLips;

  //KABIN
  vhcKabin? rvhcKabin;
  vhcKaca? rvhcKaca;
  vhcSpion? rvhcSpion;
  vhcSpeedo? rvhcSpeedo;
  vhcWiper? rvhcWiper;
  vhcKlak? rvhcKlak;
  vhcJok? rvhcJok;
  vhcSeatBealt? rvhcSeatBealt;
  vhcApar? rvhcApar;
  vhcP3k? rvhcP3k;
  vhcCone? rvhcCone;
  vhcStikerRef? rvhcStikerRef;
  //END

  //ELECTRIC
  vhcLampd? rvhcLampd;
  vhcLamps? rvhcLamps;
  vhcLampBlk? rvhcLampBlk;
  vhcLampr? rvhcLampr;
  vhcLampm? rvhcLampm;
  vhcLampAlarm? rvhcLampAlarm;
  //END

  //Chasis
  vhcKopling? rvhcKopling;
  vhcGardan? rvhcGardan;
  vhcParking? rvhcParking;
  vhcFoot? rvhcFoot;
  vhcBautRoda? rvhcBautRoda;
  vhcVelg? rvhcVelg;
  //END

  //BAN
  vhcBan? rvhcBan;
  vhcAngin? rvhcAngin;
  //end

  //PERALATAN
  vhcTerpal? rvhcTerpal;
  vhcWebing? rvhcWebing;
  vhcTambang? rvhcTambang;
  vhcDongkrak? rvhcDongkrak;
  vhcKRoda? rvhcKRoda;
  vhcGBan? rvhcGBan;
  vhcGps? rvhcGps;
  vhcDashCam? rvhcDashCam;

  //DOKUMEN
  vhcSurat? rvhcSurat;
  vhcKir? rvhcKir;
  vhcSim? rvhcSim;

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
    if (globals.page_inspeksi == 'new_driver') {
      ResetCheckBox();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => FrmSetKmByDriver()));
    } else if (globals.page_inspeksi == 'service') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewService()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewDashboard()));
    }
  }

  void getTypeTruck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.p2hVhcid = prefs.getString("method") == 'new'
        ? prefs.getString("vhcid_last_antrian")
        : prefs.getString("vhcidfromdo");
    print(globals.p2hVhcid);
    String? vhcidType = globals.p2hVhcid;
    var urlData = "${GlobalData.baseUrl}api/vehicle/type_vehicle.jsp";
    var dataParam = {"method": "get-vehicle-type-v1", "vhcid": vhcidType};
    print(dataParam);
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


  void ResetCheckBox() {
    setState(() {
      //PENGECEKAN DASAR
      rvhcOil = null;
      rvhcOliMesin = null;
      rvhcOliGardan = null;
      rvhcOliTransmisi = null;
      rvhcAir = null;
      rvhcAccu = null;
      rvhcOLips = null;
      rvhcMrem = null;

      //KABIN
      rvhcKabin = null;
      rvhcKaca = null;
      rvhcSpion = null;
      rvhcSpeedo = null;
      rvhcWiper = null;
      rvhcKlak = null;
      rvhcJok = null;
      rvhcSeatBealt = null;
      rvhcApar = null;
      rvhcP3k = null;
      rvhcCone = null;
      rvhcStikerRef = null;

      //ELECTRIC
      rvhcLampd = null;
      rvhcLamps = null;
      rvhcLampBlk = null;
      rvhcLampr = null;
      rvhcLampm = null;
      rvhcLampAlarm = null;

      //Chasis
      rvhcKopling = null;
      rvhcGardan = null;
      rvhcParking = null;
      rvhcFoot = null;
      rvhcBautRoda = null;
      rvhcVelg = null;

      //BAN
      rvhcBan = null;
      rvhcAngin = null;

      //PERALATAN
      rvhcTerpal = null;
      rvhcWebing = null;
      rvhcTambang = null;
      rvhcTambang = null;
      rvhcDongkrak = null;
      rvhcKRoda = null;
      rvhcGBan = null;
      rvhcGps = null;
      rvhcDashCam = null;

      //DOKUMEN
      rvhcSurat = null;
      rvhcKir = null;
      rvhcSim = null;

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
      globals.rvhcOil = null;
      globals.rvhcOliMesin = null;
      globals.rvhcOliGardan = null;
      globals.rvhcOliTransmisi = null;
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
    });
  }

  void isFinish() {
    setState(() {
      globals.rvhcOil = rvhcOil?.index.toString();
      globals.rvhcOliMesin = rvhcOliMesin?.index.toString();
      globals.rvhcOliGardan = rvhcOliGardan?.index.toString();
      globals.rvhcOliTransmisi = rvhcOliTransmisi?.index.toString();
      globals.rvhcAir = rvhcAir?.index.toString();
      globals.rvhcAccu = rvhcAccu?.index.toString();
      globals.rvhcOLips = rvhcOLips?.index.toString();
      globals.rvhcMrem = rvhcMrem?.index.toString();

      // globals.p2hVhcid = p2hVhcid != null ? p2hVhcid.index.toString() : null;
      // globals.p2hVhckm = 0.0;
      // globals.p2hVhcdate = rvhcKabin != null ? rvhcKabin.index.toString() : null;
      // globals.p2hVhcdefaultdriver = p2hVhcdefaultdriver != null ? p2hVhcdefaultdriver.index.toString() : null;

      //KABIN
      globals.rvhcKabin = rvhcKabin?.index.toString();
      globals.rvhcKaca = rvhcKaca?.index.toString();
      globals.rvhcSpion = rvhcSpion?.index.toString();
      globals.rvhcSpeedo = rvhcSpeedo?.index.toString();
      globals.rvhcWiper = rvhcWiper?.index.toString();
      globals.rvhcKlak = rvhcKlak?.index.toString();
      globals.rvhcJok = rvhcJok?.index.toString();
      globals.rvhcSeatBealt = rvhcSeatBealt?.index.toString();
      globals.rvhcApar = rvhcApar?.index.toString();
      globals.rvhcP3k = rvhcP3k?.index.toString();
      globals.rvhcCone = rvhcCone?.index.toString();
      globals.rvhcStikerRef = rvhcStikerRef?.index.toString();

      //ELECTTRIC
      globals.rvhcLampd = rvhcLampd?.index.toString();
      globals.rvhcLamps = rvhcLamps?.index.toString();
      globals.rvhcLampBlk = rvhcLampBlk?.index.toString();
      globals.rvhcLampr = rvhcLampr?.index.toString();
      globals.rvhcLampm = rvhcLampm?.index.toString();
      globals.rvhcLampAlarm = rvhcLampAlarm?.index.toString();

      //CHASIS
      globals.rvhcKopling = rvhcKopling?.index.toString();
      globals.rvhcGardan = rvhcGardan?.index.toString();
      globals.rvhcParking = rvhcParking?.index.toString();
      globals.rvhcFoot = rvhcFoot?.index.toString();
      globals.rvhcBautRoda = rvhcBautRoda?.index.toString();
      globals.rvhcVelg = rvhcVelg?.index.toString();

      //BAN
      globals.rvhcBan = rvhcBan?.index.toString();
      globals.rvhcAngin = rvhcAngin?.index.toString();

      //PERALATAN
      globals.rvhcTerpal = rvhcTerpal?.index.toString();
      globals.rvhcWebing = rvhcWebing?.index.toString();
      globals.rvhcTambang = rvhcTambang?.index.toString();
      globals.rvhcDongkrak = rvhcDongkrak?.index.toString();
      globals.rvhcKRoda = rvhcKRoda?.index.toString();
      globals.rvhcGBan = rvhcGBan?.index.toString();
      globals.rvhcGps = rvhcGps?.index.toString();
      globals.rvhcDashCam = rvhcDashCam?.index.toString();

      //DOCUMENT
      globals.rvhcSurat = rvhcSurat?.index.toString();
      globals.rvhcKir = rvhcKir?.index.toString();
      globals.rvhcSim = rvhcSim?.index.toString();
      globals.rvhcNotes = rvhcSim?.index.toString();
    });
  }

  void isLoadcheked() {
    setState(() {
      // globals.rvhcKm = rvhcKm != null ? rvhcKm.index.toString() : null;
      txtNotes.text = globals.rvhcNotes.toString() == "null"
          ? ""
          : globals.rvhcNotes.toString();
      //PENGECEKAN
      if (globals.rvhcOil != null) {
        final oil = globals.rvhcOil!;
        rvhcOil = int.parse(oil) == 0
            ? vhcOil.tidakAda
            : int.parse(oil) == 1
                ? vhcOil.tersedia
                : int.parse(oil) == 2
                    ? vhcOil.perluPerbaikan
                    : null;
      }

      if (globals.rvhcOliMesin != null) {
        final v = globals.rvhcOliMesin!;
        rvhcOliMesin = int.parse(v) == 0
            ? vhcOliMesin.tidakAda
            : int.parse(v) == 1
                ? vhcOliMesin.tersedia
                : int.parse(v) == 2
                    ? vhcOliMesin.perluPerbaikan
                    : null;
      }

      if (globals.rvhcOliGardan != null) {
        final v = globals.rvhcOliGardan!;
        rvhcOliGardan = int.parse(v) == 0
            ? vhcOliGardan.tidakAda
            : int.parse(v) == 1
                ? vhcOliGardan.tersedia
                : int.parse(v) == 2
                    ? vhcOliGardan.perluPerbaikan
                    : null;
      }

      if (globals.rvhcOliTransmisi != null) {
        final v = globals.rvhcOliTransmisi!;
        rvhcOliTransmisi = int.parse(v) == 0
            ? vhcOliTransmisi.tidakAda
            : int.parse(v) == 1
                ? vhcOliTransmisi.tersedia
                : int.parse(v) == 2
                    ? vhcOliTransmisi.perluPerbaikan
                    : null;
      }

      if (globals.rvhcAir != null) {
        final v = globals.rvhcAir!;
        rvhcAir = int.parse(v) == 0
            ? vhcAir.tidakAda
            : int.parse(v) == 1
                ? vhcAir.tersedia
                : int.parse(v) == 2
                    ? vhcAir.perluPerbaikan
                    : null;
      }

      if (globals.rvhcAccu != null) {
        final v = globals.rvhcAccu!;
        rvhcAccu = int.parse(v) == 0
            ? vhcAccu.tidakAda
            : int.parse(v) == 1
                ? vhcAccu.tersedia
                : int.parse(v) == 2
                    ? vhcAccu.perluPerbaikan
                    : null;
      }

      if (globals.rvhcMrem != null) {
        final v = globals.rvhcMrem!;
        rvhcMrem = int.parse(v) == 0
            ? vhcMrem.tidakAda
            : int.parse(v) == 1
                ? vhcMrem.tersedia
                : int.parse(v) == 2
                    ? vhcMrem.perluPerbaikan
                    : null;
      }
      //KABIN
      if (globals.rvhcKabin != null) {
        final v = globals.rvhcKabin!;
        rvhcKabin = int.parse(v) == 0
            ? vhcKabin.tidakAda
            : int.parse(v) == 1
                ? vhcKabin.tersedia
                : int.parse(v) == 2
                    ? vhcKabin.perluPerbaikan
                    : null;
      }
      if (globals.rvhcKaca != null) {
        final v = globals.rvhcKaca!;
        rvhcKaca = int.parse(v) == 0
            ? vhcKaca.tidakAda
            : int.parse(v) == 1
                ? vhcKaca.tersedia
                : int.parse(v) == 2
                    ? vhcKaca.perluPerbaikan
                    : null;
      }
      if (globals.rvhcSpion != null) {
        final v = globals.rvhcSpion!;
        rvhcSpion = int.parse(v) == 0
            ? vhcSpion.tidakAda
            : int.parse(v) == 1
                ? vhcSpion.tersedia
                : int.parse(v) == 2
                    ? vhcSpion.perluPerbaikan
                    : null;
      }
      if (globals.rvhcSpeedo != null) {
        final v = globals.rvhcSpeedo!;
        rvhcSpeedo = int.parse(v) == 0
            ? vhcSpeedo.tidakAda
            : int.parse(v) == 1
                ? vhcSpeedo.tersedia
                : int.parse(v) == 2
                    ? vhcSpeedo.perluPerbaikan
                    : null;
      }
      if (globals.rvhcWiper != null) {
        final v = globals.rvhcWiper!;
        rvhcWiper = int.parse(v) == 0
            ? vhcWiper.tidakAda
            : int.parse(v) == 1
                ? vhcWiper.tersedia
                : int.parse(v) == 2
                    ? vhcWiper.perluPerbaikan
                    : null;
      }
      if (globals.rvhcKlak != null) {
        final v = globals.rvhcKlak!;
        rvhcKlak = int.parse(v) == 0
            ? vhcKlak.tidakAda
            : int.parse(v) == 1
                ? vhcKlak.tersedia
                : int.parse(v) == 2
                    ? vhcKlak.perluPerbaikan
                    : null;
      }
      if (globals.rvhcJok != null) {
        final v = globals.rvhcJok!;
        rvhcJok = int.parse(v) == 0
            ? vhcJok.tidakAda
            : int.parse(v) == 1
                ? vhcJok.tersedia
                : int.parse(v) == 2
                    ? vhcJok.perluPerbaikan
                    : null;
      }
      if (globals.rvhcSeatBealt != null) {
        final v = globals.rvhcSeatBealt!;
        rvhcSeatBealt = int.parse(v) == 0
            ? vhcSeatBealt.tidakAda
            : int.parse(v) == 1
                ? vhcSeatBealt.tersedia
                : int.parse(v) == 2
                    ? vhcSeatBealt.perluPerbaikan
                    : null;
      }
      if (globals.rvhcApar != null) {
        final v = globals.rvhcApar!;
        rvhcApar = int.parse(v) == 0
            ? vhcApar.tidakAda
            : int.parse(v) == 1
                ? vhcApar.tersedia
                : int.parse(v) == 2
                    ? vhcApar.perluPerbaikan
                    : null;
      }
      if (globals.rvhcP3k != null) {
        final v = globals.rvhcP3k!;
        rvhcP3k = int.parse(v) == 0
            ? vhcP3k.tidakAda
            : int.parse(v) == 1
                ? vhcP3k.tersedia
                : int.parse(v) == 2
                    ? vhcP3k.perluPerbaikan
                    : null;
      }
      if (globals.rvhcCone != null) {
        final v = globals.rvhcCone!;
        rvhcCone = int.parse(v) == 0
            ? vhcCone.tidakAda
            : int.parse(v) == 1
                ? vhcCone.tersedia
                : int.parse(v) == 2
                    ? vhcCone.perluPerbaikan
                    : null;
      }

      if (globals.rvhcStikerRef != null) {
        final v = globals.rvhcStikerRef!;
        rvhcStikerRef = int.parse(v) == 0
            ? vhcStikerRef.tidakAda
            : int.parse(v) == 1
                ? vhcStikerRef.tersedia
                : int.parse(v) == 2
                    ? vhcStikerRef.perluPerbaikan
                    : null;
      }
      //ELECTRIC
      if (globals.rvhcLampd != null) {
        final v = globals.rvhcLampd!;
        rvhcLampd = int.parse(v) == 0
            ? vhcLampd.tidakAda
            : int.parse(v) == 1
                ? vhcLampd.tersedia
                : int.parse(v) == 2
                    ? vhcLampd.perluPerbaikan
                    : null;
      }
      if (globals.rvhcLamps != null) {
        final v = globals.rvhcLamps!;
        rvhcLamps = int.parse(v) == 0
            ? vhcLamps.tidakAda
            : int.parse(v) == 1
                ? vhcLamps.tersedia
                : int.parse(v) == 2
                    ? vhcLamps.perluPerbaikan
                    : null;
      }
      if (globals.rvhcLampBlk != null) {
        final v = globals.rvhcLampBlk!;
        rvhcLampBlk = int.parse(v) == 0
            ? vhcLampBlk.tidakAda
            : int.parse(v) == 1
                ? vhcLampBlk.tersedia
                : int.parse(v) == 2
                    ? vhcLampBlk.perluPerbaikan
                    : null;
      }
      if (globals.rvhcLampr != null) {
        final v = globals.rvhcLampr!;
        rvhcLampr = int.parse(v) == 0
            ? vhcLampr.tidakAda
            : int.parse(v) == 1
                ? vhcLampr.tersedia
                : int.parse(v) == 2
                    ? vhcLampr.perluPerbaikan
                    : null;
      }
      if (globals.rvhcLampm != null) {
        final v = globals.rvhcLampm!;
        rvhcLampm = int.parse(v) == 0
            ? vhcLampm.tidakAda
            : int.parse(v) == 1
                ? vhcLampm.tersedia
                : int.parse(v) == 2
                    ? vhcLampm.perluPerbaikan
                    : null;
      }
      if (globals.rvhcLampAlarm != null) {
        final v = globals.rvhcLampAlarm!;
        rvhcLampAlarm = int.parse(v) == 0
            ? vhcLampAlarm.tidakAda
            : int.parse(v) == 1
                ? vhcLampAlarm.tersedia
                : int.parse(v) == 2
                    ? vhcLampAlarm.perluPerbaikan
                    : null;
      }
      //CHASIS
      if (globals.rvhcKopling != null) {
        final v = globals.rvhcKopling!;
        rvhcKopling = int.parse(v) == 0
            ? vhcKopling.tidakAda
            : int.parse(v) == 1
                ? vhcKopling.tersedia
                : int.parse(v) == 2
                    ? vhcKopling.perluPerbaikan
                    : null;
      }
      if (globals.rvhcGardan != null) {
        final v = globals.rvhcGardan!;
        rvhcGardan = int.parse(v) == 0
            ? vhcGardan.tidakAda
            : int.parse(v) == 1
                ? vhcGardan.tersedia
                : int.parse(v) == 2
                    ? vhcGardan.perluPerbaikan
                    : null;
      }
      if (globals.rvhcParking != null) {
        final v = globals.rvhcParking!;
        rvhcParking = int.parse(v) == 0
            ? vhcParking.tidakAda
            : int.parse(v) == 1
                ? vhcParking.tersedia
                : int.parse(v) == 2
                    ? vhcParking.perluPerbaikan
                    : null;
      }
      if (globals.rvhcFoot != null) {
        final v = globals.rvhcFoot!;
        rvhcFoot = int.parse(v) == 0
            ? vhcFoot.tidakAda
            : int.parse(v) == 1
                ? vhcFoot.tersedia
                : int.parse(v) == 2
                    ? vhcFoot.perluPerbaikan
                    : null;
      }
      if (globals.rvhcBautRoda != null) {
        final v = globals.rvhcBautRoda!;
        rvhcBautRoda = int.parse(v) == 0
            ? vhcBautRoda.tidakAda
            : int.parse(v) == 1
                ? vhcBautRoda.tersedia
                : int.parse(v) == 2
                    ? vhcBautRoda.perluPerbaikan
                    : null;
      }
      if (globals.rvhcVelg != null) {
        final v = globals.rvhcVelg!;
        rvhcVelg = int.parse(v) == 0
            ? vhcVelg.tidakAda
            : int.parse(v) == 1
                ? vhcVelg.tersedia
                : int.parse(v) == 2
                    ? vhcVelg.perluPerbaikan
                    : null;
      }
      //BAN
      if (globals.rvhcBan != null) {
        final v = globals.rvhcBan!;
        rvhcBan = int.parse(v) == 0
            ? vhcBan.tidakAda
            : int.parse(v) == 1
                ? vhcBan.tersedia
                : int.parse(v) == 2
                    ? vhcBan.perluPerbaikan
                    : null;
      }
      if (globals.rvhcAngin != null) {
        final v = globals.rvhcAngin!;
        rvhcAngin = int.parse(v) == 0
            ? vhcAngin.tidakAda
            : int.parse(v) == 1
                ? vhcAngin.tersedia
                : int.parse(v) == 2
                    ? vhcAngin.perluPerbaikan
                    : null;
      }
      //PERALATAN
      if (globals.rvhcTerpal != null) {
        final v = globals.rvhcTerpal!;
        rvhcTerpal = int.parse(v) == 0
            ? vhcTerpal.tidakAda
            : int.parse(v) == 1
                ? vhcTerpal.tersedia
                : int.parse(v) == 2
                    ? vhcTerpal.perluPerbaikan
                    : null;
      }
      if (globals.rvhcWebing != null) {
        final v = globals.rvhcWebing!;
        rvhcWebing = int.parse(v) == 0
            ? vhcWebing.tidakAda
            : int.parse(v) == 1
                ? vhcWebing.tersedia
                : int.parse(v) == 2
                    ? vhcWebing.perluPerbaikan
                    : null;
      }
      if (globals.rvhcTambang != null) {
        final v = globals.rvhcTambang!;
        rvhcTambang = int.parse(v) == 0
            ? vhcTambang.tidakAda
            : int.parse(v) == 1
                ? vhcTambang.tersedia
                : int.parse(v) == 2
                    ? vhcTambang.perluPerbaikan
                    : null;
      }
      if (globals.rvhcDongkrak != null) {
        final v = globals.rvhcDongkrak!;
        rvhcDongkrak = int.parse(v) == 0
            ? vhcDongkrak.tidakAda
            : int.parse(v) == 1
                ? vhcDongkrak.tersedia
                : int.parse(v) == 2
                    ? vhcDongkrak.perluPerbaikan
                    : null;
      }
      if (globals.rvhcKRoda != null) {
        final v = globals.rvhcKRoda!;
        rvhcKRoda = int.parse(v) == 0
            ? vhcKRoda.tidakAda
            : int.parse(v) == 1
                ? vhcKRoda.tersedia
                : int.parse(v) == 2
                    ? vhcKRoda.perluPerbaikan
                    : null;
      }
      if (globals.rvhcGBan != null) {
        final v = globals.rvhcGBan!;
        rvhcGBan = int.parse(v) == 0
            ? vhcGBan.tidakAda
            : int.parse(v) == 1
                ? vhcGBan.tersedia
                : int.parse(v) == 2
                    ? vhcGBan.perluPerbaikan
                    : null;
      }
      if (globals.rvhcGps != null) {
        final v = globals.rvhcGps!;
        rvhcGps = int.parse(v) == 0
            ? vhcGps.tidakAda
            : int.parse(v) == 1
                ? vhcGps.tersedia
                : int.parse(v) == 2
                    ? vhcGps.perluPerbaikan
                    : null;
      }
      if (globals.rvhcDashCam != null) {
        final v = globals.rvhcDashCam!;
        rvhcDashCam = int.parse(v) == 0
            ? vhcDashCam.tidakAda
            : int.parse(v) == 1
                ? vhcDashCam.tersedia
                : int.parse(v) == 2
                    ? vhcDashCam.perluPerbaikan
                    : null;
      }
      //DOKUMEN
      if (globals.rvhcSurat != null) {
        final v = globals.rvhcSurat!;
        rvhcSurat = int.parse(v) == 0
            ? vhcSurat.tidakAda
            : int.parse(v) == 1
                ? vhcSurat.tersedia
                : int.parse(v) == 2
                    ? vhcSurat.perluPerbaikan
                    : null;
      }
      if (globals.rvhcKir != null) {
        final v = globals.rvhcKir!;
        rvhcKir = int.parse(v) == 0
            ? vhcKir.tidakAda
            : int.parse(v) == 1
                ? vhcKir.tersedia
                : int.parse(v) == 2
                    ? vhcKir.perluPerbaikan
                    : null;
      }
      if (globals.rvhcSim != null) {
        final v = globals.rvhcSim!;
        rvhcSim = int.parse(v) == 0
            ? vhcSim.tidakAda
            : int.parse(v) == 1
                ? vhcSim.tersedia
                : int.parse(v) == 2
                    ? vhcSim.perluPerbaikan
                    : null;
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
                    : null;
        rvhcOliMesin = index == 0
            ? vhcOliMesin.tidakAda
            : index == 1
                ? vhcOliMesin.tersedia
                : index == 2
                    ? vhcOliMesin.perluPerbaikan
                    : null;
        rvhcOliGardan = index == 0
            ? vhcOliGardan.tidakAda
            : index == 1
                ? vhcOliGardan.tersedia
                : index == 2
                    ? vhcOliGardan.perluPerbaikan
                    : null;
        rvhcOliTransmisi = index == 0
            ? vhcOliTransmisi.tidakAda
            : index == 1
                ? vhcOliTransmisi.tersedia
                : index == 2
                    ? vhcOliTransmisi.perluPerbaikan
                    : null;
        rvhcAir = index == 0
            ? vhcAir.tidakAda
            : index == 1
                ? vhcAir.tersedia
                : index == 2
                    ? vhcAir.perluPerbaikan
                    : null;
        rvhcAccu = index == 0
            ? vhcAccu.tidakAda
            : index == 1
                ? vhcAccu.tersedia
                : index == 2
                    ? vhcAccu.perluPerbaikan
                    : null;
        rvhcOLips = index == 0
            ? vhcOLips.tidakAda
            : index == 1
                ? vhcOLips.tersedia
                : index == 2
                    ? vhcOLips.perluPerbaikan
                    : null;
        rvhcMrem = index == 0
            ? vhcMrem.tidakAda
            : index == 1
                ? vhcMrem.tersedia
                : index == 2
                    ? vhcMrem.perluPerbaikan
                    : null;
      }
      if (event == "kabin") {
        rvhcKabin = index == 0
            ? vhcKabin.tidakAda
            : index == 1
                ? vhcKabin.tersedia
                : index == 2
                    ? vhcKabin.perluPerbaikan
                    : null;
        rvhcKaca = index == 0
            ? vhcKaca.tidakAda
            : index == 1
                ? vhcKaca.tersedia
                : index == 2
                    ? vhcKaca.perluPerbaikan
                    : null;
        rvhcSpion = index == 0
            ? vhcSpion.tidakAda
            : index == 1
                ? vhcSpion.tersedia
                : index == 2
                    ? vhcSpion.perluPerbaikan
                    : null;
        rvhcSpeedo = index == 0
            ? vhcSpeedo.tidakAda
            : index == 1
                ? vhcSpeedo.tersedia
                : index == 2
                    ? vhcSpeedo.perluPerbaikan
                    : null;
        rvhcWiper = index == 0
            ? vhcWiper.tidakAda
            : index == 1
                ? vhcWiper.tersedia
                : index == 2
                    ? vhcWiper.perluPerbaikan
                    : null;
        rvhcKlak = index == 0
            ? vhcKlak.tidakAda
            : index == 1
                ? vhcKlak.tersedia
                : index == 2
                    ? vhcKlak.perluPerbaikan
                    : null;
        rvhcJok = index == 0
            ? vhcJok.tidakAda
            : index == 1
                ? vhcJok.tersedia
                : index == 2
                    ? vhcJok.perluPerbaikan
                    : null;
        rvhcSeatBealt = index == 0
            ? vhcSeatBealt.tidakAda
            : index == 1
                ? vhcSeatBealt.tersedia
                : index == 2
                    ? vhcSeatBealt.perluPerbaikan
                    : null;
        rvhcApar = index == 0
            ? vhcApar.tidakAda
            : index == 1
                ? vhcApar.tersedia
                : index == 2
                    ? vhcApar.perluPerbaikan
                    : null;
        rvhcP3k = index == 0
            ? vhcP3k.tidakAda
            : index == 1
                ? vhcP3k.tersedia
                : index == 2
                    ? vhcP3k.perluPerbaikan
                    : null;
        rvhcCone = index == 0
            ? vhcCone.tidakAda
            : index == 1
                ? vhcCone.tersedia
                : index == 2
                    ? vhcCone.perluPerbaikan
                    : null;
        rvhcStikerRef = index == 0
            ? vhcStikerRef.tidakAda
            : index == 1
                ? vhcStikerRef.tersedia
                : index == 2
                    ? vhcStikerRef.perluPerbaikan
                    : null;
      }
      if (event == "electric") {
        rvhcLampd = index == 0
            ? vhcLampd.tidakAda
            : index == 1
                ? vhcLampd.tersedia
                : index == 2
                    ? vhcLampd.perluPerbaikan
                    : null;
        rvhcLamps = index == 0
            ? vhcLamps.tidakAda
            : index == 1
                ? vhcLamps.tersedia
                : index == 2
                    ? vhcLamps.perluPerbaikan
                    : null;
        rvhcLampBlk = index == 0
            ? vhcLampBlk.tidakAda
            : index == 1
                ? vhcLampBlk.tersedia
                : index == 2
                    ? vhcLampBlk.perluPerbaikan
                    : null;
        rvhcLampr = index == 0
            ? vhcLampr.tidakAda
            : index == 1
                ? vhcLampr.tersedia
                : index == 2
                    ? vhcLampr.perluPerbaikan
                    : null;
        rvhcLampm = index == 0
            ? vhcLampm.tidakAda
            : index == 1
                ? vhcLampm.tersedia
                : index == 2
                    ? vhcLampm.perluPerbaikan
                    : null;
        rvhcLampAlarm = index == 0
            ? vhcLampAlarm.tidakAda
            : index == 1
                ? vhcLampAlarm.tersedia
                : index == 2
                    ? vhcLampAlarm.perluPerbaikan
                    : null;
      }
      if (event == "chasis") {
        rvhcKopling = index == 0
            ? vhcKopling.tidakAda
            : index == 1
                ? vhcKopling.tersedia
                : index == 2
                    ? vhcKopling.perluPerbaikan
                    : null;
        rvhcGardan = index == 0
            ? vhcGardan.tidakAda
            : index == 1
                ? vhcGardan.tersedia
                : index == 2
                    ? vhcGardan.perluPerbaikan
                    : null;
        rvhcParking = index == 0
            ? vhcParking.tidakAda
            : index == 1
                ? vhcParking.tersedia
                : index == 2
                    ? vhcParking.perluPerbaikan
                    : null;
        rvhcFoot = index == 0
            ? vhcFoot.tidakAda
            : index == 1
                ? vhcFoot.tersedia
                : index == 2
                    ? vhcFoot.perluPerbaikan
                    : null;
        rvhcBautRoda = index == 0
            ? vhcBautRoda.tidakAda
            : index == 1
                ? vhcBautRoda.tersedia
                : index == 2
                    ? vhcBautRoda.perluPerbaikan
                    : null;
        rvhcVelg = index == 0
            ? vhcVelg.tidakAda
            : index == 1
                ? vhcVelg.tersedia
                : index == 2
                    ? vhcVelg.perluPerbaikan
                    : null;
      }
      if (event == "ban") {
        rvhcBan = index == 0
            ? vhcBan.tidakAda
            : index == 1
                ? vhcBan.tersedia
                : index == 2
                    ? vhcBan.perluPerbaikan
                    : null;
        rvhcAngin = index == 0
            ? vhcAngin.tidakAda
            : index == 1
                ? vhcAngin.tersedia
                : index == 2
                    ? vhcAngin.perluPerbaikan
                    : null;
      }
      if (event == "peralatan") {
        rvhcTerpal = index == 0
            ? vhcTerpal.tidakAda
            : index == 1
                ? vhcTerpal.tersedia
                : index == 2
                    ? vhcTerpal.perluPerbaikan
                    : null;
        rvhcWebing = index == 0
            ? vhcWebing.tidakAda
            : index == 1
                ? vhcWebing.tersedia
                : index == 2
                    ? vhcWebing.perluPerbaikan
                    : null;
        rvhcTambang = index == 0
            ? vhcTambang.tidakAda
            : index == 1
                ? vhcTambang.tersedia
                : index == 2
                    ? vhcTambang.perluPerbaikan
                    : null;
        rvhcDongkrak = index == 0
            ? vhcDongkrak.tidakAda
            : index == 1
                ? vhcDongkrak.tersedia
                : index == 2
                    ? vhcDongkrak.perluPerbaikan
                    : null;
        rvhcKRoda = index == 0
            ? vhcKRoda.tidakAda
            : index == 1
                ? vhcKRoda.tersedia
                : index == 2
                    ? vhcKRoda.perluPerbaikan
                    : null;
        rvhcGBan = index == 0
            ? vhcGBan.tidakAda
            : index == 1
                ? vhcGBan.tersedia
                : index == 2
                    ? vhcGBan.perluPerbaikan
                    : null;
        rvhcGps = index == 0
            ? vhcGps.tidakAda
            : index == 1
                ? vhcGps.tersedia
                : index == 2
                    ? vhcGps.perluPerbaikan
                    : null;
        rvhcDashCam = index == 0
            ? vhcDashCam.tidakAda
            : index == 1
                ? vhcDashCam.tersedia
                : index == 2
                    ? vhcDashCam.perluPerbaikan
                    : null;
      }

      if (event == "document") {
        rvhcSurat = index == 0
            ? vhcSurat.tidakAda
            : index == 1
                ? vhcSurat.tersedia
                : index == 2
                    ? vhcSurat.perluPerbaikan
                    : null;
        rvhcKir = index == 0
            ? vhcKir.tidakAda
            : index == 1
                ? vhcKir.tersedia
                : index == 2
                    ? vhcKir.perluPerbaikan
                    : null;
        rvhcSim = index == 0
            ? vhcSim.tidakAda
            : index == 1
                ? vhcSim.tersedia
                : index == 2
                    ? vhcSim.perluPerbaikan
                    : null;
      }
    });
  }

  @override
  void initState() {
    isLoadcheked();
    getTypeTruck();
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // pr = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: true);

    // pr.style(
    //   message: 'Wait...',
    //   borderRadius: 10.0,
    //   backgroundColor: Colors.white,
    //   elevation: 10.0,
    //   insetAnimCurve: Curves.easeInOut,
    //   progress: 0.0,
    //   maxProgress: 100.0,
    //   progressTextStyle: TextStyle(
    //       color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    //   messageTextStyle: TextStyle(
    //       color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    // );
    return WillPopScope(
        onWillPop: () {
          if (globals.page_inspeksi == 'new_driver') {
            ResetCheckBox();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => FrmSetKmByDriver()));
          } else if (globals.page_inspeksi == 'service') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewService()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          }
          return Future.value(false);
        },
        child: MaterialApp(
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
                  title: Text('Form Inspeksi',
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
                                              size: 20,
                                              color: Colors.redAccent),
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
                                              size: 20,
                                              color: Colors.redAccent),
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
                                              child: Text('Pengecekan Dasar',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isPengecekanDasar1,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isPengecekanDasar1 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("pengecekan-dasar", 0);
                                      //           isPengecekanDasar3 = false;
                                      //           isPengecekanDasar2 = false;
                                      //         } else {
                                      //           selectUnselect("pengecekan-dasar", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isPengecekanDasar2,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isPengecekanDasar2 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("pengecekan-dasar", 1);
                                      //           isPengecekanDasar1 = false;
                                      //           isPengecekanDasar3 = false;
                                      //         } else {
                                      //           selectUnselect("pengecekan-dasar", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isPengecekanDasar3,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isPengecekanDasar3 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("pengecekan-dasar", 2);
                                      //           isPengecekanDasar1 = false;
                                      //           isPengecekanDasar2 = false;
                                      //         } else {
                                      //           selectUnselect("pengecekan-dasar", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        setState(() => rvhcMrem = value);
                                    },
                                  )
                                ]),
                                Column(children: [
                                  Radio<vhcMrem>(
                                    value: vhcMrem.tersedia,
                                    groupValue: rvhcMrem,
                                    onChanged: (vhcMrem? value) {
                                      if (value != null)
                                        setState(() => rvhcMrem = value);
                                    },
                                  )
                                ]),
                                Column(children: [
                                  Radio<vhcMrem>(
                                    value: vhcMrem.perluPerbaikan,
                                    groupValue: rvhcMrem,
                                    onChanged: (vhcMrem? value) {
                                      if (value != null)
                                        setState(() => rvhcMrem = value);
                                    },
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        setState(() => rvhcOLips = value);
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
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isKabin1,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isKabin1 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("kabin", 0);
                                      //           isKabin3 = false;
                                      //           isKabin2 = false;
                                      //           // isElektrik1 =false;
                                      //           // isElektrik2 =false;
                                      //           // isElektrik3 =false;
                                      //           // isOthers1 =false;
                                      //           // isOthers2 =false;
                                      //           // isOthers3 =false;
                                      //           // isBan1 =false;
                                      //           // isBan2 =false;
                                      //           // isBan3 =false;
                                      //         } else {
                                      //           selectUnselect("kabin", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isKabin2,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isKabin2 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("kabin", 1);
                                      //           isKabin1 = false;
                                      //           isKabin3 = false;
                                      //           // isElektrik1 =false;
                                      //           // isElektrik2 =false;
                                      //           // isElektrik3 =false;
                                      //           // isOthers1 =false;
                                      //           // isOthers2 =false;
                                      //           // isOthers3 =false;
                                      //           // isBan1 =false;
                                      //           // isBan2 =false;
                                      //           // isBan3 =false;
                                      //         } else {
                                      //           selectUnselect("kabin", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isKabin3,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isKabin3 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("kabin", 2);
                                      //           isKabin1 = false;
                                      //           isKabin2 = false;
                                      //           // isElektrik1 =false;
                                      //           // isElektrik2 =false;
                                      //           // isElektrik3 =false;
                                      //           // isOthers1 =false;
                                      //           // isOthers2 =false;
                                      //           // isOthers3 =false;
                                      //           // isBan1 =false;
                                      //           // isBan2 =false;
                                      //           // isBan3 =false;
                                      //         } else {
                                      //           selectUnselect("kabin", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                  ]), //HEADER KABIN
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Kaca',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Spion',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Wiper',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Jok',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Apar',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' P3K',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ]),

                              ///
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
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isElektrik1,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isElektrik2,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isElektrik3,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                  ]), //HEADER ELEKTRIk
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          print(rvhcLamps?.index);
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
                                          print(rvhcLamps?.index);
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
                                          print(rvhcLamps?.index);
                                        });
                                    },
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          print(rvhcLampm?.index);
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
                                          print(rvhcLampm?.index);
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
                                          print(rvhcLampm?.index);
                                        });
                                    },
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isChasis1,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isChasis2,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isChasis3,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                  ]), //HEADER CHASIS
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Velg',
                                          style: TextStyle(fontSize: 14))
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
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isBan1,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isBan1 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("ban", 0);
                                      //           isBan2 = false;
                                      //           isBan3 = false;
                                      //         } else {
                                      //           selectUnselect("ban", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isBan2,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isBan2 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("ban", 1);
                                      //           isBan1 = false;
                                      //           isBan3 = false;
                                      //         } else {
                                      //           selectUnselect("ban", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isBan3,
                                      //     onChanged: (bool newValue) {
                                      //       setState(() {
                                      //         isBan3 = newValue;
                                      //         if (newValue == true) {
                                      //           selectUnselect("ban", 2);
                                      //           isBan1 = false;
                                      //           isBan2 = false;
                                      //         } else {
                                      //           selectUnselect("ban", -1);
                                      //         }
                                      //       });
                                      //     }),
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                  ]), //HEADER BAN
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        rvhcBan = value;
                                        print(rvhcBan?.index);
                                        print(type_truck);
                                        if (rvhcBan != null) {
                                          if (rvhcBan?.index == 2) {
                                            isFinish();
                                            if (type_truck == "TRAILLER") {
                                              //Navigator.
                                              //globals.page_inspeksi = "opr";
                                              Navigator.push(
                                                  globalScaffoldKey
                                                      .currentContext!,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewCarTRAILLER()));
                                            }
                                            if (type_truck == "TR") {
                                              //globals.page_inspeksi = "opr";
                                              Navigator.push(
                                                  globalScaffoldKey
                                                      .currentContext!,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewCarTR()));
                                            }
                                            if (type_truck == "LT") {
                                              //globals.page_inspeksi = "opr";
                                              Navigator.push(
                                                  globalScaffoldKey
                                                      .currentContext!,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          print(rvhcAngin?.index);
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
                                          print(rvhcAngin?.index);
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
                                          print(rvhcAngin?.index);
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
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isPeralatan1,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isPeralatan2,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isPeralatan3,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                  ]), //HEADDR Peralatan
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' GPS',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold)))
                                        ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isDokumen1,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.close,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isDokumen2,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.check_circle,
                                          size: 20, color: Colors.green)
                                    ]),
                                    Column(children: [
                                      // Checkbox(
                                      //     value: isDokumen3,
                                      //     onChanged: (bool newValue) {
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
                                      Icon(Icons.handyman,
                                          size: 20, color: Colors.redAccent)
                                    ]),
                                  ]), //HEADER DOKUMENT
                              TableRow(children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' STNK',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' Kir',
                                          style: TextStyle(fontSize: 14))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' SIM',
                                          style: TextStyle(fontSize: 14))
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
                        // Container(
                        //     width: double.infinity,
                        //     margin: EdgeInsets.all(10.0),
                        //
                        //     child: buildSelectTruck(context)),
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
        ));
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
    print('globals.page_inspeksi');
    print(globals.page_inspeksi);
    String messageTeks = globals.page_inspeksi == 'new_driver' ||
            globals.page_inspeksi == 'driver'
        ? "Lanjutkan ke proses antrian?"
        : "Lanjutkan ke proses service?";
    return new ElevatedButton.icon(
      icon: Icon(
        Icons.save,
        color: Colors.white,
        size: 15.0,
      ),
      label: Text(globals.page_inspeksi == "service" ? "Finish" : "Submit"),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Information'),
            content: new Text(messageTeks),
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
                  if (globals.p2hVhcid == null || globals.p2hVhcid == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Vehicle ID tidak boleh kosong", "error");
                  } else if (globals.rvhcOliMesin == null ||
                      globals.rvhcOliMesin == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli Mesin tidak boleh kosong", "error");
                  } else if (globals.rvhcOliGardan == null ||
                      globals.rvhcOliGardan == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli Gardan tidak boleh kosong", "error");
                  } else if (globals.rvhcOliTransmisi == null ||
                      globals.rvhcOliTransmisi == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Oli Transmisi tidak boleh kosong", "error");
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
                  } else if (globals.rvhcStikerRef == null ||
                      globals.rvhcStikerRef == "") {
                    alert(globalScaffoldKey.currentContext!, 0,
                        "Stiker reflektor tidak boleh kosong", "error");
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
                  } else {
                    globals.rvhcNotes = txtNotes.text;
                    EasyLoading.show();
                    if (globals.page_inspeksi == "service") {//NEXT PAGE
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewService()));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewAntrian()));
                    }
                  }
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
