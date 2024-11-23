import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/user.dart';

class LocationListView extends StatefulWidget {
  @override
  _LocationListViewState createState() => _LocationListViewState();
}

class _LocationListViewState extends State<LocationListView> {
  DateTime _selectedDate = DateTime.now();
  List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();
  bool _isLoading = false; // Track loading state
  List<LatLng> _stopPoints = [];
  String _formattedDate(DateTime date) =>
      DateFormat('dd-MMM-yyyy').format(date);

  Stream<QuerySnapshot> _locationStream() {
    DateTime startOfDay =
    DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    String startOfDayIsoString = startOfDay.toIso8601String();
    String endOfDayIsoString = endOfDay.toIso8601String();

    return FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDayIsoString)
        .where('timestamp', isLessThanOrEqualTo: endOfDayIsoString)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _cacheData(List<LatLng> routeData, DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String dateKey = selectedDate.toIso8601String().split("T")[0];
    String dataString = jsonEncode(routeData
        .map((point) => {'lat': point.latitude, 'lng': point.longitude})
        .toList());
    prefs.setString(dateKey, dataString);
  }

  Future<List<LatLng>?> _getCachedData(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String dateKey = selectedDate.toIso8601String().split("T")[0];
    String? dataString = prefs.getString(dateKey);
    if (dataString == null) return null;
    List<dynamic> decodedData = jsonDecode(dataString);
    return decodedData
        .map((point) => LatLng(point['lat'], point['lng']))
        .toList();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true); // Show loading indicator
    List<LatLng>? cachedData = await _getCachedData(_selectedDate);

    if (cachedData != null) {
      setState(() {
        _routePoints = cachedData;
        _isLoading = false; // Hide loading indicator
      });
      _updateMapCenter();
    } else {
      _locationStream().listen((snapshot) {
        List<Map<String, dynamic>> locationData = [];
        List<LatLng> routePoints = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          locationData.add({
            'timestamp': DateTime.parse(data['timestamp']),
            'point': LatLng(data['latitude'], data['longitude']),
          });
          return LatLng(data['latitude'], data['longitude']);
        }).toList();

        // Identify stop points
        List<LatLng> stopPoints = _identifyStopPoints(locationData);
        print("Stop points after processing: $stopPoints");

        _cacheData(routePoints, _selectedDate);
        setState(() {
          _routePoints = routePoints;
          _stopPoints = stopPoints;
          print("Route points updated: $_routePoints");
          print("Stop points updated: $_stopPoints");
          _isLoading = false; // Hide loading indicator
        });
        _updateMapCenter();
      });
    }
  }

  List<LatLng> _identifyStopPoints(List<Map<String, dynamic>> locationData) {
    List<LatLng> stopPoints = [];
    print("Location data received: $locationData");

    if (locationData.isEmpty) return stopPoints;

    locationData.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    for (int i = 1; i < locationData.length; i++) {
      DateTime prevTime = locationData[i - 1]['timestamp'];
      DateTime currTime = locationData[i]['timestamp'];
      Duration gap = currTime.difference(prevTime);

      print("Gap between points: ${gap.inHours} minutes");
      if (gap.inHours >= 1) {
        stopPoints.add(locationData[i - 1]['point']);
        print("Added stop point: ${locationData[i - 1]['point']}");
      }
    }

    print("Stop points identified: $stopPoints");
    return stopPoints;
  }





  void _updateMapCenter() {
    if (_routePoints.isNotEmpty) {
      LatLng centerPoint = _routePoints[_routePoints.length ~/ 2];
      print("Center -----------------------$centerPoint");
      _mapController.move(centerPoint, 12);
    } else {
      _mapController.move(LatLng(24.8090634, 93.9436556), 12);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map widget
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(24.8090634, 93.9436556),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Existing markers for start and end points
                if (_routePoints.isNotEmpty)
                  Marker(
                    width: 80,
                    height: 80,
                    point: _routePoints.first,
                    child: Icon(
                      Icons.home,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                if (_routePoints.isNotEmpty)
                  Marker(
                    width: 80,
                    height: 80,
                    point: _routePoints.last,
                    child: Icon(
                      Icons.home_outlined,
                      color: Colors.greenAccent,
                      size: 30,
                    ),
                  ),
                // Markers for stop points
                ..._stopPoints.map((stopPoint) {
                  print("Rendering stop point marker: $stopPoint");
                  return Marker(
                    width: 60,
                    height: 60,
                    point: stopPoint,
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_disabled,
                          color: Colors.red,
                          size: 30,
                        ),

                      ],
                    ),
                  );
                }).toList(),

              ],
            ),

          ],
        ),

        // Date selector positioned above the map
        Positioned(
          bottom: 16,
          left: 50,
          right: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _fetchData();
                    });
                  }
                },
                child: Text("Select Date: ${_formattedDate(_selectedDate)}"),
              ),
            ],
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text(
                          "Loading data...",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

}
