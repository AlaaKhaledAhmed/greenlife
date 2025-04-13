import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:greenlife/MyFavoritePlants.dart';
import 'package:greenlife/PlantInMyLocation/PlantInMyLocation.dart';
import 'package:greenlife/ar/add_measurement.dart';
import 'package:greenlife/generated/assets.dart';
import 'package:greenlife/volunteering.dart';
import 'package:greenlife/widget/AppSize.dart';
import 'package:greenlife/widget/AppText.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greenlife/widget/utils.dart';

import 'Notification/add_notification.dart';
import 'ar/measurement_history.dart';

class HomeScreen extends StatefulWidget {
  final String firstName, lastName;
  const HomeScreen(
      {super.key, required this.firstName, required this.lastName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Items> items = [
    Items(
        title: "تذكير بالعناية",
        image: Assets.svgReminder,
        pageName: AddNotification()),
    Items(
        title: "تتبع النمو",
        image: Assets.svgGrowth,
        pageName: MeasurementHistoryPage()),
    Items(
        title: "التطوع بذل وعطاء",
        image: Assets.svgDonation,
        pageName: Volunteering()),
    Items(
        title: "نبتة في حضن ارضك",
        image: Assets.svgPlantLocation,
        pageName: PlantInMyLocation()),
    Items(
        title: "سجل نباتاتك",
        image: Assets.svgPlantRecords,
        pageName: MyFavoritePlants()),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              Utils.imagesBack,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //app bar
            Container(
                padding: EdgeInsets.only(
                    bottom: 15, top: MediaQuery.of(context).padding.top + 10),
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.handshake_outlined,
                      color: Colors.black,
                      size: AppSize.iconsSize + 10,
                    ),
                  ),
                  title: AppText(
                    text: 'اهلا وسهلا بك',
                    fontSize: AppSize.labelSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  subtitle: AppText(
                    text: '${widget.firstName} ${widget.lastName}',
                    fontSize: AppSize.labelSize,
                    color: Colors.white,
                  ),
                )),

            const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: AppText(
                text: 'اختر من القائمة',
                fontSize: AppSize.textSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
//===================================================================================================================================================================
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5),
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => items[index].pageName)),
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.2),
                            radius: 50,
                            child: SvgPicture.asset(
                              height: 50,
                              width: 50,
                              items[index].image,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 20),
                            child: AppText(
                                text: items[index].title,
                                fontSize: AppSize.subTextSize),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Items {
  String title, image;
  var pageName;
  Items({required this.title, required this.image, required this.pageName});
}
