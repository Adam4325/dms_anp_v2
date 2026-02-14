

import 'dart:async';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/pages/FrmObp.dart';
import 'package:dms_anp/src/pages/FrmObpDouble.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewListObp.dart';
import 'package:dms_anp/src/pages/sub_menu_inventory.dart';
import 'package:dms_anp/src/pages/sub_menu_maintenance.dart';
import 'package:dms_anp/src/pages/sub_menuhrd.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import '../flusbar.dart';

class DetailMenu extends StatefulWidget {
  @override
  _DetailMenuState createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();

  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
  final Color accentOrange = Color(0xFFFFB347);       // Peach orange
  final Color darkOrange = Color(0xFFE07B39);         // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
  final Color cardColor = Color(0xFFFFF8F0);          // Light cream
  final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  void initState() {
    getSession();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(child: Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              _goBack(context);
            },
          ),
          centerTitle: true,
          title: Text(
            'Detail Menu',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          )),
      body: Container(
        key: globalScaffoldKey,
        constraints: BoxConstraints.expand(),
        color: backgroundColor,
        child: Stack(
          children: <Widget>[buildMenu(context)],
          //children: <Widget>[ImgHeader1(context), buildMenu(context)],
        ),
      ),
    ), onWillPop: () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ViewDashboard()));
      return Future.value(false);
    }) ;
  }

  Widget ImgHeader1(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryOrange,
            accentOrange,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: Image.asset(
            "assets/img/truck_header.jpg",
            fit: BoxFit.cover,
            height: 100.0,
            color: primaryOrange.withOpacity(0.3),
            colorBlendMode: BlendMode.overlay,
          ),
        ),
        constraints: new BoxConstraints.expand(height: 280.0),
      ),
    );
  }

  var username = "";
  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4.0,
        shadowColor: shadowColor,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (iconColor ?? primaryOrange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? primaryOrange,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: primaryOrange,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget menuFormObp(BuildContext context) {
    print('username ${username}');
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "OT");
    print((isOK != null && isOK.length > 0));
    if ((isOK != null && isOK.length > 0)|| username == 'ADMIN') {
      print('dapat akses');
      return _buildMenuCard(
        title: "BP Laka Tunggal",
        icon: Icons.directions_car,
        iconColor: Colors.blue.shade600,
        onTap: () {
          EasyLoading.show();
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FrmObp()));
          });
        },
      );
    } else {
      return Container();
    }
  }

  Widget menuFormObpDouble(BuildContext context) {
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "OT");
    if ((isOK != null && isOK.length > 0) || username == 'ADMIN') {
      return _buildMenuCard(
        title: "BP Laka Double",
        icon: Icons.group,
        iconColor: Colors.purple[600]!,
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => FrmObpDouble()));
        },
      );
    } else {
      return Container();
    }
  }

  Widget menuFormObpDetail(BuildContext context) {
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "OT");
    if ((isOK != null && isOK.length > 0) || username == 'ADMIN') {
      return _buildMenuCard(
        title: "Close OBP",
        icon: Icons.assignment_turned_in,
        iconColor: Colors.green.shade600,
        onTap: () {
          EasyLoading.show();
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewListObp()));
          });
        },
      );
    } else {
      return Container();
    }
  }

  Widget buildMenu(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
      child: ListView(
        children: <Widget>[
          // Header Section
          // Container(
          //   margin: EdgeInsets.only(bottom: 20),
          //   child: Text(
          //     'Pilih Menu',
          //     style: TextStyle(
          //       fontSize: 24,
          //       fontWeight: FontWeight.w700,
          //       color: darkOrange,
          //     ),
          //   ),
          // ),

          // Main Menu Items
          _buildMenuCard(
            title: "Maintenance",
            icon: Icons.build_circle,
            iconColor: Colors.orange.shade600,
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SubMenuMaintenance()));
            },
          ),

          _buildMenuCard(
            title: "HRD",
            icon: Icons.people_alt,
            iconColor: Colors.teal[600]!,
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubMenuHrd()));
            },
          ),

          _buildMenuCard(
            title: "Inventory",
            icon: Icons.inventory_2,
            iconColor: Colors.indigo[600]!,
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubMenuInventory()));
            },
          ),

          // Conditional Menu Items
          menuFormObp(context),
          menuFormObpDouble(context),
          menuFormObpDetail(context),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Card listSectionMethod(String title, String subtitle, IconData icon) {
    return new Card(
      elevation: 4.0,
      shadowColor: shadowColor,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryOrange,
            size: 24,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: primaryOrange,
            size: 16,
          ),
        ),
      ),
    );
  }
}