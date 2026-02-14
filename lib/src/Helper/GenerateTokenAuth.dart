import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:http/http.dart' as http;
import 'Provider.dart';

class LastPostionEasyGo{
  String vhcid = "";
  String vhcgps = "";
  double lat = 0;
  double lon = 0;
  String addr = "";
  String no_do = "";
  String ket_status_do = "";
  String driver_nm = "";
  String nopol = "";
  String gps_sn = "";
  String gps_time = "";
  int speed = 0;
  int acc = 0;
  String direction = "0";
  String message = "";
  LastPostionEasyGo(this.vhcid,this.vhcgps,this.lat,this.lon,this.addr,this.no_do,this.ket_status_do,this.driver_nm,this.nopol,this.gps_sn,this.gps_time
      ,this.speed,this.acc,this.direction,this.message);
}

class GenerateTokenAuth{
  Future<LastPostionEasyGo> GetLastPositionFirst(String token, String vhcid) async {
    //var vhcid = 'B 9646 YM/TR DP-2';//prefs.getString("vhcidOPR").toString();
    final listData  = LastPostionEasyGo("","",0,0,"","","","","","","",0,0,"","");
    try {
      Uri myUri = Uri.parse(GlobalData.baseUrlAPIEASYGO +
          "Vehicle/LastUpdateByNopol2?nopol=$vhcid");
      var response = await http.post(myUri,
          headers: {"Accept": "application/json", "Authorization": token});
      if (response.statusCode == 200) {
        final List<dynamic> dataLast = json.decode(response.body)['data'] as List<dynamic>;
        if(dataLast.isNotEmpty){
          final first = dataLast[0] as Map<String, dynamic>;
          print("dataLast[0] $first");
          listData.nopol = first["nopol"]?.toString() ?? "";
          listData.acc = (first["acc"] ?? 0) as int;
          listData.gps_time = first["gps_time"]?.toString() ?? "";
          listData.gps_sn = first["gps_sn"]?.toString() ?? "";
          listData.addr = first["addr"]?.toString() ?? "";
          listData.speed = (first["speed"] ?? 0) as int;
          listData.direction = first["direction"]?.toString() ?? "0";
          listData.lon = (first["lon"] ?? 0).toDouble();
          listData.lat = (first["lat"] ?? 0).toDouble();
          listData.no_do = first["no_do"]?.toString() ?? "";
          listData.ket_status_do = first["ket_status_do"]?.toString() ?? "";
          listData.driver_nm = first["driver_nm"]?.toString() ?? "";
          listData.message = "200";
        }else{
          listData.message = "No Data";
        }
      } else {
        final dataError = json.decode(response.body);
        listData.message =  dataError['message']?.toString() ?? 'Error';
      }
    } catch (e) {
      listData.message = "Error $e";
      print("Auth Error$e");
    }
    return listData;
  }
  Future<String> GetTokenEasyGo(String vehicle, ProgressDialog prd) async {
    return GlobalData.token_vts;
  }
  Future<String> GetTokenEasyGoOld(String vehicle, ProgressDialog prd) async {
    EasyLoading.show();
    print('start token ${vehicle.toLowerCase().replaceAll(" ", "")}');
    var token = "";
    if (vehicle.toLowerCase().replaceAll(" ", "") == "easygo") {
      try {
        final Map<String, String> queryParams = {
          'username': "andalan",
          'password': "12345",
          'appsname': "tms",
        };
        var body = json.encode(queryParams);
        Uri myUri =
        Uri.parse(GlobalData.baseUrlAPIEASYGO + "Users/authenticate");
        var response = await http.post(myUri,
            headers: {"Content-Type": "application/json"}, body: body);
        print("EASYGO TOKEN ${myUri}");
        print(response.statusCode);
        if(response.statusCode==200){
          final dataAuth = json.decode(response.body);
          print(dataAuth);
          token = dataAuth["token"].toString();
        }
        if(EasyLoading.isShow){
          EasyLoading.dismiss();
        }
      } catch (e) {
        if(EasyLoading.isShow){
          EasyLoading.dismiss();
        }
        print("Auth Error$e");
      }
    }
    return token;
  }
}