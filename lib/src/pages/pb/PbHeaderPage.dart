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

  Widget _buildSearchFieldBox({
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        cursorColor: primaryOrange,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          filled: true,
          fillColor: lightOrange,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x59FFB347), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x59FFB347), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryOrange, width: 1.5),
          ),
          prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildSearchField() {
    return _buildSearchFieldBox(
      hintText: "Cari Vendor / PO Number",
      onChanged: (val) {
        searchQuery = val;
        fetchPbData(searchQuery);
      },
    );
  }

  Widget buildSearchFieldOutstandingPr() {
    return _buildSearchFieldBox(
      hintText: "Cari PR Number / Warehouse / User",
      onChanged: (val) {
        searchOutstandingPrQuery = val;
        fetchOutstandingPrData(searchOutstandingPrQuery);
      },
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        title: Text(
          'Detail Outstanding PR ($pbnbr)',
          style: TextStyle(
            color: darkOrange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: outstandingPrDetailList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Tidak ada detail untuk $pbnbr',
                      style: const TextStyle(color: Colors.grey)),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: outstandingPrDetailList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 14, color: Color(0x25FFB347)),
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
                        _kv('TOWAREHOUSE',
                            _j(d, ['towarehouse', 'TOWAREHOUSE'])),
                        _kv('QTY', _j(d, ['qty', 'QTY'])),
                        _kv('UOMID', _j(d, ['uomid', 'UOMID'])),
                        _kv('PBNOTES', _j(d, ['pbnotes', 'PBNOTES'])),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.close, size: 16, color: Colors.white),
            label: const Text('Tutup',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: pmBtnStyle(accentOrange),
            onPressed: () => Navigator.pop(context),
          ),
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
    return _buildSearchFieldBox(
      hintText: "Cari Vendor / PR Approved",
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
            elevation: 2,
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
              onPressed: () {
                _goBack(context);
              },
            ),
            title: const Text("PR",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
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
              tabs: const [
                Tab(
                  icon: Icon(Icons.pending_actions_outlined, size: 20, color: Colors.white),
                  text: 'Outstanding PR',
                ),
                Tab(
                  icon: Icon(Icons.assignment_outlined, size: 20, color: Colors.white),
                  text: 'Outstanding PO',
                ),
                Tab(
                  icon: Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                  text: 'PR Approved',
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                itemCount: outstandingPrList.length,
                                itemBuilder: (context, index) {
                                  final pr = outstandingPrList[index];
                                  final pbnbr = _j(pr, ['pbnbr', 'PBNBR']);
                                  return _pmListCard(
                                    title: pbnbr,
                                    trailing: _badge("PR",
                                        bg: const Color(0xFFE3F2FD),
                                        fg: const Color(0xFF1565C0)),
                                    children: [
                                      _kv("PBDATE",
                                          _j(pr, ['pbdate', 'PBDATE'])),
                                      _kv("PBNBR", pbnbr),
                                      _kv("typepb",
                                          _j(pr, ['typepb', 'typepb'])),
                                      _kv(
                                          "TOWAREHOUSE",
                                          _j(pr, [
                                            'towarehouse',
                                            'TOWAREHOUSE'
                                          ])),
                                      _kv("PBNOTES",
                                          _j(pr, ['pbnotes', 'PBNOTES'])),
                                      _kv(
                                          "CREATED_USER",
                                          _j(pr, [
                                            'created_user',
                                            'CREATED_USER'
                                          ])),
                                      _kv(
                                          "CREATED_DATETIME",
                                          _j(pr, [
                                            'created_datetime',
                                            'CREATED_DATETIME'
                                          ])),
                                    ],
                                    action: Row(
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 16,
                                              color: Colors.white),
                                          label: const Text("View Detail",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: pmBtnStyle(accentOrange),
                                          onPressed: () {
                                            _showOutstandingPrDetailDialog(
                                                pbnbr);
                                          },
                                        ),
                                      ],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                itemCount: pbList.length,
                                itemBuilder: (context, index) {
                                  var po = pbList[index];
                                  final poNbr = (po['ponbr'] ??
                                          po['pbnbr'] ??
                                          '')
                                      .toString();
                                  final poDate = (po['podate'] ??
                                          po['pbdate'] ??
                                          '')
                                      .toString();
                                  return _pmListCard(
                                    title: poNbr,
                                    trailing: _badge("OUTSTANDING",
                                        bg: const Color(0xFFFFF3E0),
                                        fg: const Color(0xFFE65100)),
                                    children: [
                                      _kv("CpyName",
                                          (po['cpyname'] ?? '').toString()),
                                      _kv("PoNBR", poNbr),
                                      _kv("Warehouse",
                                          (po['towarehouse'] ?? '').toString()),
                                      _kv("Po Date", poDate),
                                      _kv("Loc",
                                          (po['locid'] ?? '').toString()),
                                      _kv("Notes",
                                          (po['notes'] ?? '').toString()),
                                    ],
                                    action: Row(
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.info_outline,
                                              size: 16, color: Colors.white),
                                          label: const Text("Detail",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: pmBtnStyle(accentOrange),
                                          onPressed: () {
                                            if (!EasyLoading.isShow) {
                                              EasyLoading.show();
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PbDetail(pbnbr: poNbr),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
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
                                color: primaryOrange))
                        : pbApprovedListGte5jt.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                itemCount: pbApprovedListGte5jt.length,
                                itemBuilder: (context, index) {
                                  var po = pbApprovedListGte5jt[index];
                                  final pbnbr =
                                      (po['pbnbr'] ?? '').toString();
                                  return _pmListCard(
                                    title: pbnbr,
                                    trailing: _badge("APPROVED",
                                        bg: const Color(0xFFE8F5E9),
                                        fg: const Color(0xFF2E7D32)),
                                    children: [
                                      _kv("Warehouse",
                                          (po['towarehouse'] ?? '').toString()),
                                      _kv("Pb Date",
                                          (po['pbdate'] ?? '').toString()),
                                      _kv("Vendor ID",
                                          (po['vendorid'] ?? '').toString()),
                                      _kv("Pb Notes",
                                          (po['pbnotes'] ?? '').toString()),
                                      _kv("Notes",
                                          (po['notes'] ?? '').toString()),
                                    ],
                                    action: Row(
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 16,
                                              color: Colors.white),
                                          label: const Text("Detail",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: pmBtnStyle(accentOrange),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PbViewDetailApproved(
                                                        pbnbr: pbnbr),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 16,
                                              color: Colors.white),
                                          label: const Text("Approve",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: pmBtnStyle(
                                              const Color(0xFF2E7D32)),
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                backgroundColor: cardColor,
                                                titlePadding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 0),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 12, 16, 8),
                                                actionsPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 0, 16, 12),
                                                title: Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: darkOrange,
                                                        size: 22),
                                                    const SizedBox(width: 8),
                                                    Text('Konfirmasi Approve',
                                                        style: TextStyle(
                                                            color: darkOrange,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)),
                                                  ],
                                                ),
                                                content: Text(
                                                    'Approve PB $pbnbr?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(ctx),
                                                    child: Text('Batal',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade700)),
                                                  ),
                                                  ElevatedButton(
                                                    style: pmBtnStyle(
                                                        const Color(0xFF2E7D32)),
                                                    onPressed: () async {
                                                      Navigator.pop(ctx);
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      var username =
                                                          prefs.getString(
                                                              'name');
                                                      if (!EasyLoading
                                                          .isShow) {
                                                        EasyLoading.show();
                                                      }
                                                      try {
                                                        final uri = Uri.parse(
                                                            GlobalData.baseUrl +
                                                                'api/pb/approved_pb.jsp?method=approve-pb&pbnbr=$pbnbr&userid=$username');
                                                        final res = await http
                                                            .get(uri)
                                                            .timeout(const Duration(
                                                                seconds: 30));
                                                        if (res.statusCode ==
                                                            200) {
                                                          final body =
                                                              json.decode(
                                                                  res.body);
                                                          final code = body
                                                                  is Map
                                                              ? body[
                                                                  'status_code']
                                                              : null;
                                                          final msg = body is Map
                                                              ? (body['message']
                                                                      ?.toString() ??
                                                                  '')
                                                              : '';
                                                          if (code == '200' ||
                                                              code == 200) {
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
                                                          EasyLoading.dismiss();
                                                        }
                                                      }
                                                    },
                                                    child: const Text('Approve',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
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

Widget _pmListCard({
  required String title,
  Widget? trailing,
  required List<Widget> children,
  Widget? action,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x59FFB347), width: 0.8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x20FF8C69),
          spreadRadius: 1,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4E6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE07B39),
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...children,
              if (action != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0x25FF8C69)),
                const SizedBox(height: 10),
                action,
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _badge(String text,
    {Color bg = const Color(0xFFFFE8D6), Color fg = const Color(0xFFE07B39)}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}

ButtonStyle pmBtnStyle(Color bg) => ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

Widget _kv(String label, String value) {
  if (value.trim().isEmpty || value == 'null') return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
          child: Text(
            ":",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
