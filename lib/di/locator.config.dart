// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:isolate_sample_apps/di/locator_module.dart' as _i988;
import 'package:isolate_sample_apps/local_repository/app_repository.dart'
    as _i37;
import 'package:isolate_sample_apps/local_repository/notification_repository.dart'
    as _i649;
import 'package:isolate_sample_apps/navigation_service.dart' as _i60;
import 'package:isolate_sample_apps/preference_info.dart' as _i132;
import 'package:isolate_sample_apps/routes/app_route.dart' as _i1012;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final locatorModules = _$LocatorModules();
    gh.singleton<_i60.NavigationService>(() => _i60.NavigationService());
    gh.singleton<_i1012.AppRouter>(() => _i1012.AppRouter());
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => locatorModules.boxClient,
      preResolve: true,
    );
    gh.lazySingleton<_i649.NotificationRepository>(
        () => _i649.NotificationRepository());
    gh.lazySingleton<_i37.BaseRepository>(
        () => _i37.AppRepository(gh<String>()));
    gh.lazySingleton<_i132.PreferenceInfo>(
        () => _i132.PreferenceInfoImpl(shared: gh<_i460.SharedPreferences>()));
    return this;
  }
}

class _$LocatorModules extends _i988.LocatorModules {}
