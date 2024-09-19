import 'dart:async';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

abstract class BaseRepository {
  Future<void> close();
  Future<void> clear();
}

@LazySingleton(as: BaseRepository)
class AppRepository implements BaseRepository {
  final String name;

  AppRepository(this.name);

  late Box box = Hive.box(name);

  /// Returns the value associated with the given [key]. If the key does not
  /// exist, `null` is returned.
  ///
  /// If [defaultValue] is specified, it is returned in case the key does not
  /// exist.
  get<E>(dynamic key, {E? defaultValue}) {
    return box.get(key, defaultValue: defaultValue);
  }

  /// Returns the value associated with the n-th key.
  getAt(int index) {
    return box.get(index);
  }

  /// Returns entire box values
  Iterable<dynamic> getAll() {
    return box.values;
  }

  Iterable<dynamic> getKeys() {
    return box.keys;
  }

  /// Returns a broadcast stream of change events.
  ///
  /// If the [key] parameter is provided, only events for the specified key are
  /// broadcasted.
  Stream<BoxEvent> watch<E>(dynamic key) {
    return box.watch(key: key);
  }

  /// Saves the [key] - [value] pair.
  Future<void> put<E>(dynamic key, E value) async {
    return await box.put(key, value);
  }

  /// Associates the [value] with the n-th key. An exception is raised if the
  /// key does not exist.
  Future<void> putAt<E>(int index, E value) async {
    return await box.putAt(index, value);
  }

  /// Saves all the key - value pairs in the [entries] map.
  Future<void> putAll<E>(Map<dynamic, E> entries) async {
    return await box.putAll(entries);
  }

  /// Saves the [value] with an auto-increment key.
  Future<int> add<E>(E value) async {
    return await box.add(value);
  }

  /// Saves all the [values] with auto-increment keys.
  Future<Iterable<int>> addAll<E>(Iterable<E> values) async {
    return await box.addAll(values);
  }

  /// Deletes the given [key] from the box.
  ///
  /// If it does not exist, nothing happens.
  Future<void> delete(dynamic key) async {
    return await box.delete(key);
  }

  /// Deletes the n-th key from the box.
  ///
  /// If it does not exist, nothing happens.
  Future<void> deleteAt(int index) async {
    return box.deleteAt(index);
  }

  /// Deletes all the given [keys] from the box.
  ///
  /// If a key does not exist, it is skipped.
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    return await box.deleteAll(keys);
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    return await box.get(key)?.cast<String, dynamic>();
  }

  @override
  Future<void> close() async {
    await box.close();
  }

  @override
  Future<int> clear() async {
    return await box.clear();
  }
}
