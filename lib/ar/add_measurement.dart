import 'package:cloud_firestore/cloud_firestore.dart';
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

class AddMeasurement extends StatefulWidget {
  const AddMeasurement({super.key});

  @override
  _AddMeasurementState createState() => _AddMeasurementState();
}

class _AddMeasurementState extends State<AddMeasurement> {
  String boll = "https://modelviewer.dev/shared-assets/models/sphere.glb";
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  List<Vector3> points = [];
  List<ARNode> pointNodes = [];
  double? lastMeasurement;
  bool isLoading = true; // للتحقق من تحميل آخر قياس أم لا
  @override
  void initState() {
    super.initState();
    _fetchLastMeasurement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
            text: "إضافة قياس جديد", fontSize: 22, color: m.Colors.white),
        backgroundColor: m.Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ARView(onARViewCreated: onARViewCreated),
                Positioned(
                    bottom: 20,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButtons(
                                backgroundColor: m.Colors.red,
                                onPressed: _resetMeasurement,
                                text: "إعادة التعيين"),
                            AppButtons(
                                onPressed: () {
                                  if (points.length == 2) {
                                    _calculateDistance();
                                  } else {
                                    showAlert(
                                        context: context,
                                        title: "حساب الطول",
                                        content:
                                            'يجب تحديد نقطة البداية والنهاية أولاً');
                                  }
                                },
                                text: "حساب الطول"),
                          ],
                        ),
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
      double distance = points[0].distanceTo(points[1]) * 100;
      showAlert(
          context: context,
          title: "حساب الطول",
          content: " طول النبتة: ${distance.toStringAsFixed(2)} سم",
          showButton: true,
          buttonsText: 'حفظ القياس',
          onConfirm: () => _saveMeasurement(distance));
    }
  }

  void _saveMeasurement(double distance) {
    String status = "نمو ثابت";
    if (lastMeasurement != null) {
      if (distance > lastMeasurement!) {
        status = "نمو";
      } else if (distance < lastMeasurement!) {
        status = "تراجع";
      }
    }
    lastMeasurement = distance;
    FirebaseFirestore.instance.collection("measurement").add({
      "distance": distance,
      "status": status,
      "timestamp": Timestamp.now(),
    });
    Navigator.pop(context);
    showAlert(
      context: context,
      title: "تم الحفظ",
      content: "تم حفظ القياس بنجاح!",
    );
  }

  void _resetMeasurement() async {
    for (var node in pointNodes) {
      await arObjectManager.removeNode(node);
    }
    pointNodes.clear();
    points.clear();
  }

  void _fetchLastMeasurement() async {
    var query = await FirebaseFirestore.instance
        .collection("measurement")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      lastMeasurement = query.docs.first["distance"];
    }
    print('===========lastMeasurement:=================== $lastMeasurement');
    setState(() {
      isLoading = false; // تم تحميل آخر قياس
    });
  }
}
