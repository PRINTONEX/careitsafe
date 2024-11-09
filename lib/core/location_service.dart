// lib/core/services/location_service.dart

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
      // If location data is null, get the latest location data
      locationData ??= await _location.getLocation();

      if (locationData != null) {
        await FirebaseManager.syncLocationData({
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("Error syncing location: $e");
    }
  }
}
