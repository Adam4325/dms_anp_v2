import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/pb/PbDetail.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/pages/pb/PbViewDetailApproved.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../flusbar.dart';

// Warna tema soft orange pastel
final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
final Color accentOrange = Color(0xFFFFB347); // Peach orange
final Color darkOrange = Color(0xFFE07B39); // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
final Color cardColor = Color(0xFFFFF8F0); // Light cream
final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow

class PbHeaderPage extends StatefulWidget {
  PbHeaderPage({Key? key}) : super(key: key);

  @override
  _PbHeaderPageState createState() => _PbHeaderPageState();
}

class _PbHeaderPageState extends State<PbHeaderPage> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List pbList = []; //
  bool isLoading = true;
  String searchQuery = '';
  List pbApprovedListGte5jt = [];
  bool isLoadingApprovedGte5jt = true;
  String searchApprovedQueryGte5jt = '';
  List outstandingPrList = [];
  bool isLoadingOutstandingPr = true;
  String searchOutstandingPrQuery = '';
  List<Map<String, dynamic>> outstandingPrDetailList = [];

  String _j(dynamic row, List<String> keys) {
    if (row is! Map) return '';
    for (final k in keys) {
      final v = row[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    fetchOutstandingPrData('');
    fetchPbData('');
    fetchPbApprovedDataGte5jt('');
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<void> fetchPbData(String search) async {
    //OUTSTANDING
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    setState(() {
      isLoading = true;
    });
    // final hasAksesPB = globals.akses_pages != null &&
    //     globals.akses_pages.where((x) => (x == "PB" && username=="ADMIN") || (x == "PB" && username=="ETIENNE") || (x == "PB" && username=="BUDI")).isNotEmpty;
    final hasAksesPB = globals.akses_pages != null &&
        globals.akses_pages
            .where((x) => x == "IR" || username == "ADMIN")
            .isNotEmpty;
    print('hakases ${username}');
    if (hasAksesPB) {
      try {
        var baseUrl = GlobalData.baseUrl +
            'api/pb/pb_header.jsp?method=list-pb-header&search=$search';
        print("pb_header");
        print(baseUrl);
        var url = Uri.parse(baseUrl);
        var res = await http.get(url);

        if (res.statusCode == 200) {
          setState(() {
            pbList = json.decode(res.body);
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
  }

  Future<void> fetchOutstandingPrData(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    final hasAksesPB = globals.akses_pages != null &&
        globals.akses_pages.where((x) => x == "IR" || username == "ADMIN").isNotEmpty;
    if (hasAksesPB) {
      setState(() {
        isLoadingOutstandingPr = true;
      });
      try {
        print('${GlobalData.baseUrl}api/pb/list_header_oustanding_pr.jsp');
        final url =
            Uri.parse('${GlobalData.baseUrl}api/pb/list_header_oustanding_pr.jsp')
            .replace(queryParameters: {
          if (search.trim().isNotEmpty) 'search': search.trim(),
        });
        print(url);
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final body = json.decode(res.body);
          if (body is Map &&
              (body['status']?.toString().toLowerCase() == 'success' ||
                  body['status_code']?.toString() == '200')) {
            setState(() {
              outstandingPrList = body['data'] is List ? body['data'] : [];
              isLoadingOutstandingPr = false;
            });
            return;
          } else if (body is List) {
            setState(() {
              outstandingPrList = body;
              isLoadingOutstandingPr = false;
            });
            return;
          }
        }
      } catch (e) {
        // Endpoint belum ada, fallback ke list kosong.
      }
    }
    setState(() {
      outstandingPrList = [];
      isLoadingOutstandingPr = false;
    });
  }

  Future<void> fetchOutstandingPrDetail(String pbnbr) async {
    setState(() {
      outstandingPrDetailList = [];
    });
    try {
      final url = Uri.parse(
              '${GlobalData.baseUrl}api/pb/list_detail_outsanding_pr.jsp')//pbnbr=ANPR26002728&method=getDetailPR
          .replace(queryParameters: {
        'method': 'getDetailPR',
        'pbnbr': pbnbr,
      });
      print(url);
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body is Map &&
            (body['status']?.toString().toLowerCase() == 'success' ||
                body['status_code']?.toString() == '200')) {
          final data = body['data'];
          if (data is List) {
            setState(() {
              outstandingPrDetailList = data
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            });
            return;
          }
        } else if (body is List) {
          setState(() {
            outstandingPrDetailList = body
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          });
          return;
        }
      }
    } catch (_) {}
    setState(() {
      outstandingPrDetailList = [];
    });
  }

  Widget buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari PR Number",
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
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
          fetchPbData(searchQuery);
        },
      ),
    );
  }

  Widget buildSearchFieldOutstandingPr() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari PR Number / Warehouse / User",
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
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
          searchOutstandingPrQuery = val;
          fetchOutstandingPrData(searchOutstandingPrQuery);
        },
      ),
    );
  }

  Future<void> _showOutstandingPrDetailDialog(String pbnbr) async {
    if (!EasyLoading.isShow) {
      EasyLoading.show();
    }
    await fetchOutstandingPrDetail(pbnbr);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Outstanding PR'),
        content: SizedBox(
          width: double.maxFinite,
          child: outstandingPrDetailList.isEmpty
              ? Text('Tidak ada detail untuk $pbnbr')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: outstandingPrDetailList.length,
                  separatorBuilder: (_, __) => Divider(height: 14),
                  itemBuilder: (context, idx) {
                    final d = outstandingPrDetailList[idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('PBNBR', _j(d, ['pbnbr', 'PBNBR'])),
                        _kv('PBLINENBR', _j(d, ['pblinenbr', 'PBLINENBR'])),
                        _kv('ITDITEMID', _j(d, ['itditemid', 'ITDITEMID'])),
                        _kv('PARTNAME', _j(d, ['partname', 'PARTNAME'])),
                        _kv('MERK', _j(d, ['merk', 'MERK'])),
                        _kv('GENUINENO', _j(d, ['genuineno', 'GENUINENO'])),
                        _kv('IDTYPE', _j(d, ['idtype', 'IDTYPE'])),
                        _kv('IDACCESS', _j(d, ['idaccess', 'IDACCESS'])),
                        _kv('typepb', _j(d, ['typepb', 'typepb'])),
                        _kv('TOWAREHOUSE', _j(d, ['towarehouse', 'TOWAREHOUSE'])),
                        _kv('QTY', _j(d, ['qty', 'QTY'])),
                        _kv('UOMID', _j(d, ['uomid', 'UOMID'])),
                        _kv('PBNOTES', _j(d, ['pbnotes', 'PBNOTES'])),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          )
        ],
      ),
    );
  }

  Future<void> fetchPbApprovedDataGte5jt(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    // final hasAksesPB = globals.akses_pages != null &&
    //     globals.akses_pages
    //         .where((x) => (x == "PB" && (
    //             username == "ADMIN" ||
    //             username == "ETIENNE" ||
    //             username == "BUDI")))
    //         .isNotEmpty;

    final hasAksesPB = globals.akses_pages != null &&
        globals.akses_pages
            .where((x) => (x == "IR"))
            .isNotEmpty;
    print('hasAksesPB Approved');
    print('username ${username}');
    if (hasAksesPB) {
      setState(() {
        isLoadingApprovedGte5jt = true;
      });
      try {
        var baseUrl = GlobalData.baseUrl +
            'api/pb/list_approved_pb.jsp?method=list-pb&userid=$username' +
            (search.isNotEmpty ? '&search=$search' : '');
        print(baseUrl);
        var url = Uri.parse(baseUrl);
        var res = await http.get(url);
        if (res.statusCode == 200) {
          var body = json.decode(res.body);
          if (body is Map &&
              (body['status_code'] == '200' || body['status_code'] == 200)) {
            setState(() {
              pbApprovedListGte5jt = body['data'] ?? [];
              isLoadingApprovedGte5jt = false;
            });
          } else {
            setState(() {
              pbApprovedListGte5jt = [];
              isLoadingApprovedGte5jt = false;
            });
          }
        } else {
          throw Exception("Failed to load approved data");
        }
      } catch (e) {
        setState(() {
          isLoadingApprovedGte5jt = false;
        });
      }
    } else {
      setState(() {
        pbApprovedListGte5jt = [];
        isLoadingApprovedGte5jt = false;
      });
    }
  }

  Widget buildSearchFieldApproved() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PR Approved",
          hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
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
          searchApprovedQueryGte5jt = val;
          () async {
            if (!EasyLoading.isShow) {
              EasyLoading.show();
            }
            await fetchPbApprovedDataGte5jt(searchApprovedQueryGte5jt);
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
          }();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
      },
      child: DefaultTabController(
        key: globalScaffoldKey,
        length: 3,
        child: Scaffold(
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
            title: Text("PR",
                style: TextStyle(fontWeight: FontWeight.bold)),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              onTap: (index) async {
                if (index == 1) {
                  if (!EasyLoading.isShow) {
                    EasyLoading.show();
                  }
                  await fetchPbData(searchQuery);
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                } else if (index == 2) {
                  if (!EasyLoading.isShow) {
                    EasyLoading.show();
                  }
                  await fetchPbApprovedDataGte5jt(searchApprovedQueryGte5jt);
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                }
              },
              tabs: [
                Tab(
                  child: Text(
                    'Outstanding PR',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                Tab(
                  child: Text(
                    'Outstanding PO',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                Tab(
                  child: Text(
                    'PR Approved',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: <Widget>[
                  buildSearchFieldOutstandingPr(),
                  Expanded(
                    child: isLoadingOutstandingPr
                        ? Center(
                            child: CircularProgressIndicator(color: primaryOrange))
                        : outstandingPrList.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                itemCount: outstandingPrList.length,
                                itemBuilder: (context, index) {
                                  final pr = outstandingPrList[index];
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
                                        _j(pr, ['pbnbr', 'PBNBR']),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkOrange,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _kv("PBDATE",
                                                _j(pr, ['pbdate', 'PBDATE'])),
                                            _kv("PBNBR",
                                                _j(pr, ['pbnbr', 'PBNBR'])),
                                            _kv("typepb",
                                                _j(pr, ['typepb', 'typepb'])),
                                            _kv(
                                                "TOWAREHOUSE",
                                                _j(pr, ['towarehouse', 'TOWAREHOUSE'])),
                                            _kv("PBNOTES",
                                                _j(pr, ['pbnotes', 'PBNOTES'])),
                                            _kv(
                                                "CREATED_USER",
                                                _j(pr, ['created_user', 'CREATED_USER'])),
                                            _kv(
                                                "CREATED_DATETIME",
                                                _j(pr, ['created_datetime', 'CREATED_DATETIME'])),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        accentOrange,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                  ),
                                                  onPressed: () {
                                                    _showOutstandingPrDetailDialog(
                                                        _j(pr, ['pbnbr', 'PBNBR']));
                                                  },
                                                  child: Text("View Detail",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  buildSearchField(),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child:
                                CircularProgressIndicator(color: primaryOrange))
                        : pbList.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                itemCount: pbList.length,
                                itemBuilder: (context, index) {
                                  var po = pbList[index];
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
                                        po['pbnbr'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkOrange,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _kv(
                                                "CpyName",
                                                (po['cpyname'] ?? '')
                                                    .toString()),
                                            _kv("pbnbr",
                                                (po['pbnbr'] ?? '').toString()),
                                            _kv(
                                                "Warehouse",
                                                (po['towarehouse'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Pb Date",
                                                (po['pbdate'] ?? '')
                                                    .toString()),
                                            // _kv("Status", (po['pbstatus'] ?? '').toString()),
                                            // _kv("Type", (po['typepb'] ?? '').toString()),
                                            _kv("Loc",
                                                (po['locid'] ?? '').toString()),
                                            _kv("Notes",
                                                (po['notes'] ?? '').toString()),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        accentOrange,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                  ),
                                                  onPressed: () {
                                                    if (!EasyLoading.isShow) {
                                                      EasyLoading.show();
                                                    }
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PbDetail(
                                                                pbnbr: po[
                                                                    'pbnbr']),
                                                      ),
                                                    );
                                                  },
                                                  child: Text("Detail",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  buildSearchFieldApproved(),
                  Expanded(
                    child: isLoadingApprovedGte5jt
                        ? Center(
                            child: CircularProgressIndicator(
                                color: primaryOrange)) //
                        : pbApprovedListGte5jt.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                itemCount: pbApprovedListGte5jt.length,
                                itemBuilder: (context, index) {
                                  var po = pbApprovedListGte5jt[index];
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
                                        po['pbnbr'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkOrange,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _kv(
                                                "Warehouse",
                                                (po['towarehouse'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Pb Date",
                                                (po['pbdate'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Vendor ID",
                                                (po['vendorid'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Pb Notes",
                                                (po['pbnotes'] ?? '')
                                                    .toString()),
                                            _kv("Notes",
                                                (po['notes'] ?? '').toString()),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        accentOrange,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PbViewDetailApproved(
                                                                pbnbr: po[
                                                                        'pbnbr']
                                                                    .toString()),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                      "Detail", //PB APPORVED
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                                SizedBox(width: 8),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.deepOrange,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                  ),
                                                  onPressed: () async {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          AlertDialog(
                                                        title:
                                                            Text('Konfirmasi'),
                                                        content: Text(
                                                            'Approve PB ${po['pbnbr']}?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    ctx),
                                                            child:
                                                                Text('Batal'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  ctx);
                                                              SharedPreferences
                                                                  prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              var username =
                                                                  prefs.getString(
                                                                      'name');
                                                              if (!EasyLoading
                                                                  .isShow) {
                                                                EasyLoading
                                                                    .show();
                                                              }
                                                              try {
                                                                final uri = Uri
                                                                    .parse(GlobalData
                                                                            .baseUrl +
                                                                        'api/pb/approved_pb.jsp?method=approve-pb&pbnbr=${po['pbnbr']}&userid=${username}');
                                                                final res = await http
                                                                    .get(uri)
                                                                    .timeout(Duration(
                                                                        seconds:
                                                                            30));
                                                                if (res.statusCode ==
                                                                    200) {
                                                                  final body = json
                                                                      .decode(res
                                                                          .body);
                                                                  final code = body
                                                                          is Map
                                                                      ? body[
                                                                          'status_code']
                                                                      : null;
                                                                  final msg = body
                                                                          is Map
                                                                      ? (body['message']
                                                                              ?.toString() ??
                                                                          '')
                                                                      : '';
                                                                  if (code ==
                                                                          '200' ||
                                                                      code ==
                                                                          200) {
                                                                    alert(
                                                                        globalScaffoldKey
                                                                            .currentContext!,
                                                                        1,
                                                                        msg.isNotEmpty
                                                                            ? msg
                                                                            : 'PB berhasil di-approve',
                                                                        'success');
                                                                    await fetchPbApprovedDataGte5jt(
                                                                        searchApprovedQueryGte5jt);
                                                                    await fetchPbData(
                                                                        searchQuery);
                                                                  } else {
                                                                    alert(
                                                                        globalScaffoldKey
                                                                            .currentContext!,
                                                                        0,
                                                                        msg.isNotEmpty
                                                                            ? msg
                                                                            : 'Gagal Approve PB',
                                                                        'error');
                                                                  }
                                                                } else {
                                                                  alert(
                                                                      globalScaffoldKey
                                                                          .currentContext!,
                                                                      0,
                                                                      'Server error: ${res.statusCode}',
                                                                      'error');
                                                                }
                                                              } catch (e) {
                                                                alert(
                                                                    globalScaffoldKey
                                                                        .currentContext!,
                                                                    2,
                                                                    'Please check your internet connection.',
                                                                    'warning');
                                                              } finally {
                                                                if (EasyLoading
                                                                    .isShow) {
                                                                  EasyLoading
                                                                      .dismiss();
                                                                }
                                                              }
                                                            },
                                                            child:
                                                                Text('Approve'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Text("Approved",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class FrmPbHeader extends StatefulWidget {
  final Map<String, dynamic> po;
  const FrmPbHeader({Key? key, required this.po}) : super(key: key);
  @override
  State<FrmPbHeader> createState() => _FrmPbHeaderState();
}

Widget _kv(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
        const SizedBox(
          width: 10,
          child: Text(
            ":",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _FrmPbHeaderState extends State<FrmPbHeader> {
  final TextEditingController txtpbnbr = TextEditingController();
  final TextEditingController txtpbdate = TextEditingController();
  final TextEditingController txtPembayaran = TextEditingController();
  final TextEditingController txtNotes = TextEditingController();
  String selVendor = "[select]";
  List<String> vendorItems = ["[select]"];
  String selWarehouse = "";
  String seltypepb = "INVENTORY";

  @override
  void initState() {
    super.initState();
    txtpbnbr.text = widget.po['pbnbr']?.toString() ?? '';
    final pbdate =
        widget.po['pbdate']?.toString() ?? _formatDate(DateTime.now());
    txtpbdate.text = pbdate;
    txtPembayaran.text = widget.po['pembayaran']?.toString() ?? '';
    txtNotes.text = widget.po['notes']?.toString() ?? '';
    selVendor = widget.po['vendorid']?.toString() ?? "[select]";
    if (selVendor != "[select]" && !vendorItems.contains(selVendor)) {
      vendorItems = ["[select]", selVendor];
    }
    selWarehouse = widget.po['towarehouse']?.toString() ?? "";
    seltypepb = widget.po['typepb']?.toString().isNotEmpty == true
        ? widget.po['typepb'].toString()
        : "INVENTORY";
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "$y-$m-$dd";
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      setState(() {
        txtpbdate.text = _formatDate(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: Text("FrmPbHeader"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildRowField("Purchase Order Number",
                  _buildReadonly(txtpbnbr, "* Auto Generate")),
              SizedBox(height: 10),
              _buildRowField("Purchase Order Date", _buildDate(txtpbdate)),
              SizedBox(height: 10),
              _buildRowField(
                  "Vendor",
                  _buildDropdown(
                    value: selVendor,
                    items: vendorItems,
                    onChanged: (v) =>
                        setState(() => selVendor = v ?? selVendor),
                    trailing: Material(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FrmMasterVendor()),
                          );
                          if (res != null && res is String && res.isNotEmpty) {
                            setState(() {
                              selVendor = res;
                              if (!vendorItems.contains(res)) {
                                vendorItems = ["[select]", res];
                              }
                            });
                          }
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Center(
                              child: Text("Add Vendor",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12))),
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 10),
              _buildRowField(
                  "To Warehouse",
                  _buildDropdown(
                    value: selWarehouse.isEmpty ? "" : selWarehouse,
                    items: [""],
                    onChanged: (v) =>
                        setState(() => selWarehouse = v ?? selWarehouse),
                  )),
              SizedBox(height: 10),
              _buildRowField(
                  "Type Pb",
                  _buildDropdown(
                    value: seltypepb,
                    items: [
                      "INVENTORY",
                      "OPEX",
                      "CAPEX",
                      "INVESTASI",
                      "STOCK",
                      "BK",
                      "RND",
                      "MATERIAL"
                    ],
                    onChanged: (v) =>
                        setState(() => seltypepb = v ?? seltypepb),
                  )),
              SizedBox(height: 10),
              _buildRowField("Pembayaran", _buildNumber(txtPembayaran)),
              SizedBox(height: 10),
              _buildRowField("Notes", _buildSingleLine(txtNotes)),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PbDetail(pbnbr: txtpbnbr.text)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Transaction Detail"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)), //
                    ),
                    child: Text("PB Approve"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowField(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        Expanded(child: field),
      ],
    );
  }

  Widget _buildReadonly(TextEditingController c, String helper) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: c,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(helper, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDate(TextEditingController c) {
    return TextField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        suffixIcon: IconButton(
            icon: Icon(Icons.date_range, color: primaryOrange),
            onPressed: _pickDate),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            //
            initialValue: items.contains(value) ? value : null,
            items: items
                .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e.isEmpty ? "" : e),
                    ))
                .toList(),
            onChanged: onChanged,
            isDense: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 110, height: 36),
            child: trailing,
          ),
        ]
      ],
    );
  }

  Widget _buildNumber(TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  } //

  Widget _buildSingleLine(TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }
}

class FrmMasterVendor extends StatefulWidget {
  const FrmMasterVendor({Key? key}) : super(key: key);
  @override
  State<FrmMasterVendor> createState() => _FrmMasterVendorState();
}

class _FrmMasterVendorState extends State<FrmMasterVendor> {
  final TextEditingController txtVendorId = TextEditingController();
  final TextEditingController txtNamaVendor = TextEditingController();
  final TextEditingController txtAlamatVendor = TextEditingController();
  final TextEditingController txtContactPerson = TextEditingController();
  final TextEditingController txtTelp = TextEditingController();
  String selStatus = "Non Active";

  @override
  void initState() {
    super.initState();
    txtVendorId.text = "";
    txtNamaVendor.text = "";
    txtAlamatVendor.text = "";
    txtContactPerson.text = "";
    txtTelp.text = "";
    selStatus = "Non Active";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        title: Text("FrmMasterVendor"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildRowField(
                  "ID Vendor", _buildReadonly(txtVendorId, "* Auto Generate")),
              SizedBox(height: 10),
              _buildRowField("Nama Vendor", _buildSingleLine(txtNamaVendor)),
              SizedBox(height: 10),
              _buildRowField(
                  "Address Vendor", _buildSingleLine(txtAlamatVendor)),
              SizedBox(height: 10),
              _buildRowField(
                  "Contact Person", _buildSingleLine(txtContactPerson)),
              SizedBox(height: 10),
              _buildRowField("Tlp", _buildSingleLine(txtTelp)), //
              SizedBox(height: 10),
              _buildRowField(
                  "Status",
                  _buildDropdown(
                    value: selStatus,
                    items: ["Active", "Non Active"],
                    onChanged: (v) =>
                        setState(() => selStatus = v ?? selStatus),
                  )),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("View Report"),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, txtVendorId.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Select"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Add"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text("Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowField(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        Expanded(child: field),
      ],
    );
  }

  Widget _buildReadonly(TextEditingController c, String helper) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: c,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(helper, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildSingleLine(TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightOrange,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : null,
            items: items
                .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e.isEmpty ? "" : e),
                    ))
                .toList(),
            onChanged: onChanged,
            isDense: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 110, height: 36),
            child: trailing,
          ),
        ]
      ],
    );
  }
}
