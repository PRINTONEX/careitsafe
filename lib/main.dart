import 'dart:async';
import 'dart:ui';
import 'package:call_log/call_log.dart';
import 'package:careitsafe/widgets/call_log_view.dart';
import 'package:careitsafe/widgets/setting_page.dart';
import 'package:careitsafe/widgets/location_view.dart';
import 'package:careitsafe/widgets/notification_log_view.dart';
import 'package:careitsafe/widgets/sms_log_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony/telephony.dart';
import 'const/user.dart';
import 'core/firebase_manager.dart';
import 'core/location_service.dart';
import 'core/permission_services.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check and request permissions
  await PermissionService.checkAndRequestPermissions();
  // Initialize Firebase only once in the main isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize the background service
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Configure notifications
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'Activity Tracking',
    description: 'Activity tracking service',
    importance: Importance.low,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AI ANALYZE ACTIVITY',
      initialNotificationContent: '',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DartPluginRegistrant.ensureInitialized();
  // Track activity every 10 seconds in the background
  // Sync SMS and call logs every 24 hours
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    print("Syncing SMS and Call Logs every 24 hours");
    // await syncSmsLog();
    await syncCallLog();
  });

  // Track activity every 10 seconds
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    print("Tracking activity every 15 seconds...");
    final activity = await FlutterActivityRecognition.instance.activityStream.first;
    await _handleActiveActivity(activity, service);
  });
}
Future<void> _handleActiveActivity(Activity activity, ServiceInstance service) async {
  try {
    final user = userId;  // Get the current userId
    String activityTypeString = activity.type.toString().split('.').last;

    // Fetch the user's selected activities from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user_settings').doc(user).get();

    if (!userDoc.exists || !(userDoc.data() is Map<String, dynamic>)) {
      // User settings not found or the data is not in the expected format
      print('User settings not found! Using default behavior.');
      // Default behavior when no settings exist
      if (activity.type == ActivityType.IN_VEHICLE) {
        print('Active movement detected: ${activity.type}. Starting location tracking.');
        await LocationService.startLocationTracking();
      } else {
        print('Non-active or unknown activity detected (${activityTypeString}). Location tracking not started.');
        LocationService.stopLocationTracking();
      }
      return; // Exit the function early as default behavior is applied
    }

    // Retrieve the LocationMonitorType field, which is a list of selected activities
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    List<dynamic> userSelectedActivities = userData['LocationMonitorType'] ?? [];

    // If the list is empty or not found, we proceed with default logic (IN_VEHICLE check)
    if (userSelectedActivities.isEmpty) {
      print('No user activities found. Defaulting to IN_VEHICLE.');
      if (activity.type == ActivityType.IN_VEHICLE) {
        print('Active movement detected: ${activity.type}. Starting location tracking.');
        await LocationService.startLocationTracking();
      } else {
        print('Non-active or unknown activity detected (${activityTypeString}). Location tracking not started.');
        LocationService.stopLocationTracking();
      }
      return;
    }

    // Check if the current activity type is in the user's selected activities
    if (userSelectedActivities.contains(activityTypeString)) {
      // If the activity is selected by the user, start location tracking
      print('Active movement detected: ${activityTypeString}. Starting location tracking.');
      await LocationService.startLocationTracking();
    } else {
      // If the activity type is not selected by the user, stop location tracking
      print('Non-active or unknown activity detected (${activityTypeString}). Location tracking not started.');
      LocationService.stopLocationTracking();
    }
  } catch (e) {
    print('Error in _handleActiveActivity: $e');
  }
}
// Sync Call Log
bool _isSyncing = false;

Future<void> syncCallLog() async {
  if (_isSyncing) {
    print("Sync in progress, skipping...");
    return;
  }

  _isSyncing = true;
  try {
    print("Syncing call logs...");
    var logs = await CallLog.get();
    // Process logs here
    print("Call logs synced: $logs");
  } catch (e) {
    print("Error syncing call logs: $e");
  } finally {
    _isSyncing = false;
  }
}

// Sync SMS Log
Future<void> syncSmsLog() async {
  print("Checking SMS...........................");
  final telephony = Telephony.instance;

  try {
    // Fetch SMS messages from the inbox
    List<SmsMessage> smsMessages = await telephony.getInboxSms();

    print("Total SMS Messages: ${smsMessages.length}");

    // Check if there are any messages
    if (smsMessages.isEmpty) {
      print("No SMS messages found.");
      return;
    }

    // Loop through SMS messages and prepare data for Firestore
    for (var sms in smsMessages) {
      Map<String, dynamic> smsData = {
        'userId' : userId,
        'address': sms.address,
        'body': sms.body,
        'timestamp': sms.date,  // Date is in milliseconds already
        'type': sms.type.toString(),  // Retrieve type directly
      };

      // Print the SMS data
      print(smsData);

      // Sync to Firestore (Make sure userId is valid)
      if (userId != null && userId.isNotEmpty) {
        await FirebaseManager.syncSmsData(smsData);
        print("SMS synced to Firestore.");
      } else {
        print("Invalid userId, cannot sync SMS.");
      }
    }

  } catch (e) {
    print("Error syncing SMS: $e");
  }
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5, // We have 5 tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Activity Tracker'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Setting'),
                Tab(text: 'Location'),
                Tab(text: 'Call Log'),
                Tab(text: 'SMS Log'),
                Tab(text: 'Notification'),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              children: [
                SettingPage(),    // 1. Setting Page
                LocationListView(),   // 2. Location View
                 CallLogView(),        // 3. Call Log (This is an example, you need to define this widget)
                 SmsLogView(),         // 4. SMS Log (This is an example, you need to define this widget)
                 NotificationLogView(),// 5. Notification Log (This is an example, you need to define this widget)
              ],
            ),
          ),
        ),
      ),
    );
  }

}
