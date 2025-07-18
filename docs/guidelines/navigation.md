# Navigation Guidelines - GoRouter 16.x

This guide provides comprehensive navigation patterns and best practices for implementing GoRouter 16.x in Flutter applications, with specific focus on integration with Riverpod state management and modern Flutter development practices.

## Table of Contents

1. [Setup and Configuration](#setup-and-configuration)
2. [Declarative Routing Patterns](#declarative-routing-patterns)
3. [Deep Linking Implementation](#deep-linking-implementation)
4. [Nested Navigation and ShellRoute](#nested-navigation-and-shellroute)
5. [Authentication Guards and Redirects](#authentication-guards-and-redirects)
6. [Navigation State Management with Riverpod](#navigation-state-management-with-riverpod)
7. [Error Handling and 404 Pages](#error-handling-and-404-pages)
8. [Web-Specific Navigation](#web-specific-navigation)
9. [Testing Navigation Flows](#testing-navigation-flows)
10. [Performance Optimization](#performance-optimization)
11. [Migration Patterns](#migration-patterns)
12. [Accessibility Considerations](#accessibility-considerations)

## Setup and Configuration

### Basic GoRouter Setup

```dart
// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/todos',
        name: 'todos',
        builder: (context, state) => const TodosScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});
```

### Integration with MaterialApp

```dart
// lib/main.dart
class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Todo App',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
```

### Route Configuration with Type Safety

```dart
// lib/router/routes.dart
enum AppRoute {
  home('/'),
  todos('/todos'),
  todoDetail('/todos/:id'),
  profile('/profile'),
  settings('/settings'),
  login('/login');

  const AppRoute(this.path);
  final String path;
}

extension AppRouteExtension on AppRoute {
  String location({Map<String, String> pathParameters = const {}}) {
    String result = path;
    for (final entry in pathParameters.entries) {
      result = result.replaceAll(':${entry.key}', entry.value);
    }
    return result;
  }
}
```

## Declarative Routing Patterns

### Hierarchical Route Structure

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      // Public routes
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
      
      // Protected routes with shell
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/todos',
            name: AppRoute.todos.name,
            builder: (context, state) => const TodosScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: AppRoute.todoDetail.name,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TodoDetailScreen(todoId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: AppRoute.profile.name,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Authentication routes
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});
```

### Route Parameters and Query Strings

```dart
// Path parameters
GoRoute(
  path: '/todos/:todoId/comments/:commentId',
  builder: (context, state) {
    final todoId = state.pathParameters['todoId']!;
    final commentId = state.pathParameters['commentId']!;
    return CommentScreen(todoId: todoId, commentId: commentId);
  },
),

// Query parameters
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    final category = state.uri.queryParameters['category'];
    return SearchScreen(query: query, category: category);
  },
),
```

## Deep Linking Implementation

### URL-Based Navigation

```dart
// Navigation methods
class NavigationService {
  static void goToTodoDetail(String todoId) {
    GoRouter.of(context).go('/todos/$todoId');
  }
  
  static void pushTodoDetail(String todoId) {
    GoRouter.of(context).push('/todos/$todoId');
  }
  
  static void goToSearch({String? query, String? category}) {
    final uri = Uri(
      path: '/search',
      queryParameters: {
        if (query != null) 'q': query,
        if (category != null) 'category': category,
      },
    );
    GoRouter.of(context).go(uri.toString());
  }
}
```

### Deep Link Handling

```dart
// lib/router/deep_link_handler.dart
class DeepLinkHandler {
  static GoRoute createTodoDetailRoute() {
    return GoRoute(
      path: '/todos/:id',
      builder: (context, state) {
        final todoId = state.pathParameters['id']!;
        
        // Validate todo ID format
        if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(todoId)) {
          return const NotFoundScreen();
        }
        
        return TodoDetailScreen(todoId: todoId);
      },
      redirect: (context, state) {
        // Check if user has permission to view this todo
        final authState = context.read(authProvider);
        if (!authState.isAuthenticated) {
          return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
        return null;
      },
    );
  }
}
```

### Share and External Link Handling

```dart
// lib/services/share_service.dart
class ShareService {
  static String generateTodoShareUrl(String todoId) {
    return 'https://yourapp.com/todos/$todoId';
  }
  
  static void handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    final router = GetIt.instance<GoRouter>();
    
    if (uri.pathSegments.isNotEmpty) {
      router.go(uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : ''));
    }
  }
}
```

## Nested Navigation and ShellRoute

### Main Layout with Persistent Navigation

```dart
// lib/widgets/main_layout.dart
class MainLayout extends ConsumerWidget {
  final Widget child;
  
  const MainLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(currentRoute)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(currentRoute),
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/todos');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }
  
  int _getCurrentIndex(String path) {
    if (path.startsWith('/todos')) return 1;
    if (path.startsWith('/settings')) return 2;
    return 0;
  }
  
  String _getPageTitle(String path) {
    if (path.startsWith('/todos')) return 'Todos';
    if (path.startsWith('/settings')) return 'Settings';
    return 'Home';
  }
}
```

### Complex Nested Navigation

```dart
// lib/router/nested_routes.dart
class NestedRoutes {
  static List<RouteBase> createMainRoutes() {
    return [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/todos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodosScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTodoScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TodoDetailScreen(todoId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EditTodoScreen(todoId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
```

### Tab-Based Navigation with State Preservation

```dart
// lib/widgets/tabbed_layout.dart
class TabbedLayout extends ConsumerStatefulWidget {
  final Widget child;
  
  const TabbedLayout({required this.child, super.key});

  @override
  ConsumerState<TabbedLayout> createState() => _TabbedLayoutState();
}

class _TabbedLayoutState extends ConsumerState<TabbedLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    
    // Sync tab controller with current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _getTabIndex(currentRoute);
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => _onTabChanged(context, index),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: widget.child,
    );
  }
  
  void _onTabChanged(BuildContext context, int index) {
    final routes = ['/todos/active', '/todos/completed', '/todos/all'];
    context.go(routes[index]);
  }
  
  int _getTabIndex(String path) {
    if (path.contains('completed')) return 1;
    if (path.contains('all')) return 2;
    return 0;
  }
}
```

## Authentication Guards and Redirects

### Riverpod-Based Authentication Provider

```dart
// lib/providers/auth_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState.unauthenticated();
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await ref.read(authRepositoryProvider).signIn(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState.unauthenticated();
  }
}

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

### Route Guards Implementation

```dart
// lib/router/auth_guard.dart
class AuthGuard {
  static String? checkAuth(BuildContext context, GoRouterState state) {
    final authState = context.read(authNotifierProvider);
    
    return authState.when(
      loading: () => null, // Allow navigation during loading
      authenticated: (_) => null, // Allow navigation when authenticated
      unauthenticated: () {
        // Store intended destination for post-login redirect
        final redirectPath = Uri.encodeComponent(state.uri.toString());
        return '/login?redirect=$redirectPath';
      },
      error: (_) => '/login',
    );
  }
  
  static String? checkGuest(BuildContext context, GoRouterState state) {
    final authState = context.read(authNotifierProvider);
    
    return authState.when(
      loading: () => null,
      authenticated: (_) => '/', // Redirect authenticated users away from login
      unauthenticated: () => null,
      error: (_) => null,
    );
  }
}
```

### Router with Authentication Integration

```dart
// lib/router/auth_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    refreshListenable: AuthChangeNotifier(ref),
    redirect: (context, state) {
      final isLoginRoute = state.uri.path == '/login';
      final isPublicRoute = ['/', '/about'].contains(state.uri.path);
      
      return authState.when(
        loading: () => null,
        authenticated: (_) {
          if (isLoginRoute) {
            // Redirect to intended destination or home
            final redirect = state.uri.queryParameters['redirect'];
            return redirect != null ? Uri.decodeComponent(redirect) : '/';
          }
          return null;
        },
        unauthenticated: () {
          if (isPublicRoute || isLoginRoute) return null;
          
          // Store intended destination
          final redirectPath = Uri.encodeComponent(state.uri.toString());
          return '/login?redirect=$redirectPath';
        },
        error: (_) => isLoginRoute ? null : '/login',
      );
    },
    routes: [
      // Public routes
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Protected routes
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/todos',
            builder: (context, state) => const TodosScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

// Helper class to notify GoRouter of auth state changes
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(this.ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
  
  final Ref ref;
}
```

### Role-Based Access Control

```dart
// lib/router/role_guard.dart
enum UserRole { admin, user, guest }

class RoleGuard {
  static String? checkRole(
    BuildContext context,
    GoRouterState state,
    List<UserRole> allowedRoles,
  ) {
    final authState = context.read(authNotifierProvider);
    
    return authState.when(
      loading: () => null,
      authenticated: (user) {
        if (allowedRoles.contains(user.role)) {
          return null; // Access granted
        }
        return '/unauthorized';
      },
      unauthenticated: () => '/login',
      error: (_) => '/login',
    );
  }
}

// Usage in routes
GoRoute(
  path: '/admin',
  redirect: (context, state) => RoleGuard.checkRole(
    context,
    state,
    [UserRole.admin],
  ),
  builder: (context, state) => const AdminScreen(),
),
```

## Navigation State Management with Riverpod

### Navigation State Provider

```dart
// lib/providers/navigation_provider.dart
@riverpod
class NavigationNotifier extends _$NavigationNotifier {
  @override
  NavigationState build() {
    return const NavigationState(
      currentPath: '/',
      history: ['/'],
      canGoBack: false,
    );
  }
  
  void updateCurrentPath(String path) {
    final newHistory = [...state.history, path];
    state = state.copyWith(
      currentPath: path,
      history: newHistory,
      canGoBack: newHistory.length > 1,
    );
  }
  
  void goBack() {
    if (state.canGoBack) {
      final newHistory = state.history.take(state.history.length - 1).toList();
      state = state.copyWith(
        currentPath: newHistory.last,
        history: newHistory,
        canGoBack: newHistory.length > 1,
      );
    }
  }
  
  void clearHistory() {
    state = const NavigationState(
      currentPath: '/',
      history: ['/'],
      canGoBack: false,
    );
  }
}

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    required String currentPath,
    required List<String> history,
    required bool canGoBack,
  }) = _NavigationState;
}
```

### Tab Navigation State

```dart
// lib/providers/tab_provider.dart
@riverpod
class TabNotifier extends _$TabNotifier {
  @override
  int build() => 0;
  
  void setTab(int index) {
    state = index;
  }
  
  void setTabFromPath(String path) {
    if (path.startsWith('/todos')) {
      state = 1;
    } else if (path.startsWith('/settings')) {
      state = 2;
    } else {
      state = 0;
    }
  }
}

// Usage in widgets
class BottomNavigation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(tabNotifierProvider);
    
    return BottomNavigationBar(
      currentIndex: currentTab,
      onTap: (index) {
        ref.read(tabNotifierProvider.notifier).setTab(index);
        _navigateToTab(context, index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todos'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
  
  void _navigateToTab(BuildContext context, int index) {
    final routes = ['/', '/todos', '/settings'];
    context.go(routes[index]);
  }
}
```

### Navigation Analytics

```dart
// lib/providers/analytics_provider.dart
@riverpod
class NavigationAnalytics extends _$NavigationAnalytics {
  @override
  Map<String, int> build() => {};
  
  void trackNavigation(String route) {
    final currentCounts = state;
    final newCount = (currentCounts[route] ?? 0) + 1;
    state = {...currentCounts, route: newCount};
    
    // Send to analytics service
    ref.read(analyticsServiceProvider).trackNavigation(route);
  }
  
  void trackTimeSpent(String route, Duration duration) {
    ref.read(analyticsServiceProvider).trackTimeSpent(route, duration);
  }
}

// Router listener for analytics
class AnalyticsRouterDelegate extends RouterDelegate {
  void trackRouteChange(String route) {
    ref.read(navigationAnalyticsProvider.notifier).trackNavigation(route);
  }
}
```

## Error Handling and 404 Pages

### Custom Error Pages

```dart
// lib/screens/error_screens.dart
class ErrorScreen extends StatelessWidget {
  final GoException? error;
  
  const ErrorScreen({this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'The page you are looking for does not exist.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Error Boundary Implementation

```dart
// lib/widgets/error_boundary.dart
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;
  
  const ErrorBoundary({
    required this.child,
    this.errorBuilder,
    super.key,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace!) ??
          ErrorScreen(error: GoException(_error.toString()));
    }
    
    return widget.child;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      });
      return const SizedBox.shrink();
    };
  }
}
```

### Global Error Handling

```dart
// lib/router/error_handler.dart
class NavigationErrorHandler {
  static Widget handleError(BuildContext context, GoRouterState state) {
    final error = state.error;
    
    // Log error for debugging
    debugPrint('Navigation error: ${error?.toString()}');
    
    // Track error in analytics
    FirebaseCrashlytics.instance.recordError(
      error,
      null,
      fatal: false,
      information: ['Route: ${state.uri}'],
    );
    
    // Return appropriate error screen
    if (error is GoException) {
      return _handleGoException(context, error);
    }
    
    return const ErrorScreen();
  }
  
  static Widget _handleGoException(BuildContext context, GoException error) {
    switch (error.toString()) {
      case 'not found':
        return const NotFoundScreen();
      case 'unauthorized':
        return const UnauthorizedScreen();
      default:
        return ErrorScreen(error: error);
    }
  }
}
```

## Web-Specific Navigation

### URL Strategy Configuration

```dart
// lib/main.dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // Remove the # from URLs on web
  usePathUrlStrategy();
  
  runApp(const ProviderScope(child: TodoApp()));
}
```

### Browser History Management

```dart
// lib/router/web_router.dart
class WebNavigationHandler {
  static void configureWebNavigation(GoRouter router) {
    // Handle browser back/forward buttons
    router.addListener(() {
      final location = router.routerDelegate.currentConfiguration.uri.toString();
      
      // Update browser title based on current route
      _updateBrowserTitle(location);
      
      // Track page views for web analytics
      _trackPageView(location);
    });
  }
  
  static void _updateBrowserTitle(String location) {
    final title = _getTitleForRoute(location);
    // Update document title for web
    if (kIsWeb) {
      html.document.title = title;
    }
  }
  
  static String _getTitleForRoute(String location) {
    if (location.startsWith('/todos')) return 'Todos - Todo App';
    if (location.startsWith('/profile')) return 'Profile - Todo App';
    return 'Todo App';
  }
  
  static void _trackPageView(String location) {
    // Google Analytics or other web analytics
    gtag('config', 'GA_MEASUREMENT_ID', {
      'page_title': _getTitleForRoute(location),
      'page_location': location,
    });
  }
}
```

### SEO and Meta Tags

```dart
// lib/widgets/seo_wrapper.dart
class SEOWrapper extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final Widget child;
  
  const SEOWrapper({
    required this.title,
    required this.description,
    required this.child,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      _updateMetaTags();
    }
    
    return child;
  }
  
  void _updateMetaTags() {
    // Update meta tags for SEO
    _setMetaTag('description', description);
    _setMetaTag('og:title', title);
    _setMetaTag('og:description', description);
    if (imageUrl != null) {
      _setMetaTag('og:image', imageUrl!);
    }
  }
  
  void _setMetaTag(String name, String content) {
    final meta = html.document.querySelector('meta[name="$name"]') ??
        html.document.querySelector('meta[property="$name"]');
    
    if (meta != null) {
      meta.setAttribute('content', content);
    }
  }
}
```

### Progressive Web App Navigation

```dart
// lib/router/pwa_router.dart
class PWANavigationHandler {
  static void handlePWANavigation(GoRouter router) {
    // Handle PWA install prompt
    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      // Store the event for later use
      _deferredPrompt = event;
    });
    
    // Handle PWA navigation scope
    if (_isPWAMode()) {
      router.addListener(() {
        _updatePWAState(router.routerDelegate.currentConfiguration.uri.toString());
      });
    }
  }
  
  static bool _isPWAMode() {
    return html.window.matchMedia('(display-mode: standalone)').matches;
  }
  
  static void _updatePWAState(String location) {
    // Update PWA-specific navigation state
    // Handle PWA-specific UI updates
  }
}
```

## Testing Navigation Flows

### Basic Navigation Tests

```dart
// test/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Navigation Tests', () {
    late GoRouter router;
    
    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/todos',
            builder: (context, state) => const TodosScreen(),
          ),
          GoRoute(
            path: '/todos/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TodoDetailScreen(todoId: id);
            },
          ),
        ],
      );
    });
    
    testWidgets('navigates to todos screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      
      // Verify initial screen
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Navigate to todos
      router.go('/todos');
      await tester.pumpAndSettle();
      
      // Verify navigation
      expect(find.byType(TodosScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
    
    testWidgets('navigates to todo detail with parameter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      
      // Navigate to todo detail
      router.go('/todos/123');
      await tester.pumpAndSettle();
      
      // Verify navigation and parameter passing
      expect(find.byType(TodoDetailScreen), findsOneWidget);
      
      // Verify the todo ID was passed correctly
      final todoDetailWidget = tester.widget<TodoDetailScreen>(
        find.byType(TodoDetailScreen),
      );
      expect(todoDetailWidget.todoId, equals('123'));
    });
  });
}
```

### Authentication Flow Tests

```dart
// test/auth_navigation_test.dart
void main() {
  group('Authentication Navigation Tests', () {
    testWidgets('redirects unauthenticated user to login', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthNotifier()),
        ],
      );
      
      final router = container.read(routerProvider);
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      
      // Try to navigate to protected route
      router.go('/profile');
      await tester.pumpAndSettle();
      
      // Should be redirected to login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
    });
    
    testWidgets('allows authenticated user to access protected routes', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthenticatedNotifier()),
        ],
      );
      
      final router = container.read(routerProvider);
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      
      // Navigate to protected route
      router.go('/profile');
      await tester.pumpAndSettle();
      
      // Should access the protected route
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

class MockAuthenticatedNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.authenticated(
    User(id: '1', email: 'test@example.com'),
  );
}
```

### Deep Link Tests

```dart
// test/deep_link_test.dart
void main() {
  group('Deep Link Tests', () {
    testWidgets('handles deep link with parameters', (tester) async {
      final router = GoRouter(
        initialLocation: '/todos/456?tab=comments',
        routes: [
          GoRoute(
            path: '/todos/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final tab = state.uri.queryParameters['tab'];
              return TodoDetailScreen(todoId: id, initialTab: tab);
            },
          ),
        ],
      );
      
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      
      await tester.pumpAndSettle();
      
      // Verify deep link was handled correctly
      expect(find.byType(TodoDetailScreen), findsOneWidget);
      
      final widget = tester.widget<TodoDetailScreen>(
        find.byType(TodoDetailScreen),
      );
      expect(widget.todoId, equals('456'));
      expect(widget.initialTab, equals('comments'));
    });
    
    testWidgets('handles invalid deep link gracefully', (tester) async {
      final router = GoRouter(
        initialLocation: '/invalid/route',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
        errorBuilder: (context, state) => const NotFoundScreen(),
      );
      
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      
      await tester.pumpAndSettle();
      
      // Should show error page for invalid route
      expect(find.byType(NotFoundScreen), findsOneWidget);
    });
  });
}
```

### Navigation State Tests

```dart
// test/navigation_state_test.dart
void main() {
  group('Navigation State Tests', () {
    test('tracks navigation history correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(navigationNotifierProvider.notifier);
      
      // Initial state
      expect(container.read(navigationNotifierProvider).currentPath, '/');
      expect(container.read(navigationNotifierProvider).canGoBack, false);
      
      // Navigate to new path
      notifier.updateCurrentPath('/todos');
      expect(container.read(navigationNotifierProvider).currentPath, '/todos');
      expect(container.read(navigationNotifierProvider).canGoBack, true);
      
      // Navigate to another path
      notifier.updateCurrentPath('/profile');
      expect(container.read(navigationNotifierProvider).currentPath, '/profile');
      expect(container.read(navigationNotifierProvider).history.length, 3);
      
      // Go back
      notifier.goBack();
      expect(container.read(navigationNotifierProvider).currentPath, '/todos');
      expect(container.read(navigationNotifierProvider).canGoBack, true);
    });
  });
}
```

## Performance Optimization

### Lazy Loading and Code Splitting

```dart
// lib/router/lazy_routes.dart
class LazyRoutes {
  static GoRoute createLazyRoute(
    String path,
    Future<Widget> Function() builder,
  ) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) {
        return MaterialPage(
          child: FutureBuilder<Widget>(
            future: builder(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
  
  static List<GoRoute> createLazyRoutes() {
    return [
      createLazyRoute(
        '/admin',
        () async {
          // Lazy load admin module
          final module = await import('package:todo_app/admin/admin_module.dart');
          return module.AdminScreen();
        },
      ),
      createLazyRoute(
        '/analytics',
        () async {
          // Lazy load analytics module
          final module = await import('package:todo_app/analytics/analytics_module.dart');
          return module.AnalyticsScreen();
        },
      ),
    ];
  }
}
```

### Route Preloading

```dart
// lib/router/route_preloader.dart
class RoutePreloader {
  static final Map<String, Widget> _preloadedRoutes = {};
  
  static void preloadRoute(String path, Widget Function() builder) {
    if (!_preloadedRoutes.containsKey(path)) {
      _preloadedRoutes[path] = builder();
    }
  }
  
  static Widget? getPreloadedRoute(String path) {
    return _preloadedRoutes[path];
  }
  
  static void preloadCriticalRoutes() {
    // Preload commonly accessed routes
    preloadRoute('/todos', () => const TodosScreen());
    preloadRoute('/profile', () => const ProfileScreen());
  }
  
  static GoRoute createPreloadedRoute(
    String path,
    Widget Function() builder,
  ) {
    return GoRoute(
      path: path,
      builder: (context, state) {
        final preloaded = getPreloadedRoute(path);
        return preloaded ?? builder();
      },
    );
  }
}
```

### Navigation Caching

```dart
// lib/router/navigation_cache.dart
class NavigationCache {
  static final Map<String, Widget> _cache = {};
  static const int maxCacheSize = 10;
  
  static Widget getCachedWidget(String key, Widget Function() builder) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    final widget = builder();
    _addToCache(key, widget);
    return widget;
  }
  
  static void _addToCache(String key, Widget widget) {
    if (_cache.length >= maxCacheSize) {
      // Remove oldest entry
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = widget;
  }
  
  static void clearCache() {
    _cache.clear();
  }
  
  static void removeCachedWidget(String key) {
    _cache.remove(key);
  }
}
```

### Performance Monitoring

```dart
// lib/router/performance_monitor.dart
class NavigationPerformanceMonitor {
  static final Map<String, DateTime> _navigationStartTimes = {};
  
  static void startNavigation(String route) {
    _navigationStartTimes[route] = DateTime.now();
  }
  
  static void endNavigation(String route) {
    final startTime = _navigationStartTimes[route];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logNavigationTime(route, duration);
      _navigationStartTimes.remove(route);
    }
  }
  
  static void _logNavigationTime(String route, Duration duration) {
    debugPrint('Navigation to $route took ${duration.inMilliseconds}ms');
    
    // Send to analytics
    FirebasePerformance.instance.newTrace('navigation_$route')
      ..setMetric('duration_ms', duration.inMilliseconds)
      ..start()
      ..stop();
  }
  
  static GoRoute createMonitoredRoute(
    String path,
    Widget Function(BuildContext, GoRouterState) builder,
  ) {
    return GoRoute(
      path: path,
      builder: (context, state) {
        startNavigation(path);
        
        return Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              endNavigation(path);
            });
            return builder(context, state);
          },
        );
      },
    );
  }
}
```

## Migration Patterns

### From Navigator 1.0

```dart
// Before (Navigator 1.0)
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TodoDetailScreen(todoId: '123'),
  ),
);

