import 'package:intl/intl.dart';

class Utils {
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
