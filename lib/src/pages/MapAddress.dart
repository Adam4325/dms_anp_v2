import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:dms_anp/src/Color/color_constants.dart';
import 'package:dms_anp/src/pages/driver/RegistrasiNewDriver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:material_floating_search_bar/src/floating_search_bar.dart';
import 'package:dms_anp/src/component/map_pin_pill.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Helper/Provider.dart';
import 'ViewDashboard.dart';

/*
Title:GoogleMapScreen
Purpose:GoogleMapScreen
Created By:Kalpesh Khandla
*/

class MapAddress extends StatefulWidget {
  MapAddress({Key? key}) : super(key: key);

  @override
  MapAddressState createState() => MapAddressState();
}

class MapAddressState extends State<MapAddress> {
  final controller = FloatingSearchBarController();
  Completer<GoogleMapController> _controllerMaps = Completer();
  List<Marker> _markers = <Marker>[];
  var heigntValue = 0.0;
  late double height, width;
  int amountTxt = 390;
  String orderNo = "4578178";
  String restaurantName = "FoodiePie Restaurants";
  String addressTxt = "B-2024, Silver Corner, Ahmedabad";
  late GoogleMapController mapController;

  double _originLatitude = 23.0284, _originLongitude = 72.5068;

  double _destLatitude = 23.1013, _destLongitude = 72.5407;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints(apiKey: 'AIzaSyD2TFCSTdbRTmvblF1WYhGxfNMZtbseMQo');
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  String googleAPiKey = "AIzaSyD2TFCSTdbRTmvblF1WYhGxfNMZtbseMQo";
  String origin = "";
  String destination = "";
  String driver_nm = "";
  String vehicled_id = "";
  String info_windows = "";
  var isShowPanel = false;
  var gps_time = '';
  var engine_acc = '';

  List<dynamic> result_history = [];

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addPolyLine() {
    print(polylineCoordinates);
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      visible: true,
      color: ColorConstants.kBlueColor.withOpacity(0.5),
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;

    updateMarker(markerId);
  }

