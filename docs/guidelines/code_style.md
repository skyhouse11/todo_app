# Code Style Guidelines

This document outlines modern code style guidelines for Dart 3+ and Flutter 3.24+, incorporating the latest language features and best practices.

## Naming Conventions

### Files
- Use `snake_case` for file names
- Match file name to the primary class name (e.g., `todo_list_screen.dart` for `TodoListScreen` class)
- Suffix file names with their type:
  - `_screen.dart` for full screens
  - `_widget.dart` for reusable widgets
  - `_provider.dart` for Riverpod providers
  - `_model.dart` for data models
  - `_service.dart` for service classes
  - `_repository.dart` for repository implementations
  - `_controller.dart` for controllers
  - `_extension.dart` for extension methods
  - `.g.dart` for generated files (build_runner)
  - `.freezed.dart` for Freezed generated files

### Classes
- Use `PascalCase` for class names
- Use descriptive nouns or noun phrases
- Suffix with type when needed (e.g., `TodoRepositoryImpl`)

```dart
// Good
class TodoListScreen extends StatelessWidget {}
class UserRepositoryImpl implements UserRepository {}

// Bad
class todoListScreen extends statelessWidget {}
class UserRepoImpl implements UserRepository {}
```

### Variables and Functions
- Use `camelCase` for variables, functions, and parameters
- Use descriptive names that indicate purpose
- Prefix boolean variables with auxiliary verbs (e.g., `isLoading`, `hasError`)
- Use positive boolean names (e.g., `isEnabled` instead of `isNotDisabled`)

```dart
// Good
final int itemCount = 10;
Future<void> fetchUserData() async {}
bool isUserLoggedIn = false;

// Bad
final int ItemCount = 10;
Future<void> GetUserData() async {}
bool userLoggedIn = false;
```

### Constants
- Use `lowerCamelCase` for private constants
- Use `UPPER_SNAKE_CASE` for public constants
- Group related constants in a class with a descriptive name

```dart
// Good
const maxRetryAttempts = 3;
const String kApiBaseUrl = 'https://api.example.com';

class AppConstants {
  static const double defaultPadding = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

// Bad
const String api_base_url = 'https://api.example.com';
const double DefaultPadding = 16.0;
```

## Formatting

### Indentation and Line Length
- Use 2 spaces for indentation (not tabs)
- Maximum line length: 80 characters
- Break long lines at appropriate points

### Spacing
- Add a single space after flow control keywords
- Add a single space around operators
- Add a single space after `,`, `:`, and `;`
- No space after `(` or before `)`

```dart
// Good
if (condition) {
  doSomething();
}

final result = a + b * c;
final list = [1, 2, 3];

// Bad
if(condition){
  doSomething();
}

final result=a+b*c;
final list = [1,2,3];
```

### Braces
- Always use curly braces for control flow statements, even for single-line bodies
- Place opening brace on the same line as the control flow statement
- Place closing brace on a new line

```dart
// Good
if (condition) {
  doSomething();
}

// Bad
if (condition) doSomething();

if (condition) 
{
  doSomething();
}
```

### Trailing Commas
- Always add trailing commas for better git diffs and formatting
- Makes diffs cleaner when adding new items
- Makes reformatting code easier

```dart
// Good
final list = [
  'item1',
  'item2',
  'item3',
];

// Bad
final list = [
  'item1',
  'item2',
  'item3'
];
```

## Documentation

### Comments
- Use `//` for single-line comments
- Use `///` for documentation comments
- Write comments that explain why, not what
- Keep comments up to date with code changes

### Documentation Comments
- Use `///` for public APIs
- Include parameter and return value documentation
- Use markdown for formatting
- Include examples for complex functions

