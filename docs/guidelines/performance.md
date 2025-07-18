# Performance Optimization Guidelines

## Table of Contents
1. [Rendering Performance](#rendering-performance)
2. [State Management](#state-management)
3. [Network Optimization](#network-optimization)
4. [Memory Management](#memory-management)
5. [Build Optimization](#build-optimization)
6. [Image Optimization](#image-optimization)
7. [Startup Time](#startup-time)
8. [Jank Reduction](#jank-reduction)
9. [Animation Performance](#animation-performance)
10. [Performance Profiling](#performance-profiling)
11. [Monitoring & Benchmarking](#monitoring--benchmarking)
12. [Best Practices](#best-practices)

## Rendering Performance

### Use `const` Constructors (Flutter 3.24+)

```dart
// Good - Compile-time constants
class TodoCard extends StatelessWidget {
  const TodoCard({
    required this.todo,
    super.key,
  });

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              todo.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Bad - Rebuilds unnecessarily
Container(
  padding: EdgeInsets.all(16.0), // Non-const
  child: Text('Hello'), // Non-const
);
```

### Minimize Repaints with RepaintBoundary

```dart
// Use RepaintBoundary for complex widgets that change independently
class TodoList extends StatelessWidget {
  const TodoList({required this.todos, super.key});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        // Isolate each item to prevent unnecessary repaints
        return RepaintBoundary(
          child: TodoCard(todo: todos[index]),
        );
      },
    );
  }
}

// For animations that don't affect the rest of the UI
RepaintBoundary(
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    color: isSelected ? Colors.blue : Colors.grey,
    child: const Icon(Icons.check),
  ),
);
```

### Optimize List Views with Flutter 3.24+ Features

```dart
// Use ListView.builder with performance optimizations
ListView.builder(
  itemCount: items.length,
  // Fixed height improves scrolling performance
  itemExtent: 72.0,
  // Reduce overdraw with cacheExtent
  cacheExtent: 200.0,
  // Use addAutomaticKeepAlives for expensive items
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,
  addSemanticIndexes: true,
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: TodoListItem(
        key: ValueKey(items[index].id),
        todo: items[index],
      ),
    );
  },
);

// For variable height items, use ListView.separated
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) {
    return IntrinsicHeight(
      child: TodoCard(todo: items[index]),
    );
  },
);

// Use CustomScrollView for complex layouts
CustomScrollView(
  slivers: [
    const SliverAppBar(
      title: Text('Todos'),
      floating: true,
      snap: true,
    ),
    SliverList.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoCard(todo: todos[index]);
      },
    ),
  ],
);
```

### Widget Tree Optimization

```dart
// Good - Split complex widgets into smaller components
class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TodoAppBar(),
      body: TodoBody(),
      floatingActionButton: AddTodoFab(),
    );
  }
}

// Use Builder to limit rebuild scope
class TodoBody extends StatelessWidget {
  const TodoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final todos = ref.watch(todosProvider);
            return todos.when(
              data: (todoList) => TodoList(todos: todoList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorWidget(error),
            );
          },
        );
      },
    );
  }
}
```

## State Management

### Riverpod 3.0 Performance Patterns

#### Use Enhanced `select` for Granular Updates

```dart
// Riverpod 3.0 - Enhanced select with better performance
final username = ref.watch(userProvider.select((user) => user.name));

// Multiple selects for complex state
final userDisplayInfo = ref.watch(
  userProvider.select((user) => (user.name, user.avatar, user.isOnline)),
);

// Select with transformation
final todoCount = ref.watch(
  todosProvider.select((todos) => todos.length),
);

// Select nested properties efficiently
final urgentTodos = ref.watch(
  todosProvider.select((todos) => 
    todos.where((todo) => todo.priority == Priority.urgent).toList(),
  ),
);
```

#### Optimize Provider Scope and Lifecycle

```dart
// Use ProviderScope efficiently
ProviderScope(
  overrides: [
    // Only override what's necessary for this scope
    todoRepositoryProvider.overrideWithValue(mockRepository),
    userPreferencesProvider.overrideWithValue(testPreferences),
  ],
  child: const MyApp(),
);

// Use ref.mounted to prevent state updates after disposal
class TodoNotifier extends _$TodoNotifier {
  @override
  List<Todo> build() => [];

  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await ref.read(todoRepositoryProvider).create(todo);
      
      // Check if still mounted before updating state
      if (ref.mounted) {
        state = [...state, newTodo];
      }
    } catch (e) {
      if (ref.mounted) {
        // Handle error
      }
    }
  }
}
```

#### Use `autoDispose` and `keepAlive` Strategically

```dart
// Auto-dispose for temporary state
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

// Keep alive for expensive computations
@riverpod
Future<List<Todo>> filteredTodos(FilteredTodosRef ref) async {
  final todos = await ref.watch(todosProvider.future);
  final filter = ref.watch(todoFilterProvider);
  
  // Keep alive for 5 minutes after last use
  ref.keepAlive();
  Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  
  return todos.where((todo) => filter.matches(todo)).toList();
}

// Use family providers efficiently
@riverpod
Future<Todo> todoDetails(TodoDetailsRef ref, String id) async {
  // Auto-dispose when no longer watched
  return ref.watch(todoRepositoryProvider).getTodo(id);
}
```

#### Advanced State Management Patterns

```dart
// Use AsyncNotifier for complex async state
@riverpod
class TodosNotifier extends _$TodosNotifier {
  @override
  Future<List<Todo>> build() async {
    // Load initial data
    return ref.watch(todoRepositoryProvider).getAllTodos();
  }

  Future<void> addTodo(Todo todo) async {
    // Optimistic update
    final currentTodos = await future;
    state = AsyncData([...currentTodos, todo]);

    try {
      final savedTodo = await ref.read(todoRepositoryProvider).create(todo);
      
      if (ref.mounted) {
        // Update with server response
        final updatedTodos = currentTodos.map((t) => 
          t.id == todo.id ? savedTodo : t
        ).toList();
        state = AsyncData(updatedTodos);
      }
    } catch (e) {
      if (ref.mounted) {
        // Revert optimistic update
        state = AsyncData(currentTodos);
        // Show error
      }
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final todos = await ref.read(todoRepositoryProvider).getAllTodos();
      if (ref.mounted) {
        state = AsyncData(todos);
      }
    } catch (e) {
      if (ref.mounted) {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }
}

// Use select with AsyncValue
final isLoading = ref.watch(
  todosNotifierProvider.select((asyncTodos) => asyncTodos.isLoading),
);

final todoCount = ref.watch(
  todosNotifierProvider.select((asyncTodos) => 
    asyncTodos.valueOrNull?.length ?? 0,
  ),
);
```

## Network Optimization

### Use Pagination

```dart
class PaginatedTodos extends StatefulWidget {
  const PaginatedTodos({Key? key}) : super(key: key);

  @override
  _PaginatedTodosState createState() => _PaginatedTodosState();
}

class _PaginatedTodosState extends State<PaginatedTodos> {
  final ScrollController _scrollController = ScrollController();
  final int _perPage = 20;
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  
  final List<Todo> _todos = [];
  
  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }
  
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newTodos = await _todoRepository.getTodos(
        page: _page,
        perPage: _perPage,
      );
      
      setState(() {
        _isLoading = false;
        _page++;
        _todos.addAll(newTodos);
        _hasMore = newTodos.length == _perPage;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _todos.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _todos.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return TodoItem(todo: _todos[index]);
      },
    );
  }
}
```

### Cache Network Responses

```dart
final todoProvider = FutureProvider.autoDispose.family<Todo, String>((ref, id) async {
  // Cache the response for 5 minutes
  return ref.cacheFor(const Duration(minutes: 5), () async {
    return await _todoRepository.getTodo(id);
  });
});

// Or with Riverpod's built-in caching
final todoProvider = FutureProvider.autoDispose.family<Todo, String>((ref, id) {
  return _todoRepository.getTodo(id);
}, cacheTime: const Duration(minutes: 5));
```

### Advanced Network Optimization

#### Implement Smart Pagination

```dart
@riverpod
class PaginatedTodos extends _$PaginatedTodos {
  @override
  Future<PaginatedResult<Todo>> build({
    int page = 0,
    int limit = 20,
    String? filter,
  }) async {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.getTodos(
      page: page,
      limit: limit,
      filter: filter,
    );
  }

  Future<void> loadMore() async {
    final current = await future;
    if (!current.hasMore) return;

    final nextPage = await ref.read(todoRepositoryProvider).getTodos(
      page: current.page + 1,
      limit: current.limit,
      filter: current.filter,
    );

    if (ref.mounted) {
      state = AsyncData(current.copyWith(
        items: [...current.items, ...nextPage.items],
        page: nextPage.page,
        hasMore: nextPage.hasMore,
      ));
    }
  }
}

// Use in widget
class TodoListView extends ConsumerWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedTodos = ref.watch(paginatedTodosProvider());
    
    return paginatedTodos.when(
      data: (result) => ListView.builder(
        itemCount: result.items.length + (result.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= result.items.length) {
            // Load more when reaching the end
            ref.read(paginatedTodosProvider().notifier).loadMore();
            return const Center(child: CircularProgressIndicator());
          }
          return TodoCard(todo: result.items[index]);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

#### Advanced Caching Strategies

```dart
// Multi-level caching with Riverpod 3.0
@riverpod
Future<Todo> todoWithCache(TodoWithCacheRef ref, String id) async {
  // Level 1: Memory cache (automatic with Riverpod)
  // Level 2: Local storage cache
  final localStorage = ref.watch(localStorageProvider);
  final cached = await localStorage.getTodo(id);
  
  if (cached != null && !cached.isStale) {
    return cached;
  }
  
  // Level 3: Network request
  final repository = ref.watch(todoRepositoryProvider);
  final todo = await repository.getTodo(id);
  
  // Cache for future use
  await localStorage.saveTodo(todo);
  
  return todo;
}

// Cache invalidation patterns
@riverpod
class TodoCache extends _$TodoCache {
  @override
  Map<String, Todo> build() => {};

  void invalidate(String id) {
    state = Map.from(state)..remove(id);
    // Also invalidate related providers
    ref.invalidate(todoWithCacheProvider(id));
  }

  void invalidateAll() {
    state = {};
    // Invalidate all related providers
    for (final id in state.keys) {
      ref.invalidate(todoWithCacheProvider(id));
    }
  }
}
```

#### Optimized Real-time Updates

```dart
// Efficient WebSocket handling with Riverpod 3.0
@riverpod
Stream<List<Todo>> todosStream(TodosStreamRef ref) {
  final userId = ref.watch(authProvider.select((auth) => auth.user?.id));
  if (userId == null) return const Stream.empty();

  final supabase = ref.watch(supabaseProvider);
  
  return supabase
      .from('todos')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at')
      .map((data) => data.map((json) => Todo.fromJson(json)).toList())
      .distinct() // Prevent duplicate emissions
      .debounceTime(const Duration(milliseconds: 100)); // Batch rapid updates
}

// Combine real-time updates with local state
@riverpod
class TodosWithRealtime extends _$TodosWithRealtime {
  @override
  Future<List<Todo>> build() async {
    // Listen to real-time updates
    ref.listen(todosStreamProvider, (previous, next) {
      next.whenData((todos) {
        if (ref.mounted) {
          state = AsyncData(todos);
        }
      });
    });

    // Return initial data
    return ref.watch(todoRepositoryProvider).getAllTodos();
  }
}
```

#### Network Request Optimization

```dart
// Batch multiple requests
@riverpod
Future<Map<String, Todo>> batchTodos(BatchTodosRef ref, List<String> ids) async {
  final repository = ref.watch(todoRepositoryProvider);
  
  // Batch requests to reduce network overhead
  final todos = await repository.getTodosBatch(ids);
  return Map.fromEntries(
    todos.map((todo) => MapEntry(todo.id, todo)),
  );
}

// Request deduplication
@riverpod
Future<Todo> debouncedTodo(DebouncedTodoRef ref, String id) async {
  // Debounce rapid requests for the same resource
  await Future.delayed(const Duration(milliseconds: 50));
  
  if (!ref.mounted) throw Exception('Request cancelled');
  
  return ref.watch(todoRepositoryProvider).getTodo(id);
}

// Retry with exponential backoff
@riverpod
Future<List<Todo>> resilientTodos(ResilientTodosRef ref) async {
  const maxRetries = 3;
  const baseDelay = Duration(seconds: 1);
  
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await ref.watch(todoRepositoryProvider).getAllTodos();
    } catch (e) {
      if (attempt == maxRetries - 1) rethrow;
      
      final delay = baseDelay * (1 << attempt); // Exponential backoff
      await Future.delayed(delay);
    }
  }
  
  throw Exception('Max retries exceeded');
}
```

## Memory Management

### Modern Resource Management

```dart
// Use Riverpod's automatic disposal
@riverpod
class ResourceManager extends _$ResourceManager {
  StreamController<String>? _controller;
  StreamSubscription<String>? _subscription;
  
  @override
  String build() {
    // Set up resources
    _controller = StreamController<String>();
    _subscription = _controller!.stream.listen(_handleData);
    
    // Automatic cleanup when provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
      _controller?.close();
    });
    
    return 'initialized';
  }
  
  void _handleData(String data) {
    // Handle stream data
  }
}

// Use ref.onDispose for cleanup
@riverpod
Future<DatabaseConnection> databaseConnection(DatabaseConnectionRef ref) async {
  final connection = await Database.connect();
  
  // Ensure connection is closed when provider is disposed
  ref.onDispose(() {
    connection.close();
  });
  
  return connection;
}
```

### Optimize Object Creation

```dart
// Use const constructors and static constants
class TodoConstants {
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(8.0));
}

// Use factory constructors for object pooling
class TodoCard extends StatelessWidget {
  const TodoCard._({
    required this.todo,
    required this.onTap,
    super.key,
  });
  
  factory TodoCard({
    required Todo todo,
    required VoidCallback onTap,
    Key? key,
  }) {
    // Reuse instances for identical todos
    return TodoCard._(
      todo: todo,
      onTap: onTap,
      key: key ?? ValueKey(todo.id),
    );
  }
  
  final Todo todo;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: TodoConstants.cardPadding,
      shape: const RoundedRectangleBorder(
        borderRadius: TodoConstants.cardBorderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: TodoConstants.cardBorderRadius,
        child: Padding(
          padding: TodoConstants.cardPadding,
          child: Text(todo.title),
        ),
      ),
    );
  }
}
```

### Memory-Efficient Data Loading

```dart
// Lazy loading with pagination
@riverpod
class LazyTodoLoader extends _$LazyTodoLoader {
  final Map<String, Todo> _cache = {};
  
  @override
  Future<Todo?> build(String id) async {
    // Check cache first
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    
    // Load from repository
    final todo = await ref.watch(todoRepositoryProvider).getTodo(id);
    
    // Cache with size limit
    if (_cache.length > 100) {
      // Remove oldest entries
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    
    _cache[id] = todo;
    return todo;
  }
  
  void clearCache() {
    _cache.clear();
    ref.invalidateSelf();
  }
}

// Use weak references for callbacks
class TodoListItem extends StatelessWidget {
  const TodoListItem({
    required this.todo,
    required this.onTap,
    super.key,
  });
  
  final Todo todo;
  final void Function(String id) onTap;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      onTap: () => onTap(todo.id), // Pass ID instead of capturing widget
    );
  }
}
```

### Memory Monitoring

```dart
// Monitor memory usage in development
@riverpod
class MemoryMonitor extends _$MemoryMonitor {
  Timer? _timer;
  
  @override
  Map<String, dynamic> build() {
    if (kDebugMode) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        _logMemoryUsage();
      });
      
      ref.onDispose(() {
        _timer?.cancel();
      });
    }
    
    return {};
  }
  
  void _logMemoryUsage() {
    final info = ProcessInfo.currentRss;
    debugPrint('Memory usage: ${info ~/ 1024 ~/ 1024} MB');
    
    // Log widget tree depth
    final context = WidgetsBinding.instance.rootElement;
    if (context != null) {
      final depth = _calculateWidgetDepth(context);
      debugPrint('Widget tree depth: $depth');
    }
  }
  
  int _calculateWidgetDepth(Element element) {
    int maxDepth = 0;
    element.visitChildren((child) {
      final depth = _calculateWidgetDepth(child) + 1;
      if (depth > maxDepth) maxDepth = depth;
    });
    return maxDepth;
  }
}
```

## Build Optimization

### Modern Build_Runner Patterns

```dart
// Optimize build.yaml for faster code generation
targets:
  $default:
    builders:
      # Riverpod code generation
      riverpod_generator:
        options:
          # Generate only what's needed
          generate_riverpod_debug_info: false
        enabled: true
      
      # Freezed code generation
      freezed:
        options:
          # Optimize for build speed
          explicit_to_json: true
          copy_with: true
          equal: true
          to_string: true
        enabled: true
      
      # JSON serialization
      json_serializable:
        options:
          # Optimize generated code
          explicit_to_json: true
          include_if_null: false
          field_rename: snake
        enabled: true

# Use incremental builds
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### Widget Construction Optimization

```dart
// Use const constructors effectively
class OptimizedTodoCard extends StatelessWidget {
  const OptimizedTodoCard({
    required this.todo,
    this.onTap,
    super.key,
  });

  final Todo todo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Cache theme data
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Card(
      // Use const where possible
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.title,
                style: textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  todo.description,
                  style: textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Advanced Layout Optimization

```dart
// Use LayoutBuilder with caching for responsive layouts
class ResponsiveTodoLayout extends StatelessWidget {
  const ResponsiveTodoLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cache layout decisions
        final isWide = constraints.maxWidth > 600;
        final isTablet = constraints.maxWidth > 900;
        
        if (isTablet) {
          return _buildTabletLayout();
        } else if (isWide) {
          return _buildWideLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }
  
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sidebar
        const SizedBox(
          width: 300,
          child: TodoSidebar(),
        ),
        const VerticalDivider(width: 1),
        // Main content
        const Expanded(
          flex: 2,
          child: TodoMainContent(),
        ),
        const VerticalDivider(width: 1),
        // Details panel
        const SizedBox(
          width: 400,
          child: TodoDetailsPanel(),
        ),
      ],
    );
  }
  
  Widget _buildWideLayout() {
    return Row(
      children: [
        const Expanded(child: TodoSidebar()),
        const VerticalDivider(width: 1),
        const Expanded(flex: 2, child: TodoMainContent()),
      ],
    );
  }
  
  Widget _buildMobileLayout() {
    return const Column(
      children: [
        Expanded(child: TodoMainContent()),
        TodoBottomNavigation(),
      ],
    );
  }
}

