import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/RegistrasiNewDriver.dart';
import 'package:dms_anp/src/pages/hrd/frmAssset.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ListAsset extends StatefulWidget {
  @override
  _ListAssetState createState() => _ListAssetState();
}

class _ListAssetState extends State<ListAsset> {
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();
  Future<AssetDataModel>? _future;
  int _currentPage = 1;

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Asset');

  void _loadData() {
    setState(() {
      _future = sendAssetDataRequest(_currentPage);
    });
  }

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: customSearchBar,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 20.0,
          onPressed: () {
            _goBack(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: customIcon,
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    onTap: () {
                      if (_txtSearch.text.isEmpty) {
                        return;
                      }
                      _searchText = _txtSearch.text;
                      _loadData();
                    },
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      controller: _txtSearch,
                      decoration: InputDecoration(
                        hintText: 'Cari name/ id asset...',
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
                  _searchText = "";
                  _txtSearch.text = "";
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('List Asset');
                  _loadData();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: FutureBuilder<AssetDataModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingWidgetMaker();
            }
            if (snapshot.hasError) {
              return errorWidgetMaker(
                  AssetDataModel.withError('${snapshot.error}'), _loadData);
            }
            final assetData = snapshot.data;
            if (assetData == null || assetData.statusCode != 200) {
              return errorWidgetMaker(
                  assetData ?? AssetDataModel.withError('Unknown error'),
                  _loadData);
            }
            final items = listItemsGetter(assetData);
            if (items.isEmpty) {
              return emptyListWidgetMaker(assetData);
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return listItemBuilder(items[index], index);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _searchText = "";
            _txtSearch.text = "";
          });
          _loadData();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Future<AssetDataModel> sendAssetDataRequest(int page) async {
    print('page ${page}');
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrlOri}api/edp/list_asset.jsp?method=list-asset-v1&page=${page}&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body}');
      return AssetDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        final ctx = context;
        if (ctx.mounted) {
          alert(ctx, 2, "Please check your internet connection.", "warning");
        }
        return AssetDataModel.withError(
            'Please check your internet connection.');
      } else {
        final ctx = context;
        if (ctx.mounted) {
          alert(ctx, 2, "Something went wrong.", "warning");
        }
        return AssetDataModel.withError('Something went wrong.');
      }
    }
  }

  List<Map<String, dynamic>> listItemsGetter(AssetDataModel assetData) {
    List<Map<String, dynamic>> list = [];
    assetData.assetdatas.forEach((value) {
      list.add({
        "assetid": value['assetid'],
        "asset_name": value['asset_name'],
        "asset_type": value['asset_type'],
        "asset_order": value['asset_order'],
        "asset_customer": value['asset_customer'],
        "no_seri": value['no_seri'],
        "asset_user": value['asset_user'],
        "divisi": value['divisi'],
        "service": value['service'],
        "asset_customer_service": value['asset_customer_service'],
        "status": value['status'],
        "notes": value['notes'],
        "service1": value['service1'],
        "service2": value['service2'],
        "service3": value['service3'],
        "hardisk": value['hardisk'],
        "memory": value['memory'],
        "type": value['type'],
        "expired_date": value['expired_date'],
      });
    });
    return list;
  }

  Widget listItemBuilder(value, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.black45))),
                    child: Icon(Icons.people, color: Colors.black),
                  ),
                  title: Text(
                    "Asset ID : ${value['assetid']}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Wrap(children: <Widget>[
                    Text("Asset Name : ${value['asset_name']}"
                        "\nAsset Type : ${value['asset_type']}"
                        "\nAsset Order : ${value['asset_order']}"
                        "\nexpired_date : ${value['expired_date']}"
                        "\nAsset Customer : ${value['asset_customer']}"
                        "\nNo Seri : ${value['no_seri']}"
                        "\nUser : ${value['asset_user']}"
                        "\nDivisi : ${value['divisi']}"
                        "\nService : ${value['service']}"
                        "\nAsset Cust. Service : ${value['asset_customer_service']}"
                        "\nStatus : ${value['status']}"
                        "\nNotes : ${value['notes']}"
                        "\nService 1 : ${value['service1']}"
                        "\nService 2 : ${value['service2']}"
                        "\nService 3 : ${value['service3']}"
                        "\nHardisk : ${value['hardisk']}"
                        "\nMemory : ${value['memory']}"
                        "\nType : ${value['type']}"
                        "",
                        style: TextStyle(color: Colors.black)),
                  ]),
                  trailing: Icon(Icons.keyboard_arrow_right,
                      color: Colors.black, size: 30.0)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Edit"),
                      onPressed: () async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        prefs.setBool("is_edit_asset", true);
                        print(value['asset_assetid'].toString());
                        prefs.setString("asset_assetid", value['assetid']?.toString() ?? '');
                        prefs.setString("asset_name", value['asset_name']?.toString() ?? '');
                        prefs.setString("asset_type", value['asset_type']?.toString() ?? '');
                        prefs.setString("asset_order", value['asset_order']?.toString() ?? '');
                        prefs.setString("asset_customer", value['asset_customer']?.toString() ?? '');
                        print("value['no_seri'].toString() ${value['no_seri']?.toString()}");

                        prefs.setString("asset_no_seri", value['no_seri']?.toString() ?? '');
                        prefs.setString("asset_user", value['asset_user']?.toString() ?? '');
                        prefs.setString("asset_divisi", value['divisi']?.toString() ?? '');
                        prefs.setString("asset_service", value['service']?.toString() ?? '');
                        prefs.setString("asset_customer_service", value['asset_customer_service']?.toString() ?? '');
                        prefs.setString("asset_status", value['status']?.toString() ?? '');
                        prefs.setString("asset_notes", value['notes']?.toString() ?? '');
                        prefs.setString("asset_service1", value['service1']?.toString() ?? '');
                        prefs.setString("asset_service2", value['service2']?.toString() ?? '');
                        prefs.setString("asset_service3", value['service3']?.toString() ?? '');
                        prefs.setString("asset_hardisk", value['hardisk']?.toString() ?? '');
                        prefs.setString("asset_memory", value['memory']?.toString() ?? '');
                        prefs.setString("asset_type", value['type']?.toString() ?? '');
                        prefs.setString("asset_expired_date", value['expired_date']?.toString() ?? '');
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FrmAsset()));
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blueAccent,
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetMaker(AssetDataModel assetDatas, VoidCallback retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(assetDatas.errorMessage),
        ),
        TextButton(
          onPressed: retryListener,
          child: Text('Retry'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(AssetDataModel driverdatas) {
    return Center(
      child: Text('Tidak ada asset dalam list'),
    );
  }
}

class AssetDataModel {
  List<dynamic> assetdatas;
  int statusCode;
  String errorMessage;
  int total;
  int nItems;

  AssetDataModel({
    required this.assetdatas,
    required this.statusCode,
    required this.errorMessage,
    required this.total,
    required this.nItems,
  });

  factory AssetDataModel.fromResponse(http.Response response) {
    List jsonData = json.decode(response.body);
    final datas = jsonData.length > 1 ? (jsonData[1] ?? []) : [];
    final tot = (jsonData.isNotEmpty && jsonData[0] != null && jsonData[0]['total'] != null)
        ? (jsonData[0]['total'] is int ? jsonData[0]['total'] as int : int.tryParse(jsonData[0]['total'].toString()) ?? 0)
        : 0;
    return AssetDataModel(
      assetdatas: datas,
      statusCode: response.statusCode,
      errorMessage: '',
      total: tot,
      nItems: datas.length,
    );
  }

  factory AssetDataModel.withError(String errorMessage) {
    return AssetDataModel(
      assetdatas: [],
      statusCode: 0,
      errorMessage: errorMessage,
      total: 0,
      nItems: 0,
    );
  }
}
