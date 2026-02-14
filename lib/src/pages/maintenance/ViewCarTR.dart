import 'package:dms_anp/src/pages/FrmInspeksiVehicle.dart';
import 'package:dms_anp/src/pages/ViewService.dart';
import 'package:dms_anp/src/pages/driver/FrmInspeksiVehicleP2H.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;

class ViewCarTR extends StatefulWidget {
  @override
  _ViewCarTRState createState() => _ViewCarTRState();
}

class _ViewCarTRState extends State<ViewCarTR> {
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scafoldGlobal2 = new GlobalKey<ScaffoldState>();
  List<String> _ban = [];

  _goBack(BuildContext context) {
    if(globals.page_inspeksi=="opr"){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => FrmInspeksiVehicleP2H()));
    } else if(globals.page_inspeksi=="driver"){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => FrmInspeksiVehicle()));
    }else if(globals.page_inspeksi=='service'){
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewService()));
    }
  }

  @override
  void initState() {
    super.initState();
    //print('globals.page_inspeksi ${globals.page_inspeksi}');
  }

  Future<bool> onWillPop() {
    print(globals.page_inspeksi);
    if(globals.page_inspeksi=="opr"){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => FrmInspeksiVehicleP2H()));
    } else if(globals.page_inspeksi=="driver"){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => FrmInspeksiVehicle()));
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
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
            title: Text('Type Truck TR',style: TextStyle(color: Colors.black))),
        key: scafoldGlobal2,
        body: Container(
          key: scafoldGlobal,
          child: Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.blue, spreadRadius: 1),
                ],
              ),
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                              image: NetworkImage(
                                "${globals.image_typr_truck_url}",
                              ),
                              fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 7),
                    SmartSelect<String>.multiple(
                      title: 'Ban Type TR',
                      selectedValue: _ban,
                      onChange: (selected) {
                        setState(() => _ban = selected.value);
                        setState(() {
                          _ban.forEach((element) {
                            var posBan = int.parse(element);
                            if (posBan <= 11) {
                              if (posBan == 1) {
                                globals.vhcposisiban1 = posBan;
                              }
                              if (posBan == 2) {
                                globals.vhcposisiban2 = posBan;
                              }
                              if (posBan == 3) {
                                globals.vhcposisiban3 = posBan;
                              }
                              if (posBan == 4) {
                                globals.vhcposisiban4 = posBan;
                              }
                              if (posBan == 5) {
                                globals.vhcposisiban5 = posBan;
                              }
                              if (posBan == 6) {
                                globals.vhcposisiban6 = posBan;
                              }
                              if (posBan == 7) {
                                globals.vhcposisiban7 = posBan;
                              }
                              if (posBan == 8) {
                                globals.vhcposisiban8 = posBan;
                              }
                              if (posBan == 9) {
                                globals.vhcposisiban9 = posBan;
                              }
                              if (posBan == 10) {
                                globals.vhcposisiban10 = posBan;
                              }
                              if (posBan == 11) {
                                globals.vhcposisiban11 = posBan;
                              }
                            } else {
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
                          });
                        });
                      },
                      choiceItems: choices.collBanTR,
                      modalType: S2ModalType.fullPage,
                      //modalConfirm: true,
                      // modalValidation: (value) {
                      //   return value.length > 0 ? null : 'Select at least one';
                      // },
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
                      // modalActionsBuilder: (context, state) {
                      //   return <Widget>[
                      //     Padding(
                      //       padding: const EdgeInsets.only(right: 13),
                      //       child: state.choiceSelector,
                      //     )
                      //   ];
                      // },
                      // modalDividerBuilder: (context, state) {
                      //   return const Divider(height: 1);
                      // },
                      // modalFooterBuilder: (context, state) {
                      //   return Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 12.0,
                      //       vertical: 7.0,
                      //     ),
                      //     child: Row(
                      //       children: <Widget>[
                      //         const Spacer(),
                      //         TextButton(
                      //           child: const Text('Cancel'),
                      //           onPressed: () {
                      //             Navigator.of(context).pop(false);
                      //             setState(() {
                      //               _ban = [];
                      //             });
                      //           },
                      //           //onPressed: () => state.closeModal(confirmed: false),
                      //         ),
                      //         const SizedBox(width: 5),
                      //         TextButton(
                      //           child: Text('OK'),
                      //           color: Theme.of(context).primaryColor,
                      //           textColor: Colors.white,
                      //           onPressed: () {
                      //             Navigator.of(context).pop(false);
                      //             setState(() {
                      //               print(_ban.length);
                      //               _ban.forEach((element) {
                      //                 print("element $element");
                      //               });
                      //             });
                      //           },
                      //           // onPressed: state.mounted
                      //           //     ? () => state.closeModal(confirmed: true)
                      //           //     : null,
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      // },
                    ),
                    // Container(
                    //     width: double.infinity,
                    //     padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    //     child: ElevatedButton.icon(
                    //       icon: Icon(
                    //         Icons.reset_tv,
                    //         color: Colors.white,
                    //         size: 20.0,
                    //       ),
                    //       label: Text("Reset"),
                    //       onPressed: () async {
                    //         setState(() {
                    //           _ban = [];
                    //         });
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //           elevation: 0.0,
                    //           backgroundColor: Colors.red,
                    //           padding: EdgeInsets.symmetric(
                    //               horizontal: 5, vertical: 0),
                    //           textStyle: TextStyle(
                    //               fontSize: 14, fontWeight: FontWeight.bold)),
                    //     ))
                  ]))),
        ),
      ),
    );
  }
}
