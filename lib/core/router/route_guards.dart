import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

class AuthGuard {
  static String? redirectLogic(BuildContext context, GoRouterState state) {
    // TODO: Implement authentication check when auth system is ready
    // final isAuthenticated = ref.watch(authProvider).hasValue;
    // if (!isAuthenticated && !_isAuthRoute(state.location)) {
    //   return RoutePaths.login;
    // }
    return null;
  }

  static bool _isAuthRoute(String location) {
    return location == RoutePaths.login ||
        location == RoutePaths.signup ||
        location == RoutePaths.resetPassword;
  }
}
