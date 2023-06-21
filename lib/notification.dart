import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'inbox',
          channelName: 'Inbox notifications',
          channelDescription: 'Notification channel for basic notifications',
          importance: NotificationImportance.Max,
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
      ],
    );
  }

  static Future<void> showNotification(String sender, String message) async {
    String? otpCode = getCode(message);
    bool isOtpMessage = otpCode != null;

    List<NotificationActionButton> actionButtons = [
      NotificationActionButton(
        key: 'action_button_mark_as_read',
        label: 'Mark as Read',
        autoDismissible: true,
      ),
    ];

    if (isOtpMessage) {
      actionButtons.insert(
        0,
        NotificationActionButton(
          key: 'action_button_copy_otp',
          label: 'Copy Otp:- $otpCode',
          icon: 'resource://drawable/copy_icon',
          autoDismissible: true,
        ),
      );
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'inbox',
        title: sender,
        body: message,
        actionType: ActionType.Default,
        notificationLayout: NotificationLayout.Default,
        payload: {'sender': sender, 'message': message},
      ),
      actionButtons: actionButtons,
    );
  }

  static String? getCode(String sms) {
    RegExp regex = RegExp(r'(\b\d{4,6}\b)');
    final Match? match = regex.firstMatch(sms);
    debugPrint(match?.group(0));
    return match?.group(0);
  }
}

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   static Future<void> showNotification(String sender, String message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: 'channel_description',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);


//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       sender,
//       message,
//       platformChannelSpecifics,
//     );
//   }
// }