// After (GoRouter)
context.push('/todos/123');

// Before (Named routes)
Navigator.of(context).pushNamed('/todos', arguments: {'id': '123'});

// After (GoRouter with parameters)
context.go('/todos/123');
```

### From Navigator 2.0

```dart
// Before (Navigator 2.0 with RouterDelegate)
class AppRouterDelegate extends RouterDelegate<AppRoutePath> {
  // Complex implementation...
}

// After (GoRouter)
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/todos/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TodoDetailScreen(todoId: id);
      },
    ),
  ],
);
```

### Migration Helper

```dart
// lib/migration/navigation_migration.dart
class NavigationMigration {
  static void migrateFromNavigator1(BuildContext context) {
    // Helper methods for gradual migration
  }
  
  static String convertNamedRouteToGoRoute(String routeName, Object? arguments) {
    switch (routeName) {
      case '/todos':
        final args = arguments as Map<String, dynamic>?;
        final id = args?['id'] as String?;
        return id != null ? '/todos/$id' : '/todos';
      case '/profile':
        return '/profile';
      default:
        return '/';
    }
  }
  
  static void pushReplacement(BuildContext context, String route) {
    // Migration helper for pushReplacement
    context.pushReplacement(route);
  }
  
  static void popUntil(BuildContext context, String route) {
    // Migration helper for popUntil
    while (GoRouterState.of(context).uri.path != route) {
      if (context.canPop()) {
        context.pop();
      } else {
        break;
      }
    }
  }
}
```

## Accessibility Considerations

### Screen Reader Support

```dart
// lib/widgets/accessible_navigation.dart
class AccessibleNavigationButton extends StatelessWidget {
  final String label;
  final String route;
  final IconData icon;
  