```dart
/// Fetches a list of todos for the current user.
///
/// Throws a [NetworkException] if the request fails.
/// Returns a [List] of [Todo] objects.
///
/// Example:
/// ```dart
/// final todos = await fetchTodos();
/// ```
Future<List<Todo>> fetchTodos() async {
  // Implementation
}
```

## Dart 3+ Modern Features

### Records
- Use records for simple data grouping without creating classes
- Prefer named fields for better readability
- Use records for multiple return values

```dart
// Good
({String name, int age}) getUserInfo() {
  return (name: 'John', age: 30);
}

final userInfo = getUserInfo();
print('Name: ${userInfo.name}, Age: ${userInfo.age}');

// Multiple return values
(bool success, String? error) validateInput(String input) {
  if (input.isEmpty) {
    return (false, 'Input cannot be empty');
  }
  return (true, null);
}

// Bad - creating a class for simple data
class UserInfo {
  UserInfo(this.name, this.age);
  final String name;
  final int age;
}
```

### Pattern Matching
- Use pattern matching with switch expressions for cleaner code
- Leverage exhaustive checking with sealed classes
- Use destructuring for records and objects

```dart
// Good - Switch expressions
String getStatusMessage(Status status) => switch (status) {
  Status.loading => 'Loading...',
  Status.success => 'Success!',
  Status.error => 'Error occurred',
};

// Pattern matching with records
String formatResult((bool success, String message) result) => switch (result) {
  (true, final message) => 'Success: $message',
  (false, final message) => 'Error: $message',
};

// Destructuring in assignments
final (name, age) = getUserInfo();
final [first, ...rest] = items;

// Bad - Traditional switch statements
String getStatusMessage(Status status) {
  switch (status) {
    case Status.loading:
      return 'Loading...';
    case Status.success:
      return 'Success!';
    case Status.error:
      return 'Error occurred';
  }
}
```

### Sealed Classes
- Use sealed classes for closed type hierarchies
- Combine with pattern matching for exhaustive handling
- Prefer sealed classes over enums for complex state

```dart
// Good
sealed class ApiResult<T> {}

class Success<T> extends ApiResult<T> {
  Success(this.data);
  final T data;
}

class Loading<T> extends ApiResult<T> {}

class Error<T> extends ApiResult<T> {
  Error(this.message);
  final String message;
}

// Usage with exhaustive pattern matching
Widget buildContent(ApiResult<List<Todo>> result) => switch (result) {
  Success(data: final todos) => TodoList(todos: todos),
  Loading() => const CircularProgressIndicator(),
  Error(message: final msg) => ErrorWidget(message: msg),
};

// Bad - Using enums for complex state
enum ApiState { loading, success, error }
```

## Dart-Specific Guidelines

### Null Safety
- Always use null safety
- Use `?` for nullable types
- Use `!` only when you're certain the value won't be null
- Use `late` for non-nullable fields that are initialized after object creation
- Use null-aware operators for safe access

```dart
// Good
String? nullableString;
late String nonNullableString;

// Null-aware operators
final length = text?.length ?? 0;
list?.add(item);
name ??= 'Default';

// Safe cascading
user
  ?..name = 'John'
  ..age = 30;

// Bad
String string; // Non-nullable without initialization
final length = text == null ? 0 : text.length; // Use ?. instead
```

### Type Inference
- Use `var` when the type is obvious from the right-hand side
- Explicitly declare types for public APIs and when it improves readability
- Use `final` for variables that won't be reassigned
- Use `const` for compile-time constants

```dart
// Good
final name = 'John';
final int age = 30;
const defaultPadding = 16.0;

// Bad
var name = 'John';
var age = 30; // Use final instead
```

### Modern Collection Handling
- Use collection literals when possible
- Use spread operators for combining collections
- Use collection if and for to build collections
- Leverage pattern matching for collection operations

```dart
// Good
final list = [1, 2, 3];
final map = {'key': 'value'};
final combinedList = [...list1, ...list2];

// Collection if/for
final filteredList = [
  if (condition) 'value1',
  for (var i in items) i.toString(),
  for (var item in conditionalItems) 
    if (item.isValid) item.name,
];

