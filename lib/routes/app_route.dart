import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../di/locator.dart';
import '../home_page.dart';
import '../navigation_service.dart';
import '../notification_page.dart';

part 'app_route.gr.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<CupertinoRoute> get routes => [];
}

final NavigationService navigationService = locator<NavigationService>();

final BuildContext globalContext = navigationService.currentContext!;
