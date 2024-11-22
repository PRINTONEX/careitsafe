// lib/core/services/permission_service.dart

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final List<Permission> _requiredPermissions = [
    Permission.activityRecognition,
    Permission.phone,
    Permission.sms,
    Permission.notification,
    Permission.location,
    Permission.contacts,
    

    // Permission.locationAlways

  ];

  static Future<void> checkAndRequestPermissions() async {
    for (Permission permission in _requiredPermissions) {
      if (await permission.isDenied || await permission.isPermanentlyDenied) {
        await permission.request();
      }
    }
  }
}
