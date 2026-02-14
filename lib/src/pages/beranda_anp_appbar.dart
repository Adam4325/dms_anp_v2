import 'dart:async';

import 'package:dms_anp/src/pages/ViewProfileUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AnpAppBar extends AppBar {
  AnpAppBar(BuildContext context)
      : super(
      elevation: 0.25,
      backgroundColor: Colors.white,
      flexibleSpace: _buildAnpAppBar(context));

  static Widget _buildAnpAppBar(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Image.asset(
            "assets/img/logo_anp.png",
            height: 50.0,
            width: 100.0,
          ),
          new Container(
            child: new Row(
              children: <Widget>[
                new Container(
                  height: 25.0,
                  width: 28.0,
                  padding: EdgeInsets.all(0.0),
                  decoration: new BoxDecoration(
                      borderRadius:
                      new BorderRadius.all(new Radius.circular(100.0)),
                      color: Colors.orangeAccent),
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: (){
                      EasyLoading.show();
                      Timer(Duration(seconds: 1), () {
                        // 5s over, navigate to a new page
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewProfileUser()));
                      });
                    },
                    icon: new Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}