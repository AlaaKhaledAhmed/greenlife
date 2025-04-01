import 'package:flutter/material.dart';
import 'package:greenlife/widget/AppText.dart';

class PlantsDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const PlantsDetails({super.key, required this.data});

  @override
  State<PlantsDetails> createState() => _PlantsDetailsState();
}

class _PlantsDetailsState extends State<PlantsDetails> {
  @override
  Widget build(BuildContext context) {
    // استخراج البيانات من الـ Firestore
    final String name = widget.data['name'] ?? "اسم غير متوفر";
    final List<dynamic> commonNames = widget.data['common_names'] ?? [];
    final String scientificName = widget.data['scientific_name'] ?? "غير معروف";
    final String description =
        widget.data['description'] ?? "لا يوجد وصف متاح.";
    final String careLevel = widget.data['care_level'] ?? "غير محدد";
    final List<dynamic> images = widget.data['images'] ?? [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: "معلومات النبات",
          fontSize: 22,
          color: Colors.white,
        ),

        backgroundColor: Colors.green, // AppBar color
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ عرض الصورة الرئيسية
                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      images[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ اسم النبات الرئيسي
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                // ✅ الأسماء الشائعة (إذا كانت موجودة)
                if (commonNames.isNotEmpty)
                  Text(
                    "الأسماء الشائعة: ${commonNames.join(", ")}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                const SizedBox(height: 5),

                // ✅ الاسم العلمي
                Text(
                  "الاسم العلمي: $scientificName",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 15),

                // ✅ عرض جميع الصور المرتبطة بالنبات
                if (images.isNotEmpty)
                  Container(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                // ✅ العنوان: "الوصف"
                const Text(
                  "الوصف",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),

                // ✅ وصف النبات
                Container(
                  width: double.maxFinite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 15),

                // ✅ مستوى العناية
                Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.green),
                    const SizedBox(width: 5),
                    Text("العناية: $careLevel",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 100),

                // ✅ أزرار الحفظ والمشاركة
                Row(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.camera_alt),
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      child: Icon(Icons.share),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "حفظ إلى نباتاتي",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
