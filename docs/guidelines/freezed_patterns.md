# Freezed Patterns and Best Practices

This guide covers modern Freezed patterns with Dart 3+ features, focusing on pattern matching, sealed classes, and integration with the latest Flutter ecosystem.

## Table of Contents

- [Overview](#overview)
- [Setup and Dependencies](#setup-and-dependencies)
- [Basic Freezed Patterns](#basic-freezed-patterns)
- [Dart 3+ Pattern Matching](#dart-3-pattern-matching)
- [Sealed Classes and Union Types](#sealed-classes-and-union-types)
- [JSON Serialization](#json-serialization)
- [CopyWith and Immutable Data](#copywith-and-immutable-data)
- [Code Generation Workflow](#code-generation-workflow)
- [Testing Patterns](#testing-patterns)
- [Performance Considerations](#performance-considerations)
- [Riverpod 3.0 Integration](#riverpod-30-integration)
- [Error Handling with Union Types](#error-handling-with-union-types)
- [Best Practices and Organization](#best-practices-and-organization)

## Overview

Freezed 3.1.0+ provides powerful code generation for immutable classes with native Dart 3 pattern matching support. This eliminates the need for legacy `when`/`map` methods in favor of modern switch expressions and pattern matching.

### Key Benefits

- **Type Safety**: Compile-time guarantees for exhaustive pattern matching
- **Performance**: Zero-cost abstractions with efficient code generation
- **Developer Experience**: Reduced boilerplate with powerful IDE support
- **Modern Syntax**: Native Dart 3 patterns instead of generated methods

## Setup and Dependencies

Ensure your `pubspec.yaml` includes the latest versions:

```yaml
dependencies:
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.5.4
  freezed: ^3.1.0
  json_serializable: ^6.9.5
  freezed_lint: ^0.0.10
```

### Build Configuration

Create or update `build.yaml` for optimized generation:

```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          # Enable Dart 3 pattern matching
          pattern_matching: true
          # Disable legacy when/map methods
          legacy_methods: false
          # Enable sealed class generation
          sealed_classes: true
```

## Basic Freezed Patterns

### Simple Data Class

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    DateTime? lastLogin,
    @Default(false) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Using the Model

```dart
// Creating instances
const user = User(
  id: '123',
  name: 'John Doe',
  email: 'john@example.com',
);

// Copying with changes
final updatedUser = user.copyWith(
  lastLogin: DateTime.now(),
  isActive: true,
);

// JSON serialization
final json = user.toJson();
final fromJson = User.fromJson(json);
```

## Dart 3+ Pattern Matching

### Modern Switch Expressions

Replace legacy `when`/`map` methods with native Dart 3 patterns:

```dart
@freezed
sealed class LoadingState<T> with _$LoadingState<T> {
  const factory LoadingState.initial() = Initial<T>;
  const factory LoadingState.loading() = Loading<T>;
  const factory LoadingState.success(T data) = Success<T>;
  const factory LoadingState.error(String message, [StackTrace? stackTrace]) = Error<T>;
}

// Modern pattern matching
String getStateMessage<T>(LoadingState<T> state) {
  return switch (state) {
    Initial() => 'Ready to start',
    Loading() => 'Loading...',
    Success(data: final data) => 'Loaded: $data',
    Error(message: final msg) => 'Error: $msg',
  };
}

// Pattern matching in widgets
Widget buildStateWidget<T>(LoadingState<T> state) {
  return switch (state) {
    Initial() => const Text('Tap to start'),
    Loading() => const CircularProgressIndicator(),
    Success(data: final data) => Text('Data: $data'),
    Error(message: final error) => Text('Error: $error', 
      style: const TextStyle(color: Colors.red)),
  };
}
```

### Destructuring Patterns

```dart
@freezed
class Point with _$Point {
  const factory Point(double x, double y) = _Point;
}

@freezed
class Rectangle with _$Rectangle {
  const factory Rectangle(Point topLeft, Point bottomRight) = _Rectangle;
}

// Destructuring in pattern matching
double calculateArea(Rectangle rect) {
  return switch (rect) {
    Rectangle(
      topLeft: Point(x: final x1, y: final y1),
      bottomRight: Point(x: final x2, y: final y2)
    ) => (x2 - x1).abs() * (y2 - y1).abs(),
  };
}
```

## Sealed Classes and Union Types

### Exhaustive Pattern Matching

```dart
@freezed
sealed class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.loading() = ApiLoading<T>;
  const factory ApiResult.error(String message, int? statusCode) = ApiError<T>;
  const factory ApiResult.networkError(String message) = ApiNetworkError<T>;
}

// Compiler enforces exhaustive matching
Widget buildResult<T>(ApiResult<T> result) {
  return switch (result) {
    ApiSuccess(data: final data) => SuccessWidget(data),
    ApiLoading() => const LoadingWidget(),
    ApiError(message: final msg, statusCode: final code) => 
      ErrorWidget(msg, code),
    ApiNetworkError(message: final msg) => NetworkErrorWidget(msg),
    // Compiler error if any case is missing
  };
}
```

### Complex Union Types

```dart
@freezed
sealed class TodoFilter with _$TodoFilter {
  const factory TodoFilter.all() = AllTodos;
  const factory TodoFilter.completed() = CompletedTodos;
  const factory TodoFilter.pending() = PendingTodos;
  const factory TodoFilter.byTag(String tag) = TodosByTag;
  const factory TodoFilter.byDateRange(DateTime start, DateTime end) = TodosByDateRange;
}

// Pattern matching with guards
List<Todo> filterTodos(List<Todo> todos, TodoFilter filter) {
  return switch (filter) {
    AllTodos() => todos,
    CompletedTodos() => todos.where((t) => t.isCompleted).toList(),
    PendingTodos() => todos.where((t) => !t.isCompleted).toList(),
    TodosByTag(tag: final tag) => todos.where((t) => t.tags.contains(tag)).toList(),
    TodosByDateRange(start: final start, end: final end) => 
      todos.where((t) => t.createdAt.isAfter(start) && t.createdAt.isBefore(end)).toList(),
  };
}
```

## JSON Serialization

### Advanced JSON Patterns

```dart
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    required String description,
    @Default(false) bool isCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @Default([]) List<String> tags,
    @JsonKey(includeIfNull: false) String? assigneeId,
    @JsonKey(fromJson: _priorityFromJson, toJson: _priorityToJson) 
    @Default(Priority.medium) Priority priority,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

enum Priority { low, medium, high, urgent }

Priority _priorityFromJson(String value) => Priority.values.byName(value);
String _priorityToJson(Priority priority) => priority.name;
```

### Nested Object Serialization

```dart
@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    required String description,
    required User owner,
    @Default([]) List<User> members,
    @Default([]) List<Todo> todos,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}

// Usage with nested serialization
final project = Project.fromJson({
  'id': '1',
  'name': 'Flutter App',
  'description': 'A todo app',
  'owner': {'id': '1', 'name': 'John', 'email': 'john@example.com'},
  'members': [
    {'id': '2', 'name': 'Jane', 'email': 'jane@example.com'},
  ],
  'todos': [
    {'id': '1', 'title': 'Setup project', 'description': 'Initial setup'},
  ],
  'created_at': '2025-01-01T00:00:00Z',
});
```

## CopyWith and Immutable Data

### Advanced CopyWith Patterns

```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(Locale('en')) Locale locale,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool analyticsEnabled,
    @Default(Duration(minutes: 30)) Duration reminderInterval,
    Map<String, dynamic>? customSettings,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => 
    _$AppSettingsFromJson(json);
}

// Nested updates with copyWith
AppSettings updateNotificationSettings(
  AppSettings settings, {
  bool? enabled,
  Duration? interval,
}) {
  return settings.copyWith(
    notificationsEnabled: enabled ?? settings.notificationsEnabled,
    reminderInterval: interval ?? settings.reminderInterval,
  );
}

// Conditional updates
AppSettings toggleTheme(AppSettings settings) {
  return settings.copyWith(
    themeMode: switch (settings.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    },
  );
}
```

### Immutable Collections

```dart
@freezed
class TodoList with _$TodoList {
  const factory TodoList({
    required String id,
    required String name,
    @Default([]) List<Todo> todos,
    @Default({}) Map<String, String> metadata,
  }) = _TodoList;

  factory TodoList.fromJson(Map<String, dynamic> json) => 
    _$TodoListFromJson(json);
}

// Safe immutable operations
extension TodoListOperations on TodoList {
  TodoList addTodo(Todo todo) {
    return copyWith(todos: [...todos, todo]);
  }

  TodoList removeTodo(String todoId) {
    return copyWith(
      todos: todos.where((t) => t.id != todoId).toList(),
    );
  }

  TodoList updateTodo(String todoId, Todo Function(Todo) updater) {
    return copyWith(
      todos: todos.map((t) => t.id == todoId ? updater(t) : t).toList(),
    );
  }

  TodoList addMetadata(String key, String value) {
    return copyWith(metadata: {...metadata, key: value});
  }
}
```

## Code Generation Workflow

### Build Runner Commands

```bash
# Generate code once
dart run build_runner build

# Watch for changes and regenerate
dart run build_runner watch

# Clean generated files
dart run build_runner clean

# Build with specific options
dart run build_runner build --delete-conflicting-outputs
```

### Automated Generation Script

Create `scripts/generate.dart`:

```dart
import 'dart:io';

Future<void> main() async {
  print('🔄 Cleaning previous builds...');
  await Process.run('dart', ['run', 'build_runner', 'clean']);
  
  print('🏗️ Generating code...');
  final result = await Process.run('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  
  if (result.exitCode == 0) {
    print('✅ Code generation completed successfully!');
  } else {
    print('❌ Code generation failed:');
    print(result.stderr);
    exit(1);
  }
}
```

### VS Code Tasks

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate Freezed Code",
      "type": "shell",
      "command": "dart",
      "args": ["run", "build_runner", "build", "--delete-conflicting-outputs"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Watch Freezed Code",
      "type": "shell",
      "command": "dart",
      "args": ["run", "build_runner", "watch"],
      "group": "build",
      "isBackground": true,
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

## Testing Patterns

### Unit Testing Freezed Models

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo.dart';

void main() {
  group('Todo Model Tests', () {
    test('should create todo with required fields', () {
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        createdAt: DateTime.now(),
      );

      expect(todo.id, '1');
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false); // Default value
      expect(todo.tags, isEmpty); // Default empty list
    });

    test('should support copyWith operations', () {
      final original = Todo(
        id: '1',
        title: 'Original',
        description: 'Description',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
      );

      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.id, original.id); // Unchanged
      expect(updated.description, original.description); // Unchanged
    });

    test('should serialize to and from JSON', () {
      final todo = Todo(
        id: '1',
        title: 'Test',
        description: 'Description',
        createdAt: DateTime.parse('2025-01-01T00:00:00Z'),
        tags: ['work', 'urgent'],
      );

      final json = todo.toJson();
      final fromJson = Todo.fromJson(json);

      expect(fromJson, equals(todo));
      expect(fromJson.tags, containsAll(['work', 'urgent']));
    });
  });

  group('LoadingState Pattern Matching', () {
    test('should handle all states with pattern matching', () {
      const states = [
        LoadingState<String>.initial(),
        LoadingState<String>.loading(),
        LoadingState<String>.success('data'),
        LoadingState<String>.error('error message'),
      ];

      for (final state in states) {
        final message = switch (state) {
          Initial() => 'initial',
          Loading() => 'loading',
          Success(data: final data) => 'success: $data',
          Error(message: final msg) => 'error: $msg',
        };

        expect(message, isNotEmpty);
      }
    });
  });
}
```

### Golden Tests for Freezed Models

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('Todo JSON Golden Tests', () {
    testGoldens('should match golden JSON output', (tester) async {
      final todo = Todo(
        id: '123',
        title: 'Sample Todo',
        description: 'This is a sample todo item',
        createdAt: DateTime.parse('2025-01-01T12:00:00Z'),
        tags: ['work', 'important'],
        priority: Priority.high,
      );

      final json = todo.toJson();
      
      // Compare with golden file
      await expectLater(
        json,
        matchesGoldenFile('goldens/todo_json.json'),
      );
    });
  });
}
```

### Mock Data Generation

```dart
import 'package:mocktail/mocktail.dart';

class MockTodo {
  static Todo create({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    List<String>? tags,
    Priority? priority,
  }) {
    return Todo(
      id: id ?? 'mock-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Mock Todo',
      description: description ?? 'Mock Description',
      isCompleted: isCompleted ?? false,
      createdAt: createdAt ?? DateTime.now(),
      tags: tags ?? ['test'],
      priority: priority ?? Priority.medium,
    );
  }

  static List<Todo> createList(int count) {
    return List.generate(count, (index) => create(
      id: 'mock-$index',
      title: 'Todo $index',
      isCompleted: index % 2 == 0,
    ));
  }
}
```

## Performance Considerations

### Memory Optimization

```dart
// Use const constructors when possible
@freezed
class ImmutableConfig with _$ImmutableConfig {
  const factory ImmutableConfig({
    required String apiUrl,
    required int timeout,
    @Default(false) bool debugMode,
  }) = _ImmutableConfig;
}

// Const instance for reuse
const defaultConfig = ImmutableConfig(
  apiUrl: 'https://api.example.com',
  timeout: 30000,
);
```

### Efficient Collections

```dart
@freezed
class OptimizedTodoList with _$OptimizedTodoList {
  const factory OptimizedTodoList({
    required String id,
    required String name,
    // Use Set for unique items
    @Default(<String>{}) Set<String> tags,
    // Use Map for O(1) lookups
    @Default(<String, Todo>{}) Map<String, Todo> todosById,
  }) = _OptimizedTodoList;

  factory OptimizedTodoList.fromJson(Map<String, dynamic> json) => 
    _$OptimizedTodoListFromJson(json);
}

extension OptimizedTodoListOperations on OptimizedTodoList {
  // O(1) todo lookup
  Todo? getTodo(String id) => todosById[id];
  
  // Efficient operations
  OptimizedTodoList addTodo(Todo todo) {
    return copyWith(
      todosById: {...todosById, todo.id: todo},
      tags: {...tags, ...todo.tags},
    );
  }
  
  List<Todo> get todos => todosById.values.toList();
  List<Todo> get completedTodos => 
    todosById.values.where((t) => t.isCompleted).toList();
}
```

### Lazy Evaluation

```dart
@freezed
class LazyComputedData with _$LazyComputedData {
  const factory LazyComputedData({
    required List<int> numbers,
  }) = _LazyComputedData;
}

extension LazyComputedDataOperations on LazyComputedData {
  // Lazy computed properties
  int get sum => numbers.fold(0, (a, b) => a + b);
  double get average => numbers.isEmpty ? 0 : sum / numbers.length;
  int get max => numbers.isEmpty ? 0 : numbers.reduce(math.max);
  int get min => numbers.isEmpty ? 0 : numbers.reduce(math.min);
}
```

## Riverpod 3.0 Integration

### State Management with Freezed

```dart
@riverpod
class TodoNotifier extends _$TodoNotifier {
  @override
  LoadingState<List<Todo>> build() {
    return const LoadingState.initial();
  }

  Future<void> loadTodos() async {
    state = const LoadingState.loading();
    
    try {
      final todos = await ref.read(todoRepositoryProvider).getAllTodos();
      state = LoadingState.success(todos);
    } catch (error, stackTrace) {
      state = LoadingState.error(error.toString(), stackTrace);
    }
  }

  Future<void> addTodo(Todo todo) async {
    final currentState = state;
    if (currentState is! Success<List<Todo>>) return;

    try {
      await ref.read(todoRepositoryProvider).createTodo(todo);
      state = LoadingState.success([...currentState.data, todo]);
    } catch (error) {
      state = LoadingState.error(error.toString());
    }
  }

  void updateTodo(String id, Todo Function(Todo) updater) {
    final currentState = state;
    if (currentState is! Success<List<Todo>>) return;

    final updatedTodos = currentState.data.map((todo) {
      return todo.id == id ? updater(todo) : todo;
    }).toList();

    state = LoadingState.success(updatedTodos);
  }
}
```

### Provider Families with Freezed

```dart
@riverpod
LoadingState<Todo?> todo(TodoRef ref, String todoId) {
  final todosState = ref.watch(todoNotifierProvider);
  
  return switch (todosState) {
    Initial() => const LoadingState.initial(),
    Loading() => const LoadingState.loading(),
    Success(data: final todos) => LoadingState.success(
      todos.firstWhere((t) => t.id == todoId, orElse: () => null),
    ),
    Error(message: final msg) => LoadingState.error(msg),
  };
}

@riverpod
List<Todo> filteredTodos(FilteredTodosRef ref, TodoFilter filter) {
  final todosState = ref.watch(todoNotifierProvider);
  
  return switch (todosState) {
    Success(data: final todos) => filterTodos(todos, filter),
    _ => [],
  };
}
```

### Async Data with Freezed

```dart
@riverpod
Future<LoadingState<Project>> project(ProjectRef ref, String projectId) async {
  try {
    final project = await ref.read(projectRepositoryProvider)
        .getProject(projectId);
    return LoadingState.success(project);
  } catch (error) {
    return LoadingState.error(error.toString());
  }
}

// Usage in widgets
class ProjectView extends ConsumerWidget {
  const ProjectView({required this.projectId, super.key});
  
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectProvider(projectId));
    
    return projectAsync.when(
      data: (state) => switch (state) {
        Success(data: final project) => ProjectContent(project: project),
        Loading() => const CircularProgressIndicator(),
        Error(message: final error) => ErrorWidget(error),
        Initial() => const SizedBox.shrink(),
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => ErrorWidget(error.toString()),
    );
  }
}
```

## Error Handling with Union Types

### Result Pattern

```dart
@freezed
sealed class Result<T, E> with _$Result<T, E> {
  const factory Result.success(T value) = Success<T, E>;
  const factory Result.failure(E error) = Failure<T, E>;
}

// Extension methods for Result
extension ResultExtensions<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
  
  T? get valueOrNull => switch (this) {
    Success(value: final value) => value,
    Failure() => null,
  };
  
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };
  
  Result<U, E> map<U>(U Function(T) mapper) => switch (this) {
    Success(value: final value) => Result.success(mapper(value)),
    Failure(error: final error) => Result.failure(error),
  };
  
  Result<T, F> mapError<F>(F Function(E) mapper) => switch (this) {
    Success(value: final value) => Result.success(value),
    Failure(error: final error) => Result.failure(mapper(error)),
  };
}
```

### Application Error Types

```dart
@freezed
sealed class AppError with _$AppError {
  const factory AppError.network(String message, int? statusCode) = NetworkError;
  const factory AppError.validation(String field, String message) = ValidationError;
  const factory AppError.authentication(String message) = AuthenticationError;
  const factory AppError.permission(String resource) = PermissionError;
  const factory AppError.notFound(String resource, String id) = NotFoundError;
  const factory AppError.unknown(String message, [Object? cause]) = UnknownError;
}

// Error handling in services
class TodoService {
  Future<Result<List<Todo>, AppError>> getTodos() async {
    try {
      final response = await httpClient.get('/todos');
      
      return switch (response.statusCode) {
        200 => Result.success(
          (response.data as List)
              .map((json) => Todo.fromJson(json))
              .toList(),
        ),
        401 => const Result.failure(
          AppError.authentication('Invalid credentials'),
        ),
        403 => const Result.failure(
          AppError.permission('todos'),
        ),
        404 => const Result.failure(
          AppError.notFound('todos', 'all'),
        ),
        _ => Result.failure(
          AppError.network('HTTP ${response.statusCode}', response.statusCode),
        ),
      };
    } catch (error) {
      return Result.failure(AppError.unknown(error.toString(), error));
    }
  }
}
```

### Error Recovery Patterns

```dart
extension ErrorRecovery<T> on Result<T, AppError> {
  Result<T, AppError> recover(T Function(AppError) recovery) => switch (this) {
    Success() => this,
    Failure(error: final error) => Result.success(recovery(error)),
  };
  
  Result<T, AppError> recoverWith(
    Result<T, AppError> Function(AppError) recovery,
  ) => switch (this) {
    Success() => this,
    Failure(error: final error) => recovery(error),
  };
  
  Future<Result<T, AppError>> retryOnError({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    required Future<Result<T, AppError>> Function() operation,
  }) async {
    if (isSuccess) return this;
    
    for (int i = 0; i < maxRetries; i++) {
      await Future.delayed(delay);
      final result = await operation();
      if (result.isSuccess) return result;
    }
    
    return this;
  }
}
```

## Best Practices and Organization

### File Structure

```
lib/
├── models/
│   ├── core/
│   │   ├── result.dart
│   │   ├── loading_state.dart
│   │   └── app_error.dart
│   ├── todo/
│   │   ├── todo.dart
│   │   ├── todo_filter.dart
│   │   └── todo_list.dart
│   ├── user/
│   │   ├── user.dart
│   │   └── user_preferences.dart
│   └── project/
│       ├── project.dart
│       └── project_settings.dart
├── providers/
│   ├── todo_provider.dart
│   ├── user_provider.dart
│   └── project_provider.dart
└── services/
    ├── todo_service.dart
    ├── user_service.dart
    └── project_service.dart
```

### Naming Conventions

```dart
// Model classes: PascalCase
class TodoItem with _$TodoItem { }
class UserProfile with _$UserProfile { }

// Union types: descriptive names
sealed class LoadingState<T> { }
sealed class ApiResult<T> { }
sealed class ValidationResult { }

// Factory constructors: camelCase
const factory TodoItem.create() = _Create;
const factory TodoItem.update() = _Update;
const factory TodoItem.delete() = _Delete;

// JSON keys: snake_case (matching API)
@JsonKey(name: 'created_at') DateTime createdAt;
@JsonKey(name: 'updated_at') DateTime? updatedAt;
```

### Code Organization Patterns

```dart
// Group related models in the same file
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    // ... other fields
  }) = _Todo;
  
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

@freezed
class TodoList with _$TodoList {
  const factory TodoList({
    required String id,
    required List<Todo> todos,
  }) = _TodoList;
  
  factory TodoList.fromJson(Map<String, dynamic> json) => _$TodoListFromJson(json);
}

// Extensions in the same file
extension TodoOperations on Todo {
  bool get isOverdue => dueDate?.isBefore(DateTime.now()) ?? false;
  bool get isUrgent => priority == Priority.urgent;
}

extension TodoListOperations on TodoList {
  List<Todo> get completedTodos => todos.where((t) => t.isCompleted).toList();
  List<Todo> get pendingTodos => todos.where((t) => !t.isCompleted).toList();
  int get completionPercentage => 
    todos.isEmpty ? 0 : (completedTodos.length / todos.length * 100).round();
}
```

### Documentation Standards

```dart
/// Represents a todo item in the application.
/// 
/// This model uses Freezed for immutability and code generation.
/// It supports JSON serialization for API communication and
/// local storage persistence.
/// 
/// Example:
/// ```dart
/// final todo = Todo(
///   id: '123',
///   title: 'Complete project',
///   description: 'Finish the Flutter todo app',
///   createdAt: DateTime.now(),
/// );
/// 
/// // Update the todo
/// final completed = todo.copyWith(isCompleted: true);
/// 
/// // Serialize to JSON
/// final json = todo.toJson();
/// ```
@freezed
class Todo with _$Todo {
  /// Creates a new todo item.
  /// 
  /// [id] must be unique across all todos.
  /// [title] and [description] cannot be empty.
  /// [createdAt] defaults to the current time if not provided.
  const factory Todo({
    required String id,
    required String title,
    required String description,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    @Default([]) List<String> tags,
    @Default(Priority.medium) Priority priority,
  }) = _Todo;

  /// Creates a Todo instance from JSON data.
  /// 
  /// Typically used when deserializing data from APIs or local storage.
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

### Migration Guidelines

When upgrading from legacy Freezed patterns:

1. **Replace when/map methods**:
   ```dart
   // Old way
   final result = state.when(
     initial: () => 'Not started',
     loading: () => 'Loading...',
     success: (data) => 'Success: $data',
     error: (error) => 'Error: $error',
   );
   
   // New way
   final result = switch (state) {
     Initial() => 'Not started',
     Loading() => 'Loading...',
     Success(data: final data) => 'Success: $data',
     Error(message: final error) => 'Error: $error',
   };
   ```

2. **Update build configuration**:
   ```yaml
   # Add to build.yaml
   targets:
     $default:
       builders:
         freezed:
           options:
             pattern_matching: true
             legacy_methods: false
   ```

3. **Enable sealed classes**:
   ```dart
   // Add sealed keyword
   @freezed
   sealed class MyUnion with _$MyUnion {
     // ...
   }
   ```

This comprehensive guide covers all aspects of modern Freezed usage with Dart 3+ patterns, providing a solid foundation for building maintainable and type-safe Flutter applications.