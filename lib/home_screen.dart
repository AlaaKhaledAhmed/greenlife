import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:greenlife/PlantInMyLocation/PlantInMyLocation.dart';
import 'package:greenlife/ar/traking_plant.dart';
import 'package:greenlife/volunteering.dart';

import 'Notification/add_notification.dart';

class HomeScreen extends StatefulWidget {
  final String firstName, lastName;
  const HomeScreen(
      {super.key, required this.firstName, required this.lastName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = const [
    "assets/images/rem.JPG",
    "assets/images/rem2.JPG",
    "assets/images/rem3.JPG"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header Section
          Container(
            width: double.maxFinite,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/back.JPG',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Feature Buttons
          Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  // top: 150,
                  // right: 20,
                  child: Text(
                    'مرحبًا ${widget.firstName} ${widget.lastName}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 150,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.52,
                  ),
                  items: items.map((item) {
                    return InkWell(
                      onTap: () {
                        if (item == "assets/images/rem.JPG") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNotification()));
                        } else if (item == "assets/images/rem3.JPG") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlantARMeasurement()));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Volunteering()));
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child:
                            Image.asset(item, fit: BoxFit.cover, width: 1000),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  print('objectttttttttt');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlantInMyLocation()),
                  );
                },
                child: Container(
                  height: 75,
                  width: 295,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/plantland.JPG',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: Container(
                  height: 70,
                  width: 295,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/regplant.JPG',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