  updateMarker(id) async {
    Uri myUri = Uri.parse("http://maps.google.com/mapfiles/ms/micons/blue.png");
    Uri myUri2 =
        Uri.parse("http://maps.google.com/mapfiles/ms/micons/blue.png");
    var request = await http.get(myUri);
    var request2 = await http.get(myUri2);
    var bytes = request.bodyBytes;
    var bytes2 = request2.bodyBytes;
    var dataBytes;
    var dataBytes2;
    setState(() {
      dataBytes = bytes;
      dataBytes2 = bytes2;
    });
    final marker =
        markers.values.toList().firstWhere((item) => item.markerId == id);

    Marker _marker = Marker(
      markerId: marker.markerId,
      onTap: () {
        // print(marker.markerId);
        // print(marker.markerId.value);
        // if(marker.markerId.value=='origin'){
        //   print('origin');
        //   setState(() {
        //     info_windows=result_history!=null && result_history.length>0?result_history[0]['address']:origin;
        //   });
        // }else if(marker.markerId.value=='destination'){
        //   print('destination');
        //   setState(() {
        //     info_windows=result_history!=null && result_history.length>0?result_history[result_history.length-1]['address']:destination;
        //   });
        // }
        if (isShowPanel == false) {
          setState(() {
            isShowPanel = true;
          });
        } else {
          setState(() {
            isShowPanel = false;
          });
        }
      },
      position: LatLng(marker.position.latitude, marker.position.longitude),
      //icon: marker.icon,

      // icon: marker.markerId.value == 'origin' &&
      //    result_history != null? BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List()):BitmapDescriptor.fromBytes(dataBytes2.buffer.asUint8List()),
      infoWindow: InfoWindow(
          title: marker.markerId.value == 'origin' &&
                  result_history != null &&
                  result_history.length > 0
              ? "(Start)"
              : (marker.markerId.value == 'destination' &&
                      result_history != null &&
                      result_history.length > 0
                  ? "(Finish)".toString()
                  : 'No Address'),
          snippet: marker.markerId.value == 'origin' &&
                  result_history != null &&
                  result_history.length > 0
              ? "Address: " +
                  result_history[0]['address'].toString() +
                  "\n" +
                  ",GPS Time " +
                  result_history[0]['gps_time'].toString()
              : (marker.markerId.value == 'destination' &&
                      result_history != null &&
                      result_history.length > 0
                  ? "Address: " +
                      result_history[result_history.length - 1]['address'] +
                      "\n" +
                      ",GPS Time " +
                      result_history[result_history.length - 1]['gps_time']
                          .toString()
                          .toString()
                  : 'No Address')),
    );

    setState(() {
      //the marker is identified by the markerId and not with the index of the list
      markers[id] = _marker;
    });
    // mapController
    //   ..animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    //       target: LatLng(marker.position.latitude, marker.position.longitude),
    //       zoom: 11.0)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerUI = FloatingSearchBarController();
    isShowPanel = false;
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    controllerUI.dispose();
    super.dispose();
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("page_lat_lon", "");
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => RegisterNewDriver()));
  }

  int _searchVersion = 0;

  Future<String> GetDataArress(String query) async {
    var address = "";
    final q = query?.toString().trim() ?? "";
    if (q.isEmpty) {
      if (mounted) setState(() { dataAddress = []; _searchVersion++; });
      return "";
    }
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }
      var urlOSM = GlobalData.baseUrlOri + "api/osm_address.jsp?query=${Uri.encodeComponent(q)}";
      print("URL OSM ${urlOSM}");
      final response = await http.get(Uri.parse(urlOSM));
      print(response.body);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (mounted) {
          setState(() {
            dataAddress = decoded is List ? List.from(decoded) : [];
            _searchVersion++;
          });
        }
        address = "Success";
        print('JSON address ${dataAddress}');
      } else {
        if (mounted) setState(() { dataAddress = []; _searchVersion++; });
        address = "";
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch ($e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      if (mounted) setState(() { dataAddress = []; _searchVersion++; });
      address = "";
    }

    return address;
  }

  Future<String> GetDataArressByLatLon(String lat,String lon) async {
    var address = "";
    if (lat != null && lon != "") {
      try {
        var urlOSM =
            "https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&zoom=18&addressdetails=1";
        print("URL OSM ${urlOSM}");
        var encoded = Uri.encodeFull(urlOSM);
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        final response = await http.get(urlEncode, headers: {
          'User-Agent': 'DMS_ANP/1.0 (ANP Driver Management System)',
        });
        print(response.body);
        if (response.statusCode == 200) {
          address = json.decode(response.body)["display_name"];
        } else {
          address = "";
        }
      } catch ($e) {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        address = "";
      }
    }

    return address;
  }

  late FloatingSearchBarController controllerUI;
  Widget searchBarUI() {
    return Padding(
        padding: const EdgeInsets.only(top: 70.0),
        child: FloatingSearchBar(
          controller: controllerUI,
          hint: 'Search.....',
          openAxisAlignment: 0.0,
          openWidth: 600,
          axisAlignment: 0.0,
          scrollPadding: EdgeInsets.only(top: 16, bottom: 20),
          elevation: 4.0,
          physics: BouncingScrollPhysics(),
          onQueryChanged: (query) async {
            //Your methods will be here
            print('search data address');
            await GetDataArress(query);
            //controllerUI.close();
          },
          //showDrawerHamburger: false,
          transitionCurve: Curves.easeInOut,
          transitionDuration: Duration(milliseconds: 500),
          transition: CircularFloatingSearchBarTransition(),
          debounceDelay: Duration(milliseconds: 500),
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                icon: Icon(Icons.location_on),
                onPressed: () {
                  setState(() {
                    print("klic");
                    controllerUI.close();
                  });
                },
              ),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          builder: (context, transition) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Material(
                color: Colors.white,
                child: _buildListViewAddress(context),
              ),
            );
          },
        ));
  }

  List dataAddress = [];
  Widget _buildListViewAddress(BuildContext ctx) {
    return Container(
        height: 350,
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            key: ValueKey(_searchVersion),
            scrollDirection: Axis.vertical,
            padding:
                const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
            itemCount: dataAddress == null ? 0 : dataAddress.length,
            itemBuilder: (context, index) {
              return _builListAddress(ctx, dataAddress[index], index);
            }));
  }

  Widget _builListAddress(BuildContext ctx, dynamic item, int index) {
    return InkWell(
        onTap: () async {
          controllerUI.close();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print(item["lat"]);
          print(item["lon"]);
          prefs.setString("lat_lon", '${item["lat"]},${item["lon"]}');
          print("View Markers");
          Marker? marker;

          try {
            marker = _markers.firstWhere(
                  (marker) => marker.markerId.value == "SomeId",
            );
          } catch (e) {
            marker = null;
          }

          setState(() {
            _markers.remove(marker);
          });
          _markers.add(Marker(
              markerId: MarkerId('SomeId'),
              draggable: true,
              onDragEnd: ((newPosition) async{
                print(newPosition.latitude);
                print(newPosition.longitude);
                prefs.setString("lat_lon", '${newPosition.latitude},${newPosition.longitude}');
                var addr = await GetDataArressByLatLon(
                    '${newPosition.latitude}', '${newPosition.longitude}');
                setState(() {
                  item["display_name"] = addr;
                });
              }),
              position:
                  LatLng(double.parse(item["lat"]), double.parse(item["lon"])),
              infoWindow: InfoWindow(title: item["display_name"])));
          CameraPosition cPosition = CameraPosition(
            zoom: 9,
            tilt: 0,
            bearing: 30,
            target:
                LatLng(double.parse(item["lat"]), double.parse(item["lon"])),
          );
          final GoogleMapController controllerMaps = await mapController;
          mapController
              .animateCamera(CameraUpdate.newCameraPosition(cPosition));
          controllerUI.close();
          //Navigator.of(ctx).pop(false);
        },
        child: Card(
            child: ListTile(
                title: Text('${item["name"]}'),
                subtitle: Text('${item["display_name"]}'),
                trailing: Icon(Icons.arrow_right))));
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => RegisterNewDriver()));
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-6.181866111111, 106.829632777778),
                    zoom: 12,
                  ),
                  mapType: MapType.normal,
                  markers: Set<Marker>.of(_markers),
                  myLocationEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: _onMapCreated,
                  //markers: Set<Marker>.of(markers.values),
                  // onMapCreated: (GoogleMapController controller) {
                  //   _controller.complete(controller);
                  // },
                  //polylines: Set<Polyline>.of(polylines.values),
                ),
                searchBarUI(),
                GestureDetector(
                  onTap: () {
                    _goBack(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 15,
                    ),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: ColorConstants.kWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: ColorConstants.kBlackColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
