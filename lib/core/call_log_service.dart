// lib/core/services/call_log_service.dart

import 'firebase_manager.dart';

class CallLogService {
  static Future<void> syncCallLogs() async {
    try {
      // Placeholder call log data
      List<Map<String, dynamic>> callLogs = [
        {'number': '1234567890', 'duration': 30, 'timestamp': DateTime.now().toIso8601String()},
      ];

      for (var callLog in callLogs) {
        await FirebaseManager.syncCallLogData(callLog);
      }

      print("Call logs synced successfully.");
    } catch (e) {
      print("Error syncing call logs: $e");
    }
  }
}
