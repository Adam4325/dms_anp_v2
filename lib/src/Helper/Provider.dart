import 'package:shared_preferences/shared_preferences.dart';

class GetDataServer {
  //static final String getserver_name="";
  static Future<String> getServerName() async {
    var server_name = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sn = prefs.getString("server_name");
    server_name = sn == null || sn == "" || sn == "default"
        ? "apps.tuluatas.com:8080"
        : (sn == "mirroring"
            ? "101.255.103.242:8080"
            : "apps.tuluatas.com:8080");
    print("GlobalData ${server_name}");
    return server_name;
  }
}

class GlobalData {

  // static const String baseUrlAPICANVASE = "https://canvas.easygo-gps.co.id/";
  // static const String baseUrlAPIEASYGO = "https://api.easygo-gps.co.id/";
  //PROD
  // static final String getServerName = GetDataServer.getServerName() as String;
  // static final String baseUrlDEV = "http://apps.tuluatas.com:8080/cemindo/mobile/";
  // static final String baseUrl = "http://apps.tuluatas.com:8080/trucking/mobile/";
  // static final String baseUrlOri = "http://apps.tuluatas.com:8080/trucking/";
  // static final String baseUrlOriIP = "http://apps.tuluatas.com:8080/trucking/";
  // static final String baseUrlProd = "http://apps.tuluatas.com:8080/trucking/mobile/";
  // static final String baseUrlServlet = "http://apps.tuluatas.com:8080/trucking/mobile/";
  //END

  static final String getServerName = GetDataServer.getServerName() as String;
  static final String baseUrlDEV = "https://apps.tuluatas.com:8080/cemindo/mobile/";
  // static final String baseUrl = "http://hen08xv0xw5.sn.mynetname.net:8080/trucking/mobile/";
  // static final String baseUrlOri = "http://hen08xv0xw5.sn.mynetname.net:8080/trucking/";
  // static final String baseUrlOriIP = "http://hen08xv0xw5.sn.mynetname.net:8080/trucking/";
  // static final String baseUrlProd = "http://hen08xv0xw5.sn.mynetname.net:8080/trucking/mobile/";
  // static final String baseUrlServlet = "http://hen08xv0xw5.sn.mynetname.net:8080/trucking/mobile/";

  static final String baseUrl = "https://apps.tuluatas.com/trucking/mobile/";
  static final String baseUrlOri = "https://apps.tuluatas.com/trucking/";
  static final String baseUrlOriIP = "https://apps.tuluatas.com/trucking/";
  static final String baseUrlProd = "https://apps.tuluatas.com/trucking/mobile/";
  static final String baseUrlServlet = "https://apps.tuluatas.com/trucking/mobile/";
  static final String token_vts = "9C1CDA30C0D5405682C40C0B00FED742";


  //
  // static Future<String> baseUrlProd() async {
  //   var servername  = GetDataServer.getServerName() as String;
  //   print('server name ${servername}');
  //   return servername;
  // }
  //
  // static final String baseUrlServlet =
  //     "http://${getServerName}/trucking/mobile/";

  // static final String baseUrlDEV = "http://101.255.157.162:8085/cemindo/mobile/";
  // static final String baseUrl = "http://101.255.157.162:8085/cemindo/mobile/";
  // static final String baseUrlOri = "http://101.255.157.162:8085/cemindo/";
  // static final String baseUrlProd = "http://101.255.157.162:8085/cemindo/mobile/";
  // static final String baseUrlServlet = "http://101.255.157.162:8085/cemindo/mobile/";

  static final String baseUrlAPIEASYGO = "http://tronsapi.easygo-gps.co.id/";
  static final String baseUrlAPICANVASE = "https://canvas.easygo-gps.co.id/";
  static String loginname = "";
  static String frmVhcid = "";
  static String frmDrvId = "";
  static String frmDrvName = "";
  static String frmUserId = "";
  static String frmLat = "0";
  static String frmLon = "0";
  static String frmGeoCodeAsal = "";
  static String frmGeoCodeTujuan = "";
  static String frmVhCKM = "0";
  static String frmLocid = "";
  static String frmDloDoNumber = "";
  static String frmBujDoNumber = "";
  static String responseMessage = "";
  static String servicetype = "";
  static String mcn_id1 = "";
  static String mcn_id2 = "";
  static String foreman_mcn_id = "";
  static String vehicle_mcn_id = "";
}
