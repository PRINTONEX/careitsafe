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

  String _formattedDate(DateTime date) => DateFormat('dd-MMM-yyyy').format(date);

  // Firebase query stream for location data based on selected date
  Stream<QuerySnapshot> _locationStream() {
    DateTime startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

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
    String dataString = jsonEncode(routeData.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList());
    prefs.setString(dateKey, dataString);
  }

  Future<List<LatLng>?> _getCachedData(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String dateKey = selectedDate.toIso8601String().split("T")[0];
    String? dataString = prefs.getString(dateKey);
    if (dataString == null) return null;
    List<dynamic> decodedData = jsonDecode(dataString);
    return decodedData.map((point) => LatLng(point['lat'], point['lng'])).toList();
  }

  Future<void> _fetchData() async {
    List<LatLng>? cachedData = await _getCachedData(_selectedDate);
    if (cachedData != null) {
      setState(() {
        _routePoints = cachedData;
      });
      _updateMapCenter(); // Update map center to cached data
    } else {
      _locationStream().listen((snapshot) {
        List<LatLng> routePoints = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return LatLng(data['latitude'], data['longitude']);
        }).toList();
        _cacheData(routePoints, _selectedDate);
        setState(() {
          _routePoints = routePoints;
        });
        _updateMapCenter(); // Update map center to new data
      });
    }
  }

  void _updateMapCenter() {
    if (_routePoints.isNotEmpty) {
      // Center the map on the midpoint of the route
      LatLng centerPoint = _routePoints[_routePoints.length ~/ 2];
      _mapController.move(centerPoint, 12);
    } else {
      // Move to a default location if no route points are available
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
    return Column(
      children: [
        // Date selection button
        ElevatedButton(
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
                _fetchData(); // Fetch data for the new date
              });
            }
          },
          child: Text(
            "Date: ${_formattedDate(_selectedDate)}",
            style: TextStyle(color: Colors.black),
          ),
        ),

        // Map with polyline and markers
        Expanded(
          child: Container(
            height: 600,
            child: FlutterMap(
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
                    if (_routePoints.isNotEmpty)
                      Marker(
                        width: 80,
                        height: 80,
                        point: _routePoints.first,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    if (_routePoints.isNotEmpty)
                      Marker(
                        width: 80,
                        height: 80,
                        point: _routePoints.last,
                        child: Icon(
                          Icons.home,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