  const AccessibleNavigationButton({
    required this.label,
    required this.route,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navigate to $label',
      hint: 'Double tap to go to $label page',
      button: true,
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => context.go(route),
        tooltip: label,
      ),
    );
  }
}
```

### Focus Management

```dart
// lib/widgets/focus_aware_route.dart
class FocusAwareRoute extends StatefulWidget {
  final Widget child;
  final String routeName;
  
  const FocusAwareRoute({
    required this.child,
    required this.routeName,
    super.key,
  });

  @override
  State<FocusAwareRoute> createState() => _FocusAwareRouteState();
}

class _FocusAwareRouteState extends State<FocusAwareRoute> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      
      // Announce route change to screen readers
      SemanticsService.announce(
        'Navigated to ${widget.routeName}',
        TextDirection.ltr,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: widget.child,
    );
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
```

### Keyboard Navigation

```dart
// lib/widgets/keyboard_navigation.dart
class KeyboardNavigationHandler extends StatelessWidget {
  final Widget child;
  
  const KeyboardNavigationHandler({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit1):
            const NavigateIntent('/'),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit2):
            const NavigateIntent('/todos'),
        LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit3):
            const NavigateIntent('/profile'),
      },
      child: Actions(
        actions: {
          NavigateIntent: NavigateAction(),
        },
        child: child,
      ),
    );
  }
}