// Pattern matching with collections
final result = switch (items) {
  [] => 'Empty list',
  [final single] => 'Single item: $single',
  [final first, ...final rest] => 'First: $first, Rest: ${rest.length}',
};

// Destructuring assignments
final [first, second, ...rest] = items;
final {'name': name, 'age': age} = userMap;

// Bad
final list = List<int>.from([1, 2, 3]);
final map = Map<String, String>();
map['key'] = 'value';

// Traditional approach instead of pattern matching
if (items.isEmpty) {
  return 'Empty list';
} else if (items.length == 1) {
  return 'Single item: ${items.first}';
} else {
  return 'First: ${items.first}, Rest: ${items.length - 1}';
}
```

## Flutter 3.24+ Widget Guidelines

### Widget Structure and Composition
- Keep widgets small and focused (single responsibility)
- Extract large build methods into separate widget methods
- Use `const` constructors for stateless widgets
- Use `@immutable` for widget parameters
- Leverage widget composition over inheritance

```dart
// Good - Small, focused widgets
class TodoItem extends StatelessWidget {
  const TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(todo.title),
        subtitle: _buildSubtitle(),
        trailing: _buildActions(),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      todo.description,
      style: TextStyle(
        decoration: todo.isCompleted 
          ? TextDecoration.lineThrough 
          : null,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onToggle,
          icon: Icon(
            todo.isCompleted 
              ? Icons.check_box 
              : Icons.check_box_outline_blank,
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}

// Widget composition example
class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TodoAppBar(),
      body: const TodoList(),
      floatingActionButton: const AddTodoFab(),
    );
  }
}
```

### Material 3 Design System
- Use Material 3 components and theming
- Leverage ColorScheme.fromSeed for consistent colors
- Use Material 3 typography scale
- Implement proper elevation and surfaces

```dart
// Good - Material 3 theming
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    typography: Typography.material2021(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    typography: Typography.material2021(),
  );
}

// Material 3 components
class ModernCard extends StatelessWidget {
  const ModernCard({
    required this.child,
    this.elevation = 1,
    super.key,
  });

  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: child,
    );
  }
}
```

### Performance-Focused Patterns
- Use `const` constructors wherever possible
- Implement `RepaintBoundary` for expensive widgets
- Use `ListView.builder` for large lists
- Leverage `AutomaticKeepAliveClientMixin` when needed

```dart
// Good - Performance optimized
class OptimizedTodoList extends StatelessWidget {
  const OptimizedTodoList({
    required this.todos,
    super.key,
  });

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            key: ValueKey(todos[index].id),
            child: TodoItem(
              todo: todos[index],
              onToggle: () => _toggleTodo(todos[index]),
              onDelete: () => _deleteTodo(todos[index]),
            ),
          );
        },
      ),
    );
  }

  void _toggleTodo(Todo todo) {
    // Implementation
  }

  void _deleteTodo(Todo todo) {
    // Implementation
  }
}

// Const widgets for better performance
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
```

### Widget Parameters
- Use named parameters for optional parameters
- Use `@required` for required parameters (or make them positional)
- Group related parameters together
- Keep the parameter list clean and focused

```dart
// Good
class MyButton extends StatelessWidget {
  const MyButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.color = Colors.blue,
    this.padding = const EdgeInsets.all(8.0),
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final EdgeInsets padding;
  
  // ...
}
```

## Modern Error Handling

### Custom Exceptions with Sealed Classes
- Use sealed classes for type-safe error handling
- Create specific exception types for different error categories
- Include useful context information in error messages
- Use pattern matching for exhaustive error handling

```dart
// Good - Sealed class exceptions
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, this.statusCode);
  final int statusCode;
}

