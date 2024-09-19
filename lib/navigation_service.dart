import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'di/locator.dart';
import 'routes/app_route.dart';

@singleton
class NavigationService {
  StackRouter get _router => locator<AppRouter>();

  GlobalKey<NavigatorState> get navigationKey => _router.navigatorKey;
  BuildContext? get currentContext => navigationKey.currentState!.context;

  Future<T?> push<T extends Object?>(PageRouteInfo<dynamic> route, {void Function(NavigationFailure)? onFailure}) => _router.push(
        route,
        onFailure: onFailure,
      );

  Future<T?> pushAndPopUntil<T extends Object?>(
    PageRouteInfo<dynamic> route, {
    required bool Function(Route<dynamic>) predicate,
    bool scopedPopUntil = true,
    void Function(NavigationFailure)? onFailure,
  }) =>
      _router.pushAndPopUntil(
        route,
        predicate: predicate,
        scopedPopUntil: scopedPopUntil,
        onFailure: onFailure,
      );

  void popUntil(
    bool Function(Route<dynamic>) predicate, {
    bool scoped = true,
  }) {
    _router.popUntil(
      predicate,
      scoped: scoped,
    );
  }

  Future<bool> maybePop<T extends Object?>([T? result]) => _router.maybePop(result);
}
