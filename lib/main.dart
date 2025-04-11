import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenlife/home_screen.dart';
import 'package:greenlife/main_page.dart';
import 'package:greenlife/map_screen.dart';
import 'package:greenlife/profile.dart';
import 'package:greenlife/welcome_page.dart';
import 'package:greenlife/widget/app_color.dart';
import 'Notification/NotificationController.dart';
import 'Notification/initial_notification.dart';
import 'ar/add_measurement.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///init local notification
  LocalNotificationServices.initialize();
  initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.white,
        useMaterial3: true,
        fontFamily: GoogleFonts.tajawal().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      //home: LoginPage(),
   home: MainScreen(firstName: 'firstName', lastName: 'lastName'),
   //   home:GoogleMapsScreen(),

      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}
// //
