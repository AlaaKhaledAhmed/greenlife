
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/Notification/AppDropList.dart';
import 'package:greenlife/Notification/MessageDetails.dart';
import 'package:greenlife/PlantInMyLocation/AppSize.dart';
import 'package:greenlife/PlantInMyLocation/AppText.dart';

import 'initial_notification.dart';

class AddNotification extends StatefulWidget {
  const AddNotification({super.key});

  @override
  State<AddNotification> createState() => _AddNotificationState();
}

class _AddNotificationState extends State<AddNotification> {
  String selectedTask = "الري";
  TimeOfDay selectedTime = TimeOfDay.now(); // Default to current time
  bool useSmartSchedule = false;
  int repeatValue = 1;
  String repeatUnit = "ايام";
  DateTime selectedDate = DateTime.now(); // Default to today's date
  TextEditingController plantNameController =
      TextEditingController(); // Controller for plant name

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.brown[50], // Background color as beige
        appBar: AppBar(
          centerTitle: true,
          title: AppText(
            text: "التذكير بالعناية",
            fontSize:22,
            color: Colors.white,
          ),

          backgroundColor: Colors.green, // AppBar color
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                  "ذكرني ب",
                  selectedTask,
                  ["الري", "التسميد", "التقليم"],
                  (value) => setState(() => selectedTask = value ?? "الري")),
              const SizedBox(height: 20),
              _buildTextField("اسم النبتة", plantNameController),
              const SizedBox(height: 20),
              _buildTimePicker("وقت الإشعار", selectedTime, _pickTime),
              const SizedBox(height: 20),
              _buildDatePicker("تاريخ الإشعار", selectedDate, _pickDate),
              const SizedBox(height: 20),
              _buildSwitch("تكرار الاشعار", useSmartSchedule, (value) {
                setState(() {
                  useSmartSchedule = value;
                });
              }),
              const SizedBox(height: 12),
              if (useSmartSchedule) _buildRepeater(),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedTask.isEmpty ||
                        plantNameController.text.isEmpty) {
                      // Ensure the user has selected the task type and plant name
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("يرجى اختيار نوع التذكير واسم النبتة")));
                    } else {
                      // Create a MessageDetails object based on the user input
                      MessageDetails m = MessageDetails(
                          id: LocalNotificationServices.uniqueId(),
                          title: "تذكير ب$selectedTask",
                          body:
                              "تذكير ب$selectedTask لنبتة ${plantNameController.text}",
                          hour: selectedTime.hour,
                          minute: selectedTime.minute,
                          repeats: useSmartSchedule,
                          repeatInterval: repeatUnit,
                          repeatEvery: repeatValue,
                          active: 1,
                          day: selectedDate.day,
                          month: selectedDate.month,
                          year: selectedDate.year);
                      // Show the notification
                      await LocalNotificationServices.showScheduleNotification(
                          m);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Center(
                        child: Text(
                            "تمت إضافة تنبيه ب$selectedTask لنبتة ${plantNameController.text}"),
                      )));
                    }
                  },
                  child: const Text("تأكيد", style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, value, List<String> items, onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 4),
        AppDropList(
          validator: (v) {},
          hintText: "اختر من القائمة",
          onChanged: onChanged,
          items: items,
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
      subtitle: Text(
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      trailing: Icon(Icons.alarm, color: Colors.grey.shade700),
      onTap: onTap,
    );
  }

  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
      subtitle: Text(
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.grey.shade700),
      onTap: onTap,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "أدخل اسم النبتة",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        Switch(
          value: value,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRepeater() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.refresh,
                color: Colors.black,
                size: AppSize.iconsSize,
              ),
              SizedBox(
                width: 5,
              ),
              AppText(
                text: 'كرر',
                fontSize: AppSize.labelSize,
                color: Colors.black,
              )
            ],
          ),
          Divider(),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: AppText(
                text: 'كل',
                fontSize: AppSize.labelSize,
                color: Colors.black,
              )),
              Expanded(
                  child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (v) {
                  setState(() {
                    repeatValue = v + 1;
                  });
                },
                children: List<int>.generate(100, (int index) => index + 1,
                        growable: true)
                    .map((e) => AppText(
                          text: e.toString(),
                          fontSize: AppSize.labelSize,
                          color: Colors.black,
                        ))
                    .toList(),
              )),
              Expanded(
                  child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (v) {
                  setState(() {
                    repeatUnit = v == 0 ? "ايام" : "اسابيع";
                  });
                },
                children: [
                  AppText(
                    text: 'ايام',
                    fontSize: AppSize.labelSize,
                    color: Colors.black,
                  ),
                  AppText(
                    text: 'اسابيع',
                    fontSize: AppSize.labelSize,
                    color: Colors.black,
                  ),
                ],
              )),
            ],
          )
        ],
      ),
    );
  }
}
