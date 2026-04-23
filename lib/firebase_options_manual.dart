import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Manual Firebase options sourced from `android/app/google-services.json`.
class ManualFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Manual Firebase options for web are not set.');
    }
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCWlmD6-quQ5iiSOUFCF8SuvDk9lXHkE0',
    appId: '1:7501757339:android:c32d130bc51204577e3f3e',
    messagingSenderId: '7501757339',
    projectId: 'notif-driver',
    storageBucket: 'notif-driver.firebasestorage.app',
  );
}