// Use Builder to limit rebuild scope
class TodoMainContent extends StatelessWidget {
  const TodoMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            // Only rebuild when todos change
            final todosAsync = ref.watch(todosProvider);
            
            return todosAsync.when(
              data: (todos) => TodoList(todos: todos),
              loading: () => const TodoLoadingView(),
              error: (error, stack) => TodoErrorView(error: error),
            );
          },
        );
      },
    );
  }
}
```

### Build Performance Monitoring

```dart
// Monitor build performance in development
class BuildPerformanceMonitor extends StatelessWidget {
  const BuildPerformanceMonitor({
    required this.child,
    this.name,
    super.key,
  });

  final Widget child;
  final String? name;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      
      return Builder(
        builder: (context) {
          final result = child;
          
          stopwatch.stop();
          final buildTime = stopwatch.elapsedMicroseconds;
          
          if (buildTime > 1000) { // Log builds taking > 1ms
            debugPrint(
              'Slow build: ${name ?? runtimeType} took ${buildTime}μs',
            );
          }
          
          return result;
        },
      );
    }
    
    return child;
  }
}

// Usage
BuildPerformanceMonitor(
  name: 'TodoCard',
  child: TodoCard(todo: todo),
);
```

## Image Optimization

### Modern Image Formats and Optimization

```dart
// Use WebP for better compression (2025 standard)
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // Prefer WebP, fallback to original format
    final webpUrl = imageUrl.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '.webp');
    
    return CachedNetworkImage(
      imageUrl: webpUrl,
      width: width,
      height: height,
      fit: fit,
      // Progressive loading
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: progress.progress,
              strokeWidth: 2,
            ),
          ),
        );
      },
      // Fallback to original format
      errorWidget: (context, url, error) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          ),
        );
      },
      // Memory cache optimization
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
```

### Advanced Image Caching

```dart
// Configure image cache in main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optimize image cache for 2025 devices
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 200; // Increase for modern devices
  imageCache.maximumSizeBytes = 200 << 20; // 200MB for high-res images
  
  // Configure network image cache
  DefaultCacheManager().emptyCache(); // Clear on app start if needed
  
  runApp(const MyApp());
}

