import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../PlantInMyLocation/plant_details.dart';

class ScanHome extends StatefulWidget {
  const ScanHome({super.key});

  @override
  State<ScanHome> createState() => _ScanHomeState();
}

class _ScanHomeState extends State<ScanHome> {
  File? _image;
  String? plantName;
  String _result = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // تحميل النموذج
  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
      print("تم تحميل النموذج بنجاح");
    } catch (e) {
      print("خطأ في تحميل النموذج: $e");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      classifyImage(_image!);
    }
  }

  Future<void> classifyImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5, // تعديل القيم إلى 127.5 لتحسين المعالجة
      imageStd: 127.5, // تعديل التوزيع القياسي
      numResults: 5, // زيادة عدد النتائج قد يكون مفيدًا
      threshold: 0.1, // تقليل العتبة لتحسين النتائج
      asynch: true,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      List<String> results = [];
      plantName = recognitions[0]['label']; // اسم النبتة
      for (var result in recognitions) {
        String label = result['label'];
        double confidence = result['confidence'] * 100; // نسبة الثقة
        results.add("$label - ${confidence.toStringAsFixed(2)}%");
      }

      setState(() {
        _result = results.join("\n");
        print("plant name: $plantName");
      });
    }
  }

  Future<void> fetchPlantData(String plantName) async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection("plants").get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data();

      for (var city in data.keys) {
        var cityData = data[city];

        if (cityData is List) {
          for (var plant in cityData) {
            // if (plant is Map && plant["common_names"] is List) {
            //List<dynamic> commonNames = plant["common_names"];
            var name = plant["name"];
            if (name.contains(plantName)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlantsDetails(data: Map<String, dynamic>.from(plant)),
                ),
              );

              return;
            }
            //   }
          }
        }
      }
    }


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("لا توجد معلومات عن ال$plantName"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('التعرف على النباتات',
            style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.green[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.grey.shade300,
              ),
              height: MediaQuery.of(context).size.height / 3,
              width: double.maxFinite,
              child: _image == null
                  ? Icon(Icons.image, size: 100, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child:
                          Image.file(_image!, height: 200, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: Text('اختيار من المعرض',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: Text('التقاط صورة',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900]),
            ),
            _result.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton.icon(
                      icon: isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              padding: EdgeInsets.all(5),
                            )
                          : Icon(
                              Icons.data_exploration_rounded,
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await fetchPlantData('$plantName');
                        setState(() {
                          isLoading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown),
                      label: Text('معلومات اضافيه',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
