
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmRequestAttendance.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';

// Constants
class AttendanceConstants {
  static const String noImageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  static const int defaultGeoId = 99999;
  static const int headOfficeGeoId = 23;
}

// Data Models
class AttendanceInfo {
  String timeIn = "";
  String timeOut = "";
  String duration = "";
  String date = "";
  String locationName = "";

  AttendanceInfo({
    this.timeIn = "",
    this.timeOut = "",
    this.duration = "",
    this.date = "",
    this.locationName = "",
  });

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      timeIn: json['logtimein'] ?? "",
      timeOut: json['logtimeout'] ?? "",
      duration: json['duration'] ?? "",
      date: json['logdate'] ?? "",
      locationName: json['location_name'] ?? "",
    );
  }
}

class GeofenceArea {
  int geoId;
  String name;
  double latitude;
  double longitude;
  double radius;

  GeofenceArea({
    this.geoId = 0,
    this.name = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.radius = 0.0,
  });

  factory GeofenceArea.fromJson(Map<String, dynamic> json) {
    return GeofenceArea(
      geoId: int.tryParse(json['geo_id'].toString()) ?? 0,
      name: json['name'] ?? "",
      latitude: double.tryParse(json['lat'].toString()) ?? 0.0,
      longitude: double.tryParse(json['lon'].toString()) ?? 0.0,
      radius: double.tryParse(json['radius'].toString()) ?? 0.0,
    );
  }
}

class FrmAttendanceDriver extends StatefulWidget {
  @override
  FrmAttendanceDriverState createState() => FrmAttendanceDriverState();
}

