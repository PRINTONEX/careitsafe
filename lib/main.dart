import 'package:careitsafe/CallLogListPage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital SafeGuard',
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
    MapEntry('Location', Permission.location),
    MapEntry('Call Log', Permission.phone),
    MapEntry('SMS', Permission.sms),
    MapEntry('Contacts', Permission.contacts),
    MapEntry('Camera', Permission.camera),
    MapEntry('Microphone', Permission.microphone),
    MapEntry('Storage', Permission.storage),
    MapEntry('Notification Access', Permission.notification),
  ];

  Map<String, PermissionStatus> _permissionsStatus = {};
  bool _isCheckingPermissions = false;

  Future<void> _checkPermissionsWithAnimation() async {
    setState(() {
      _isCheckingPermissions = true;
      _permissionsStatus.clear();
    });

    for (var entry in _permissions) {
      PermissionStatus status = await entry.value.request();
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
            title: GestureDetector(
              onTap: () {
                if (status == PermissionStatus.granted) {
                  _navigateToPermissionPage(permissionName);
                } else {
                  _requestSinglePermission(permission, permissionName);
                }
              },
              child: Text(
                permissionName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        if (status != PermissionStatus.granted)
          ElevatedButton(
            onPressed: () => _requestSinglePermission(permission, permissionName),
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

  Future<void> _requestSinglePermission(
      Permission permission, String permissionName) async {
    PermissionStatus status = await permission.request();
    setState(() {
      _permissionsStatus[permissionName] = status;
    });
  }

  void _navigateToPermissionPage(String permissionName) {
    switch (permissionName) {
      case 'Location':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LocationListPage()),
        );
        break;
      case 'Call Log':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CallLogListPage()),
        );
        break;
      case 'SMS':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SmsListPage()),
        );
        break;
      case 'Contacts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactsListPage()),
        );
        break;
    // Add more cases as needed for other permissions.
      default:
        print('Page for $permissionName not yet implemented');
        break;
    }
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
                  .map((entry) => _buildPermissionStatus(entry.key, entry.value))
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

// Example pages for each permission type

class LocationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location List')),
      body: Center(child: Text('Display location data here')),
    );
  }
}



class SmsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMS List')),
      body: Center(child: Text('Display SMS data here')),
    );
  }
}

class ContactsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts List')),
      body: Center(child: Text('Display contacts data here')),
    );
  }
}
