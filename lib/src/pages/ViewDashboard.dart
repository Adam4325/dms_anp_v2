import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dms_anp/src/pages/marketing/ListOpenDO.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dms_anp/helpers/database_helper.dart';
import 'package:dms_anp/src/Helper/AnpService.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/constant.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/model/NotificationData.dart';
import 'package:dms_anp/src/model/banner_anp.dart';
import 'package:dms_anp/src/pages/DetailMenu.dart';
import 'package:dms_anp/src/pages/FrmAttendance.dart';
import 'package:dms_anp/src/pages/FrmAttendanceAdvance.dart';
import 'package:dms_anp/src/pages/FrmCHK.dart';
import 'package:dms_anp/src/pages/FrmCreateAntrianNewDriver.dart';
import 'package:dms_anp/src/pages/FrmPlayBack.dart';
import 'package:dms_anp/src/pages/FrmSetKmByDriver.dart';
import 'package:dms_anp/src/pages/MapAddress.dart';
import 'package:dms_anp/src/pages/MapHistory.dart';
import 'package:dms_anp/src/pages/driver/FrmStoring.dart';
import 'package:dms_anp/src/pages/driver/ListDriverInspeksi.dart';
import 'package:dms_anp/src/pages/driver/RegistrasiNewDriver.dart';
import 'package:dms_anp/src/pages/ViewListDo.dart';
import 'package:dms_anp/src/pages/ViewListDoOpr.dart';
import 'package:dms_anp/src/pages/ViewListRitase.dart';
import 'package:dms_anp/src/pages/ViewPelanggaran.dart';
import 'package:dms_anp/src/pages/ViewProfileUser.dart';
import 'package:dms_anp/src/pages/hrd/ApvRewards.dart';
import 'package:dms_anp/src/pages/hrd/ListAbsensiKaryawanV1.dart';
import 'package:dms_anp/src/pages/hrd/frmAssset.dart';
import 'package:dms_anp/src/pages/inventory/FrmWareHouseOpName.dart';
import 'package:dms_anp/src/pages/inventory/ListInventoryTransNew.dart';
import 'package:dms_anp/src/pages/maintenance/FrmServiceRequestTms.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
import 'package:dms_anp/src/pages/mekanik/DailyMekanikCheckScreenP2H.dart';
import 'package:dms_anp/src/pages/pie_chart_sample2.dart';
import 'package:dms_anp/src/pages/po/PoHeaderPage.dart';
import 'package:dms_anp/src/pages/tuker_point/RewardTabsPage.dart';
import 'package:dms_anp/src/pages/vehicle/FrmRequestMovingUnits.dart';
import 'package:dms_anp/src/pages/vehicle/ViewPhotoVehicle.dart';
import 'package:dms_anp/src/services/NotificationServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:local_auth/local_auth.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// qrscan deprecated - using mobile_scanner; scan stubbed until integrated
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:unique_identifier/unique_identifier.dart';
import '../../helpers/GpsSecurityChecker.dart';

import '../flusbar.dart';
import 'FrmAttendanceDriver.dart';
import 'FrmMasterData.dart';
import 'FrmNonTera.dart';
import 'LiveMaps.dart';
import 'ViewListStoring.dart';
import 'driver/ApprovedDriverRequest.dart';
import 'driver/FrmApprovalReqDriver.dart';
import 'driver/ListDriverInspeksiV2.dart';
import 'maintenance/FrmServiceRequestOprPM.dart';
import 'maintenance/FrmServiceTire.dart';
import 'maintenance/ViewListWoMcByForeMan.dart';
import 'marketing/ListOpenDOMP.dart';
import 'mekanik/ListMekanikInspeksiV2.dart';

class ViewDashboard extends StatefulWidget {
  @override
  _ViewDashboardState createState() => _ViewDashboardState();
}

