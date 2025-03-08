import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:greenlife/PlantInMyLocation/AppSize.dart';
import 'package:greenlife/PlantInMyLocation/AppText.dart';
import 'package:image_picker/image_picker.dart';

class ScanHome extends StatefulWidget {
  const ScanHome({super.key});

  @override
  State<ScanHome> createState() => _ScanHomeState();
}

class _ScanHomeState extends State<ScanHome> {
  File? _image;
  String _result = "";

  List<String> _labels = [];

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
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true
        useGpuDelegate: false, // defaults to false
      );
      print("Model Loaded Successfully");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      classifyImage(_image!); // استدعاء التصنيف بعد اختيار الصورة
    }
  }

  // تصنيف الصورة
  // Future<void> classifyImage(File image) async {
  //   var recognitions = await Tflite.runModelOnImage(
  //     path: image.path,
  //     imageMean: 0.0,
  //     imageStd: 255.0,
  //     numResults: 2,
  //     threshold: 0.2,
  //     asynch: true,
  //   );
  //
  //   if (recognitions != null && recognitions.isNotEmpty) {
  //     var result = recognitions[0];
  //
  //     // تأكد أن result['label'] يحتوي على النص الصحيح
  //     String label = result['label'];
  //     double confidence = result['confidence'] * 100;
  //
  //     setState(() {
  //       _result = "$label\nنسبة الثقة: ${confidence.toStringAsFixed(2)}%";
  //     });
  //   }
  // }
  Future<void> classifyImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 5, // زيادة عدد النتائج
      threshold: 0.2,
      asynch: true,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      List<String> results = [];

      for (var result in recognitions) {
        String label = result['label']; // اسم النبتة
        double confidence = result['confidence'] * 100; // نسبة الثقة
        results.add("$label - ${confidence.toStringAsFixed(2)}%");
      }

      setState(() {
        _result = results.join("\n");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: 'التعرف على النباتات',
          fontSize: 22,
          color: Colors.white,
        ),

        backgroundColor: Colors.green, // AppBar color
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
                        child: Image.file(
                          _image!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )),
            const SizedBox(height: 20),
//=====================================================================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: AppText(
                      text: 'اختيار من المعرض',
                      fontSize: AppSize.subTextSize,
                      color: Colors.white,
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: AppText(
                      text: 'التقاط صورة',
                      fontSize: AppSize.subTextSize,
                      color: Colors.white,
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _result, // عرض النتيجة هنا
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
