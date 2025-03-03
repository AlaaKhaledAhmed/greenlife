import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:greenlife/PlantInMyLocation/PlantInMyLocation.dart';

import 'Notification/add_notification.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  // top: 150,
                  // right: 20,
                  child: Text(
                    'مرحباً هيفاء محمد!',
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
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                  ),
                  items: items.map((item) {
                    return InkWell(
                      onTap: () {
                        if (item == "assets/images/rem.JPG") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNotification()));
                        }
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(item,
                                fit: BoxFit.cover, width: 1000),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black54, Colors.transparent],
                              ),
                            ),
                          ),
                        ],
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
