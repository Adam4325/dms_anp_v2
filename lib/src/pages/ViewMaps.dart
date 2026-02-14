import 'dart:async';
import 'dart:convert';
import 'package:dms_anp/src/model/PinInformation.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locator;
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/component/map_pin_pill.dart';
import 'dart:ui' as ui;
import '../flusbar.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(-6.181866111111, 106.829632777778);
const LatLng DEST_LOCATION = LatLng(-6.181866111111, 106.829632777778);

//https://canvas.easygo-gps.co.id/MasterData/GetListSn?token=YW5kYWxhbnwxMjM0NQ==
class ViewMaps extends StatefulWidget {
  @override
  ViewMapsState createState() => ViewMapsState();
}

class ViewMapsState extends State<ViewMaps> {
  final controller = FloatingSearchBarController();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  double pinPillPosition = -170;
  List dataVehicle = [];
  List dataVehicleTemp = [];

  late Timer _timer;
  int speed = 0;
  double lat = 0;
  double lon = 0;
  int acc = 0;
  String direction = "0";
  List<Marker> _markers = <Marker>[];
  //Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  final _cnSearch = TextEditingController();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(-6.181866111111, 106.829632777778),
      locationName: '',
      labelColor: Colors.grey);
  late PinInformation sourcePinInfo;
  late PinInformation destinationPinInfo;


  void getShareDateSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lat = double.parse(prefs.getString("view_lat")!);
      lon = double.parse(prefs.getString("view_lon")!);
    });

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(lat, lon),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  getAddressFromLatLng(context, double lat, double lng) async {
    var mapApiKey="AIzaSyD2TFCSTdbRTmvblF1WYhGxfNMZtbseMQo";
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url = '$_host?key=$mapApiKey&language=en&latlng=$lat,$lng';
    if(lat != null && lng != null){
      var response = await http.get(Uri.parse(url));
      if(response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        String _formattedAddress = data["results"][0]["formatted_address"];
        print("response ==== $_formattedAddress");
        return _formattedAddress;
      } else return null;
    } else return null;
  }
  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.getString("pages_back");
    });
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ViewDashboard()));
    return Future.value(false);
  }

  late FloatingSearchBarController controllerUI;
  @override
  void initState() {
    getShareDateSession();

    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    print('widget ${lat} ${lon}');
    CameraPosition initialCameraPosition;
    initialCameraPosition = CameraPosition(
        zoom: 14,
        target: LatLng(-6.2293796, 106.6647034) //SOURCE_LOCATION
    );

    return new WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              color: Colors.black,
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            elevation: 0.0,
            centerTitle: true,
            title: Text('View Maps', style: TextStyle(color: Colors.black))),
        body: Stack(
          key: globalScaffoldKey,
          clipBehavior: Clip.none,
          //fit: StackFit.expand,
          children: [
            GoogleMap(
              mapToolbarEnabled: true,
              buildingsEnabled: true,
              myLocationEnabled: true,
              //trafficEnabled: true,
              //compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: markers.values.toSet(),
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: onMapCreated,
              onTap: (LatLng location) {
                setState(() {
                  pinPillPosition = -170;
                });
              },
            )
          ],
        ),
      ),
    );
  }
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};


  void onMapCreated(GoogleMapController controller) async {
    //controller.setMapStyle(Utils.mapStyles);
    print('map created ${lat} ${lon}');


    _controller.complete(controller);
    //_getLocation();
    final marker = Marker(
      markerId: MarkerId('place_name'),
      position: LatLng(lat, lon),
      // icon: BitmapDescriptor.,
      // infoWindow: InfoWindow(
      //   title: 'Information',
      //   snippet: 'address\n alamat',
      // ),
    );

    setState(() {
      markers[MarkerId('place_name')] = marker;
    });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}