// Smart image preloading
@riverpod
class ImagePreloader extends _$ImagePreloader {
  @override
  Set<String> build() => {};

  Future<void> preloadImages(BuildContext context, List<String> urls) async {
    final futures = urls.where((url) => !state.contains(url)).map((url) async {
      try {
        await precacheImage(NetworkImage(url), context);
        if (ref.mounted) {
          state = {...state, url};
        }
      } catch (e) {
        debugPrint('Failed to preload image: $url');
      }
    });
    
    await Future.wait(futures);
  }
}
```

### SVG Optimization

```dart
// Optimized SVG handling
class OptimizedSvgIcon extends StatelessWidget {
  const OptimizedSvgIcon({
    required this.assetPath,
    this.size = 24.0,
    this.color,
    super.key,
  });

  final String assetPath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      // Cache SVG parsing
      placeholderBuilder: (context) => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 1),
      ),
    );
  }
}

// SVG icon cache
@riverpod
class SvgIconCache extends _$SvgIconCache {
  final Map<String, SvgPicture> _cache = {};
  
  @override
  Map<String, SvgPicture> build() => {};

  SvgPicture getIcon(String assetPath, {double size = 24.0, Color? color}) {
    final key = '$assetPath-$size-${color?.value}';
    
    if (!_cache.containsKey(key)) {
      _cache[key] = SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        colorFilter: color != null 
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
    }
    
    return _cache[key]!;
  }
}
```

### Responsive Image Loading

```dart
// Load appropriate image sizes based on device
class ResponsiveImage extends StatelessWidget {
  const ResponsiveImage({
    required this.baseUrl,
    this.aspectRatio = 16 / 9,
    super.key,
  });

