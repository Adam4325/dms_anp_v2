import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String titleAlert = "";
Color colorBg = Colors.blue;
void initAlert(int alertType) {
  if(alertType == 0){
    titleAlert = "Failed !";
    colorBg = Colors.red;
  }
  else if(alertType == 1){
    titleAlert = "Success";
    colorBg = Colors.green;
  }
  else if(alertType == 2){
    titleAlert = "Warning";
    colorBg = Colors.orange;
  }
  else if(alertType == 3){
    titleAlert = "Info";
    colorBg = Colors.blueAccent;
  }
}
void alert(BuildContext context, int alertType, String message, String colorInfo) {
  initAlert(alertType);
  Flushbar(
    title: titleAlert,
    message: message,
    icon: Icon(
      Icons.info_outline,
      color: Colors.white,
    ),
    backgroundGradient:
    LinearGradient(colors: [colorBg, colorBg]),
    backgroundColor: colorInfo=="error"? Colors.red:colorInfo=="warning"?Colors.yellow:colorInfo=="success"?Colors.green:colorInfo=="info"?Colors.blueAccent:Colors.blue,
    boxShadows: [
      BoxShadow(
        color: Colors.blue.shade800,
        offset: Offset(0.0, 2.0),
        blurRadius: 3.0,
      )
    ],
    duration: Duration(seconds: 3),
  )
    ..show(context);
}