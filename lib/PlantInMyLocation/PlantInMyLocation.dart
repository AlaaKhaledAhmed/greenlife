import 'package:flutter/material.dart';
import 'package:greenlife/PlantInMyLocation/plants_list.dart';

import 'AppSize.dart';
import 'AppText.dart';

class PlantInMyLocation extends StatefulWidget {
  const PlantInMyLocation({super.key});

  @override
  State<PlantInMyLocation> createState() => _PlantInMyLocationState();
}

class _PlantInMyLocationState extends State<PlantInMyLocation> {
  TextEditingController searchController = TextEditingController();
  List<String> allCities = [
    "الرياض",
    "جدة",
    "مكة",
    "المدينة المنورة",
    "الدمام",
    "الطائف",
    "تبوك",
    "بريدة",
    "خميس مشيط",
    "حائل",
    "نجران",
    "أبها",
    "عرعر",
    "سكاكا",
    "جازان",
    "الباحة",
    "الجوف",
    "ينبع",
    "القريات",
  ];
  List<String> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCities = allCities;
  }

  void filterCities(String query) {
    setState(() {
      filteredCities = allCities.where((city) => city.contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: AppText(
            text: "اختر موقعًا",
            fontSize: 22,
            color: Colors.white,
          ),

          backgroundColor: Colors.green, // AppBar color
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "ابحث عن مدينة...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => filterCities(value),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredCities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading:
                            const Icon(Icons.location_on, color: Colors.green),
                        title: Text(
                          filteredCities[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text("المملكة العربية السعودية"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PlantsList(city: filteredCities[index])),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