  final String baseUrl;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final targetWidth = (constraints.maxWidth * devicePixelRatio).toInt();
        
        // Choose appropriate image size
        String imageUrl;
        if (targetWidth <= 400) {
          imageUrl = '${baseUrl}_400w.webp';
        } else if (targetWidth <= 800) {
          imageUrl = '${baseUrl}_800w.webp';
        } else if (targetWidth <= 1200) {
          imageUrl = '${baseUrl}_1200w.webp';
        } else {
          imageUrl = '${baseUrl}_1600w.webp';
        }
        
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: OptimizedImage(
            imageUrl: imageUrl,
            width: constraints.maxWidth,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
```

## Startup Time

### Optimized App Initialization (2025)

```dart
// main.dart - Optimized startup sequence
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure performance settings early
  _configurePerformance();
  
  // Show splash immediately
  runApp(const SplashApp());
  
  // Initialize services in parallel
  final initFuture = _initializeServices();
  
  // Wait for minimum splash duration and initialization
  await Future.wait([
    initFuture,
    Future.delayed(const Duration(milliseconds: 1500)), // Minimum splash time
  ]);
  
  // Switch to main app
  runApp(
    ProviderScope(
      child: const TodoApp(),
    ),
  );
}

void _configurePerformance() {
  // Optimize image cache
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200MB
  
  // Configure HTTP client
  HttpOverrides.global = _CustomHttpOverrides();
  
  // Set up error handling
  FlutterError.onError = (details) {
    // Log to crash reporting service
    debugPrint('Flutter Error: ${details.exception}');
  };
}

Future<void> _initializeServices() async {
  try {
    // Critical services first
    await Future.wait([
      _initializeSupabase(),
      _loadUserPreferences(),
    ]);
    
    // Non-critical services
    unawaited(_initializeAnalytics());
    unawaited(_initializeCrashReporting());
    unawaited(_preloadCriticalData());
  } catch (e) {
    debugPrint('Service initialization error: $e');
    // Continue with app launch even if some services fail
  }
}

// Splash app with minimal dependencies
class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}
```

### Deferred Loading Patterns

```dart
// Lazy load heavy packages
class DeferredFeatures {
  static Future<void> loadCamera() async {
    // Load camera package only when needed
    await import('package:camera/camera.dart') as camera;
    return camera.availableCameras();
  }
  
