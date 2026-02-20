
import 'dart:io';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/DetailMenu.dart';
import 'package:dms_anp/src/pages/FormVerifikasiOBP.dart';
import 'package:dms_anp/src/pages/ViewListObp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FrmPreviewObp extends StatefulWidget {
  @override
  _FrmPreviewObpState createState() => _FrmPreviewObpState();
}

class _FrmPreviewObpState extends State<FrmPreviewObp> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  late WebViewController _controllerWeb;
  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewListObp()));
  }

  void reloadWebView() {
    _controllerWeb.reload();
  }

  @override
  Widget build(BuildContext context) {
    var bpnbr = globals.bpnbr_web_view;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewListObp()));
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
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
            title: Text('')),
        body: Container(
            child: WebView(
                onWebViewCreated: (controller) {
                  _controllerWeb = controller;
                },
                initialUrl:
                'http://apps.tuluatas.com:8080/trucking/bp.jsp?method=preview-bpnbr&bpnbr=${bpnbr}',
                gestureRecognizers: Set()
                  ..add(
                    Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer(),
                    ), // or null
                  ),
                key: Key("webview1"),
                debuggingEnabled: true,
                javascriptMode: JavascriptMode.unrestricted)
        ),
      ),
    );
  }
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.initState();
  }
}