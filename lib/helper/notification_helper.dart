import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  //initilize

  Future initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("ic_launcher");

    IOSInitializationSettings iosInitializationSettings =
    IOSInitializationSettings();

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'id',
        'Calenday',
        'welcome to calenday',
        importance: Importance.high,
        priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap("ic_launcher_round"),
       /* ticker: 'ticker'*/);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        id, title, body , platformChannelSpecifics,);
  }

  Future<void> zonedScheduleNotification(int id, title, body, String date, int hours, int option) async {

    await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.parse(tz.local, date).add(Duration(hours: hours - option)),
        NotificationDetails(
            android: AndroidNotificationDetails(
                'id',
                'Calenday',
                'welcome to calenday',
              largeIcon: DrawableResourceAndroidBitmap("ic_launcher_round"),

                playSound: true,
                priority: Priority.high,
                )),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }
  Future cancelAllNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future cancelNotification(id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /*Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {

    // display a dialog with the notification details, tap ok to go to another page
  }*/

}