class FrmAttendanceDriverState extends State<FrmAttendanceDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Data
  String androidID = "";
  String namaKaryawan = "";
  String address = "";
  Position? userLocation;
  List<GeofenceArea> geofenceAreas = [];
  AttendanceInfo attendanceInfo = AttendanceInfo();

  // Photo
  File? photoFile;
  String photoBase64 = "";
  Uint8List? photoBytes;
  final ImagePicker _picker = ImagePicker();

  // Location
  bool isMockLocation = true;
  String trustLatitude = "0.0";
  String trustLongitude = "0.0";

  // Dropdown
  String selectedShift = 'no shift';
  List<String> shiftOptions = ['no shift', 'shift'];

  // Controllers
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (EasyLoading.isShow) EasyLoading.dismiss();

    await _loadUserSession();
    await _loadStoredPhoto();
    await _getCurrentLocation();
    await _loadGeofenceAreas();
    await _loadTodayAttendance();
  }

  Future<void> _loadUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaKaryawan = prefs.getString("name") ?? "";
      androidID = prefs.getString("androidID") ?? "";
    });
  }

  Future<void> _loadStoredPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedPhoto = prefs.getString("photoProfile") ?? "";

    if (storedPhoto.isNotEmpty) {
      setState(() {
        photoBase64 = storedPhoto;
        photoBytes = Base64Decoder().convert(storedPhoto);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      isMockLocation = await TrustLocation.isMockLocation;
      TrustLocation.start(5);

      TrustLocation.onChange.listen((values) {
        trustLatitude = values.latitude.toString();
        trustLongitude = values.longitude.toString();
      });

      TrustLocation.stop();

      setState(() {
        userLocation = position;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _loadGeofenceAreas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String driverId = prefs.getString("drvid") ?? "";

      if (driverId.isEmpty) {
        _showError("Driver ID not found");
        return;
      }

      String url = "${GlobalData.baseUrlOri}mobile/api/absensi/create_geofence_area_driver.jsp"
          "?method=list-geofence-area-v1&drvid=$driverId";

      final response = await http.get(
          Uri.parse(url),
          headers: {"Accept": "application/json"}
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          geofenceAreas = jsonList.map((json) => GeofenceArea.fromJson(json)).toList();
        });
        print("Loaded ${geofenceAreas.length} geofence areas");
      } else {
        _showError("Failed to load geofence areas: ${response.statusCode}");
      }
    } on TimeoutException {
      _showError("Request timeout. Please check your internet connection.");
    } catch (e) {
      _showError("Error loading geofence areas: $e");
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      if (androidID.isEmpty) {
        print("Android ID is empty, skipping attendance load");
        return;
      }

      String url = "${GlobalData.baseUrlOri}mobile/api/absensi/get_info_absensi.jsp"
          "?method=list-info-absensi&imeiid=$androidID";

      final response = await http.get(
          Uri.parse(url),
          headers: {"Accept": "application/json"}
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isNotEmpty && jsonList[0]['logdate'] != null) {
          setState(() {
            attendanceInfo = AttendanceInfo.fromJson(jsonList[0]);
            addressController.text = attendanceInfo.locationName;
          });
          print("Loaded today's attendance: ${attendanceInfo.date}");
        } else {
          print("No attendance data found for today");
        }
      } else {
        _showError("Failed to load attendance info: ${response.statusCode}");
      }
    } on TimeoutException {
      _showError("Request timeout. Please check your internet connection.");
    } catch (e) {
      _showError("Error loading attendance info: $e");
    }
  }

  // Network connectivity check
  Future<bool> _checkConnectivity() async {
    try {
      final response = await http.get(
          Uri.parse('https://www.google.com'),
          headers: {"Accept": "application/json"}
      ).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Enhanced error handling with retry options
  void _showErrorWithRetry(String message, VoidCallback retryAction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              retryAction();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Distance calculation utility
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth radius in meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        List<int> imageBytes = imageFile.readAsBytesSync();
        String base64Image = base64Encode(imageBytes);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("photoProfile", base64Image);

        setState(() {
          photoFile = imageFile;
          photoBase64 = base64Image;
        });
      }
    } catch (e) {
      _showError("Error picking image: $e");
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        content: Text('Choose image source for your photo'),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              "Camera",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C69),
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_library, color: Colors.white),
            label: Text(
              "Gallery",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C69),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      String url = "https://nominatim.openstreetmap.org/reverse"
          "?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1";

      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'DMS_ANP/1.0 (ANP Driver Management System)',
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data["display_name"] ?? "";
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return "";
  }

  Future<void> _processAttendance(String type) async {
    // Show loading
    EasyLoading.show(status: 'Getting location...');

    try {
      if (userLocation == null) {
        await _getCurrentLocation();
        if (userLocation == null) {
          _showError("Unable to get current location. Please check GPS settings.");
          return;
        }
      }

      GeofenceArea selectedGeofence = _findNearestGeofence();
      String address = "";

      if (selectedGeofence.geoId == 0) {
        EasyLoading.show(status: 'Getting address...');
        address = await _getAddressFromCoordinates(
            userLocation!.latitude,
            userLocation!.longitude
        );
        addressController.text = address;

        if (geofenceAreas.isNotEmpty) {
          _showError("You are outside the geofence area");
          return;
        }
      } else {
        addressController.text = selectedGeofence.name;
      }

      _showAttendanceConfirmation(type, selectedGeofence, address);
    } catch (e) {
      _showError("Error processing attendance: $e");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  GeofenceArea _findNearestGeofence() {
    if (geofenceAreas.isEmpty || userLocation == null) {
      return GeofenceArea();
    }

    GeofenceArea nearestGeofence = GeofenceArea();
    double shortestDistance = double.infinity;

    for (GeofenceArea geo in geofenceAreas) {
      num distance = SphericalUtil.computeDistanceBetween(
        LatLng(geo.latitude, geo.longitude),
        LatLng(userLocation!.latitude, userLocation!.longitude),
      );

      // Special handling for default geofence
      if (geo.geoId == AttendanceConstants.defaultGeoId) {
        return geo;
      }

      if (distance <= geo.radius && geo.radius < shortestDistance) {
        shortestDistance = geo.radius;
        nearestGeofence = geo;
      }
    }

    return nearestGeofence;
  }

  void _showAttendanceConfirmation(String type, GeofenceArea geofence, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text("Proceed with ${type.toUpperCase()} attendance?"),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.close, color: Colors.white),
            label: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.check, color: Colors.white),
            label: Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              _submitAttendance(type, geofence, address);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C69),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAttendance(String type, GeofenceArea geofence, String address) async {
    // Show loading
    EasyLoading.show(status: 'Submitting attendance...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("name") ?? "";

      // Validation
      if (!_validateAttendanceData(userId)) {
        return;
      }

      String url = "${GlobalData.baseUrlOri}mobile/api/absensi/check_in_out_geofence_driver.jsp";

      Map<String, String> data = {
        'method': type == "IN" ? "checkin-attendance-v3" : "checkout-attendance-v3",
        'imeiid': androidID,
        'shift': selectedShift,
        'geo_id': geofence.geoId.toString(),
        'geo_nm': geofence.name,
        'is_mock': isMockLocation ? '1' : '0',
        'employeeid': "",
        'lat': userLocation!.latitude.toString(),
        'lon': userLocation!.longitude.toString(),
        'truslat': trustLatitude,
        'truslon': trustLongitude,
        'address': address,
        'userid': userId.toUpperCase(),
        'company': 'AN'
      };

      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        encoding: Encoding.getByName('utf-8'),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        _handleAttendanceResponse(result);
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } on TimeoutException {
      _showError("Request timeout. Please check your internet connection.");
    } catch (e) {
      _showError("Error submitting attendance: $e");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  bool _validateAttendanceData(String userId) {
    if (androidID.isEmpty) {
      _showError("IMEI ID is empty, contact Administrator");
      return false;
    }

    if (userId.isEmpty) {
      _showError("User ID cannot be empty");
      return false;
    }

    if (userLocation == null) {
      _showError("Location data is not available");
      return false;
    }

    return true;
  }

  // Utility function to format time
  String _formatTime(String time) {
    if (time.isEmpty) return "-";
    try {
      // Format time if needed
      return time;
    } catch (e) {
      return time;
    }
  }

  // Utility function to format date
  String _formatDate(String date) {
    if (date.isEmpty) return "-";
    try {
      // Format date if needed
      return date;
    } catch (e) {
      return date;
    }
  }

  void _handleAttendanceResponse(Map<String, dynamic> result) {
    int statusCode = result["status_code"] ?? 100;
    String message = result["message"] ?? "Unknown error";

    if (statusCode == 200) {
      setState(() {
        attendanceInfo.date = result["tgl_absen"] ?? "";
        attendanceInfo.duration = result["duration"] ?? "";
        attendanceInfo.timeIn = result["timein"] ?? "";
        attendanceInfo.timeOut = result["timeout"] ?? "";
      });
      _showSuccess(message);
    } else if (statusCode == 304) {
      setState(() {
        attendanceInfo.date = result["tgl_absen"] ?? "";
      });
      _showWarning(message);
    } else {
      _showError(message);
    }
  }

  void _showSuccess(String message) {
    alert(context, 1, message, "success");
  }

  void _showWarning(String message) {
    alert(context, 2, message, "warning");
  }

  void _showError(String message) {
    alert(context, 0, message, "error");
  }

  void _shareImeiLink() {
    Share.share(
        'https://apps.tuluatas.com/trucking/master/update_imei_driver.jsp?imeiid=$androidID'
    );
  }

  void _navigateToRequestAttendance() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FrmRequestAttendance()),
    );
  }

  void _navigateBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFFFF4E6), // soft orange background
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF8C69), // soft orange appBar
          title: Text('Driver Attendance'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          color: HexColor("#f0eff4"),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadTodayAttendance();
    await _loadGeofenceAreas();
    await _getCurrentLocation();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPhotoSection(),
          SizedBox(height: 20),
          _buildInfoSection(),
          SizedBox(height: 20),
          _buildAttendanceSection(),
          SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Photo Profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: _buildPhotoWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWidget() {
    if (photoFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          photoFile!,
          width: 180,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (photoBase64.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          photoBytes!,
          width: 180,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 50, color: Colors.grey.shade600),
            SizedBox(height: 8),
            Text("Tap to add photo", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Attendance Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoItem("Employee Name", namaKaryawan),
            SizedBox(height: 8),
            _buildInfoItem("Location", addressController.text),
            SizedBox(height: 8),
            _buildInfoItem("Date", _formatDate(attendanceInfo.date)),
            SizedBox(height: 8),
            _buildInfoItem("Time IN", _formatTime(attendanceInfo.timeIn)),
            SizedBox(height: 8),
            _buildInfoItem("Time OUT", _formatTime(attendanceInfo.timeOut)),
            SizedBox(height: 8),
            _buildInfoItem("Duration", attendanceInfo.duration),
            SizedBox(height: 16),
            _buildLocationAccuracy(),
            SizedBox(height: 16),
            _buildShiftDropdown(),
            SizedBox(height: 16),
            _buildImeiSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAccuracy() {
    if (userLocation == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              "Location not available",
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                "Location Available",
                style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Lat: ${userLocation?.latitude.toStringAsFixed(6)}, Lng: ${userLocation?.longitude.toStringAsFixed(6)}",
            style: TextStyle(color: Colors.green.shade600, fontSize: 11),
          ),
          if (userLocation?.accuracy != null)
            Text(
              "Accuracy: ${userLocation?.accuracy.toStringAsFixed(1)}m",
              style: TextStyle(color: Colors.green.shade600, fontSize: 11),
            ),
          if (isMockLocation)
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Mock Location Detected",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    bool canCheckIn =true;// attendanceInfo.timeIn.isEmpty;
    bool canCheckOut =true;// attendanceInfo.timeIn.isNotEmpty && attendanceInfo.timeOut.isEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Attendance Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text(
                      "Check IN",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed:
                        canCheckIn ? () => _processAttendance("IN") : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canCheckIn ? const Color(0xFF4CAF50) : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      "Check OUT",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed:
                        canCheckOut ? () => _processAttendance("OUT") : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canCheckOut ? const Color(0xFFFF8C69) : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildAttendanceStatus(canCheckIn, canCheckOut),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatus(bool canCheckIn, bool canCheckOut) {
    String statusText = "";
    Color statusColor = Colors.grey;

    if (canCheckIn) {
      statusText = "Ready to Check IN";
      statusColor = Colors.green;
    } else if (canCheckOut) {
      statusText = "Ready to Check OUT";
      statusColor = Colors.orange;
    } else {
      statusText = "Attendance completed for today";
      statusColor = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          child: Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildShiftDropdown() {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            "Shift:",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: selectedShift,
            icon: Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
            items: shiftOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedShift = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImeiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "IMEI ID:",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: _shareImeiLink,
          child: Text(
            androidID.isEmpty ? "-" : androidID,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Additional Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.create, color: Colors.white),
                label: const Text(
                  "Request Attendance",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _navigateToRequestAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C69),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}