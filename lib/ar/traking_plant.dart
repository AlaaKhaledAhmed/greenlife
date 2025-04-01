import 'dart:math' as math;
import 'package:flutter/material.dart' as m;
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart'
    show NodeType;
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart' show ARNode;
import 'package:ar_flutter_plugin_engine/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/widget/AppText.dart';
import 'package:greenlife/widget/app_button.dart';
import 'package:greenlife/widget/showDialog.dart';
import 'package:vector_math/vector_math_64.dart';

class PlantARMeasurement extends StatefulWidget {
  const PlantARMeasurement({super.key});

  @override
  _PlantARMeasurementState createState() => _PlantARMeasurementState();
}

class _PlantARMeasurementState extends State<PlantARMeasurement> {
  String boll = "https://modelviewer.dev/shared-assets/models/sphere.glb";
  String line =
      "https://github.com/tomaszew95/3d-models-pack/raw/main/cylinder.glb";

  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  List<Vector3> points = []; // لتخزين نقاط البداية والنهاية
  List<ARNode> pointNodes = []; // لتخزين العلامات على النقاط
  ARNode? lineNode; // لتخزين الخط المرسوم
  bool showResetButton = false; // إظهار زر إعادة التعيين عند رسم الخط

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: "تتبع النمو",
          fontSize: 22,
          color: m.Colors.white,
        ),

        backgroundColor: m.Colors.green, // AppBar color
      ),
      body: Stack(
        children: [
          ARView(onARViewCreated: onARViewCreated),

          // زر حساب الطول
          Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر إعادة التعيين
                  if (showResetButton)
                    Positioned(
                        bottom: 20,
                        left: 20,
                        child: AppButtons(
                            backgroundColor: m.Colors.red,
                            onPressed: _resetMeasurement,
                            text: "إعادة التعيين")),

                  //حساب الطول
                  AppButtons(
                      onPressed: () {
                        if (points.length == 2) {
                          _calculateDistance();
                          setState(() {
                            showResetButton = true;
                          });
                        } else {
                          showAlert(
                              context: context,
                              title: "حساب الطول",
                              content: 'يجب تحديد نقطة البدايه والنهاية اولا');
                        }
                      },
                      text: "حساب الطول"),
                ],
              )),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager sessionManager, ARObjectManager objectManager, _, __) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager.onInitialize(
        showFeaturePoints: true, showPlanes: true, showAnimatedGuide: false);

    arSessionManager.onPlaneOrPointTap = (hitResult) {
      if (points.length < 2) {
        Vector3 position = Vector3(
          hitResult.first.worldTransform.getColumn(3).x,
          hitResult.first.worldTransform.getColumn(3).y,
          hitResult.first.worldTransform.getColumn(3).z,
        );
        points.add(position);
        _addMarker(position);
      }
    };
  }

  void _addMarker(Vector3 position) async {
    var markerNode = ARNode(
      type: NodeType.webGLB,
      uri: boll,
      position: position,
      scale: Vector3(0.02, 0.02, 0.02),
    );

    await arObjectManager.addNode(markerNode);
    pointNodes.add(markerNode);
  }

  void _calculateDistance() {
    if (points.length == 2) {
      double distance = points[0].distanceTo(points[1]) * 100; // تحويل إلى سم
      showAlert(
          context: context,
          title: "قياس الطول",
          content: "طول النبتة: ${distance.toStringAsFixed(2)} سم");
    }
  }

  void _resetMeasurement() async {
    // حذف جميع النقاط
    for (var node in pointNodes) {
      await arObjectManager.removeNode(node);
    }
    pointNodes.clear();

    // حذف الخط
    if (lineNode != null) {
      await arObjectManager.removeNode(lineNode!);
      lineNode = null;
    }

    // إعادة ضبط المتغيرات
    points.clear();
    setState(() {
      showResetButton = false;
    });
  }
}
