import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/sign_page.dart';
import '../screens/splash_page.dart';

part 'routes.g.dart';

/// Defines all the routes in the application.
enum AppRoute {
  splash,
  sign;

  static const Map<AppRoute, String> _paths = <AppRoute, String>{
    AppRoute.splash: '/',
    AppRoute.sign: '/sign',
  };

  static const Map<AppRoute, String> _names = <AppRoute, String>{
    AppRoute.splash: 'splash',
    AppRoute.sign: 'sign',
  };

  String get path => _paths[this]!;
  String get name => _names[this]!;
}

@TypedGoRoute<SplashRoute>(path: '/', name: 'splash')
class SplashRoute extends GoRouteData with _$SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<SignRoute>(path: '/sign', name: 'sign')
class SignRoute extends GoRouteData with _$SignRoute {
  const SignRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignPage();
}