  static Future<void> loadImagePicker() async {
    // Deferred loading for image picker
    final picker = await import('package:image_picker/image_picker.dart');
    return picker.ImagePicker();
  }
  
  static Future<void> loadMaps() async {
    // Load maps only when navigation is needed
    await import('package:google_maps_flutter/google_maps_flutter.dart');
  }
}

// Use deferred loading in widgets
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadCameraFeature();
  }
  
  Future<void> _loadCameraFeature() async {
    try {
      await DeferredFeatures.loadCamera();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading camera...'),
            ],
          ),
        ),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCameraFeature,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return const CameraView();
  }
}
```

### Background Initialization

```dart
// Initialize non-critical services in background
@riverpod
class BackgroundInitializer extends _$BackgroundInitializer {
  @override
  Future<bool> build() async {
    // Run background tasks
    unawaited(_initializeAnalytics());
    unawaited(_preloadImages());
    unawaited(_syncOfflineData());
    unawaited(_updateAppConfig());
    
    return true;
  }
  
  Future<void> _initializeAnalytics() async {
    try {
      // Initialize analytics service
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('Analytics initialized');
    } catch (e) {
      debugPrint('Analytics initialization failed: $e');
    }
  }
  
  Future<void> _preloadImages() async {
    try {
      // Preload critical images
      final context = WidgetsBinding.instance.rootElement;
      if (context != null) {
        await Future.wait([
          precacheImage(const AssetImage('assets/images/logo.png'), context),
          precacheImage(const AssetImage('assets/images/placeholder.png'), context),
        ]);
      }
    } catch (e) {
      debugPrint('Image preloading failed: $e');
    }
  }
  
  Future<void> _syncOfflineData() async {
    try {
      // Sync any offline data
      await Future.delayed(const Duration(seconds: 3));
      debugPrint('Offline data synced');
    } catch (e) {
      debugPrint('Offline sync failed: $e');
    }
  }
  
