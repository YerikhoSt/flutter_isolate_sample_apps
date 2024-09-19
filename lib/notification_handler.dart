import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isolate_sample_apps/di/locator.dart';
import 'package:isolate_sample_apps/routes/app_route.dart';
import 'local_repository/notification_repository.dart';
import 'preference_info.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  try {
    // init firebase
    await Firebase.initializeApp();

    // init service locator
    if (!locator.isRegistered<PreferenceInfo>()) {
      // if firebase crashlytics not registered, init service locator
      await configureDependencies();
    }

    Map<String, dynamic> data = message.data;
    if (data.isEmpty) {
      // add data from notification to data
      data = {
        'title': message.notification?.title,
        'body': message.notification?.body,
      };
    }
    // insert new notification to preference info
    await locator<PreferenceInfo>().addNewNotification(notification: data);

    IsolateNameServer.lookupPortByName('notif_port')?.send(data);
  } catch (error) {
    rethrow;
  }
}

class NotificationInfo {
  static final NotificationInfo _instance = NotificationInfo._internal();

  late FirebaseMessaging _firebaseInstance;
  late InitializationSettings initializationSettings;
  late NotificationDetails platformChannelSpecifics;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');

  final initializationSettingsIOS = const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  //PLATFORM SPCIFIC HANDLER
  final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    '1',
    'Xellar',
    channelDescription: 'Xellar Notification',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'Xellar',
  );
  final iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
    threadIdentifier: 'Xellar',
    presentAlert: true,
    presentSound: true,
    presentBadge: true,
  );
  final macOSPlatformChannelSpecifics = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    threadIdentifier: 'Xellar',
  );

  factory NotificationInfo() {
    return _instance;
  }

  NotificationInfo._internal() {
    _firebaseInstance = FirebaseMessaging.instance;
    _firebaseInstance
        .requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    )
        .then((value) async {
      NotificationSettings settings = value;

      // subscribe to topic all
      await subscribeToTopic(
        topic: 'all',
      );

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: macOSPlatformChannelSpecifics,
      );

      // on tap local notification
      _onTapLocalNotification(
        flutterLocalNotificationsPlugin,
        initializationSettings,
      );
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      Map<String, dynamic> data = message.data;

      if (data.isEmpty) {
        // add data from notification to data
        data = {
          'title': message.notification?.title,
          'body': message.notification?.body,
        };
      }

      // insert notification data to notification repository
      await locator<NotificationRepository>().saveNotificationData(data);

      // check is android
      final android = message.notification?.android;
      if (android != null) {
        // if android, show local notification
        await flutterLocalNotificationsPlugin.show(
          Random().nextInt(99999999),
          data['title'],
          data['body'],
          platformChannelSpecifics,
          payload: jsonEncode(data).toString(),
        );
      }
    });
  }

  Future<void> unsubTopic({required String topic}) async {
    try {
      await _firebaseInstance.unsubscribeFromTopic(topic);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> subscribeToTopic({
    required String? topic,
  }) async {
    try {
      if (topic == null) {
        // if topic null, don't subscribe
        return;
      }

      await _firebaseInstance.subscribeToTopic(topic);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _onTapLocalNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    InitializationSettings initializationSettings,
  ) async {
    final notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true && notificationAppLaunchDetails?.notificationResponse?.payload != null) {
      final message = jsonDecode(
        notificationAppLaunchDetails?.notificationResponse?.payload ?? '',
      );

      // delayed 100ms
      await Future.delayed(Duration(milliseconds: 100));

      onTapHandler(message);
    }

    // FOREGROUND LOCAL
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        if (payload.payload != null) {
          final message = jsonDecode(payload.payload ?? '{}');

          // delayed 100ms
          await Future.delayed(Duration(milliseconds: 100));

          onTapHandler(message);
        }
      },
    );

    //----------------------- FCM TAP HANDLER --------------------------------
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) async {
      if (message != null) {
        // delayed 100ms
        await Future.delayed(const Duration(milliseconds: 100));

        onTapHandler(message.data);
      }
    });

    // FOREGROUND FCM
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // delayed 100ms
      await Future.delayed(const Duration(milliseconds: 100));

      onTapHandler(message.data);
    });
  }

  Future<void> onTapHandler(Map<String, dynamic> message) async {
    navigationService.push(const NotificationRoute());
  }
}
