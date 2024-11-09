// lib/core/services/sms_service.dart

import 'package:careitsafe/core/firebase_manager.dart';

class SmsService {
  static Future<void> syncSmsLogs() async {
    try {
      // Placeholder SMS data
      List<Map<String, dynamic>> smsLogs = [
        {'number': '0987654321', 'message': 'Hello!', 'timestamp': DateTime.now().toIso8601String()},
      ];

      for (var smsLog in smsLogs) {
        await FirebaseManager.syncSmsData(smsLog);
      }

      print("SMS logs synced successfully.");
    } catch (e) {
      print("Error syncing SMS logs: $e");
    }
  }
}
