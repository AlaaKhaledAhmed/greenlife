import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

class GoogleMapsScreen extends StatefulWidget {
  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  String? userAddress;

  List<Map<String, dynamic>> seedlingCenters = [
    {"name": "Green Seedlings", "lat": 40.712776, "lng": -74.005974},
    {"name": "Eco Nursery", "lat": 34.052235, "lng": -118.243683},
    {"name": "Nature's Hub", "lat": 37.774929, "lng": -122.419418},
  ];

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print('تم رفض إذن الموقع');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('إذن الموقع مرفوض نهائيًا، يجب تغييره من الإعدادات.');
      return;
    }

    print('تم منح إذن الموقع بنجاح!');
  }

  // Get User Location
  Future<void> getUserLocation() async {
    await requestLocationPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    // Convert coordinates to address
    // List<Placemark> placemarks = await placemarkFromCoordinates(
    //   position.latitude,
    //   position.longitude,
    // );

    // if (placemarks.isNotEmpty) {
    //   setState(() {
    //     userAddress = "${placemarks[0].street}, ${placemarks[0].locality}";
    //   });
    // }
  }

  // Find Nearest Seedling Center
  Map<String, dynamic>? findNearestCenter() {
    if (userLocation == null) return null;

    double minDistance = double.infinity;
    Map<String, dynamic>? nearestCenter;

    for (var center in seedlingCenters) {
      double distance = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        center['lat'],
        center['lng'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCenter = center;
      }
    }

    return nearestCenter;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? nearestCenter = findNearestCenter();

    return Scaffold(
      //appBar: AppBar(title: Text("Nearest Seedling Center")),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: userLocation!,
                      zoom: 12,
                    ),
                    markers: {
                      // User Location Marker
                      Marker(
                        markerId: MarkerId("userLocation"),
                        position: userLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                        infoWindow: InfoWindow(title: "You are here"),
                      ),
                      // Seedling Centers Markers
                      for (var center in seedlingCenters)
                        Marker(
                          markerId: MarkerId(center['name']),
                          position: LatLng(center['lat'], center['lng']),
                          icon: BitmapDescriptor.defaultMarker,
                          infoWindow: InfoWindow(title: center['name']),
                        ),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Your Location: $userAddress"),
                      SizedBox(height: 10),
                      nearestCenter == null
                          ? Text("Finding nearest center...")
                          : Text("Nearest Center: ${nearestCenter['name']}"),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