class ValidationException extends AppException {
  const ValidationException(super.message, this.field);
  final String field;
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

// Result type for error handling
sealed class Result<T> {}

class Success<T> extends Result<T> {
  Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  Failure(this.exception);
  final AppException exception;
}

// Usage with pattern matching
Future<void> handleApiCall() async {
  final result = await fetchTodos();
  
  switch (result) {
    case Success(data: final todos):
      // Handle success
      displayTodos(todos);
    case Failure(exception: final NetworkException(message: final msg, statusCode: final code)):
      // Handle network errors
      showError('Network error ($code): $msg');
    case Failure(exception: final AuthenticationException(message: final msg)):
      // Handle auth errors
      redirectToLogin(msg);
    case Failure(exception: final AppException(message: final msg)):
      // Handle other errors
      showError(msg);
  }
}

// Traditional try-catch with specific exceptions
try {
  await performOperation();
} on NetworkException catch (e) {
  log('Network error: ${e.statusCode} - ${e.message}');
  rethrow;
} on ValidationException catch (e) {
  log('Validation error in ${e.field}: ${e.message}');
  showFieldError(e.field, e.message);
} on AppException catch (e) {
  log('App error: ${e.message}');
  showGenericError(e.message);
} catch (e, stackTrace) {
  log('Unexpected error', error: e, stackTrace: stackTrace);
  rethrow;
}
```

### Null Safety
- Use null-aware operators (`?.`, `??`, `??=`)
- Use `late` for non-nullable fields that are initialized later
- Use `required` for non-optional named parameters

```dart
// Good
String? name;
final length = name?.length ?? 0;

class User {
  User({required this.id, this.name});
  
  final String id;
  final String? name;
}
```

## Import Organization and File Structure

### Import Ordering
- Dart SDK imports first
- Flutter framework imports
- Third-party package imports
- Local project imports
- Relative imports last

```dart
// Good
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_app/core/constants.dart';
import 'package:todo_app/features/auth/auth.dart';

import '../models/todo.dart';
import 'todo_repository.dart';
```

### File Structure Best Practices
- Group related files in feature folders
- Use barrel exports for clean imports
- Separate generated files from source files
- Keep test files alongside source files

```
lib/
├── core/
│   ├── constants/
│   ├── extensions/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── auth.dart (barrel export)
│   └── todos/
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       └── todos.dart (barrel export)
└── shared/
    ├── widgets/
    └── providers/
```

## Documentation Standards

### Modern Dartdoc Patterns
- Use triple-slash comments for public APIs
- Include examples with code blocks
- Document parameters and return values
- Use markdown formatting for better readability
- Include since/deprecated annotations

```dart
/// A repository for managing todo items.
///
/// This repository provides methods to create, read, update, and delete
/// todo items. It handles both local caching and remote synchronization.
///
/// Example:
/// ```dart
/// final repository = TodoRepository();
/// final todos = await repository.fetchTodos();
/// 
/// final newTodo = Todo(
///   id: 'unique-id',
///   title: 'Buy groceries',
///   isCompleted: false,
/// );
/// await repository.createTodo(newTodo);
/// ```
///
/// See also:
/// * [Todo] for the todo model
/// * [TodoProvider] for state management integration
abstract class TodoRepository {
  /// Fetches all todos for the current user.
  ///
  /// Returns a [List] of [Todo] objects. The list may be empty if no todos
  /// are found.
  ///
  /// Throws:
  /// * [NetworkException] if the network request fails
  /// * [AuthenticationException] if the user is not authenticated
  ///
  /// Since: 1.0.0
  Future<List<Todo>> fetchTodos();

  /// Creates a new todo item.
  ///
  /// The [todo] parameter must have a unique [Todo.id]. If a todo with the
  /// same ID already exists, this method will throw a [ValidationException].
  ///
  /// Returns the created [Todo] with any server-generated fields populated.
  ///
  /// Example:
  /// ```dart
  /// final todo = Todo(
  ///   id: uuid.v4(),
  ///   title: 'Complete project',
  ///   description: 'Finish the Flutter app',
  /// );
  /// final createdTodo = await repository.createTodo(todo);
  /// ```
  Future<Todo> createTodo(Todo todo);