  Future<void> _updateAppConfig() async {
    try {
      // Update app configuration
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('App config updated');
    } catch (e) {
      debugPrint('Config update failed: $e');
    }
  }
}
```

## Jank Reduction

### Strategic RepaintBoundary Usage

```dart
// Use RepaintBoundary to isolate expensive repaints
class OptimizedTodoList extends StatelessWidget {
  const OptimizedTodoList({
    required this.todos,
    super.key,
  });

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      // Reduce overdraw
      cacheExtent: 200.0,
      itemBuilder: (context, index) {
        // Isolate each item to prevent cascade repaints
        return RepaintBoundary(
          child: TodoListItem(
            key: ValueKey(todos[index].id),
            todo: todos[index],
          ),
        );
      },
    );
  }
}

// Complex widgets with animations
class AnimatedTodoCard extends StatefulWidget {
  const AnimatedTodoCard({
    required this.todo,
    super.key,
  });

  final Todo todo;

  @override
  State<AnimatedTodoCard> createState() => _AnimatedTodoCardState();
}

class _AnimatedTodoCardState extends State<AnimatedTodoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Isolate animation to prevent parent rebuilds
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: TodoCard(todo: widget.todo),
      ),
    );
  }
}
```

### Advanced Animation Optimization

```dart
// Use AnimatedBuilder for complex animations
class PerformantLoadingIndicator extends StatefulWidget {
  const PerformantLoadingIndicator({super.key});

  @override
  State<PerformantLoadingIndicator> createState() => 
      _PerformantLoadingIndicatorState();
}

class _PerformantLoadingIndicatorState extends State<PerformantLoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseController]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            ),
          );
        },
        child: const Icon(
          Icons.refresh,
          size: 24,
          color: Colors.blue,
        ),
      ),
    );
  }
}
```

### Scroll Performance Optimization

```dart
// Optimize scroll performance
class HighPerformanceScrollView extends StatelessWidget {
  const HighPerformanceScrollView({
    required this.items,
    super.key,
  });

  final List<Todo> items;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Optimize scroll physics
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          title: const Text('Todos'),
          floating: true,
          snap: true,
          // Prevent unnecessary rebuilds
          pinned: false,
        ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: KeepAlive(
                keepAlive: index < 10, // Keep first 10 items alive
                child: TodoListItem(
                  key: ValueKey(items[index].id),
                  todo: items[index],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Custom KeepAlive widget
class KeepAlive extends StatefulWidget {
  const KeepAlive({
    required this.child,
    required this.keepAlive,
    super.key,
  });

  final Widget child;
  final bool keepAlive;

  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
```

## Animation Performance

### Modern Animation Techniques

```dart
// Use Lottie for complex animations
class LottieLoadingAnimation extends StatelessWidget {
  const LottieLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        // Optimize for performance
        options: LottieOptions(
          enableMergePaths: true,
        ),
      ),
    );
  }
}

// Use Rive for interactive animations
class InteractiveRiveAnimation extends StatefulWidget {
  const InteractiveRiveAnimation({super.key});

  @override
  State<InteractiveRiveAnimation> createState() => 
      _InteractiveRiveAnimationState();
}

class _InteractiveRiveAnimationState extends State<InteractiveRiveAnimation> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('idle');
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RiveAnimation.asset(
        'assets/animations/button.riv',
        controllers: [_controller],
        onInit: (artboard) {
          // Animation initialized
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Optimized Transition Animations

```dart
// Custom page transitions for better performance
class OptimizedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  OptimizedPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Use efficient slide transition
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        );
}

// Hero animations with performance optimization
class OptimizedHeroImage extends StatelessWidget {
  const OptimizedHeroImage({
    required this.tag,
    required this.imageUrl,
    this.width,
    this.height,
    super.key,
  });

  final String tag;
  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      // Optimize hero animation
      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return OptimizedImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
              );
            },
          ),
        );
      },
      child: OptimizedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
```

## Performance Profiling

### Modern DevTools Usage (2025)

```bash
# Run app in profile mode for accurate performance data
flutter run --profile --enable-software-rendering

# Open DevTools with enhanced features
dart devtools --port=9100

# For web performance profiling
flutter run -d chrome --profile --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Advanced Performance Monitoring

```dart
// Performance monitoring service
@riverpod
class PerformanceMonitor extends _$PerformanceMonitor {
  Timer? _timer;
  final List<PerformanceMetric> _metrics = [];

  @override
  bool build() {
    if (kDebugMode || kProfileMode) {
      _startMonitoring();
      
      ref.onDispose(() {
        _timer?.cancel();
      });
    }
    
    return true;
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _collectMetrics();
    });
  }

  void _collectMetrics() {
    final metric = PerformanceMetric(
      timestamp: DateTime.now(),
      memoryUsage: _getMemoryUsage(),
      frameRate: _getFrameRate(),
      buildCount: _getBuildCount(),
    );
    
    _metrics.add(metric);
    
    // Keep only last 100 metrics
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }
    
    // Log performance issues
    if (metric.frameRate < 55) {
      debugPrint('Performance warning: Low frame rate ${metric.frameRate}');
    }
    
    if (metric.memoryUsage > 200 * 1024 * 1024) { // 200MB
      debugPrint('Performance warning: High memory usage ${metric.memoryUsage ~/ 1024 ~/ 1024}MB');
    }
  }

  int _getMemoryUsage() {
    // Get current memory usage
    return ProcessInfo.currentRss;
  }

  double _getFrameRate() {
    // Calculate current frame rate
    final binding = WidgetsBinding.instance;
    return 60.0; // Simplified - use actual frame timing in real implementation
  }

  int _getBuildCount() {
    // Track widget builds
    return _buildCounter.value;
  }
}

