import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) => GoRouter(
  debugLogDiagnostics: true,
  initialLocation: AppRoute.splash.path,
  routes: $appRoutes,
  errorBuilder: (BuildContext context, GoRouterState state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);
