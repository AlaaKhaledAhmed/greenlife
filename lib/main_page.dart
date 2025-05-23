import 'package:flutter/material.dart';
import 'package:greenlife/profile.dart';
import 'package:greenlife/scan_plant/scan_home.dart';
import 'home_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const MainScreen(
      {super.key, required this.firstName, required this.lastName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> _screens;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(firstName: widget.firstName, lastName: widget.lastName),
      GoogleMapsScreen(),
      ScanHome(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'مرحبًا ${widget.firstName} ${widget.lastName}!',
        //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        //   ),
        // ),
        body: _screens[_index],
        bottomNavigationBar:
            // Bottom Navigation Bar
            BottomNavigationBar(
          onTap: (value) {
            setState(() {
              _index = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 15,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on), label: 'الموقع'),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt), label: 'كاميرا'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
