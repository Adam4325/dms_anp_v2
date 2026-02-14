// import 'dart:async';
// import 'dart:convert';
//
// import 'package:dms_anp/src/Helper/Provider.dart';
// import 'package:dms_anp/src/flusbar.dart';
// import 'package:dms_anp/src/pages/driver/ListDriverInspeksi.dart';
// import 'package:dms_anp/src/pages/maintenance/ViewCarLT.dart';
// import 'package:dms_anp/src/pages/maintenance/ViewCarTR.dart';
// import 'package:dms_anp/src/pages/maintenance/ViewCarTRAILLER.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dms_anp/src/Helper/globals.dart' as globals;
// import 'package:http/http.dart' as http;
// import 'package:smart_select/smart_select.dart';
// import '../../../choices.dart' as choices;
//
// class FrmInspeksiMekanikP2H extends StatefulWidget {
//   @override
//   _FrmInspeksiMekanikP2HState createState() => _FrmInspeksiMekanikP2HState();
// }
//
// //GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
// bool isShowCheck = false;
// //PENGECEKAN DASAR
// enum vhcOil { tidakAda, tersedia, perluPerbaikan }
// enum vhcOliMesin { tidakAda, tersedia, perluPerbaikan }
// enum vhcOliGardan { tidakAda, tersedia, perluPerbaikan }
// enum vhcOliTransmisi { tidakAda, tersedia, perluPerbaikan }
// enum vhcAir { tidakAda, tersedia, perluPerbaikan } //Air Radiator
// enum vhcAccu { tidakAda, tersedia, perluPerbaikan } //Air AKI
// enum vhcMrem { tidakAda, tersedia, perluPerbaikan } //Minyak Rem
// enum vhcOLips { tidakAda, tersedia, perluPerbaikan } //Oli Power Steering
//
// //KABIN
// enum vhcKabin { tidakAda, tersedia, perluPerbaikan }
// enum vhcKaca { tidakAda, tersedia, perluPerbaikan }
// enum vhcSpion { tidakAda, tersedia, perluPerbaikan }
// enum vhcSpeedo { tidakAda, tersedia, perluPerbaikan }
// enum vhcWiper { tidakAda, tersedia, perluPerbaikan } //WIPER
// enum vhcKlak { tidakAda, tersedia, perluPerbaikan }
// enum vhcJok { tidakAda, tersedia, perluPerbaikan }
// enum vhcSeatBealt { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcApar { tidakAda, tersedia, perluPerbaikan }
// enum vhcP3k { tidakAda, tersedia, perluPerbaikan }
// enum vhcCone { tidakAda, tersedia, perluPerbaikan }
// enum vhcStikerRef { tidakAda, tersedia, perluPerbaikan }
//
// //ELECTRIK
// enum vhcLampd { tidakAda, tersedia, perluPerbaikan }
// enum vhcLamps { tidakAda, tersedia, perluPerbaikan } //LAMPU SEN
// enum vhcLampBlk { tidakAda, tersedia, perluPerbaikan } //ADD LAMPU Belakang
// enum vhcLampr { tidakAda, tersedia, perluPerbaikan }
// enum vhcLampm { tidakAda, tersedia, perluPerbaikan }
// enum vhcLampAlarm { tidakAda, tersedia, perluPerbaikan }
//
// //Chasis
// enum vhcKopling { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcGardan { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcParking { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcFoot { tidakAda, tersedia, perluPerbaikan }
// enum vhcBautRoda { tidakAda, tersedia, perluPerbaikan }
// enum vhcVelg { tidakAda, tersedia, perluPerbaikan } //ADD
//
// //BAN
// enum vhcBan { tidakAda, tersedia, perluPerbaikan }
// enum vhcAngin { tidakAda, tersedia, perluPerbaikan }
//
// //PERLATAN
// enum vhcTerpal { tidakAda, tersedia, perluPerbaikan }
// enum vhcWebing { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcTambang { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcDongkrak { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcKRoda { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcGBan { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcGps { tidakAda, tersedia, perluPerbaikan }
// enum vhcDashCam { tidakAda, tersedia, perluPerbaikan } //ADD
//
// //DOKUMEN
// enum vhcSurat { tidakAda, tersedia, perluPerbaikan }
// enum vhcKir { tidakAda, tersedia, perluPerbaikan } //ADD
// enum vhcSim { tidakAda, tersedia, perluPerbaikan } //ADD
//
// class _FrmInspeksiMekanikP2HState extends State<FrmInspeksiMekanikP2H> {
//   GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController txtNotes = new TextEditingController();
//   TextEditingController txtKm = new TextEditingController();
//   ProgressDialog pr;
//   List<String> selBan = [];
//   String type_truck = "";
//   String status_code = "";
//   String status_code_img = "";
//   String message = "";
//   String image_url = "";
//   double iconSize = 40;
//
//   //PENGECEKAN DASAR
//   vhcOil rvhcOil;
//   vhcOliMesin rvhcOliMesin;
//   vhcOliGardan rvhcOliGardan;
//   vhcOliTransmisi rvhcOliTransmisi;
//   vhcAir rvhcAir;
//   vhcAccu rvhcAccu;
//   vhcMrem rvhcMrem;
//   vhcOLips rvhcOLips;
//
//   //KABIN
//   vhcKabin rvhcKabin;
//   vhcKaca rvhcKaca;
//   vhcSpion rvhcSpion;
//   vhcSpeedo rvhcSpeedo;
//   vhcWiper rvhcWiper;
//   vhcKlak rvhcKlak;
//   vhcJok rvhcJok;
//   vhcSeatBealt rvhcSeatBealt;
//   vhcApar rvhcApar;
//   vhcP3k rvhcP3k;
//   vhcCone rvhcCone;
//   vhcStikerRef rvhcStikerRef;
//   //END
//
//   //ELECTRIC
//   vhcLampd rvhcLampd;
//   vhcLamps rvhcLamps;
//   vhcLampBlk rvhcLampBlk;
//   vhcLampr rvhcLampr;
//   vhcLampm rvhcLampm;
//   vhcLampAlarm rvhcLampAlarm;
//   //END
//
//   //Chasis
//   vhcKopling rvhcKopling;
//   vhcGardan rvhcGardan;
//   vhcParking rvhcParking;
//   vhcFoot rvhcFoot;
//   vhcBautRoda rvhcBautRoda;
//   vhcVelg rvhcVelg;
//   //END
//
//   //BAN
//   vhcBan rvhcBan;
//   vhcAngin rvhcAngin;
//   //end
//
//   //PERALATAN
//   vhcTerpal rvhcTerpal;
//   vhcWebing rvhcWebing;
//   vhcTambang rvhcTambang;
//   vhcDongkrak rvhcDongkrak;
//   vhcKRoda rvhcKRoda;
//   vhcGBan rvhcGBan;
//   vhcGps rvhcGps;
//   vhcDashCam rvhcDashCam;
//
//   //DOKUMEN
//   vhcSurat rvhcSurat;
//   vhcKir rvhcKir;
//   vhcSim rvhcSim;
//
//   String vhcNotes = "";
//
//   bool isPengecekanDasar1 = false;
//   bool isPengecekanDasar2 = false;
//   bool isPengecekanDasar3 = false;
//
//   bool isKabin1 = false;
//   bool isKabin2 = false;
//   bool isKabin3 = false;
//
//   bool isElektrik1 = false;
//   bool isElektrik2 = false;
//   bool isElektrik3 = false;
//
//   bool isChasis1 = false;
//   bool isChasis2 = false;
//   bool isChasis3 = false;
//
//   bool isBan1 = false;
//   bool isBan2 = false;
//   bool isBan3 = false;
//
//   bool isPeralatan1 = false;
//   bool isPeralatan2 = false;
//   bool isPeralatan3 = false;
//
//   bool isDokumen1 = false;
//   bool isDokumen2 = false;
//   bool isDokumen3 = false;
//
//   //bool bTasPP = false;
//   _goBack(BuildContext context) {
//     ResetCheckBox();
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => ListDriverInspeksi()));
//   }
//
//   void getTypeTruck() async {
//     //SharedPreferences prefs = await SharedPreferences.getInstance();
//     String vhcidType = globals.p2hVhcid;
//     var urlData = "${GlobalData.baseUrl}api/vehicle/type_vehicle.jsp";
//     var dataParam = {"method": "get-vehicle-type-v1", "vhcid": vhcidType};
//     var encoded = Uri.encodeFull(urlData);
//     Uri myUri = Uri.parse(encoded);
//     print(myUri);
//     final response = await http.post(
//       myUri,
//       body: dataParam,
//       headers: {
//         "Content-Type": "application/x-www-form-urlencoded",
//       },
//       encoding: Encoding.getByName('utf-8'),
//     );
//
//     setState(() {
//       status_code_img = json.decode(response.body)["status_code"].toString();
//       globals.image_typr_truck_url = json.decode(response.body)["image_url"];
//       type_truck = json.decode(response.body)["type"];
//       if (status_code_img == "200") {
//         print('Ok');
//       } else {
//         globals.image_typr_truck_url = "";
//         type_truck = "";
//       }
//     });
//   }
//
//
//
//   Widget buildSelectTruck(BuildContext context) {
//     return new SmartSelect<String>.multiple(
//       title: 'Ban Type $type_truck',
//       value: selBan,
//       onChange: (selected) {
//         setState(() => selBan = selected.value);
//       },
//       choiceItems: type_truck == "TR"
//           ? choices.collBanTR
//           : (type_truck == "LT" ? choices.collBanLT : choices.collBanTRAILLER),
//       modalType: S2ModalType.popupDialog,
//       modalConfirm: true,
//       modalValidation: (value) {
//         return value.length > 0 ? null : 'Select at least one';
//       },
//       modalHeaderStyle: S2ModalHeaderStyle(
//         backgroundColor: Theme.of(context).cardColor,
//       ),
//       tileBuilder: (context, state) {
//         return S2Tile.fromState(
//           state,
//           isTwoLine: true,
//           leading: Container(
//             width: 40,
//             alignment: Alignment.center,
//             child: const Icon(Icons.shopping_cart),
//           ),
//         );
//       },
//       modalActionsBuilder: (context, state) {
//         return <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(right: 13),
//             child: state.choiceSelector,
//           )
//         ];
//       },
//       modalDividerBuilder: (context, state) {
//         return const Divider(height: 1);
//       },
//       modalFooterBuilder: (context, state) {
//         return Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 12.0,
//             vertical: 7.0,
//           ),
//           child: Row(
//             children: <Widget>[
//               const Spacer(),
//               TextButton(
//                 child: const Text('Cancel'),
//                 onPressed: () {
//                   state.closeModal(confirmed: false);
//                   setState(() {
//                     selBan = [];
//                     state.value = [];
//                   });
//                 },
//               ),
//               const SizedBox(width: 5),
//               TextButton(
//                 child: Text('OK'),
//                 color: Theme.of(context).primaryColor,
//                 textColor: Colors.white,
//                 onPressed: state.mounted
//                     ? () => state.closeModal(confirmed: true)
//                     : null,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void initState() {
//     isLoadcheked();
//     getTypeTruck();
//     if (EasyLoading.isShow) {
//       EasyLoading.dismiss();
//     }
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     pr = new ProgressDialog(context,
//         type: ProgressDialogType.Normal, isDismissible: true);
//
//     pr.style(
//       message: 'Wait...',
//       borderRadius: 10.0,
//       backgroundColor: Colors.white,
//       elevation: 10.0,
//       insetAnimCurve: Curves.easeInOut,
//       progress: 0.0,
//       maxProgress: 100.0,
//       progressTextStyle: TextStyle(
//           color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//       messageTextStyle: TextStyle(
//           color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
//     );
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//               //backgroundColor: Color(0xFFFF1744),
//               leading: IconButton(
//                 icon: Icon(
//                   Icons.arrow_back,
//                   color: Colors.black,
//                 ),
//                 iconSize: 20.0,
//                 onPressed: () {
//                   _goBack(context);
//                 },
//               ),
//               backgroundColor: Colors.transparent,
//               elevation: 0.0,
//               centerTitle: true,
//               title: Text('Form Inspeksi ${globals.p2hVhcid.toString()}',
//                   style: TextStyle(color: Colors.black))),
//           body: Container(
//               key: globalScaffoldKey,
//               height: MediaQuery.of(context).size.height,
//               child: SingleChildScrollView(
//                   clipBehavior: Clip.antiAlias,
//                   child: Column(children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.all(10),
//                       alignment: Alignment.center,
//                       child: Text("Daily Check Before Riding",
//                           style: TextStyle(fontSize: 25)),
//                     ),
//                     Container(
//                         margin: EdgeInsets.all(10),
//                         child: Table(
//                             columnWidths: {
//                               0: FlexColumnWidth(4),
//                               1: FlexColumnWidth(4),
//                               2: FlexColumnWidth(4),
//                             },
//                             //border: TableBorder.all(),
//                             defaultVerticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             children: [
//                               TableRow(children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Icon(Icons.close,
//                                           size: 20, color: Colors.redAccent),
//                                       Text('= Tidak Ada',
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold))
//                                     ]),
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Icon(Icons.check,
//                                           size: 20, color: Colors.green),
//                                       Text('= Tersedia',
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold))
//                                     ]),
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Icon(Icons.handyman,
//                                           size: 20, color: Colors.redAccent),
//                                       Text('= Perlu Perbaikan',
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold))
//                                     ])
//                               ]),
//                             ])),
//                     Container(
//                       margin: EdgeInsets.all(10),
//                       child: Table(
//                         columnWidths: {
//                           0: FlexColumnWidth(4),
//                           1: FlexColumnWidth(1),
//                           2: FlexColumnWidth(1),
//                           3: FlexColumnWidth(1),
//                         },
//                         border: TableBorder.all(),
//                         defaultVerticalAlignment:
//                             TableCellVerticalAlignment.middle,
//                         children: [
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('Pengecekan Dasar ',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent),
//                                   if (isShowCheck) ...[
//                                     Checkbox(
//                                         value: isPengecekanDasar1,
//                                         onChanged: (bool newValue) {
//                                           setState(() {
//                                             isPengecekanDasar1 = newValue;
//                                             if (newValue == true) {
//                                               selectUnselect(
//                                                   "pengecekan-dasar", 0);
//                                               isPengecekanDasar3 = false;
//                                               isPengecekanDasar2 = false;
//                                             } else {
//                                               selectUnselect(
//                                                   "pengecekan-dasar", -1);
//                                             }
//                                           });
//                                         }),
//                                     Icon(Icons.close,
//                                         size: 20, color: Colors.redAccent)
//                                   ]
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green),
//                                   if (isShowCheck) ...[
//                                     Checkbox(
//                                         value: isPengecekanDasar2,
//                                         onChanged: (bool newValue) {
//                                           setState(() {
//                                             isPengecekanDasar2 = newValue;
//                                             if (newValue == true) {
//                                               selectUnselect(
//                                                   "pengecekan-dasar", 1);
//                                               isPengecekanDasar1 = false;
//                                               isPengecekanDasar3 = false;
//                                             } else {
//                                               selectUnselect(
//                                                   "pengecekan-dasar", -1);
//                                             }
//                                           });
//                                         }),
//                                     Icon(Icons.check_circle,
//                                         size: 20, color: Colors.green)
//                                   ]
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent),
//                                   if (isShowCheck) ...[
//                                     Checkbox(
//                                         value: isPengecekanDasar3,
//                                         onChanged: (bool newValue) {
//                                           setState(() {
//                                             isPengecekanDasar3 = newValue;
//                                             if (newValue == true) {
//                                               selectUnselect(
//                                                   "pengecekan-dasar", 2);
//                                               isPengecekanDasar1 = false;
//                                               isPengecekanDasar2 = false;
//                                             } else {
//                                               selectUnselect(
//                                                   "pengecekan-dasar", -1);
//                                             }
//                                           });
//                                         }),
//                                     Icon(Icons.handyman,
//                                         size: 20, color: Colors.redAccent)
//                                   ]
//                                 ]),
//                               ]), //HEADER PENGECEKAN
//                           // TableRow(children: [
//                           //   Column(
//                           //       crossAxisAlignment: CrossAxisAlignment.start,
//                           //       children: [
//                           //         Text(' OLI', style: TextStyle(fontSize: 14))
//                           //       ]),
//                           //   Column(children: [
//                           //     Radio<vhcOil>(
//                           //       value: vhcOil.tidakAda,
//                           //       groupValue: rvhcOil,
//                           //       onChanged: (vhcOil value) {
//                           //         setState(() {
//                           //           rvhcOil = value;
//                           //         });
//                           //       },
//                           //     )
//                           //   ]),
//                           //   Column(children: [
//                           //     Radio<vhcOil>(
//                           //       value: vhcOil.tersedia,
//                           //       groupValue: rvhcOil,
//                           //       onChanged: (vhcOil value) {
//                           //         setState(() {
//                           //           rvhcOil = value;
//                           //         });
//                           //       },
//                           //     )
//                           //   ]),
//                           //   Column(children: [
//                           //     Radio<vhcOil>(
//                           //       value: vhcOil.perluPerbaikan,
//                           //       groupValue: rvhcOil,
//                           //       onChanged: (vhcOil value) {
//                           //         setState(() {
//                           //           rvhcOil = value;
//                           //         });
//                           //       },
//                           //     )
//                           //   ]),
//                           // ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Oli Mesin',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcOliMesin>(
//                                 value: vhcOliMesin.tidakAda,
//                                 groupValue: rvhcOliMesin,
//                                 onChanged: (vhcOliMesin value) {
//                                   setState(() {
//                                     rvhcOliMesin = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOliMesin>(
//                                 value: vhcOliMesin.tersedia,
//                                 groupValue: rvhcOliMesin,
//                                 onChanged: (vhcOliMesin value) {
//                                   setState(() {
//                                     rvhcOliMesin = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOliMesin>(
//                                 value: vhcOliMesin.perluPerbaikan,
//                                 groupValue: rvhcOliMesin,
//                                 onChanged: (vhcOliMesin value) {
//                                   setState(() {
//                                     rvhcOliMesin = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Oli Gardan',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcOliGardan>(
//                                 value: vhcOliGardan.tidakAda,
//                                 groupValue: rvhcOliGardan,
//                                 onChanged: (vhcOliGardan value) {
//                                   setState(() {
//                                     rvhcOliGardan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOliGardan>(
//                                 value: vhcOliGardan.tersedia,
//                                 groupValue: rvhcOliGardan,
//                                 onChanged: (vhcOliGardan value) {
//                                   setState(() {
//                                     rvhcOliGardan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOliGardan>(
//                                 value: vhcOliGardan.perluPerbaikan,
//                                 groupValue: rvhcOliGardan,
//                                 onChanged: (vhcOliGardan value) {
//                                   setState(() {
//                                     rvhcOliGardan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Oli Transmisi',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcOliTransmisi>(
//                                 value: vhcOliTransmisi.tidakAda,
//                                 groupValue: rvhcOliTransmisi,
//                                 onChanged: (vhcOliTransmisi value) {
//                                   setState(() {
//                                     rvhcOliTransmisi = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOliTransmisi>(
//                                 value: vhcOliTransmisi.tersedia,
//                                 groupValue: rvhcOliTransmisi,
//                                 onChanged: (vhcOliTransmisi value) {
//                                   setState(() {
//                                     rvhcOliTransmisi = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOliTransmisi>(
//                                 value: vhcOliTransmisi.perluPerbaikan,
//                                 groupValue: rvhcOliTransmisi,
//                                 onChanged: (vhcOliTransmisi value) {
//                                   setState(() {
//                                     rvhcOliTransmisi = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Air Radiator',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcAir>(
//                                 value: vhcAir.tidakAda,
//                                 groupValue: rvhcAir,
//                                 onChanged: (vhcAir value) {
//                                   setState(() {
//                                     rvhcAir = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcAir>(
//                                 value: vhcAir.tersedia,
//                                 groupValue: rvhcAir,
//                                 onChanged: (vhcAir value) {
//                                   setState(() {
//                                     rvhcAir = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcAir>(
//                                 value: vhcAir.perluPerbaikan,
//                                 groupValue: rvhcAir,
//                                 onChanged: (vhcAir value) {
//                                   setState(() {
//                                     rvhcAir = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Air Aki',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcAccu>(
//                                 value: vhcAccu.tidakAda,
//                                 groupValue: rvhcAccu,
//                                 onChanged: (vhcAccu value) {
//                                   setState(() {
//                                     rvhcAccu = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcAccu>(
//                                 value: vhcAccu.tersedia,
//                                 groupValue: rvhcAccu,
//                                 onChanged: (vhcAccu value) {
//                                   setState(() {
//                                     rvhcAccu = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcAccu>(
//                                 value: vhcAccu.perluPerbaikan,
//                                 groupValue: rvhcAccu,
//                                 onChanged: (vhcAccu value) {
//                                   setState(() {
//                                     rvhcAccu = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Minyak Rem',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcMrem>(
//                                 value: vhcMrem.tidakAda,
//                                 groupValue: rvhcMrem,
//                                 onChanged: (vhcMrem value) {
//                                   setState(() {
//                                     rvhcMrem = value;
//                                     print(globals.rvhcMrem);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcMrem>(
//                                 value: vhcMrem.tersedia,
//                                 groupValue: rvhcMrem,
//                                 onChanged: (vhcMrem value) {
//                                   setState(() {
//                                     rvhcMrem = value;
//                                     print(globals.rvhcMrem);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcMrem>(
//                                 value: vhcMrem.perluPerbaikan,
//                                 groupValue: rvhcMrem,
//                                 onChanged: (vhcMrem value) {
//                                   setState(() {
//                                     rvhcMrem = value;
//                                     print(rvhcMrem);
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Oli Power Steering',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcOLips>(
//                                 value: vhcOLips.tidakAda,
//                                 groupValue: rvhcOLips,
//                                 onChanged: (vhcOLips value) {
//                                   setState(() {
//                                     rvhcOLips = value;
//                                     print(globals.rvhcOLips);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOLips>(
//                                 value: vhcOLips.tersedia,
//                                 groupValue: rvhcOLips,
//                                 onChanged: (vhcOLips value) {
//                                   setState(() {
//                                     rvhcOLips = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcOLips>(
//                                 value: vhcOLips.perluPerbaikan,
//                                 groupValue: rvhcOLips,
//                                 onChanged: (vhcOLips value) {
//                                   setState(() {
//                                     rvhcOLips = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('KABIN',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isKabin1,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isKabin1 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("kabin", 0);
//                                   //           isKabin3 = false;
//                                   //           isKabin2 = false;
//                                   //         } else {
//                                   //           selectUnselect("kabin", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.close,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green)
//                                   // Checkbox(
//                                   //     value: isKabin2,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isKabin2 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("kabin", 1);
//                                   //           isKabin1 = false;
//                                   //           isKabin3 = false;
//                                   //         } else {
//                                   //           selectUnselect("kabin", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.check_circle,
//                                   //     size: 20, color: Colors.green)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isKabin3,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isKabin3 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("kabin", 2);
//                                   //           isKabin1 = false;
//                                   //           isKabin2 = false;
//                                   //         } else {
//                                   //           selectUnselect("kabin", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.handyman,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                               ]), //HEADER KABIN
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Body Kabin',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcKabin>(
//                                 value: vhcKabin.tidakAda,
//                                 groupValue: rvhcKabin,
//                                 onChanged: (vhcKabin value) {
//                                   setState(() {
//                                     rvhcKabin = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKabin>(
//                                 value: vhcKabin.tersedia,
//                                 groupValue: rvhcKabin,
//                                 onChanged: (vhcKabin value) {
//                                   setState(() {
//                                     rvhcKabin = value;
//                                     print(rvhcKabin);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKabin>(
//                                 value: vhcKabin.perluPerbaikan,
//                                 groupValue: rvhcKabin,
//                                 onChanged: (vhcKabin value) {
//                                   setState(() {
//                                     rvhcKabin = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Kaca', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcKaca>(
//                                 value: vhcKaca.tidakAda,
//                                 groupValue: rvhcKaca,
//                                 onChanged: (vhcKaca value) {
//                                   setState(() {
//                                     rvhcKaca = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKaca>(
//                                 value: vhcKaca.tersedia,
//                                 groupValue: rvhcKaca,
//                                 onChanged: (vhcKaca value) {
//                                   setState(() {
//                                     rvhcKaca = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKaca>(
//                                 value: vhcKaca.perluPerbaikan,
//                                 groupValue: rvhcKaca,
//                                 onChanged: (vhcKaca value) {
//                                   setState(() {
//                                     rvhcKaca = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Spion', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcSpion>(
//                                 value: vhcSpion.tidakAda,
//                                 groupValue: rvhcSpion,
//                                 onChanged: (vhcSpion value) {
//                                   setState(() {
//                                     rvhcSpion = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSpion>(
//                                 value: vhcSpion.tersedia,
//                                 groupValue: rvhcSpion,
//                                 onChanged: (vhcSpion value) {
//                                   setState(() {
//                                     rvhcSpion = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSpion>(
//                                 value: vhcSpion.perluPerbaikan,
//                                 groupValue: rvhcSpion,
//                                 onChanged: (vhcSpion value) {
//                                   setState(() {
//                                     rvhcSpion = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Speedometer',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcSpeedo>(
//                                 value: vhcSpeedo.tidakAda,
//                                 groupValue: rvhcSpeedo,
//                                 onChanged: (vhcSpeedo value) {
//                                   setState(() {
//                                     rvhcSpeedo = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSpeedo>(
//                                 value: vhcSpeedo.tersedia,
//                                 groupValue: rvhcSpeedo,
//                                 onChanged: (vhcSpeedo value) {
//                                   setState(() {
//                                     rvhcSpeedo = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSpeedo>(
//                                 value: vhcSpeedo.perluPerbaikan,
//                                 groupValue: rvhcSpeedo,
//                                 onChanged: (vhcSpeedo value) {
//                                   setState(() {
//                                     rvhcSpeedo = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Wiper', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcWiper>(
//                                 value: vhcWiper.tidakAda,
//                                 groupValue: rvhcWiper,
//                                 onChanged: (vhcWiper value) {
//                                   setState(() {
//                                     rvhcWiper = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcWiper>(
//                                 value: vhcWiper.tersedia,
//                                 groupValue: rvhcWiper,
//                                 onChanged: (vhcWiper value) {
//                                   setState(() {
//                                     rvhcWiper = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcWiper>(
//                                 value: vhcWiper.perluPerbaikan,
//                                 groupValue: rvhcWiper,
//                                 onChanged: (vhcWiper value) {
//                                   setState(() {
//                                     rvhcWiper = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Klakson',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcKlak>(
//                                 value: vhcKlak.tidakAda,
//                                 groupValue: rvhcKlak,
//                                 onChanged: (vhcKlak value) {
//                                   setState(() {
//                                     rvhcKlak = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKlak>(
//                                 value: vhcKlak.tersedia,
//                                 groupValue: rvhcKlak,
//                                 onChanged: (vhcKlak value) {
//                                   setState(() {
//                                     rvhcKlak = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKlak>(
//                                 value: vhcKlak.perluPerbaikan,
//                                 groupValue: rvhcKlak,
//                                 onChanged: (vhcKlak value) {
//                                   setState(() {
//                                     rvhcKlak = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Jok', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcJok>(
//                                 value: vhcJok.tidakAda,
//                                 groupValue: rvhcJok,
//                                 onChanged: (vhcJok value) {
//                                   setState(() {
//                                     rvhcJok = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcJok>(
//                                 value: vhcJok.tersedia,
//                                 groupValue: rvhcJok,
//                                 onChanged: (vhcJok value) {
//                                   setState(() {
//                                     rvhcJok = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcJok>(
//                                 value: vhcJok.perluPerbaikan,
//                                 groupValue: rvhcJok,
//                                 onChanged: (vhcJok value) {
//                                   setState(() {
//                                     rvhcJok = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Sabuk Pengaman',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcSeatBealt>(
//                                 value: vhcSeatBealt.tidakAda,
//                                 groupValue: rvhcSeatBealt,
//                                 onChanged: (vhcSeatBealt value) {
//                                   setState(() {
//                                     rvhcSeatBealt = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSeatBealt>(
//                                 value: vhcSeatBealt.tersedia,
//                                 groupValue: rvhcSeatBealt,
//                                 onChanged: (vhcSeatBealt value) {
//                                   setState(() {
//                                     rvhcSeatBealt = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSeatBealt>(
//                                 value: vhcSeatBealt.perluPerbaikan,
//                                 groupValue: rvhcSeatBealt,
//                                 onChanged: (vhcSeatBealt value) {
//                                   setState(() {
//                                     rvhcSeatBealt = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Apar', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcApar>(
//                                 value: vhcApar.tidakAda,
//                                 groupValue: rvhcApar,
//                                 onChanged: (vhcApar value) {
//                                   setState(() {
//                                     rvhcApar = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcApar>(
//                                 value: vhcApar.tersedia,
//                                 groupValue: rvhcApar,
//                                 onChanged: (vhcApar value) {
//                                   setState(() {
//                                     rvhcApar = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcApar>(
//                                 value: vhcApar.perluPerbaikan,
//                                 groupValue: rvhcApar,
//                                 onChanged: (vhcApar value) {
//                                   setState(() {
//                                     rvhcApar = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]), //
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' P3K', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcP3k>(
//                                 value: vhcP3k.tidakAda,
//                                 groupValue: rvhcP3k,
//                                 onChanged: (vhcP3k value) {
//                                   setState(() {
//                                     rvhcP3k = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcP3k>(
//                                 value: vhcP3k.tersedia,
//                                 groupValue: rvhcP3k,
//                                 onChanged: (vhcP3k value) {
//                                   setState(() {
//                                     rvhcP3k = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcP3k>(
//                                 value: vhcP3k.perluPerbaikan,
//                                 groupValue: rvhcP3k,
//                                 onChanged: (vhcP3k value) {
//                                   setState(() {
//                                     rvhcP3k = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]), //
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Segitiga Pengaman',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcCone>(
//                                 value: vhcCone.tidakAda,
//                                 groupValue: rvhcCone,
//                                 onChanged: (vhcCone value) {
//                                   setState(() {
//                                     rvhcCone = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcCone>(
//                                 value: vhcCone.tersedia,
//                                 groupValue: rvhcCone,
//                                 onChanged: (vhcCone value) {
//                                   setState(() {
//                                     rvhcCone = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcCone>(
//                                 value: vhcCone.perluPerbaikan,
//                                 groupValue: rvhcCone,
//                                 onChanged: (vhcCone value) {
//                                   setState(() {
//                                     rvhcCone = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Stiker Reflektor',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcStikerRef>(
//                                 value: vhcStikerRef.tidakAda,
//                                 groupValue: rvhcStikerRef,
//                                 onChanged: (vhcStikerRef value) {
//                                   setState(() {
//                                     rvhcStikerRef = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcStikerRef>(
//                                 value: vhcStikerRef.tersedia,
//                                 groupValue: rvhcStikerRef,
//                                 onChanged: (vhcStikerRef value) {
//                                   setState(() {
//                                     rvhcStikerRef = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcStikerRef>(
//                                 value: vhcStikerRef.perluPerbaikan,
//                                 groupValue: rvhcStikerRef,
//                                 onChanged: (vhcStikerRef value) {
//                                   setState(() {
//                                     rvhcStikerRef = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]), //
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('Elektrik',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isElektrik1,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isElektrik1 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("electric", 0);
//                                   //           isElektrik2 = false;
//                                   //           isElektrik3 = false;
//                                   //         } else {
//                                   //           selectUnselect("electric", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.close,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green)
//                                   // Checkbox(
//                                   //     value: isElektrik2,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isElektrik2 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("electric", 1);
//                                   //           isElektrik1 = false;
//                                   //           isElektrik3 = false;
//                                   //         } else {
//                                   //           selectUnselect("electric", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.check_circle,
//                                   //     size: 20, color: Colors.green)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isElektrik3,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isElektrik3 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("electric", 2);
//                                   //           isElektrik1 = false;
//                                   //           isElektrik2 = false;
//                                   //         } else {
//                                   //           selectUnselect("electric", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.handyman,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                               ]), //HEADER ELEKTRIk
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Lampu Depan',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcLampd>(
//                                 value: vhcLampd.tidakAda,
//                                 groupValue: rvhcLampd,
//                                 onChanged: (vhcLampd value) {
//                                   setState(() {
//                                     rvhcLampd = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampd>(
//                                 value: vhcLampd.tersedia,
//                                 groupValue: rvhcLampd,
//                                 onChanged: (vhcLampd value) {
//                                   setState(() {
//                                     rvhcLampd = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampd>(
//                                 value: vhcLampd.perluPerbaikan,
//                                 groupValue: rvhcLampd,
//                                 onChanged: (vhcLampd value) {
//                                   setState(() {
//                                     rvhcLampd = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Lampu Sign',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcLamps>(
//                                 value: vhcLamps.tidakAda,
//                                 groupValue: rvhcLamps,
//                                 onChanged: (vhcLamps value) {
//                                   setState(() {
//                                     rvhcLamps = value;
//                                     print(rvhcLamps.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLamps>(
//                                 value: vhcLamps.tersedia,
//                                 groupValue: rvhcLamps,
//                                 onChanged: (vhcLamps value) {
//                                   setState(() {
//                                     rvhcLamps = value;
//                                     print(rvhcLamps.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLamps>(
//                                 value: vhcLamps.perluPerbaikan,
//                                 groupValue: rvhcLamps,
//                                 onChanged: (vhcLamps value) {
//                                   setState(() {
//                                     rvhcLamps = value;
//                                     print(rvhcLamps.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Lampu Belakang',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcLampBlk>(
//                                 value: vhcLampBlk.tidakAda,
//                                 groupValue: rvhcLampBlk,
//                                 onChanged: (vhcLampBlk value) {
//                                   setState(() {
//                                     rvhcLampBlk = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampBlk>(
//                                 value: vhcLampBlk.tersedia,
//                                 groupValue: rvhcLampBlk,
//                                 onChanged: (vhcLampBlk value) {
//                                   setState(() {
//                                     rvhcLampBlk = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampBlk>(
//                                 value: vhcLampBlk.perluPerbaikan,
//                                 groupValue: rvhcLampBlk,
//                                 onChanged: (vhcLampBlk value) {
//                                   setState(() {
//                                     rvhcLampBlk = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Lampu Rotary',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcLampr>(
//                                 value: vhcLampr.tidakAda,
//                                 groupValue: rvhcLampr,
//                                 onChanged: (vhcLampr value) {
//                                   setState(() {
//                                     rvhcLampr = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampr>(
//                                 value: vhcLampr.tersedia,
//                                 groupValue: rvhcLampr,
//                                 onChanged: (vhcLampr value) {
//                                   setState(() {
//                                     rvhcLampr = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampr>(
//                                 value: vhcLampr.perluPerbaikan,
//                                 groupValue: rvhcLampr,
//                                 onChanged: (vhcLampr value) {
//                                   setState(() {
//                                     rvhcLampr = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]), //rotary
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Lampu Mundur',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcLampm>(
//                                 value: vhcLampm.tidakAda,
//                                 groupValue: rvhcLampm,
//                                 onChanged: (vhcLampm value) {
//                                   setState(() {
//                                     rvhcLampm = value;
//                                     print(rvhcLampm.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampm>(
//                                 value: vhcLampm.tersedia,
//                                 groupValue: rvhcLampm,
//                                 onChanged: (vhcLampm value) {
//                                   setState(() {
//                                     rvhcLampm = value;
//                                     print(rvhcLampm.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampm>(
//                                 value: vhcLampm.perluPerbaikan,
//                                 groupValue: rvhcLampm,
//                                 onChanged: (vhcLampm value) {
//                                   setState(() {
//                                     rvhcLampm = value;
//                                     print(rvhcLampm.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Lampu Alarm',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcLampAlarm>(
//                                 value: vhcLampAlarm.tidakAda,
//                                 groupValue: rvhcLampAlarm,
//                                 onChanged: (vhcLampAlarm value) {
//                                   setState(() {
//                                     rvhcLampAlarm = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampAlarm>(
//                                 value: vhcLampAlarm.tersedia,
//                                 groupValue: rvhcLampAlarm,
//                                 onChanged: (vhcLampAlarm value) {
//                                   setState(() {
//                                     rvhcLampAlarm = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcLampAlarm>(
//                                 value: vhcLampAlarm.perluPerbaikan,
//                                 groupValue: rvhcLampAlarm,
//                                 onChanged: (vhcLampAlarm value) {
//                                   setState(() {
//                                     rvhcLampAlarm = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]), //END HEADER ELEKTRIK
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('Chasis',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isChasis1,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isChasis1 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("chasis", 0);
//                                   //           isChasis2 = false;
//                                   //           isChasis3 = false;
//                                   //         } else {
//                                   //           selectUnselect("chasis", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.close,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green)
//                                   // Checkbox(
//                                   //     value: isChasis2,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isChasis2 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("chasis", 1);
//                                   //           isChasis1 = false;
//                                   //           isChasis3 = false;
//                                   //         } else {
//                                   //           selectUnselect("chasis", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.check_circle,
//                                   //     size: 20, color: Colors.green)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isChasis3,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isChasis3 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("chasis", 2);
//                                   //           isChasis1 = false;
//                                   //           isChasis2 = false;
//                                   //         } else {
//                                   //           selectUnselect("chasis", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.handyman,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                               ]), //HEADER CHASIS
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Transmisi/Kopling',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcKopling>(
//                                 value: vhcKopling.tidakAda,
//                                 groupValue: rvhcKopling,
//                                 onChanged: (vhcKopling value) {
//                                   setState(() {
//                                     rvhcKopling = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKopling>(
//                                 value: vhcKopling.tersedia,
//                                 groupValue: rvhcKopling,
//                                 onChanged: (vhcKopling value) {
//                                   setState(() {
//                                     rvhcKopling = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKopling>(
//                                 value: vhcKopling.perluPerbaikan,
//                                 groupValue: rvhcKopling,
//                                 onChanged: (vhcKopling value) {
//                                   setState(() {
//                                     rvhcKopling = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Gardan',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcGardan>(
//                                 value: vhcGardan.tidakAda,
//                                 groupValue: rvhcGardan,
//                                 onChanged: (vhcGardan value) {
//                                   setState(() {
//                                     rvhcGardan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcGardan>(
//                                 value: vhcGardan.tersedia,
//                                 groupValue: rvhcGardan,
//                                 onChanged: (vhcGardan value) {
//                                   setState(() {
//                                     rvhcGardan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcGardan>(
//                                 value: vhcGardan.perluPerbaikan,
//                                 groupValue: rvhcGardan,
//                                 onChanged: (vhcGardan value) {
//                                   setState(() {
//                                     rvhcGardan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Rem Tangan',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcParking>(
//                                 value: vhcParking.tidakAda,
//                                 groupValue: rvhcParking,
//                                 onChanged: (vhcParking value) {
//                                   setState(() {
//                                     rvhcParking = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcParking>(
//                                 value: vhcParking.tersedia,
//                                 groupValue: rvhcParking,
//                                 onChanged: (vhcParking value) {
//                                   setState(() {
//                                     rvhcParking = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcParking>(
//                                 value: vhcParking.perluPerbaikan,
//                                 groupValue: rvhcParking,
//                                 onChanged: (vhcParking value) {
//                                   setState(() {
//                                     rvhcParking = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Rem Kaku',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcFoot>(
//                                 value: vhcFoot.tidakAda,
//                                 groupValue: rvhcFoot,
//                                 onChanged: (vhcFoot value) {
//                                   setState(() {
//                                     rvhcFoot = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcFoot>(
//                                 value: vhcFoot.tersedia,
//                                 groupValue: rvhcFoot,
//                                 onChanged: (vhcFoot value) {
//                                   setState(() {
//                                     rvhcFoot = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcFoot>(
//                                 value: vhcFoot.perluPerbaikan,
//                                 groupValue: rvhcFoot,
//                                 onChanged: (vhcFoot value) {
//                                   setState(() {
//                                     rvhcFoot = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Baut Roda',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcBautRoda>(
//                                 value: vhcBautRoda.tidakAda,
//                                 groupValue: rvhcBautRoda,
//                                 onChanged: (vhcBautRoda value) {
//                                   setState(() {
//                                     rvhcBautRoda = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcBautRoda>(
//                                 value: vhcBautRoda.tersedia,
//                                 groupValue: rvhcBautRoda,
//                                 onChanged: (vhcBautRoda value) {
//                                   setState(() {
//                                     rvhcBautRoda = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcBautRoda>(
//                                 value: vhcBautRoda.perluPerbaikan,
//                                 groupValue: rvhcBautRoda,
//                                 onChanged: (vhcBautRoda value) {
//                                   setState(() {
//                                     rvhcBautRoda = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Velg', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcVelg>(
//                                 value: vhcVelg.tidakAda,
//                                 groupValue: rvhcVelg,
//                                 onChanged: (vhcVelg value) {
//                                   setState(() {
//                                     rvhcVelg = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcVelg>(
//                                 value: vhcVelg.tersedia,
//                                 groupValue: rvhcVelg,
//                                 onChanged: (vhcVelg value) {
//                                   setState(() {
//                                     rvhcVelg = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcVelg>(
//                                 value: vhcVelg.perluPerbaikan,
//                                 groupValue: rvhcVelg,
//                                 onChanged: (vhcVelg value) {
//                                   setState(() {
//                                     rvhcVelg = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]), // END OTHER
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('Ban',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isBan1,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isBan1 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("ban", 0);
//                                   //           // isKabin1=false;
//                                   //           // isKabin2=false;
//                                   //           // isKabin3=false;
//                                   //           // isElektrik1 =false;
//                                   //           // isElektrik2 =false;
//                                   //           // isElektrik3 =false;
//                                   //           // isOthers1 =false;
//                                   //           // isOthers2 =false;
//                                   //           // isOthers3 =false;
//                                   //           isBan2 = false;
//                                   //           isBan3 = false;
//                                   //         } else {
//                                   //           selectUnselect("ban", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.close,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green)
//                                   // Checkbox(
//                                   //     value: isBan2,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isBan2 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("ban", 1);
//                                   //           // isKabin1=false;
//                                   //           // isKabin2=false;
//                                   //           // isKabin3=false;
//                                   //           // isElektrik1 =false;
//                                   //           // isElektrik2 =false;
//                                   //           // isElektrik3 =false;
//                                   //           // isOthers1 =false;
//                                   //           // isOthers2 =false;
//                                   //           // isOthers3 =false;
//                                   //           isBan1 = false;
//                                   //           isBan3 = false;
//                                   //         } else {
//                                   //           selectUnselect("ban", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.check_circle,
//                                   //     size: 20, color: Colors.green)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isBan3,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isBan3 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("ban", 2);
//                                   //           // isKabin1=false;
//                                   //           // isKabin2=false;
//                                   //           // isKabin3=false;
//                                   //           // isElektrik1 =false;
//                                   //           // isElektrik2 =false;
//                                   //           // isElektrik3 =false;
//                                   //           // isOthers1 =false;
//                                   //           // isOthers2 =false;
//                                   //           // isOthers3 =false;
//                                   //           isBan1 = false;
//                                   //           isBan2 = false;
//                                   //         } else {
//                                   //           selectUnselect("ban", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.handyman,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                               ]), //HEADER BAN
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Kondisi Ban',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcBan>(
//                                 value: vhcBan.tidakAda,
//                                 groupValue: rvhcBan,
//                                 onChanged: (vhcBan value) {
//                                   setState(() {
//                                     rvhcBan = value;
//                                     print(rvhcBan);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcBan>(
//                                 value: vhcBan.tersedia,
//                                 groupValue: rvhcBan,
//                                 onChanged: (vhcBan value) {
//                                   setState(() {
//                                     rvhcBan = value;
//                                     print(rvhcBan);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcBan>(
//                                 value: vhcBan.perluPerbaikan,
//                                 groupValue: rvhcBan,
//                                 onChanged: (vhcBan value) {
//                                   setState(() {
//                                     rvhcBan = value;
//                                     print(rvhcBan.index);
//                                     print(type_truck);
//                                     if (rvhcBan != null) {
//                                       if (rvhcBan.index == 2) {
//                                         isFinish();
//                                         if (type_truck == "TRAILLER") {
//                                           //Navigator.
//                                           globals.page_inspeksi = "opr";
//                                           Navigator.push(
//                                               globalScaffoldKey.currentContext,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ViewCarTRAILLER()));
//                                         }
//                                         if (type_truck == "TR") {
//                                           globals.page_inspeksi = "opr";
//                                           Navigator.push(
//                                               globalScaffoldKey.currentContext,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ViewCarTR()));
//                                         }
//                                         if (type_truck == "LT") {
//                                           globals.page_inspeksi = "opr";
//                                           Navigator.push(
//                                               globalScaffoldKey.currentContext,
//                                               MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ViewCarLT()));
//                                         }
//                                       }
//                                     }
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Tekanan Angin',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcAngin>(
//                                 value: vhcAngin.tidakAda,
//                                 groupValue: rvhcAngin,
//                                 onChanged: (vhcAngin value) {
//                                   setState(() {
//                                     rvhcAngin = value;
//                                     print(rvhcAngin.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcAngin>(
//                                 value: vhcAngin.tersedia,
//                                 groupValue: rvhcAngin,
//                                 onChanged: (vhcAngin value) {
//                                   setState(() {
//                                     rvhcAngin = value;
//                                     print(rvhcAngin.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcAngin>(
//                                 value: vhcAngin.perluPerbaikan,
//                                 groupValue: rvhcAngin,
//                                 onChanged: (vhcAngin value) {
//                                   setState(() {
//                                     rvhcAngin = value;
//                                     print(rvhcAngin.index);
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('Peralatan',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isPeralatan1,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isPeralatan1 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("peralatan", 0);
//                                   //           isPeralatan2 = false;
//                                   //           isPeralatan3 = false;
//                                   //         } else {
//                                   //           selectUnselect("peralatan", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.close,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green)
//                                   // Checkbox(
//                                   //     value: isPeralatan2,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isPeralatan2 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("peralatan", 1);
//                                   //           isPeralatan1 = false;
//                                   //           isPeralatan3 = false;
//                                   //         } else {
//                                   //           selectUnselect("peralatan", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.check_circle,
//                                   //     size: 20, color: Colors.green)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isPeralatan3,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isPeralatan3 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("peralatan", 2);
//                                   //           isPeralatan1 = false;
//                                   //           isPeralatan2 = false;
//                                   //         } else {
//                                   //           selectUnselect("peralatan", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.handyman,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                               ]), //HEADDR Peralatan
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Terpal',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcTerpal>(
//                                 value: vhcTerpal.tidakAda,
//                                 groupValue: rvhcTerpal,
//                                 onChanged: (vhcTerpal value) {
//                                   setState(() {
//                                     rvhcTerpal = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcTerpal>(
//                                 value: vhcTerpal.tersedia,
//                                 groupValue: rvhcTerpal,
//                                 onChanged: (vhcTerpal value) {
//                                   setState(() {
//                                     rvhcTerpal = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcTerpal>(
//                                 value: vhcTerpal.perluPerbaikan,
//                                 groupValue: rvhcTerpal,
//                                 onChanged: (vhcTerpal value) {
//                                   setState(() {
//                                     rvhcTerpal = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Webing',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcWebing>(
//                                 value: vhcWebing.tidakAda,
//                                 groupValue: rvhcWebing,
//                                 onChanged: (vhcWebing value) {
//                                   setState(() {
//                                     rvhcWebing = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcWebing>(
//                                 value: vhcWebing.tersedia,
//                                 groupValue: rvhcWebing,
//                                 onChanged: (vhcWebing value) {
//                                   setState(() {
//                                     rvhcWebing = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcWebing>(
//                                 value: vhcWebing.perluPerbaikan,
//                                 groupValue: rvhcWebing,
//                                 onChanged: (vhcWebing value) {
//                                   setState(() {
//                                     rvhcWebing = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Tambang',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcTambang>(
//                                 value: vhcTambang.tidakAda,
//                                 groupValue: rvhcTambang,
//                                 onChanged: (vhcTambang value) {
//                                   setState(() {
//                                     rvhcTambang = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcTambang>(
//                                 value: vhcTambang.tersedia,
//                                 groupValue: rvhcTambang,
//                                 onChanged: (vhcTambang value) {
//                                   setState(() {
//                                     rvhcTambang = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcTambang>(
//                                 value: vhcTambang.perluPerbaikan,
//                                 groupValue: rvhcTambang,
//                                 onChanged: (vhcTambang value) {
//                                   setState(() {
//                                     rvhcTambang = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Dongkrak',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcDongkrak>(
//                                 value: vhcDongkrak.tidakAda,
//                                 groupValue: rvhcDongkrak,
//                                 onChanged: (vhcDongkrak value) {
//                                   setState(() {
//                                     rvhcDongkrak = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcDongkrak>(
//                                 value: vhcDongkrak.tersedia,
//                                 groupValue: rvhcDongkrak,
//                                 onChanged: (vhcDongkrak value) {
//                                   setState(() {
//                                     rvhcDongkrak = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcDongkrak>(
//                                 value: vhcDongkrak.perluPerbaikan,
//                                 groupValue: rvhcDongkrak,
//                                 onChanged: (vhcDongkrak value) {
//                                   setState(() {
//                                     rvhcDongkrak = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Kunci Roda',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcKRoda>(
//                                 value: vhcKRoda.tidakAda,
//                                 groupValue: rvhcKRoda,
//                                 onChanged: (vhcKRoda value) {
//                                   setState(() {
//                                     rvhcKRoda = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKRoda>(
//                                 value: vhcKRoda.tersedia,
//                                 groupValue: rvhcKRoda,
//                                 onChanged: (vhcKRoda value) {
//                                   setState(() {
//                                     rvhcKRoda = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKRoda>(
//                                 value: vhcKRoda.perluPerbaikan,
//                                 groupValue: rvhcKRoda,
//                                 onChanged: (vhcKRoda value) {
//                                   setState(() {
//                                     rvhcKRoda = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Ganjal Ban',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcGBan>(
//                                 value: vhcGBan.tidakAda,
//                                 groupValue: rvhcGBan,
//                                 onChanged: (vhcGBan value) {
//                                   setState(() {
//                                     rvhcGBan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcGBan>(
//                                 value: vhcGBan.tersedia,
//                                 groupValue: rvhcGBan,
//                                 onChanged: (vhcGBan value) {
//                                   setState(() {
//                                     rvhcGBan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcGBan>(
//                                 value: vhcGBan.perluPerbaikan,
//                                 groupValue: rvhcGBan,
//                                 onChanged: (vhcGBan value) {
//                                   setState(() {
//                                     rvhcGBan = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' GPS', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcGps>(
//                                 value: vhcGps.tidakAda,
//                                 groupValue: rvhcGps,
//                                 onChanged: (vhcGps value) {
//                                   setState(() {
//                                     rvhcGps = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcGps>(
//                                 value: vhcGps.tersedia,
//                                 groupValue: rvhcGps,
//                                 onChanged: (vhcGps value) {
//                                   setState(() {
//                                     rvhcGps = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcGps>(
//                                 value: vhcGps.perluPerbaikan,
//                                 groupValue: rvhcGps,
//                                 onChanged: (vhcGps value) {
//                                   setState(() {
//                                     rvhcGps = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' DashCam',
//                                       style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcDashCam>(
//                                 value: vhcDashCam.tidakAda,
//                                 groupValue: rvhcDashCam,
//                                 onChanged: (vhcDashCam value) {
//                                   setState(() {
//                                     rvhcDashCam = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcDashCam>(
//                                 value: vhcDashCam.tersedia,
//                                 groupValue: rvhcDashCam,
//                                 onChanged: (vhcDashCam value) {
//                                   setState(() {
//                                     rvhcDashCam = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcDashCam>(
//                                 value: vhcDashCam.perluPerbaikan,
//                                 groupValue: rvhcDashCam,
//                                 onChanged: (vhcDashCam value) {
//                                   setState(() {
//                                     rvhcDashCam = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(
//                               decoration: BoxDecoration(color: Colors.grey),
//                               children: [
//                                 Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.all(10),
//                                           child: Text('Dokumen',
//                                               style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold)))
//                                     ]),
//                                 Column(children: [
//                                   Icon(Icons.close,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isDokumen1,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isDokumen1 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("document", 0);
//                                   //           isDokumen2 = false;
//                                   //           isDokumen3 = false;
//                                   //         } else {
//                                   //           selectUnselect("document", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.close,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.check_circle,
//                                       size: 20, color: Colors.green)
//                                   // Checkbox(
//                                   //     value: isDokumen2,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isDokumen2 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("document", 1);
//                                   //           isDokumen1 = false;
//                                   //           isDokumen3 = false;
//                                   //         } else {
//                                   //           selectUnselect("document", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.check_circle,
//                                   //     size: 20, color: Colors.green)
//                                 ]),
//                                 Column(children: [
//                                   Icon(Icons.handyman,
//                                       size: 20, color: Colors.redAccent)
//                                   // Checkbox(
//                                   //     value: isDokumen3,
//                                   //     onChanged: (bool newValue) {
//                                   //       setState(() {
//                                   //         isDokumen3 = newValue;
//                                   //         if (newValue == true) {
//                                   //           selectUnselect("document", 2);
//                                   //           isDokumen1 = false;
//                                   //           isDokumen2 = false;
//                                   //         } else {
//                                   //           selectUnselect("document", -1);
//                                   //         }
//                                   //       });
//                                   //     }),
//                                   // Icon(Icons.handyman,
//                                   //     size: 20, color: Colors.redAccent)
//                                 ]),
//                               ]), //HEADER DOKUMENT
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' STNK', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcSurat>(
//                                 value: vhcSurat.tidakAda,
//                                 groupValue: rvhcSurat,
//                                 onChanged: (vhcSurat value) {
//                                   setState(() {
//                                     rvhcSurat = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSurat>(
//                                 value: vhcSurat.tersedia,
//                                 groupValue: rvhcSurat,
//                                 onChanged: (vhcSurat value) {
//                                   setState(() {
//                                     rvhcSurat = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSurat>(
//                                 value: vhcSurat.perluPerbaikan,
//                                 groupValue: rvhcSurat,
//                                 onChanged: (vhcSurat value) {
//                                   setState(() {
//                                     rvhcSurat = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' Kir', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcKir>(
//                                 value: vhcKir.tidakAda,
//                                 groupValue: rvhcKir,
//                                 onChanged: (vhcKir value) {
//                                   setState(() {
//                                     rvhcKir = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKir>(
//                                 value: vhcKir.tersedia,
//                                 groupValue: rvhcKir,
//                                 onChanged: (vhcKir value) {
//                                   setState(() {
//                                     rvhcKir = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcKir>(
//                                 value: vhcKir.perluPerbaikan,
//                                 groupValue: rvhcKir,
//                                 onChanged: (vhcKir value) {
//                                   setState(() {
//                                     rvhcKir = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                           TableRow(children: [
//                             Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(' SIM', style: TextStyle(fontSize: 14))
//                                 ]),
//                             Column(children: [
//                               Radio<vhcSim>(
//                                 value: vhcSim.tidakAda,
//                                 groupValue: rvhcSim,
//                                 onChanged: (vhcSim value) {
//                                   setState(() {
//                                     rvhcSim = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSim>(
//                                 value: vhcSim.tersedia,
//                                 groupValue: rvhcSim,
//                                 onChanged: (vhcSim value) {
//                                   setState(() {
//                                     rvhcSim = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                             Column(children: [
//                               Radio<vhcSim>(
//                                 value: vhcSim.perluPerbaikan,
//                                 groupValue: rvhcSim,
//                                 onChanged: (vhcSim value) {
//                                   setState(() {
//                                     rvhcSim = value;
//                                   });
//                                 },
//                               )
//                             ]),
//                           ]),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.all(10.0),
//                       child: TextField(
//                         cursorColor: Colors.black,
//                         style: TextStyle(color: Colors.grey.shade800),
//                         controller: txtKm,
//                         keyboardType: TextInputType.number,
//                         decoration: new InputDecoration(
//                           fillColor: Colors.white,
//                           filled: true,
//                           isDense: true,
//                           labelText: "Kilometer",
//                           contentPadding: EdgeInsets.all(5.0),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.all(10.0),
//                       child: TextField(
//                         cursorColor: Colors.black,
//                         style: TextStyle(color: Colors.grey.shade800),
//                         controller: txtNotes,
//                         onChanged: (value) {
//                           if (value != null && value != "") {
//                             globals.rvhcNotes = value;
//                           }
//                         },
//                         maxLength: 100,
//                         keyboardType: TextInputType.text,
//                         decoration: new InputDecoration(
//                           fillColor: Colors.white,
//                           filled: true,
//                           isDense: true,
//                           labelText: "Notes",
//                           contentPadding: EdgeInsets.all(5.0),
//                         ),
//                       ),
//                     ),
//                     Container(
//                         width: double.infinity,
//                         margin: EdgeInsets.all(10.0),
//                         child: Row(children: <Widget>[
//                           Expanded(
//                             child: _builButtonReset(context),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Expanded(
//                             child: _builButtonNext(context),
//                           ),
//                         ]))
//                   ])))),
//     );
//   }
//
//   Widget _builButtonReset(BuildContext context) {
//     return new ElevatedButton.icon(
//       icon: Icon(
//         Icons.reset_tv,
//         color: Colors.white,
//         size: 15.0,
//       ),
//       label: Text("Reset"),
//       onPressed: () async {
//         ResetCheckBox();
//       },
//       style: ElevatedButton.styleFrom(
//           elevation: 0.0,
//           backgroundColor: Colors.red,
//           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//           textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//     );
//   }
//
//   Widget _builButtonNext(BuildContext context) {
//     return new ElevatedButton.icon(
//       icon: Icon(
//         Icons.save,
//         color: Colors.white,
//         size: 15.0,
//       ),
//       label: Text("Submit"),
//       onPressed: () async {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         showDialog(
//           context: context,
//           builder: (context) => new AlertDialog(
//             title: new Text('Information'),
//             content: new Text("Create Form Inspeksi ${globals.p2hVhcid}"),
//             actions: <Widget>[
//               new ElevatedButton.icon(
//                 icon: Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 20.0,
//                 ),
//                 label: Text("No"),
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//                 style: ElevatedButton.styleFrom(
//                     elevation: 0.0,
//                     backgroundColor: Colors.red,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                     textStyle:
//                         TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//               ),
//               new ElevatedButton.icon(
//                 icon: Icon(
//                   Icons.save,
//                   color: Colors.white,
//                   size: 20.0,
//                 ),
//                 label: Text("Ok"),
//                 onPressed: () async {
//                   Navigator.of(context).pop(false);
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   var username = prefs.getString("name");
//                   isFinish();
//                   print(globals.rvhcMrem);
//                   print("globals.rvhcOliMesin ${globals.rvhcOliMesin}");
//                   if (globals.p2hVhcid == null || globals.p2hVhcid == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Vehicle ID tidak boleh kosong", "error");
//                   } else if (txtKm.text == null || txtKm.text == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "KIlometer tidak boleh kosong", "error");
//                   } else if (int.parse(txtKm.text) <= 0) {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "KIlometer tidak boleh <= 0", "error");
//                   } else if (globals.rvhcOliMesin == null || globals.rvhcOliMesin == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Oli mesin tidak boleh kosong", "error");
//                   }else if (globals.rvhcOliGardan == null || globals.rvhcOliGardan == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Oli gardan tidak boleh kosong", "error");
//                   }else if (globals.rvhcOliTransmisi == null || globals.rvhcOliTransmisi == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Oli transmisi tidak boleh kosong", "error");
//                   } else if (globals.rvhcAir == null || globals.rvhcAir == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Radiator tidak boleh kosong", "error");
//                   } else if (globals.rvhcAccu == null ||
//                       globals.rvhcAccu == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Accu tidak boleh kosong", "error");
//                   } else if (globals.rvhcMrem == null ||
//                       globals.rvhcMrem == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Minyak rem tidak boleh kosong", "error");
//                   } else if (globals.rvhcOLips == null ||
//                       globals.rvhcOLips == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Oli Power steering tidak boleh kosong", "error");
//                   } else if (globals.rvhcKabin == null ||
//                       globals.rvhcKabin == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Kabin steering tidak boleh kosong", "error");
//                   } else if (globals.rvhcKaca == null ||
//                       globals.rvhcKaca == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Kaca tidak boleh kosong", "error");
//                   } else if (globals.rvhcSpion == null ||
//                       globals.rvhcSpion == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Spion tidak boleh kosong", "error");
//                   } else if (globals.rvhcSpeedo == null ||
//                       globals.rvhcSpeedo == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Speedometer tidak boleh kosong", "error");
//                   } else if (globals.rvhcWiper == null ||
//                       globals.rvhcWiper == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Wiper tidak boleh kosong", "error");
//                   } else if (globals.rvhcKlak == null ||
//                       globals.rvhcKlak == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Klakson tidak boleh kosong", "error");
//                   } else if (globals.rvhcJok == null || globals.rvhcJok == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Jok tidak boleh kosong", "error");
//                   } else if (globals.rvhcSeatBealt == null ||
//                       globals.rvhcSeatBealt == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Seat Bealt tidak boleh kosong", "error");
//                   } else if (globals.rvhcApar == null ||
//                       globals.rvhcApar == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "APAR tidak boleh kosong", "error");
//                   } else if (globals.rvhcP3k == null || globals.rvhcP3k == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "P3K tidak boleh kosong", "error");
//                   } else if (globals.rvhcCone == null ||
//                       globals.rvhcCone == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Segitiga pengaman tidak boleh kosong", "error");
//                   }else if (globals.rvhcStikerRef == null ||
//                       globals.rvhcStikerRef == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Stiker Reflektor tidak boleh kosong", "error");
//                   } else if (globals.rvhcLampd == null ||
//                       globals.rvhcLampd == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Lampu depan tidak boleh kosong", "error");
//                   } else if (globals.rvhcLamps == null ||
//                       globals.rvhcLamps == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Lampu sign tidak boleh kosong", "error");
//                   } else if (globals.rvhcLampBlk == null ||
//                       globals.rvhcLampBlk == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Lampu belakang tidak boleh kosong", "error");
//                   } else if (globals.rvhcLampr == null ||
//                       globals.rvhcLampr == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Lampu Rotary tidak boleh kosong", "error");
//                   } else if (globals.rvhcLampm == null ||
//                       globals.rvhcLampm == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Lampu mundur tidak boleh kosong", "error");
//                   } else if (globals.rvhcLampAlarm == null ||
//                       globals.rvhcLampAlarm == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Lampu Alarm tidak boleh kosong", "error");
//                   } else if (globals.rvhcKopling == null ||
//                       globals.rvhcKopling == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Transmisi kopling tidak boleh kosong", "error");
//                   } else if (globals.rvhcGardan == null ||
//                       globals.rvhcGardan == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Gardan kopling tidak boleh kosong", "error");
//                   } else if (globals.rvhcParking == null ||
//                       globals.rvhcParking == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Rem tangan tidak boleh kosong", "error");
//                   } else if (globals.rvhcFoot == null ||
//                       globals.rvhcFoot == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Rem kaki tidak boleh kosong", "error");
//                   } else if (globals.rvhcBautRoda == null ||
//                       globals.rvhcBautRoda == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Baut roda tidak boleh kosong", "error");
//                   } else if (globals.rvhcVelg == null ||
//                       globals.rvhcVelg == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Velg tidak boleh kosong", "error");
//                   } else if (globals.rvhcBan == null || globals.rvhcBan == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Ban tidak boleh kosong", "error");
//                   } else if (globals.rvhcAngin == null ||
//                       globals.rvhcAngin == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Angin tidak boleh kosong", "error");
//                   } else if (globals.rvhcTerpal == null ||
//                       globals.rvhcTerpal == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Terpal tidak boleh kosong", "error");
//                   } else if (globals.rvhcWebing == null ||
//                       globals.rvhcWebing == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Webing tidak boleh kosong", "error");
//                   } else if (globals.rvhcTambang == null ||
//                       globals.rvhcTambang == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Tambang tidak boleh kosong", "error");
//                   } else if (globals.rvhcDongkrak == null ||
//                       globals.rvhcDongkrak == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Dongkrak tidak boleh kosong", "error");
//                   } else if (globals.rvhcKRoda == null ||
//                       globals.rvhcKRoda == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Kunci Roda tidak boleh kosong", "error");
//                   } else if (globals.rvhcGBan == null ||
//                       globals.rvhcGBan == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Ganjal ban tidak boleh kosong", "error");
//                   } else if (globals.rvhcGps == null || globals.rvhcGps == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "GPS tidak boleh kosong", "error");
//                   } else if (globals.rvhcDashCam == null ||
//                       globals.rvhcDashCam == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Dash Camera tidak boleh kosong", "error");
//                   } else if (globals.rvhcSurat == null ||
//                       globals.rvhcSurat == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "STNK tidak boleh kosong", "error");
//                   } else if (globals.rvhcKir == null || globals.rvhcKir == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "KIR tidak boleh kosong", "error");
//                   } else if (globals.rvhcSim == null || globals.rvhcSim == "") {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "SIM tidak boleh kosong", "error");
//                   } else if (int.parse(txtKm.text) <= 0) {
//                     alert(globalScaffoldKey.currentContext, 0,
//                         "Kilometer tidak boleh kosong", "error");
//                   } else {
//                     print("globals.rvhcOliMesin");
//                     print(globals.rvhcOliMesin);
//                     createFormInspeksi(username);
//                   }
//                   // Navigator.pushReplacement(context,
//                   //     MaterialPageRoute(builder: (context) => ViewAntrian()));
//                 },
//                 style: ElevatedButton.styleFrom(
//                     elevation: 0.0,
//                     backgroundColor: Colors.blue,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                     textStyle:
//                         TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         );
//       },
//       style: ElevatedButton.styleFrom(
//           elevation: 0.0,
//           backgroundColor: Colors.red,
//           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//           textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//     );
//   }
// }