class PerformanceMetric {
  final DateTime timestamp;
  final int memoryUsage;
  final double frameRate;
  final int buildCount;

  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.frameRate,
    required this.buildCount,
  });
}
```

### Build Performance Tracking

```dart
// Track widget build performance
class BuildTracker extends StatelessWidget {
  const BuildTracker({
    required this.child,
    required this.name,
    super.key,
  });

  final Widget child;
  final String name;

  static final Map<String, List<int>> _buildTimes = {};
  static final ValueNotifier<int> _buildCounter = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      
      return Builder(
        builder: (context) {
          final result = child;
          
          stopwatch.stop();
          final buildTime = stopwatch.elapsedMicroseconds;
          
          // Track build times
          _buildTimes.putIfAbsent(name, () => []);
          _buildTimes[name]!.add(buildTime);
          
          // Keep only last 50 builds
          if (_buildTimes[name]!.length > 50) {
            _buildTimes[name]!.removeAt(0);
          }
          
          _buildCounter.value++;
          
          // Log slow builds
          if (buildTime > 5000) { // 5ms
            final average = _buildTimes[name]!.reduce((a, b) => a + b) / 
                           _buildTimes[name]!.length;
            debugPrint(
              'Slow build: $name took ${buildTime}μs (avg: ${average.toInt()}μs)',
            );
          }
          
          return result;
        },
      );
    }
    
    return child;
  }
  
  static Map<String, double> getAverageBuildTimes() {
    return _buildTimes.map((name, times) {
      final average = times.reduce((a, b) => a + b) / times.length;
      return MapEntry(name, average);
    });
  }
}

// Usage
BuildTracker(
  name: 'TodoCard',
  child: TodoCard(todo: todo),
);
```

### Performance Testing

```dart
// Performance test utilities
class PerformanceTestUtils {
  static Future<void> measureScrollPerformance(
    WidgetTester tester,
    Finder scrollable,
  ) async {
    final stopwatch = Stopwatch();
    
    stopwatch.start();
    await tester.fling(scrollable, const Offset(0, -500), 1000);
    await tester.pumpAndSettle();
    stopwatch.stop();
    
    final scrollTime = stopwatch.elapsedMilliseconds;
    expect(scrollTime, lessThan(1000), reason: 'Scroll should complete in <1s');
  }
  
  static Future<void> measureBuildPerformance(
    WidgetTester tester,
    Widget widget,
  ) async {
    final stopwatch = Stopwatch();
    
    stopwatch.start();
    await tester.pumpWidget(widget);
    stopwatch.stop();
    
    final buildTime = stopwatch.elapsedMilliseconds;
    expect(buildTime, lessThan(100), reason: 'Build should complete in <100ms');
  }
  
  static Future<void> measureAnimationPerformance(
    WidgetTester tester,
    Widget widget,
    Duration animationDuration,
  ) async {
    await tester.pumpWidget(widget);
    
    final stopwatch = Stopwatch()..start();
    await tester.pump(animationDuration);
    stopwatch.stop();
    
    final actualDuration = stopwatch.elapsedMilliseconds;
    final expectedDuration = animationDuration.inMilliseconds;
    
    expect(
      actualDuration,
      closeTo(expectedDuration, expectedDuration * 0.1),
      reason: 'Animation timing should be accurate within 10%',
    );
  }
}
```

## Monitoring & Benchmarking

### CI/CD Performance Integration

```yaml
# .github/workflows/performance.yml
name: Performance Tests

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run performance tests
        run: |
          flutter test integration_test/performance_test.dart \
            --performance-metrics \
            --reporter=json > performance_results.json
            
      - name: Analyze performance
        run: |
          dart run tools/analyze_performance.dart performance_results.json
          
      - name: Upload performance artifacts
        uses: actions/upload-artifact@v4
        with:
          name: performance-results
          path: performance_results.json
```

### Performance Benchmarking

```dart
// integration_test/performance_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Performance Tests', () {
    testWidgets('Todo list scroll performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to todo list
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      
      // Measure scroll performance
      await binding.traceAction(
        () async {
          final listFinder = find.byType(ListView);
          await tester.fling(listFinder, const Offset(0, -500), 1000);
          await tester.pumpAndSettle();
        },
        reportKey: 'todo_list_scroll',
      );
    });
    
    testWidgets('Todo creation performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Measure todo creation time
      await binding.traceAction(
        () async {
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();
          
          await tester.enterText(find.byType(TextField).first, 'Test Todo');
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
        },
        reportKey: 'todo_creation',
      );
    });
    
    testWidgets('App startup performance', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert startup time is reasonable
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
        reason: 'App should start in less than 3 seconds',
      );
      
      // Report startup time
      await binding.reportData(<String, dynamic>{
        'startup_time_ms': stopwatch.elapsedMilliseconds,
      });
    });
  });
}
```

### Performance Metrics Collection

```dart
// lib/services/performance_service.dart
@riverpod
class PerformanceService extends _$PerformanceService {
  @override
  Map<String, dynamic> build() => {};

