import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../const/user.dart';
import 'firebase_manager.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStreamSubscription;

  // Method to start location tracking
  static Future<void> startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Request permission if needed
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print("Location permission denied.");
        return;
      }
    }

    // Start listening to location updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,  // Updates every 10 meters
      ),
    ).listen((Position currentLocation) {
      syncLocation(currentLocation);
    });
  }

  // Method to stop location tracking
  static void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    print("Location tracking stopped.");
  }

  static Future<void> syncLocation(Position locationData) async {
    try {
      // Delay to ensure service is ready
      await Future.delayed(Duration(seconds: 10));

      if (locationData.latitude != null && locationData.longitude != null) {
        await FirebaseManager.syncLocationData({
          'userId': userId,
          'speed': locationData.speed,
          'heading': locationData.heading,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
        print("Lat: ${locationData.latitude}, Lon: ${locationData.longitude}");
      }
    } catch (e) {
      print("Error syncing location: $e");
    }
  }
}