class NavigateIntent extends Intent {
  final String route;
  const NavigateIntent(this.route);
}

class NavigateAction extends Action<NavigateIntent> {
  @override
  Object? invoke(NavigateIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      context.go(intent.route);
    }
    return null;
  }
}
```

### Route Announcements

```dart
// lib/router/accessibility_router.dart
class AccessibilityRouter {
  static GoRouter createAccessibleRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const FocusAwareRoute(
            routeName: 'Home',
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/todos',
          builder: (context, state) => const FocusAwareRoute(
            routeName: 'Todos',
            child: TodosScreen(),
          ),
        ),
      ],
      observers: [AccessibilityNavigatorObserver()],
    );
  }
}

class AccessibilityNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _announceRouteChange(route);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _announceRouteChange(previousRoute);
    }
  }
  
  void _announceRouteChange(Route<dynamic> route) {
    final routeName = route.settings.name ?? 'Unknown page';
    SemanticsService.announce(
      'Navigated to $routeName',
      TextDirection.ltr,
    );
  }
}
```

## Best Practices Summary

### Do's
- ✅ Use declarative route definitions for maintainability
- ✅ Implement proper error handling with custom error pages
- ✅ Use ShellRoute for persistent layouts and nested navigation
- ✅ Integrate authentication guards with redirect logic
- ✅ Test navigation flows thoroughly
- ✅ Implement accessibility features for inclusive design
- ✅ Use type-safe route definitions and parameters
- ✅ Monitor navigation performance and optimize accordingly

### Don'ts
- ❌ Don't mix Navigator 1.0 methods with GoRouter
- ❌ Don't ignore web-specific navigation requirements
- ❌ Don't forget to handle deep links and URL parameters
- ❌ Don't skip error handling for unknown routes
- ❌ Don't neglect accessibility in navigation design
- ❌ Don't create overly complex nested route structures
- ❌ Don't forget to test authentication flows
- ❌ Don't ignore performance implications of route building

### Performance Tips
- 🚀 Use lazy loading for heavy screens
- 🚀 Implement route preloading for critical paths
- 🚀 Cache frequently accessed widgets
- 🚀 Monitor navigation timing and optimize bottlenecks
- 🚀 Use const constructors where possible
- 🚀 Minimize widget rebuilds during navigation

This comprehensive guide covers all aspects of implementing GoRouter 16.x in a Flutter application with Riverpod integration. Follow these patterns and best practices to create a robust, maintainable, and accessible navigation system.