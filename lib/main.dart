import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

import 'constant.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase for the app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permission Check Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MapEntry<String, Permission>> _permissions = [
    // Permissions for location
    MapEntry('Location', Permission.location),
    MapEntry('Location Background', Permission.locationAlways),
    MapEntry('Location Coarse', Permission.locationWhenInUse),
// Permissions for call logs and phone state
    MapEntry('Call Log', Permission.phone),

    // Permissions for SMS
    MapEntry('SMS', Permission.sms),
    // Permissions for accessing contacts
    MapEntry('Contacts', Permission.contacts),


    // Permissions for camera
    MapEntry('Camera', Permission.camera),

    // Permissions for microphone
    MapEntry('Microphone', Permission.microphone),

    // Permissions for storage (external)
    MapEntry('Storage', Permission.storage),

    // Permissions for notifications
    MapEntry('Notification Access', Permission.notification),
// Permissions for Bluetooth
    MapEntry('Bluetooth', Permission.bluetooth),
    MapEntry('App Upadate', Permission.requestInstallPackages),
  ];

  Map<String, PermissionStatus> _permissionsStatus = {};
  bool _isCheckingPermissions = false;

  Future<void> _checkPermissionsWithAnimation() async {
    setState(() {
      _isCheckingPermissions = true;
      _permissionsStatus.clear();
    });

    for (var entry in _permissions) {
      // Request permission
      PermissionStatus status = await entry.value.request();

      // Print the status for debugging
      print('Permission: ${entry.key}, Status: $status');

      await Future.delayed(Duration(milliseconds: 300));

      setState(() {
        _permissionsStatus[entry.key] = status;
      });
    }

    setState(() {
      _isCheckingPermissions = false;
    });
  }


  Future<void> _requestSinglePermission(
      Permission permission, String permissionName) async {
    PermissionStatus status = await permission.request();
    setState(() {
      _permissionsStatus[permissionName] = status;
    });
  }

  Widget _buildPermissionStatus(String permissionName, Permission permission) {
    PermissionStatus? status = _permissionsStatus[permissionName];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: Icon(
              status == PermissionStatus.granted
                  ? Icons.check_circle
                  : Icons.cancel,
              color: status == PermissionStatus.granted
                  ? Colors.green
                  : Colors.red,
            ),
            title: Text(
              permissionName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        if (status != PermissionStatus.granted)
          ElevatedButton(
            onPressed: () =>
                _requestSinglePermission(permission, permissionName),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('Grant Permission'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital SafeGuard')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._permissions
                  .map(
                      (entry) => _buildPermissionStatus(entry.key, entry.value))
                  .toList(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isCheckingPermissions
                    ? null
                    : _checkPermissionsWithAnimation,
                child: Text(_isCheckingPermissions
                    ? 'Checking...'
                    : 'Check All Permissions'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
