# Development Standards & Best Practices

## Code Organization

### File Structure
- Follow Flutter's standard project structure
- Group related files in feature-based folders under `lib/`
- Use barrel exports (`index.dart`) for clean imports
- Keep models, providers, and widgets in separate files

### Naming Conventions
- Use `snake_case` for file names
- Use `PascalCase` for class names
- Use `camelCase` for variables and methods
- Use `SCREAMING_SNAKE_CASE` for constants

## State Management with Riverpod 3.0.0-dev.16

### Provider Patterns
- Use `@riverpod` annotation for code generation (new syntax in 3.0)
- Use `@Riverpod()` class-based providers for complex state management
- Prefer `AsyncNotifier` classes over `StateNotifier` 
- Use `@riverpod` functions for simple providers
- Keep providers focused and single-responsibility

### New Syntax Examples
```dart
// Function-based provider (new syntax)
@riverpod
Future<List<Todo>> todos(TodosRef ref) async {
  // Implementation
}

// Class-based provider (new syntax)
@Riverpod()
class TodosNotifier extends _$TodosNotifier {
  @override
  Future<List<Todo>> build() async {
    // Initial state
  }
  
  Future<void> addTodo(Todo todo) async {
    // Update logic
  }
}
```

### Widget Patterns
- Use `ConsumerWidget` or `HookConsumerWidget`
- Prefer `ref.watch()` for reactive state
- Use `ref.read()` for one-time actions
- Handle loading and error states explicitly with `AsyncValue`

## Data Models

### Freezed Classes
- Use `@freezed` for immutable data classes
- Include `@JsonSerializable()` for API models
- Use unions for different states (loading, success, error)
- Add `copyWith` methods for state updates

### Example Structure
```dart
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    required bool isCompleted,
    DateTime? createdAt,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

## Error Handling

### Async Operations
- Always handle errors in async providers
- Use `AsyncValue` for loading/error states
- Provide meaningful error messages
- Log errors for debugging

### UI Error States
- Show user-friendly error messages
- Provide retry mechanisms
- Use consistent error UI patterns

## Testing

### Unit Tests
- Test business logic and providers
- Mock external dependencies
- Use `ProviderContainer` for testing providers
- Aim for high coverage on critical paths

### Widget Tests
- Test user interactions
- Verify state changes
- Test error scenarios
- Use `ProviderScope` in widget tests

## Performance

### Best Practices
- Use `const` constructors where possible
- Minimize widget rebuilds with proper provider scoping
- Lazy load data when appropriate
- Optimize list rendering with `ListView.builder`

### Code Generation
- Run code generation after model changes
- Keep generated files in version control
- Use `--delete-conflicting-outputs` flag

## Supabase Integration

### Authentication
- Handle auth state changes reactively
- Implement proper logout flow
- Store tokens securely

### Database Operations
- Use typed queries with generated models
- Handle network errors gracefully
- Implement optimistic updates where appropriate
- Use real-time subscriptions for live data