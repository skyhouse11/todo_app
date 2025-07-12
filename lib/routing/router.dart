import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_app/routing/routes.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) =>
    GoRouter(routes: $appRoutes, initialLocation: '/init');
