import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/pages/driver/FrmApprovalReqDriver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ViewDashboard.dart';

class ApprovedDriverRequest extends StatefulWidget {
  @override
  _ApprovedDriverRequestState createState() => _ApprovedDriverRequestState();
}

class _ApprovedDriverRequestState extends State<ApprovedDriverRequest> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> _future;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  Icon _searchIcon = Icon(Icons.search);
  Widget _searchBar = Text('List Driver Request');

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _future = _fetchApprovedRequests();
  }

  Future<List<Map<String, dynamic>>> _fetchApprovedRequests() async {
    try {
      // Mengikuti pola existing: gunakan http dan try/catch sederhana
      final String url = GlobalData.baseUrl +
          'api/driver/list_driver_oprs_approve.jsp?method=list-driver-oprs';
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Map<String, dynamic>> items = [];
        jsonList.forEach((raw) {
          final Map<String, dynamic> row = {
            "RDNBR": _safeString(raw, 'rdnbr'),
            "RDDATETIME": _safeString(raw, 'rddatetime'),
            "VHCID": _safeString(raw, 'vhcid'),
            "RDAPVBY": _safeString(raw, 'rdapvby'),
            "RDAPVDATETIME": _safeString(raw, 'rdapvdatetime'),
            "RDSTATUS": _safeString(raw, 'rdstatus'),
            "RDNOTES": _safeString(raw, 'rdnotes'),
            "LOCID": _safeString(raw, 'locid'),
            "RDTYPE": _safeString(raw, 'rdtype'),
          };
          items.add(row);
        });
        return items;
      } else {
        return <Map<String, dynamic>>[];
      }
    } catch (e) {
      if (e is IOException) {
        alert(context, 2, "Please check your internet connection.", "warning");
      } else {
        alert(context, 2, "Something went wrong.", "warning");
      }
      return <Map<String, dynamic>>[];
    }
  }

  String _safeString(Map<String, dynamic> map, String key) {
    final dynamic value = map[key];
    if (value == null) return "";
    final String text = value.toString();
    if (text.toLowerCase() == 'null') return "";
    return text;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchApprovedRequests();
    });
  }

  goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => FrmApprovalReqDriver()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        goBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF8C69),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              goBack(context);
            },
          ),
          title: _searchBar,
          actions: <Widget>[
            IconButton(
              icon: _searchIcon,
              onPressed: () {
                setState(() {
                  if (_searchIcon.icon == Icons.search) {
                    _searchIcon = Icon(Icons.cancel);
                    _searchBar = ListTile(
                      onTap: () async {
                        if (_searchController.text.isEmpty) {
                          return;
                        } else {
                          _searchText = _searchController.text;
                          setState(() {
                            _future = _fetchApprovedRequests();
                          });
                        }
                      },
                      leading: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nopol...',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    setState(() {
                      _searchText = '';
                      _searchController.text = '';
                    });
                    _searchIcon = Icon(Icons.search);
                    _searchBar = Text('List Driver Request');
                    setState(() {
                      _future = _fetchApprovedRequests();
                    });
                  }
                });
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          key: globalScaffoldKey,
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Terjadi kesalahan'));
              }
              final List<Map<String, dynamic>> data =
                  snapshot.data ?? <Map<String, dynamic>>[];
              if (data.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 120),
                    Center(child: Text('Tidak ada data')),
                  ],
                );
              }

              // Filter data based on search text
              List<Map<String, dynamic>> filteredData = data;
              if (_searchText.isNotEmpty) {
                filteredData = data.where((item) {
                  final vhcid = item['VHCID']?.toString().toLowerCase() ?? '';
                  return vhcid.contains(_searchText.toLowerCase());
                }).toList();
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  return _buildCard(item);
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refresh,
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }

  Future<void> Approved(
      String vhcid, String rdnbr, String rdtype, String userid,String locid) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/driver/approved_req_driver.jsp'
      '?method=approve_req_driver'
      '&vhcid=${vhcid}'
      '&rdnbr=${rdnbr}'
      '&userid=${userid}'
      '&locid=${locid}'
      '&rdtype=${rdtype}',
    );

    try {
      EasyLoading.show(status: 'Loading...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          print('✅ Approved berhasil: ${data['message']}');
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) alert(ctx, 1, '✅ Approved berhasil: ${data['message']}', 'success');
          //Navigator.pop(context, data);
          await _refresh();
        } else {
          print('⚠️ Approved gagal: ${data['message']}');
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) alert(ctx, 0, 'Approved gagal: ${data['message']}', 'error');
          //Navigator.pop(context, data);
        }
      } else {
        print('❌ Error server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> Cancel(
      String vhcid, String rdnbr, String rdtype, String userid) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/driver/cancel_req_driver.jsp'
      '?method=cancel_req_driver'
      '&vhcid=${vhcid}'
      '&rdnbr=${rdnbr}'
      '&userid=${userid}'
      '&rdtype=${rdtype}',
    );

    try {
      EasyLoading.show(status: 'Loading...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          print("✅ Cancel sukses: ${data['message']}");
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) alert(ctx, 1, "✅ Cancel sukses: ${data['message']}", 'success');
          //Navigator.pop(context, data);
          await _refresh();
        } else {
          print("⚠️ Cancel gagal: ${data['message']}");
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) alert(ctx, 1, "⚠️ Cancel gagal: ${data['message']}", 'success');
          //Navigator.pop(context, data);
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 1.0, color: Colors.black45),
                  ),
                ),
                child: Icon(Icons.receipt_long, color: Colors.black),
              ),
              title: Text(
                item['RDNBR'],
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6),
                  _kv('RDDATETIME', item['RDDATETIME']),
                  _divider(),
                  _kv('VHCID', item['VHCID']),
                  _divider(),
                  _kv('RDAPVBY', item['RDAPVBY']),
                  _divider(),
                  _kv('RDAPVDATETIME', item['RDAPVDATETIME']),
                  _divider(),
                  _kv('RDSTATUS', item['RDSTATUS']),
                  _divider(),
                  _kv('RDNOTES', item['RDNOTES']),
                  _divider(),
                  _kv('LOCID', item['LOCID']),
                  _divider(),
                  _kv('RDTYPE', item['RDTYPE']),
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right,
                  color: Colors.black, size: 28.0),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check, color: Colors.white, size: 16.0),
                    label: Text('Cancel'),
                    onPressed: () async {
                      var vhcid = item['VHCID'];
                      var rdtype = item['RDTYPE'];
                      var rdnbr = item['RDNBR'];

                      showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text('Konfirmasi'),
                            content: Text('Cancel data ini?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                                child: Text('Tidak'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop(false);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  var username = prefs.getString("name");
                                  await Cancel(vhcid, rdnbr, rdtype, username!);

                                },
                                child: Text('Ya'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check, color: Colors.white, size: 16.0),
                    label: Text('Approve'),
                    onPressed: () async {
                      var vhcid = item['VHCID'];
                      var rdtype = item['RDTYPE'];
                      var rdnbr = item['RDNBR'];
                      var locid = item['LOCID'];

                      showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text('Konfirmasi'),
                            content: Text('Approv data ini?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                                child: Text('Tidak'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop(false);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  var username = prefs.getString("name");
                                  await Approved(
                                      vhcid, rdnbr, rdtype, username!,locid);

                                },
                                child: Text('Ya'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String keyLabel, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: keyLabel + ': ',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
          TextSpan(
            text: value ?? '',
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.black12, height: 12);
  }
}
