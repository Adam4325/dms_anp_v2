// //import 'package:design_new/MoreMenu.dart';
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:badges/badges.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:dms_anp/src/Helper/AnpService.dart';
// import 'package:dms_anp/src/Helper/GenerateTokenAuth.dart';
// import 'package:dms_anp/src/Helper/Provider.dart';
// import 'package:dms_anp/src/Helper/constant.dart';
// import 'package:dms_anp/src/loginPage.dart';
// import 'package:dms_anp/src/model/banner_anp.dart';
// import 'package:dms_anp/src/pages/DetailMenu.dart';
// import 'package:dms_anp/src/pages/FrmAttendance.dart';
// import 'package:dms_anp/src/pages/FrmAttendanceAdvance.dart';
// import 'package:dms_anp/src/pages/FrmCHK.dart';
// import 'package:dms_anp/src/pages/FrmCreateAntrianNewDriver.dart';
// import 'package:dms_anp/src/pages/FrmPlayBack.dart';
// import 'package:dms_anp/src/pages/FrmSetKmByDriver.dart';
// import 'package:dms_anp/src/pages/LiveMaps.dart';
// import 'package:dms_anp/src/pages/MapAddress.dart';
// import 'package:dms_anp/src/pages/MapHistory.dart';
// import 'package:dms_anp/src/pages/driver/FrmStoring.dart';
// import 'package:dms_anp/src/pages/driver/ListDriverInspeksi.dart';
// import 'package:dms_anp/src/pages/driver/RegistrasiNewDriver.dart';
// import 'package:dms_anp/src/pages/ViewListDo.dart';
// import 'package:dms_anp/src/pages/ViewListDoOpr.dart';
// import 'package:dms_anp/src/pages/ViewListRitase.dart';
// import 'package:dms_anp/src/pages/ViewPelanggaran.dart';
// import 'package:dms_anp/src/pages/ViewProfileUser.dart';
// import 'package:dms_anp/src/pages/beranda_anp_appbar.dart';
// import 'package:dms_anp/src/pages/hrd/frmAssset.dart';
// import 'package:dms_anp/src/pages/inventory/FrmWareHouseOpName.dart';
// import 'package:dms_anp/src/pages/inventory/ListInventoryTransNew.dart';
// import 'package:dms_anp/src/pages/maintenance/FrmServiceRequestTms.dart';
// import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
// import 'package:dms_anp/src/pages/pie_chart_sample2.dart';
// import 'package:dms_anp/src/pages/vehicle/FrmRequestMovingUnits.dart';
// import 'package:dms_anp/src/pages/vehicle/ViewPhotoVehicle.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:qrscan/qrscan.dart' as scanner;
// import 'package:dms_anp/src/Helper/globals.dart' as globals;
// import 'package:timelines/timelines.dart';
// import 'package:unique_identifier/unique_identifier.dart';
//
// import '../flusbar.dart';
// import 'FrmNonTera.dart';
// import 'ViewListStoring.dart';
// import 'maintenance/FrmServiceRequestOprPM.dart';
// import 'package:flutter/material.dart';
//
// class ViewDashboard extends StatefulWidget {
//   @override
//   _ViewDashboardState createState() => _ViewDashboardState();
// }
//
// class _ViewDashboardState extends State<ViewDashboard> {
//   //const ViewDashboard({Key key}) : super(key: key);
//   GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
//   GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
//
//   final List<String> imageListAtt = [
//     'https://apps.tuluatas.com/trucking/carousel/icon_storing.png',
//     'https://apps.tuluatas.com/trucking/carousel/icon_hadir.jpg',
//     'https://apps.tuluatas.com/trucking/carousel/icon_sick.png',
//     'https://apps.tuluatas.com/trucking/carousel/icon_ijin.jpg',
//     'https://apps.tuluatas.com/trucking/carousel/icon_cuti.jpg'
//   ];
//
//   Timer timer;
//   String _identifier = '';
//   List<AnpService> _anpServiceList = [];
//   List<BannerBottom> _bannerList = [];
//   List<DetailInfo> _detailInfo = [];
//   List data = [];
//   SharedPreferences sharedPreferences;
//   String spLoginName;
//   String loginname;
//   String ismixer;
//   String vhcid;
//   String vhckm;
//   String vhcnopol;
//   String locid;
//   String firstName;
//   String username;
//   String cpyid;
//   String cpyname;
//   String scanResult = '';
//   String simType = '';
//   String expireSIM = '';
//   String hadir = "";
//   String sakit = "";
//   String izin = "";
//   String cuti = "";
//   String storing = "";
//
//   Future<void> initUniqueIdentifierState() async {
//     String identifier;
//     try {
//       identifier = await UniqueIdentifier.serial;
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString("androidID", identifier);
//     } catch (latformException) {
//       identifier = 'Failed to get Unique Identifier';
//     }
//
//     if (!mounted) return; //1
//     if (mounted) {
//       setState(() {
//         _identifier = identifier;
//       });
//     }
//   }
//
//   Future scanQRCode() async {
//     String cameraScanResult = await scanner.scan();
//     setState(() {
//       scanResult = cameraScanResult;
//       if (scanResult != null) {
//         showDialog(
//           context: context,
//           builder: (context) => new AlertDialog(
//             title: new Text('Information'),
//             content: new Text(
//                 "ITEM ID ${scanResult}, proses lanjut, untuk penginputan?"),
//             actions: <Widget>[
//               new ElevatedButton.icon(
//                 icon: Icon(
//                   Icons.camera_alt,
//                   color: Colors.white,
//                   size: 24.0,
//                 ),
//                 label: Text("Ok"),
//                 onPressed: () async {
//                   print('Clicked');
//                   // sharedPreferences = await SharedPreferences.getInstance();
//                   // sharedPreferences.setString("item_id_scan", scanResult);
//                   // Navigator.pushReplacement(context,
//                   //     MaterialPageRoute(builder: (context) => FrmInventory()));
//                 },
//                 style: ElevatedButton.styleFrom(
//                     elevation: 0.0,
//                     backgroundColor: Colors.grey,
//                     padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//                     textStyle:
//                         TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         );
//       }
//     });
//   }
//   var driver_id_image = "";
//   Future getDataPreference() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//     setState(() {
//       //sharedPreferences.setString("vhcidfromdo","B 9565 YM");//DEMO
//       print("sharedPreferences.getStringList(akses_pages)");
//       sharedPreferences.setString("lat_lon", "");
//       globals.akses_pages = sharedPreferences.getStringList("akses_pages");
//       print(globals.akses_pages);
//       username = sharedPreferences.getString("username");
//       driver_id_image = sharedPreferences.getString("photo_driver");
//       print("https://apps.tuluatas.com/trucking/photo_trucking/PHOTO_DRIVER/${driver_id_image}");
//       loginname = sharedPreferences.getString("loginname") == null ||
//               sharedPreferences.getString("loginname") == ''
//           ? ""
//           : sharedPreferences.getString("loginname");
//
//       ismixer = sharedPreferences.getString("ismixer") == null ||
//               sharedPreferences.getString("ismixer") == ''
//           ? "false"
//           : sharedPreferences.getString("ismixer");
//
//       vhcid = sharedPreferences.getString("vhcid");
//       vhckm = sharedPreferences.getString("vhckm");
//       vhcnopol = sharedPreferences.getString("vhcnopol");
//       locid = sharedPreferences.getString("locid");
//       print("loginname ${loginname}");
//       print(locid);
//       firstName = sharedPreferences.getString("name");
//       cpyid = sharedPreferences.getString("cpyid");
//       cpyname = sharedPreferences.getString("cpyname");
//       sharedPreferences.setString("page", "dashboard");
//       if (loginname != null && loginname != "") {
//         if (loginname == "DRIVER") {
//           cekDetailInfo("status_unit");
//           cekDetailInfo("sim");
//           cekDetailInfo("stnk");
//           cekDetailInfo("kir");
//         }
//         if (loginname == "MECHANIC") {
//           print('status_mc_out_standing ${loginname}');
//           cekDetailInfoMECHANIC("status_mc_out_standing");
//           //cekDetailInfo("sim");
//           //cekDetailInfo("sim");
//           // cekDetailInfo("stnk");
//           // cekDetailInfo("kir");
//         }
//         _anpServiceList.clear();
//         _anpServiceList.add(new AnpService(
//             image:
//                 loginname == "DRIVER" ? Icons.location_on : Icons.location_on,
//             color: AnpPalette.menuRide,
//             idKey: 1,
//             title: loginname == "DRIVER" ? "Maps" : "Maps"));
//         if (loginname != "DRIVER") {
//           var isOK = globals.akses_pages == null
//               ? globals.akses_pages
//               : globals.akses_pages
//                   .where((x) => (x == "OP" || username == "ADMIN"));
//           if (isOK != null) {
//             if (isOK.length > 0) {
//               _anpServiceList.add(new AnpService(
//                   image: Icons.play_arrow,
//                   color: Colors.red,
//                   idKey: 22,
//                   title: "PLAYBACK"));
//             }
//           }
//         }
//         _anpServiceList.add(new AnpService(
//             image: Icons.add_chart,
//             color: AnpPalette.menuCar,
//             idKey: 2,
//             title:
//                 "DO DITERIMA")); //loginname == "DRIVER" ? "RECEIVE-DO" : "CLOSE-DO"));
//         _anpServiceList.add(new AnpService(
//             image: Icons.closed_caption,
//             color: AnpPalette.menuBluebird,
//             idKey: 3,
//             title: "CLOSE DO"));
//         _anpServiceList.add(new AnpService(
//             image: Icons.bubble_chart,
//             color: AnpPalette.menuFood,
//             idKey: 4,
//             title: "RITASE"));
//         _anpServiceList.add(new AnpService(
//             image: (loginname == 'DRIVER'
//                 ? Icons.drive_eta_rounded
//                 : Icons.electric_car_outlined),
//             color: AnpPalette.menuDeals,
//             idKey: 5,
//             title: (loginname == 'DRIVER' ? "ANTRIAN" : "NEW DRIVER")));
//         _anpServiceList.add(new AnpService(
//             image: Icons.bar_chart,
//             color: AnpPalette.menuPulsa,
//             idKey: 6,
//             title: "PERFORMANCE"));
//         _anpServiceList.add(new AnpService(
//             image: Icons.alarm_on,
//             color: AnpPalette.menuDeals,
//             idKey: 7,
//             title: "PELANGGARAN"));
//         _anpServiceList.add(new AnpService(
//             image: Icons.queue,
//             color: AnpPalette.menuSend,
//             idKey: 8,
//             title: "Others"));
//         if (loginname != "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.work_outlined,
//               color: Colors.red,
//               idKey: 9,
//               title: "P2H"));
//         }
//
//         if (loginname == "DRIVER" && ismixer == "true") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.work_outlined,
//               color: Colors.red,
//               idKey: 9,
//               title: "P2H"));
//         }
//         if (loginname != "DRIVER") {
//           var isOK = globals.akses_pages == null
//               ? globals.akses_pages
//               : globals.akses_pages.where((x) =>
//                   (x == "OP" || x == "MT" || username == "ADMIN") && x != "MK");
//           if (isOK != null) {
//             if (isOK.length > 0) {
//               _anpServiceList.add(new AnpService(
//                   image: Icons.car_repair,
//                   color: Colors.red,
//                   idKey: 11,
//                   title: "MOVING UNIT"));
//             }
//           }
//         }
//         if (loginname != "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.home_repair_service_outlined,
//               color: Colors.red,
//               idKey: 12,
//               title: "SR"));
//         }
//         if (loginname != "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.donut_large,
//               color: Colors.red,
//               idKey: 13,
//               title: "TMS"));
//         }
//
//         if (loginname != "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.today_outlined,
//               color: Colors.red,
//               idKey: 14,
//               title: "INVENTORY"));
//         }
//
//         if (loginname != "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.fingerprint,
//               color: Colors.red,
//               idKey: 15,
//               title: "ATTENDANCE"));
//         }
//         if (loginname != "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.fingerprint_rounded,
//               color: Colors.green,
//               idKey: 20,
//               title: "ATT ADV"));
//         }
//         if (loginname != "DRIVER") {
//           var isOK = globals.akses_pages == null
//               ? globals.akses_pages
//               : globals.akses_pages.where((x) =>
//                   (x == "OP" || x == "MT" || username == "ADMIN") && x != "MK");
//           if (isOK != null) {
//             if (isOK.length > 0) {
//               _anpServiceList.add(new AnpService(
//                   image: Icons.web_asset,
//                   color: Colors.red,
//                   idKey: 16,
//                   title: "EDP/ASSET"));
//             }
//           }
//         }
//
//         if (loginname != "DRIVER") {
//           var isOK = globals.akses_pages == null
//               ? globals.akses_pages
//               : globals.akses_pages.where((x) =>
//                   (x == "OP" || x == "MT" || username == "ADMIN") && x != "MK");
//           if (isOK != null) {
//             if (isOK.length > 0) {
//               _anpServiceList.add(new AnpService(
//                   image: Icons.room_preferences,
//                   color: Colors.red,
//                   idKey: 17,
//                   title: "WH. OPNAME"));
//             }
//           }
//         }
//
//         if (loginname != "DRIVER") {
//           var isOK = globals.akses_pages == null
//               ? globals.akses_pages
//               : globals.akses_pages
//                   .where((x) => (x == "OP" || username == "ADMIN"));
//           if (isOK != null) {
//             if (isOK.length > 0) {
//               _anpServiceList.add(new AnpService(
//                   image: Icons.credit_card,
//                   color: Colors.red,
//                   idKey: 21,
//                   title: "NON-TERA"));
//             }
//           }
//         }
//         // if (loginname != "DRIVER") {
//         //   _anpServiceList.add(new AnpService(
//         //       image: Icons.format_list_numbered_rtl,
//         //       color: Colors.red,
//         //       idKey: 18,
//         //       title: "FRM CHK"));
//         // }
//         // _anpServiceList.add(new AnpService(
//         //     image: Icons.restore_page,
//         //     color: Colors.red,
//         //     idKey: 18,
//         //     title: "OBP"));
//         if (loginname == "DRIVER") {
//           _anpServiceList.add(new AnpService(
//               image: Icons.handyman,
//               color: Colors.red,
//               idKey: 19,
//               title: "Storing"));
//         }
//
//         _bannerList.add(new BannerBottom(
//             title: "Banner 1", image: "assets/img/banner1.jpg"));
//         _bannerList.add(new BannerBottom(
//             title: "Banner 2", image: "assets/img/banner2.jpg"));
//         _bannerList.add(new BannerBottom(
//             title: "Banner 3", image: "assets/img/banner3.jpg"));
//         _bannerList.add(new BannerBottom(
//             title: "Banner 1", image: "assets/img/banner1.jpg"));
//         _bannerList.add(new BannerBottom(
//             title: "Banner 2", image: "assets/img/banner2.jpg"));
//
//         //print(_anpServiceList);
//       }
//     });
//   }
//
//   Future<String> GetVhcidDo() async {
//     try {
//       final JsonDecoder _decoder = new JsonDecoder();
//       sharedPreferences = await SharedPreferences.getInstance();
//       String drvid = sharedPreferences.getString("drvid");
//       var resVhcid = "";
//       var vDo = sharedPreferences.getString("vhcidfromdo");
//       if (vDo == null || vDo == "") {
//         var urlData =
//             "${GlobalData.baseUrlProd}api/log_receive_do.jsp?method=vehicle-log&drvid=" +
//                 drvid;
//         Uri myUri = Uri.parse(urlData);
//         print(myUri.toString());
//         var response =
//             await http.get(myUri, headers: {"Accept": "application/json"});
//         setState(() {
//           if (response.statusCode == 200) {
//             var result = json.decode(response.body)[0];
//             print(result['vhcid']);
//             resVhcid = result['vhcid'];
//             sharedPreferences.setString("vhcidfromdo", resVhcid);
//           }
//           //if(resVhcid!=null && resVhcid!=""){
//           //sharedPreferences.setString("vhcidfromdo",resVhcid);
//           //}
//         });
//       }
//       return resVhcid;
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future GetCountStoring() async {
//     //print('GetCountStoring');
//     try {
//       var isOK = globals.akses_pages == null
//           ? globals.akses_pages
//           : globals.akses_pages.where((x) => x == "OP");
//       bool isValid = false;
//       if (isOK != null) {
//         if (isOK.length > 0) {
//           isValid = true;
//         }
//       }
//       if (username == "ADMIN") {
//         isValid = true;
//       }
//       print('isvalid ${isValid} ${username}');
//       if (isValid) {
//         var urlData =
//             "${GlobalData.baseUrlProd}api/list_storing.jsp?method=count-data-storing";
//         Uri myUri = Uri.parse(urlData);
//         print(myUri.toString());
//         var response =
//             await http.get(myUri, headers: {"Accept": "application/json"});
//         if (response.statusCode == 200) {
//           var result = json.decode(response.body);
//           print(result['total']);
//           setState(() {
//             countNotif =
//                 result['total'] == null ? 0 : int.parse(result['total']);
//           });
//         }
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future GetAbsensiSummary() async {
//     try {
//       //a114b4179bc8fd9f
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String imeiid = prefs.getString("androidID");
//       var urlData =
//           "${GlobalData.baseUrlProd}api/absensi/list_total_absensi.jsp?method=list_absensi&imeiid=${imeiid}";
//       var encoded = Uri.encodeFull(urlData);
//       Uri myUris = Uri.parse(encoded);
//       var responses =
//           await http.get(myUris, headers: {"Accept": "application/json"});
//       print(responses);
//       if (responses.statusCode == 200) {
//         var result = json.decode(responses.body);
//         setState(() {
//           hadir = result['hadir'] == null ? "0" : result['hadir'];
//           sakit = result['sakit'] == null ? "0" : result['sakit'];
//           izin = result['izin'] == null ? "0" : result['izin'];
//           cuti = result['cuti'] == null ? "0" : result['cuti'];
//           storing = result['storing'] == null ? "0" : result['storing'];
//           print('Hadir');
//         });
//       }
//     } catch (e) {
//       print('Error');
//       print(e);
//     }
//   }
//
//   Future<String> cekDetailInfoMECHANIC(String method) async {
//     //OUT STANDINGS JOBS
//     try {
//       final JsonDecoder _decoder = new JsonDecoder();
//       sharedPreferences = await SharedPreferences.getInstance();
//       String vhcid = sharedPreferences.getString("vhcid");
//       String drvid = sharedPreferences.getString("drvid");
//       String mechanicid = sharedPreferences.getString("mechanicid");
//
//       print('mechanicid ${mechanicid}');
//       var urlData = "";
//       if (method == "status_mc_out_standing") {
//         urlData =
//             "${GlobalData.baseUrlProd}api/detail_info.jsp?method=status_mc_out_standing&mcid=" +
//                 mechanicid;
//         print(urlData);
//       }
//       Uri myUri = Uri.parse(urlData);
//       print(myUri.toString());
//       var response =
//           await http.get(myUri, headers: {"Accept": "application/json"});
//       setState(() {
//         // Get the JSON data
//         var result = _decoder.convert(response.body);
//         print(result);
//         if (result['status_code'] == '200') {
//           print('status code ${result['status_code']}');
//           if (method == "status_mc_out_standing") {
//             data.add({
//               "name": "status_unit",
//               "from": "",
//               "to": "",
//               "status": result['status']
//             });
//           } else {
//             var from = result['from'] == null ? '' : result['from'];
//             var to = result['to'] == null ? '' : result['to'];
//             data.add({"name": method, "from": from, "to": to, "status": ""});
//           }
//           print("data ${data}");
//           //if(data[0]['name'])
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//     return "Successfull";
//   }
//
//   Future<String> cekDetailInfo(String method) async {
//     try {
//       final JsonDecoder _decoder = new JsonDecoder();
//       sharedPreferences = await SharedPreferences.getInstance();
//       String vhcid = sharedPreferences.getString("vhcid");
//       String drvid = sharedPreferences.getString("drvid");
//       var urlData = "";
//       if (method == "status_unit") {
//         urlData =
//             "${GlobalData.baseUrlProd}api/detail_info.jsp?method=status_unit&vhcid=" +
//                 vhcid;
//         print(urlData);
//       } else if (method == "sim") {
//         urlData =
//             "${GlobalData.baseUrlProd}api/detail_info.jsp?method=sim&drvid=" +
//                 drvid;
//       } else if (method == "stnk") {
//         urlData =
//             "${GlobalData.baseUrlProd}api/detail_info.jsp?method=stnk&vhcid=" +
//                 vhcid;
//       } else if (method == "kir") {
//         urlData =
//             "${GlobalData.baseUrlProd}api/detail_info.jsp?method=kir&vhcid=" +
//                 vhcid;
//       }
//       Uri myUri = Uri.parse(urlData);
//       print(myUri.toString());
//       var response =
//           await http.get(myUri, headers: {"Accept": "application/json"});
//       setState(() {
//         // Get the JSON data
//         var result = _decoder.convert(response.body);
//         print(result);
//         if (result['status_code'] == '200') {
//           if (method == "status_unit") {
//             data.add({
//               "name": "status_unit",
//               "from": "",
//               "to": "",
//               "status": result['status']
//             });
//           } else {
//             var from = result['from'] == null ? '' : result['from'];
//             var to = result['to'] == null ? '' : result['to'];
//             data.add({"name": method, "from": from, "to": to, "status": ""});
//           }
//           //print(data[0]['name']);
//           //if(data[0]['name'])
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//     return "Successfull";
//   }
//
//   Future<String> cekIsActiveUser() async {
//     try {
//       final JsonDecoder _decoder = new JsonDecoder();
//       sharedPreferences = await SharedPreferences.getInstance();
//       //String vhcid = sharedPreferences.getString("vhcid");
//
//       Uri myUri = Uri.parse(
//           "${GlobalData.baseUrlProd}api/is_sign.jsp?method=is_sign&username=" +
//               username);
//       print(myUri.toString());
//       var response =
//           await http.get(myUri, headers: {"Accept": "application/json"});
//       setState(() {
//         // Get the JSON data
//         var result = _decoder.convert(response.body);
//         if (result['status_code'] == '200') {
//           if (result['is_active'].toString().toLowerCase() != 'act' &&
//               result['is_active'].toString().toLowerCase() != 'active') {
//             showMyDialog();
//           } else {
//             print(result['is_active']);
//           }
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//     return "Successfull";
//   }
//
//   void showMyDialog() {
//     showDialog(
//       context: globalScaffoldKey.currentContext,
//       builder: (context) => new AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(15.0))),
//         title: new Text('Authorize'),
//         content: new Text('Username is not active'),
//         actions: <Widget>[
//           new TextButton(
//             onPressed: () async {
//               SharedPreferences preferences =
//                   await SharedPreferences.getInstance();
//               await preferences.clear();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginPage()),
//                 (Route<dynamic> route) => false,
//               );
//             },
//             child: new Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildInfoDetail() {
//     if (loginname == "DRIVER") {
//       var status_unit = '';
//       var fromKir = '';
//       var toKir = '';
//       var fromSTNK = '';
//       var toSTNK = '';
//       var fromSIM = '';
//       var toSIM = '';
//
//       for (var i = 0; i < data.length; i++) {
//         print(data[i]['name']);
//         if (data[i]['name'] != null) {
//           if (data[i]['name'] == 'status_unit') {
//             status_unit = data[i]['status'] == null
//                 ? ''
//                 : data[i]['status'].toString().toUpperCase();
//           } else if (data[i]['name'] == 'sim') {
//             fromSIM = data[i]['from'] == null
//                 ? ''
//                 : data[i]['from'].toString().toUpperCase();
//             toSIM = data[i]['to'] == null
//                 ? ''
//                 : data[i]['to'].toString().toUpperCase();
//           } else if (data[i]['name'] == 'stnk') {
//             fromSTNK = data[i]['from'] == null
//                 ? ''
//                 : data[i]['from'].toString().toUpperCase();
//             toSTNK = data[i]['to'] == null
//                 ? ''
//                 : data[i]['to'].toString().toUpperCase();
//           } else if (data[i]['name'] == 'kir') {
//             fromKir = data[i]['from'] == null
//                 ? ''
//                 : data[i]['from'].toString().toUpperCase();
//             toKir = data[i]['to'] == null
//                 ? ''
//                 : data[i]['to'].toString().toUpperCase();
//           }
//         }
//       }
//       print(status_unit);
//       print(fromSIM);
//       print(toSIM);
//       return new Container(
//           margin: const EdgeInsets.only(top: 10.0),
//           child: new Column(
//             children: <Widget>[
//               new Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.blue, Colors.blue],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(color: Colors.grey, spreadRadius: 1),
//                   ],
//                 ),
//                 height: 70,
//                 child: Center(
//                   child: ListTile(
//                       title: Text("Status (${status_unit})",
//                           style: TextStyle(color: Colors.white)),
//                       //subtitle: Text(ktp.text),
//                       //leading: CircleAvatar(backgroundImage: AssetImage("assets/js.png")),
//                       trailing: Icon(Icons.car_rental)),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () async {
//                   print('kir');
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   prefs.setString("view_name", "SIM");
//                   EasyLoading.show();
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => ViewPhotoVehicle()));
//                 },
//                 child: new Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title: Text("SIM (${fromSIM}-${toSIM})",
//                             style: TextStyle(color: Colors.white)),
//                         //subtitle: Text(ktp.text),
//                         //leading: CircleAvatar(backgroundImage: AssetImage("assets/js.png")),
//                         trailing: Icon(Icons.card_membership)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                   onTap: () async {
//                     print('stnk');
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.setString("view_name", "STNK");
//                     EasyLoading.show();
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ViewPhotoVehicle()));
//                   },
//                   child: new Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.blue, Colors.blue],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(color: Colors.grey, spreadRadius: 1),
//                       ],
//                     ),
//                     height: 70,
//                     child: Center(
//                       child: ListTile(
//                           title: Text("STNK (${fromSTNK}-${toSTNK})",
//                               style: TextStyle(color: Colors.white)),
//                           //subtitle: Text(ktp.text),
//                           //leading: CircleAvatar(backgroundImage: AssetImage("assets/js.png")),
//                           trailing: Icon(Icons.card_membership)),
//                     ),
//                   )),
//               SizedBox(height: 5),
//               new InkWell(
//                   onTap: () async {
//                     print('kir');
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.setString("view_name", "KIR");
//                     EasyLoading.show();
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ViewPhotoVehicle()));
//                   },
//                   child: new Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.blue, Colors.blue],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(color: Colors.grey, spreadRadius: 1),
//                       ],
//                     ),
//                     height: 70,
//                     child: Center(
//                       child: ListTile(
//                           title: Text("KIR (${fromKir}-${toKir})",
//                               style: TextStyle(color: Colors.white)),
//                           //subtitle: Text(ktp.text),
//                           //leading: CircleAvatar(backgroundImage: AssetImage("assets/js.png")),
//                           trailing: Icon(Icons.confirmation_number)),
//                     ),
//                   )),
//               SizedBox(height: 5),
//               new InkWell(
//                   onTap: () async {
//                     print('photo keluarga');
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.setString("view_name", "FAMILY");
//                     EasyLoading.show();
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ViewPhotoVehicle()));
//                   },
//                   child: new Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.blue, Colors.blue],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(color: Colors.grey, spreadRadius: 1),
//                       ],
//                     ),
//                     height: 70,
//                     child: Center(
//                       child: ListTile(
//                           title: Text("PHOTO KELUARGA",
//                               style: TextStyle(color: Colors.white)),
//                           //subtitle: Text(ktp.text),
//                           //leading: CircleAvatar(backgroundImage: AssetImage("assets/js.png")),
//                           trailing: Icon(Icons.confirmation_number)),
//                     ),
//                   )),
//               SizedBox(height: 5),
//               new InkWell(
//                   onTap: () async {
//                     print('photo domisili');
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.setString("view_name", "DOMISILI");
//                     EasyLoading.show();
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ViewPhotoVehicle()));
//                   },
//                   child: new Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.blue, Colors.blue],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(color: Colors.grey, spreadRadius: 1),
//                       ],
//                     ),
//                     height: 70,
//                     child: Center(
//                       child: ListTile(
//                           title: Text("PHOTO DOMISILI",
//                               style: TextStyle(color: Colors.white)),
//                           //subtitle: Text(ktp.text),
//                           //leading: CircleAvatar(backgroundImage: AssetImage("assets/js.png")),
//                           trailing: Icon(Icons.confirmation_number)),
//                     ),
//                   )),
//             ],
//           ));
//     } else if (loginname == "MECHANIC") {
//       var out_standing_jobs = "0";
//       for (var i = 0; i < data.length; i++) {
//         if (data[i]['status'] != null && data[i]['status'] != 'null') {
//           out_standing_jobs = data[i]['status'];
//         }
//       }
//       return new Container(
//           margin: const EdgeInsets.only(top: 10.0),
//           child: new Column(
//             children: <Widget>[
//               new InkWell(
//                 onTap: () {
//                   EasyLoading.show();
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               ViewListWoMCN())); //test FrmInspeksiVehicleP2H
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title: Text("OUT STANDING JOBS = ${out_standing_jobs}",
//                             style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.handyman)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               if (loginname == "MECHANIC" || username == "ADMIN") ...[
//                 new InkWell(
//                   onTap: () {
//                     print('On Tap');
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.blue, Colors.blue],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(color: Colors.grey, spreadRadius: 1),
//                       ],
//                     ),
//                     height: 70,
//                     child: Center(
//                       child: ListTile(
//                           title: Text(storing,
//                               style: TextStyle(color: Colors.white)),
//                           trailing: Icon(Icons.present_to_all)),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 5),
//               ],
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(hadir, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(sakit, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(izin, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(cuti, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//             ],
//           ));
//     } else {
//       print('sakit ${hadir}');
//       return new Container(
//           margin: const EdgeInsets.only(top: 10.0),
//           child: new Column(
//             children: <Widget>[
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title: Text(storing,
//                             style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(hadir, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(sakit, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(izin, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 5),
//               new InkWell(
//                 onTap: () {
//                   print('On Tap');
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.blue, Colors.blue],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, spreadRadius: 1),
//                     ],
//                   ),
//                   height: 70,
//                   child: Center(
//                     child: ListTile(
//                         title:
//                             Text(cuti, style: TextStyle(color: Colors.white)),
//                         trailing: Icon(Icons.present_to_all)),
//                   ),
//                 ),
//               ),
//             ],
//           ));
//     }
//   }
//
//
//   final auth = LocalAuthentication();
//   String authorized = " not authorized";
//   bool _canCheckBiometric = false;
//   List<BiometricType> _availableBiometric;
//
//   Future<void> _authenticate() async {
//     bool authenticated = false;
//     try {
//       authenticated = await auth.authenticateWithBiometrics(
//           localizedReason: "Scan your finger to authenticate",
//           useErrorDialogs: true,
//           stickyAuth: true);
//     } on PlatformException catch (e) {
//       print(e);
//     }
//     setState(() {
//       authorized =
//           authenticated ? "Authorized success" : "Failed to authenticate";
//       print(authorized);
//     });
//     Timer(Duration(seconds: 1), () {
//       // 5s over, navigate to a new page
//       if (authorized == "Authorized success") {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => FrmAttendance()));
//       } else {
//         alert(
//             globalScaffoldKey.currentContext,
//             0,
//             "Authentication finger failed, silahkan kontak Administrator",
//             "error");
//       }
//     });
//   }
//
//   Future<void> _checkBiometric() async {
//     bool canCheckBiometric = false;
//
//     try {
//       bool isBiometricSupported = await auth.isDeviceSupported();
//       canCheckBiometric = await auth.canCheckBiometrics;
//       if (!isBiometricSupported && !canCheckBiometric) {
//         alert(globalScaffoldKey.currentContext, 0,
//             "Device not supported finger", "error");
//       } else {
//         print(canCheckBiometric);
//       }
//     } on PlatformException catch (e) {
//       print(e);
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       _canCheckBiometric = canCheckBiometric;
//     });
//   }
//
//   Future _getAvailableBiometric() async {
//     List<BiometricType> availableBiometric = [];
//
//     try {
//       availableBiometric = await auth.getAvailableBiometrics();
//       //print('availableBiometric');
//       //print(availableBiometric.elementAt(0));
//     } on PlatformException catch (e) {
//       print(e);
//     }
//
//     setState(() {
//       _availableBiometric = availableBiometric;
//     });
//   }
//
//   var selectedIndexBottom = 0;
//   var countNotif = 0;
//
//   void UpdateMenuBottom() async {
//     if (selectedIndexBottom == 0) {
//       var isOK = globals.akses_pages == null
//           ? globals.akses_pages
//           : globals.akses_pages.where((x) => x == "OP");
//       if (isOK != null) {
//         if (isOK.length > 0 || username == 'ADMIN') {
//           EasyLoading.show();
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (context) => ViewListStoring()));
//         } else {
//           alert(globalScaffoldKey.currentContext, 0, "Anda tidak punya akses",
//               "error");
//         }
//       } else {
//         alert(globalScaffoldKey.currentContext, 0, "Anda tidak punya akses",
//             "error");
//       }
//     }
//     if (selectedIndexBottom == 1) {
//       if (loginname == "DRIVER") {
//         EasyLoading.show();
//         var tokenAuth = new GenerateTokenAuth();
//         var _tokens = await tokenAuth.GetTokenEasyGo("easygo".toString(), pr);
//         if (_tokens != "" && _tokens != null) {
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString("page", "dashboard");
//           prefs.setString("tokeneasygo", _tokens);
//           prefs.setString("is_driver", "true");
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (context) => LiveMaps()));
//         } else {
//           alert(globalScaffoldKey.currentContext, 0, "Terjadi kesalahan server",
//               "error");
//         }
//       } else {
//         var isOK = globals.akses_pages == null
//             ? globals.akses_pages
//             : globals.akses_pages.where((x) =>
//                 x == "MT" || x == "OP" || x == "OK" || x == "OT" || x == "UA");
//         if (isOK != null) {
//           if (isOK.length > 0 ||
//               loginname == "MECHANIC" ||
//               username == 'ADMIN') {
//             var tokenAuth = new GenerateTokenAuth();
//             var _tokens =
//                 await tokenAuth.GetTokenEasyGo("easygo".toString(), pr);
//             if (_tokens != "" && _tokens != null) {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.setString("page", "dashboard");
//               prefs.setString("tokeneasygo", _tokens);
//               prefs.setString("is_driver", "false");
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => LiveMaps()));
//             } else {
//               alert(globalScaffoldKey.currentContext, 0,
//                   "Terjadi kesalahan server", "error");
//             }
//           } else {
//             alert(globalScaffoldKey.currentContext, 0, "Anda tidak punya akses",
//                 "error");
//           }
//         } else {
//           print('globals.akses_pages ${globals.akses_pages}');
//           alert(
//               globalScaffoldKey.currentContext, 0, "Dont Have Access", "error");
//         }
//       }
//     }
//     if (selectedIndexBottom == 2) {
//       EasyLoading.show();
//       Timer(Duration(seconds: 1), () {
//         // 5s over, navigate to a new page
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => ViewProfileUser()));
//       });
//     }
//   }
//
//   int pageIndex = 0;
//   bool extended = true;
//   final pages = [];
//   List<dynamic> data_list_do = [];
//   void GetListDo() async {
//     try {
//       final JsonDecoder _decoder = new JsonDecoder();
//       sharedPreferences = await SharedPreferences.getInstance();
//       String drvid = sharedPreferences.getString("drvid");
//       String vhcid = sharedPreferences.getString("vhcid");
//       var vDo = sharedPreferences.getString("vhcidfromdo");
//       var urlData =
//           "${GlobalData.baseUrlProd}api/do/list_do_driver.jsp?method=lookup-list-do-driver-v1&vhcid=${vhcid}&drvid=${drvid}";
//       Uri myUri = Uri.parse(urlData);
//       print(myUri.toString());
//       var response =
//           await http.get(myUri, headers: {"Accept": "application/json"});
//       setState(() {
//         if (response.statusCode == 200) {
//           data_list_do = json.decode(response.body);
//         }
//         print("data_list_do");
//         print(data_list_do);
//       });
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Widget MenuStatusCard(
//       {IconData icon, String label, String value, Gradient gradient}) {
//     return Expanded(
//       child: Container(
//         margin: EdgeInsets.symmetric(
//             horizontal: 5), // Add minimal spacing between boxes
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           gradient: gradient,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.white, size: 30),
//                 Spacer(),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   var status_unit = '';
//   Widget DetailStatusDokDriver(
//       {IconData icon, String label, String value, Gradient gradient}) {
//     if (loginname == "DRIVER" || username == "ADMIN") {
//       print("${MenuStatusCard} ${loginname}");
//       var fromKir = '';
//       var toKir = '';
//       var fromSTNK = '';
//       var toSTNK = '';
//       var fromSIM = '';
//       var toSIM = '';
//
//       for (var i = 0; i < data.length; i++) {
//         print(data[i]['name']);
//         if (data[i]['name'] != null) {
//           if (data[i]['name'] == 'status_unit') {
//             status_unit = data[i]['status'] == null
//                 ? ''
//                 : data[i]['status'].toString().toUpperCase();
//           } else if (data[i]['name'] == 'sim') {
//             fromSIM = data[i]['from'] == null
//                 ? ''
//                 : data[i]['from'].toString().toUpperCase();
//             toSIM = data[i]['to'] == null
//                 ? ''
//                 : data[i]['to'].toString().toUpperCase();
//           } else if (data[i]['name'] == 'stnk') {
//             fromSTNK = data[i]['from'] == null
//                 ? ''
//                 : data[i]['from'].toString().toUpperCase();
//             toSTNK = data[i]['to'] == null
//                 ? ''
//                 : data[i]['to'].toString().toUpperCase();
//           } else if (data[i]['name'] == 'kir') {
//             fromKir = data[i]['from'] == null
//                 ? ''
//                 : data[i]['from'].toString().toUpperCase();
//             toKir = data[i]['to'] == null
//                 ? ''
//                 : data[i]['to'].toString().toUpperCase();
//           }
//         }
//       }
//       print(status_unit);
//       print(fromSIM);
//       print(toSIM);
//       print("LABEL ${label}");
//       if (label == "SIM") {
//         return Expanded(
//           child: new InkWell(
//             onTap: () async {
//               print('SIM');
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.setString("view_name", "SIM");
//               EasyLoading.show();
//               Navigator.pushReplacement(context,
//                   MaterialPageRoute(builder: (context) => ViewPhotoVehicle()));
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 5), // Add minimal spacing between boxes
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 gradient: gradient,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(icon, color: Colors.white, size: 20),
//                       Spacer(),
//                       Text(
//                         "${fromSIM}\n${toSIM}",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       } else if (label == "STNK") {
//         return Expanded(
//           child: new InkWell(
//             onTap: () async {
//               print('stnk');
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.setString("view_name", "STNK");
//               EasyLoading.show();
//               Navigator.pushReplacement(context,
//                   MaterialPageRoute(builder: (context) => ViewPhotoVehicle()));
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 5), // Add minimal spacing between boxes
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 gradient: gradient,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(icon, color: Colors.white, size: 20),
//                       Spacer(),
//                       Text(
//                         "(${fromSTNK}\n${toSTNK})",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       } else if (label == "KIR") {
//         return Expanded(
//           child: new InkWell(
//             onTap: () async {
//               print('kir');
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.setString("view_name", "KIR");
//               EasyLoading.show();
//               Navigator.pushReplacement(context,
//                   MaterialPageRoute(builder: (context) => ViewPhotoVehicle()));
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 5), // Add minimal spacing between boxes
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 gradient: gradient,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(icon, color: Colors.white, size: 20),
//                       Spacer(),
//                       Text(
//                         "(${fromKir}\n${toKir})",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       } else if (label == "FAMILY") {
//         return Expanded(
//           child: new InkWell(
//             onTap: () async {
//               print('photo keluarga');
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.setString("view_name", "FAMILY");
//               EasyLoading.show();
//               Navigator.pushReplacement(context,
//                   MaterialPageRoute(builder: (context) => ViewPhotoVehicle()));
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 5), // Add minimal spacing between boxes
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 gradient: gradient,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(icon, color: Colors.white, size: 20),
//                       Spacer(),
//                       Text(
//                         "Photo\nKeluarga",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       } else if (label == "DOMISILI") {
//         return Expanded(
//           child: new InkWell(
//             onTap: () async {
//               print('photo domisili');
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               prefs.setString("view_name", "DOMISILI");
//               EasyLoading.show();
//               Navigator.pushReplacement(context,
//                   MaterialPageRoute(builder: (context) => ViewPhotoVehicle()));
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 5), // Add minimal spacing between boxes
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 gradient: gradient,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(icon, color: Colors.white, size: 20),
//                       Spacer(),
//                       Text(
//                         "Photo\nDomisili",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       } else {
//         return Container();
//       }
//     } else if (label=="MECHANIC" || loginname=="MECHANIC") {
//
//       var out_standing_jobs = "0";
//       for (var i = 0; i < data.length; i++) {
//         if (data[i]['status'] != null && data[i]['status'] != 'null') {
//           out_standing_jobs = data[i]['status'];
//         }
//       }
//       print("${loginname} ${out_standing_jobs}");
//       if(data.length>0){
//         return Expanded(
//           child: new InkWell(
//             onTap: () async {
//               print('ViewListWoMCN');
//               EasyLoading.show();
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           ViewListWoMCN()));
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 5), // Add minimal spacing between boxes
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 gradient: gradient,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(icon, color: Colors.white, size: 20),
//                       Spacer(),
//                       Text(
//                         "OUT STANDING JOBS= ${out_standing_jobs}\n\n",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }else{
//         return Container();
//       }
//
//     }
//   }
//   Widget walletIconButton(IconData icon, Color color, String label) {
//
//     var fromKir = '';
//     var toKir = '';
//     var fromSTNK = '';
//     var toSTNK = '';
//     var fromSIM = '';
//     var toSIM = '';
//
//     for (var i = 0; i < data.length; i++) {
//       print(data[i]['name']);
//       if (data[i]['name'] != null) {
//         if (data[i]['name'] == 'status_unit') {
//           status_unit = data[i]['status'] == null
//               ? ''
//               : data[i]['status'].toString().toUpperCase();
//         } else if (data[i]['name'] == 'sim') {
//           fromSIM = data[i]['from'] == null
//               ? ''
//               : data[i]['from'].toString().toUpperCase();
//           toSIM = data[i]['to'] == null
//               ? ''
//               : data[i]['to'].toString().toUpperCase();
//         } else if (data[i]['name'] == 'stnk') {
//           fromSTNK = data[i]['from'] == null
//               ? ''
//               : data[i]['from'].toString().toUpperCase();
//           toSTNK = data[i]['to'] == null
//               ? ''
//               : data[i]['to'].toString().toUpperCase();
//         } else if (data[i]['name'] == 'kir') {
//           fromKir = data[i]['from'] == null
//               ? ''
//               : data[i]['from'].toString().toUpperCase();
//           toKir = data[i]['to'] == null
//               ? ''
//               : data[i]['to'].toString().toUpperCase();
//         }
//       }
//     }
//     print(status_unit);
//     print(fromSIM);
//     print(toSIM);
//     return Column(
//       children: [
//         CircleAvatar(
//           backgroundColor: color,
//           radius: 24,
//           child: Icon(icon, color: Colors.white),
//         ),
//         SizedBox(height: 5),
//         // You can replace below with actual wallet names like "Shopee", "Link Aja", etc.
//         Text(
//           "Status (${status_unit})",
//           style: TextStyle(fontSize: 12, color: Colors.black87),
//         ),
//       ],
//     );
//   }
//
//   Widget ListTimeLineDo() {
//     return new SizedBox(
//         width: double.infinity,
//         height: 350,
//         child: new Container(
//             margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
//             padding: const EdgeInsets.all(3.0),
//             decoration: BoxDecoration(
//               //border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(color: Colors.grey, spreadRadius: 0.1),
//               ],
//             ),
//             child: ListView.builder(
//               itemCount: data_list_do == null ? 0 : data_list_do.length,
//               //key: RIKeys.riKey1,
//               itemBuilder: (context, index) {
//                 final data = _data(0, index, data_list_do[index]);
//                 return Center(
//                   child: Container(
//                     width: 360.0,
//                     child: Card(
//                       margin: EdgeInsets.all(20.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Text(
//                           //   "Jadwal hari ini",
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: _OrderTitle(
//                               orderInfo: data, //LIST DATA DO
//                             ),
//                           ),
//                           Divider(height: 1.0),
//                           _DeliveryProcesses(processes: data.deliveryProcesses),
//                           Divider(height: 1.0),
//                           Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: _OnTimeBar(
//                                 list_do: data_list_do[index],
//                                 loginname: loginname),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             )));
//   }
//
//   Future<ImageProvider> _loadImage(String url) async {
//     try {
//       final image = NetworkImage(url);
//       await image.obtainKey(const ImageConfiguration()); // Preload to check if the image is valid
//       return image; // Return the image if it loads successfully
//     } catch (e) {
//       throw Exception("Image not found"); // Throw an error if the image fails to load
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//         child: new Scaffold(
//       backgroundColor: Color(0xFFFDEDB1),
//       body: Stack(
//         key: globalScaffoldKey,
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Image.asset(
//               'assets/img/bg_top.png',
//               width: double.infinity,
//               fit: BoxFit.cover,
//               height: 200, // Height of the top background image
//             ),
//           ),
//           Container(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     width: double.infinity + 50,
//                     margin: const EdgeInsets.only(
//                         top: 50, right: 10, left: 10, bottom: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${firstName}',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               '${vhcid} ${loginname=="DRIVER"?"(${status_unit})":""}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if(loginname=="DRIVER")...[
//                         FutureBuilder(
//                           future: _loadImage('https://apps.tuluatas.com/trucking/photo_trucking/PHOTO_DRIVER/${driver_id_image}'), // Invalid URL example
//                           builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
//                             if (snapshot.connectionState == ConnectionState.done) {
//                               if (snapshot.hasError) {
//                                 return CircleAvatar(
//                                   backgroundImage: AssetImage('https://apps.tuluatas.com/trucking/carousel/profile_user.jpg'), // Fallback image
//                                   radius: 30,
//                                 );
//                               } else {
//                                 return CircleAvatar(
//                                   backgroundImage: snapshot.data, // Successfully loaded image
//                                   radius: 30,
//                                 );
//                               }
//                             } else {
//                               return CircularProgressIndicator(); // Loading state
//                             }
//                           },
//                         )
//                         ]else...[
//                         CircleAvatar(
//                           radius: 30.0, // Adjust the size accordingly
//                           backgroundImage: NetworkImage(
//                           'https://apps.tuluatas.com/trucking/carousel/profile_user.jpg'),
//
//                         )],
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.only(
//                         top: 5, right: 10, left: 10, bottom: 0),
//                     padding: const EdgeInsets.only(
//                         top: 5, right: 5, left: 5, bottom: 15),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF4F4F4),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10.0),
//                         topRight: Radius.circular(10.0),
//                         bottomLeft: Radius.circular(10.0),
//                         bottomRight: Radius.circular(10.0),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // const Text(
//                           //   'Role',
//                           //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           // ),
//                           // const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               GestureDetector(
//                                   onTap: () async {
//                                     if (loginname == "DRIVER") {
//                                       EasyLoading.show();
//                                       var tokenAuth = new GenerateTokenAuth();
//                                       var _tokens =
//                                           await tokenAuth.GetTokenEasyGo(
//                                               "easygo".toString(), pr);
//                                       print("Token Easygo ${_tokens}");
//                                       if (_tokens != "" && _tokens != null) {
//                                         SharedPreferences prefs =
//                                             await SharedPreferences
//                                                 .getInstance();
//                                         prefs.setString("page", "dashboard");
//                                         prefs.setString("tokeneasygo", _tokens);
//                                         prefs.setString("is_driver", "true");
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     LiveMaps()));
//                                       } else {
//                                         alert(
//                                             globalScaffoldKey.currentContext,
//                                             0,
//                                             "Terjadi kesalahan server",
//                                             "error");
//                                       }
//                                     } else {
//                                       var isOK = globals.akses_pages == null
//                                           ? globals.akses_pages
//                                           : globals.akses_pages.where((x) =>
//                                               x == "MT" ||
//                                               x == "OP" ||
//                                               x == "OK" ||
//                                               x == "OT" ||
//                                               x == "UA");
//                                       if (isOK != null) {
//                                         print('IS OK ${isOK}');
//                                         if (isOK.length > 0 ||
//                                             loginname == "MECHANIC" ||
//                                             loginname == "DRIVER" ||
//                                             loginname == "DISPATCHER") {
//                                           print('Login maps ${loginname}');
//                                           var tokenAuth =
//                                               new GenerateTokenAuth();
//                                           var _tokens =
//                                               await tokenAuth.GetTokenEasyGo(
//                                                   "easygo".toString(), pr);
//                                           print("Token Easygo ${_tokens}");
//                                           if (_tokens != "" &&
//                                               _tokens != null) {
//                                             SharedPreferences prefs =
//                                                 await SharedPreferences
//                                                     .getInstance();
//                                             prefs.setString(
//                                                 "page", "dashboard");
//                                             prefs.setString(
//                                                 "tokeneasygo", _tokens);
//                                             prefs.setString(
//                                                 "is_driver", "false");
//                                             Navigator.pushReplacement(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         LiveMaps()));
//                                           } else {
//                                             alert(
//                                                 globalScaffoldKey
//                                                     .currentContext,
//                                                 0,
//                                                 "Terjadi kesalahan server",
//                                                 "error");
//                                           }
//                                         } else {
//                                           alert(
//                                               globalScaffoldKey.currentContext,
//                                               0,
//                                               "Anda tidak punya akses",
//                                               "error");
//                                         }
//                                       } else {
//                                         print(
//                                             'globals.akses_pages ${globals.akses_pages}');
//                                         alert(globalScaffoldKey.currentContext,
//                                             0, "Dont Have Access", "error");
//                                       }
//                                     }
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           //color: Colors.blue,
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/ic_maps.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'Maps',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   )),
//                               GestureDetector(
//                                   onTap: () async {
//                                     EasyLoading.show();
//                                     Timer(Duration(seconds: 1), () {
//                                       // 5s over, navigate to a new page
//                                       var isOK = globals.akses_pages == null
//                                           ? globals.akses_pages
//                                           : globals.akses_pages.where((x) =>
//                                               x == "OP" ||
//                                               x == "OK" ||
//                                               x == "OT" ||
//                                               x == "UA");
//                                       if (loginname == "DRIVER") {
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     ViewListDo()));
//                                       } else if (isOK != null) {
//                                         if (isOK.length > 0) {
//                                           Navigator.pushReplacement(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ViewListDoOpr()));
//                                         } else {
//                                           alert(
//                                               globalScaffoldKey.currentContext,
//                                               0,
//                                               "Anda tidak punya akses",
//                                               "error");
//                                         }
//                                       } else {
//                                         Navigator.of(context).pop(false);
//                                         alert(globalScaffoldKey.currentContext,
//                                             0, "Access Denied", "error");
//                                       }
//                                     });
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           //color: Colors.blue,
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/box-add.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'Terima DO',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   )),
//                               GestureDetector(
//                                   onTap: () async {
//                                     if (loginname == "DRIVER") {
//                                       // SharedPreferences prefs =
//                                       //     await SharedPreferences.getInstance(); //DEVELOPMENT
//                                       //prefs.setString("vhcidfromdo",'B 9948 KYV');
//                                       GetVhcidDo();
//                                       EasyLoading.show();
//                                       Timer(Duration(seconds: 1), () {
//                                         // 5s over, navigate to a new page
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     FrmSetKmByDriver()));
//                                       });
//                                     } else {
//                                       await showDialog(
//                                         context:
//                                             globalScaffoldKey.currentContext,
//                                         builder: (context) => new AlertDialog(
//                                           title: new Text('Information'),
//                                           content:
//                                               new Text("Acces Menu For Driver"),
//                                           actions: <Widget>[
//                                             new TextButton(
//                                               onPressed: () async {
//                                                 Navigator.of(context).pop(true);
//                                               },
//                                               child: new Text('Ok'),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           //color: Colors.blue,
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/box-remove.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'Close DO',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   )),
//                               GestureDetector(
//                                   onTap: () async {
//                                     if (loginname == "DRIVER") {
//                                       EasyLoading.show();
//                                       Timer(Duration(seconds: 1), () {
//                                         // 5s over, navigate to a new page
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     ViewListRitase()));
//                                       });
//                                     } else {
//                                       await showDialog(
//                                         context:
//                                             globalScaffoldKey.currentContext,
//                                         builder: (context) => new AlertDialog(
//                                           title: new Text('Information'),
//                                           content:
//                                               new Text("Acces Menu For Driver"),
//                                           actions: <Widget>[
//                                             new TextButton(
//                                               onPressed: () async {
//                                                 Navigator.of(context).pop(true);
//                                               },
//                                               child: new Text('Ok'),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           //color: Colors.black26,
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/routing.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'Ritase',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   )),
//                             ],
//                           ),
//                           const SizedBox(height: 5),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               if (loginname != 'DRIVER') ...[
//                                 GestureDetector(
//                                   onTap: () async {
//                                     if (loginname == "DRIVER") {
//                                       EasyLoading.show();
//                                       Timer(Duration(seconds: 1), () async {
//                                         // 5s over, navigate to a new page
//                                         SharedPreferences prefs =
//                                             await SharedPreferences
//                                                 .getInstance();
//                                         prefs.setString(
//                                             "page_antrian", "NOBUJNUMBER");
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     FrmCreateAntrianNewDriver()));
//                                       });
//                                     } else {
//                                       var isOK = globals.akses_pages == null
//                                           ? globals.akses_pages
//                                           : globals.akses_pages.where((x) =>
//                                               x == "HR" ||
//                                               x == "HD" ||
//                                               x == "UA");
//                                       if (isOK != null) {
//                                         if (isOK.length > 0) {
//                                           showDialog(
//                                             context: context,
//                                             builder: (context) =>
//                                                 new AlertDialog(
//                                               title: new Text('Information'),
//                                               content: new Text(
//                                                   "Gunakan maps untuk pencarian lokasi ?"),
//                                               actions: <Widget>[
//                                                 new ElevatedButton.icon(
//                                                   icon: Icon(
//                                                     Icons.close,
//                                                     color: Colors.white,
//                                                     size: 20.0,
//                                                   ),
//                                                   label: Text("No"),
//                                                   onPressed: () async {
//                                                     Navigator.of(context)
//                                                         .pop(false);
//                                                     SharedPreferences prefs =
//                                                         await SharedPreferences
//                                                             .getInstance();
//                                                     prefs.setBool(
//                                                         "is_edit", false);
//                                                     prefs.setString(
//                                                         "driver_id", "");
//                                                     prefs.setString(
//                                                         "lat_lon", "");
//                                                     Navigator.pushReplacement(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder: (context) =>
//                                                                 RegisterNewDriver()));
//                                                   },
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                           elevation: 0.0,
//                                                           backgroundColor: //                                                               Colors.deepOrange,
//                                                           padding: EdgeInsets
//                                                               .symmetric(
//                                                                   horizontal:
//                                                                       10,
//                                                                   vertical: 0),
//                                                           textStyle: TextStyle(
//                                                               fontSize: 10,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold)),
//                                                 ),
//                                                 new ElevatedButton.icon(
//                                                   icon: Icon(
//                                                     Icons.save,
//                                                     color: Colors.white,
//                                                     size: 20.0,
//                                                   ),
//                                                   label: Text("Yes"),
//                                                   onPressed: () async {
//                                                     Navigator.of(context)
//                                                         .pop(false);
//                                                     SharedPreferences prefs =
//                                                         await SharedPreferences
//                                                             .getInstance();
//                                                     prefs.setBool(
//                                                         "is_edit", false);
//                                                     prefs.setString(
//                                                         "driver_id", "");
//                                                     prefs.setString(
//                                                         "lat_lon", "");
//
//                                                     EasyLoading.show();
//                                                     Navigator.pushReplacement(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                             builder: (context) =>
//                                                                 MapAddress()));
//                                                     // Navigator.pushReplacement(
//                                                     //     context,
//                                                     //     MaterialPageRoute(
//                                                     //         builder: (context) => RegisterNewDriver()));
//                                                   },
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                           elevation: 0.0,
//                                                           backgroundColor: Colors.blue,
//                                                           padding: EdgeInsets
//                                                               .symmetric(
//                                                                   horizontal:
//                                                                       10,
//                                                                   vertical: 0),
//                                                           textStyle: TextStyle(
//                                                               fontSize: 10,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold)),
//                                                 ),
//                                               ],
//                                             ),
//                                           );
//                                         } else {
//                                           alert(
//                                               globalScaffoldKey.currentContext,
//                                               0,
//                                               "Anda tidak punya akses",
//                                               "error");
//                                         }
//                                       } else {
//                                         await showDialog(
//                                           context:
//                                               globalScaffoldKey.currentContext,
//                                           builder: (context) => new AlertDialog(
//                                             title: new Text('Information'),
//                                             content: new Text(
//                                                 "Acces Menu For Operasional"),
//                                             actions: <Widget>[
//                                               new TextButton(
//                                                 onPressed: () async {
//                                                   Navigator.of(context)
//                                                       .pop(true);
//                                                 },
//                                                 child: new Text('Ok'),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           //color: Colors.blue,
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/new_driver.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'New Driver',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     if (loginname == "DRIVER") {
//                                       alert(globalScaffoldKey.currentContext, 0,
//                                           "Access Not Allowed", "error");
//                                     } else {
//                                       //_authenticate();
//                                       EasyLoading.show();
//                                       Timer(Duration(seconds: 1), () {
//                                         // 5s over, navigate to a new page
//                                         Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     FrmAttendance()));
//                                       });
//                                     }
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                           //color: Colors.blue,
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/calendar.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'Attendance',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                               GestureDetector(
//                                 onTap: () async {
//                                   if (loginname == "DRIVER") {
//                                     EasyLoading.show();
//                                     Timer(Duration(seconds: 1), () {
//                                       // 5s over, navigate to a new page
//                                       Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   ViewListPelanggaran()));
//                                     });
//                                   } else {
//                                     await showDialog(
//                                       context: globalScaffoldKey.currentContext,
//                                       builder: (context) => new AlertDialog(
//                                         title: new Text('Information'),
//                                         content:
//                                             new Text("Acces Menu For Driver"),
//                                         actions: <Widget>[
//                                           new TextButton(
//                                             onPressed: () async {
//                                               Navigator.of(context).pop(true);
//                                             },
//                                             child: new Text('Ok'),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }
//                                 },
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(10.0),
//                                       decoration: BoxDecoration(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0),
//                                         //color: Colors.blue,
//                                       ),
//                                       child: Image.asset(
//                                         'assets/img/warning-2.png',
//                                         width: 25,
//                                         fit: BoxFit.cover,
//                                         height:
//                                             25, // Height of the top background image
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     const Text(
//                                       'Pelanggaran',
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (loginname != 'DRIVER') ...[
//                                 GestureDetector(
//                                   onTap: () {
//                                     showModalBottomSheet(
//                                       context: context,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.vertical(
//                                             top: Radius.circular(20.0)),
//                                       ),
//                                       isScrollControlled: true,
//                                       builder: (BuildContext context) {
//                                         return DraggableScrollableSheet(
//                                           initialChildSize:
//                                               0.5, // Initial size of the modal
//                                           minChildSize:
//                                               0.3, // Minimum height the sheet can be dragged to
//                                           maxChildSize:
//                                               1.0, // Maximum height the sheet can be dragged to
//                                           expand:
//                                               false, // Allows the sheet to shrink back when the user drags down
//                                           builder: (BuildContext context,
//                                               ScrollController
//                                                   scrollController) {
//                                             return Container(
//                                               padding:
//                                                   const EdgeInsets.all(16.0),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                                 borderRadius:
//                                                     BorderRadius.vertical(
//                                                         top: Radius.circular(
//                                                             20.0)),
//                                               ),
//                                               child: Column(
//                                                 children: [
//                                                   Container(
//                                                     height: 4,
//                                                     width: 50,
//                                                     margin:
//                                                         EdgeInsets.symmetric(
//                                                             vertical: 8),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.grey.shade300,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               20),
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     child: ListView(
//                                                       controller:
//                                                           scrollController,
//                                                       children: [
//                                                         Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .spaceAround,
//                                                               children: [
//                                                                 GestureDetector(
//                                                                   onTap:
//                                                                       () async {
//                                                                     print(
//                                                                         'P2h');
//                                                                     if (loginname ==
//                                                                             "DRIVER" &&
//                                                                         ismixer ==
//                                                                             "false") {
//                                                                       alert(
//                                                                           globalScaffoldKey
//                                                                               .currentContext,
//                                                                           0,
//                                                                           "Access Not Allowed",
//                                                                           "error");
//                                                                     } else {
//                                                                       if (ismixer ==
//                                                                           "true") {
//                                                                         if (EasyLoading
//                                                                             .isShow) {
//                                                                           EasyLoading
//                                                                               .dismiss();
//                                                                         }
//                                                                         EasyLoading
//                                                                             .show();
//                                                                         Timer(
//                                                                             Duration(seconds: 1),
//                                                                             () {
//                                                                           // 5s over, navigate to a new page
//                                                                           Navigator.pushReplacement(
//                                                                               context,
//                                                                               MaterialPageRoute(builder: (context) => ListDriverInspeksi()));
//                                                                         });
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x == "OP" ||
//                                                                                 x == "OK" ||
//                                                                                 x == "OT" ||
//                                                                                 x == "UA");
//                                                                         if (isOK !=
//                                                                             null) {
//                                                                           if (isOK.length >
//                                                                               0) {
//                                                                             if (EasyLoading.isShow) {
//                                                                               EasyLoading.dismiss();
//                                                                             }
//                                                                             EasyLoading.show();
//                                                                             Timer(Duration(seconds: 1),
//                                                                                 () {
//                                                                               // 5s over, navigate to a new page
//                                                                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListDriverInspeksi()));
//                                                                             });
//                                                                           } else {
//                                                                             alert(
//                                                                                 globalScaffoldKey.currentContext,
//                                                                                 0,
//                                                                                 "Anda tidak punya akses",
//                                                                                 "error");
//                                                                           }
//                                                                         } else {
//                                                                           await showDialog(
//                                                                             context:
//                                                                                 globalScaffoldKey.currentContext,
//                                                                             builder: (context) =>
//                                                                                 new AlertDialog(
//                                                                               title: new Text('Information'),
//                                                                               content: new Text("Acces Menu For OP/OK/OT"),
//                                                                               actions: <Widget>[
//                                                                                 new TextButton(
//                                                                                   onPressed: () async {
//                                                                                     Navigator.of(context).pop(true);
//                                                                                   },
//                                                                                   child: new Text('Ok'),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           );
//                                                                         }
//                                                                       }
//                                                                     }
//                                                                   },
//                                                                   child: Column(
//                                                                     children: [
//                                                                       Container(
//                                                                         padding:
//                                                                             const EdgeInsets.all(10.0),
//                                                                         decoration:
//                                                                             BoxDecoration(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(10.0),
//                                                                           //color: Colors.blue,
//                                                                         ),
//                                                                         child: Image
//                                                                             .asset(
//                                                                           'assets/img/menu_p2h.jpg',
//                                                                           width:
//                                                                               25,
//                                                                           fit: BoxFit
//                                                                               .cover,
//                                                                           height:
//                                                                               25, // Height of the top background image
//                                                                         ),
//                                                                       ),
//                                                                       const SizedBox(
//                                                                           height:
//                                                                               5),
//                                                                       const Text(
//                                                                         'P2H',
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 12),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x == "OP" ||
//                                                                                 x == "SA" ||
//                                                                                 x == "FO" ||
//                                                                                 username == "ADMIN");
//                                                                         if (isOK !=
//                                                                             null) {
//                                                                           if (isOK.length >
//                                                                               0) {
//                                                                             EasyLoading.show();
//                                                                             // Timer(Duration(seconds: 1), () {
//                                                                             //   Navigator.pushReplacement(
//                                                                             //       context,
//                                                                             //       MaterialPageRoute(
//                                                                             //           builder: (context) =>
//                                                                             //               FrmServiceRequestOprPM()));
//                                                                             // });
//                                                                             Timer(Duration(seconds: 1),
//                                                                                 () {
//                                                                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FrmServiceRequestOprPM()));
//                                                                             });
//                                                                           } else {
//                                                                             alert(
//                                                                                 globalScaffoldKey.currentContext,
//                                                                                 0,
//                                                                                 "Access Not Allowed",
//                                                                                 "error");
//                                                                           }
//                                                                         } else {
//                                                                           alert(
//                                                                               globalScaffoldKey.currentContext,
//                                                                               0,
//                                                                               "Access Not Allowed",
//                                                                               "error");
//                                                                         }
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_sr.png',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'SR',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x == "TY" ||
//                                                                                 username == "ADMIN");
//                                                                         if (isOK !=
//                                                                             null) {
//                                                                           if (isOK.length >
//                                                                               0) {
//                                                                             EasyLoading.show();
//                                                                             Timer(Duration(seconds: 1),
//                                                                                 () {
//                                                                               // 5s over, navigate to a new page
//                                                                               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FrmServiceRequestTms()));
//                                                                             });
//                                                                           } else {
//                                                                             alert(
//                                                                                 globalScaffoldKey.currentContext,
//                                                                                 0,
//                                                                                 "Access Not Allowed",
//                                                                                 "error");
//                                                                           }
//                                                                         } else {
//                                                                           alert(
//                                                                               globalScaffoldKey.currentContext,
//                                                                               0,
//                                                                               "Access Not Allowed",
//                                                                               "error");
//                                                                         }
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_tms.png',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'TMS',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                   onTap:
//                                                                       () async {
//                                                                     if (loginname ==
//                                                                         "DRIVER") {
//                                                                       alert(
//                                                                           globalScaffoldKey
//                                                                               .currentContext,
//                                                                           0,
//                                                                           "Access Not Allowed",
//                                                                           "error");
//                                                                     } else {
//                                                                       var isOK = globals.akses_pages ==
//                                                                               null
//                                                                           ? globals
//                                                                               .akses_pages
//                                                                           : globals.akses_pages.where((x) =>
//                                                                               x == "IN" ||
//                                                                               x == "IR" ||
//                                                                               x == "UA" ||
//                                                                               username == "ADMIN");
//                                                                       if (isOK !=
//                                                                           null) {
//                                                                         if (isOK.length >
//                                                                             0) {
//                                                                           EasyLoading
//                                                                               .show();
//                                                                           Timer(
//                                                                               Duration(seconds: 1),
//                                                                               () {
//                                                                             // 5s over, navigate to a new page
//                                                                             Navigator.pushReplacement(context,
//                                                                                 MaterialPageRoute(builder: (context) => ListInventoryTransNew()));
//                                                                           });
//                                                                         } else {
//                                                                           alert(
//                                                                               globalScaffoldKey.currentContext,
//                                                                               0,
//                                                                               "Access Not Allowed",
//                                                                               "error");
//                                                                         }
//                                                                       } else {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       }
//                                                                     }
//                                                                   },
//                                                                   child: Column(
//                                                                     children: [
//                                                                       Container(
//                                                                         padding:
//                                                                             const EdgeInsets.all(10.0),
//                                                                         decoration:
//                                                                             BoxDecoration(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(10.0),
//                                                                           //color: Colors.black26,
//                                                                         ),
//                                                                         child: Image
//                                                                             .asset(
//                                                                           'assets/img/menu_inventory.jpg',
//                                                                           width:
//                                                                               25,
//                                                                           fit: BoxFit
//                                                                               .cover,
//                                                                           height:
//                                                                               25, // Height of the top background image
//                                                                         ),
//                                                                       ),
//                                                                       const SizedBox(
//                                                                           height:
//                                                                               5),
//                                                                       const Text(
//                                                                         'Inventory',
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 14),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 )
//                                                               ],
//                                                             ),
//                                                             const SizedBox(
//                                                                 height: 5),
//                                                             Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .spaceAround,
//                                                               children: [
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         //_authenticate();
//                                                                         EasyLoading
//                                                                             .show();
//                                                                         Timer(
//                                                                             Duration(seconds: 1),
//                                                                             () {
//                                                                           // 5s over, navigate to a new page
//                                                                           Navigator.pushReplacement(
//                                                                               context,
//                                                                               MaterialPageRoute(builder: (context) => FrmAttendanceAdvance()));
//                                                                         });
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_inventory.jpg',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'Att ADV',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x == "OP" ||
//                                                                                 x == "HR");
//                                                                         if (isOK !=
//                                                                             null) {
//                                                                           EasyLoading
//                                                                               .show();
//                                                                           Timer(
//                                                                               Duration(seconds: 1),
//                                                                               () {
//                                                                             // 5s over, navigate to a new page
//                                                                             Navigator.pushReplacement(context,
//                                                                                 MaterialPageRoute(builder: (context) => FrmAsset()));
//                                                                           });
//                                                                         }
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_performance.jpg',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'Perfrormance',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x ==
//                                                                                 "OP");
//                                                                         Timer(
//                                                                             Duration(seconds: 1),
//                                                                             () {
//                                                                           // 5s over, navigate to a new page
//                                                                           Navigator.pushReplacement(
//                                                                               context,
//                                                                               MaterialPageRoute(builder: (context) => FrmRequestMovingUnits()));
//                                                                         });
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/moving_unit.png',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'Moving Unit',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x == "OP" ||
//                                                                                 x == "HR");
//                                                                         if (isOK !=
//                                                                             null) {
//                                                                           EasyLoading
//                                                                               .show();
//                                                                           Timer(
//                                                                               Duration(seconds: 1),
//                                                                               () {
//                                                                             // 5s over, navigate to a new page
//                                                                             Navigator.pushReplacement(context,
//                                                                                 MaterialPageRoute(builder: (context) => FrmAsset()));
//                                                                           });
//                                                                         }
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_asset.jpg',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'EDP/ASSET',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     ))
//                                                               ],
//                                                             ),
//                                                             //ANOTHER
//                                                             const SizedBox(
//                                                                 height: 5),
//                                                             Row(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .spaceAround,
//                                                               children: [
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         var isOK = globals.akses_pages ==
//                                                                                 null
//                                                                             ? globals
//                                                                                 .akses_pages
//                                                                             : globals.akses_pages.where((x) =>
//                                                                                 x == "OP" ||
//                                                                                 x == "IN" ||
//                                                                                 x == "IR");
//                                                                         if (isOK !=
//                                                                             null) {
//                                                                           EasyLoading
//                                                                               .show();
//                                                                           Timer(
//                                                                               Duration(seconds: 1),
//                                                                               () {
//                                                                             // 5s over, navigate to a new page
//                                                                             Navigator.pushReplacement(context,
//                                                                                 MaterialPageRoute(builder: (context) => FrmWareHouseOpName()));
//                                                                           });
//                                                                         }
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_wh_opname.jpg',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'WH. Opname',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         alert(
//                                                                             globalScaffoldKey.currentContext,
//                                                                             0,
//                                                                             "Access Not Allowed",
//                                                                             "error");
//                                                                       } else {
//                                                                         //_authenticate();
//                                                                         EasyLoading
//                                                                             .show();
//                                                                         Timer(
//                                                                             Duration(seconds: 1),
//                                                                             () {
//                                                                           // 5s over, navigate to a new page
//                                                                           Navigator.pushReplacement(
//                                                                               context,
//                                                                               MaterialPageRoute(builder: (context) => FrmNonTera()));
//                                                                         });
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu_nontera.jpg',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'Non Tera',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     )),
//                                                                 GestureDetector(
//                                                                     onTap:
//                                                                         () async {
//                                                                       if (loginname ==
//                                                                           "DRIVER") {
//                                                                         print(
//                                                                             'Only DISPATCHER');
//                                                                       } else {
//                                                                         EasyLoading
//                                                                             .show();
//                                                                         Timer(
//                                                                             Duration(seconds: 1),
//                                                                             () {
//                                                                           // 5s over, navigate to a new page
//                                                                           Navigator.pushReplacement(
//                                                                               context,
//                                                                               MaterialPageRoute(builder: (context) => DetailMenu()));
//                                                                         });
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Container(
//                                                                           padding:
//                                                                               const EdgeInsets.all(10.0),
//                                                                           decoration:
//                                                                               BoxDecoration(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                             //color: Colors.blue,
//                                                                           ),
//                                                                           child:
//                                                                               Image.asset(
//                                                                             'assets/img/menu-more.png',
//                                                                             width:
//                                                                                 25,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                             height:
//                                                                                 25, // Height of the top background image
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 5),
//                                                                         const Text(
//                                                                           'Others',
//                                                                           style:
//                                                                               TextStyle(fontSize: 14),
//                                                                         ),
//                                                                       ],
//                                                                     ))
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(10.0),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10.0),
//                                         ),
//                                         child: Image.asset(
//                                           'assets/img/menu-more.png',
//                                           width: 25,
//                                           fit: BoxFit.cover,
//                                           height:
//                                               25, // Height of the top background image
//                                         ),
//                                       ),
//                                       const SizedBox(height: 5),
//                                       const Text(
//                                         'More',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                               if (loginname == 'DRIVER') ...[
//                                 //buildInfoDetail()
//                               ]
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   if (loginname == 'DRIVER' && data_list_do.length > 0) ...[
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
//                       child: Container(
//                         width: MediaQuery.of(context).size.width,
//                         child: InkWell(
//                           onTap: () {
//                             setState(() {
//                               if (extended == null || !extended)
//                                 extended = true;
//                               else
//                                 extended = false;
//                             });
//                           },
//                           enableFeedback: false,
//                           splashColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           child: Center(
//                             child: Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   SizedBox(
//                                     height: 10.0,
//                                   ),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Text(
//                                           'Jadwal hari ini',
//                                           style: TextStyle(fontSize: 16.0),
//                                         ),
//                                       ),
//                                       Icon(
//                                         extended
//                                             ? Icons.keyboard_arrow_down
//                                             : Icons.keyboard_arrow_right,
//                                         size: 26,
//                                         color: Colors.grey,
//                                       )
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 10.0,
//                                   ),
//                                   extended ? ListTimeLineDo() : Container()
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(7.0),
//                           ),
//                           boxShadow: <BoxShadow>[
//                             BoxShadow(
//                               color: Color.fromRGBO(0, 0, 0, 0.09),
//                               offset: Offset(0.0, -2.0),
//                               blurRadius: 12.0,
//                             ),
//                             BoxShadow(
//                               color: Color.fromRGBO(0, 0, 0, 0.09),
//                               offset: Offset(0.0, 6.0),
//                               blurRadius: 15.0,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                   if (loginname == 'DRIVER') ...[
//                     SizedBox(height: 5),
//                     Container(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             DetailStatusDokDriver(
//                               icon: Icons.email_rounded,
//                               label: "SIM",
//                               value: "Sim",
//                               gradient: LinearGradient(
//                                 colors: [Colors.white, Colors.grey],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             ),
//                             DetailStatusDokDriver(
//                               icon: Icons.email_outlined,
//                               label: "STNK",
//                               value: "Stnk",
//                               gradient: LinearGradient(
//                                 colors: [Colors.white, Colors.red],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             ),
//                             DetailStatusDokDriver(
//                               icon: Icons.email,
//                               label: "KIR",
//                               value: "Kir",
//                               gradient: LinearGradient(
//                                 colors: [Colors.white, Colors.orange],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             DetailStatusDokDriver(
//                               icon: Icons.people,
//                               label: "FAMILY",
//                               value: "Family",
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.white,
//                                   Colors.blueAccent.shade200
//                                 ],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             ),
//                             DetailStatusDokDriver(
//                               icon: Icons.location_on,
//                               label: "DOMISILI",
//                               value: "Domisili",
//                               gradient: LinearGradient(
//                                 colors: [Colors.white, Colors.green],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                   if(loginname == "MECHANIC")...[
//                     Container(
//                       margin: EdgeInsets.only(left: 15,right: 15),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             DetailStatusDokDriver(
//                               icon: Icons.settings,
//                               label: "MECHANIC",
//                               value: "Mechanic",
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Colors.white,
//                                   Colors.blueAccent.shade200
//                                 ],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                   if (loginname == 'MECHANIC' || username == 'ADMIN') ...[
//                     Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.only(
//                             top: 5, right: 10, left: 10, bottom: 10),
//                         padding: const EdgeInsets.all(5.0),
//                         decoration: BoxDecoration(
//                           //color: Color(0xFFF4F4F4),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10.0),
//                             topRight: Radius.circular(10.0),
//                             bottomLeft: Radius.circular(10.0),
//                             bottomRight: Radius.circular(10.0),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(0.0),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   MenuStatusCard(
//                                     icon: Icons.account_balance_wallet,
//                                     label: "Storing",
//                                     value:"${storing.replaceAll('Storing:', '')}",
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.white,
//                                         Colors.red
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         )),
//                     Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.only(
//                             top: 5, right: 10, left: 10, bottom: 10),
//                         padding: const EdgeInsets.all(5.0),
//                         decoration: BoxDecoration(
//                           //color: Color(0xFFF4F4F4),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10.0),
//                             topRight: Radius.circular(10.0),
//                             bottomLeft: Radius.circular(10.0),
//                             bottomRight: Radius.circular(10.0),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(0.0),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   MenuStatusCard(
//                                     icon: Icons.leave_bags_at_home,
//                                     label: "Cuti",
//                                     value: "${cuti.replaceAll('Cuti:', '')}",
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.orangeAccent.shade100,
//                                         Colors.orangeAccent.shade400
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   MenuStatusCard(
//                                     icon: Icons.transfer_within_a_station,
//                                     label: "Hadir",
//                                     value: "${hadir.replaceAll('Hadir:', '')}",
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.greenAccent.shade100,
//                                         Colors.greenAccent.shade400
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ),
//                                   ),
//                                   MenuStatusCard(
//                                     icon: Icons.refresh,
//                                     label: "Sakit",
//                                     value: "${sakit.replaceAll('Sakit:', '')}",
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.yellow.shade800,
//                                         Colors.yellow.shade900
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ),
//                                   ),
//                                   MenuStatusCard(
//                                     icon: Icons.exit_to_app,
//                                     label: "Izin s",
//                                     value: "${izin.replaceAll('Izin:', '')}",
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.orangeAccent.shade100,
//                                         Colors.orangeAccent.shade200
//                                       ],
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ],
//                           ),
//                         )),
//                   ]
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: pageIndex == 0
//                 ? countNotif > 0
//                     ? Badge(
//                         badgeContent: Text(countNotif.toString(),
//                             style: TextStyle(color: Colors.white)),
//                         child: Icon(
//                           Icons.work_outlined,
//                           // color: Colors.white,
//                           // size: 35,
//                         ),
//                       )
//                     : Icon(
//                         Icons.work_outlined,
//                         // color: Colors.white,
//                         // size: 35,
//                       )
//                 : countNotif > 0
//                     ? Badge(
//                         badgeContent: Text(countNotif.toString(),
//                             style: TextStyle(color: Colors.white)),
//                         child: Icon(
//                           Icons.work_outline_outlined,
//                           // color: Colors.white,
//                           // size: 35,
//                         ),
//                       )
//                     : Icon(
//                         Icons.work_outline_outlined,
//                         // color: Colors.white,
//                         // size: 35,
//                       ),
//             label: 'Work',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.location_pin),
//             label: 'Location',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         currentIndex: pageIndex,
//         onTap: (int index) {
//           setState(() {
//             pageIndex = index;
//             selectedIndexBottom = pageIndex;
//           });
//           UpdateMenuBottom();
//         },
//       ),
//     ));
//   }
//
//   @override
//   void initState() {
//     if (EasyLoading.isShow) {
//       EasyLoading.dismiss();
//     }
//     getDataPreference();
//     GetAbsensiSummary();
//     cekIsActiveUser();
//     GetCountStoring();
//     initUniqueIdentifierState();
//     _checkBiometric();
//     _getAvailableBiometric();
//     GetListDo();
//     super.initState();
//     timer =
//         Timer.periodic(Duration(seconds: 5), (Timer t) => GetCountStoring());
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
// }
//
// class _OrderTitle extends StatelessWidget {
//   const _OrderTitle({
//     Key key,
//     this.orderInfo,
//   }) : super(key: key);
//
//   final _OrderInfo orderInfo;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           '${orderInfo.id}',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Spacer(),
//         // Text(
//         //   //'${orderInfo.date.day}/${orderInfo.date.month}/${orderInfo.date.year}',
//         //   '${orderInfo.date}',
//         //   style: TextStyle(
//         //     color: Color(0xffb6b2b2),
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
//
// class _InnerTimeline extends StatelessWidget {
//   const _InnerTimeline({
//     this.messages,
//   });
//
//   final List<_DeliveryMessage> messages;
//
//   @override
//   Widget build(BuildContext context) {
//     bool isEdgeIndex(int index) {
//       return index == 0 || index == messages.length + 1;
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: FixedTimeline.tileBuilder(
//         theme: TimelineTheme.of(context).copyWith(
//           nodePosition: 0,
//           connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
//                 thickness: 1.0,
//               ),
//           indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
//                 size: 10.0,
//                 position: 0.5,
//               ),
//         ),
//         builder: TimelineTileBuilder(
//           indicatorBuilder: (_, index) =>
//               !isEdgeIndex(index) ? Indicator.outlined(borderWidth: 1.0) : null,
//           startConnectorBuilder: (_, index) => Connector.solidLine(),
//           endConnectorBuilder: (_, index) => Connector.solidLine(),
//           contentsBuilder: (_, index) {
//             if (isEdgeIndex(index)) {
//               return null;
//             }
//
//             return Padding(
//               padding: EdgeInsets.only(left: 8.0),
//               child: Text(messages[index - 1].toString()),
//             );
//           },
//           itemExtentBuilder: (_, index) => isEdgeIndex(index) ? 10.0 : 30.0,
//           nodeItemOverlapBuilder: (_, index) =>
//               isEdgeIndex(index) ? true : null,
//           itemCount: messages.length + 2,
//         ),
//       ),
//     );
//   }
// }
//
// class _DeliveryProcesses extends StatelessWidget {
//   const _DeliveryProcesses({Key key, this.processes}) : super(key: key);
//
//   final List<_DeliveryProcess> processes;
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTextStyle(
//       style: TextStyle(
//         color: Color(0xff9b9b9b),
//         fontSize: 12,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: FixedTimeline.tileBuilder(
//           theme: TimelineThemeData(
//             nodePosition: 0,
//             color: Color(0xff989898),
//             indicatorTheme: IndicatorThemeData(
//               position: 0,
//               size: 12.0,
//             ),
//             connectorTheme: ConnectorThemeData(
//               thickness: 2.5,
//             ),
//           ),
//           builder: TimelineTileBuilder.connected(
//             connectionDirection: ConnectionDirection.before,
//             itemCount: processes.length,
//             contentsBuilder: (_, index) {
//               if (processes[index].isCompleted) return null;
//
//               return Padding(
//                 padding: EdgeInsets.only(left: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       processes[index].name,
//                       style: DefaultTextStyle.of(context).style.copyWith(
//                             fontSize: 12.0,
//                           ),
//                     ),
//                     _InnerTimeline(messages: processes[index].messages),
//                   ],
//                 ),
//               );
//             },
//             indicatorBuilder: (_, index) {
//               if (processes[index].isCompleted) {
//                 return DotIndicator(
//                   color: Color(0xff66c97f),
//                   child: Icon(
//                     Icons.check,
//                     color: Colors.white,
//                     size: 12.0,
//                   ),
//                 );
//               } else {
//                 return OutlinedDotIndicator(
//                   borderWidth: 2.5,
//                 );
//               }
//             },
//             connectorBuilder: (_, index, ___) => SolidLineConnector(
//               color: processes[index].isCompleted ? Color(0xff66c97f) : null,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _OnTimeBar extends StatelessWidget {
//   const _OnTimeBar({Key key, this.list_do, this.loginname}) : super(key: key);
//
//   final list_do;
//   final loginname;
//
//   Future<String> GetVhcidDo2() async {
//     try {
//       print('Get DO');
//       final JsonDecoder _decoder = new JsonDecoder();
//       var sharedPreferences = await SharedPreferences.getInstance();
//       String drvid = sharedPreferences.getString("drvid");
//       var resVhcid = "";
//       var vDo = sharedPreferences.getString("vhcidfromdo");
//       if (vDo == null || vDo == "") {
//         var urlData =
//             "${GlobalData.baseUrlProd}api/log_receive_do.jsp?method=vehicle-log&drvid=" +
//                 drvid;
//         Uri myUri = Uri.parse(urlData);
//         print(myUri.toString());
//         var response =
//             await http.get(myUri, headers: {"Accept": "application/json"});
//         if (response.statusCode == 200) {
//           var result = json.decode(response.body)[0];
//           print(result['vhcid']);
//           resVhcid = result['vhcid'];
//           sharedPreferences.setString("vhcidfromdo", resVhcid);
//         }
//       }
//       return resVhcid;
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String nameButton =
//         list_do['incustomer'].toString() == "1" ? "DO Diterima" : "Close DO";
//     return Row(
//       children: [
//         Expanded(
//             child: MaterialButton(
//           onPressed: () async {
//             print(
//                 "nameButton ${nameButton} ${list_do['incustomer'].toString()}");
//             EasyLoading.show();
//             if (list_do['incustomer'].toString() == "2") {
//               //CLOSE DO
//               GetVhcidDo2();
//               EasyLoading.show();
//               Timer(Duration(seconds: 1), () {
//                 // 5s over, navigate to a new page
//                 Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => FrmSetKmByDriver()));
//               });
//             } else {
//               if (list_do['incustomer'].toString() == "1") {
//                 //TERIMA DO
//                 Timer(Duration(seconds: 1), () {
//                   // 5s over, navigate to a new page
//                   var isOK = globals.akses_pages == null
//                       ? globals.akses_pages
//                       : globals.akses_pages.where((x) =>
//                           x == "OP" || x == "OK" || x == "OT" || x == "UA");
//                   if (loginname == "DRIVER") {
//                     Navigator.pushReplacement(context,
//                         MaterialPageRoute(builder: (context) => ViewListDo()));
//                   } else if (isOK != null) {
//                     if (isOK.length > 0) {
//                       Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => ViewListDoOpr()));
//                     } else {
//                       alert(context, 0, "Anda tidak punya akses", "error");
//                     }
//                   } else {
//                     Navigator.of(context).pop(false);
//                     alert(context, 0, "Access Denied", "error");
//                   }
//                 });
//               }
//             }
//           },
//           elevation: 0,
//           shape: StadiumBorder(),
//           color: Colors.blue,
//           textColor: Colors.white,
//           child: Text(nameButton),
//         )),
//         SizedBox(width: 10),
//         Expanded(
//             child: MaterialButton(
//           onPressed: () async {
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(
//             //     content: Text('History!'),
//             //   ),
//             // );
//             print(list_do['do_number']);
//             print(list_do['tgl_do']);
//             print(list_do['time_do']);
//             print(list_do['nopol']);
//             print(list_do['vehicle_id']);
//             var tgl_do = list_do['tgl_do'] + " " + list_do['time_do'];
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             prefs.setString("do_maps", list_do['do_number']);
//             prefs.setString("do_tgl_do", tgl_do);
//             prefs.setString("do_nopol", list_do['vehicle_id']);
//             prefs.setString("do_origin", list_do['origin']);
//             prefs.setString("do_destination", list_do['destination']);
//             prefs.setString("do_vehicle_id", list_do['vehicle_id']);
//             prefs.setString("do_driver_nm", list_do['driver_nm']);
//
//             Navigator.pushReplacement(
//                 context, MaterialPageRoute(builder: (context) => MapHistory()));
//           },
//           elevation: 0,
//           shape: StadiumBorder(),
//           color: Color(0xff66c97f),
//           textColor: Colors.white,
//           child: Text('View History'),
//         )),
//         // SizedBox(width: 10),
//         // Expanded(
//         //     child: MaterialButton(
//         //       onPressed: () async {
//         //         print(list_do['do_number']);
//         //         print(list_do['tgl_do']);
//         //         print(list_do['time_do']);
//         //         print(list_do['nopol']);
//         //         print(list_do['vehicle_id']);
//         //         var tgl_do = list_do['tgl_do'] + " " + list_do['time_do'];
//         //         SharedPreferences prefs = await SharedPreferences.getInstance();
//         //         prefs.setString("do_maps", list_do['do_number']);
//         //         prefs.setString("do_tgl_do", tgl_do);
//         //         prefs.setString("do_nopol", list_do['vehicle_id']);
//         //         prefs.setString("do_origin", list_do['origin']);
//         //         prefs.setString("do_destination", list_do['destination']);
//         //         prefs.setString("do_vehicle_id", list_do['vehicle_id']);
//         //         prefs.setString("do_driver_nm", list_do['driver_nm']);
//         //
//         //         // Navigator.pushReplacement(
//         //         //     context, MaterialPageRoute(builder: (context) => MapHistory()));
//         //       },
//         //       elevation: 0,
//         //       shape: StadiumBorder(),
//         //       color: Color(0xff66c97f),
//         //       textColor: Colors.white,
//         //       child: Text('Play'),
//         //     )),
//       ],
//     );
//   }
// }
//
// _OrderInfo _data(int id, int index, dynamic item) => _OrderInfo(
//       id: item['bujnbr'] + "\n" + item['do_number'] + "\n" + item['vehicle_id'],
//       doNumber: item['do_number'],
//       date: item['tgl_do'] + " " + item['time_do'],
//       driverInfo: _DriverInfo(
//         name: item['driver_nm'],
//         thumbnailUrl:
//             'https://i.pinimg.com/originals/08/45/81/084581e3155d339376bf1d0e17979dc6.jpg',
//       ),
//       deliveryProcesses: [
//         _DeliveryProcess(
//           item['tgl_do'] + " " + item['time_do'],
//           messages: [
//             _DeliveryMessage('Origin: ', item['origin']),
//             _DeliveryMessage('Destination: ', item['destination']),
//           ],
//         ),
//         _DeliveryProcess.complete(),
//       ],
//     );
//
// class _OrderInfo {
//   const _OrderInfo({
//     this.id,
//     this.doNumber,
//     this.date,
//     this.driverInfo,
//     this.deliveryProcesses,
//   });
//
//   final String id;
//   final String doNumber;
//   final String date;
//   final _DriverInfo driverInfo;
//   final List<_DeliveryProcess> deliveryProcesses;
// }
//
// class _DriverInfo {
//   const _DriverInfo({
//     this.name,
//     this.thumbnailUrl,
//   });
//
//   final String name;
//   final String thumbnailUrl;
// }
//
// class _DeliveryProcess {
//   const _DeliveryProcess(
//     this.name, {
//     this.messages = const [],
//   });
//
//   const _DeliveryProcess.complete()
//       : this.name = 'Done',
//         this.messages = const [];
//
//   final String name;
//   final List<_DeliveryMessage> messages;
//
//   bool get isCompleted => name == 'Done';
// }
//
// class _DeliveryMessage {
//   const _DeliveryMessage(this.createdAt, this.message);
//
//   final String createdAt; // final DateTime createdAt;
//   final String message;
//
//   @override
//   String toString() {
//     return '$createdAt $message';
//   }
// }
