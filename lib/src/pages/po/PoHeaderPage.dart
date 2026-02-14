import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/po/PoDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Warna tema soft orange pastel
final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
final Color accentOrange = Color(0xFFFFB347);       // Peach orange
final Color darkOrange = Color(0xFFE07B39);         // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5);    // Cream white
final Color cardColor = Color(0xFFFFF8F0);          // Light cream
final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow

class PoHeaderPage extends StatefulWidget {
  PoHeaderPage({Key? key}) : super(key: key);

  @override
  _PoHeaderPageState createState() => _PoHeaderPageState();
}

class _PoHeaderPageState extends State<PoHeaderPage> {
  List poList = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPoData('');
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<void> fetchPoData(String search) async {
    setState(() {
      isLoading = true;
    });

    try {
      var baseUrl = GlobalData.baseUrl + 'api/po/po_header.jsp?method=list-po-header&search=$search';
      print(baseUrl);
      var url = Uri.parse(baseUrl);
      var res = await http.get(url);

      if (res.statusCode == 200) {
        setState(() {
          poList = json.decode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PO Number",
          filled: true,
          fillColor: lightOrange,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: primaryOrange),
        ),
        onChanged: (val) {
          searchQuery = val;
          fetchPoData(searchQuery);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text("Outstanding PO",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: <Widget>[
          buildSearchField(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryOrange))
                : poList.isEmpty
                ? Center(
                child: Text("Tidak ada data",
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: poList.length,
              itemBuilder: (context, index) {
                var po = poList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    title: Text(
                      po['ponbr'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkOrange,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(po['cpyname'] ?? '',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87)),
                          SizedBox(height: 2),
                          Text(
                            "Warehouse: ${po['towarehouse'] ?? ''}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                          ),
                          Text(po['podate'] ?? '',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87)),
                          SizedBox(height: 2),
                          Text(po['notes'] ?? '',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87)),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if(!EasyLoading.isShow){
                          EasyLoading.show();
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoDetail(ponbr: po['ponbr']),
                          ),
                        );
                      },
                      child: Text(
                        "Detail",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