  void recordMetric(String name, double value, {String? unit}) {
    final metric = {
      'name': name,
      'value': value,
      'unit': unit ?? 'ms',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    state = {...state, name: metric};
    
    // Send to analytics in production
    if (kReleaseMode) {
      _sendToAnalytics(metric);
    }
  }
  
  void recordBuildTime(String widgetName, int microseconds) {
    recordMetric(
      'build_time_$widgetName',
      microseconds / 1000,
      unit: 'ms',
    );
  }
  
  void recordNetworkTime(String endpoint, int milliseconds) {
    recordMetric(
      'network_time_$endpoint',
      milliseconds.toDouble(),
      unit: 'ms',
    );
  }
  
  void recordMemoryUsage(int bytes) {
    recordMetric(
      'memory_usage',
      bytes / 1024 / 1024,
      unit: 'MB',
    );
  }
  
  Future<void> _sendToAnalytics(Map<String, dynamic> metric) async {
    // Send to your analytics service
    try {
      // await analyticsService.track('performance_metric', metric);
    } catch (e) {
      debugPrint('Failed to send performance metric: $e');
    }
  }
  
  Map<String, dynamic> getMetricsSummary() {
    final metrics = state.values.toList();
    
    return {
      'total_metrics': metrics.length,
      'average_build_time': _calculateAverageForPrefix('build_time_'),
      'average_network_time': _calculateAverageForPrefix('network_time_'),
      'peak_memory_usage': _getPeakValue('memory_usage'),
    };
  }
  
  double _calculateAverageForPrefix(String prefix) {
    final matchingMetrics = state.entries
        .where((entry) => entry.key.startsWith(prefix))
        .map((entry) => entry.value['value'] as double)
        .toList();
    
    if (matchingMetrics.isEmpty) return 0.0;
    
    return matchingMetrics.reduce((a, b) => a + b) / matchingMetrics.length;
  }
  
  double _getPeakValue(String metricName) {
    final metric = state[metricName];
    return metric?['value'] ?? 0.0;
  }
}
```

## Best Practices

### 2025 Performance Guidelines

#### General Principles
1. **Profile first, optimize second**: Always measure before optimizing
2. **Use const constructors everywhere**: Leverage compile-time optimizations
3. **Minimize widget rebuilds**: Use Riverpod's select and proper state management
4. **Optimize for 120Hz displays**: Target 120fps for modern devices
5. **Test on real devices**: Emulators don't reflect real performance

#### State Management (Riverpod 3.0)
1. **Use enhanced select**: Leverage new select capabilities for granular updates
2. **Implement ref.mounted checks**: Prevent state updates after disposal
3. **Use autoDispose strategically**: Balance memory usage with performance
4. **Leverage AsyncNotifier**: For complex async state management
5. **Implement proper error boundaries**: Prevent cascading failures

#### Network Optimization
1. **Implement smart pagination**: Load data incrementally
2. **Use multi-level caching**: Memory, local storage, and CDN
3. **Batch network requests**: Reduce round trips
4. **Implement retry with backoff**: Handle network failures gracefully
5. **Use WebSockets efficiently**: For real-time features

#### Memory Management
1. **Use Riverpod's automatic disposal**: Leverage built-in lifecycle management
2. **Implement object pooling**: For frequently created objects
3. **Monitor memory usage**: Set up automated monitoring
4. **Use weak references**: For callbacks and listeners
5. **Optimize image memory**: Use appropriate formats and sizes

#### Build Optimization
1. **Use build_runner efficiently**: Optimize code generation workflows
2. **Implement RepaintBoundary strategically**: Isolate expensive repaints
3. **Cache expensive computations**: Use memoization patterns
4. **Optimize layout calculations**: Minimize constraint solving
5. **Use const widgets**: Maximize compile-time optimizations

#### Image Optimization
1. **Use WebP format**: Better compression than PNG/JPEG
2. **Implement responsive images**: Load appropriate sizes
3. **Use SVG for icons**: Vector graphics scale better
4. **Implement progressive loading**: Show placeholders while loading
5. **Cache images aggressively**: Use multi-level caching

#### Startup Time
1. **Defer non-critical initialization**: Show UI immediately
2. **Use deferred loading**: Load features on demand
3. **Optimize dependency injection**: Minimize startup overhead
4. **Implement background initialization**: Load services asynchronously
5. **Monitor startup metrics**: Track and optimize startup time

#### Animation Performance
1. **Use RepaintBoundary for animations**: Isolate animated content
2. **Prefer AnimatedBuilder**: Over setState for animations
3. **Use Lottie/Rive for complex animations**: Better than custom implementations
4. **Optimize hero animations**: Use efficient flight shuttles
5. **Target 120fps**: For smooth animations on modern devices

#### Monitoring & Testing
1. **Implement performance monitoring**: Track key metrics in production
2. **Set up CI/CD performance tests**: Catch regressions early
3. **Use DevTools effectively**: Profile regularly during development
4. **Establish performance budgets**: Set and enforce limits
5. **Monitor real user metrics**: Track performance in production

#### Platform-Specific Optimizations
1. **Optimize for web**: Use SKIA renderer, optimize bundle size
2. **Leverage platform channels efficiently**: Minimize bridge overhead
3. **Use platform-specific optimizations**: iOS/Android specific features
4. **Optimize for different screen densities**: Handle various device types
5. **Test across platforms**: Ensure consistent performance

#### Security & Performance
1. **Implement secure caching**: Don't cache sensitive data
2. **Use HTTPS everywhere**: But optimize TLS handshakes
3. **Validate input efficiently**: Balance security with performance
4. **Implement rate limiting**: Protect against abuse
5. **Monitor for performance attacks**: Detect and mitigate threats

#### Future-Proofing
1. **Stay updated with Flutter releases**: Adopt new performance features
2. **Monitor dependency updates**: Keep packages current
3. **Implement feature flags**: Enable gradual rollouts
4. **Plan for scaling**: Design for growth
5. **Document performance decisions**: Maintain institutional knowledge
