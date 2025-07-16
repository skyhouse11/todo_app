import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'index.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) =>
    GoRouter(initialLocation: RoutePaths.login, routes: $appRoutes);
