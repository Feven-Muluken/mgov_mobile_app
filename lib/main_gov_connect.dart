import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'features/gov_connect/gov_connect_app.dart';
import 'core/config/firebase_initializer.dart';
import 'modules/notifications/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Load what the first screen needs. Never let a failure here leave a blank screen.
  String? user;
  bool hasSeenOnboarding = false;
  try {
    await Hive.initFlutter();
    user = await getFromLocalStorage('user_data');
    var settingsBox = await Hive.openBox('settings');
    hasSeenOnboarding = settingsBox.get('hasSeenOnboarding', defaultValue: false) ?? false;
  } catch (e) {
    debugPrint('Startup storage error: $e');
  }

  // Show the UI first.
  runApp(GovConnectApp(hasSeenOnboarding: hasSeenOnboarding, user: user));

  // Firebase and notifications start afterwards and can fail without breaking the app.
  _startFirebaseServices();
}

Future<void> _startFirebaseServices() async {
  try {
    await FirebaseInitializer.initialize();
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase is not initialized; notifications are disabled.');
      return;
    }
    await NotificationService.initialize();
    //_printToken();
    // Already logged in from a previous session: make sure the backend has this phone's token.
    await NotificationService.registerTokenWithBackend();
    await _storeToken();
  } catch (e) {
    debugPrint('Firebase/notification setup failed: $e');
  }
}

Future<void> _printToken() async {
  final token = await NotificationService.getDeviceToken();
  if (kDebugMode) {
    print('🔥 FCM Token: $token');
  }
}

Future<void> _storeToken() async {
  final token = await NotificationService.getDeviceToken();
  if (kDebugMode) {
    print('🔥 FCM Token: $token');
  }

  if (token != null) {
    await _storeTokenInDatabase(token); // Call the new storage function
  }
}

// Helper function to get a stable unique ID for the device.
Future<String?> _getDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? rawDeviceId;

  if (Platform.isAndroid) {
    // Android ID
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    rawDeviceId = androidInfo.id;
    //return androidInfo.id;
  } else if (Platform.isIOS) {
    // iOS Identifier for Vendor (IDFV)
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    //return iosInfo.identifierForVendor;
    rawDeviceId = iosInfo.identifierForVendor;
  } else {
    // For web/desktop/other platforms, you'll need another unique identifier
    // or you can just use a constant for now if these aren't priority targets.
    if (kDebugMode) {
      print('Unsupported platform for device ID');
    }
    return null;
  }

  // 💡 NEW STEP: Sanitize the rawDeviceId
  if (rawDeviceId != null) {
    // Replace dots and other potentially illegal characters with a safe character (e.g., a hyphen).
    // Firebase prohibits '.', '#', '$', '[', and ']'.
    final sanitizedDeviceId = rawDeviceId.replaceAll('.', '-').replaceAll('#', '-').replaceAll('\$', '-').replaceAll('[', '-').replaceAll(']', '-');
    
    if (kDebugMode) {
        print('Raw Device ID: $rawDeviceId');
        print('Sanitized Device ID: $sanitizedDeviceId');
    }
    
    return sanitizedDeviceId;
  }
  
  return null;
}

Future<void> _storeTokenInDatabase(String token) async {
  try {
    // 1. Get the unique Device ID instead of the User ID.
    final deviceId = await _getDeviceId();

    if (deviceId != null) {
      // 2. Set the database reference path to use the deviceId.
      // The new path will be: fcm_tokens_no_auth/<deviceId>
      // We use a different top-level node (e.g., 'fcm_tokens_no_auth') 
      // to keep it separate from authenticated users.
      final dbRef = FirebaseDatabase.instance.ref('fcm_tokens_no_auth/$deviceId');

      // 3. Store the token, overwriting the previous one for this device.
      // This is generally better for non-authenticated tokens.
      await dbRef.set({
        'token': token,
        'lastUpdated': ServerValue.timestamp, // Use server timestamp for freshness
        'platform': Platform.operatingSystem, // Helpful for management
      });
      
      if (kDebugMode) {
        print('✅ FCM Token stored successfully for Device ID: $deviceId');
      }
    } else {
      // Handle the case where a stable Device ID couldn't be retrieved.
      if (kDebugMode) {
        print('⚠️ Could not retrieve a stable Device ID. Cannot store token.');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error storing FCM token in Realtime Database: $e');
    }
  }
}

// Future<void> _storeTokenInDatabase(String token) async {
//   try {
//     // 1. Get the current authenticated user's ID
//     final user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       final userId = user.uid;
//       final dbRef = FirebaseDatabase.instance.ref('users/$userId/tokens');

//       // 2. Store the token, typically along with a timestamp for management
//       // Using an array-like structure in a Realtime Database for multiple tokens per user
//       // or set() to store a map if you only expect one active token per user/device
//       await dbRef.child(token).set({
//         'token': token,
//         'timestamp': ServerValue.timestamp, // Use server timestamp for freshness
//       });
      
//       if (kDebugMode) {
//         print('✅ FCM Token stored successfully for user $userId');
//       }
//     } else {
//       // Handle the case where the user is not logged in yet
//       if (kDebugMode) {
//         print('⚠️ User not logged in. Cannot store token yet.');
//         // Consider moving token storage to a point after user login/registration.
//       }
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print('❌ Error storing FCM token in Realtime Database: $e');
//     }
//   }
// }

