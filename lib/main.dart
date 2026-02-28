import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/model/NotificationData.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
import 'package:dms_anp/src/services/NotificationServices.dart';
import 'package:dms_anp/src/services/PermissionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/database_helper.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  await DatabaseHelper.instance.database;
  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DMS ANP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ⭐ GUNAKAN NOTIFICATION SERVICE YANG SUDAH DIPERBAIKI
  final NotificationService _notificationService = NotificationService();
  List<NotificationData> _notifications = [];//
  bool _isLoading = true;//

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: MyHomePage initState called');//

    // Delay sedikit untuk memastikan context siap
    Future.delayed(Duration(milliseconds: 100), () {//
      _requestPermissions();
    });
  }

  // ⭐ REQUEST PERMISSIONS DULU
  void _requestPermissions() async {
    print('🔍 DEBUG: Requesting permissions...');

    try {
      // Request notification permission
      bool notifPermission =
          await PermissionService.requestNotificationPermission();

      // Request system alert window permission (untuk overlay)
      bool overlayPermission =
          await PermissionService.requestSystemAlertWindowPermission();

      print('🔍 DEBUG: Notification Permission: $notifPermission');
      print('🔍 DEBUG: Overlay Permission: $overlayPermission');

      // Lanjutkan ke login check
      _checkLoginStatus();
    } catch (e) {
      print('❌ ERROR: Exception in _requestPermissions: $e');
      // Tetap lanjutkan meskipun permission error
      _checkLoginStatus();
    }
  }

  // ⭐ CHECK LOGIN STATUS
  void _checkLoginStatus() async {
    print('🔍 DEBUG: Checking login status...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      GlobalData.frmDrvId = prefs.getString('drvid') ?? '';
      GlobalData.loginname = prefs.getString('loginname') ?? '';

      print('🔍 DEBUG: drvid: ${GlobalData.frmDrvId}');
      print('🔍 DEBUG: loginname: ${GlobalData.loginname}');

      if (GlobalData.frmDrvId == null || GlobalData.frmDrvId.isEmpty) {
        print('🔍 DEBUG: No login data, redirecting to LoginPage');
        _navigateToLogin();
      } else {
        print('🔍 DEBUG: Login data found, setting up notifications...');
        _setupNotifications();
        _navigateToMainApp();
      }
    } catch (e) {
      print('❌ ERROR: Exception in _checkLoginStatus: $e');
      _navigateToLogin();
    }
  }

  // ⭐ SETUP NOTIFICATION SERVICE/
  void _setupNotifications() {
    print('🔍 DEBUG: Setting up notification service...');

    // Start timer untuk check API setiap 30 detik (10 detik untuk testing)
    _notificationService.startNotificationTimer(intervalSeconds: 10);

    // Listen untuk notifikasi baru
    _notificationService.notificationStream.listen((notifications) {
      print('🔍 DEBUG: Received ${notifications.length} notifications in main');

      setState(() {
        _notifications = notifications;
      });

      // Tampilkan notifikasi sebagai dialog untuk testing
      if (notifications.isNotEmpty) {
        _showNotificationDialog(notifications.first);
      }
    });

    // Test dengan dummy data setelah 5 detik
    Future.delayed(Duration(seconds: 5), () {
      print('🔍 DEBUG: Adding dummy notification for testing...');
      //_notificationService.addDummyNotification();
    });
  }

  // ⭐ SHOW NOTIFICATION DIALOG (UNTUK TESTING)
  void _showNotificationDialog(NotificationData notification) {
    print('🔍 DEBUG: Showing notification dialog for: ${notification.title}');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications, color: Colors.blue),
              SizedBox(width: 8),
              Text('Notifikasi Baru'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title ?? 'Tidak ada judul',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(notification.message ?? 'Tidak ada pesan'),
              SizedBox(height: 8),
              Text(
                'ID: ${notification.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Driver ID: ${notification.drvid}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleNotificationTap(notification);
              },
              child: Text('Balas'),
            ),
          ],
        );
      },
    );
  }

  // ⭐ HANDLE NOTIFICATION TAP
  void _handleNotificationTap(NotificationData notification) async {
    print('🔍 DEBUG: Handling notification tap for: ${notification.id}');

    try {
      // Kirim response ke API
      await _notificationService.sendNotificationResponse(notification);

      // Hapus notifikasi dari list
      _notificationService.removeNotification(notification.id);

      print('✅ SUCCESS: Notification handled successfully');
    } catch (e) {
      print('❌ ERROR: Exception in _handleNotificationTap: $e');
    }
  }

  // ⭐ NAVIGATE TO LOGIN
  void _navigateToLogin() {
    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  // ⭐ NAVIGATE TO MAIN APP
  void _navigateToMainApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = false;
    });
    var isForeman = prefs.getString('isMenuForeman');
    if (GlobalData.loginname == "MECHANIC" && isForeman == "0") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewListWoMCN()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau Icon
            // Icon(
            //   Icons.notifications,
            //   size: 80,
            //   color: Colors.blue,
            // ),
            SizedBox(height: 20),

            // Loading indicator
            if (_isLoading) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Memuat...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // SizedBox(height: 10),
              // Text(
              //   'Menginisialisasi layanan notifikasi',
              //   style: TextStyle(fontSize: 14, color: Colors.grey),
              // ),
            ],

            // Debug info
            // if (!_isLoading) ...[
            //   Text(
            //     'Debug Info:',
            //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //   ),
            //   SizedBox(height: 10),
            //   Text('Notifications: ${_notifications.length}'),
            //   Text('Driver ID: ${GlobalData.frmDrvId ?? 'None'}'),
            //   Text('Login Name: ${GlobalData.loginname ?? 'None'}'),
            //
            //   SizedBox(height: 20),
            //   ElevatedButton(
            //     onPressed: () {
            //       //_notificationService.addDummyNotification();
            //     },
            //     child: Text('Test Notification'),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🔍 DEBUG: MyHomePage dispose called');
    _notificationService.dispose();
    super.dispose();
  }
}
