// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$splashRoute, $signRoute];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/',
  name: 'splash',

  factory: _$SplashRoute._fromState,
);

mixin _$SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signRoute => GoRouteData.$route(
  path: '/sign',
  name: 'sign',

  factory: _$SignRoute._fromState,
);

mixin _$SignRoute on GoRouteData {
  static SignRoute _fromState(GoRouterState state) => const SignRoute();

  @override
  String get location => GoRouteData.$location('/sign');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
