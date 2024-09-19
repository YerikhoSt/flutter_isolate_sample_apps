import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class LocatorModules {
  @lazySingleton
  @preResolve
  Future<SharedPreferences> get boxClient => SharedPreferences.getInstance();
}
