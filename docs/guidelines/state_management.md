# State Management Guidelines

## Table of Contents
1. [Riverpod 3.0 Stable](#riverpod-30-stable)
   - [Setup and Migration](#setup-and-migration)
   - [Unified Notifier API](#unified-notifier-api)
   - [New Features](#new-features)
   - [Provider Types](#provider-types)
   - [Provider Modifiers](#provider-modifiers)
   - [Best Practices](#riverpod-best-practices)
2. [flutter_hooks](#flutter_hooks)
   - [Basic Hooks](#basic-hooks)
   - [Custom Hooks](#custom-hooks)
   - [Best Practices](#hooks-best-practices)
3. [Freezed Integration](#freezed-integration)
   - [Model Definition](#model-definition)
   - [Union Types](#union-types)
   - [Best Practices](#freezed-best-practices)
4. [Combining Riverpod and Hooks](#combining-riverpod-and-hooks)
5. [Performance Optimization](#performance-optimization)
6. [Testing](#testing-state-management)
7. [Migration Guide](#migration-guide)

## Riverpod 3.0

### Setup and Migration

Add to `pubspec.yaml`:

```yaml
dependencies:
  # For Flutter apps
  flutter_riverpod: ^3.0.0-dev.16
  # For Flutter Hooks integration
  hooks_riverpod: ^3.0.0-dev.16
  # The annotation package containing @riverpod
  riverpod_annotation: ^3.0.0-dev.16
  # For state persistence
  shared_preferences: ^2.2.2
  # For HTTP requests
  http: ^1.2.1

dev_dependencies:
  # Code generation tools
  build_runner: ^2.5.4
  # The code generator for Riverpod
  riverpod_generator: ^3.0.0-dev.16
  # Linting for Riverpod
  riverpod_lint: ^3.0.0-dev.16
  # For JSON serialization
  json_serializable: ^6.9.5
  # For testing
  mocktail: ^1.0.4
  # For code coverage
  test_coverage: ^0.5.0
```

### Code Generation Commands

```bash
# Generate code once
dart run build_runner build

# Watch for changes and regenerate automatically
dart run build_runner watch

# Delete conflicting outputs and regenerate
dart run build_runner build --delete-conflicting-outputs

# Run tests with coverage
flutter test --coverage

# Verify build outputs
dart run build_verify
```

### Unified Notifier API

Riverpod 3.0 introduces a unified `Notifier` class that replaces separate `AutoDisposeNotifier` and regular notifiers:

```dart
// counter_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() {
    // Check if the notifier is still mounted before updating state
    if (!ref.mounted) return;
    state++;
  }
  
  void decrement() {
    if (!ref.mounted) return;
    state--;
  }
  
  void reset() {
    if (!ref.mounted) return;
    state = 0;
  }
}
```

### New Features

#### Ref.mounted Pattern

Similar to `BuildContext.mounted`, use `ref.mounted` to check if the provider is still active:

```dart
@riverpod
class DataFetcher extends _$DataFetcher {
  @override
  Future<String> build() async {
    final data = await fetchData();
    
    // Check if still mounted before updating state
    if (!ref.mounted) return '';
    
    return data;
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final newData = await fetchData();
      
      // Always check mounted before state updates
      if (!ref.mounted) return;
      
      state = AsyncValue.data(newData);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

#### Automatic Retry with Exponential Backoff

```dart
@riverpod
class NetworkData extends _$NetworkData {
  @override
  Future<String> build() async {
    return _fetchWithRetry();
  }
  
  Future<String> _fetchWithRetry({int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (!ref.mounted) throw Exception('Provider disposed');
        
        final data = await http.get(Uri.parse('https://api.example.com/data'));
        return data.body;
      } catch (error) {
        if (attempt == maxRetries - 1) rethrow;
        
        // Exponential backoff
        final delay = Duration(milliseconds: 1000 * (1 << attempt));
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }
  
  Future<void> retry() async {
    ref.invalidateSelf();
  }
}
```

#### Pause/Resume Support

```dart
@riverpod
class StreamData extends _$StreamData {
  StreamSubscription? _subscription;
  bool _isPaused = false;
  
  @override
  Stream<String> build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    return _createStream();
  }
  
  Stream<String> _createStream() async* {
    _subscription = someDataStream.listen((data) {
      if (!_isPaused && ref.mounted) {
        // Emit data only when not paused and mounted
        state = AsyncValue.data(data);
      }
    });
    
    yield* someDataStream;
  }
  
  void pause() {
    _isPaused = true;
    _subscription?.pause();
  }
  
  void resume() {
    _isPaused = false;
    _subscription?.resume();
  }
}
```

#### Offline Persistence (Experimental)

```dart
@riverpod
class PersistedCounter extends _$PersistedCounter {
  @override
  Future<int> build() async {
    // Load from persistent storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('counter') ?? 0;
  }
  
  Future<void> increment() async {
    if (!ref.mounted) return;
    
    final currentValue = await future;
    final newValue = currentValue + 1;
    
    // Update state
    state = AsyncValue.data(newValue);
    
    // Persist to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', newValue);
  }
  
  Future<void> decrement() async {
    if (!ref.mounted) return;
    
    final currentValue = await future;
    final newValue = currentValue - 1;
    
    state = AsyncValue.data(newValue);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', newValue);
  }
}
```

#### Mutations with Optimistic Updates

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    return await todoRepository.fetchTodos();
  }
  
  Future<void> addTodo(String title) async {
    if (!ref.mounted) return;
    
    final currentTodos = await future;
    final optimisticTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
    );
    
    // Optimistic update
    state = AsyncValue.data([...currentTodos, optimisticTodo]);
    
    try {
      final newTodo = await todoRepository.createTodo(title);
      
      if (!ref.mounted) return;
      
      // Replace optimistic todo with real one
      final updatedTodos = currentTodos.map((todo) {
        return todo.id == optimisticTodo.id ? newTodo : todo;
      }).toList();
      
      state = AsyncValue.data(updatedTodos);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      
      // Revert optimistic update
      state = AsyncValue.data(currentTodos);
      
      // Show error
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

### Statically Safe Scoping

Riverpod 3.0 introduces improved scoping with compile-time safety:

```dart
// Define scoped providers
@riverpod
class UserSession extends _$UserSession {
  @override
  User? build() => null;
  
  void login(User user) {
    if (!ref.mounted) return;
    state = user;
  }
  
  void logout() {
    if (!ref.mounted) return;
    state = null;
  }
}

// Scoped provider that depends on user session
@riverpod
Future<List<Order>> userOrders(UserOrdersRef ref) async {
  final user = ref.watch(userSessionProvider);
  
  if (user == null) {
    throw Exception('User not logged in');
  }
  
  return await orderRepository.fetchUserOrders(user.id);
}

// Widget with scoped providers
class UserDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        // Scope providers to this widget tree
        userSessionProvider.overrideWith(() => UserSession()),
      ],
      child: const UserDashboardContent(),
    );
  }
}
```

### Provider Lifecycle Management

```dart
@riverpod
class ResourceManager extends _$ResourceManager {
  Timer? _timer;
  StreamSubscription? _subscription;
  
  @override
  String build() {
    // Setup lifecycle management
    ref.onDispose(() {
      _cleanup();
    });
    
    ref.onCancel(() {
      // Called when provider is about to be disposed
      print('Provider is being cancelled');
    });
    
    ref.onResume(() {
      // Called when provider is resumed after being paused
      print('Provider resumed');
    });
    
    _startTimer();
    _subscribeToStream();
    
    return 'initialized';
  }
  
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      
      // Update state periodically
      state = DateTime.now().toString();
    });
  }
  
  void _subscribeToStream() {
    _subscription = someStream.listen((data) {
      if (!ref.mounted) return;
      
      state = data;
    });
  }
  
  void _cleanup() {
    _timer?.cancel();
    _subscription?.cancel();
  }
}
```

### Best Practices

1. **Always check `ref.mounted`** before state updates in async operations
2. **Use code generation** for better performance and type safety
3. **Keep providers small and focused** on a single responsibility
4. **Use `ref.watch` in widgets** and `ref.read` in callbacks
5. **Leverage `select`** to optimize rebuilds
6. **Implement proper cleanup** in `ref.onDispose`
7. **Use optimistic updates** for better UX in mutations
8. **Test providers** in isolation with new testing utilities
9. **Document public providers** with clear documentation
10. **Use unified `Notifier`** instead of separate auto-dispose variants

### Provider Types

#### `@riverpod` Notifier (Recommended)
For complex state management with the unified Notifier API.

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() {
    if (!ref.mounted) return;
    state++;
  }
  
  void decrement() {
    if (!ref.mounted) return;
    state--;
  }
}
```

#### `@riverpod` Function Provider
For simple, immutable values or computed values.

```dart
@riverpod
int doubledCounter(DoubledCounterRef ref) {
  final count = ref.watch(counterProvider);
  return count * 2;
}
```

#### `@riverpod` Async Provider
For asynchronous data fetching.

```dart
@riverpod
Future<User> user(UserRef ref, String userId) async {
  // Check mounted state for long-running operations
  if (!ref.mounted) throw Exception('Provider disposed');
  
  final response = await http.get(
    Uri.parse('https://api.example.com/users/$userId'),
  );
  
  if (!ref.mounted) throw Exception('Provider disposed');
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user');
  }
}
```

#### `@riverpod` Stream Provider
For real-time data.

```dart
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String chatId) async* {
  final subscription = chatRepository.watchMessages(chatId);
  
  ref.onDispose(() {
    subscription.cancel();
  });
  
  await for (final messages in subscription) {
    if (!ref.mounted) break;
    yield messages;
  }
}
```

#### Legacy Provider Types (Still Supported)

```dart
// Simple state
final counterProvider = StateProvider<int>((ref) => 0);

// Immutable values
final configProvider = Provider<Config>((ref) => Config());

// Complex state (prefer @riverpod Notifier instead)
final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
```

### Provider Modifiers

#### Family Parameters
For parameterized providers using the unified API.

```dart
@riverpod
Future<Todo> todo(TodoRef ref, String id) async {
  if (!ref.mounted) throw Exception('Provider disposed');
  
  return await todoRepository.getTodo(id);
}

// Usage
final todo = ref.watch(todoProvider('123'));
```

#### Keep Alive
Prevents auto-disposal of providers.

```dart
@Riverpod(keepAlive: true)
Future<Config> config(ConfigRef ref) async {
  // This provider will not be auto-disposed
  return await configRepository.getConfig();
}
```

#### Dependencies and Watching
```dart
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref) async {
  // Watch other providers
  final userId = ref.watch(currentUserIdProvider);
  final settings = ref.watch(userSettingsProvider(userId));
  
  if (!ref.mounted) throw Exception('Provider disposed');
  
  return await userRepository.getProfile(userId, settings);
}
```

### Advanced Patterns

#### Conditional Provider Watching
```dart
@riverpod
class ConditionalData extends _$ConditionalData {
  @override
  Future<String> build() async {
    final isEnabled = ref.watch(featureFlagProvider);
    
    if (!isEnabled) {
      return 'Feature disabled';
    }
    
    // Only watch expensive provider when feature is enabled
    final data = ref.watch(expensiveDataProvider);
    return data.when(
      data: (value) => value,
      loading: () => 'Loading...',
      error: (error, _) => 'Error: $error',
    );
  }
}
```

#### Provider Composition
```dart
@riverpod
class ComposedData extends _$ComposedData {
  @override
  Future<CombinedData> build() async {
    // Wait for multiple providers
    final results = await Future.wait([
      ref.watch(dataAProvider.future),
      ref.watch(dataBProvider.future),
      ref.watch(dataCProvider.future),
    ]);
    
    if (!ref.mounted) throw Exception('Provider disposed');
    
    return CombinedData(
      dataA: results[0],
      dataB: results[1],
      dataC: results[2],
    );
  }
}
```

## flutter_hooks

### Basic Hooks

#### `useState`
For local state management.

```dart
class Counter extends HookWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    return Column(
      children: [
        Text('Count: ${count.value}'),
        ElevatedButton(
          onPressed: () => count.value++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

#### `useEffect`
For side effects.

```dart
class DataFetcher extends HookWidget {
  const DataFetcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = useState<Data?>(null);
    
    useEffect(() {
      bool mounted = true;
      
      fetchData().then((result) {
        if (mounted) {
          data.value = result;
        }
      });
      
      return () {
        mounted = false;
      };
    }, const []); // Empty dependency array means run once
    
    return data.value != null 
        ? DataView(data: data.value!)
        : const CircularProgressIndicator();
  }
}
```

#### `useMemoized`
For expensive computations.

```dart
class ExpensiveComputation extends HookWidget {
  const ExpensiveComputation({required this.items, Key? key}) : super(key: key);
  
  final List<int> items;
  
  @override
  Widget build(BuildContext context) {
    final result = useMemoized(
      () => expensiveComputation(items),
      [items], // Recompute when items change
    );
    
    return Text('Result: $result');
  }
}
```

### Custom Hooks

```dart
String useFormattedDate(DateTime date) {
  return useMemoized(
    () => DateFormat('yyyy-MM-dd').format(date),
    [date],
  );
}

// Usage
final formattedDate = useFormattedDate(DateTime.now());
```

### Best Practices

1. **Extract complex hooks logic**
   ```dart
   // Good
   Widget build(BuildContext context) {
     final {data, isLoading, error} = useDataFetcher();
     // ...
   }
   
   // Bad - Too much logic in build method
   Widget build(BuildContext context) {
     final data = useState<Data?>(null);
     final isLoading = useState(false);
     final error = useState<Exception?>(null);
     
     useEffect(() {
       // Complex data fetching logic
     }, []);
     
     // ...
   }
   ```

2. **Use `useCallback` for stable function references**
   ```dart
   final onPressed = useCallback(() {
     // Handler logic
   }, []); // Empty dependency array means stable reference
   ```

## Freezed Integration

### Model Definition

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(false) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Union Types and Pattern Matching

```dart
@freezed
abstract class LoadingState<T> with _$LoadingState<T> {
  const factory LoadingState.loading() = _Loading;
  const factory LoadingState.data(T data) = _Data;
  const factory LoadingState.error(String message) = _Error;
}

// Usage with Dart switch expressions (Freezed v3+)
Widget build(BuildContext context) {
  final state = ref.watch(dataProvider);
  
  return switch (state) {
    _Loading() => const CircularProgressIndicator(),
    _Data(:final data) => Text('Data: $data'),
    _Error(:final message) => Text('Error: $message'),
  };
}

// Alternative with if-case pattern matching
Widget build(BuildContext context) {
  final state = ref.watch(dataProvider);
  
  if (state case _Loading()) {
    return const CircularProgressIndicator();
  } else if (state case _Data(:final data)) {
    return Text('Data: $data');
  } else if (state case _Error(:final message)) {
    return Text('Error: $message');
  }
  
  throw StateError('Unhandled state: $state');
}

### Freezed v3 Migration Notes

**Important**: Freezed v3 has removed the `.map` and `.when` extensions in favor of Dart's native pattern matching:

```dart
// ❌ Old way (no longer available in v3)
final result = model.when(
  first: (String a) => 'first $a',
  second: (int b, bool c) => 'second $b $c',
);

// ✅ New way (use Dart switch expressions)
final result = switch (model) {
  First(:final a) => 'first $a',
  Second(:final b, :final c) => 'second $b $c',
};
```

### Riverpod 3.0 + Freezed Integration

```dart
@freezed
class AsyncState<T> with _$AsyncState<T> {
  const factory AsyncState.loading() = _Loading;
  const factory AsyncState.data(T data) = _Data;
  const factory AsyncState.error(String message, [StackTrace? stackTrace]) = _Error;
}

@riverpod
class DataManager extends _$DataManager {
  @override
  AsyncState<String> build() => const AsyncState.loading();
  
  Future<void> fetchData() async {
    if (!ref.mounted) return;
    
    state = const AsyncState.loading();
    
    try {
      final data = await apiService.fetchData();
      
      if (!ref.mounted) return;
      
      state = AsyncState.data(data);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      
      state = AsyncState.error(error.toString(), stackTrace);
    }
  }
}

// Usage in widgets
class DataView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataManagerProvider);
    
    return switch (state) {
      _Loading() => const CircularProgressIndicator(),
      _Data(:final data) => Text('Data: $data'),
      _Error(:final message) => Text('Error: $message'),
    };
  }
}
```

### Best Practices

1. **Use `sealed` for union types** to ensure exhaustive pattern matching
2. **Prefer immutable data structures** for better performance and predictability
3. **Use `copyWith` for updates** instead of creating new instances manually
4. **Use Dart switch expressions** instead of `.map`/`.when` (Freezed v3+)
5. **Combine with JSON serialization** for API integration
6. **Use descriptive factory names** for union type variants
7. **Integrate with Riverpod's AsyncValue** for consistent async state handling
8. **Use pattern matching** for exhaustive state handling in widgets

## Combining Riverpod and Hooks

### Using `HookConsumerWidget`

```dart
class UserProfile extends HookConsumerWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use hooks
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    
    // Use Riverpod
    final user = ref.watch(userProvider);
    
    return user.when(
      data: (user) => UserView(user: user),
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => ErrorView(error: error),
    );
  }
}
```

### Using `HookConsumer`

```dart
class Counter extends StatelessWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HookConsumer(
      builder: (context, ref, child) {
        final count = useState(0);
        final theme = ref.watch(themeProvider);
        
        return Text(
          'Count: ${count.value}',
          style: TextStyle(color: theme.primaryColor),
        );
      },
    );
  }
}
```

## Performance Optimization

### Use `select` for Granular Updates

```dart
// Only rebuild when the username changes
final username = ref.watch(userProvider.select((user) => user.name));
```

### Use `const` Constructors

```dart
// Good
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}
```

### Optimize Rebuilds with `ProviderScope`

```dart
ProviderScope(
  overrides: [
    // Only override what's necessary
    repositoryProvider.overrideWithValue(mockRepository),
  ],
  child: const MyApp(),
);
```

## Testing State Management

### Testing with New Utilities

Riverpod 3.0 introduces enhanced testing utilities for better test isolation and control.

#### ProviderContainer.test()

```dart
void main() {
  test('counter increments with new testing utilities', () async {
    await ProviderContainer.test(
      (container) async {
        // Test initial state
        expect(container.read(counterProvider), 0);
        
        // Test increment
        container.read(counterProvider.notifier).increment();
        expect(container.read(counterProvider), 1);
        
        // Test decrement
        container.read(counterProvider.notifier).decrement();
        expect(container.read(counterProvider), 0);
      },
    );
  });
}
```

#### NotifierProvider.overrideWithBuild

```dart
void main() {
  test('override notifier with custom build logic', () async {
    await ProviderContainer.test(
      overrides: [
        counterProvider.overrideWithBuild(() => 100), // Start with 100
      ],
      (container) async {
        expect(container.read(counterProvider), 100);
        
        container.read(counterProvider.notifier).increment();
        expect(container.read(counterProvider), 101);
      },
    );
  });
}
```

#### Testing Async Providers with Mounted Checks

```dart
void main() {
  test('async provider handles disposal correctly', () async {
    await ProviderContainer.test(
      (container) async {
        // Start the async operation
        final future = container.read(dataFetcherProvider.future);
        
        // Dispose the container while operation is running
        container.dispose();
        
        // The provider should handle the disposal gracefully
        await expectLater(
          future,
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Provider disposed'),
          )),
        );
      },
    );
  });
}
```

#### Testing Provider Lifecycle

```dart
void main() {
  test('provider lifecycle callbacks are called', () async {
    var onDisposeCallCount = 0;
    var onCancelCallCount = 0;
    var onResumeCallCount = 0;
    
    await ProviderContainer.test(
      overrides: [
        resourceManagerProvider.overrideWith(() {
          return ResourceManagerForTesting(
            onDispose: () => onDisposeCallCount++,
            onCancel: () => onCancelCallCount++,
            onResume: () => onResumeCallCount++,
          );
        }),
      ],
      (container) async {
        // Read the provider to initialize it
        container.read(resourceManagerProvider);
        
        // Dispose the container
        container.dispose();
        
        expect(onDisposeCallCount, 1);
      },
    );
  });
}
```

### Testing Hooks

```dart
void main() {
  testWidgets('useCounter increments', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HookBuilder(
          builder: (context) {
            final counter = useCounter();
            return Text('${counter.value}');
          },
        ),
      ),
    );
    
    expect(find.text('0'), findsOneWidget);
    
    // Test hook interactions
    // ...
  });
}
```

### Mocking Dependencies with Enhanced Patterns

```dart
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;
  
  setUp(() {
    mockRepository = MockUserRepository();
  });
  
  test('user provider fetches user with error handling', () async {
    // Setup mock to throw error first, then succeed
    when(mockRepository.getUser('123'))
        .thenThrow(Exception('Network error'))
        .thenAnswer((_) async => User(id: '123', name: 'Test'));
    
    await ProviderContainer.test(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockRepository),
      ],
      (container) async {
        // First call should throw
        await expectLater(
          container.read(userProvider('123').future),
          throwsA(isA<Exception>()),
        );
        
        // Invalidate and retry
        container.invalidate(userProvider('123'));
        
        // Second call should succeed
        final user = await container.read(userProvider('123').future);
        expect(user.name, 'Test');
      },
    );
  });
  
  test('test optimistic updates', () async {
    when(mockRepository.createTodo(any()))
        .thenAnswer((_) async => Todo(id: 'real-id', title: 'Test', isCompleted: false));
    
    await ProviderContainer.test(
      overrides: [
        todoRepositoryProvider.overrideWithValue(mockRepository),
      ],
      (container) async {
        final notifier = container.read(todoListProvider.notifier);
        
        // Add todo with optimistic update
        await notifier.addTodo('Test Todo');
        
        final todos = await container.read(todoListProvider.future);
        expect(todos.length, 1);
        expect(todos.first.title, 'Test Todo');
        expect(todos.first.id, 'real-id'); // Should have real ID after API call
      },
    );
  });
}
```

### Golden Tests for State Management

```dart
void main() {
  testWidgets('counter widget golden test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          counterProvider.overrideWith(() => Counter()..state = 42),
        ],
        child: const MaterialApp(
          home: CounterWidget(),
        ),
      ),
    );
    
    await expectLater(
      find.byType(CounterWidget),
      matchesGoldenFile('counter_widget_42.png'),
    );
  });
}
```
## Migration Guide

### From Riverpod 3.0-dev to 3.0 Stable

#### 1. Update Dependencies

```yaml
# Before
dependencies:
  flutter_riverpod: ^3.0.0-dev.16
  hooks_riverpod: ^3.0.0-dev.16
  riverpod_annotation: ^3.0.0-dev.16

dev_dependencies:
  riverpod_generator: ^3.0.0-dev.16
  riverpod_lint: ^3.0.0-dev.16

# After
dependencies:
  flutter_riverpod: ^3.0.0
  hooks_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

dev_dependencies:
  riverpod_generator: ^3.0.0
  riverpod_lint: ^3.0.0
```

#### 2. Update Code Generation

```bash
# Clean and regenerate all generated files
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 3. Migrate to Unified Notifier API

```dart
// Before (separate auto-dispose notifiers)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}

@riverpod
class AutoDisposeCounter extends _$AutoDisposeCounter {
  @override
  int build() => 0;
  
  void increment() => state++;
}

// After (unified Notifier with auto-dispose by default)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() {
    if (!ref.mounted) return; // Add mounted checks
    state++;
  }
}

// For keep-alive behavior
@Riverpod(keepAlive: true)
class PersistentCounter extends _$PersistentCounter {
  @override
  int build() => 0;
  
  void increment() {
    if (!ref.mounted) return;
    state++;
  }
}
```

#### 4. Add Mounted Checks

```dart
// Before
@riverpod
class DataFetcher extends _$DataFetcher {
  @override
  Future<String> build() async {
    final data = await fetchData();
    return data;
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final newData = await fetchData();
    state = AsyncValue.data(newData);
  }
}

// After
@riverpod
class DataFetcher extends _$DataFetcher {
  @override
  Future<String> build() async {
    final data = await fetchData();
    
    if (!ref.mounted) return '';
    
    return data;
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final newData = await fetchData();
      
      if (!ref.mounted) return;
      
      state = AsyncValue.data(newData);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

#### 5. Update Testing Code

```dart
// Before
test('counter test', () {
  final container = ProviderContainer();
  
  expect(container.read(counterProvider), 0);
  container.read(counterProvider.notifier).increment();
  expect(container.read(counterProvider), 1);
  
  container.dispose();
});

// After
test('counter test', () async {
  await ProviderContainer.test(
    (container) async {
      expect(container.read(counterProvider), 0);
      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), 1);
    },
  );
});
```

### Breaking Changes Summary

1. **Unified Notifier API**: No more separate `AutoDisposeNotifier`
2. **Mounted Checks**: Always check `ref.mounted` in async operations
3. **Testing Utilities**: Use new `ProviderContainer.test()` method
4. **Provider Overrides**: Use `overrideWithBuild` for notifier providers
5. **Lifecycle Management**: Enhanced `onDispose`, `onCancel`, `onResume` callbacks

### Performance Improvements in 3.0

1. **Reduced Memory Usage**: Better garbage collection of disposed providers
2. **Faster Rebuilds**: Optimized dependency tracking
3. **Improved Code Generation**: Smaller generated code footprint
4. **Better Tree Shaking**: Unused providers are eliminated more effectively
5. **Enhanced Caching**: Better caching strategies for computed values

### New Lint Rules

Update your `analysis_options.yaml` to include new Riverpod 3.0 lint rules:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - riverpod_final_provider
    - riverpod_ref_mounted_check
    - riverpod_avoid_manual_providers_as_generated_provider_dependency
    - riverpod_avoid_build_context_in_providers
    - riverpod_provider_dependencies
```
