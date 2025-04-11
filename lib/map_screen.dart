import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenlife/widget/AppSize.dart';
import 'package:greenlife/widget/AppText.dart';
import 'package:greenlife/widget/app_button.dart';
import 'package:greenlife/widget/showDialog.dart';
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
  Set<Circle> _circles = {};
  List<Map<String, dynamic>> _nurseries = [];
  int searchRadius = 1000;
  bool isLoading = false;
  bool noNurseriesFound = false;
  double maxDistance = 300000;
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
      noNurseriesFound = false;
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
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final query = '''
  [out:json];
  (
    node["shop"="plant_nursery"](around:$radius,$lat,$lon);
    node["shop"="garden_centre"](around:$radius,$lat,$lon);
  );
  out;
''';

    final url =
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}';

    final response = await http.get(Uri.parse(url));
    debugPrint("==========data: ${response.body}");

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody)['elements'];
      Set<Marker> markers = {
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(lat, lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "موقعك الحالي"),
        ),
      };

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

      Set<Circle> circles = {
        Circle(
          circleId: const CircleId('user_location_circle'),
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

      await _zoomToFitCircle(LatLng(lat, lon), radius.toDouble());

      if (nurseriesList.length < 3) {
        if (radius < maxDistance) {
          searchRadius = radius + 10000;
          _fetchNurseries(lat, lon, searchRadius);
        } else {
          setState(() {
            noNurseriesFound = true;
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _zoomToFitCircle(LatLng center, double radius) async {
    final southWest = LatLng(center.latitude - radius / 111000,
        center.longitude - radius / (111000 * cos(center.latitude * pi / 180)));
    final northEast = LatLng(center.latitude + radius / 111000,
        center.longitude + radius / (111000 * cos(center.latitude * pi / 180)));

    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _moveToLocation(
                    _currentPosition!.latitude, _currentPosition!.longitude);
              },
              icon: Icon(
                Icons.location_searching,
                color: Colors.white,
                size: 30,
              ))
        ],
        title: const Text('محلات بيع الشتلات',
            style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 14,
                  ),
                  markers: _markers,
                  circles: _circles,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
//search range==================================================================================================================================================================================================================================================
                //don't show container when complete search
                if (!(searchRadius >= maxDistance && _nurseries.isNotEmpty))
                  Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _nurseries.isEmpty && noNurseriesFound
                          ? Colors.red
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      _nurseries.isEmpty && noNurseriesFound
                          ? 'لا توجد مشاتل قريبة من موقعك الحالي'
                          : 'تم البحث في نطاق: ${_circles.isNotEmpty ? min(_circles.first.radius.toInt(), maxDistance.toInt()) : 0} متر من أصل ${maxDistance.toInt()} متر',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _nurseries.isEmpty && noNurseriesFound
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
//nurser===========================================================================================
                Positioned(
                  bottom: 30,
                  left: 10,
                  right: 10,
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _nurseries.length,
                    itemBuilder: (context, index) {
                      var nursery = _nurseries[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nursery["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppButtons(
                                      onPressed: () => _moveToLocation(
                                          nursery["latitude"],
                                          nursery["longitude"]),
                                      icon: Icon(
                                        Icons.map,
                                        color: Colors.white,
                                      ),
                                      text: "عرض",
                                      backgroundColor: Colors.red,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.directions,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                      onPressed: () => _openInGoogleMaps(
                                          nursery["latitude"],
                                          nursery["longitude"]),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
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
