import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/background_task.dart'; // Import the BackgroundTaskManager
import 'app.dart'; // Your app’s main UI
import 'firebase_options.dart'; // Firebase configuration options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize background task management
  await BackgroundTaskManager.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kid Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(), // Your main app screen
    );
  }
}
