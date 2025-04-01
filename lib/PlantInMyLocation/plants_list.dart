import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greenlife/PlantInMyLocation/plant_details.dart';
import 'package:greenlife/widget/AppText.dart';
import '../widget/AppSize.dart';


class PlantsList extends StatefulWidget {
  final String city;
  const PlantsList({super.key, required this.city});

  @override
  State<PlantsList> createState() => _PlantsListState();
}

class _PlantsListState extends State<PlantsList> {
  List<Map<String, dynamic>> plantsList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  ///get data from database
  Future<void> fetchPlants() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("plants")
          .doc("DHOCxXa3ZNVf53GVfeA0")
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey(widget.city)) {
          setState(() {
            plantsList = List<Map<String, dynamic>>.from(data[widget.city]);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "⚠️ لا توجد نباتات مسجلة لهذه المدينة.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "⚠️ لم يتم العثور على المستند.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "❌ خطأ أثناء جلب البيانات: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        centerTitle: true,
        title: AppText(
          text: widget.city,
          fontSize: 22,
          color: Colors.white,
        ),
        leading: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.green, // AppBar color
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                children: [
                  AppText(
                      fontWeight: FontWeight.bold,
                      text: 'افضل ${plantsList.length} في ${widget.city}',
                      fontSize: AppSize.labelSize),
                  AppText(
                      text: 'النباتات التي تضفي البهجة لايام الناس',
                      fontSize: AppSize.smallSubText),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.separated(
                          itemCount: plantsList.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            var plant = plantsList[index];
                            return ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: Image.network(
                                    plant['images'][0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                plant['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(plant['family']),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlantsDetails(data: plant),
                                    ));
                              },
                              trailing: Icon(Icons.arrow_forward_ios),
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
