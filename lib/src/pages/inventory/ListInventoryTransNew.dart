import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/inventory/FrmInventory.dart';
import 'package:dms_anp/src/pages/inventory/ListInventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import '../../../choices.dart' as choices;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dms_anp/src/Helper/scanner_helper.dart';

import 'ListInventoryDetail.dart';

TextEditingController txtSearchWoNumber = new TextEditingController();
TextEditingController txtWoNumberID = new TextEditingController();
List<Map<String, dynamic>> lstInvOrderNumber = [];
List<Map<String, dynamic>> lstInvOrderNumberTemp = [];
List<Map<String, dynamic>> lstInvOrderNumberTemp2 = [];
List<Map<String, dynamic>> lstSearchInvOrderNumber = [];
var selInvOrderNumber = '';

class _BottomSheetContentListWo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "List Wo. Number",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Container(
            margin: EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                //filterSearchResultsDriver(value);
              },
              controller: txtSearchWoNumber,
              cursorColor: Color(0xFFFF8C69), // ✅ Orange cursor
              style: TextStyle(color: Colors.black87, fontSize: 14),
              decoration: InputDecoration(
                fillColor: Colors.white, // ✅ White background
                filled: true,
                isDense: true,
                labelText: "Search",
                hintText: "Search",
                labelStyle:
                    TextStyle(color: Colors.grey.shade600, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Color(0xFFFF8C69)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // ✅ Modern radius
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Color(0xFFFF8C69), width: 2), // ✅ Orange focus
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lstInvOrderNumber.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      selInvOrderNumber =
                          lstInvOrderNumber[index]['id'].toString();
                      txtWoNumberID.text =
                          lstInvOrderNumber[index]['id'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${lstInvOrderNumber[index]['id']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

 

class ListInventoryTransNew extends StatefulWidget {
  final String tabName;
  const ListInventoryTransNew({Key? key, required this.tabName})
      : super(key: key);
  @override
  _ListInventoryTransNewState createState() => _ListInventoryTransNewState();
}

class _ListInventoryTransNewState extends State<ListInventoryTransNew>
    with SingleTickerProviderStateMixin {
  // Orange Soft Theme Colors (sesuai INSTRUCTIONS.md)
  final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
  final Color accentOrange = Color(0xFFFFB347); // Peach orange
  final Color darkOrange = Color(0xFFE07B39); // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  final Color cardColor = Color(0xFFFFF8F0); // Light cream
  final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  TextEditingController txtSearchVehicleTyreTms = new TextEditingController();
  TextEditingController txtOrginalSn = new TextEditingController();
  TextEditingController txtInvTrxNumber = new TextEditingController();
  TextEditingController txtInvTrxDate = new TextEditingController();
  TextEditingController txtInvTrxFromWH = new TextEditingController();
  TextEditingController txtInvSearchFromWH = new TextEditingController();
  TextEditingController txtInvTrxToWH = new TextEditingController();
  TextEditingController txtInvSearchToWH = new TextEditingController();
  TextEditingController txtInvTrxToCustomer = new TextEditingController();
  TextEditingController txtInvSearchToCustomer = new TextEditingController();
  TextEditingController txtInvTrxNotes = new TextEditingController();
  TextEditingController txtInvLocid = new TextEditingController();
  String scanResult = '';
  var selTrxType = "";

  List<Map<String, dynamic>> lstVType = [];

  List dataListTmsTyreDummy = [];
  List dataListTyreTms = [];
  ProgressDialog? pr;
  String _searchText = "";
  int lengTabs = 3;
  int status_code = 0;
  String message = "";
  var username = "";
  var userid = "";
  var locid = "";
  var is_edit_req = false;
  List<Map<String, dynamic>> lstNoData = [
    {"id": "", "text": "No Data"}
  ];
  List<Map<String, dynamic>> lstFromWH = [];
  List<Map<String, dynamic>> dataSearchListFromWH = [];
  List<Map<String, dynamic>> lstToWH = [];
  List<Map<String, dynamic>> dataSearchListToWH = [];
  List<Map<String, dynamic>> lstToCustomer = [];
  List<Map<String, dynamic>> lstVendorID = [];
  List<Map<String, dynamic>> dataSearchlstToCustomer = [];

  List<Map<String, dynamic>> lstInvLocid = [];
  var selInvFromWH = '';
  var selInvToWH = '';
  var selInvToCustomer = '';
  var selInvVendorID = '';
  var readOnlyWo = false;
  var IsScanWo = true;
  var selInvType = '';
  var selInvLocid = '';
  final TextEditingController _filter = new TextEditingController();

  _goBack(BuildContext context) {
    globals.inv_back_page_detail = "";
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  // Custom TextField with orange theme (sesuai INSTRUCTIONS.md)
  Widget buildTextField({
    String labelText = '',
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixIcon,
    required Function(String) onTap,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: TextField(
        readOnly: readOnly,
        cursorColor: primaryOrange, // ✅ Orange cursor
        style: TextStyle(color: Colors.black87, fontSize: 14),
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap != null ? () => onTap('') : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor: Colors.white, // ✅ White background
          filled: true,
          isDense: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // ✅ Modern radius
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: primaryOrange, width: 2), // ✅ Orange focus
          ),
        ),
      ),
    );
  }

  // Custom SmartSelect with orange theme (sesuai INSTRUCTIONS.md)
  Widget buildSmartSelect({
    String title = '',
    String value = '',
    required Function(dynamic) onChange,
    List<S2Choice<String>> choices = const <S2Choice<String>>[],
    bool modalFilter = false,
    bool isDisabled = false,
  }) {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: SmartSelect<String>.single(
        title: title,
        placeholder: 'Pilih satu',
        selectedValue: value,
        onChange: isDisabled ? null : onChange,
        choiceType: S2ChoiceType.radios,
        choiceItems: choices,
        modalType: S2ModalType.popupDialog,
        modalHeader: false,
        modalFilter: modalFilter,
        modalFilterAuto: modalFilter,
        modalConfig: S2ModalConfig(
          style: S2ModalStyle(
            elevation: 8,
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
        ),
        tileBuilder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ListTile(
              title: Text(
                title,
                style: TextStyle(
                  color:
                      isDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                (value != null && value.isNotEmpty) ? value : 'Pilih satu',
                style: TextStyle(
                  color: (value != null && value.isNotEmpty)
                      ? (isDisabled ? Colors.grey.shade500 : Colors.black87)
                      : Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              trailing: Icon(Icons.arrow_drop_down,
                  color: isDisabled ? Colors.grey.shade400 : primaryOrange),
              onTap: isDisabled ? null : state.showModal,
            ),
          );
        },
      ),
    );
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Inventory');

  void resetTeksInvTrx() {
    setState(() {
      selInvLocid = '';
      selInvFromWH = '';
      selInvToWH = '';
      selInvToCustomer = '';
      selInvOrderNumber = '';
      txtWoNumberID.text = '';
      selInvType = '';
      selInvLocid = '';
    });
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";
    userid = prefs.getString("name") ?? "";
    locid = prefs.getString("locid") ?? "";
  }

  var tabNomor = 0;
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          tabNomor = 1;
          //getJSONDataTyre(true, '');
          break;
        case 1:
          tabNomor = 2;
          break;
        case 2:
          tabNomor = 3;
          break;
      }
      print('tabNomor ${tabNomor}');
    }
  }

  void _searchInventory(value) {
    //var value = _txtSearch.text;
    if (value == null || value == "") {
      return;
    } else {
      if (value.length >= 3) {
        _searchText = value;
        paginatorGlobalKey.currentState?.changeState(
            pageLoadFuture: sendInventoryDataRequest, resetState: true);
      } else {
        _searchText = '';
      }
    }
  }

  void _searchWoNumber() {
    List<Map<String, dynamic>> dummyListDataWo2 = [];
    if (txtSearchWoNumber.text != "" && txtSearchWoNumber.text != null) {
      if (txtSearchWoNumber.text.length >= 3) {
        for (var i = 0; i < lstInvOrderNumberTemp.length; i++) {
          var dtC = lstInvOrderNumberTemp[i]['id'].toLowerCase().toString();
          //print("${dtC} => ${txtSearchCabangNameCHK.text.toLowerCase().toString()}");
          if (dtC.contains(txtSearchWoNumber.text.toLowerCase().toString())) {
            //print(dtC);
            dummyListDataWo2.add({
              "id": lstInvOrderNumberTemp[i]['id'].toString(),
              "text": lstInvOrderNumberTemp[i]['text']
            });
          }
        }
      }
      if (dummyListDataWo2.length > 0) {
        if (mounted) {
          setState(() {
            lstInvOrderNumber = [];
            lstInvOrderNumber = dummyListDataWo2;
          });
        }
      } else {
        lstInvOrderNumber = lstInvOrderNumberTemp;
      }
      return;
    }
  }

  void _showModalListWo(BuildContext context) {
    //selInvOrderNumber
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentListWo();
      },
    );
  }

  void _searchVehicleNameTyreTms() {
    if (txtSearchVehicleTyreTms.text != "" &&
        txtSearchVehicleTyreTms.text != null) {
      if (txtSearchVehicleTyreTms.text.length >= 3) {
        print(txtSearchVehicleTyreTms.text);
        getJSONDataTyre(false, txtSearchVehicleTyreTms.text);
      } else {
        dataListTyreTms = dataListTmsTyreDummy;
        return;
      }
    } else {
      dataListTyreTms = dataListTmsTyreDummy;
      return;
    }
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: lengTabs);
    _txtSearch.text = "";
    globals.inv_back_page = "";
    setState(() {
      getSession();
    });
    _tabController.addListener(_handleTabSelection);
    txtSearchWoNumber.addListener(_searchWoNumber);
    print(lstInvOrderNumberTemp);
    //Future.delayed(Duration(milliseconds: 50));
    // if(globals.inv_back_page_detail!="" && globals.inv_back_page_detail!=null) {
    //   _searchText = globals.inv_back_page_detail;
    //   paginatorGlobalKey.currentState?.changeState(
    //       pageLoadFuture: sendInventoryDataRequest, resetState: true);
    //   //sendInventoryDataRequestSearch(1,globals.inv_back_page_detail);
    // }
    getJSONDataTyre(false, '');
    getListDataFromWH();
    getListDataToWH();
    getListDataToWo();
    getListDataToCustomer();
    getListDataLocid();
    getListDataVendorID();
    //_txtSearch.addListener(_searchInventory);
    //txtSearchVehicleTyreTms.addListener(_searchVehicleNameTyreTms);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (globals.inv_back_page_detail != "" &&
        globals.inv_back_page_detail != null) {
      _tabController.animateTo(1);
    }
    if (widget.tabName != null && widget.tabName == "wid_list_inventory") {
      _tabController.animateTo(1);
    }
    super.initState();
  }

  Future<String> getJSONDataTyre(bool isloading, String search) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        EasyLoading.show();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/maintenance/sr/list_data_rs_opr.jsp?method=lookup-list-tire-tms-v1&search=" +
              search);
      print(myUri.toString());
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
      setState(() {
        // Get the JSON data
        dataListTyreTms = json.decode(response.body);
        print(dataListTyreTms);
        if (dataListTyreTms == null || dataListTyreTms.length == 0) {
          if (search == '' || search == null) {
            alert(globalScaffoldKey.currentContext!, 2,
                "Data Tyre TMS tidak di temukan", "error");
          }
        } else {
          dataListTmsTyreDummy = dataListTyreTms;
        }
      });
    } catch (e) {
      if (isloading == true) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
      }
    }
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          }
        },
        child: DefaultTabController(
          length: lengTabs,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: primaryOrange, // ✅ Orange background
              foregroundColor: Colors.white, // ✅ White text/icons
              elevation: 2,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(globalScaffoldKey.currentContext!);
                },
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white, // ✅ White indicator
                indicatorWeight: 3,
                labelColor: Colors.white, // ✅ White selected text
                unselectedLabelColor:
                    Colors.white70, // ✅ Light white unselected
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                tabs: [
                  Tab(
                      icon: Icon(Icons.format_list_numbered_rtl,
                          size: 20, color: Colors.white),
                      child: Text('Form Inv.')),
                  Tab(
                      icon: Icon(Icons.list, size: 20, color: Colors.white),
                      child: Text('List Inventory')),
                  Tab(
                      icon:
                          Icon(Icons.car_repair, size: 20, color: Colors.white),
                      child: Text('List Tyre')),
                ],
              ),
              title: Text('Detail Inventory',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            body: TabBarView(
              key: globalScaffoldKey,
              controller: _tabController,
              children: [
                _buildListViewFormTrx(context),
                _buildListViewInventory(context),
                _buildListViewTmsTyre(context),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryOrange, // ✅ Orange background
              foregroundColor: Colors.white, // ✅ White icon
              elevation: 6,
              onPressed: () {
                if (tabNomor == 3) {
                  txtSearchVehicleTyreTms.text = '';
                  Future.delayed(Duration(milliseconds: 50));
                  getJSONDataTyre(true, '');
                }
                if (tabNomor == 2) {
                  setState(() {
                    _searchText = "";
                    _txtSearch.text = "";
                  });
                  paginatorGlobalKey.currentState?.changeState(
                      pageLoadFuture: sendInventoryDataRequest,
                      resetState: true);
                }
                if (tabNomor == 1) {
                  print('Inventory TRX');
                }
              },
              child: Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ));
  }

  var sel_inv_datetime = '';
  dateTimePickerWidget(BuildContext context) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'yyyy-MM-dd',
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(3000),
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime, List<int> index) {
        print('Done');
        DateTime selectdate = dateTime;
        sel_inv_datetime = DateFormat('yyyy-MM-dd').format(selectdate);
        print(sel_inv_datetime);
        setState(() {
          txtInvTrxDate.text = sel_inv_datetime.toString();
        });
      },
    );
  }

  Future getListDataFromWH() async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_fromwh";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      if (response.statusCode == 200) {
        setState(() {
          lstFromWH = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data WH",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data WH",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataToWH() async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_towh";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      if (response.statusCode == 200) {
        setState(() {
          lstToWH = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data To WH",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data To WH",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataToWo() async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_wo";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      if (response.statusCode == 200) {
        setState(() {
          lstInvOrderNumber = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();

          lstInvOrderNumberTemp = lstInvOrderNumber;
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data To WO",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data To WO",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataToCustomer() async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_customer";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          lstToCustomer = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data To Customer", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Client, Load data To Customer ${$e.toString()})", "error");
      print($e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataVendorID() async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_vendor";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          lstVendorID = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data vendor",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Client, Load data vendor ${$e.toString()})", "error");
      print($e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataLocid() async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/refference_master.jsp?method=list_bengkel";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          lstInvLocid = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data locid",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Client, Load data locid ${$e.toString()})", "error");
      print($e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  void resetInvTrx() {
    setState(() {
      txtInvTrxDate.text = "";
      selTrxType = "";
      selInvFromWH = "";
      selInvToWH = "";
      selInvOrderNumber = "";
      txtWoNumberID.text = "";
      selInvToCustomer = "";
      txtInvTrxNotes.text = "";
      selInvLocid = '';
      txtInvLocid.text = "";
      txtInvTrxDate.text = "";
      txtInvTrxFromWH.text = "";
      txtInvSearchFromWH.text = "";
      txtInvSearchFromWH.text = "";
      txtInvTrxToWH.text = "";
      txtInvSearchToWH.text = "";
      txtInvTrxToCustomer.text = "";
      txtInvSearchToCustomer.text = "";
      txtInvTrxNotes.text = "";
      txtInvLocid.text = "";
    });
  }

  Future CreateTrxInv(
      String inv_date,
      String inv_type,
      String vendorid,
      String inv_from_wh,
      String inv_to_wh,
      String inv_order_number,
      String inv_to_customer,
      String notes,
      String userid,
      String locid) async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/inventory_transaction.jsp?method=create-inv-trx&inv_date=${inv_date}"
          "&vendorid=${vendorid}&inv_type=${inv_type}&inv_from_wh=${inv_from_wh}&inv_to_wh=${inv_to_wh}&inv_order_number=${inv_order_number}&inv_to_customer=${inv_to_customer}&notes=${notes}&userid=${userid}&locid=${locid}";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        var status_code = json.decode(response.body)["status_code"];
        var returnnum = json.decode(response.body)["returnnum"];
        var message = json.decode(response.body)["message"];
        if (status_code == 200) {
          setState(() {
            resetInvTrx();
            txtInvTrxNumber.text = returnnum;
          });
          alert(globalScaffoldKey.currentContext!, 1, message, "success");
          resetInvTrx();
        } else {
          alert(globalScaffoldKey.currentContext!, 0, message, "error");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal create transaction",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "Gagal create transaction ${$e.toString()})", "error");
      print($e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future ApproveTrxInv(
      String inv_trx_type,
      String wo_number,
      String inv_trx_number,
      String from_ware_house,
      String to_warehouse,
      String locid) async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/approve_transaction_inventory.jsp?act=approve&inv_trx_type=${inv_trx_type}&wo_number=${wo_number}&inv_trx_number=${inv_trx_number}&from_ware_house=${from_ware_house}&to_warehouse=${to_warehouse}&userid=${username}&locid=${locid}";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        var message = json.decode(response.body)["message"];
        if (message.toString().contains("Approve Success")) {
          alert(globalScaffoldKey.currentContext!, 1, message, "success");
          paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: sendInventoryDataRequest, resetState: true);
        } else {
          alert(globalScaffoldKey.currentContext!, 0, message, "error");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal approve transaction",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "failed approve transaction ${$e.toString()})", "error");
      print($e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future CancelTrxInv(String inv_trx_number) async {
    try {
      EasyLoading.show();

      var url =
          "${GlobalData.baseUrl}api/inventory/cancel_transaction_inventory.jsp?act=cancel&inv_trx_number=${inv_trx_number}";

      var urlData = Uri.parse(url);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response = await http.get(myUri,
          headers: {"Accept": "application/json", "Connection": "Keep-Alive"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        var message = json.decode(response.body)["message"];
        if (status_code == 200) {
          if (message.toString().contains("Failed")) {
            alert(globalScaffoldKey.currentContext!, 0, message, "error");
          } else {
            alert(globalScaffoldKey.currentContext!, 1, message, "success");
            paginatorGlobalKey.currentState?.changeState(
                pageLoadFuture: sendInventoryDataRequest, resetState: true);
          }
        } else {
          alert(globalScaffoldKey.currentContext!, 0, message, "error");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal approve transaction",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      alert(globalScaffoldKey.currentContext!, 0,
          "failed approve transaction ${$e.toString()})", "error");
      print($e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future scanQRCodeWO() async {
    if (!mounted) return;
    
    final String? scanResult = await openQrScanner(context);
    
    if (scanResult == null || scanResult.isEmpty) {
      if (mounted) {
        alert(globalScaffoldKey.currentContext!, 0, "Scan WO Number gagal!", "error");
      }
      return;
    }
    
    setState(() {
      var itemID = scanResult;
      if (itemID != null && itemID != '') {
        if (lstInvOrderNumber.length > 0) {
          var dataFind = lstInvOrderNumber.where((x) => x['id'] == itemID);
          lstInvOrderNumber = [];
          var isFound = false;
          if (dataFind.isNotEmpty) {
            for (var i = 0; i < dataFind.length; i++) {
              lstInvOrderNumber.add(dataFind.elementAt(i));
              isFound = true;
            }
          }
          if (isFound == true) {
            setState(() {
              selInvOrderNumber = itemID;
              txtWoNumberID.text = itemID;
            });
          } else {
            alert(globalScaffoldKey.currentContext!, 3, "WO Number tidak di temukan!", "Info");
          }
        } else {
          alert(globalScaffoldKey.currentContext!, 3, "WO Number tidak di temukan!", "Info");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 3, "WO Number tidak di temukan!", "Info");
      }
    });
  }

  Future scanQRCodeWODev() async {
    setState(() {
      scanResult = "ANWO23013311";

      ///print("scanResult : $scanResult");
      if (scanResult != null) {
        var itemID = scanResult;
        if (itemID != null && itemID != '') {
          if (lstInvOrderNumber.length > 0) {
            var dataFind = lstInvOrderNumber
                .where((x) => x['id'] == itemID); //ANWO20012584
            lstInvOrderNumber = [];
            var isFound = false;
            if (dataFind.isNotEmpty) {
              for (var i = 0; i < dataFind.length; i++) {
                lstInvOrderNumber.add(dataFind.elementAt(i));
                isFound = true;
              }
            }
            if (isFound == true) {
              setState(() {
                selInvOrderNumber = itemID;
                txtWoNumberID.text = itemID;
              });
            }
            print(lstInvOrderNumber);
          }
        } else {
          alert(globalScaffoldKey.currentContext!, 3,
              "WO Number tidak di temukan!", "Info");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Scan WO Number gagal!",
            "error");
      }
    });
  }

  var array_list_smart = []; //list disable
  Widget _buildListViewFormTrx(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.blue, spreadRadius: 1),
        ],
      ),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            buildTextField(
              labelText: "Inv. Trx Number",
              controller: txtInvTrxNumber,
              readOnly: true,
              suffixIcon: null,
              onTap: (String p1) {},
              onChanged: (String p1) {},
            ),
            buildTextField(
              labelText: "Inv. Trx DateTime",
              controller: txtInvTrxDate,
              readOnly: true,
              onTap: (value) {
                dateTimePickerWidget(context);
              },
              onChanged: (String p1) {},
              suffixIcon: Icon(Icons.calendar_today, color: primaryOrange),
            ),
            buildSmartSelect(
              title: 'Inv. Trx Type',
              value: selTrxType,
              onChange: (selected) async {
                setState(() {
                  selTrxType = selected.value;
                  array_list_smart = [];
                  print(selTrxType);
                  readOnlyWo = false;
                  lstInvOrderNumber = [];
                  lstInvOrderNumber = lstInvOrderNumberTemp;
                  if (selTrxType == 'IR-W' || selTrxType == 'IS-W') {
                    selInvToCustomer = '';
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvVendorID = '';
                    array_list_smart = ["order-number", "customer", "vendorid"];
                    print(' array_list_smart ${array_list_smart}');
                  } else if (selTrxType == 'IR-P') {
                    selInvToCustomer = '';
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvFromWH = '';
                    array_list_smart = [
                      "order-number",
                      "customer",
                      "warehouse"
                    ];
                  } else if (selTrxType == 'IR-M') {
                    selInvToCustomer = '';
                    selInvFromWH = '';
                    array_list_smart = ["customer", "warehouse"];
                  } else if (selTrxType == 'IS-P') {
                    selInvToCustomer = '';
                    selInvFromWH = '';
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    array_list_smart = [
                      "order-number",
                      "customer",
                      "to-warehouse"
                    ];
                  } else if (selTrxType == 'IS-M') {
                    selInvToCustomer = '';
                    selInvToWH = '';
                    selInvVendorID = '';
                    array_list_smart = ["customer", "to-warehouse", "vendorid"];
                  } else if (selTrxType == 'IS-B') {
                    selInvToCustomer = '';
                    selInvToWH = '';
                    selInvVendorID = '';
                    array_list_smart = ["customer", "to-warehouse", "vendorid"];
                  } else if (selTrxType == 'IS-C') {
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvToWH = '';
                    selInvVendorID = '';
                    array_list_smart = [
                      "order-number",
                      "to-warehouse",
                      "vendorid"
                    ];
                    print(
                        "array_list_smart warehouese ${array_list_smart.indexOf("warehouse")}");
                  } else if (selTrxType == 'IS-S') {
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvFromWH = '';
                    selInvToCustomer = '';
                    selInvVendorID = '';
                    array_list_smart = [
                      "order-number",
                      "warehouse",
                      "customer",
                      "vendorid"
                    ];
                  } else if (selTrxType == 'IR-S') {
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvFromWH = '';
                    selInvToCustomer = '';
                    selInvVendorID = '';
                    array_list_smart = [
                      "order-number",
                      "warehouse",
                      "customer",
                      "vendorid"
                    ];
                  } else if (selTrxType == 'IR-P') {
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvFromWH = '';
                    selInvToCustomer = '';
                    array_list_smart = [
                      "order-number",
                      "warehouse",
                      "customer"
                    ];
                  }
                  // else if (selTrxType == 'IR-W') {
                  //   selInvOrderNumber = '';
                  //   selInvFromWH = '';
                  //   selInvToCustomer = '';
                  //   selInvVendorID = '';
                  //   array_list_smart = [
                  //     "order-number",
                  //     "customer",
                  //     "vendorid"
                  //   ];
                  //   print('IR-W ${array_list_smart.indexOf("vendorid") >= 0}');
                  // }
                  else if (selTrxType == 'IS-T') {
                    selInvOrderNumber = '';
                    readOnlyWo = true;
                    txtWoNumberID.text = '';
                    selInvToCustomer = '';
                    selInvVendorID = '';
                    array_list_smart = ["order-number", "customer", "vendorid"];
                  } else {
                    array_list_smart = [];
                  }
                  print(array_list_smart.indexOf("warehouse"));
                });
              },
              choices: choices.listInventoryTrxType,
              modalFilter: true,
            ),
            buildSmartSelect(
              title: 'From WareHouse',
              value: selInvFromWH,
              onChange: (selected) async {
                setState(() {
                  selInvFromWH = selected.value;
                  print(lstFromWH);
                });
              },
              choices: S2Choice.listFrom<String, Map>(
                  source: (array_list_smart.length > 0 &&
                          array_list_smart.indexOf("warehouse") >= 0
                      ? lstNoData
                      : lstFromWH),
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              modalFilter: true,
              isDisabled: (array_list_smart.length > 0 &&
                  array_list_smart.indexOf("warehouse") >= 0),
            ),
            SmartSelect<String>.single(
              // globalScaffoldKey,
              title: 'To WareHouse',
              selectedValue: selInvToWH,
              placeholder: 'Pilih To WareHouse',
              onChange: (selected) async {
                setState(() {
                  selInvToWH = selected.value;
                });
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: (array_list_smart.length > 0 &&
                          array_list_smart.indexOf("to-warehouse") >= 0
                      ? lstNoData
                      : lstToWH),
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              //choiceGrouped: true,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            buildTextField(
              labelText: "Work Order Number",
              controller: txtWoNumberID,
              readOnly: true,
              onTap: (value) {
                print('ontap ${readOnlyWo}');
                if (IsScanWo == false) {
                  setState(() {
                    _showModalListWo(context);
                  });
                }
              },
              suffixIcon: IconButton(
                icon: new Image.asset(
                  "assets/img/qrcode.png",
                  width: 32.0,
                  height: 32.0,
                ),
                onPressed: () {
                  IsScanWo = true;
                  if (IsScanWo == true) {
                    showDialog(
                      context: context,
                      builder: (context) => new AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: cardColor,
                        title: new Text('Information',
                            style: TextStyle(
                              color: darkOrange,
                              fontWeight: FontWeight.w600,
                            )),
                        content: new Text("Scan WO Number?"),
                        actions: <Widget>[
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 18.0,
                            ),
                            label: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                              setState(() {
                                IsScanWo = false;
                                selInvOrderNumber = "";
                                txtWoNumberID.text = "";
                                lstInvOrderNumber = lstInvOrderNumberTemp;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 2.0,
                                backgroundColor: Colors.grey.shade500,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                textStyle: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                          new ElevatedButton.icon(
                            icon: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 18.0,
                            ),
                            label: Text("Scan WO?"),
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                              setState(() {
                                selInvOrderNumber = "";
                                txtWoNumberID.text = "";
                              });
                              scanQRCodeWO();
                              if (IsScanWo == true) { //
                                setState(() {
                                  IsScanWo = false;
                                });
                                print("IsScanWo ${IsScanWo}");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 2.0,
                                backgroundColor: primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                textStyle: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ), onChanged: (String p1) {  },
            ),
            SmartSelect<String>.single(
              title: 'To Customer',
              selectedValue: selInvToCustomer,
              placeholder: 'Pilih To Customer',
              onChange: (selected) async {
                setState(() {
                  selInvToCustomer = selected.value;
                });
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: (array_list_smart.length > 0 &&
                          array_list_smart.indexOf("customer") >= 0
                      ? lstNoData
                      : lstToCustomer),
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              //choiceGrouped: true,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            SmartSelect<String>.single(
              title: 'Vendor ID',
              selectedValue: selInvVendorID,
              placeholder: 'Pilih Vendor ID',
              onChange: (selected) async {
                setState(() {
                  selInvVendorID = selected.value;
                });
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: (array_list_smart.length > 0 &&
                          array_list_smart.indexOf("vendorid") >= 0
                      ? lstNoData
                      : lstVendorID),
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              //choiceGrouped: true,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            SmartSelect<String>.single(
              title: 'Cabang',
              selectedValue: selInvToCustomer,
              placeholder: 'Pilih Cabang',
              onChange: (selected) async {
                setState(() {
                  selInvLocid = selected.value;
                });
              },
              choiceItems: S2Choice.listFrom<String, Map>(
                  source: lstInvLocid,
                  value: (index, item) => item['id'],
                  title: (index, item) => item['text']),
              //choiceGrouped: true,
              modalFilter: true,
              modalFilterAuto: true,
            ),
            buildTextField(
              labelText: "Notes",
              controller: txtInvTrxNotes,
              readOnly: false, onTap: (String p1) {  }, onChanged: (String p1) {  },
            ),
            Container(
              margin: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 18.0,
                  ),
                  label: Text("Cancel"),
                  onPressed: () async {
                    resetTeksInvTrx();
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor:
                          Colors.grey.shade500, // ✅ Neutral gray for cancel
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                )),
                SizedBox(width: 5),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 18.0,
                  ),
                  label: Text("Submit"),
                  onPressed: () async {
                    //alert(globalScaffoldKey.currentContext!,0,"Anda tidak dapat melakukan transaksi ini","error");
                    if (txtInvTrxDate.text == null ||
                        txtInvTrxDate.text == "") {
                      alert(globalScaffoldKey.currentContext!, 2,
                          "Date tidak boleh kosong", "warning");
                    } else if (selTrxType == null || selTrxType == "") {
                      alert(globalScaffoldKey.currentContext!, 2,
                          "Type tidak boleh kosong", "warning");
                    } else if (selInvLocid == null || selInvLocid == "") {
                      alert(globalScaffoldKey.currentContext!, 2,
                          "Cabang ID tidak boleh kosong", "warning");
                    } else if (selTrxType == "IR-P" &&
                        (selInvVendorID == '' || selInvVendorID == null)) {
                      alert(globalScaffoldKey.currentContext!, 2,
                          "Vendor ID tidak boleh kosong", "warning");
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text(
                              is_edit_req == false ? "Save" : "Update"),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("No"),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("Ok"),
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                                var isOK = globals.akses_pages == null
                                    ? globals.akses_pages
                                    : globals.akses_pages.where((x) =>
                                        x == "OP" || username == "ADMIN");
                                if (isOK != null) {
                                  if (isOK.length > 0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        title: new Text('Information'),
                                        content: new Text(
                                            "Create transaction Inventory?"),
                                        actions: <Widget>[
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            label: Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor: Colors.red,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          new ElevatedButton.icon(
                                            icon: Icon(
                                              Icons.save,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            label: Text("Ok"),
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                              await CreateTrxInv(
                                                  txtInvTrxDate.text,
                                                  selTrxType,
                                                  selInvVendorID,
                                                  selInvFromWH,
                                                  selInvToWH,
                                                  selInvOrderNumber,
                                                  selInvToCustomer,
                                                  txtInvTrxNotes.text,
                                                  username,
                                                  selInvLocid);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor: Colors.blue,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                                textStyle: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  alert(
                                      globalScaffoldKey.currentContext!,
                                      0,
                                      "Anda tidak dapat melakukan transaksi ini",
                                      "error");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      print('save transaction');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: primaryOrange, // ✅ Orange background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                )),
                //SizedBox(width: 5),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListViewTmsTyre(BuildContext context) {
    return SingleChildScrollView(
        //shrinkWrap: true,
        padding: EdgeInsets.all(2.0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            buildTextField(
              labelText: "Search",
              controller: txtSearchVehicleTyreTms,
              onChanged: (value) {
                //print(value);
                if (value != "" && value != null) {
                  if (value.length >= 3) {
                    print(value);
                    getJSONDataTyre(false, value);
                  } else {
                    dataListTyreTms = dataListTmsTyreDummy;
                    return;
                  }
                } else {
                  dataListTyreTms = dataListTmsTyreDummy;
                  return;
                }
              },
              suffixIcon: Icon(Icons.search, color: primaryOrange), onTap: (String p1) {  },
            ),
            Container(
              //padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(5.0),
                  itemCount: dataListTyreTms.length,
                  itemBuilder: (context, index) {
                    return _buildDListRequestTmsTyre(
                        dataListTyreTms[index], index);
                  }),
            )
          ],
        ));
  }

  Widget _buildListViewInventory(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      scrollDirection: Axis.vertical,

      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 70,
            child: buildTextField(
              labelText: "Search...",
              controller: _txtSearch,
              onChanged: (value) {
                print('INVENTORY SEARCH ${value}');
                if (value != "" && value != null) {
                  if (value.length >= 3) {
                    print(value);
                    _searchInventory(value);
                  }
                } else {
                  //dataListTyreTms = dataListTmsTyreDummy;
                  return;
                }
                globals.inv_back_page_detail = "";
              },
              suffixIcon: Icon(Icons.search, color: primaryOrange), onTap: (String p1) {  },
            ),
          ),
          SizedBox(
            height: 500,
            child: Paginator.listView(
              key: paginatorGlobalKey,
              //scrollDirection: Axis.vertical,
              //shrinkWrap: true,
              pageLoadFuture: sendInventoryDataRequest,
              pageItemsGetter: (data) =>
                  listItemsGetter(data as InventoryTransDataModel),
              listItemBuilder: listItemBuilder,
              loadingWidgetBuilder: loadingWidgetMaker,
              errorWidgetBuilder: errorWidgetMaker,
              emptyListWidgetBuilder: (data) =>
                  emptyListWidgetMaker(data as InventoryTransDataModel),
              totalItemsGetter: (data) =>
                  totalPagesGetter(data as InventoryTransDataModel),
              pageErrorChecker: (data) =>
                  pageErrorChecker(data as InventoryTransDataModel),
              scrollPhysics: BouncingScrollPhysics(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDListRequestTmsTyre(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.black45))),
                  child: Icon(Icons.settings_applications, color: Colors.black),
                ),
                title: Text(
                  "Tyre Number : ${item['tyrenumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Status : ${item['tyrestatus']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Po. Number : ${item['ponumber']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("IV. Number: ${item['ivnumber']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "Original SN: ${item['original_sn'] == null ? '[Not Set]' : item['original_sn']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                buildButtonUpdateSn(context, item['tyrenumber']),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonUpdateSn(BuildContext context, String tyrenumber) {
    return Expanded(
        child: ElevatedButton.icon(
      icon: Icon(
        Icons.save,
        color: Colors.white,
        size: 18.0,
      ),
      label: Text("Update SN"),
      onPressed: () async {
        showDialog(
          context: globalScaffoldKey.currentContext!,
          builder: (context) => new AlertDialog(
            title: new Text('Information'),
            //content: new Text("Close WO data ${appSrnumber}"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              // wrap content in flutter
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Update SN ${tyrenumber}"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextField(
                    cursorColor: primaryOrange, // ✅ Orange cursor
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    controller: txtOrginalSn,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelText: "Set original SN",
                      labelStyle:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: primaryOrange, width: 2), // ✅ Orange focus
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              new TextButton(
                  onPressed: () {
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                    txtOrginalSn.text = "";
                  },
                  child: new Text('No')),
              new ElevatedButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 18.0,
                  ),
                  label: Text("Update"),
                  onPressed: () async {
                    Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                     updateSnTyre(tyrenumber, txtOrginalSn.text, "");
                    txtOrginalSn.text = "";
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: primaryOrange, // ✅ Orange background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          ),
        );
      },
      style: ElevatedButton.styleFrom(
          elevation: 2.0,
          backgroundColor: primaryOrange, // ✅ Orange background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ));
  }

  void updateSnTyre(String tyrenumber, original_sn, notes) async {
    try {
      if (tyrenumber == null || tyrenumber == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Tyre Number tidak boleh kosong", "error");
      }
      if (original_sn == null || original_sn == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "SN Tyre tidak boleh kosong", "error");
      } else {
        EasyLoading.show();
        var encoded = Uri.encodeFull(
            "${GlobalData.baseUrl}api/maintenance/sr/update_tyre_number.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = 'update-sn-tyre-v1';
        var data = {
          'method': method,
          'tyrenumber': tyrenumber,
          'original_sn': original_sn,
          'userid': userid.toUpperCase(),
          'notes': notes,
          'company': 'AN'
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(response);
            if (status_code == 200) {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        getJSONDataTyre(true, "");
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blue,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            } else {
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            alert(globalScaffoldKey.currentContext!, 0,
                "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  Future<InventoryTransDataModel> sendInventoryDataRequest(int page) async {
    print('page ${page}');
    try {
      // String url = Uri.encodeFull(
      //     'http://apps.tuluatas.com:8085/cemindo/api/inventory/list_inventory_trans.jsp?method=list-inventory-trans-v1&page=${page}&search=' +
      //         _searchText);
      if (globals.inv_back_page_detail != "" &&
          globals.inv_back_page_detail != null) {
        _txtSearch.text = globals.inv_back_page_detail!;
      }
      String url = Uri.encodeFull(
          '${GlobalData.baseUrl}api/inventory/list_inventory_trans.jsp?method=list-inventory-trans-v1&page=${page}&search=' +
              _txtSearch.text);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body} end');
      return InventoryTransDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        //paginatorGlobalKey
        alert(context, 2, "Please check your internet connection.", "warning");
        return InventoryTransDataModel.withError(
            'Please check your internet connection.');
      } else {
        //alert(context, 2, "Something went wrong.", "warning");
        return InventoryTransDataModel.withError('Something went wrong.');
      }
    }
  }

  Future<InventoryTransDataModel> sendInventoryDataRequestSearch(
      int page, String search) async {
    print('page ${page}');
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrl}api/inventory/list_inventory_trans.jsp?method=list-inventory-trans-v1&page=${page}&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body} end');
      return InventoryTransDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        //paginatorGlobalKey
        alert(context, 2, "Please check your internet connection.", "warning");
        return InventoryTransDataModel.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return InventoryTransDataModel.withError('Something went wrong.');
      }
    }
  }

  List<Map<String, dynamic>> listItemsGetter(InventoryTransDataModel data) {
    List<Map<String, dynamic>> list = [];
    print("listItemsGetter");
    data.inventorydataModel.forEach((value) {
      list.add({
        "inv_trx_number": value['inv_trx_number'],
        "inv_trx_status": value['inv_trx_status'],
        "inv_trx_type": value['inv_trx_type'],
        "from_ware_house": value['from_ware_house'],
        "towarehouse": value['towarehouse'],
        "vendorid": value['vendorid'],
        "wo_number": value['wo_number'],
        "locid": value['locid'],
        "created_user": value['created_user'],
        "nopol": value['nopol'],
        "vhtid": value['vhtid'],
        "genuine_no": value['genuine_no'],
      });
    });
    return list;
  }

  Widget listItemBuilder(value, int index) {
    //print(value["drvid"]);
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
                  child: Icon(Icons.settings, color: Colors.black),
                ),

                title: Text(
                  "Inv. Trx Number: ${value['inv_trx_number']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Nopol: ${value['nopol']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "Inv. Trx Status / Type: ${value['inv_trx_status']} / ${value['inv_trx_type']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("From Ware House: ${value['from_ware_house']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "To Ware House: ${(value['towarehouse'] == 'null' || value['towarehouse'] == '' || value['towarehouse'] == null ? '' : value['towarehouse'])}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "Vendor ID: ${(value['vendorid'] == 'null' || value['vendorid'] == null ? '' : value['vendorid'])}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text(
                      "Wo Number: ${(value['wo_number'] == 'null' || value['wo_number'] == '' || value['wo_number'] == null ? '' : value['wo_number'])}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Cabang: ${value['locid']}",
                      style: TextStyle(color: Colors.black)),
                ]),
                // trailing: Icon(Icons.keyboard_arrow_right,
                //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Add",style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    globals.inv_trx_number = value['inv_trx_number'];
                    globals.from_ware_house = value['from_ware_house'];
                    globals.inv_trx_type = value['inv_trx_type'];
                    globals.inv_locid = value['locid'];
                    globals.inv_vhtid = value['vhtid'];
                    globals.inv_genuine_no = value['genuine_no'];
                    globals.inv_method = "";
                    globals.inv_back_page = "form";
                    globals.inv_back_page_detail = value['inv_trx_number'];
                    globals.inv_wonumber = value['wo_number'];
                    print(
                        'globals.inv_towarehouse ${value['towarehouse'].toString()}');
                    print(
                        'globals.from_ware_house ${value['from_ware_house'].toString()}');
                    globals.inv_vendorid =
                        value['vendorid'] == 'null' || value['vendorid'] == null
                            ? ''
                            : value['vendorid'];
                    globals.inv_towarehouse = value['towarehouse'] == 'null' ||
                            value['towarehouse'] == null
                        ? ''
                        : value['towarehouse'];
                    // print(globals.inv_back_page_detail);
                    // print(globals.inv_locid);
                    // print("inv_towarehouse");
                    // print(globals.inv_towarehouse);
                    print('inv_trx_type');
                    print(value['inv_trx_type']);
                    var isIsm = value['inv_trx_type'] != null &&
                            value['inv_trx_type'].toString() != ''
                        ? value['inv_trx_type'].toString()
                        : null;
                    print(isIsm);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FrmInventory(invTrxStatusBarang: isIsm!)));
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: accentOrange, // ✅ Accent orange for Add
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                )),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("View Detail",style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    print(value['inv_trx_number']);
                    globals.inv_trx_number = value['inv_trx_number'];
                    globals.from_ware_house = value['from_ware_house'];
                    globals.inv_trx_type = value['inv_trx_type'];
                    globals.inv_locid = value['locid'];
                    globals.inv_vhtid = value['vhtid'];
                    globals.inv_genuine_no = value['genuine_no'];
                    globals.inv_vendorid =
                        value['vendorid'] == 'null' || value['vendorid'] == null
                            ? ''
                            : value['vendorid'];
                    globals.inv_towarehouse = value['towarehouse'] == 'null' ||
                            value['towarehouse'] == null
                        ? ''
                        : value['towarehouse'];
                    print(globals.inv_locid);
                    globals.inv_back_page = "detail";
                    globals.inv_back_page_detail = value['inv_trx_number'];
                    print(globals.inv_back_page_detail);
                    var isIsm = value['inv_trx_type'] != null &&
                            value['inv_trx_type'].toString() != ''
                        ? value['inv_trx_type'].toString()
                        : null;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListInventoryDetail(
                                tabName: '', invTrxStatusBarang: isIsm ?? '')));
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor:
                          primaryOrange, // ✅ Orange for View Detail
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                )),
              ]),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Cancel",style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // globals.inv_trx_number = value['inv_trx_number'];
                    // globals.from_ware_house = value['from_ware_house'];
                    // globals.inv_trx_type = value['inv_trx_type'];
                    // globals.inv_locid = value['locid'];
                    // globals.inv_vhtid = value['vhtid'];
                    // globals.inv_genuine_no = value['genuine_no'];
                    // globals.inv_method = "cancel";
                    print('cancel');

                    if (value['wo_number'] == null ||
                        value['wo_number'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "WO Number tidak boleh kosong", "error");
                    } else if (value['inv_trx_number'] == null ||
                        value['inv_trx_number'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Trx Number tidak boleh kosong", "error");
                    } else {
                      showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Cancel this data?"),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("No"),
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                            new SizedBox(width: 10),
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("Cancel Transaction"),
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                await CancelTrxInv(value['inv_trx_number']);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor:
                          Colors.grey.shade500, // ✅ Gray for Cancel
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                )),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Approve",style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    // print(value['inv_trx_number']);
                    // globals.inv_trx_number = value['inv_trx_number'];
                    // globals.from_ware_house = value['from_ware_house'];
                    // globals.inv_trx_type = value['inv_trx_type'];
                    print('Approve');
                    if (value['wo_number'] == null ||
                        value['wo_number'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "WO Number tidak boleh kosong", "error");
                    } else if (value['inv_trx_number'] == null ||
                        value['inv_trx_number'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Trx Number tidak boleh kosong", "error");
                    } else if (value['inv_trx_type'] == null ||
                        value['inv_trx_type'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Type tidak boleh kosong", "error");
                    } else if (value['from_ware_house'] == null ||
                        value['from_ware_house'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "WH ID tidak boleh kosong", "error");
                    } else if (value['locid'] == null || value['locid'] == '') {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Cabang tidak boleh kosong", "error");
                    } else {
                      showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Approve this data?"),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("No"),
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                            new SizedBox(width: 10),
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text("Approve"),
                              onPressed: () async {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                print(value['inv_trx_type']);
                                print(value['wo_number']);
                                print(value['inv_trx_number']);
                                print(value['from_ware_house']);
                                print(value['towarehouse']);
                                print(value['locid']);
                                await ApproveTrxInv(
                                    value['inv_trx_type'],
                                    value['wo_number'],
                                    value['inv_trx_number'],
                                    value['from_ware_house'],
                                    value['towarehouse'],
                                    value['locid']);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: darkOrange, // ✅ Dark orange for Approve
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

  Widget errorWidgetMaker(
      dynamic inventorydataModel, VoidCallback retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Text(inventorydataModel?.errorMessage ?? "Something went wrong."),
        ),
        TextButton(
          onPressed: retryListener,
          child: Text('Retry'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(InventoryTransDataModel inventorydataModel) {
    return Center(
      child: Text('Tidak ada inventory dalam list'),
    );
  }

  int totalPagesGetter(InventoryTransDataModel inventorydataModel) {
    return inventorydataModel.total;
  }

  bool pageErrorChecker(InventoryTransDataModel inventorydataModel) {
    return inventorydataModel.statusCode != 200;
  }
}

class InventoryTransDataModel {
  late List<dynamic> inventorydataModel;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  InventoryTransDataModel.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    List jsonData = json.decode(response.body);
    inventorydataModel = jsonData[1] ?? [];
    total = ((jsonData[0] as Map)['total'] ?? 0) as int;
    nItems = inventorydataModel.length;
    errorMessage = '';
  }

  InventoryTransDataModel.withError(String msg)
      : inventorydataModel = [],
        statusCode = 0,
        total = 0,
        nItems = 0,
        errorMessage = msg;
}