  /// Updates an existing todo item.
  ///
  /// {@deprecated Use [updateTodoById] instead. This method will be removed in v2.0.0}
  @Deprecated('Use updateTodoById instead')
  Future<Todo> updateTodo(Todo todo);
}
```

## Accessibility Guidelines

### Semantic Labeling
- Provide meaningful semantic labels for all interactive elements
- Use proper heading hierarchy
- Include tooltips for icon buttons
- Ensure proper reading order

```dart
// Good - Accessible widget
class AccessibleTodoItem extends StatelessWidget {
  const AccessibleTodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Todo item: ${todo.title}',
      hint: todo.isCompleted 
        ? 'Completed todo item' 
        : 'Incomplete todo item',
      child: Card(
        child: ListTile(
          title: Text(
            todo.title,
            semanticsLabel: 'Todo title: ${todo.title}',
          ),
          subtitle: Text(
            todo.description,
            semanticsLabel: 'Description: ${todo.description}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: todo.isCompleted 
                  ? 'Mark as incomplete' 
                  : 'Mark as complete',
                child: IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    todo.isCompleted 
                      ? Icons.check_box 
                      : Icons.check_box_outline_blank,
                  ),
                  tooltip: todo.isCompleted 
                    ? 'Mark as incomplete' 
                    : 'Mark as complete',
                ),
              ),
              Semantics(
                label: 'Delete todo: ${todo.title}',
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete todo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Proper focus management
class AccessibleForm extends StatefulWidget {
  const AccessibleForm({super.key});

  @override
  State<AccessibleForm> createState() => _AccessibleFormState();
}

class _AccessibleFormState extends State<AccessibleForm> {
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          focusNode: _titleFocusNode,
          decoration: const InputDecoration(
            labelText: 'Todo Title',
            hintText: 'Enter a descriptive title',
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _descriptionFocusNode.requestFocus();
          },
        ),
        TextFormField(
          focusNode: _descriptionFocusNode,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Optional description',
          ),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
```

## Code Generation Best Practices

### Build Runner Workflows
- Use proper file naming conventions for generated files
- Keep generated files out of version control
- Use build.yaml for custom configuration
- Run code generation as part of CI/CD

```dart
// Good - Freezed model with proper annotations
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default('') String description,
    @Default(false) bool isCompleted,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

// Riverpod code generation
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_provider.g.dart';

@riverpod
class TodoNotifier extends _$TodoNotifier {
  @override
  Future<List<Todo>> build() async {
    return await ref.read(todoRepositoryProvider).fetchTodos();
  }

  Future<void> addTodo(Todo todo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(todoRepositoryProvider).createTodo(todo);
      return await ref.read(todoRepositoryProvider).fetchTodos();
    });
  }
}
```

### Generated File Management
```yaml
# build.yaml
targets:
  $default:
    builders:
      freezed:
        options:
          # Generate copyWith methods
          copy_with: true
          # Generate when/map methods
          when: true
          map: true
      json_serializable:
        options:
          # Generate explicit toJson methods
          explicit_to_json: true
          # Include null values in JSON
          include_if_null: false
```

## Best Practices

### Code Organization
- Keep files small and focused (< 300 lines)
- Group related functionality in feature folders
- Use barrel exports for clean imports
- Separate concerns with proper layering

### Performance
- Use `const` constructors for widgets
- Implement `RepaintBoundary` for expensive widgets
- Use `ListView.builder` for large lists
- Leverage `AutomaticKeepAliveClientMixin` when needed
- Profile performance regularly with DevTools

### Testing
- Write tests for business logic
- Test edge cases and error conditions
- Keep tests focused and independent
- Use descriptive test names that explain behavior
- Test accessibility features

### Version Control
- Write clear, descriptive commit messages
- Keep commits small and focused
- Use conventional commit format
- Review code before merging
- Use feature branches for development
