import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  onSelectNotification(String? payload) async {
    //Navigate to wherever you want
  }

  // Future<void> scheduleNotification({id, title, body, time}) async {
  //   try {
  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //         id,
  //         title,
  //         body,
  //         tz.TZDateTime.from(time, tz.local),
  //         const NotificationDetails(
  //             android: AndroidNotificationDetails('your channel id',
  //                 'your channel name', 'your channel description')),
  //         androidAllowWhileIdle: true,
  //         uiLocalNotificationDateInterpretation:
  //             UILocalNotificationDateInterpretation.absoluteTime);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payload,
      required DateTime scheduleNotificationDateTime}) async {
    tz.initializeTimeZones();
    return flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduleNotificationDateTime, tz.local),
        await const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  // Future<void> showNotifications({id, title, body, payload}) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //           'your channel id', 'your channel name', 'your channel description',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           ticker: 'ticker');
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin
  //       .show(id, title, body, platformChannelSpecifics, payload: payload);
  // }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    return flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        await const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description')));
  }
}
