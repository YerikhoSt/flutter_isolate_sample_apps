import 'dart:isolate';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:isolate_sample_apps/routes/app_route.dart';

import 'di/locator.dart';
import 'local_repository/notification_repository.dart';
import 'preference_info.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ReceivePort receivePort = ReceivePort();

  @override
  void initState() {
    IsolateNameServer.removePortNameMapping('notif_port');
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'notif_port');

    receivePort.listen((message) async {
      // clear newNotifications
      await locator<PreferenceInfo>().clearNewNotifications();
      // insert new notification to preference info
      await locator<PreferenceInfo>().addNewNotification(
        notification: message,
      );
      final newNotifications = await locator<PreferenceInfo>().getNewNotifications();

      if (newNotifications.isNotEmpty) {
        // if newNotifications is not empty, update notification repository in hive
        for (final notification in newNotifications) {
          // insert to notification repository
          await locator<NotificationRepository>().saveNotificationData(
            notification,
          );
        }

        // clear newNotifications
        await locator<PreferenceInfo>().clearNewNotifications();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('notif_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Isolate Sample Apps'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Test Isolate Server',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigationService.push(const NotificationRoute());
        },
        tooltip: 'Notification',
        child: const Icon(Icons.notifications),
      ),
    );
  }
}
