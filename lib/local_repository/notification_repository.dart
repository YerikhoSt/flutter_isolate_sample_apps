import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'app_repository.dart';

@LazySingleton()
class NotificationRepository {
  static NotificationRepository? _singleton;
  AppRepository? _appRepository;

  factory NotificationRepository() {
    _singleton ??= NotificationRepository._internal();

    return _singleton!;
  }

  NotificationRepository._internal() {
    _appRepository = AppRepository('notification');
  }

  get<E>(E key) {
    return _appRepository!.get(key);
  }

  Future<void> save<E>(String key, E entries) async {
    await _appRepository!.put(key, entries);
  }

  Future<void> delete(dynamic key) async {
    await _appRepository!.delete(key);
  }

  Future<void> close() async {
    await _appRepository!.close();
  }

  Future<void> putAt<E>(int index, E value) async {
    await _appRepository!.putAt(index, value);
  }

  //   Future<void> putAll<E>(E value) async {
  //   await _appRepository!.putAll(value);
  // }

  Future<int> clear() async {
    return await _appRepository!.clear();
  }

  List? getAll() {
    return _appRepository?.getAll().toList();
  }

  Future<int> add<E>(E value) async {
    return await _appRepository!.add(value);
  }

  Future<void> updateNotifBadge() async {
    if (await FlutterAppBadger.isAppBadgeSupported() == true) {
      var unread = _appRepository!.getAll().toList();

      unread.removeWhere((element) => element['is_read'] == true);
      debugPrint('updateBadgeCount : ${unread.length}');
      FlutterAppBadger.updateBadgeCount(unread.length);
    }
  }

  Future<void> saveNotificationData(dynamic messageData) async {
    try {
      if (messageData == null) {
        return;
      }

      if (getAll() != null) {
        if (getAll()!.length > 50) {
          _appRepository!.deleteAt(0);
        }
      }

      // update badge
      updateNotifBadge();
      const uuid = Uuid();

      final Map<String, dynamic> data = {
        "id": uuid.v1(),
        "title": messageData['title'],
        "description": messageData['desc'],
      };

      if (data['title'] == null || data['title'] == '') {
        // if title is null or empty, don't insert
        return;
      }

      // insert to notification repository
      await _appRepository!.add(data);
    } catch (error) {
      rethrow;
    }
  }
}
