import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final List<String> _activityOptions = [
    'IN_VEHICLE',
    'ON_BICYCLE',
    'RUNNING',
    'WALKING',
    'STILL',
  ];
  // Track selected activities
  List<String> _selectedActivities = [];
  // Your user ID, replace with actual user ID
  final String userId = "9481924680";
  @override
  void initState() {
    super.initState();
    _loadSelectedActivitiesFromFirebase();
  }
  // Load selected activities from Firestore
  Future<void> _loadSelectedActivitiesFromFirebase() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _selectedActivities = List<String>.from(userDoc['LocationMonitorType'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading activities from Firebase: $e");
    }
  }

  // Function to update activityType in Firestore
  Future<void> _updateActivityTypeInFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('user_settings').doc(userId).set({
        'LocationMonitorType': _selectedActivities, // Update the LocationMonitorType field with the selected activities
      }, SetOptions(merge: true));  // This ensures that if the document already exists, it will only update this field.
      print("Location monitor type updated successfully!");
    } catch (e) {
      print("Error updating activity type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,  // Ensures GridView takes only the required space
      physics: NeverScrollableScrollPhysics(),  // Disable internal scrolling, as it's already in a scrollable parent
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,  // 2 items per row
        crossAxisSpacing: 8,  // Horizontal spacing between items
        mainAxisSpacing: 8,   // Vertical spacing between items
      ),
      itemCount: _activityOptions.length,
      itemBuilder: (context, index) {
        final activity = _activityOptions[index];

        // Select an appropriate icon based on the activity type
        Icon activityIcon;
        switch (activity) {
          case "IN_VEHICLE":
            activityIcon = Icon(Icons.directions_car, size: 30, color: Colors.blue);  // Vehicle icon
            break;
          case "ON_BICYCLE":
            activityIcon = Icon(Icons.directions_bike, size: 30, color: Colors.green);  // Bicycle icon
            break;
          case "RUNNING":
            activityIcon = Icon(Icons.directions_run, size: 30, color: Colors.orange);  // Running icon
            break;
          case "WALKING":
            activityIcon = Icon(Icons.directions_walk, size: 30, color: Colors.purple);  // Walking icon
            break;
          case "STILL":
            activityIcon = Icon(Icons.device_unknown, size: 30, color: Colors.grey);  // Still (stop) icon
            break;
          default:
            activityIcon = Icon(Icons.help, size: 30, color: Colors.red);  // Default icon for unknown activities
        }

        bool isSelected = _selectedActivities.contains(activity); // Check if this activity is selected

        return Card(
          elevation: isSelected ? 20 : 3,  // Higher elevation when selected
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),  // Rounded corners for smooth look
          ),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          child: InkWell(
            onTap: () {
              // Toggle the selection when the card is tapped
              if (isSelected) {
                _selectedActivities.remove(activity);
              } else {
                _selectedActivities.add(activity);
              }
              setState(() {});  // Rebuild to reflect the change in elevation
              _updateActivityTypeInFirebase();  // Update Firebase with the new selection
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),  // Reduced padding for compact design
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),  // Adds padding inside the container for the icon
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,  // Circular background for the icon
                      color: Colors.grey[200],  // Background color for the icon
                    ),
                    child: activityIcon,
                  ),
                  SizedBox(height: 8),  // Space between icon and label
                  Text(
                    activity,  // Display activity name
                    textAlign: TextAlign.center,  // Center the text
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),  // Small, bold text
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
