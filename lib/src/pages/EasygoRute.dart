import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class RouteCheckList {
  final int responseCode;
  final String responseMessage;
  final int isTokenValid;
  final List<RouteChecks> data;

  RouteCheckList({
    this.responseCode = 0,
    this.responseMessage = "",
    this.isTokenValid = 0,
    this.data = const [],
  });

  factory RouteCheckList.fromJson(Map<String, dynamic> json) {
    try {
      var dataList = json["data"] as List;
      return RouteCheckList(
        responseCode: json["responseCode"] ?? 0,
        responseMessage: json["responseMessage"] ?? "",
        isTokenValid: json["isTokenValid"] ?? 0,
        data: dataList.map((x) => RouteChecks.fromJson(x)).toList(),
      );
    } catch (e) {
      print('Error in RouteCheckList.fromJson: $e');
      return RouteCheckList();
    }
  }
}

class RouteChecks {
  final int companyId;
  final String vehicleId;
  final String gpsSn;
  final String nopol;
  final double odometer;
  final double temperatur1;
  final double temperatur2;
  final String tempStatus;
  final String driverNm;
  final String carModel;
  final String carType;
  final double batteryPercent;
  final double mainPowerVoltage;
  final int routeId;
  final String routeNm;

  RouteChecks({
    this.companyId = 0,
    this.vehicleId = "",
    this.gpsSn = "",
    this.nopol = "",
    this.odometer = 0.0,
    this.temperatur1 = 0.0,
    this.temperatur2 = 0.0,
    this.tempStatus = "",
    this.driverNm = "",
    this.carModel = "",
    this.carType = "",
    this.batteryPercent = 0.0,
    this.mainPowerVoltage = 0.0,
    this.routeId = 0,
    this.routeNm = "",
  });

  factory RouteChecks.fromJson(Map<String, dynamic> json) {
    try {
      return RouteChecks(
        companyId: json["company_id"] ?? 0,
        vehicleId: json["vehicle_id"] ?? "",
        gpsSn: json["gps_sn"] ?? "",
        nopol: json["nopol"] ?? "",
        odometer: (json["odometer"] ?? 0.0).toDouble(),
        temperatur1: (json["temperatur1"] ?? 0.0).toDouble(),
        temperatur2: (json["temperatur2"] ?? 0.0).toDouble(),
        tempStatus: json["temp_status"] ?? "",
        driverNm: json["driver_nm"] ?? "",
        carModel: json["car_model"] ?? "",
        carType: json["car_type"] ?? "",
        batteryPercent: (json["battery_percent"] ?? 0.0).toDouble(),
        mainPowerVoltage: (json["main_power_voltage"] ?? 0.0).toDouble(),
        routeId: json["route_id"] ?? 0,
        routeNm: json["route_nm"] ?? "",
      );
    } catch (e) {
      print('Error in RouteChecks.fromJson: $e');
      return RouteChecks();
    }
  }
}

class EasygoRute extends StatefulWidget {
  @override
  _EasygoRuteState createState() => _EasygoRuteState();
}

class _EasygoRuteState extends State<EasygoRute> {
  Future<List<RouteChecks>> _getUnits() async {
    EasyLoading.show();
    var uri = "https://tmsmobileapi.easygo-gps.co.id/RouteChecker/data_route";

    var token =
        "eyJhbGciOiJBMTI4S1ciLCJlbmMiOiJBMTI4Q0JDLUhTMjU2IiwidHlwIjoiSldUIiwiY3R5IjoiSldUIn0.TD7l3KJZsDlr1r3TdbN-FYdmH9nF0Tz5Hk6NTFLLSZeoQETwUlZ2Ew.LLgAOkwCYo8xpEGvzOCONA.VrcnSr-WG-xkz-O7XwOX5yqMGEZC0Y_NKdUHdHpqY2KdSiRURizkSOd8HDA0S2NGmFn7MgoR0tU5LnBueOq_bCQBuXxn6pKojLIayYl8KF00CL6PXJvIjBTdVAnMgTKtguALq9OYKunYdmhSC7IgNn-VjW4G253I3fgiiHBwYyyrSdkV6cGwRPgkdTxylxujU83OGEdY-JEqDAkZJSLfT_2aPNZ1pg4j-XJKs4E66saB6c5wBWW1kHESkgI8fJDNLfTjeVKIh4xJRUmTvFZQnQ-NCYkl6Zq-OPNUpmWa8Hu_kNkRYQsD7ov7lg5dZSeTQwrOfvADPv6pYOiFByo_EUPa-ezZTpz5OUM5m_573swo3ZdZg1yz_GVn8BsLMT5eNB_l3x5pULsL4luZmqVaS2ivToIRO7NL2tnldbJ_Ds9Dd-6lzPn1cIj3SbnmBl8dFkWsBV61UVHysUlW-qcZT05F6V_hHlI-cu4tPHqW9H9QfajRgpvGMt75dZfm4zxr88S1k9tRYDdyAcM1BVVaFQ.oomGo1AIzYWQco8vDOG0JA";

    Map body = {"search_param": ""};

    var response = await http.post(Uri.parse(uri),
        headers: {
          "Content-Type": "application/json",
          "auth": token,
        },
        body: jsonEncode(body));

    var res = jsonDecode(response.body);

    print(res);

    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    var data = RouteCheckList.fromJson(res);
    if (data.responseCode == 0) {
      return List.empty();
    } else {
      return data.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Hello World")),
        body: const Center(
          child: Text(
            "Hello, World!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _getUnits();
    super.initState();
  }
}
