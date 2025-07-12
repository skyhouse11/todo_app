import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/views/auth/forgot_password_page.dart';
import 'package:todo_app/views/auth/login_page.dart';
import 'package:todo_app/views/auth/sign_up_page.dart';
import 'package:todo_app/views/init/init_page.dart';

part 'routes.g.dart';

@TypedGoRoute<InitRoute>(path: '/init', name: 'init')
class InitRoute extends GoRouteData with _$InitRoute {
  const InitRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const InitPage();
  }
}

@TypedGoRoute<LoginRoute>(path: '/login', name: 'login')
class LoginRoute extends GoRouteData with _$LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

@TypedGoRoute<SignUpRoute>(path: '/sign-up', name: 'signUp')
class SignUpRoute extends GoRouteData with _$SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignUpPage();
  }
}

@TypedGoRoute<ForgotPasswordRoute>(
  path: '/forgot-password',
  name: 'forgotPassword',
)
class ForgotPasswordRoute extends GoRouteData with _$ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordPage();
  }
}
