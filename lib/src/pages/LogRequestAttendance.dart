import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/pages/FrmRequestAttendance.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

// Create a Form widget.
class LogRequestAttendance extends StatefulWidget {
  @override
  LogRequestAttendanceState createState() => LogRequestAttendanceState();
}

class LogRequestAttendanceState extends State<LogRequestAttendance> {
  final globalScaffoldKey = GlobalKey<FormState>();
  ProgressDialog? pr;

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FrmAttendance(context)));
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true);

    pr?.style(
      message: 'Proses...',
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
    return new Scaffold(
      key: globalScaffoldKey,
      backgroundColor: Colors.blueAccent,
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
          title: Text('Log Request Attendance')),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[
            FrmAttendance(context),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // _getLocation().then((position) {
    //   userLocation = position;
    // });
    // getListGeofenceArea(false);
    // getSession();
    super.initState();
  }
  Widget FrmAttendance(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 0),
      child: Card(
        elevation: 0.0,
        shadowColor: Color(0x802196F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Nama Karyawan ",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 15)),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.create,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        label: Text("Create Request"),
                        onPressed: () async {
                          print('Create Request');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FrmRequestAttendance()));
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blue,
                            padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        label: Text("log Request"),
                        onPressed: () async {
                          print('Log Request');
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blueAccent,
                            padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                ])),
          ],
        ),
      ),
    );
  }
}
