import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // Set for circles
  List<Map<String, dynamic>> _nurseries = []; // List to store nursery data
  int searchRadius = 1000; // Initial search radius in meters
  bool isLoading = false; // Flag to prevent repeated requests
  bool noNurseriesFound = false; // Flag to show no nurseries found message

  @override
  void initState() {
    super.initState();
    _getLocationAndFetchNurseries();
  }

  Future<void> _getLocationAndFetchNurseries() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      noNurseriesFound = false; // Reset the flag before new search
    });

    _fetchNurseries(position.latitude, position.longitude, searchRadius);
  }

  Future<void> _fetchNurseries(double lat, double lon, int radius) async {
    /// "garden_centre" refers to stores or centers that sell a variety of gardening products
    /// including plants, tools, soil, fertilizers, and flowers. It's a general gardening store.
    /// Example: A shop selling tools and plants together would be categorized as "garden_centre".

    /// "plant_nursery" refers to places that specifically grow and sell plants, such as young trees,
    /// shrubs, flowers, and other plants. They focus on nurturing and selling plants before they
    /// reach full maturity, often for resale to garden centers or retail stores.
    /// Example: A place that specializes in growing and selling only plants would be categorized as "plant_nursery".

    if (isLoading) return; // Prevent multiple requests
    setState(() {
      isLoading = true;
    });

    final query = '''
      [out:json];
      node
        ["shop"="plant_nursery"]
        (around:$radius,$lat,$lon);
      out;
    ''';

    final url =
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}';

    final response = await http.get(Uri.parse(url));
    debugPrint("==========data: ${response.body}");

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['elements'];

      Set<Marker> markers = {
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(lat, lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "موقعك الحالي"),
        ),
      };

      // Add nurseries markers
      List<Map<String, dynamic>> nurseriesList = [];
      for (var item in data.take(3)) {
        markers.add(
          Marker(
            markerId: MarkerId(item["id"].toString()),
            position: LatLng(item["lat"], item["lon"]),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: item["tags"]["name"] ?? "مشتل غير معروف",
            ),
          ),
        );
        nurseriesList.add({
          "name": item["tags"]["name"] ?? "مشتل غير معروف",
          "latitude": item["lat"],
          "longitude": item["lon"],
        });
      }

      // Set the circle based on radius
      Set<Circle> circles = {
        Circle(
          circleId: CircleId('user_location_circle'),
          center: LatLng(lat, lon),
          radius: radius.toDouble(),
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.1),
        ),
      };

      setState(() {
        _markers = markers;
        _circles = circles;
        _nurseries = nurseriesList;
        isLoading = false;
      });

      // If fewer than 3 nurseries found, increase the search radius and retry
      if (nurseriesList.length < 3) {
        if (radius < 100000) {
          // Max radius limit (100,000 meters)
          searchRadius = radius + 200; // Increase radius by 200m
          _fetchNurseries(lat, lon, searchRadius); // Retry with new radius
        } else {
          // If no nurseries found even after max radius, show message
          setState(() {
            noNurseriesFound = true;
            isLoading = false;
          });
        }
      } else {
        // If 3 or more nurseries are found, stop the search
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lon), 14),
        );
      }
    }
  }

  void _moveToLocation(double lat, double lon) {
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lon), 16));
  }

  void _openInGoogleMaps(double lat, double lon) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("أقرب 3 مشاتل زراعية")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    circles: _circles, // Add the circles to the map
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _nurseries.isEmpty && noNurseriesFound
                      ? Center(child: Text("لا توجد مشاتل قريبة"))
                      : ListView.builder(
                          itemCount: _nurseries.length,
                          itemBuilder: (context, index) {
                            var nursery = _nurseries[index];
                            return ListTile(
                              title: Text(nursery["name"]),
                              onTap: () => _moveToLocation(
                                  nursery["latitude"], nursery["longitude"]),
                              trailing: IconButton(
                                icon: const Icon(Icons.directions),
                                onPressed: () => _openInGoogleMaps(
                                    nursery["latitude"], nursery["longitude"]),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
