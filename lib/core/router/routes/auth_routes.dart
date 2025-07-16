import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../index.dart';
import 'package:todo_app/features/auth/screens/index.dart';

part 'auth_routes.g.dart';

@TypedGoRoute<LoginRoute>(path: RoutePaths.login)
class LoginRoute extends GoRouteData with _$LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }
}

@TypedGoRoute<SignUpRoute>(path: RoutePaths.signup)
class SignUpRoute extends GoRouteData with _$SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignUpScreen();
  }
}

@TypedGoRoute<ResetPasswordRoute>(path: RoutePaths.resetPassword)
class ResetPasswordRoute extends GoRouteData with _$ResetPasswordRoute {
  const ResetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ResetPasswordScreen();
  }
}
