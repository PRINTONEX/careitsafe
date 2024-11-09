// lib/app.dart

import 'package:flutter/material.dart';
import 'core/permission_services.dart';
import 'core/sync_service.dart';
import 'screens/home_screen.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    // Start permission check and background sync on app start
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Request required permissions for the app
    await PermissionService.checkAndRequestPermissions();

    // Start sync service to run background tasks
    SyncService.startBackgroundSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kid Monitor Dashboard')),
      body: HomeScreen(),
    );
  }

  @override
  void dispose() {
    // Stop background sync when the app is disposed
    SyncService.stopBackgroundSync();
    super.dispose();
  }
}
