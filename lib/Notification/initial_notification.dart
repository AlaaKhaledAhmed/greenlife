import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'MessageDetails.dart';

class LocalNotificationServices {
  static String channelKey = 'basic_channel';
  static String channelGroupKey = 'basic_channel_group';
  static String channelName = 'Basic notifications';
  static String channelGroupName = 'Basic group';
  static String localTimeZone = '';

  /// Initialize local notification ------------------------------------------------------------------------------------
  static Future<void> initialize() async {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelGroupKey: channelGroupKey,
            channelKey: channelKey,
            channelName: channelName,
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.green,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            criticalAlerts: true,
          )
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: channelGroupKey,
            channelGroupName: channelGroupName,
          )
        ],
        debug: true);
    localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    print('localTimeZone: $localTimeZone');
  }

  /// Display schedule notification ------------------------------------------------------------------------------------
  static showScheduleNotification(MessageDetails message) async {
    try {
      DateTime notificationTime = DateTime(
        message.year ?? DateTime.now().year,
        message.month ?? DateTime.now().month,
        message.day ?? DateTime.now().day,
        message.hour,
        message.minute,
      );

      // تحديد الوقت الأولي للإشعار بناءً على المدخلات من المستخدم
      NotificationCalendar notificationCalendar = NotificationCalendar(
        preciseAlarm: true, // تحديد وقت دقيق للإشعار
        allowWhileIdle: true,
        hour: notificationTime.hour,
        minute: notificationTime.minute,
        day: notificationTime.day,
        month: notificationTime.month,
        year: notificationTime.year,
        timeZone: localTimeZone, // استخدام التوقيت المحلي
        repeats: false, // لا تكرار للإشعار الأولي
      );

      // إنشاء الإشعار الأولي الذي سيتم تنفيذه في نفس الوقت
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: message.id,
          title: message.title,
          body: message.body,
          channelKey: channelKey,
          actionType: ActionType.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true, // إيقاظ الشاشة عند وصول الإشعار
        ),
        schedule: notificationCalendar, // جدولة الإشعار الأولي
      );

      // في حالة التكرار، نقوم بجدولة إشعار آخر بعد المدة المحددة
      if (message.repeats) {
        DateTime nextNotificationTime = notificationTime;

        if (message.repeatInterval == "ايام") {
          nextNotificationTime =
              notificationTime.add(Duration(days: message.repeatEvery));
        } else if (message.repeatInterval == "اسابيع") {
          nextNotificationTime =
              notificationTime.add(Duration(days: message.repeatEvery * 7));
        }

        NotificationCalendar repeatCalendar = NotificationCalendar(
          preciseAlarm: true,
          allowWhileIdle: true,
          hour: nextNotificationTime.hour,
          minute: nextNotificationTime.minute,
          day: nextNotificationTime.day,
          month: nextNotificationTime.month,
          year: nextNotificationTime.year,
          timeZone: localTimeZone,
          repeats: true, // تكرار الإشعار بعد الفترة المحددة
        );

        // جدولة الإشعار المتكرر
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: message.id + uniqueId(), // استخدام ID مختلف للإشعار المتكرر
            title: message.title,
            body: message.body,
            channelKey: channelKey,
            actionType: ActionType.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
          ),
          schedule: repeatCalendar, // جدولة الإشعار المتكرر
        );
      }
    } catch (e) {
      print('\x1B[33m Error in show notification: ${e.toString()}\x1B[0m');
    }
  }

  /// Cancel notification ===================================================================
  static Future<void> cancelNotification(int notificationId) async {
    await AwesomeNotifications().cancel(notificationId).then((value) {
      print('AwesomeNotifications cancel');
    });
  }

  /// Unique notification ID
  static int uniqueId() {
    const characters = '0123456789';
    Random random = Random();
    String id = String.fromCharCodes(Iterable.generate(
        6, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
    return int.parse(id);
  }
}
