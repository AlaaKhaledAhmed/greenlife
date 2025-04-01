import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_engine/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_engine/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart' as m;
import '../PlantInMyLocation/AppText.dart';

class ARMeasurementScreen extends StatefulWidget {
  const ARMeasurementScreen({super.key});

  @override
  State<ARMeasurementScreen> createState() => _ARMeasurementScreenState();
}

class _ARMeasurementScreenState extends State<ARMeasurementScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<Vector3> selectedPoints = [];
  List<ARNode> pointNodes = [];

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى منح إذن الكاميرا لاستخدام الواقع المعزز")),
      );
    }
  }

  void _onARViewCreated(ARSessionManager sessionManager,
      ARObjectManager objectManager, ARAnchorManager anchorManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager?.onPlaneOrPointTap = _processTap;
  }

  void _processTap(List<ARHitTestResult> hitResults) async {
    if (hitResults.isNotEmpty) {
      final hit = hitResults.first;
      Vector3 position = Vector3(
        hit.worldTransform.getTranslation().x,
        hit.worldTransform.getTranslation().y,
        hit.worldTransform.getTranslation().z,
      );

      // إضافة نقطة مرئية (كرة صغيرة)
      final pointNode = ARNode(
        type: NodeType.webGLB,
        position: position,
        scale: Vector3(0.02, 0.02, 0.02),
        uri: "https://modelviewer.dev/shared-assets/models/sphere.glb",
      );

      await arObjectManager?.addNode(pointNode);
      pointNodes.add(pointNode);
      selectedPoints.add(position);

      if (selectedPoints.length == 2) {
        _calculateDistance(selectedPoints[0], selectedPoints[1]);
        _drawLine(selectedPoints[0], selectedPoints[1]);
        selectedPoints.clear();
      }
    }
  }

  void _calculateDistance(Vector3 point1, Vector3 point2) {
    double distance = point1.distanceTo(point2);
    double distanceInCm = distance * 100;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("الطول المحسوب"),
        content: Text("الطول: ${distanceInCm.toStringAsFixed(2)} سم"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reset(); // إعادة تعيين النقاط والموديلات بعد إغلاق الدايلوق
            },
            child: Text("حسناً"),
          ),
        ],
      ),
    );
  }

  void _reset() {
    // إزالة النقاط المضافة سابقاً
    for (var node in pointNodes) {
      arObjectManager?.removeNode(node);
    }
    pointNodes.clear();
    selectedPoints.clear();
  }

  void _drawLine(Vector3 start, Vector3 end) async {
    Vector3 midPoint = (start + end) / 2;
    double length = start.distanceTo(end);

    // إيجاد محور الدوران والزاوية المناسبة
    Vector3 direction = end - start;
    direction.normalize();
    Quaternion rotation =
        Quaternion.fromTwoVectors(Vector3(0, 1, 0), direction);

    final lineNode = ARNode(
      type: NodeType.webGLB,
      position: midPoint,

      scale: Vector3(0.0005, length / 2, 0.0005), // قطر صغير للحصول على خط رفيع
      rotation: Vector4(rotation.x, rotation.y, rotation.z, rotation.w),
      uri: "https://github.com/tomaszew95/3d-models-pack/raw/main/cylinder.glb",
    );

    await arObjectManager?.addNode(lineNode);
  }

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
      body: ARView(
        onARViewCreated: (sessionManager, objectManager, anchorManager, _) {
          _onARViewCreated(sessionManager, objectManager, anchorManager);

          arSessionManager?.onInitialize(
            showFeaturePoints: true,
            showPlanes: true,
            handleTaps: true,
            showAnimatedGuide: false,
          );
        },
      ),
    );
  }
}
