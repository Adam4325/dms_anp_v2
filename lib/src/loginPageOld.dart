// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:dms_anp/src/Helper/Provider.dart';
// import 'package:dms_anp/src/flusbar.dart';
// import 'package:dms_anp/src/pages/ViewDashboard.dart';
// import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_select/smart_select.dart';
// import '../../../choices.dart' as choices;
//
// import 'widgets/bezierContainer.dart';
//
// class LoginPage extends StatefulWidget {
//   LoginPage({Key key, this.title}) : super(key: key);
//   final String title;
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// final globalScaffoldKey = GlobalKey<ScaffoldState>();
//
// class _LoginPageState extends State<LoginPage> {
//   GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
//   DateTime? currentBackPressTime;
//   var server_value='default';
//   TextEditingController TxtUsername = new TextEditingController();
//   TextEditingController TxtPassword = new TextEditingController();
//   List<String> listServer = <String>['default', 'mirroring'];
//   @override
//   void initState() {
//     super.initState();
//     //configLoading();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   Future<bool> onWillPop() {
//     return Future.value(false);
//   }
//
//   Future doLogin(BuildContext context) async {
//     EasyLoading.show();
//     try {
//       final JsonDecoder _decoder = new JsonDecoder();
//       //var endpointUrl = "${GlobalData.baseUrl}api/authorize.jsp";
//       var endpointUrl = "";
//       setState(() {
//         //"http://${server_name}/trucking/mobile/
//         print("login server_value ${server_value}");
//         if(server_value=="mirroring"){
//           endpointUrl = "http://101.255.103.242:8080/trucking/mobile/api/authorize_v3.jsp";
//         }else{
//           endpointUrl = "http://hen08xv0xw5.sn.mynetname.net:8080/trucking/mobile/api/authorize_v3.jsp";
//           //endpointUrl = "http://apps.tuluatas.com:8080/trucking/mobile/api/authorize_v3.jsp";
//         }
//
//       });
//       String username;
//       String password;
//       username = TxtUsername.text;
//       password = TxtPassword.text;
//
//       Map<String, String> queryParams = {
//         'method': 'authorize-v1',
//         'username': username,
//         'password': password,
//       };
//       print(queryParams);
//       var headers = {
//         HttpHeaders.contentTypeHeader: 'application/json',
//       };
//
//       String queryString = Uri(queryParameters: queryParams).query;
//
//       var requestUrl = endpointUrl +
//           '?' +
//           queryString; // result - https://www.myurl.com/api/v1/user?param1=1&param2=2
//       Uri myUri = Uri.parse(requestUrl);
//       print(myUri);
//       var response = await http.get(myUri, headers: headers);
//       if (response.statusCode != 200) {
//         // if (pr.isShowing()) {
//         //   await pr.hide();
//         // }
//         EasyLoading.dismiss();
//         alert(globalScaffoldKey.currentContext, 0, "Error while fetching data",
//             "error");
//       } else {
//         if (response.statusCode == 200) {
//           var result = _decoder.convert(response.body);
//           print(result["status_code"]);
//
//           if (int.parse(result["status_code"]) == 100) {
//             // if (pr.isShowing()) {
//             //   await pr.hide();
//             // }
//             EasyLoading.dismiss();
//             alert(globalScaffoldKey.currentContext, 0, result["message"],
//                 "error");
//           } else {
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             var drvid = result["data"][0]["drvid"];
//             var mechanicid = result["data"][0]["drvid"];
//             var name = result["data"][0]["name"];
//             var nickname = result["data"][0]["nickname"];
//             var loginname = result["data"][0]["loginname"];
//             var vhcid = result["data"][0]["vhcid"];
//             var vhcnopol = result["data"][0]["vhcnopol"];
//             var locid = result["data"][0]["locid"];
//             var akses_page = result["akses"][0];
//             var vhckm = result["data"][0]["vhckm"];
//             var cpyid = result["data"][0]["cpyid"];
//             var cpyname = result["data"][0]["cpyname"];
//             var ismixer = result["data"][0]["ismixer"];
//
//             if (loginname != null && loginname != "DRIVER") {
//               if (akses_page != null) {
//                 String s = akses_page;
//                 print(s);
//                 var dataAkses = s.split(',');
//                 List<String> arrAksesPage = [];
//                 if (dataAkses.length > 0) {
//                   for (var i = 0; i < dataAkses.length; i++) {
//                     print(dataAkses[i]);
//                     arrAksesPage.add(dataAkses[i]);
//                   }
//                 }
//                 prefs.setStringList("akses_pages", arrAksesPage);
//               }
//             }
//
//             print(drvid);
//             print(cpyid);
//             print(cpyname);
//             print(vhcnopol);
//             print(vhcid);
//             if ((prefs.getString('loginname') != null &&
//                 prefs.getString('loginname') == 'DRIVER')) {
//               if (prefs.getString('bujnumber') != null &&
//                   prefs.getString('drvid') == drvid &&
//                   prefs.getString('vhcid') == vhcid) {
//                 print('buj number ${prefs.getString('bujnumber')}');
//               } else {
//                 prefs.remove('bujnumber');
//               }
//             }
//
//             prefs.setString('drvid', drvid);
//             prefs.setString('mechanicid', mechanicid);
//             prefs.setString('username', username);
//             prefs.setString('name', name);
//             prefs.setString('nickname', nickname);
//             prefs.setString('loginname', loginname);
//             prefs.setString('vhcid', vhcid);
//             prefs.setString('vhcnopol', vhcnopol);
//             prefs.setString('locid', locid);
//             prefs.setString('vhckm', vhckm);
//             prefs.setString('cpyid', cpyid);
//             prefs.setString('cpyname', cpyname);
//             prefs.setString('cpyname', cpyname);
//             prefs.setString('ismixer', ismixer);
//
//             Timer(Duration(seconds: 1), () async {
//               // if (pr.isShowing()) {
//               //   await pr.hide();
//               // }
//               EasyLoading.dismiss();
//               if (loginname == "MECHANIC") {
//                 Navigator.pushReplacement(globalScaffoldKey.currentContext,
//                     MaterialPageRoute(builder: (context) => ViewListWoMCN()));
//               } else {
//                 Navigator.pushReplacement(globalScaffoldKey.currentContext,
//                     MaterialPageRoute(builder: (context) => ViewDashboard()));
//               }
//             });
//           }
//         } else {
//           // if (pr.isShowing()) {
//           //   await pr.hide();
//           // }
//           EasyLoading.dismiss();
//           alert(globalScaffoldKey.currentContext, 0, response.reasonPhrase,
//               "error");
//         }
//       }
//     } catch (e) {
//       // if (pr.isShowing()) {
//       //   await pr.hide();
//       // }
//       EasyLoading.dismiss();
//       print(e);
//     }
//   }
//
//   Widget _entryField(
//       String title, String hintText, TextEditingController inputText,
//       {bool isPassword = false}) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           // Text(
//           //   title,
//           //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           // ),
//           SizedBox(
//             height: 10,
//           ),
//           TextField(
//               controller: inputText,
//               cursorColor: Colors.white,
//               style: TextStyle(color: Colors.white),
//               obscureText: isPassword,
//               decoration: InputDecoration(
//                   hintText: hintText,
//                   hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(15)),
//                     borderSide: BorderSide(width: 0, color: Colors.blue),
//                   ),
//                   fillColor: Colors.blue,
//                   filled: true))
//         ],
//       ),
//     );
//   }
//
//   Widget serverDefault() {
//     // return DropdownButton<String>(
//     //   items: <String>['default', 'mirroring'].map((String value) {
//     //     return DropdownMenuItem<String>(
//     //       value: value,
//     //       child: Text(value),
//     //     );
//     //   }).toList(),
//     //   onChanged: (_) {},
//     // );
//
//     return SmartSelect<String>.single(
//       title: 'Server name ',
//       value: server_value,
//       onChange: (selected) async{
//         // setState(() => server_value = selected.value);
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         print('server name ${selected.value}');
//         setState(() {
//           server_value = selected.value;
//           prefs.setString("server_name",selected.value);
//         });
//       },
//       choiceType: S2ChoiceType.radios,
//       choiceItems: choices.listServerName,
//       modalType: S2ModalType.popupDialog,
//       modalHeader: false,
//       modalConfig: const S2ModalConfig(
//         style: S2ModalStyle(
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0)),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _submitButton() {
//     return InkWell(
//         onTap: () async {
//           try {
//             await doLogin(context);
//             //EasyLoading.dismiss();
//           } catch (e) {
//             pr.hide();
//             alert(globalScaffoldKey.currentContext, 0, e, "error");
//           }
//         },
//         child: new Container(
//           width: MediaQuery.of(context).size.width / 2,
//           padding: EdgeInsets.symmetric(vertical: 15),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(15)),
//               boxShadow: <BoxShadow>[
//                 BoxShadow(
//                     color: Colors.grey.shade200,
//                     offset: Offset(2, 4),
//                     blurRadius: 5,
//                     spreadRadius: 2)
//               ],
//               gradient: LinearGradient(
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                   colors: [Colors.blueAccent, Colors.blue])),
//           child: Text(
//             'Login',
//             style: TextStyle(fontSize: 20, color: Colors.white),
//           ),
//         ));
//   }
//
//   Widget _divider() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: <Widget>[
//           SizedBox(
//             width: 20,
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Divider(
//                 thickness: 1,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 20,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _title() {
//     return RichText(
//       textAlign: TextAlign.center,
//       text: TextSpan(
//           text: 'ANP',
//           style: GoogleFonts.portLligatSans(
//             textStyle: Theme.of(context).textTheme.headline1,
//             fontSize: 30,
//             fontWeight: FontWeight.w700,
//             color: Color(0xfffd3939), //Color(0xfffd3939), Color(0xffe3023c)
//           ),
//           children: [
//             TextSpan(
//               text: 'D',
//               style: TextStyle(color: Colors.black, fontSize: 30),
//             ),
//             TextSpan(
//               text: 'MS',
//               style: TextStyle(color: Color(0xffe3023c), fontSize: 30),
//             ),
//           ]),
//     );
//   }
//
//   Widget _emailPasswordWidget() {
//     return Column(
//       children: <Widget>[
//         _entryField("Username", "Username", TxtUsername),
//         _entryField("Password", "Password", TxtPassword, isPassword: true),
//         //serverDefault(),
//       ],
//     );
//   }
//
//   var currentFocus;
//
//   unfocus() {
//     currentFocus = FocusScope.of(context);
//
//     if (!currentFocus.hasPrimaryFocus) {
//       currentFocus.unfocus();
//     }
//   }
//
//   ProgressDialog pr;
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
//       maxProgress: 50.0,
//       progressTextStyle: TextStyle(
//           color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
//       messageTextStyle: TextStyle(
//           color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
//     );
//     final height = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//         //backgroundColor: Colors.white,
//         key: globalScaffoldKey,
//         body: InkWell(
//             onTap: () {
//               onWillPop();
//             },
//             child: Container(
//               //key: _loginKey,
//               height: height,
//               // decoration: BoxDecoration(
//               //   image: DecorationImage(
//               //     image: AssetImage("assets/img/bg_anp.jpeg"),
//               //     fit: BoxFit.cover,
//               //   ),
//               // ),
//               child: Stack(
//                 children: <Widget>[
//                   Container(
//                     child: new Image.asset(
//                       "assets/img/front-login.png",
//                       //fit: BoxFit.cover,
//                       height: 50.0,
//                     ),
//                     constraints: new BoxConstraints.expand(height: 350.0),
//                   ),
//                   const SizedBox(height: 7),
//                   Container(
//                     margin: EdgeInsets.only(top: 140),
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           SizedBox(height: height * .2),
//                           //_title(),
//                           SizedBox(height: 50),
//                           _emailPasswordWidget(),
//                           SizedBox(height: 20),
//                           _submitButton(),
//                           Container(
//                             padding: EdgeInsets.symmetric(vertical: 10),
//                             alignment: Alignment.centerRight,
//                             child: Text('Version 1.2 beta',
//                                 style: TextStyle(
//                                     fontSize: 14, fontWeight: FontWeight.w500)),
//                           ),
//                           _divider(),
//                           //_facebookButton(),
//                           SizedBox(height: height * .055),
//                           //_createAccountLabel(),
//                         ],
//                       ),
//                     ),
//                   ),
//                   //Positioned(top: 40, left: 0, child: _backButton()),
//                 ],
//               ),
//             )));
//   }
// }
