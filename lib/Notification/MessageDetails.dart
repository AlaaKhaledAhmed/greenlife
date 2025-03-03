// class MessageDetails {
//   int id;
//   String title;
//   String body;
//   int hour;
//   int minute;
//   int? day;
//   int? year;
//   int? month;
//   bool repeats;
//   int active;
//   MessageDetails({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.hour,
//     required this.minute,
//     this.repeats = false,
//     this.active = 1,
//     this.day,
//     this.month,
//     this.year,
//   });
// }
class MessageDetails {
  int id;
  String title;
  String body;
  int hour;
  int minute;
  int? day;
  int? year;
  int? month;
  bool repeats;
  String repeatInterval; // "أيام" or "أسابيع"
  int repeatEvery; // How many days or weeks to repeat
  int active;

  MessageDetails({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    this.repeats = false,
    this.repeatInterval = "ايام", // Default to "أيام"
    this.repeatEvery = 1, // Default repeat every 1 day
    this.active = 1,
    this.day,
    this.month,
    this.year,
  });
}
