import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/po/PoDetail.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/pages/po/ViewDetailApproved.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

import '../../flusbar.dart';

// Warna tema soft orange pastel
final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
final Color accentOrange = Color(0xFFFFB347); // Peach orange
final Color darkOrange = Color(0xFFE07B39); // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
final Color cardColor = Color(0xFFFFF8F0); // Light cream
final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow

class PoHeaderPage extends StatefulWidget {
  PoHeaderPage({Key? key}) : super(key: key);

  @override
  _PoHeaderPageState createState() => _PoHeaderPageState();
}

class _PoHeaderPageState extends State<PoHeaderPage> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List poList = []; //
  bool isLoading = true;
  String searchQuery = '';
  List poApprovedListGte5jt = [];
  List poApprovedListLt5jt = [];
  bool isLoadingApprovedGte5jt = true;
  bool isLoadingApprovedLt5jt = true;
  String searchApprovedQueryGte5jt = '';
  String searchApprovedQueryLt5jt = '';
  List poPrintList = [];
  bool isLoadingPoPrint = true;
  String searchPoPrintQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPoData('');
    fetchPoApprovedDataGte5jt('');
    fetchPoPrintData('');
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<void> fetchPoData(String search) async {
    //OUTSTANDING
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    setState(() {
      isLoading = true;
    });
    // final hasAksesPO = globals.akses_pages != null &&
    //     globals.akses_pages.where((x) => (x == "PO" && username=="ADMIN") || (x == "PO" && username=="ETIENNE") || (x == "PO" && username=="BUDI")).isNotEmpty;
    final hasAksesPO = globals.akses_pages != null &&
        globals.akses_pages
            .where((x) => x == "PO" || username == "ADMIN")
            .isNotEmpty;
    print('hakases ${username}');
    if (hasAksesPO) {
      try {
        var baseUrl = GlobalData.baseUrl +
            'api/po/po_header.jsp?method=list-po-header&search=$search';
        print("po_header");
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
  }

  Widget buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PO Number",
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
          fetchPoData(searchQuery);
        },
      ),
    );
  }

  Future<void> fetchPoApprovedDataGte5jt(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    final hasAksesPO = globals.akses_pages != null &&
        globals.akses_pages
            .where((x) =>
                (x == "PO" || username == "ADMIN" || username == "ETIENNE" || username == "BUDI"))
            .isNotEmpty;
    print('hasAksesPO Approved');
    print('username ${username}');
    if (hasAksesPO) {
      setState(() {
        isLoadingApprovedGte5jt = true;
      });
      try {
        var baseUrl = GlobalData.baseUrl +
            'api/po/list_approved_po.jsp?method=list-po' +
            (search.isNotEmpty ? '&search=$search' : '');
        print(baseUrl);
        var url = Uri.parse(baseUrl);
        var res = await http.get(url);
        if (res.statusCode == 200) {
          var body = json.decode(res.body);
          if (body is Map &&
              (body['status_code'] == '200' || body['status_code'] == 200)) {
            setState(() {
              poApprovedListGte5jt = body['data'] ?? [];
              isLoadingApprovedGte5jt = false;
            });
          } else {
            setState(() {
              poApprovedListGte5jt = [];
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
        poApprovedListGte5jt = [];
        isLoadingApprovedGte5jt = false;
      });
    }
  }

  Future<void> fetchPoApprovedDataLt5jt(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    final hasAksesPO = globals.akses_pages != null &&
        globals.akses_pages
            .where((x) =>
        (x == "PO" || username == "ADMIN"))
            .isNotEmpty;
    print('hasAksesPO Approved');
    print('username ${username}');
    if (hasAksesPO) {
      setState(() {
        isLoadingApprovedLt5jt = true;
      });
      try {
        var baseUrl = GlobalData.baseUrl +
            'api/po/list_approved_po2.jsp?method=list-po' +
            (search.isNotEmpty ? '&search=$search' : '');
        print(baseUrl);
        var url = Uri.parse(baseUrl);
        var res = await http.get(url);
        if (res.statusCode == 200) {
          var body = json.decode(res.body);
          if (body is Map &&
              (body['status_code'] == '200' || body['status_code'] == 200)) {
            setState(() {
              poApprovedListLt5jt = body['data'] ?? [];
              print("poApprovedListLt5jt");
              print(poApprovedListLt5jt);
              isLoadingApprovedLt5jt = false;
            });
          } else {
            setState(() {
              poApprovedListLt5jt = [];
              isLoadingApprovedLt5jt = false;
            });
          }
        } else {
          throw Exception("Failed to load approved data");
        }
      } catch (e) {
        setState(() {
          isLoadingApprovedLt5jt = false;
        });
      }
    } else {
      setState(() {
        poApprovedListLt5jt = [];
        isLoadingApprovedLt5jt = false;
      });
    }
  }

  Future<void> fetchPoPrintData(String search, {String? ponbr}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('name');
    final hasAksesPO = globals.akses_pages != null &&
        globals.akses_pages
            .where((x) => x == "PO" || username == "ADMIN")
            .isNotEmpty;
    if (hasAksesPO) {
      setState(() {
        isLoadingPoPrint = true;
      });
      try {
        final queryParams = <String, String>{
          'method': 'list-print-po',
        };
        if (search.trim().isNotEmpty) {
          queryParams['search'] = search.trim();
        }
        //ponbr = "ANPO26001086";//
        if (ponbr != null && ponbr.trim().isNotEmpty) {
          queryParams['ponbr'] = ponbr.trim();
        }

        final url = Uri.parse('${GlobalData.baseUrl}api/po/list_print_po.jsp')
            .replace(queryParameters: queryParams);
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final body = json.decode(res.body);
          if (body is Map && body['status'] == 'success') {
            final fetchedList = body['data'] is List ? body['data'] : [];
            setState(() {
              poPrintList = fetchedList;
              isLoadingPoPrint = false;
            });
          } else {
            setState(() {
              poPrintList = [];
              isLoadingPoPrint = false;
            });
          }
        } else {
          throw Exception("Failed to load print data");
        }
      } catch (e) {
        setState(() {
          isLoadingPoPrint = false;
        });
      }
    } else {
      setState(() {
        poPrintList = [];
        isLoadingPoPrint = false;
      });
    }
  }

  String _buildPoPrintReportUrl(String ponbr,String cpyname) {
    //final uri = Uri.parse('${GlobalData.baseUrlOri}reporting/report_it_po_mobile.jsp')//
    final uri = Uri.parse('${GlobalData.baseUrl}api/po/report_it_po_mobile.jsp')//
        .replace(queryParameters: {
      'method': 'print-po-view-pdf',
      //'jasperFile': 'rpt_order_barang',
      'jasperFile': 'rpt_order_barangap_DMS',
      'viewer': 'pdf',
      'fieldName': 'PONBR',
      'fieldValue':  ponbr,//ANPO26001086
      'viewName': 'vpoprintnew',
      'cpyname': cpyname,
    });//
    return uri.toString();
  }

  Future<String> _downloadPoPrintPdfToTempFile(String ponbr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cpyname = prefs.getString('cpyname').toString()??"";
    final reportUrl = _buildPoPrintReportUrl(ponbr,cpyname);
    print("PO Print PDF URL: $reportUrl");
    final uri = Uri.parse(reportUrl);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }
    final tempDir = await getTemporaryDirectory();
    final safeName =
        'po_print_${ponbr.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';
    final file = File('${tempDir.path}/$safeName');
    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file.path;
  }

  Future<void> _sendPoPrintToEmail({
    required String ponbr,
    required String email,
  }) async {
    final safePonbr = ponbr.trim();
    final safeEmail = email.trim();
    if (safePonbr.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 2, "PONBR tidak valid", "warning");
      return;
    }
    if (safeEmail.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 2, "Email tujuan kosong", "warning");
      return;
    }
    try {
      final sendUri = Uri.parse(
              '${GlobalData.baseUrlOri}reporting/send_po_print_email.jsp')
          .replace(queryParameters: {
        'ponbr': safePonbr,
        'email': safeEmail,
      });
      print("PO Send Email URL: $sendUri");
      final res = await http.get(sendUri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final isSuccess = (body is Map &&
            ((body['status'] == 'success') ||
                (body['status_code'] == 200) ||
                (body['status_code'] == '200')));
        if (isSuccess) {
          alert(globalScaffoldKey.currentContext!, 1,
              "Email PO $safePonbr berhasil dikirim ke $safeEmail", "success");
        } else {
          final message = body is Map
              ? (body['message']?.toString() ?? 'Gagal kirim email')
              : 'Gagal kirim email';
          alert(globalScaffoldKey.currentContext!, 0, message, "error");
        }
      } else {
        String serverMessage = 'Gagal kirim email. HTTP ${res.statusCode}';
        try {
          final body = json.decode(res.body);
          if (body is Map && body['message'] != null) {
            serverMessage = body['message'].toString();
          }
        } catch (_) {}
        alert(globalScaffoldKey.currentContext!, 0, serverMessage, "error");
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal kirim email: ${e.toString()}", "error");
    }
  }

  Future<bool> _confirmSendPoPrintEmail(
      BuildContext ctx, String ponbr, String email) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Kirim email PO $ponbr ke $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showPoPrintPdfDialog({
    required String ponbr,
    required String email,
  }) async {
    final safePonbr = ponbr.trim();
    if (safePonbr.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 2, "PONBR tidak valid", "warning");//
      return;
    }

    final pdfFuture = _downloadPoPrintPdfToTempFile(safePonbr);

    bool isSending = false;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              title: Text("View PDF - $safePonbr"),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(ctx).size.height * 0.72,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: FutureBuilder<String>(
                        future: pdfFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: primaryOrange),
                                  SizedBox(height: 8),
                                  Text("Menyiapkan PDF..."),
                                ],
                              ),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.picture_as_pdf_outlined,
                                        size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      "PDF tidak dapat ditampilkan di dialog.",
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        String cpyname = prefs.getString('cpyname').toString() ??"";
                                        final uri = Uri.parse(
                                            _buildPoPrintReportUrl(
                                                safePonbr,cpyname));
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        }
                                      },
                                      child: Text("Buka di Browser"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom:25),
                            child: PDFView(
                              filePath: snapshot.data!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: false,
                              pageFling: false,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isSending
                            ? null
                            : () async {
                                final confirmed = await _confirmSendPoPrintEmail(
                                    ctx, safePonbr, email);
                                if (!confirmed) return;
                                setDialogState(() => isSending = true);
                                await _sendPoPrintToEmail(
                                    ponbr: safePonbr, email: email);
                                if (ctx.mounted) {
                                  setDialogState(() => isSending = false);
                                }
                              },
                        icon: isSending
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(Icons.email_outlined, size: 18),
                        label: Text(isSending ? "Sending..." : "Send to Email"),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSearchFieldApprovedLesThan5jt() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PO Approved < 5jt",
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
          searchApprovedQueryLt5jt = val;
          () async {
            if (!EasyLoading.isShow) {
              EasyLoading.show();
            }
            await fetchPoApprovedDataLt5jt(searchApprovedQueryLt5jt);
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
          }();
        },
      ),
    );
  }

  Widget buildSearchFieldApproved() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Vendor / PO Approved >= 5jt",
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
            await fetchPoApprovedDataGte5jt(searchApprovedQueryGte5jt);
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
          }();
        },
      ),
    );
  }

  Widget buildSearchFieldPoPrint() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari PO Number / Email",
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
          searchPoPrintQuery = val;
          fetchPoPrintData(searchPoPrintQuery);
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
        length: 4,
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
            title: Text("Outstanding PO",
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
                  await fetchPoApprovedDataLt5jt(searchApprovedQueryLt5jt);
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                } else if (index == 2) {
                  if (!EasyLoading.isShow) {
                    EasyLoading.show();
                  }
                  await fetchPoApprovedDataGte5jt(searchApprovedQueryGte5jt);
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                } else if (index == 3) {
                  if (!EasyLoading.isShow) {
                    EasyLoading.show();
                  }
                  await fetchPoPrintData(searchPoPrintQuery);
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                }
              },
              tabs: [
                Tab(
                  child: Text(
                    'Outstanding',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                Tab(
                  child: Text(
                    'PO Approved\n< 5jt',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                Tab(
                  child: Text(
                    'PO Approved\n>= 5jt',
                    textAlign: TextAlign.center,//
                    maxLines: 2,
                  ),
                ),
                Tab(
                  child: Text(
                    'PO Print',
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
                  buildSearchField(),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child:
                                CircularProgressIndicator(color: primaryOrange))
                        : poList.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _kv(
                                                "CpyName",
                                                (po['cpyname'] ?? '')
                                                    .toString()),
                                            _kv("PoNBR",
                                                (po['ponbr'] ?? '').toString()),
                                            _kv(
                                                "Warehouse",
                                                (po['towarehouse'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Po Date",
                                                (po['podate'] ?? '')
                                                    .toString()),
                                            // _kv("Status", (po['postatus'] ?? '').toString()),
                                            // _kv("Type", (po['typepo'] ?? '').toString()),
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
                                                            PoDetail(
                                                                ponbr: po[
                                                                    'ponbr']),
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
                  buildSearchFieldApprovedLesThan5jt(),
                  Expanded(
                    child: isLoadingApprovedLt5jt
                        ? Center(
                            child:
                                CircularProgressIndicator(color: primaryOrange))
                        : poApprovedListLt5jt.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                itemCount: poApprovedListLt5jt.length,
                                itemBuilder: (context, index) {
                                  var po = poApprovedListLt5jt[index];
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _kv(
                                                "Warehouse",
                                                (po['towarehouse'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Po Date",
                                                (po['podate'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Vendor ID",
                                                (po['vendorid'] ?? '')
                                                    .toString()),
                                            _kv(
                                                "Po Notes",
                                                (po['ponotes'] ?? '')
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
                                                            ViewDetailApproved(
                                                                ponbr: po[
                                                                        'ponbr']
                                                                    .toString()),
                                                      ),
                                                    );
                                                  },
                                                  child: Text("Detail", //PO APPORVED
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
                                                            'Approve PO ${po['ponbr']}?'),
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
                                                                        'api/po/approved_po.jsp?method=approve-po&ponbr=${po['ponbr']}&userid=${username}');
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
                                                                            : 'PO berhasil di-approve',
                                                                        'success');
                                                                    await fetchPoApprovedDataLt5jt(
                                                                        searchApprovedQueryLt5jt);
                                                                    await fetchPoData(
                                                                        searchQuery);
                                                                  } else {
                                                                    alert(
                                                                        globalScaffoldKey
                                                                            .currentContext!,
                                                                        0,
                                                                        msg.isNotEmpty
                                                                            ? msg
                                                                            : 'Gagal approve PO',
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
              Column(
                children: <Widget>[
                  buildSearchFieldApproved(),
                  Expanded(
                    child: isLoadingApprovedGte5jt
                        ? Center(
                        child:
                        CircularProgressIndicator(color: primaryOrange))//
                        : poApprovedListGte5jt.isEmpty
                        ? Center(
                        child: Text("Tidak ada data",
                            style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      itemCount: poApprovedListGte5jt.length,
                      itemBuilder: (context, index) {
                        var po = poApprovedListGte5jt[index];
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
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: <Widget>[
                                  _kv(
                                      "Warehouse",
                                      (po['towarehouse'] ?? '')
                                          .toString()),
                                  _kv(
                                      "Po Date",
                                      (po['podate'] ?? '')
                                          .toString()),
                                  _kv(
                                      "Vendor ID",
                                      (po['vendorid'] ?? '')
                                          .toString()),
                                  _kv(
                                      "Po Notes",
                                      (po['ponotes'] ?? '')
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
                                                  ViewDetailApproved(
                                                      ponbr: po[
                                                      'ponbr']
                                                          .toString()),
                                            ),
                                          );
                                        },
                                        child: Text("Detail", //PO APPORVED
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
                                                      'Approve PO ${po['ponbr']}?'),
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
                                                              'api/po/approved_po.jsp?method=approve-po&ponbr=${po['ponbr']}&userid=${username}');
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
                                                                      : 'PO berhasil di-approve',
                                                                  'success');
                                                              await fetchPoApprovedDataGte5jt(
                                                                  searchApprovedQueryGte5jt);
                                                              await fetchPoData(
                                                                  searchQuery);
                                                            } else {
                                                              alert(
                                                                  globalScaffoldKey
                                                                      .currentContext!,
                                                                  0,
                                                                  msg.isNotEmpty
                                                                      ? msg
                                                                      : 'Gagal approve PO',
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
              Column(
                children: <Widget>[
                  buildSearchFieldPoPrint(),
                  Expanded(
                    child: isLoadingPoPrint
                        ? Center(
                            child:
                                CircularProgressIndicator(color: primaryOrange))
                        : poPrintList.isEmpty
                            ? Center(
                                child: Text("Tidak ada data",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  10,
                                  4,
                                  10,
                                  28 + MediaQuery.of(context).padding.bottom,
                                ),
                                itemCount: poPrintList.length,
                                itemBuilder: (context, index) {
                                  var po = poPrintList[index];
                                  final ponbr =
                                      (po['ponbr'] ?? '').toString().trim();
                                  final cpyemail =(po['cpyemail'] ?? '').toString().trim();
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
                                        ponbr,
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
                                            _kv("Po Date",
                                                (po['podate'] ?? '').toString()),
                                            _kv(
                                                "Warehouse",
                                                (po['towarehouse'] ?? '')
                                                    .toString()),
                                            _kv("Vendor ID",
                                                (po['vendorid'] ?? '').toString()),
                                            _kv("Po Notes",
                                                (po['ponotes'] ?? '').toString()),
                                            _kv("Email",
                                                (po['cpyemail'] ?? '').toString()),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: accentOrange,
                                                    foregroundColor: Colors.white,
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
                                                  onPressed: () =>
                                                      _showPoPrintPdfDialog(
                                                          ponbr: ponbr,
                                                          email: cpyemail),
                                                  child: Text("View PDF",
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

class FrmPoHeader extends StatefulWidget {
  final Map<String, dynamic> po;
  const FrmPoHeader({Key? key, required this.po}) : super(key: key);
  @override
  State<FrmPoHeader> createState() => _FrmPoHeaderState();
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

class _FrmPoHeaderState extends State<FrmPoHeader> {
  final TextEditingController txtPonbr = TextEditingController();
  final TextEditingController txtPodate = TextEditingController();
  final TextEditingController txtPembayaran = TextEditingController();
  final TextEditingController txtNotes = TextEditingController();
  String selVendor = "[select]";
  List<String> vendorItems = ["[select]"];
  String selWarehouse = "";
  String selTypePo = "INVENTORY";

  @override
  void initState() {
    super.initState();
    txtPonbr.text = widget.po['ponbr']?.toString() ?? '';
    final podate =
        widget.po['podate']?.toString() ?? _formatDate(DateTime.now());
    txtPodate.text = podate;
    txtPembayaran.text = widget.po['pembayaran']?.toString() ?? '';
    txtNotes.text = widget.po['notes']?.toString() ?? '';
    selVendor = widget.po['vendorid']?.toString() ?? "[select]";
    if (selVendor != "[select]" && !vendorItems.contains(selVendor)) {
      vendorItems = ["[select]", selVendor];
    }
    selWarehouse = widget.po['towarehouse']?.toString() ?? "";
    selTypePo = widget.po['typepo']?.toString().isNotEmpty == true
        ? widget.po['typepo'].toString()
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
        txtPodate.text = _formatDate(selected);
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
        title: Text("FrmPoHeader"),
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
                  _buildReadonly(txtPonbr, "* Auto Generate")),
              SizedBox(height: 10),
              _buildRowField("Purchase Order Date", _buildDate(txtPodate)),
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
                  "Type Po",
                  _buildDropdown(
                    value: selTypePo,
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
                        setState(() => selTypePo = v ?? selTypePo),
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
                                PoDetail(ponbr: txtPonbr.text)),
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
                    child: Text("PO Approve"),
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
