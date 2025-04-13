import 'package:intl/intl.dart';

class Utils {
  static String imagesBack='https://images.unsplash.com/photo-1533644611662-442cba9ad938?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
//==============================================================================
  static String convertMessageTime(timestamp) {
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 24 && now.day == messageTime.day) {
      return DateFormat('hh:mm a', 'ar').format(messageTime);
    } else if (difference.inDays == 1 ||
        (now.day - messageTime.day == 1 && now.month == messageTime.month)) {
      return 'الأمس';
    } else {
      return DateFormat('d MMMM y', 'ar').format(messageTime);
    }
  }
}
