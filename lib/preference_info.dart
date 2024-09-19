import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferenceInfo {
  Future<bool> addNewNotification({
    required Map<String, dynamic> notification,
  });
  Future<List<Map<String, dynamic>>> getNewNotifications();
  Future<bool> clearNewNotifications();
}

@LazySingleton(as: PreferenceInfo)
class PreferenceInfoImpl implements PreferenceInfo {
  final SharedPreferences shared;

  PreferenceInfoImpl({
    required this.shared,
  });

  static const String notificationKey = 'notification';

  @override
  Future<bool> addNewNotification({
    required Map<String, dynamic> notification,
  }) async {
    try {
      // Get the list of notifications
      final notificationList = await getNewNotifications();

      // Add the new notification to the list
      notificationList.add(notification);

      // Convert the list to a string
      final notificationListString = notificationList.map((e) {
        return jsonEncode(e);
      }).toList();

      // Save the list to the shared preferences
      final result = await shared.setStringList(
        notificationKey,
        notificationListString,
      );

      return result;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNewNotifications() async {
    try {
      // Get the list of notifications
      List<String>? notificationList = shared.getStringList(notificationKey);

      // If the list is null, set it to an empty list
      notificationList ??= [];

      // Convert the list to a map
      final result = notificationList.map(
        (e) {
          return jsonDecode(e) as Map<String, dynamic>;
        },
      ).toList();

      return result;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> clearNewNotifications() async {
    try {
      // Clear the list of notifications
      final result = await shared.remove(notificationKey);

      return result;
    } catch (error) {
      rethrow;
    }
  }
}
