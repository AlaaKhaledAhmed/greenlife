import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'PlantInMyLocation/plant_details.dart';

class MyFavoritePlants extends StatefulWidget {
  const MyFavoritePlants({super.key});

  @override
  State<MyFavoritePlants> createState() => _MyFavoritePlantsState();
}

class _MyFavoritePlantsState extends State<MyFavoritePlants> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _removeFromFavorites(String docId) async {
    // حذف النبات من مجموعة 'my_plants'
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("my_plants")
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: Text("الرجاء تسجيل الدخول أولاً"));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('نباتاتي',
            style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("my_plants")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final favoriteDocs = snapshot.data?.docs ?? [];

            if (favoriteDocs.isEmpty) {
              return const Center(child: Text("📭 لا يوجد نباتات مفضلة"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteDocs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final data = favoriteDocs[index].data() as Map<String, dynamic>;
                final docId = favoriteDocs[index].id;

                return ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image.network(
                        data['images'][0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    data['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['family']),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      await _removeFromFavorites(docId);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PlantsDetails(data: data)),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