class _ViewDashboardState extends State<ViewDashboard> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationData> _notifications = [];
  StreamSubscription<List<NotificationData>>? _notificationSubscription;
  bool _isDialogShowing = false;
  Set<String> _shownNotificationIds = {};
  Timer? _dialogDebounceTimer;
  bool isMenuForeman = false;
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  Timer? timer;
  String _identifier = '';
  List<AnpService> _anpServiceList = [];

  // ✅ ADDED: Variables untuk menu management
  List<AnpService> _mainMenuList = []; // Menu utama (max 8)
  List<AnpService> _additionalMenuList = []; // Menu tambahan
  static const int MAX_MAIN_MENU = 7; // 7 menu + 1 "More" = 8 total

  List<BannerBottom> _bannerList = [];
  List<DetailInfo> _detailInfo = [];
  List data = [];
  List pointDetails = [];
  SharedPreferences? sharedPreferences;
  String spLoginName = '';
  String loginname = '';
  String login_type = '';
  String ismixer = '';
  String vhcid = '';
  String vhckm = '';
  String vhcnopol = '';
  String locid = '';
  String firstName = '';
  String username = '';
  String cpyid = '';
  String cpyname = '';
  String scanResult = '';
  String simType = '';
  String expireSIM = '';
  String hadir = "";
  String sakit = "";
  String izin = "";
  String cuti = "";
  String storing = "";
  String vhcid_units = '';
  String _message_notif = "Belum ada notifikasi";

  final auth = LocalAuthentication();
  String authorized = " not authorized";
  bool _canCheckBiometric = false;
  List<BiometricType> _availableBiometric = [];
  ProgressDialog? pr;
  var selectedIndexBottom = 0;
  var countNotif = 0;
  int pageIndex = 0;
  bool extended = true;
  List<dynamic> data_list_do = [];
  var status_unit = '';
  int points = 0;

  // ✅ ADDED: Orange Soft Color Scheme
  static const Color primaryOrange = Color(0xFFFF8A50);
  static const Color lightOrange = Color(0xFFFFB085);
  static const Color paleOrange = Color(0xFFFFF0E6);
  static const Color darkOrange = Color(0xFFE65100);
  static const Color accentOrange = Color(0xFFFF7043);

  Future<void> initUniqueIdentifierState() async {
    String? identifier;
    try {
      identifier = await UniqueIdentifier.serial;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("androidID", identifier!);
    } catch (latformException) {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;

    setState(() {
      _identifier = identifier!;
    });
  }

  Future scanQRCode() async {
    // TODO: Integrate mobile_scanner - qrscan deprecated
    String? cameraScanResult = null;
    setState(() {
      scanResult = cameraScanResult ?? '';
      if (scanResult.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: new Text('Information'),
            content: new Text(
                "ITEM ID ${scanResult}, proses lanjut, untuk penginputan?"),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.0),
                label: Text("Ok"),
                onPressed: () async {
                  print('Clicked');
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    });
  }

  Future getDataPreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setString("lat_lon", "");
      isMenuForeman =
          sharedPreferences!.getString("isMenuForeman") == "1" ? true : false;
      globals.akses_pages = sharedPreferences!.getStringList("akses_pages") ?? [];
      print(globals.akses_pages);
      username = sharedPreferences!.getString("username") ?? '';
      loginname = sharedPreferences!.getString("loginname") ?? '';
      login_type = sharedPreferences!.getString("login_type") ?? '';

      ismixer = sharedPreferences!.getString("ismixer") ?? 'false';

      vhcid = sharedPreferences!.getString("vhcid") ?? '';
      vhckm = sharedPreferences!.getString("vhckm") ?? '';
      vhcnopol = sharedPreferences!.getString("vhcnopol") ?? '';
      locid = sharedPreferences!.getString("locid") ?? '';
      print("loginname ${loginname}");
      print(locid);
      firstName = sharedPreferences!.getString("name") ?? '';
      cpyid = sharedPreferences!.getString("cpyid") ?? '';
      cpyname = sharedPreferences!.getString("cpyname") ?? '';
      sharedPreferences!.setString("page", "dashboard");

      if (loginname != null && loginname != "") {
        if (loginname == "DRIVER") {
          cekDetailInfo("status_unit");
          cekDetailInfo("sim");
          cekDetailInfo("stnk");
          cekDetailInfo("kir");
          fetchPoints();
        }
        if (loginname == "MECHANIC") {
          print('status_mc_out_standing ${loginname}');
          cekDetailInfoMECHANIC("status_mc_out_standing");
        }

        _anpServiceList.clear();
        _setupMenuItems();
        _setupBannerItems();
      }
    });
  }

  void _setupMenuItems() {
    _anpServiceList.add(new AnpService(
        image: loginname == "DRIVER" ? Icons.location_on : Icons.location_on,
        color: AnpPalette.menuRide,
        idKey: 1,
        title: loginname == "DRIVER" ? "Maps" : "Maps"));

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
              .where((x) => (x == "OP" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.play_arrow,
              color: Colors.red,
              idKey: 22,
              title: "Playback"));
        }
      }
    }

    _anpServiceList.add(new AnpService(
        image: Icons.add_chart,
        color: AnpPalette.menuCar,
        idKey: 2,
        title: "Do Diterima"));

    _anpServiceList.add(new AnpService(
        image: Icons.closed_caption,
        color: AnpPalette.menuBluebird,
        idKey: 3,
        title: "Close Do"));

    _anpServiceList.add(new AnpService(
        image: Icons.bubble_chart,
        color: AnpPalette.menuFood,
        idKey: 4,
        title: "Ritase"));

    _anpServiceList.add(new AnpService(
        image: (loginname == 'DRIVER'
            ? Icons.drive_eta_rounded
            : Icons.electric_car_outlined),
        color: AnpPalette.menuDeals,
        idKey: 5,
        title: (loginname == 'DRIVER' ? "Antrian" : "New Driver")));

    _anpServiceList.add(new AnpService(
        image: Icons.bar_chart,
        color: AnpPalette.menuPulsa,
        idKey: 6,
        title: "Perform"));

    _anpServiceList.add(new AnpService(
        image: Icons.alarm_on,
        color: AnpPalette.menuDeals,
        idKey: 7,
        title: "Violation"));

    _anpServiceList.add(new AnpService(
        image: Icons.queue,
        color: AnpPalette.menuSend,
        idKey: 8,
        title: "Others"));

    if (username == "ADMIN" ||
        username == "NURIZKI" ||
        ismixer == "true" ||
        getAkses("OP")) {
      _anpServiceList.add(new AnpService(
          image: Icons.work_outlined,
          color: Colors.red,
          idKey: 23,
          title: "P2H"));
    }

    if (loginname != "DRIVER") {
      _anpServiceList.add(new AnpService(
          image: Icons.work_outlined,
          color: Colors.red,
          idKey: 24,
          title: "P2H Tools"));
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) =>
              (x == "OP" || x == "MT" || username == "ADMIN") && x != "MK");
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.car_repair,
              color: Colors.red,
              idKey: 11,
              title: "Moving Unit"));
        }
      }
    }

    if (loginname != "DRIVER") {
      _anpServiceList.add(new AnpService(
          image: Icons.home_repair_service_outlined,
          color: Colors.red,
          idKey: 12,
          title: "SR"));
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) =>
      (x == "IN" || x == "TY" || username == "ADMIN"));
      if(isOK!=null){
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.donut_large,
              color: Colors.red,
              idKey: 31,
              title: "Tyre"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) =>
      (x == "IN" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.today_outlined,
              color: Colors.red,
              idKey: 14,
              title: "Inventory")); //INI
        }
      }
    }

    if (loginname != "DRIVER") {
      _anpServiceList.add(new AnpService(
          image: Icons.fingerprint,
          color: Colors.red,
          idKey: 15,
          title: "Absensi"));
    }

    if (loginname == "DRIVER") {
      _anpServiceList.add(new AnpService(
          image: Icons.fingerprint,
          color: Colors.red,
          idKey: 15,
          title: "Absensi"));
    }

    if (loginname != "DRIVER") {
      _anpServiceList.add(new AnpService(
          image: Icons.fingerprint_rounded,
          color: Colors.green,
          idKey: 20,
          title: "Absen ADV"));
    }


    // if (username == "ADMIN" || isMenuForeman == true) {
    //
    // }

    var isOK2 = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) =>
    (x == "IN" || username == "ADMIN" || isMenuForeman == true));
    if (isOK2 != null) {
      if (isOK2.length > 0) {
        print("isMenuForeman");
        print(isMenuForeman);
        _anpServiceList.add(new AnpService(
            image: Icons.inventory,
            color: Colors.green,
            idKey: 27,
            title: "Inv. Foreman"));
      }
    }

    if(isMenuForeman == true){
      _anpServiceList.add(new AnpService(
          image: Icons.inventory,
          color: Colors.green,
          idKey: 27,
          title: "Inv. Foreman"));
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) =>
              (x == "OP" || x == "MT" || username == "ADMIN") && x != "MK");
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.web_asset,
              color: Colors.red,
              idKey: 16,
              title: "Edp/Aset"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) =>
              (x == "IN" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.room_preferences,
              color: Colors.red,
              idKey: 17,
              title: "WH. Opname"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
              .where((x) => (x == "OP" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.credit_card,
              color: Colors.red,
              idKey: 21,
              title: "Non-Tera"));
        }
      }
    }

    if (loginname == "DRIVER") {
      _anpServiceList.add(new AnpService(
          image: Icons.handyman,
          color: Colors.red,
          idKey: 19,
          title: "Storing"));
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
              .where((x) => (x == "PO" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.point_of_sale,
              color: Colors.red,
              idKey: 25,
              title: "PO"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
              .where((x) => (x == "OP" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.person_outline,
              color: Colors.red,
              idKey: 28,
              title: "Req. Driver"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
              .where((x) => (x == "OP" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: Icons.card_giftcard,
              color: Colors.red,
              idKey: 29,
              title: "Apv. Reward"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
          .where((x) => (x == "OP" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: FontAwesomeIcons.delicious,
              color: Colors.red,
              idKey: 30,
              title: "Open DO MP"));
        }
      }
    }
    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
          .where((x) => (x == "OP" || username == "ADMIN"));
      if (isOK != null) {
        if (isOK.length > 0) {
          _anpServiceList.add(new AnpService(
              image: FontAwesomeIcons.delicious,
              color: Colors.red,
              idKey: 33,
              title: "Open DO NC"));
        }
      }
    }

    if (loginname != "DRIVER") {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages
              .where((x) => (x == "MK" || username == "ADMIN"));
      if (isOK != null && isOK.length > 0) {
        _anpServiceList.add(new AnpService(
            image: Icons.storage,
            color: Colors.blue.shade700,
            idKey: 32,
            title: "Mst Data"));
      }
    }

    // ✅ ADDED: Pisahkan menu untuk ADMIN/OP
    _organizeMenus();
  }

  // ✅ ADDED: Function untuk memisahkan menu utama dan tambahan
  void _organizeMenus() {
    _mainMenuList.clear();
    _additionalMenuList.clear();

    // Cek apakah user adalah ADMIN atau memiliki akses OP
    bool isAdminOrOp = (username == "ADMIN" || getAkses("OP"));

    if (isAdminOrOp && _anpServiceList.length > MAX_MAIN_MENU) {
      // Jika ADMIN/OP dan menu lebih dari 7, pisahkan
      _mainMenuList = _anpServiceList.take(MAX_MAIN_MENU).toList();
      _additionalMenuList = _anpServiceList.skip(MAX_MAIN_MENU).toList();

      // Tambahkan menu "More"
      _mainMenuList.add(new AnpService(
          image: Icons.more_horiz,
          color: Colors.grey.shade600,
          idKey: 999, // Special ID untuk More
          title: "More"));
    } else {
      // Jika bukan ADMIN/OP atau menu tidak lebih dari 7, tampilkan semua
      _mainMenuList = _anpServiceList;
    }
  }

  void _setupBannerItems() {
    _bannerList.add(
        new BannerBottom(title: "Banner 1", image: "assets/img/banner1.jpg"));
    _bannerList.add(
        new BannerBottom(title: "Banner 2", image: "assets/img/banner2.jpg"));
    _bannerList.add(
        new BannerBottom(title: "Banner 3", image: "assets/img/banner3.jpg"));
    _bannerList.add(
        new BannerBottom(title: "Banner 1", image: "assets/img/banner1.jpg"));
    _bannerList.add(
        new BannerBottom(title: "Banner 2", image: "assets/img/banner2.jpg"));
  }

  Future<String> GetVhcidDo() async {
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      sharedPreferences = await SharedPreferences.getInstance();
      String drvid = sharedPreferences!.getString("drvid") ?? '';
      var resVhcid = "";
      var vDo = sharedPreferences!.getString("vhcidfromdo") ?? '';
      if (vDo == null || vDo == "") {
        var urlData =
            "${GlobalData.baseUrlProd}api/log_receive_do.jsp?method=vehicle-log&drvid=" +
                drvid;
        Uri myUri = Uri.parse(urlData);
        print(myUri.toString());
        var response =
            await http.get(myUri, headers: {"Accept": "application/json"});
        setState(() {
          if (response.statusCode == 200) {
            var result = json.decode(response.body)[0];
            print(result['vhcid']);
            resVhcid = result['vhcid']?.toString() ?? '';
            sharedPreferences!.setString("vhcidfromdo", resVhcid);
          }
        });
      }
      return resVhcid;
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future GetCountStoring() async {
    try {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "OP");
      bool isValid = false;
      if (isOK != null) {
        if (isOK.length > 0) {
          isValid = true;
        }
      }
      if (username == "ADMIN") {
        isValid = true;
      }
      print('isvalid ${isValid} ${username}');
      if (isValid) {
        var urlData =
            "${GlobalData.baseUrlProd}api/list_storing.jsp?method=count-data-storing";
        Uri myUri = Uri.parse(urlData);
        print(myUri.toString());
        var response =
            await http.get(myUri, headers: {"Accept": "application/json"});
        if (response.statusCode == 200) {
          var result = json.decode(response.body);
          print(result['total']);
          setState(() {
            countNotif =
                result['total'] == null ? 0 : int.parse(result['total']);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future GetAbsensiSummary() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String imeiid = prefs.getString("androidID") ?? '';
      var urlData =
          "${GlobalData.baseUrlProd}api/absensi/list_total_absensi.jsp?method=list_absensi&imeiid=${imeiid}";
      var encoded = Uri.encodeFull(urlData);
      Uri myUris = Uri.parse(encoded);
      var responses =
          await http.get(myUris, headers: {"Accept": "application/json"});
      print(responses);
      if (responses.statusCode == 200) {
        var result = json.decode(responses.body);
        setState(() {
          hadir = result['hadir'] == null ? "0" : result['hadir'];
          sakit = result['sakit'] == null ? "0" : result['sakit'];
          izin = result['izin'] == null ? "0" : result['izin'];
          cuti = result['cuti'] == null ? "0" : result['cuti'];
          storing = result['storing'] == null ? "0" : result['storing'];
          print('Hadir');
        });
      }
    } catch (e) {
      print('Error');
      print(e);
    }
  }

  Future<String> cekDetailInfoMECHANIC(String method) async {
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      sharedPreferences = await SharedPreferences.getInstance();
      String vhcid = sharedPreferences!.getString("vhcid") ?? '';
      String drvid = sharedPreferences!.getString("drvid") ?? '';
      String mechanicid = sharedPreferences!.getString("mechanicid") ?? '';

      print('mechanicid ${mechanicid}');
      var urlData = "";
      if (method == "status_mc_out_standing") {
        urlData =
            "${GlobalData.baseUrlProd}api/detail_info.jsp?method=status_mc_out_standing&mcid=" +
                mechanicid;
        print(urlData);
      }
      Uri myUri = Uri.parse(urlData);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        var result = _decoder.convert(response.body);
        print(result);
        if (result['status_code'] == '200') {
          print('status code ${result['status_code']}');
          if (method == "status_mc_out_standing") {
            data.add({
              "name": "status_unit",
              "from": "",
              "to": "",
              "status": result['status'],
              "nopol": result['nopol'],
            });
          } else {
            var from = result['from'] == null ? '' : result['from'];
            var to = result['to'] == null ? '' : result['to'];
            data.add({
              "name": method,
              "from": from,
              "to": to,
              "status": "",
              "nopol": ""
            });
          }
          print("data ${data}");
        }
      });
    } catch (e) {
      print(e);
    }
    return "Successfull";
  }

  Future<String> cekDetailInfo(String method) async {
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      sharedPreferences = await SharedPreferences.getInstance();
      String vhcid = sharedPreferences!.getString("vhcid") ?? '';
      String drvid = sharedPreferences!.getString("drvid") ?? '';
      var urlData = "";
      if (method == "status_unit") {
        urlData =
            "${GlobalData.baseUrlProd}api/detail_info.jsp?method=status_unit_new&vhcid=" +
                vhcid +
                "&drvid=" +
                drvid;
        print(urlData);
      } else if (method == "sim") {
        urlData =
            "${GlobalData.baseUrlProd}api/detail_info.jsp?method=sim&drvid=" +
                drvid +
                "&drvid=" +
                drvid;
      } else if (method == "stnk") {
        urlData =
            "${GlobalData.baseUrlProd}api/detail_info.jsp?method=stnk&vhcid=" +
                vhcid +
                "&drvid=" +
                drvid;
      } else if (method == "kir") {
        urlData =
            "${GlobalData.baseUrlProd}api/detail_info.jsp?method=kir&vhcid=" +
                vhcid +
                "&drvid=" +
                drvid;
      }
      Uri myUri = Uri.parse(urlData);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        var result = _decoder.convert(response.body);
        print(result);
        if (result['status_code'] == '200') {
          if (method == "status_unit") {
            data.add({
              "name": "status_unit",
              "from": "",
              "to": "",
              "status": result['status'],
              "nopol": result['nopol'],
            });
          } else {
            var from = result['from'] == null ? '' : result['from'];
            var to = result['to'] == null ? '' : result['to'];
            data.add({
              "name": method,
              "from": from,
              "to": to,
              "status": "",
              "nopol": ""
            });
          }
        }
      });
    } catch (e) {
      print(e);
    }
    return "Successfull";
  }

  Future<String> cekIsActiveUser() async {
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      sharedPreferences = await SharedPreferences.getInstance();

      Uri myUri = Uri.parse(
          "${GlobalData.baseUrlProd}api/is_sign.jsp?method=is_sign&username=" +
              username);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        var result = _decoder.convert(response.body);
        if (result['status_code'] == '200') {
          if (result['is_active'].toString().toLowerCase() != 'act' &&
              result['is_active'].toString().toLowerCase() != 'active') {
            showMyDialog();
          } else {
            print(result['is_active']);
          }
        }
      });
    } catch (e) {
      print(e);
    }
    return "Successfull";
  }

  void showMyDialog() {
    final ctx = globalScaffoldKey.currentContext!;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: new Text('Authorize'),
        content: new Text('Username is not active'),
        actions: <Widget>[
          new TextButton(
            onPressed: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: new Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> saveDriverTokenToFirebase(String tokens) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String method = 'driver-token';
    final String vhcid = prefs.getString('vhcid') ?? '';
    final String drvid = prefs.getString('drvid') ?? '';
    final String token = tokens;

    final Uri url = Uri.parse(
            'https://apps.tuluatas.com/trucking/mobile/api/firebase/save_token.jsp')
        .replace(
      queryParameters: {
        'method': method,
        'drvid': drvid,
        'vhcid': vhcid,
        'token': token
      },
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData');
        if (responseData['success'] == true) {
          print('Token berhasil diperbarui: ${responseData['message']}');
        } else {
          print('Gagal: ${responseData['message']}');
        }
      } else {
        print('Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi error: $e');
    }
  }

  void _setupNotifications() {
    print('🔍 DEBUG: Setting up notifications in ViewDashboard...');
    _notificationSubscription?.cancel();
    _dialogDebounceTimer?.cancel();
    _notificationService.resetService();

    _notificationSubscription = _notificationService.notificationStream.listen(
      (notifications) {
        print(
            '🔍 DEBUG: Stream received ${notifications.length} notifications');
        setState(() {
          _notifications = notifications;
        });
        if (notifications.isNotEmpty && !_isDialogShowing) {
          _dialogDebounceTimer?.cancel();
          _dialogDebounceTimer = Timer(Duration(milliseconds: 500), () {
            _showLatestNotification(notifications);
          });
        }
      },
      onError: (error) {
        print('❌ ERROR: Stream error: $error');
      },
      onDone: () {
        print('🔍 DEBUG: Stream done');
      },
    );

    _notificationService.startNotificationTimer(intervalSeconds: 30);
    print('🔍 DEBUG: Notification setup completed');
  }

  void _showLatestNotification(List<NotificationData> notifications) {
    if (!mounted || context == null || _isDialogShowing) return;

    NotificationData? newNotification;
    for (var notification in notifications) {
      if (!_shownNotificationIds.contains(notification.id)) {
        newNotification = notification;
        break;
      }
    }

    if (newNotification != null) {
      print('🔍 DEBUG: Showing new notification: ${newNotification.id}');
      _shownNotificationIds.add(newNotification.id);
      _showNotificationDialog(newNotification);
    }
  }

  void _showNotificationDialog(NotificationData notification) {
    print(
        '🔍 DEBUG: Attempting to show notification dialog for ID: ${notification.id}');

    if (_isDialogShowing) {
      print('⚠️ WARNING: Dialog already showing, skipping...');
      return;
    }

    if (!mounted || context == null) {
      print('❌ ERROR: Context not available for dialog');
      return;
    }

    _isDialogShowing = true;

    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.assignment, color: primaryOrange, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'P2H Notification',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.p2hnumber ?? 'P2H Number',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        notification.note_verifikasi ?? 'Tidak ada catatan',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Driver: ${notification.drvid}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _isDialogShowing = false;
                },
                child: Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _isDialogShowing = false;
                  _handleNotificationTap(notification);
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Tandai Dibaca'),
              ),
            ],
          );
        },
      ).then((_) {
        _isDialogShowing = false;
      });

      print('✅ SUCCESS: Dialog shown successfully');
    } catch (e) {
      print('❌ ERROR: Failed to show dialog: $e');
      _isDialogShowing = false;
    }
  }

  void _handleNotificationTap(NotificationData notification) async {
    print('🔍 DEBUG: Handling notification tap for: ${notification.id}');
    try {
      await _notificationService.sendNotificationResponse(notification);
      _notificationService.removeNotification(notification.id);
      print('✅ SUCCESS: Notification handled successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi telah ditandai sebagai dibaca'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print('❌ ERROR: Exception in _handleNotificationTap: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    getDataPreference();
    GetAbsensiSummary();
    cekIsActiveUser();
    GetCountStoring();
    initUniqueIdentifierState();
    _checkBiometric();
    _getAvailableBiometric();
    GetListDo();
    //print('widget_isMenuForeman ${widget.widget_isMenuForeman}');
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        _setupNotifications();
      }
    });

    timer =
        Timer.periodic(Duration(seconds: 5), (Timer t) => GetCountStoring());
  }

  @override
  void dispose() {
    print('🔍 DEBUG: ViewDashboard dispose called');
    _notificationSubscription?.cancel();
    timer?.cancel();
    _dialogDebounceTimer?.cancel();
    _isDialogShowing = false;
    _shownNotificationIds.clear();
    _notificationService.dispose();
    super.dispose();
  }

  Future<void> fetchPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var driverId = prefs.getString('drvid') ?? '';
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/list_point_driver.jsp?method=get-points&drvid=${driverId}');
    print('Points driver ${url}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status_code'] == "200") {
          setState(() {
            points = data['jumlah'];
          });
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> fetchPointsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var driverId = prefs.getString('drvid') ?? '';
    final url = Uri.parse(
        '${GlobalData.baseUrl}api/list_point_driver.jsp?method=get-list-points&drvid=${driverId}');
    print('Points driver ${url}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          pointDetails = data;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryOrange,
            accentOrange
          ], // ✅ UPDATED: Orange soft gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  firstName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      loginname ?? 'Role',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    // ✅ ADDED: Badge untuk ADMIN/OP
                    if (username == "ADMIN" || getAkses("OP")) ...[
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          username == "ADMIN" ? "ADMIN" : "OP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (loginname == 'DRIVER') ...[
            GestureDetector(
              onTap: _showPointsDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.yellow.shade300, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${points}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationBanner() {
    if (_notifications.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications, color: primaryOrange, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi Baru',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkOrange,
                  ),
                ),
                Text(
                  '${_notifications.length} notifikasi menunggu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showNotificationList,
            child: Text(
              'Lihat',
              style: TextStyle(color: darkOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuGrid(),
          SizedBox(height: 16),
          if (login_type!="MIXER" && loginname == 'DRIVER' && data_list_do.isNotEmpty) ...[
            _buildScheduleCard(),
            SizedBox(height: 16),
          ] else if (login_type=="MIXER" && loginname == 'DRIVER' && data_list_do.isNotEmpty) ...[
            _buildScheduleCardMixer(),
            SizedBox(height: 16),
          ],
          _buildInfoCards(),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      primaryOrange.withOpacity(0.1), // ✅ UPDATED: Orange theme
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.apps,
                    color: primaryOrange, size: 20), // ✅ UPDATED: Orange theme
              ),
              SizedBox(width: 12),
              Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Spacer(),
              // ✅ ADDED: Indicator untuk menu tambahan
              if (_additionalMenuList.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${_additionalMenuList.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: darkOrange,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _mainMenuList.length,
            itemBuilder: (context, index) {
              return _buildMenuCard(_mainMenuList[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(AnpService service) {
    // ✅ UPDATED: Special styling untuk menu "More"
    bool isMoreMenu = service.idKey == 999;

    return GestureDetector(
      onTap: () => _handleMenuTap(service),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMoreMenu
                ? primaryOrange.withOpacity(0.5)
                : Colors.grey.shade200,
            width: isMoreMenu ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isMoreMenu
                  ? primaryOrange.withOpacity(0.2)
                  : Colors.grey.shade100,
              blurRadius: isMoreMenu ? 8 : 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (service.color ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Icon(
                    service.image,
                    color: service.color,
                    size: 22,
                  ),
                  // ✅ ADDED: Badge untuk menu "More"
                  if (isMoreMenu && _additionalMenuList.isNotEmpty)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          _additionalMenuList.length.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              service.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isMoreMenu ? FontWeight.bold : FontWeight.w600,
                color: isMoreMenu ? darkOrange : Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADDED: Function untuk menampilkan menu tambahan
  void _showMoreMenuModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, darkOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.apps, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Menu Tambahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_additionalMenuList.length} Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Menu Grid
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: _additionalMenuList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu,
                                size: 64, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada menu tambahan',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _additionalMenuList.length,
                        itemBuilder: (context, index) {
                          return _buildAdditionalMenuCard(
                              _additionalMenuList[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalMenuCard(AnpService service) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close modal
        _handleMenuTap(service); // Handle menu action
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryOrange.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (service.color ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                service.image,
                color: service.color,
                size: 22,
              ),
            ),
            SizedBox(height: 8),
            Text(
              service.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.schedule, color: Colors.green, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Jadwal Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  extended ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    extended = !extended;
                  });
                },
              ),
            ],
          ),
          if (extended) ...[
            SizedBox(height: 16),
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: data_list_do.length,
                itemBuilder: (context, index) {
                  final item = data_list_do[index];
                  return _buildScheduleItem(item); //HISTORY
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCardMixer() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.schedule, color: Colors.green, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Jadwal Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  extended ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    extended = !extended;
                  });
                },
              ),
            ],
          ),
          if (extended) ...[
            SizedBox(height: 16),
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: data_list_do.length,
                itemBuilder: (context, index) {
                  final item = data_list_do[index];
                  return _buildScheduleItemMixer(item); //HISTORY
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleItem(dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item['do_number'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Text(
                item['tgl_do'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'From: ${item['origin'] ?? ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          Text(
            'To: ${item['destination'] ?? ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleScheduleAction(item),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    item['incustomer'].toString() == "1"
                        ? "Terima DO"
                        : "Close DO",
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _viewHistory(item),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItemMixer(dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item['do_number'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Text(
                item['tgl_do'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'From: ${item['origin'] ?? ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          Text(
            'To: ${item['destination'] ?? ''}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleScheduleActionMixer(item),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    item['status_do_mixer'].toString() == "INLOADING"
                        ? "OUTLOADING"
                        : item['status_do_mixer'].toString() == "OUTLOADING"
                            ? "OUTPOOL"
                            : item['status_do_mixer'].toString() == "OUTPOOL"
                                ? "INCUSTOMER"
                                : item['status_do_mixer'].toString() ==
                                        "INCUSTOMER"
                                    ? "OUTUNLOADING"
                                    : item['status_do_mixer'].toString() ==
                                            "OUTUNLOADING"
                                        ? "Close DO"
                                        : "Close DO",
                    style: TextStyle(fontSize: 11,color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _viewHistory(item),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: 11,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      primaryOrange.withOpacity(0.1), // ✅ UPDATED: Orange theme
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline,
                    color: primaryOrange, size: 20), // ✅ UPDATED: Orange theme
              ),
              SizedBox(width: 12),
              Text(
                'Informasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoContent(),
        ],
      ),
    );
  }

  Widget _buildInfoContent() {
    if (loginname == "DRIVER") {
      return _buildDriverInfo();
    } else {
      return _buildStaffInfo();
    }
  }

  Widget _buildDriverInfo() {
    var fromKir = '';
    var toKir = '';
    var fromSTNK = '';
    var toSTNK = '';
    var fromSIM = '';
    var toSIM = '';
    print("Detail info");
    print(data);
    for (var i = 0; i < data.length; i++) {
      if (data[i]['name'] != null) {
        if (data[i]['name'] == 'status_unit') {
          // Antisipasi jika 'nopol' null agar tidak melempar type 'Null' is not a subtype of type 'String'
          vhcid_units = data[i]['nopol']?.toString() ?? '';
          var nopol = data[i]['nopol'] == null ? "" : data[i]['nopol'] + " ";
          status_unit = data[i]['status'] == null
              ? ''
              : nopol + data[i]['status'].toString().toUpperCase();
        } else if (data[i]['name'] == 'sim') {
          fromSIM = data[i]['from'] == null
              ? ''
              : data[i]['from'].toString().toUpperCase();
          toSIM = data[i]['to'] == null
              ? ''
              : data[i]['to'].toString().toUpperCase();
        } else if (data[i]['name'] == 'stnk') {
          fromSTNK = data[i]['from'] == null
              ? ''
              : data[i]['from'].toString().toUpperCase();
          toSTNK = data[i]['to'] == null
              ? ''
              : data[i]['to'].toString().toUpperCase();
        } else if (data[i]['name'] == 'kir') {
          fromKir = data[i]['from'] == null
              ? ''
              : data[i]['from'].toString().toUpperCase();
          toKir = data[i]['to'] == null
              ? ''
              : data[i]['to'].toString().toUpperCase();
        }
      }
    }

    return Column(
      children: [
        _buildInfoItem(Icons.directions_car, 'Status Unit/QR Pertamina',
            status_unit, primaryOrange, // ✅ UPDATED: Orange theme
            onTap: () => _navigateToPhotoUnits("STATUS_UNIT", vhcid_units)),
        _buildInfoItem(
            Icons.card_membership, 'SIM', '${fromSIM}-${toSIM}', Colors.green,
            onTap: () => _navigateToPhoto("SIM")),
        _buildInfoItem(Icons.assignment, 'STNK', '${fromSTNK}-${toSTNK}',
            accentOrange, // ✅ UPDATED: Orange theme
            onTap: () => _navigateToPhoto("STNK")),
        _buildInfoItem(
            Icons.confirmation_number, 'KIR', '${fromKir}-${toKir}', Colors.red,
            onTap: () => _navigateToPhoto("KIR")),
        _buildInfoItem(Icons.family_restroom, 'Foto Keluarga',
            'Tap untuk lihat', Colors.purple,
            onTap: () => _navigateToPhoto("FAMILY")),
        _buildInfoItem(Icons.home, 'Domisili', 'Tap untuk lihat', Colors.indigo,
            onTap: () => _navigateToPhoto("DOMISILI")),
      ],
    );
  }
  //ERRO

  Widget _buildStaffInfo() {
    var out_standing_jobs = "0";
    if (loginname == "MECHANIC") {
      for (var i = 0; i < data.length; i++) {
        if (data[i]['status'] != null && data[i]['status'] != 'null') {
          out_standing_jobs = data[i]['status'];
        }
      }
    }

    return Column(
      children: [
        if (loginname == "MECHANIC")
          _buildInfoItem(Icons.handyman, 'Outstanding Jobs', out_standing_jobs,
              primaryOrange, // ✅ UPDATED: Orange theme
              onTap: () => _navigateToWoMCN()),
        _buildInfoItem(Icons.work, 'Storing', storing, primaryOrange,
            onTap: () => _navigateToListAbsensi('storing')),
        _buildInfoItem(Icons.check_circle, 'Hadir', hadir, Colors.green,
            onTap: () => _navigateToListAbsensi('hadir')),
        _buildInfoItem(Icons.sick, 'Sakit', sakit, Colors.red,
            onTap: () => _navigateToListAbsensi('sakit')),
        _buildInfoItem(Icons.schedule, 'Izin', izin, accentOrange,
            onTap: () => _navigateToListAbsensi('izin')),
        _buildInfoItem(Icons.people, 'Cuti', cuti, Colors.purple,
            onTap: () => _navigateToListAbsensi('cuti')),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(
              icon: Icons.work_outline,
              activeIcon: Icons.work,
              label: 'Storing',
              index: 0,
              badge: countNotif,
            ),
            _buildBottomNavItem(
              icon: Icons.pin_drop_outlined,
              activeIcon: Icons.pin_drop,
              label: 'Maps',
              index: 1,
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBarOLd() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                label: 'Storing',
                index: 0,
                badge: countNotif,
              ),
              _buildBottomNavItem(
                icon: Icons.pin_drop_outlined,
                activeIcon: Icons.pin_drop,
                label: 'Maps',
                index: 1,
              ),
              _buildBottomNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    String? label,
    int? index,
    int badge = 0,
  }) {
    bool isActive = pageIndex == index;
    return Flexible(
      child: GestureDetector(
        onTap: () {
          setState(() {
            pageIndex = index!;
            selectedIndexBottom = index!;
          });
          UpdateMenuBottom();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? primaryOrange
                              .withOpacity(0.1) // ✅ UPDATED: Orange theme
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      color: isActive
                          ? primaryOrange
                          : Colors.grey.shade600, // ✅ UPDATED: Orange theme
                      size: 20,
                    ),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          badge.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2),
              Flexible(
                child: Text(
                  label!,
                  style: TextStyle(
                    fontSize: 9,
                    color: isActive
                        ? primaryOrange
                        : Colors.grey.shade600, // ✅ UPDATED: Orange theme
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods and Navigation
  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      //getDataPreference();
      GetAbsensiSummary();
      GetCountStoring();
      GetListDo();
      fetchPoints();
    });
  }

  void _showNotificationList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryOrange, // ✅ UPDATED: Orange theme
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Semua Notifikasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off,
                              size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada notifikasi',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryOrange.withOpacity(
                                    0.1), // ✅ UPDATED: Orange theme
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.notifications,
                                  color: primaryOrange,
                                  size: 20), // ✅ UPDATED: Orange theme
                            ),
                            title: Text(
                              notification.note_verifikasi ?? 'No Title',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              notification.p2hnumber ?? 'No Message',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors.red, size: 20),
                              onPressed: () {
                                _notificationService
                                    .removeNotification(notification.id);
                              },
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _handleNotificationTap(notification);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPointsDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    await fetchPointsList();
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.star, color: primaryOrange), // ✅ UPDATED: Orange theme
              SizedBox(width: 8),
              Text('Detail Points'),
            ],
          ),
          content: Container(
            height: 300,
            width: double.maxFinite,
            child: pointDetails.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada points',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: pointDetails.length,
                    itemBuilder: (context, index) {
                      final item = pointDetails[index];
                      return Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: primaryOrange
                              .withOpacity(0.1), // ✅ UPDATED: Orange theme
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: primaryOrange
                                  .withOpacity(0.3)), // ✅ UPDATED: Orange theme
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row(
                            //   children: [
                            //     Container(
                            //       padding: EdgeInsets.all(4),
                            //       decoration: BoxDecoration(
                            //         color: primaryOrange.withOpacity(0.2),
                            //         borderRadius: BorderRadius.circular(4),
                            //       ),
                            //       child: Icon(Icons.star,
                            //           color: primaryOrange, size: 16),
                            //     ),
                            //     SizedBox(width: 8),
                            //     Expanded(
                            //       // biar teks bisa pisah kiri-kanan
                            //       child: Row(
                            //         mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           // Selalu tampil poin utama
                            //           Text(
                            //             "${item['points']} Points",
                            //             style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               color: darkOrange,
                            //             ),
                            //           ),
                            //
                            //           // Jika ada cancel_point, tampilkan di kanan
                            //           if (item['cancel_point'] != null &&
                            //               item['cancel_point']
                            //                   .toString()
                            //                   .isNotEmpty)
                            //             Text(
                            //               "${item['cancel_point']} Points",
                            //               style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color: darkOrange,
                            //               ),
                            //             ),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primaryOrange.withOpacity(
                                        0.2), // ✅ UPDATED: Orange theme
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(Icons.star,
                                      color: primaryOrange,
                                      size: 16), // ✅ UPDATED: Orange theme
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "${item['points']} Points",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        darkOrange, // ✅ UPDATED: Orange theme
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Type: ${item['point_type']}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade700),
                            ),
                            Text(
                              "Date: ${item['date_time']}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Cek Reward'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, // ✅ UPDATED: Orange theme
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                Navigator.of(context).pop();
                var drvid = prefs.getString('drvid') ?? '';
                var name = prefs.getString('name') ?? '';
                var locid = prefs.getString('locid') ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RewardTabsPage(
                      driverPoints: points,
                      driverId: drvid,
                      createdBy: name,
                      locId: locid,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Keluar Aplikasi?'),
            content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Tidak'),
              ),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Ya'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // Navigation methods
  void _navigateToPhoto(String viewName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("view_name", viewName);
    EasyLoading.show();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewPhotoVehicle()),
    );
  }

  void _navigateToPhotoUnits(String viewName, String vehicle_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("view_name", viewName);
    prefs.setString("vehicle_id", vehicle_id);
    EasyLoading.show();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewPhotoVehicle()),
    );
  }

  void _showAlert(BuildContext? ctx, int type, String message, String colorInfo) {
    if (ctx != null) alert(ctx, type, message, colorInfo);
  }

  void _navigateToWoMCN() {
    EasyLoading.show();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewListWoMCN()),
    );
  }

  void _navigateToListAbsensi(String method) {
    print(method);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListAbsensiKaryawanV1(method: method),
      ),
    );
  }

  void _handleScheduleAction(dynamic item) async {
    print("nameButton ${item['incustomer'].toString()}");
    EasyLoading.show();
    if (item['incustomer'].toString() == "2") {
      GetVhcidDo();
      Timer(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FrmSetKmByDriver()),
        );
      });
    } else {
      if (item['incustomer'].toString() == "1") {
        Timer(Duration(seconds: 1), () {
          var isOK = globals.akses_pages == null
              ? globals.akses_pages
              : globals.akses_pages.where(
                  (x) => x == "OP" || x == "OK" || x == "OT" || x == "UA");
          if (loginname == "DRIVER") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ViewListDo()),
            );
          } else if (isOK != null) {
            if (isOK.length > 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ViewListDoOpr()),
              );
            } else {
              alert(context, 0, "Anda tidak punya akses", "error");
            }
          } else {
            Navigator.of(context).pop(false);
            alert(context, 0, "Access Denied", "error");
          }
        });
      }
    }
  }

  void _handleScheduleActionMixer(dynamic item) async {
    EasyLoading.show();
    try {
      if (item['status_do_mixer'].toString() == "OUTUNLOADING") {
        GetVhcidDo();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmSetKmByDriver()),
          );
        });
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Konfirmasi'),
          content: Text('Yakin update status DO mixer ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return;
      }

      var gpsResult = await GpsSecurityChecker.checkGpsSecurity();
      var latitude = gpsResult["latitude"] ?? 0;
      var longitude = gpsResult["longitude"] ?? 0;

      var baseURL = GlobalData.baseUrl +
          "api/do_mixer/update_status_do_mixer.jsp?method=update-status-do-mixer&bujnbr=${item['bujnbr']}"
              "&status_do_mixer=${item['status_do_mixer']}&latitude=${latitude}&longitude=${longitude}&bujdestination=${item['bujdestination']}&userid=${loginname}";

      var encoded = Uri.encodeFull(baseURL);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        var status = result["status"]?.toString() ?? "";
        var message = result["message"]?.toString() ?? "";

        if (status.toLowerCase() == "success") {
          alert(globalScaffoldKey.currentContext!, 0, message, "success");
          GetListDo();
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              message.isNotEmpty ? message : "Gagal update status DO", "error");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal menghubungi server (${response.statusCode})", "error");
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Terjadi kesalahan: $e", "error");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }
  void _viewHistory(dynamic item) async {
    print(item['do_number']);
    print(item['tgl_do']);
    print(item['time_do']);
    print(item['nopol']);
    print(item['vehicle_id']);
    var tgl_do = item['tgl_do'] + " " + item['time_do'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("do_maps", item['do_number']);
    prefs.setString("do_tgl_do", tgl_do);
    prefs.setString("do_nopol", item['vehicle_id']);
    prefs.setString("do_origin", item['origin']);
    prefs.setString("do_destination", item['destination']);
    prefs.setString("do_vehicle_id", item['vehicle_id']);
    prefs.setString("do_driver_nm", item['driver_nm']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MapHistory()),
    );
  }

  void _handleMenuTap(AnpService anpService) async {
    // ✅ ADDED: Handle menu "More"
    if (anpService.idKey == 999) {
      _showMoreMenuModal();
      return;
    }

    // ✅ Original menu handling logic remains the same

    if (anpService.idKey == 1) {
      print("MAPS ${loginname}");
      //return;
      if (loginname == "DRIVER") {
        EasyLoading.show();
        //var tokenAuth =GlobalData.token_vts;// new GenerateTokenAuth();
        // var _tokens = await tokenAuth.GetTokenEasyGo("easygo".toString(), pr);
        // print("🔍 Token result driver: ${_tokens}");
        // print("🔍 Token length: ${_tokens?.length}");
        // print("🔍 Token type: ${_tokens.runtimeType}");
        var _tokens = GlobalData.token_vts;
        if (_tokens != "" && _tokens != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("page", "dashboard");
          prefs.setString("tokeneasygo", _tokens);
          prefs.setString("is_driver", "true");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LiveMaps(is_driver: 'true'),
            ),
          );

        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Terjadi kesalahan server",
              "error");
        }
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages.where((x) =>
                x == "MT" || x == "OP" || x == "OK" || x == "OT" || x == "UA");
        if (isOK != null) {
          print('IS OK ${isOK}');
          if (isOK.length > 0 ||
              loginname == "MECHANIC" ||
              loginname == "DRIVER" ||
              loginname == "DISPATCHER") {
            print('Login maps ${loginname}');
            if (!EasyLoading.isShow) {
              EasyLoading.show();
            }
            //var tokenAuth = new GenerateTokenAuth();
            var _tokens = GlobalData.token_vts;
            // await tokenAuth.GetTokenEasyGo("easygo".toString(), pr);
            // print("🔍 Token result: ${_tokens}");
            // print("🔍 Token length: ${_tokens?.length}");
            // print("🔍 Token type: ${_tokens.runtimeType}");
            if (_tokens != "" && _tokens != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("page", "dashboard");
              prefs.setString("tokeneasygo", _tokens);
              prefs.setString("is_driver", "false");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LiveMaps(is_driver:'false')),
              );
            } else {
              _showAlert(globalScaffoldKey.currentContext!, 0,
                  "Terjadi kesalahan server", "error");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LiveMaps(is_driver:'true')),
              );
            }
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
                "error");
          }
        } else {
          alert(
              globalScaffoldKey.currentContext!, 0, "Dont Have Access", "error");
        }
      }
    } else if (anpService.idKey == 2) {
      EasyLoading.show();
      Timer(Duration(seconds: 1), () {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages
                .where((x) => x == "OP" || x == "OK" || x == "OT" || x == "UA");
        if (loginname == "DRIVER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewListDo()),
          );
        } else if (isOK != null) {
          if (isOK.length > 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ViewListDoOpr()),
            );
          } else {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
            _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
                "error");
          }
        } else {
          Navigator.of(context).pop(false);
          _showAlert(globalScaffoldKey.currentContext!, 0, "Access Denied", "error");
        }
      });
    } else if (anpService.idKey == 4) {
      if (loginname == "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewListRitase()),
          );
        });
      } else {
        final ctx = globalScaffoldKey.currentContext!;
        if (ctx != null) {
          await showDialog(
            context: ctx,
            builder: (context) => new AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: new Text('Information'),
              content: new Text("Acces Menu For Driver"),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
    } else if (anpService.idKey == 7) {
      if (loginname == "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewListPelanggaran()),
          );
        });
      } else {
        final ctx = globalScaffoldKey.currentContext!;
        if (ctx != null) {
          await showDialog(
            context: ctx,
            builder: (context) => new AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: new Text('Information'),
              content: new Text("Acces Menu For Driver"),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
    } else if (anpService.idKey == 22) {
      if (loginname != "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmPlayBack()),
          );
        });
      }
    } else if (anpService.idKey == 6) {
      if (loginname == "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PieChartSample2()),
          );
        });
      } else {
        final ctx = globalScaffoldKey.currentContext!;
        if (ctx != null) {
          await showDialog(
            context: ctx,
            builder: (context) => new AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: new Text('Information'),
              content: new Text("Acces Menu For Driver"),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
    } else if (anpService.idKey == 5) {
      if (loginname == "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("page_antrian", "NOBUJNUMBER");
          prefs.setString("p2h_antrian", "true");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FrmCreateAntrianNewDriver()),
          );
        });
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages
                .where((x) => x == "HR" || x == "HD" || x == "UA");
        if (isOK != null) {
          if (isOK.length > 0) {
            showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: new Text('Information'),
                content: new Text("Gunakan maps untuk pencarian lokasi ?"),
                actions: <Widget>[
                  new ElevatedButton.icon(
                    icon: Icon(Icons.close, color: Colors.white, size: 20.0),
                    label: Text("No"),
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("is_edit", false);
                      prefs.setString("driver_id", "");
                      prefs.setString("lat_lon", "");
                      prefs.setString("p2h_antrian", "true");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterNewDriver()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.deepOrange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  new ElevatedButton.icon(
                    icon: Icon(Icons.save, color: Colors.white, size: 20.0),
                    label: Text("Yes"),
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("is_edit", false);
                      prefs.setString("driver_id", "");
                      prefs.setString("lat_lon", "");
                      EasyLoading.show();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MapAddress()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: primaryOrange, // ✅ UPDATED: Orange theme
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
                "error");
          }
        } else {
          final ctx = globalScaffoldKey.currentContext!;
          if (ctx != null) {
            await showDialog(
              context: ctx,
              builder: (context) => new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: new Text('Information'),
                content: new Text("Acces Menu For Operasional"),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
            );
          }
        }
      }
    } else if (anpService.idKey == 3) {
      if (loginname == "DRIVER") {
        GetVhcidDo();
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("p2h_antrian", "false");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmSetKmByDriver()),
          );
        });
      } else {
        final ctx = globalScaffoldKey.currentContext!;
        if (ctx != null) {
          await showDialog(
            context: ctx,
            builder: (context) => new AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: new Text('Information'),
              content: new Text("Acces Menu For Driver"),
              actions: <Widget>[
                new TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
    } else if (anpService.idKey == 8) {
      if (loginname == "DRIVER") {
        print('Only DISPATCHER');
      } else {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DetailMenu()),
          );
        });
      }
    } else if (anpService.idKey == 23) {
      if (username == "ADMIN" ||
          username == "NURIZKI" ||
          ismixer == "true" ||
          getAkses("OP")) {
        print('test p2h');
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          globals.inspeksi_name = "new_inspeksi";
          globals.p2hVhcDriver = "";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ListDriverInspeksiV2()),
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 24) {
      if (loginname != "DRIVER") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          globals.inspeksi_name = "new_inspeksi_mc";
          if (loginname == "MECHANIC") {
            globals.p2hVhcMekanik = "yes";
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DailyMekanikCheckScreenP2H()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ListMekanikInspeksiV2()),
            );
          }
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 25) {
      if (loginname != "DRIVER") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PoHeaderPage()),
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 27) {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "IN");
      if ((isOK != null && isOK.length > 0) || username == "ADMIN" || isMenuForeman == true) {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewListWoMcByForeMan()),
          );
        });
      }else{
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
      // if (username == "ADMIN" || isMenuForeman == true) {
      //   if (!EasyLoading.isShow) {
      //     EasyLoading.show();
      //   }
      //   Timer(Duration(seconds: 1), () {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => ViewListWoMcByForeMan()),
      //     );
      //   });
      // } else {
      //   _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
      //       "error");
      // }
    } else if (anpService.idKey == 28) {
      if (username != "DRIVER") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FrmApprovalReqDriver()), //ApprovedDriverRequest
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 29) {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "HR" || x == "HD");
      if ((isOK != null && isOK.length > 0) || username == "ADMIN") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ApvRewards()), //ApprovedDriverRequest
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    }else if (anpService.idKey == 30) {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "OP");
      if ((isOK != null && isOK.length > 0) || username == "ADMIN") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ListOpenDO()), //ApprovedDriverRequest
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 33) {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "OP");
      if ((isOK != null && isOK.length > 0) || username == "ADMIN") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ListOpenDOMP()), //ApprovedDriverRequest
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 9) {
      if (username == "ADMIN" || loginname == "DRIVER" || ismixer == "true") {
        final ctx = globalScaffoldKey.currentContext!;
        if (ctx != null) {
          showDialog(
            context: ctx,
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator());
            },
          );
        }
        Timer(Duration(seconds: 1), () {
          globals.inspeksi_name = "";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ListDriverInspeksi()),
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    } else if (anpService.idKey == 11) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmRequestMovingUnits()),
          );
        });
      }
    } else if (anpService.idKey == 12) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages.where((x) =>
                x == "OP" || x == "SA" || x == "FO" || username == "ADMIN");
        if (isOK != null) {
          if (isOK.length > 0) {
            EasyLoading.show();
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FrmServiceRequestOprPM()),
              );
            });
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
                "error");
          }
        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
              "error");
        }
      }
    } else if (anpService.idKey == 13) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages
                .where((x) => x == "TY" || username == "ADMIN");
        if (isOK != null) {
          if (isOK.length > 0) {
            EasyLoading.show();
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FrmServiceRequestTms()),
              );
            });
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
                "error");
          }
        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
              "error");
        }
      }
    } else if (anpService.idKey == 31) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages
                .where((x) => x == "TY" || username == "ADMIN");
        if (isOK != null) {
          if (isOK.length > 0) {
            EasyLoading.show();
            sharedPreferences = await SharedPreferences.getInstance();
            String drvid = sharedPreferences!.getString("drvid") ?? '';
            sharedPreferences!.setString("tire_vhttype", "");
            sharedPreferences!.setString("tire_drvid", "");
            sharedPreferences!.setString("tire_vhcid", "");
            await DatabaseHelper.instance.deleteItemLogsAll();
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FrmServiceTire()),
              );
            });
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
                "error");
          }
        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
              "error");
        }
      }
    } else if (anpService.idKey == 14) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages.where((x) =>
                x == "IN" || x == "IR" || x == "UA" || username == "ADMIN");
        if (isOK != null) {
          if (isOK.length > 0) {
            EasyLoading.show();
            Timer(Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ListInventoryTransNew(tabName: '',)),
              );
            });
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
                "error");
          }
        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Access Not Allowed",
              "error");
        }
      }
    } else if (anpService.idKey == 15) {
      if (loginname == "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmAttendanceDriver()),
          );
        });
      } else {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmAttendance()),
          );
        });
      }
    } else if (anpService.idKey == 16) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages.where((x) => x == "OP" || x == "HR");
        if (isOK != null) {
          EasyLoading.show();
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FrmAsset()),
            );
          });
        }
      }
    } else if (anpService.idKey == 17) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages
                .where((x) => x == "OP" || x == "IN" || x == "IR");
        if (isOK != null) {
          EasyLoading.show();
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FrmWareHouseOpName()),
            );
          });
        }
      }
    } else if (anpService.idKey == 18) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages
                .where((x) => x == "OP" || username == 'ADMIN');
        if (isOK != null) {
          EasyLoading.show();
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FrmCHK()),
            );
          });
        }
      }
    } else if (anpService.idKey == 19) {
      print('loginname ${loginname}');
      if (loginname == "DRIVER") {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmStoring()),
          );
        });
      } else {
        _showAlert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      }
    } else if (anpService.idKey == 20) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmAttendanceAdvance()),
          );
        });
      }
    } else if (anpService.idKey == 21) {
      if (loginname == "DRIVER") {
        alert(
            globalScaffoldKey.currentContext!, 0, "Access Not Allowed", "error");
      } else {
        EasyLoading.show();
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FrmNonTera()),
          );
        });
      }
    } else if (anpService.idKey == 32) {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "MK");
      if ((isOK != null && isOK.length > 0) || username == "ADMIN") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FrmMasterData()), //ApprovedDriverRequest
          );
        });
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }

    } else {
      final ctx = globalScaffoldKey.currentContext!;
      if (ctx != null) {
        await showDialog(
          context: ctx,
          builder: (context) => new AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: new Text('Information'),
            content: new Text("ON Progress"),
          actions: <Widget>[
            new TextButton(
              // ✅ UPDATED: Use TextButton instead of FlatButton
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: new Text('Ok'),
            ),
          ],
        ),
      );
    }}
  }

  void UpdateMenuBottom() async {
    if (selectedIndexBottom == 0) {
      var isOK = globals.akses_pages == null
          ? globals.akses_pages
          : globals.akses_pages.where((x) => x == "OP");
      if (isOK != null) {
        if (isOK.length > 0 || username == 'ADMIN') {
          EasyLoading.show();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewListStoring()),
          );
        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
              "error");
        }
      } else {
        _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
            "error");
      }
    }
    if (selectedIndexBottom == 1) {
      if (loginname == "DRIVER") {
        EasyLoading.show();
        // var tokenAuth = new GenerateTokenAuth();
        // var _tokens = await tokenAuth.GetTokenEasyGo("easygo".toString(), pr);
        var _tokens = GlobalData.token_vts;
        if (_tokens != "" && _tokens != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("page", "dashboard");
          prefs.setString("tokeneasygo", _tokens);
          prefs.setString("is_driver", "true");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LiveMaps(is_driver:'true')),
          );
        } else {
          _showAlert(globalScaffoldKey.currentContext!, 0, "Terjadi kesalahan server",
              "error");
        }
      } else {
        var isOK = globals.akses_pages == null
            ? globals.akses_pages
            : globals.akses_pages.where((x) =>
                x == "MT" || x == "OP" || x == "OK" || x == "OT" || x == "UA");
        if (isOK != null) {
          if (isOK.length > 0 ||
              loginname == "MECHANIC" ||
              username == 'ADMIN') {
            // var tokenAuth = new GenerateTokenAuth();
            // var _tokens =
            // await tokenAuth.GetTokenEasyGo("easygo".toString(), pr);
            var _tokens = GlobalData.token_vts;
            if (_tokens != "" && _tokens != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("page", "dashboard");
              prefs.setString("tokeneasygo", _tokens);
              prefs.setString("is_driver", "false");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LiveMaps(is_driver:'false')),
              );
            } else {
              _showAlert(globalScaffoldKey.currentContext!, 0,
                  "Terjadi kesalahan server", "error");
            }
          } else {
            _showAlert(globalScaffoldKey.currentContext!, 0, "Anda tidak punya akses",
                "error");
          }
        } else {
          alert(
              globalScaffoldKey.currentContext!, 0, "Dont Have Access", "error");
        }
      }
    }
    if (selectedIndexBottom == 2) {
      EasyLoading.show();
      Timer(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewProfileUser()),
        );
      });
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: "Scan your finger to authenticate",
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }
    setState(() {
      authorized =
          authenticated ? "Authorized success" : "Failed to authenticate";
      print(authorized);
    });
    Timer(Duration(seconds: 1), () {
      if (authorized == "Authorized success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FrmAttendance()),
        );
      } else {
        alert(
          globalScaffoldKey.currentContext!,
          0,
          "Authentication finger failed, silahkan kontak Administrator",
          "error",
        );
      }
    });
  }

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;
    try {
      bool isBiometricSupported = await auth.isDeviceSupported();
      canCheckBiometric = await auth.canCheckBiometrics;
      if (!isBiometricSupported && !canCheckBiometric) {
        _showAlert(globalScaffoldKey.currentContext!, 0,
            "Device not supported finger", "error");
      } else {
        print(canCheckBiometric);
      }
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  bool getAkses(akses) {
    var isAkses = false;
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == akses);
    if (isOK != null) {
      if (isOK.length > 0) {
        isAkses = true;
      }
    }
    return isAkses;
  }

  Future _getAvailableBiometric() async {
    List<BiometricType> availableBiometric = [];
    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    setState(() {
      _availableBiometric = availableBiometric;
    });
  }

  void GetListDo() async {
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      sharedPreferences = await SharedPreferences.getInstance();
      String drvid = sharedPreferences!.getString("drvid") ?? '';
      String vhcid = sharedPreferences!.getString("vhcid") ?? '';
      String _loginType = sharedPreferences!.getString("login_type") ?? '';
      var urlData =_loginType=="MIXER"?
          "${GlobalData.baseUrlProd}api/do_mixer/list_do_driver_mixer.jsp?method=lookup-list-do-driver-v1&vhcid=${vhcid}&drvid=${drvid}"
      :"${GlobalData.baseUrlProd}api/do/list_do_driver.jsp?method=lookup-list-do-driver-v1&vhcid=${vhcid}&drvid=${drvid}";
      Uri myUri = Uri.parse(urlData);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          data_list_do = json.decode(response.body);
        }
        print("data_list_do");
        print(data_list_do);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
        backgroundColor: paleOrange, // ✅ UPDATED: Orange soft background
        key: globalScaffoldKey,
        body: Column(
          children: [
            SizedBox(height: 25),
            _buildProfileHeader(), // Fixed Header

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 12),
                      _buildNotificationBanner(),
                      _buildMainContent(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
}
