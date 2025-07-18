# Flutter Todo App - Development Guidelines

## Table of Contents
1. [Project Structure](#project-structure)
2. [Code Style](#code-style)
3. [State Management](#state-management)
4. [Supabase Integration](#supabase-integration)
5. [Error Handling](#error-handling)
6. [Testing](#testing)
7. [Version Control](#version-control)
8. [Documentation](#documentation)

## Project Structure

```
lib/
├── core/                  # Core functionality
│   ├── constants/        # App-wide constants
│   ├── errors/           # Custom error classes
│   ├── utils/            # Utility functions and helpers
│   └── theme/            # App theming
├── features/             # Feature-based modules
│   └── todos/            # Todo feature
│       ├── data/         # Data layer
│       │   ├── models/   # Data models
│       │   ├── sources/  # Data sources (local/remote)
│       │   └── repositories/ # Repository implementations
│       ├── domain/       # Business logic
│       │   ├── entities/ # Business entities
│       │   └── repositories/ # Repository interfaces
│       └── presentation/ # UI layer
│           ├── screens/  # Full screens
│           ├── widgets/  # Reusable widgets
│           └── providers/ # Riverpod providers
└── main.dart             # App entry point
```

## Code Style

### Naming Conventions
- **Files**: Use `snake_case` for file names (e.g., `todo_list_screen.dart`)
- **Classes**: Use `PascalCase` (e.g., `TodoListScreen`)
- **Variables and Functions**: Use `camelCase` (e.g., `final todoList`, `Future<void> fetchTodos()`)
- **Constants**: Use `lowerCamelCase` for private constants and `UPPER_SNAKE_CASE` for public constants

### Formatting
- Use 2 spaces for indentation
- Maximum line length: 80 characters
- Always add trailing commas for better git diffs
- Use `//` for comments and `///` for documentation

## State Management

### flutter_hooks Integration

#### Basic Usage
```dart
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final todos = useState<List<Todo>>([]);
    
    // Fetch todos on init
    useEffect(() {
      fetchTodos().then((value) => todos.value = value);
      return null; // No cleanup needed
    }, const []);
    
    return Scaffold(
      body: ListView.builder(
        itemCount: todos.value.length,
        itemBuilder: (context, index) => 
            TodoItem(todo: todos.value[index]),
      ),
    );
  }
}
```

#### Useful Hooks
- `useState`: Manage local state
- `useEffect`: Handle side effects
- `useMemoized`: Memoize computed values
- `useContext`: Access BuildContext
- `useRef`: Keep mutable references
- `useAnimationController`: For animations

### Freezed Integration

#### Basic Setup
Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.5.4
  freezed: ^3.1.0
  json_serializable: ^6.9.5
```

#### Model Definition
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? description,
    @JsonKey(name: 'user_id') required String userId,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

#### Immutable Collections
By default, Freezed makes collections immutable. To allow mutation:

```dart
@unfreezed
sealed class TodoList with _$TodoList {
  factory TodoList(List<Todo> items) = _TodoList;
  factory TodoList.fromJson(Map<String, dynamic> json) => _$TodoListFromJson(json);
}
```

#### Union Types (Sealed Classes)
```dart
@freezed
sealed class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.loading() = Loading<T>;
  const factory ApiResult.error(String message) = ErrorDetails<T>;
}
```

As of Dart 3, Dart now has built-in pattern-matching using sealed classes. As such, you no longer need to rely on Freezed's generated methods for pattern matching. Instead of using when/map, use the official Dart syntax.

#### JSON Serialization
```dart
// For nested JSON
@freezed
abstract class User with _$User {
  factory User({
    required String id,
    required String email,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// For custom JSON conversion
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();
  
  @override
  DateTime fromJson(String json) => DateTime.parse(json);
  
  @override
  String toJson(DateTime object) => object.toIso8601String();
}
```

#### Copy With
```dart
final todo = Todo(id: '1', title: 'Learn Freezed', isCompleted: false, createdAt: DateTime.now());
final updated = todo.copyWith(isCompleted: true);

// Deep copy with nested objects
final user = User(id: '1', email: 'test@example.com', createdAt: DateTime.now());
final updatedUser = user.copyWith.email('new@example.com');
```

#### Equality and Validation
```dart
@freezed
abstract class Todo with _$Todo {
  const Todo._(); // Private constructor for methods
  
  const factory Todo({
    required String id,
    @_ValidateTitle() required String title,
    @Default(false) bool isCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Todo;
  
  // Custom validation
  bool get isValid => title.length >= 3;
}

// Custom validator
class _ValidateTitle extends Validator<String> {
  const _ValidateTitle();
  
  @override
  String validate(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    return value;
  }
}
```

#### Best Practices
1. **Use `@freezed` for immutable models**
2. **Keep models pure** - avoid business logic in models
3. **Use `sealed` for state management** - great for API responses
4. **Implement `fromJson`/`toJson`** - for serialization
5. **Use `@Default` for default values**
6. **Leverage `copyWith`** - for immutable updates
7. **Add validation** - in the private constructor
8. **Document complex fields** - with `///` comments
9. **Use `@JsonKey`** - for custom JSON field names
10. **Generate code** after changes:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

#### Benefits
- **Type Safety**: Compile-time checks for pattern matching
- **Immutability**: All generated classes are immutable
- **Boilerplate Reduction**: No need to manually implement `==`, `hashCode`, `toString()`
- **JSON Serialization**: Built-in support for JSON serialization
- **Pattern Matching**: Powerful pattern matching with `when`, `maybeWhen`, `map`, etc.
- **Union Types**: Represent multiple states in a type-safe way
- **Copy with**: Easy immutable updates with `copyWith`
- **Sealed Exhaustiveness**: Ensures all cases are handled in switches

### Supabase Integration

#### Basic Setup
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(MyApp());
}
```

### Riverpod 3.0 Best Practices

#### Provider Types
- Use `NotifierProvider` for most state management needs (replaces `StateNotifierProvider`)
- Use `FutureProvider` for async data fetching
- Use `StreamProvider` for reactive data streams
- Use `StateProvider` only for very simple state (consider `NotifierProvider` for more complex cases)
- Prefer the new `@riverpod` annotation for better type safety and less boilerplate

#### Provider Naming
- Name providers with a `Provider` suffix (e.g., `todosProvider`)
- For `@riverpod` annotated classes, the provider will be auto-named by converting the class name to camelCase
- Keep providers close to where they're used

### State Management Patterns

#### Using `@riverpod` Annotation
```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  FutureOr<List<Todo>> build() async {
    // Initial state loading
    return [];
  }
  
  Future<void> addTodo(Todo todo) async {
    // Update state
    state = await AsyncValue.guard(() async {
      final items = [...?state.value];
      items.add(todo);
      return items;
    });
  }
}
```

#### State Updates
- Keep UI and business logic separate
- Use immutable state objects
- For complex state, use `AsyncValue` for proper loading/error states
- Use `ref.invalidate` to refresh providers when needed
- Implement `updateShouldNotify` for custom update logic

#### Auto-Dispose and Family
- Use `@Riverpod(keepAlive: true)` to prevent auto-disposal
- Use family parameters for parameterized providers
- For complex dependencies, use `ref.watch` inside providers

#### Error Handling
- Use `AsyncValue` for proper error handling
- Implement custom retry logic using the `retry` parameter
- Handle loading/error states in the UI with `when` or `whenOrNull`

## Supabase Integration

### Database Best Practices

#### Table Design
- Use snake_case for table and column names
- Enable Row Level Security (RLS) for all tables
- Create appropriate indexes for frequently queried columns
- Use migrations for database schema changes
- Set up foreign key constraints
- Add comments to document tables and columns

#### RLS Policies
```sql
-- Example RLS Policy
create policy "Users can view their own todos"
on todos for select
using (auth.uid() = user_id);

create policy "Users can insert their own todos"
on todos for insert
with check (auth.uid() = user_id);
```

### Client-Side Usage

#### Querying Data
```dart
// Basic query
final data = await supabase
    .from('todos')
    .select()
    .eq('is_completed', false);

// With realtime
final subscription = supabase
    .from('todos')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .listen((data) {
      // Handle realtime updates
    });
```

#### Authentication
```dart
// Email/password sign up
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password',
);

// Email/password sign in
final response = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password',
);

// Session management
final session = supabase.auth.currentSession;
final user = session?.user;
```

### Combined Example with Hooks and Riverpod

#### Provider Setup
```dart
final todosProvider = StreamProvider.autoDispose<List<Todo>>((ref) async* {
  final userId = ref.watch(authProvider).value?.id;
  if (userId == null) return [];
  
  final supabase = Supabase.instance.client;
  yield* supabase
      .from('todos')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at')
      .map((data) => data.map((json) => Todo.fromJson(json)).toList());
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final supabase = Supabase.instance.client;
  return TodoRepository(supabase);
});
```

#### Hook Widget Usage
```dart
class TodoList extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);
    final controller = useTextEditingController();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (todos) => ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) => TodoItem(todo: todos[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTodo(context, ref, controller),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Future<void> _addTodo(
    BuildContext context, 
    WidgetRef ref,
    TextEditingController controller,
  ) async {
    final title = controller.text.trim();
    if (title.isEmpty) return;
    
    try {
      await ref.read(todoRepositoryProvider).addTodo(
        title: title,
        isCompleted: false,
      );
      controller.clear();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add todo: $e')),
        );
      }
    }
  }
}
```

### Authentication
- Store tokens securely using Flutter Secure Storage
- Implement proper error handling for auth flows
- Use Supabase's built-in auth UI components when possible

### Real-time Subscriptions
- Unsubscribe from streams when not in use
- Handle connection state changes gracefully
- Debounce rapid updates when necessary

## Error Handling

### Data Layer
- Create custom error classes for different error types
- Handle network errors gracefully
- Implement retry logic for transient failures

### UI Layer
- Show user-friendly error messages
- Provide recovery options when possible
- Log errors for debugging

## Testing

### Unit Tests
- Test business logic in isolation
- Mock external dependencies
- Aim for high test coverage of core functionality

### Widget Tests
- Test UI components in isolation
- Use `testWidgets` for widget tests
- Mock providers when needed

### Integration Tests
- Test complete user flows
- Use mock data for external services
- Run on both emulator and real devices

## Version Control

### Branching Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `release/*` - Release preparation

### Commit Messages
Follow the Conventional Commits specification:
- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code changes that neither fix bugs nor add features
- `test:` Adding tests
- `chore:` Changes to build process or auxiliary tools

## Documentation

### Code Documentation
- Document public APIs using `///`
- Explain complex logic with inline comments
- Keep comments up-to-date with code changes

### API Documentation
- Document API endpoints and data structures
- Include example requests and responses
- Document authentication requirements

### Project Documentation
- Keep README.md up-to-date
- Document setup and deployment procedures
- Include troubleshooting guides

## Development Workflow

1. Create a new feature branch from `develop`
2. Implement changes following these guidelines
3. Write tests for new functionality
4. Run all tests locally
5. Create a pull request to `develop`
6. Address code review feedback
7. Squash and merge when approved

## Dependencies

### Adding New Dependencies
1. Check if the package is actively maintained
2. Review the package's test coverage
3. Check for any open security issues
4. Add to appropriate section in `pubspec.yaml`
5. Document the reason for adding the dependency

### Updating Dependencies
- Update dependencies regularly
- Test thoroughly after updates
- Document any breaking changes
