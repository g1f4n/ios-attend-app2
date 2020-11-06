// import 'dart:io';

import 'package:attend_app/Home_Staff.dart';
import 'package:attend_app/Home_Leader.dart';
import 'package:attend_app/absence_radius_check_select.dart';
import 'package:attend_app/absence_reason.dart';
// import 'package:attend_app/actions/actions.dart';
import 'package:attend_app/camera/camera.dart';
import 'package:attend_app/camera/camera_file.dart';
import 'package:attend_app/camera/camera_login.dart';
import 'package:attend_app/camera/camera_vision.dart';
import 'package:attend_app/cuti_reason.dart';
import 'package:attend_app/dashboard_leader.dart';
import 'package:attend_app/display_data.dart';
import 'package:attend_app/leave_reason.dart';
import 'package:attend_app/login.dart';
import 'package:attend_app/parse_init/parse_init.dart';
import 'package:attend_app/request_list.dart';
// import 'package:attend_app/store/AppState.dart';
// import 'package:attend_app/store/store.dart';
import 'package:attend_app/submit.dart';
// import 'package:attend_app/utils/notificationHelper.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// NotificationAppLaunchDetails notificationAppLaunchDetails;
// Store<AppState> store;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initStore();
  // store = getStore();
  // notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  // await initNotifications(flutterLocalNotificationsPlugin);
  // requestIOSPermissions(flutterLocalNotificationsPlugin);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    ParseInit().initialize().then((value) {
      runApp(MyApp());
    });
  });
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  SharedPreferences prefs;
  bool hasLogin;
  String role;
  // bool hasSetNotif;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    getDataProfile();
    // setNotification();
    // firebaseSetup();
  }

  // firebaseSetup() {
  //   _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("onMessage: $message");
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print("onLaunch: $message");
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print("onResume: $message");
  //     },
  //   );
  //   _firebaseMessaging.requestNotificationPermissions(
  //       const IosNotificationSettings(
  //           sound: true, badge: true, alert: true, provisional: true));
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings) {
  //     print("Settings registered: $settings");
  //   });
  // }

  getDataProfile() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      hasLogin = prefs.getBool('hasLogin');
      if (hasLogin == null) {
        hasLogin = false;
      } else {
        if (hasLogin) {
          role = prefs.getString('roles');
        }
      }
      // hasSetNotif = prefs.getBool('hasSetNotif');
      // if (hasSetNotif == null) {
      //   hasSetNotif = false;
      // }
    });
  }

  // setNotification() async {
  //   DateTime now = await NTP.now();
  //   if (!hasSetNotif) {
  //     _configureCustomReminder(
  //         true, now, 8, 50, 'Saatnya untuk absen masuk.', Time(8, 50, 0));
  //     _configureCustomReminder(
  //         true, now, 17, 00, 'Saatnya untuk absen keluar.', Time(17, 0, 0));
  //     prefs.setBool('hasSetNotif', true);
  //   } else {}
  // }

  // void _configureCustomReminder(
  //     bool value, DateTime now, int hour, int minute, String body, Time time) {
  //   if (value) {
  //     var notificationTime =
  //         new DateTime(now.year, now.month, now.day, hour, minute);

  //     getStore().dispatch(SetReminderAction(
  //         time: notificationTime.toLocal().toString(),
  //         name: body,
  //         repeat: RepeatInterval.Daily));

  //      scheduleNotification(
  //          flutterLocalNotificationsPlugin, '4', body, notificationTime);
  //     showDailyAtTime(flutterLocalNotificationsPlugin, '4', body, time);
  //   } else {
  //     getStore().dispatch(RemoveReminderAction(body));
  //     turnOffNotificationById(flutterLocalNotificationsPlugin, 4);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dika Attend',
      home: hasLogin == true ? _homeLog() : Login(),
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => Login(),
        '/homeStaff': (BuildContext context) => HomeStaff(),
        '/homeLeader': (BuildContext context) => HomeLeader(),
        '/radiusCheck': (BuildContext context) => RadiusCheck(),
        '/absenceReason': (BuildContext context) => AbsenceReason(),
        '/leaveReason': (BuildContext context) => LeaveReason(
              imageFilePath: null,
            ),
        '/cutiReason': (BuildContext context) => CutiReason(),
        '/cameraSelfie': (BuildContext context) => CameraSelfie(),
        '/cameraFile': (BuildContext context) => CameraFile(),
        '/cameraLogin': (BuildContext context) => CameraLogin(),
        '/cameraVision': (BuildContext context) => CameraVision(),
        '/submit': (BuildContext context) => Submit(),
        '/display': (BuildContext context) => DisplayData(),
        '/requestList': (BuildContext context) => RequestList(),
        '/dashboard': (BuildContext context) => LeaderDashboard(),
      },
    );
  }

  Widget _homeLog() {
    if (role == 'staff') {
      return HomeStaff();
    } else {
      return HomeLeader();
    }
  }
}
