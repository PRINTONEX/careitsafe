// lib/core/services/location_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

import 'firebase_manager.dart';

class LocationService {
  static final Location _location = Location();

  static Future<void> startLocationTracking() async {
    // Check if location services are enabled
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }
    }

    // Check for permission
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus != PermissionStatus.granted) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        print("Location permission denied.");
        return;
      }
    }

    // Start listening to location changes
    _location.onLocationChanged.listen((LocationData currentLocation) {
      syncLocation(currentLocation);
    });
  }
  static Future<void> syncLocation([LocationData? locationData]) async {
    try {
      locationData ??= await _location.getLocation();
      if (locationData != null) {
        await FirebaseManager.syncLocationData({
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e, stackTrace) {
      print("Error syncing location: $e");
      await logError('LocationSync', e.toString(), stackTrace);

      // Retry after 5 seconds
      await Future.delayed(Duration(seconds: 5));
      await syncLocation(locationData);
    }
  }
  static Future<void> logError(String functionName, String errorMessage, [StackTrace? stackTrace]) async {
    try {
      await FirebaseFirestore.instance.collection('error_logs').add({
        'function': functionName,
        'error': errorMessage,
        'stackTrace': stackTrace?.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error logging error: $e");
    }
  }



}
