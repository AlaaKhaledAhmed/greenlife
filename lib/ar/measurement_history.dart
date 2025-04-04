import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/ar/add_measurement.dart';
import 'package:greenlife/widget/AppSize.dart';
import 'package:greenlife/widget/AppText.dart';
import 'package:greenlife/widget/app_color.dart';
import 'package:greenlife/widget/utils.dart';

class MeasurementHistoryPage extends StatelessWidget {
  const MeasurementHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(
            text: "سجل القياسات", fontSize: 22, color: Colors.white),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColor.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMeasurement()),
              );
            },
          )
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("measurement")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var docs = snapshot.data!.docs;
            return docs.isEmpty
                ? Center(
                    child: AppText(
                        text: 'لا توجد قياسات حالية',
                        fontSize: AppSize.smallSubText),
                  )
                : ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                              "القياس: ${data['distance'].toStringAsFixed(2)} سم"),
                          subtitle: AppText(
                            fontWeight: FontWeight.bold,
                            text: "الحالة: ${data['status']}",
                            fontSize: AppSize.smallSubText,
                            color: data['status'] == "تراجع"
                                ? Colors.red
                                : data['status'] == "نمو ثابت"
                                    ? Colors.blue
                                    : Colors.green,
                          ),
                          trailing:
                              Text(Utils.convertMessageTime(data['timestamp'])),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  // String _formatTimestamp(Timestamp timestamp) {
  //   DateTime dateTime = timestamp.toDate();
  //   return "${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}";
  // }
}
