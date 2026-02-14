// import 'package:carousel_pro/carousel_pro.dart';
// import 'package:dms_anp/src/Helper/Provider.dart';
// import 'package:dms_anp/src/Theme/app_theme.dart';
// import 'package:dms_anp/src/custom_loader.dart';
// import 'package:dms_anp/src/loginPage.dart';
// import 'package:dms_anp/src/pages/ViewListDo.dart';
// import 'package:dms_anp/src/pages/ViewListVehicle.dart';
// import 'package:flutter/material.dart';
// import 'package:dms_anp/src/Color/hex_color.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'ViewDashboard.dart';
//
// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
//   SharedPreferences sharedPreferences;
//   String spLoginName;
//   String loginname;
//
//   Future getLoginName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     GlobalData.loginname = prefs.getString("loginname");
//     print("LoGINNAME " + GlobalData.loginname);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     configLoading();
//     EasyLoading.show();
//     getDataPreference();
//     EasyLoading.dismiss();
//   }
//
//   getDataPreference() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//     setState(() {
//       loginname = sharedPreferences.getString("loginname");
//       if(loginname != null) {
//         spLoginName = sharedPreferences.getString("loginname");
//       } else {
//         spLoginName = "Sign in with Google";
//       }
//     });
//   }
//
//
//   void loginName(String value) {
//     setState(() {
//       GlobalData.loginname = value;
//     });
//     sharedPreferences?.setString("loginname", value);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new WillPopScope(
//       onWillPop: _onWillPop,
//       child: new Scaffold(
//         body: Container(
//           //key: _homeKey,
//           constraints: BoxConstraints.expand(),
//           color: HexColor("#f0eff4"),
//           child: Stack(
//             children: <Widget>[
//               ImgHeader1(context),
//               ImgHeader2(context),
//               BuildHeader(context),
//               _getContent(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _getContent(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(10.0, 250.0, 10.0, 0.0),
//       child: ListView(
//         children: <Widget>[
//           Container(
//             child: Card(
//               elevation: 14.0,
//               shadowColor: Color(0x802196F3),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0)),
//               clipBehavior: Clip.antiAlias,
//               child: InkWell(
//                 onTap: () {
//                   if (spLoginName == "DISPATCH") {
//                     Navigator.pushReplacement(
//                         context, MaterialPageRoute(builder: (context) => ViewDashboard()));
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => ViewDashboard(),
//                     //   ),
//                     // );
//                   } else {
//                     Navigator.pushReplacement(
//                         context, MaterialPageRoute(builder: (context) => ViewListDo()));
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => ViewListDo(),
//                     //   ),
//                     // );
//                   }
//                 },
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: Icon(
//                         Icons.work,
//                         size: 30,
//                         color: Colors.red,
//                       ),
//                       title: Text(
//                           spLoginName == "DISPATCH"
//                               ? 'List Vehicle'
//                               : 'Delivery Order',
//                           style: TextStyle(
//                               fontSize: 20.0, color: AppTheme.nearlyBlack)),
//                       trailing: Icon(
//                         Icons.arrow_right,
//                         color: Colors.blueGrey,
//                         size: 35,
//                       ),
//                       tileColor: HexColor('#fff'),
//                       //tileColor: AppTheme.dark_grey,
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//             child: Card(
//               elevation: 14.0,
//               shadowColor: Color(0x802196F3),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0)),
//               clipBehavior: Clip.antiAlias,
//               child: InkWell(
//                 onTap: () {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     builder: (context) => Safety(),
//                   //   ),
//                   // );
//                 },
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: Icon(
//                         Icons.people,
//                         size: 30,
//                         color: Colors.green,
//                       ),
//                       title: Text('Profile',
//                           style: TextStyle(
//                               fontSize: 20.0, color: AppTheme.nearlyBlack)),
//                       trailing: Icon(
//                         Icons.arrow_right,
//                         color: Colors.blueGrey,
//                         size: 35,
//                       ),
//                       tileColor: HexColor('#fff'),
//                       //tileColor: AppTheme.dark_grey,
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//             child: Card(
//               elevation: 14.0,
//               shadowColor: Color(0x802196F3),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0)),
//               clipBehavior: Clip.antiAlias,
//               child: InkWell(
//                 onTap: () {
//                   _onWillPop();
//                 },
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: Icon(
//                         Icons.logout,
//                         size: 30,
//                         color: Colors.orange,
//                       ),
//                       title: Text('Log Out',
//                           style: TextStyle(
//                               fontSize: 20.0, color: AppTheme.nearlyBlack)),
//                       tileColor: HexColor('#fff'),
//                       //tileColor: AppTheme.dark_grey,
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget LoadListMenu(BuildContext context) {
//     return Expanded(
//       child: Container(
//         //padding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
//         margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
//         child: GridView.count(
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           crossAxisCount: 3,
//           //childAspectRatio: .90,
//           children: <Widget>[
//             Container(
//               height: 10,
//               child: Card(
//                 semanticContainer: true,
//                 clipBehavior: Clip.antiAliasWithSaveLayer,
//                 elevation: 5.0,
//                 //shadowColor: Color(0x802196F3),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//                 child: InkWell(
//                   onTap: () => Navigator.pushReplacement(context,
//                       MaterialPageRoute(builder: (context) => ViewListDo())),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         Material(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.circular(15.0),
//                             child: Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Icon(Icons.pageview,
//                                   color: Colors.white, size: 34.0),
//                             )),
//                         Padding(padding: EdgeInsets.only(bottom: 10.0)),
//                         //AutoSizeText('Dashboard')
//                         Text('List DO OPENED',
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 20.0)),
//                         //Text('Dashboard',
//                         //    style: TextStyle(color: Colors.black45)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               child: Card(
//                 elevation: 5.0,
//                 //shadowColor: Color(0x802196F3),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//                 child: InkWell(
//                   // onTap: () => Navigator.pushReplacement(context,
//                   //     MaterialPageRoute(builder: (context) => DoPage())),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         Material(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(15.0),
//                             child: Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Icon(Icons.work,
//                                   color: Colors.white, size: 34.0),
//                             )),
//                         Padding(padding: EdgeInsets.only(bottom: 10.0)),
//                         Text('Profile',
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 20.0)),
//                         //Text('Dashboard',
//                         //    style: TextStyle(color: Colors.black45)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               child: Card(
//                 elevation: 5.0,
//                 //shadowColor: Color(0x802196F3),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//                 child: InkWell(
//                   onTap: () {
//                     print("LOGOUT");
//                   },
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         Material(
//                             color: Colors.orange,
//                             borderRadius: BorderRadius.circular(15.0),
//                             child: Padding(
//                               padding: EdgeInsets.all(10.0),
//                               child: Icon(Icons.person,
//                                   color: Colors.white, size: 34.0),
//                             )),
//                         Padding(padding: EdgeInsets.only(bottom: 10.0)),
//                         Text('Log Out',
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 20.0)),
//                         //Text('Dashboard',
//                         //    style: TextStyle(color: Colors.black45)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget ImgHeader1(BuildContext context) {
//     return Container(
//       child: new Image.asset(
//         "assets/img/truck_header.jpg",
//         fit: BoxFit.cover,
//         height: 300.0,
//       ),
//       constraints: new BoxConstraints.expand(height: 295.0),
//     );
//   }
//
//   Widget ImgHeader2(BuildContext context) {
//     return Container(
//       margin: new EdgeInsets.only(top: 190.0),
//       height: 110.0,
//       decoration: new BoxDecoration(
//         gradient: new LinearGradient(
//           //colors: <Color>[new Color(0x00736AB7), new Color(0xFF736AB7)],
//           colors: <Color>[new Color(0x00736AB7), HexColor("#f0eff4")],
//           stops: [0.0, 0.9],
//           begin: const FractionalOffset(0.0, 0.0),
//           end: const FractionalOffset(0.0, 1.0),
//         ),
//       ),
//     );
//   }
//
//   Future<bool> _onWillPop() async {
//     return (await showDialog(
//           context: context,
//           builder: (context) => new AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(15.0))),
//             title: new Text('Are you sure?'),
//             content: new Text('Do you want to exit an App'),
//             actions: <Widget>[
//               // ignore: deprecated_member_use
//               new TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: new Text('No'),
//               ),
//               // ignore: deprecated_member_use
//               new TextButton(
//                 onPressed: () async {
//                   SharedPreferences preferences =
//                       await SharedPreferences.getInstance();
//                   await preferences.clear();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LoginPage(),
//                     ),
//                   );
//                 },
//                 child: new Text('Yes'),
//               ),
//             ],
//           ),
//         )) ??
//         false;
//   }
//
//   Widget BuildHeader(BuildContext context) {
//     return ListTile(
//         contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
//         title: Text(
//           'Driver Management System',
//           style: TextStyle(
//               color: AppTheme.nearlyWhite,
//               fontWeight: FontWeight.w500,
//               fontSize: 16.0),
//         ),
//         trailing: Icon(Icons.account_circle,
//             size: 35,
//             color: AppTheme
//                 .nearlyBlack) //CircleAvatar(backgroundColor: AppTheme.white),
//         );
//   }
// }
//
// Widget CarouselImg(BuildContext context) {
//   return Container(
//     margin: new EdgeInsets.only(
//       top: 0,
//     ),
//     child: SizedBox(
//       height: MediaQuery.of(context).size.height / 4.5,
//       width: MediaQuery.of(context).size.width - 32,
//       child: Carousel(
//         borderRadius: true,
//         radius: Radius.circular(15.0),
//         boxFit: BoxFit.fill,
//         autoplay: true,
//         animationCurve: Curves.easeInOutQuad,
//         animationDuration: Duration(milliseconds: 500),
//         dotSize: 6.0,
//         dotIncreasedColor: HexColor("#003b65"),
//         dotBgColor: Colors.transparent,
//         dotPosition: DotPosition.bottomCenter,
//         dotVerticalPadding: 10.0,
//         showIndicator: true,
//         indicatorBgPadding: 7.0,
//         images: [
//           NetworkImage(
//               'https://vtsadmin.easygo-gps.co.id/picture/apps_banner_1.jpg'),
//           NetworkImage(
//               'https://vtsadmin.easygo-gps.co.id/picture/apps_banner_2.jpg'),
//           NetworkImage(
//               'https://vtsadmin.easygo-gps.co.id/picture/apps_banner_3.jpg'),
//           NetworkImage(
//               'https://vtsadmin.easygo-gps.co.id/picture/apps_banner_4.jpg'),
//           NetworkImage(
//               'https://vtsadmin.easygo-gps.co.id/picture/apps_banner_5.jpg'),
//         ],
//         //images: listBanner,
//       ),
//     ),
//   );
// }
//
// Card makeDashboardItem(int id, String title, IconData icon) {
//   return Card(
//       elevation: 1.0,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(color: Colors.white70, width: 1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       margin: new EdgeInsets.all(8.0),
//       child: Container(
//         decoration: new BoxDecoration(
//             color: Colors.white70, //new Color.fromRGBO(255, 0, 0, 0.0),
//             borderRadius: new BorderRadius.only(
//                 topLeft: const Radius.circular(10.0),
//                 topRight: const Radius.circular(10.0))),
//         //decoration: BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1.0)),
//         child: new InkWell(
//           onTap: () {
//             if (id == 1) {
//               //EasyLoading.show();
//               runApp(MaterialApp(home: Home()));
//               //EasyLoading.dismiss();
//             } else if (id == 2) {
//               //alert(context, 1, "On progress", "success");
//             } else if (id == 3) {
//               //alert(context, 1, "On progress", "success");
//             } else if (id == 4) {
//               //alert(context, 1, "On progress", "success");
//             }
//           },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             mainAxisSize: MainAxisSize.min,
//             verticalDirection: VerticalDirection.down,
//             children: <Widget>[
//               SizedBox(height: 50.0),
//               Center(
//                   child: Icon(
//                 icon,
//                 size: 40.0,
//                 color: Colors.black,
//               )),
//               SizedBox(height: 20.0),
//               new Center(
//                 child: new Text(title,
//                     style: new TextStyle(fontSize: 18.0, color: Colors.black)),
//               )
//             ],
//           ),
//         ),
//       ));
// }
