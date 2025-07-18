# Testing Guidelines

## Table of Contents
1. [Testing Strategy](#testing-strategy)
2. [Unit Testing](#unit-testing)
3. [Widget Testing](#widget-testing)
4. [Golden Tests & Visual Regression](#golden-tests--visual-regression)
5. [BDD Testing with Flutter Gherkin](#bdd-testing-with-flutter-gherkin)
6. [Integration Testing](#integration-testing)
7. [Testing with Riverpod 3.0](#testing-with-riverpod-30)
8. [Testing with Supabase](#testing-with-supabase)
9. [Performance Testing](#performance-testing)
10. [Test Coverage & Enforcement](#test-coverage--enforcement)
11. [Continuous Integration](#continuous-integration)
12. [Modern Mocking Patterns](#modern-mocking-patterns)
13. [Offline Persistence Testing](#offline-persistence-testing)
14. [Best Practices](#best-practices)

## Testing Strategy

### Modern Testing Pyramid (2025)
```
        E2E Tests (5%)
      /     |     \
     /      |      \
    /       |       \
Integration  Golden  Unit Tests
Tests (15%)  Tests   (70%)
     |       (10%)
     |
  Widget Tests
  & BDD Tests
```

### Comprehensive Test File Structure
```
test/
├── unit/                    # Unit tests (70%)
│   ├── models/             # Model tests with Freezed
│   ├── providers/          # Riverpod 3.0 provider tests
│   ├── repositories/       # Repository tests
│   ├── services/           # Service tests
│   └── utils/              # Utility function tests
├── widget/                 # Widget tests (15%)
│   ├── screens/            # Screen widget tests
│   ├── widgets/            # Reusable widget tests
│   └── golden/             # Golden test files
├── integration/            # Integration tests (10%)
│   ├── app_test.dart       # Full app flow tests
│   ├── offline_test.dart   # Offline persistence tests
│   └── performance_test.dart # Performance benchmarks
├── bdd/                    # BDD tests with Gherkin (5%)
│   ├── features/           # Feature files (.feature)
│   ├── steps/              # Step definitions
│   └── support/            # Test support files
├── mocks/                  # Mock classes and data
│   ├── mock_providers.dart # Riverpod mock providers
│   ├── mock_supabase.dart  # Supabase mocks
│   └── test_data.dart      # Test data factories
└── helpers/                # Test utilities
    ├── test_app.dart       # Test app wrapper
    ├── pump_app.dart       # Widget test helpers
    └── golden_config.dart  # Golden test configuration
```

### Testing Framework Selection (2025)
- **Unit Testing**: Built-in `flutter_test` with `mocktail` for mocking
- **Widget Testing**: `flutter_test` with `golden_toolkit` for visual regression
- **BDD Testing**: `flutter_gherkin` for natural language scenarios
- **Integration Testing**: `integration_test` with real device testing
- **Performance Testing**: `flutter_driver` with custom benchmarks
- **Coverage**: `test_coverage` package with enforcement

## Unit Testing

### Modern Model Testing with Freezed

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/models/todo.dart';

void main() {
  group('Todo Model', () {
    test('should create todo with factory constructor', () {
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        isCompleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
      );
      
      expect(todo.id, '1');
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
      expect(todo.createdAt, DateTime.utc(2025, 1, 1));
    });

    test('should convert from JSON with proper null safety', () {
      final json = {
        'id': '1',
        'title': 'Test Todo',
        'is_completed': false,
        'created_at': '2025-01-01T00:00:00.000Z',
        'description': null, // Test null handling
      };
      
      final todo = Todo.fromJson(json);
      
      expect(todo.id, '1');
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
      expect(todo.createdAt, DateTime.utc(2025, 1, 1));
      expect(todo.description, isNull);
    });
    
    test('should use copyWith for immutable updates', () {
      final original = Todo(
        id: '1',
        title: 'Original',
        isCompleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
      );
      
      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
      );
      
      expect(updated.id, '1'); // Unchanged
      expect(updated.title, 'Updated'); // Changed
      expect(updated.isCompleted, true); // Changed
      expect(updated.createdAt, DateTime.utc(2025, 1, 1)); // Unchanged
      
      // Original should remain unchanged
      expect(original.title, 'Original');
      expect(original.isCompleted, false);
    });

    test('should support pattern matching with sealed classes', () {
      const todoState = TodoState.loading();
      
      final result = switch (todoState) {
        TodoState.loading() => 'Loading todos...',
        TodoState.loaded(todos: final todos) => 'Loaded ${todos.length} todos',
        TodoState.error(message: final msg) => 'Error: $msg',
      };
      
      expect(result, 'Loading todos...');
    });
  });
}
```

### Repository Testing with Mocktail

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/models/todo.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late TodoRepositoryImpl repository;
  late MockSupabaseClient mockSupabase;
  late MockPostgrestFilterBuilder mockQuery;
  
  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQuery = MockPostgrestFilterBuilder();
    repository = TodoRepositoryImpl(mockSupabase);
  });
  
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const Todo(
      id: '',
      title: '',
      isCompleted: false,
      createdAt: null,
    ));
  });
  
  group('TodoRepository', () {
    test('getTodos returns list of todos with proper error handling', () async {
      // Arrange
      final todosJson = [
        {
          'id': '1',
          'title': 'Test Todo',
          'is_completed': false,
          'created_at': '2025-01-01T00:00:00.000Z',
        },
      ];
      
      when(() => mockSupabase.from('todos')).thenReturn(mockQuery);
      when(() => mockQuery.select()).thenAnswer((_) async => todosJson);
      
      // Act
      final result = await repository.getTodos();
      
      // Assert
      expect(result, isA<List<Todo>>());
      expect(result.length, 1);
      expect(result[0].id, '1');
      expect(result[0].title, 'Test Todo');
      
      verify(() => mockSupabase.from('todos')).called(1);
      verify(() => mockQuery.select()).called(1);
    });
    
    test('createTodo handles optimistic updates', () async {
      // Arrange
      final newTodo = Todo(
        id: '2',
        title: 'New Todo',
        isCompleted: false,
        createdAt: DateTime.utc(2025, 1, 1),
      );
      
      when(() => mockSupabase.from('todos')).thenReturn(mockQuery);
      when(() => mockQuery.insert(any())).thenAnswer((_) async => [newTodo.toJson()]);
      
      // Act
      final result = await repository.createTodo(newTodo);
      
      // Assert
      expect(result.id, '2');
      expect(result.title, 'New Todo');
      
      verify(() => mockSupabase.from('todos')).called(1);
      verify(() => mockQuery.insert(newTodo.toJson())).called(1);
    });
    
    test('handles network errors gracefully', () async {
      // Arrange
      when(() => mockSupabase.from('todos')).thenReturn(mockQuery);
      when(() => mockQuery.select()).thenThrow(
        const PostgrestException(message: 'Network error', code: '500'),
      );
      
      // Act & Assert
      expect(
        () => repository.getTodos(),
        throwsA(isA<PostgrestException>()),
      );
    });
  });
}
```

## Widget Testing

### Modern Widget Testing with Test Helpers

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/screens/todo_list_screen.dart';
import 'package:todo_app/providers/todo_providers.dart';
import '../helpers/pump_app.dart';
import '../mocks/mock_providers.dart';

void main() {
  group('TodoListScreen Widget Tests', () {
    testWidgets('displays loading state initially', (tester) async {
      await tester.pumpApp(
        const TodoListScreen(),
        overrides: [
          todosProvider.overrideWith((ref) => const AsyncValue.loading()),
        ],
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading todos...'), findsOneWidget);
    });

    testWidgets('displays todos when loaded', (tester) async {
      final testTodos = [
        Todo(id: '1', title: 'Test Todo 1', isCompleted: false),
        Todo(id: '2', title: 'Test Todo 2', isCompleted: true),
      ];

      await tester.pumpApp(
        const TodoListScreen(),
        overrides: [
          todosProvider.overrideWith((ref) => AsyncValue.data(testTodos)),
        ],
      );
      
      expect(find.text('Test Todo 1'), findsOneWidget);
      expect(find.text('Test Todo 2'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
    });

    testWidgets('handles todo completion toggle', (tester) async {
      final mockNotifier = MockTodosNotifier();
      final testTodos = [
        Todo(id: '1', title: 'Test Todo', isCompleted: false),
      ];

      await tester.pumpApp(
        const TodoListScreen(),
        overrides: [
          todosProvider.overrideWith(() => mockNotifier),
        ],
      );

      // Simulate initial data
      when(() => mockNotifier.build()).thenReturn(AsyncValue.data(testTodos));
      await tester.pump();

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verify the toggle method was called
      verify(() => mockNotifier.toggleTodo('1')).called(1);
    });

    testWidgets('shows error state with retry option', (tester) async {
      const error = 'Failed to load todos';
      
      await tester.pumpApp(
        const TodoListScreen(),
        overrides: [
          todosProvider.overrideWith((ref) => 
            AsyncValue.error(error, StackTrace.current)),
        ],
      );
      
      expect(find.text('Error: $error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      
      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      // Verify retry was triggered (would need mock setup)
    });

    testWidgets('supports accessibility features', (tester) async {
      final testTodos = [
        Todo(id: '1', title: 'Accessible Todo', isCompleted: false),
      ];

      await tester.pumpApp(
        const TodoListScreen(),
        overrides: [
          todosProvider.overrideWith((ref) => AsyncValue.data(testTodos)),
        ],
      );
      
      // Test semantic labels
      expect(
        find.bySemanticsLabel('Mark Accessible Todo as completed'),
        findsOneWidget,
      );
      
      // Test focus traversal
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(tester.binding.focusManager.primaryFocus, isNotNull);
    });
  });
}
```

### Testing User Interactions with Modern Patterns

```dart
testWidgets('Add todo with validation and feedback', (tester) async {
  final mockNotifier = MockTodosNotifier();
  
  await tester.pumpApp(
    const AddTodoScreen(),
    overrides: [
      todosProvider.overrideWith(() => mockNotifier),
    ],
  );
  
  // Test empty input validation
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  expect(find.text('Please enter a todo title'), findsOneWidget);
  
  // Test successful todo creation
  await tester.enterText(find.byType(TextField), 'New Important Todo');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Verify the add method was called with correct data
  verify(() => mockNotifier.addTodo(
    argThat(predicate<Todo>((todo) => todo.title == 'New Important Todo')),
  )).called(1);
  
  // Test success feedback
  expect(find.byType(SnackBar), findsOneWidget);
  expect(find.text('Todo added successfully!'), findsOneWidget);
});
```

## Golden Tests & Visual Regression

### Setting Up Golden Tests with golden_toolkit

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:todo_app/widgets/todo_card.dart';
import '../helpers/golden_config.dart';

void main() {
  group('TodoCard Golden Tests', () {
    setUpAll(() async {
      await loadAppFonts();
    });

    testGoldens('TodoCard renders correctly in different states', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.iphone11,
          Device.tabletPortrait,
        ])
        ..addScenario(
          widget: TodoCard(
            todo: Todo(
              id: '1',
              title: 'Complete project documentation',
              isCompleted: false,
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
          name: 'incomplete_todo',
        )
        ..addScenario(
          widget: TodoCard(
            todo: Todo(
              id: '2',
              title: 'Review pull requests',
              isCompleted: true,
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
          name: 'completed_todo',
        )
        ..addScenario(
          widget: TodoCard(
            todo: Todo(
              id: '3',
              title: 'Very long todo title that should wrap to multiple lines and test text overflow behavior',
              isCompleted: false,
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
          name: 'long_title_todo',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'todo_card_states');
    });

    testGoldens('TodoCard dark mode rendering', (tester) async {
      await tester.pumpWidgetBuilder(
        TodoCard(
          todo: Todo(
            id: '1',
            title: 'Dark mode todo',
            isCompleted: false,
            createdAt: DateTime(2025, 1, 1),
          ),
        ),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
        ),
      );

      await screenMatchesGolden(tester, 'todo_card_dark_mode');
    });

    testGoldens('TodoCard accessibility focus states', (tester) async {
      await tester.pumpWidgetBuilder(
        TodoCard(
          todo: Todo(
            id: '1',
            title: 'Focused todo',
            isCompleted: false,
            createdAt: DateTime(2025, 1, 1),
          ),
        ),
        wrapper: materialAppWrapper(),
      );

      // Simulate focus
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      await screenMatchesGolden(tester, 'todo_card_focused');
    });
  });
}
```

### Visual Regression Testing Configuration

```dart
// test/helpers/golden_config.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      enableRealShadows: true,
      defaultDevices: const [
        Device.phone,
        Device.iphone11,
        Device.tabletPortrait,
      ],
    ),
  );
}

Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Load custom fonts used in the app
  final fontLoader = FontLoader('Roboto')
    ..addFont(rootBundle.load('fonts/Roboto-Regular.ttf'))
    ..addFont(rootBundle.load('fonts/Roboto-Bold.ttf'));
  
  await fontLoader.load();
}
```

## BDD Testing with Flutter Gherkin

### Feature File Example

```gherkin
# test/bdd/features/todo_management.feature
Feature: Todo Management
  As a user
  I want to manage my todos
  So that I can stay organized

  Background:
    Given the app is launched
    And I am signed in as "test@example.com"

  Scenario: Adding a new todo
    Given I am on the todos screen
    When I tap the add todo button
    And I enter "Buy groceries" as the todo title
    And I tap the save button
    Then I should see "Buy groceries" in the todo list
    And the todo should be marked as incomplete

  Scenario: Completing a todo
    Given I have a todo "Finish homework" in my list
    When I tap the checkbox next to "Finish homework"
    Then the todo should be marked as completed
    And it should appear in the completed section

  Scenario: Editing a todo
    Given I have a todo "Call mom" in my list
    When I long press on "Call mom"
    And I select "Edit" from the context menu
    And I change the title to "Call mom about dinner"
    And I tap save
    Then I should see "Call mom about dinner" in the todo list

  Scenario: Deleting a todo
    Given I have a todo "Old task" in my list
    When I swipe left on "Old task"
    And I tap the delete button
    Then "Old task" should not appear in the todo list

  Scenario: Filtering todos
    Given I have the following todos:
      | title           | completed |
      | Active task 1   | false     |
      | Completed task  | true      |
      | Active task 2   | false     |
    When I tap the filter button
    And I select "Active only"
    Then I should see 2 todos in the list
    And I should not see "Completed task"

  Scenario: Offline todo creation
    Given I am offline
    When I create a todo "Offline task"
    Then the todo should be saved locally
    And when I go back online
    Then the todo should sync to the server
```

### Step Definitions

```dart
// test/bdd/steps/todo_steps.dart
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';

class TodoSteps {
  static Iterable<StepDefinitionGeneric> get steps => [
    given1<String, FlutterWorld>(
      'I am signed in as {string}',
      (email, context) async {
        final tester = context.world.rawAppDriver;
        
        // Navigate to sign in if needed
        if (find.text('Sign In').evaluate().isNotEmpty) {
          await tester.enterText(find.byKey(const Key('email_field')), email);
          await tester.enterText(find.byKey(const Key('password_field')), 'password123');
          await tester.tap(find.text('Sign In'));
          await tester.pumpAndSettle();
        }
      },
    ),

    given1<String, FlutterWorld>(
      'I have a todo {string} in my list',
      (todoTitle, context) async {
        final tester = context.world.rawAppDriver;
        
        // Add the todo if it doesn't exist
        if (find.text(todoTitle).evaluate().isEmpty) {
          await tester.tap(find.byKey(const Key('add_todo_button')));
          await tester.pumpAndSettle();
          
          await tester.enterText(find.byKey(const Key('todo_title_field')), todoTitle);
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
        }
      },
    ),

    when1<String, FlutterWorld>(
      'I enter {string} as the todo title',
      (title, context) async {
        final tester = context.world.rawAppDriver;
        await tester.enterText(find.byKey(const Key('todo_title_field')), title);
      },
    ),

    when1<String, FlutterWorld>(
      'I tap the checkbox next to {string}',
      (todoTitle, context) async {
        final tester = context.world.rawAppDriver;
        final todoFinder = find.ancestor(
          of: find.text(todoTitle),
          matching: find.byType(CheckboxListTile),
        );
        final checkboxFinder = find.descendant(
          of: todoFinder,
          matching: find.byType(Checkbox),
        );
        
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();
      },
    ),

    then1<String, FlutterWorld>(
      'I should see {string} in the todo list',
      (todoTitle, context) async {
        final tester = context.world.rawAppDriver;
        expect(find.text(todoTitle), findsOneWidget);
      },
    ),

    then0<FlutterWorld>(
      'the todo should be marked as completed',
      (context) async {
        final tester = context.world.rawAppDriver;
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
        expect(checkbox.value, true);
      },
    ),
  ];
}
```

### BDD Test Configuration

```dart
// test/bdd/flutter_test_config.dart
import 'dart:async';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'steps/todo_steps.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final config = FlutterTestConfiguration()
    ..features = [RegExp(r'test/bdd/features/.*\.feature')]
    ..reporters = [
      ProgressReporter(),
      TestRunSummaryReporter(),
      JsonReporter(path: './test_report.json'),
    ]
    ..stepDefinitions = TodoSteps.steps
    ..customStepParameterDefinitions = []
    ..restartAppBetweenScenarios = true
    ..targetAppPath = 'test_driver/app.dart'
    ..exitAfterTestRun = true;

  return GherkinRunner().execute(config);
}
```

## Integration Testing

### Modern Integration Testing with Real Device Support

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Todo App Integration Tests', () {
    testWidgets('Complete user journey', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      
      // Test authentication flow
      await _signInUser(tester);
      
      // Test todo creation
      await _createTodo(tester, 'Integration Test Todo');
      
      // Test todo completion
      await _completeTodo(tester, 'Integration Test Todo');
      
      // Test todo deletion
      await _deleteTodo(tester, 'Integration Test Todo');
      
      // Test offline functionality
      await _testOfflineMode(tester);
    });

    testWidgets('Performance benchmarks', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Measure app startup time
      final startupTime = await tester.binding.defaultBinaryMessenger
          .send('flutter/platform_views', null);
      
      // Measure list scrolling performance
      await _measureScrollPerformance(tester);
      
      // Measure navigation performance
      await _measureNavigationPerformance(tester);
    });
  });
}

Future<void> _signInUser(WidgetTester tester) async {
  // Wait for sign-in screen
  await tester.pumpAndSettle(const Duration(seconds: 2));
  
  if (find.text('Sign In').evaluate().isNotEmpty) {
    await tester.enterText(
      find.byKey(const Key('email_field')), 
      'test@example.com'
    );
    await tester.enterText(
      find.byKey(const Key('password_field')), 
      'password123'
    );
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
  
  // Verify we're on the home screen
  expect(find.text('My Todos'), findsOneWidget);
}

Future<void> _createTodo(WidgetTester tester, String title) async {
  await tester.tap(find.byKey(const Key('add_todo_button')));
  await tester.pumpAndSettle();
  
  await tester.enterText(find.byKey(const Key('todo_title_field')), title);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  
  expect(find.text(title), findsOneWidget);
}

Future<void> _completeTodo(WidgetTester tester, String title) async {
  final todoFinder = find.ancestor(
    of: find.text(title),
    matching: find.byType(CheckboxListTile),
  );
  final checkboxFinder = find.descendant(
    of: todoFinder,
    matching: find.byType(Checkbox),
  );
  
  await tester.tap(checkboxFinder);
  await tester.pumpAndSettle();
  
  final checkbox = tester.widget<Checkbox>(checkboxFinder);
  expect(checkbox.value, true);
}

Future<void> _deleteTodo(WidgetTester tester, String title) async {
  // Swipe to delete
  await tester.drag(find.text(title), const Offset(-300, 0));
  await tester.pumpAndSettle();
  
  await tester.tap(find.byKey(const Key('delete_button')));
  await tester.pumpAndSettle();
  
  expect(find.text(title), findsNothing);
}

Future<void> _testOfflineMode(WidgetTester tester) async {
  // Simulate offline mode
  await tester.binding.defaultBinaryMessenger.send(
    'flutter/connectivity',
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('setConnectivity', 'none'),
    ),
  );
  
  // Try to create a todo offline
  await _createTodo(tester, 'Offline Todo');
  
  // Verify it's saved locally
  expect(find.text('Offline Todo'), findsOneWidget);
  expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  
  // Restore connectivity
  await tester.binding.defaultBinaryMessenger.send(
    'flutter/connectivity',
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('setConnectivity', 'wifi'),
    ),
  );
  
  await tester.pumpAndSettle(const Duration(seconds: 2));
  
  // Verify sync indicator
  expect(find.byIcon(Icons.cloud_done), findsOneWidget);
}

Future<void> _measureScrollPerformance(WidgetTester tester) async {
  // Create multiple todos for scrolling test
  for (int i = 0; i < 20; i++) {
    await _createTodo(tester, 'Todo $i');
  }
  
  final listFinder = find.byType(ListView);
  
  // Measure scroll performance
  final stopwatch = Stopwatch()..start();
  
  await tester.fling(listFinder, const Offset(0, -500), 1000);
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  
  // Assert reasonable scroll time (adjust threshold as needed)
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
}

Future<void> _measureNavigationPerformance(WidgetTester tester) async {
  final stopwatch = Stopwatch()..start();
  
  // Navigate to settings
  await tester.tap(find.byKey(const Key('settings_button')));
  await tester.pumpAndSettle();
  
  // Navigate back
  await tester.tap(find.byKey(const Key('back_button')));
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  
  // Assert reasonable navigation time
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
}
```

## Testing with Riverpod 3.0

### Modern Provider Testing with New Utilities

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/providers/todo_providers.dart';
import 'package:todo_app/repositories/todo_repository.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  group('TodosNotifier Tests', () {
    late MockTodoRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockTodoRepository();
      container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading', () {
      final notifier = container.read(todosProvider.notifier);
      final state = container.read(todosProvider);
      
      expect(state, const AsyncValue<List<Todo>>.loading());
    });

    test('loads todos successfully', () async {
      final testTodos = [
        Todo(id: '1', title: 'Test Todo', isCompleted: false),
      ];
      
      when(() => mockRepository.getTodos())
          .thenAnswer((_) async => testTodos);

      // Use the new test utility
      await container.read(todosProvider.notifier).loadTodos();
      
      final state = container.read(todosProvider);
      expect(state.value, testTodos);
      expect(state.hasError, false);
    });

    test('handles errors gracefully', () async {
      const error = 'Network error';
      
      when(() => mockRepository.getTodos())
          .thenThrow(Exception(error));

      await container.read(todosProvider.notifier).loadTodos();
      
      final state = container.read(todosProvider);
      expect(state.hasError, true);
      expect(state.error.toString(), contains(error));
    });

    test('addTodo updates state optimistically', () async {
      final newTodo = Todo(
        id: '2',
        title: 'New Todo',
        isCompleted: false,
      );
      
      when(() => mockRepository.createTodo(any()))
          .thenAnswer((_) async => newTodo);

      // Set initial state
      container.read(todosProvider.notifier).state = 
          const AsyncValue.data([]);

      await container.read(todosProvider.notifier).addTodo(newTodo);
      
      final state = container.read(todosProvider);
      expect(state.value, contains(newTodo));
      
      verify(() => mockRepository.createTodo(newTodo)).called(1);
    });

    test('toggleTodo updates completion status', () async {
      final todo = Todo(id: '1', title: 'Test', isCompleted: false);
      final updatedTodo = todo.copyWith(isCompleted: true);
      
      when(() => mockRepository.updateTodo(any()))
          .thenAnswer((_) async => updatedTodo);

      // Set initial state
      container.read(todosProvider.notifier).state = 
          AsyncValue.data([todo]);

      await container.read(todosProvider.notifier).toggleTodo('1');
      
      final state = container.read(todosProvider);
      expect(state.value?.first.isCompleted, true);
    });

    test('supports offline persistence', () async {
      final todo = Todo(id: '1', title: 'Offline Todo', isCompleted: false);
      
      // Simulate offline mode
      when(() => mockRepository.createTodo(any()))
          .thenThrow(const SocketException('No internet'));
      
      when(() => mockRepository.saveOffline(any()))
          .thenAnswer((_) async => todo);

      await container.read(todosProvider.notifier).addTodo(todo);
      
      // Verify offline save was called
      verify(() => mockRepository.saveOffline(todo)).called(1);
      
      // Verify state includes offline todo
      final state = container.read(todosProvider);
      expect(state.value, contains(todo));
    });
  });

  group('Provider Integration Tests', () {
    test('provider dependencies work correctly', () {
      final container = ProviderContainer();
      
      // Test that dependent providers are properly initialized
      final authState = container.read(authProvider);
      final todosState = container.read(todosProvider);
      
      expect(authState, isA<AsyncValue>());
      expect(todosState, isA<AsyncValue>());
      
      container.dispose();
    });

    test('provider scoping works with families', () {
      final container = ProviderContainer();
      
      // Test family provider with different parameters
      final todo1 = container.read(todoProvider('1'));
      final todo2 = container.read(todoProvider('2'));
      
      expect(todo1, isNot(equals(todo2)));
      
      container.dispose();
    });

    test('ref.mounted prevents state updates after disposal', () async {
      final container = ProviderContainer();
      final notifier = container.read(todosProvider.notifier);
      
      // Dispose container
      container.dispose();
      
      // Attempt to update state (should be ignored due to ref.mounted check)
      await notifier.loadTodos();
      
      // No assertion needed - test passes if no exception is thrown
    });
  });
}
```

### Testing Provider Lifecycle and Dependencies

```dart
void main() {
  group('Provider Lifecycle Tests', () {
    test('provider auto-dispose works correctly', () {
      final container = ProviderContainer();
      
      // Read the provider to initialize it
      container.read(todosProvider);
      
      // Verify provider is active
      expect(container.getAllProviderElements(), isNotEmpty);
      
      // Simulate no listeners
      container.updateOverrides([]);
      
      // Provider should auto-dispose after timeout
      // (This would need actual timing in real tests)
    });

    test('provider refresh works correctly', () async {
      final mockRepository = MockTodoRepository();
      final container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      when(() => mockRepository.getTodos())
          .thenAnswer((_) async => []);

      // Initial load
      await container.read(todosProvider.future);
      
      // Refresh
      await container.refresh(todosProvider.future);
      
      // Verify repository was called twice
      verify(() => mockRepository.getTodos()).called(2);
      
      container.dispose();
    });

    test('provider invalidation cascades correctly', () {
      final container = ProviderContainer();
      
      // Set up listeners to track invalidations
      var authInvalidated = false;
      var todosInvalidated = false;
      
      container.listen(authProvider, (previous, next) {
        authInvalidated = true;
      });
      
      container.listen(todosProvider, (previous, next) {
        todosInvalidated = true;
      });
      
      // Invalidate auth provider
      container.invalidate(authProvider);
      
      // Both should be invalidated due to dependency
      expect(authInvalidated, true);
      expect(todosInvalidated, true);
      
      container.dispose();
    });
  });
}
```

## Testing with Supabase

### Modern Supabase Testing with Mocktail

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/services/auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockRealtimeClient extends Mock implements RealtimeClient {}
class MockStorageClient extends Mock implements SupabaseStorageClient {}

void main() {
  group('Supabase Auth Service Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late AuthService authService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      authService = AuthService(mockSupabase);
      
      when(() => mockSupabase.auth).thenReturn(mockAuth);
    });

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const AuthResponse());
      registerFallbackValue(const User(
        id: '',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      ));
    });

    test('signInWithEmailAndPassword returns user on success', () async {
      // Arrange
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      final session = Session(
        accessToken: 'access_token_123',
        tokenType: 'bearer',
        user: user,
        expiresIn: 3600,
        refreshToken: 'refresh_token_123',
      );

      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => AuthResponse(
        session: session,
        user: user,
      ));

      // Act
      final result = await authService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.id, 'user123');
      expect(result.email, 'test@example.com');
      
      verify(() => mockAuth.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('signInWithEmailAndPassword throws on invalid credentials', () async {
      // Arrange
      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(const AuthException('Invalid credentials'));

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword(
          email: 'invalid@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('getCurrentUser returns null when not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = authService.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('signOut clears session', () async {
      // Arrange
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      // Act
      await authService.signOut();

      // Assert
      verify(() => mockAuth.signOut()).called(1);
    });

    test('handles session refresh automatically', () async {
      // Arrange
      final refreshedSession = Session(
        accessToken: 'new_access_token',
        tokenType: 'bearer',
        user: User(
          id: 'user123',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        expiresIn: 3600,
        refreshToken: 'new_refresh_token',
      );

      when(() => mockAuth.refreshSession()).thenAnswer(
        (_) async => AuthResponse(session: refreshedSession),
      );

      // Act
      final result = await authService.refreshSession();

      // Assert
      expect(result.accessToken, 'new_access_token');
      verify(() => mockAuth.refreshSession()).called(1);
    });
  });

  group('Supabase Database Service Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockPostgrestClient mockPostgrest;
    late TodoService todoService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockPostgrest = MockPostgrestClient();
      todoService = TodoService(mockSupabase);
      
      when(() => mockSupabase.from(any())).thenReturn(mockPostgrest as dynamic);
    });

    test('creates todo with RLS policy enforcement', () async {
      // Arrange
      final todoData = {
        'title': 'Test Todo',
        'is_completed': false,
        'user_id': 'user123',
      };

      final createdTodo = {
        'id': '1',
        'title': 'Test Todo',
        'is_completed': false,
        'user_id': 'user123',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      when(() => mockPostgrest.insert(any())).thenAnswer(
        (_) async => [createdTodo],
      );

      // Act
      final result = await todoService.createTodo(todoData);

      // Assert
      expect(result['id'], '1');
      expect(result['title'], 'Test Todo');
      
      verify(() => mockPostgrest.insert(todoData)).called(1);
    });

    test('handles real-time subscriptions', () async {
      // Arrange
      final mockRealtime = MockRealtimeClient();
      when(() => mockSupabase.realtime).thenReturn(mockRealtime);

      final mockChannel = MockRealtimeChannel();
      when(() => mockRealtime.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.on(any(), any())).thenReturn(mockChannel);
      when(() => mockChannel.subscribe()).thenAnswer((_) async {});

      // Act
      await todoService.subscribeToTodos('user123');

      // Assert
      verify(() => mockRealtime.channel('todos:user123')).called(1);
      verify(() => mockChannel.subscribe()).called(1);
    });
  });

  group('Supabase Storage Service Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockStorageClient mockStorage;
    late FileService fileService;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockStorage = MockStorageClient();
      fileService = FileService(mockSupabase);
      
      when(() => mockSupabase.storage).thenReturn(mockStorage);
    });

    test('uploads file with progress tracking', () async {
      // Arrange
      final fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      const fileName = 'test_file.jpg';
      const bucketName = 'avatars';

      when(() => mockStorage.from(bucketName).uploadBinary(
        fileName,
        fileBytes,
        fileOptions: any(named: 'fileOptions'),
      )).thenAnswer((_) async => 'uploads/$fileName');

      // Act
      final result = await fileService.uploadFile(
        bucketName: bucketName,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      // Assert
      expect(result, 'uploads/$fileName');
      
      verify(() => mockStorage.from(bucketName).uploadBinary(
        fileName,
        fileBytes,
        fileOptions: any(named: 'fileOptions'),
      )).called(1);
    });

    test('handles upload errors gracefully', () async {
      // Arrange
      final fileBytes = Uint8List.fromList([1, 2, 3]);
      const fileName = 'test_file.jpg';
      const bucketName = 'avatars';

      when(() => mockStorage.from(bucketName).uploadBinary(
        fileName,
        fileBytes,
        fileOptions: any(named: 'fileOptions'),
      )).thenThrow(const StorageException('Upload failed'));

      // Act & Assert
      expect(
        () => fileService.uploadFile(
          bucketName: bucketName,
          fileName: fileName,
          fileBytes: fileBytes,
        ),
        throwsA(isA<StorageException>()),
      );
    });
  });
}

// Additional mock classes for real-time testing
class MockRealtimeChannel extends Mock implements RealtimeChannel {}
```

## Performance Testing

### Performance Benchmarking and Profiling

```dart
// test/performance/performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('App startup performance', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert startup time is under 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      
      print('App startup time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('List scrolling performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Create a large list of todos
      await _createManyTodos(tester, 100);
      
      final listFinder = find.byType(ListView);
      
      // Measure scroll performance
      final timeline = await tester.binding.traceAction(() async {
        await tester.fling(listFinder, const Offset(0, -500), 1000);
        await tester.pumpAndSettle();
      });
      
      // Analyze frame times
      final summary = TimelineSummary.summarize(timeline);
      
      // Assert no dropped frames
      expect(summary.countFrames(), greaterThan(0));
      expect(summary.frameBuildRate, greaterThan(55.0)); // 55+ FPS
      
      print('Average frame build time: ${summary.averageFrameBuildTimeMillis}ms');
    });

    testWidgets('Memory usage during heavy operations', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Get initial memory usage
      final initialMemory = await _getMemoryUsage();
      
      // Perform memory-intensive operations
      await _performHeavyOperations(tester);
      
      // Force garbage collection
      await tester.binding.reassembleApplication();
      await tester.pumpAndSettle();
      
      final finalMemory = await _getMemoryUsage();
      
      // Assert memory didn't increase significantly
      final memoryIncrease = finalMemory - initialMemory;
      expect(memoryIncrease, lessThan(50 * 1024 * 1024)); // Less than 50MB
      
      print('Memory increase: ${memoryIncrease / 1024 / 1024}MB');
    });

    testWidgets('Network request performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // Trigger network requests
      await tester.tap(find.byKey(const Key('refresh_button')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert network operations complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      
      print('Network request time: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}

Future<void> _createManyTodos(WidgetTester tester, int count) async {
  for (int i = 0; i < count; i++) {
    await tester.tap(find.byKey(const Key('add_todo_button')));
    await tester.pumpAndSettle();
    
    await tester.enterText(
      find.byKey(const Key('todo_title_field')), 
      'Performance Test Todo $i'
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }
}

Future<int> _getMemoryUsage() async {
  // This would integrate with platform-specific memory monitoring
  // For now, return a mock value
  return 100 * 1024 * 1024; // 100MB
}

Future<void> _performHeavyOperations(WidgetTester tester) async {
  // Simulate heavy operations like image loading, data processing, etc.
  for (int i = 0; i < 10; i++) {
    await tester.tap(find.byKey(const Key('heavy_operation_button')));
    await tester.pump();
  }
}
```

### Widget Performance Testing

```dart
// test/performance/widget_performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/widgets/todo_list.dart';

void main() {
  group('Widget Performance Tests', () {
    testWidgets('TodoList renders efficiently with many items', (tester) async {
      final todos = List.generate(1000, (index) => Todo(
        id: '$index',
        title: 'Todo $index',
        isCompleted: index % 2 == 0,
      ));

      final timeline = await tester.binding.traceAction(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodoList(todos: todos),
            ),
          ),
        );
      });

      final summary = TimelineSummary.summarize(timeline);
      
      // Assert efficient rendering
      expect(summary.averageFrameBuildTimeMillis, lessThan(16.0)); // 60 FPS
      
      print('TodoList render time: ${summary.averageFrameBuildTimeMillis}ms');
    });

    testWidgets('Complex widget rebuilds efficiently', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ComplexTodoWidget(),
      ));

      final timeline = await tester.binding.traceAction(() async {
        // Trigger multiple rebuilds
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byKey(const Key('update_button')));
          await tester.pump();
        }
      });

      final summary = TimelineSummary.summarize(timeline);
      
      // Assert rebuild performance
      expect(summary.averageFrameBuildTimeMillis, lessThan(8.0));
    });
  });
}
```

## Test Coverage & Enforcement

### Modern Coverage with test_coverage Package

```dart
// test/coverage_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:test_coverage/test_coverage.dart';

void main() {
  group('Test Coverage Enforcement', () {
    test('Verify minimum test coverage', () async {
      final coverage = await TestCoverage.getCoverage(
        excludePatterns: [
          '**/*.g.dart',
          '**/*.freezed.dart',
          '**/*.config.dart',
          '**/generated/**',
          '**/l10n/**',
        ],
        includePaths: [
          'lib/',
        ],
      );

      const minCoverage = 85.0;
      final coveragePercent = coverage.percentage;
      
      print('Current test coverage: ${coveragePercent.toStringAsFixed(2)}%');
      print('Lines covered: ${coverage.linesCovered}/${coverage.totalLines}');
      
      // Print uncovered files for debugging
      if (coveragePercent < minCoverage) {
        print('\nUncovered files:');
        for (final file in coverage.uncoveredFiles) {
          print('  - ${file.path}: ${file.coveragePercent.toStringAsFixed(1)}%');
        }
      }
      
      expect(
        coveragePercent,
        greaterThanOrEqualTo(minCoverage),
        reason: 'Test coverage is ${coveragePercent.toStringAsFixed(2)}%, '
                'which is below the required $minCoverage%',
      );
    });

    test('Verify critical paths have 100% coverage', () async {
      final criticalPaths = [
        'lib/services/auth_service.dart',
        'lib/repositories/todo_repository.dart',
        'lib/providers/todo_providers.dart',
      ];

      for (final path in criticalPaths) {
        final coverage = await TestCoverage.getFileCoverage(path);
        
        expect(
          coverage.percentage,
          equals(100.0),
          reason: 'Critical file $path must have 100% test coverage, '
                  'but has ${coverage.percentage.toStringAsFixed(2)}%',
        );
      }
    });

    test('Verify no regression in coverage', () async {
      final currentCoverage = await TestCoverage.getCoverage();
      
      // This would typically read from a stored baseline
      const baselineCoverage = 85.0;
      
      expect(
        currentCoverage.percentage,
        greaterThanOrEqualTo(baselineCoverage),
        reason: 'Test coverage has regressed from $baselineCoverage% '
                'to ${currentCoverage.percentage.toStringAsFixed(2)}%',
      );
    });
  });
}
```

### Coverage Configuration

```yaml
# coverage_config.yaml
coverage:
  min_coverage: 85.0
  critical_files:
    - lib/services/auth_service.dart
    - lib/repositories/todo_repository.dart
    - lib/providers/todo_providers.dart
  exclude_patterns:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"
    - "**/generated/**"
    - "**/l10n/**"
  include_paths:
    - "lib/"
  fail_on_regression: true
  generate_html_report: true
  output_directory: "coverage/html"
```

## Continuous Integration

### Modern GitHub Actions CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: Flutter CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'

jobs:
  analyze:
    name: Code Analysis
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
          
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}
          
      - name: Cache dependencies
        uses: actions/cache@v4
        with:
          path: |
            ~/.pub-cache
            **/.dart_tool
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-
            
      - name: Install dependencies
        run: flutter pub get
        
      - name: Generate code
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
        
      - name: Analyze code
        run: flutter analyze --fatal-infos
        
      - name: Check formatting
        run: dart format --set-exit-if-changed .
        
      - name: Check for unused dependencies
        run: flutter pub deps

  test:
    name: Unit & Widget Tests
    runs-on: ubuntu-latest
    needs: analyze
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Generate code
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
        
      - name: Run unit tests
        run: flutter test test/unit/ --coverage --reporter=github
        
      - name: Run widget tests
        run: flutter test test/widget/ --coverage --reporter=github
        
      - name: Run golden tests
        run: flutter test test/widget/golden/ --update-goldens
        
      - name: Verify test coverage
        run: flutter test test/coverage_test.dart
        
      - name: Generate coverage report
        run: |
          sudo apt-get update
          sudo apt-get install -y lcov
          genhtml coverage/lcov.info -o coverage/html
          
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage/lcov.info
          fail_ci_if_error: true
          token: ${{ secrets.CODECOV_TOKEN }}
          
      - name: Upload coverage artifacts
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/html/

  integration_test:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
          
      - name: Setup Android SDK
        uses: android-actions/setup-android@v3
        
      - name: Install dependencies
        run: flutter pub get
        
      - name: Generate code
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
        
      - name: Start Android emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 33
          target: google_apis
          arch: x86_64
          profile: Nexus 6
          script: |
            flutter test integration_test/app_test.dart
            flutter test integration_test/performance_test.dart

  bdd_test:
    name: BDD Tests
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Generate code
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
        
      - name: Run BDD tests
        run: flutter test test/bdd/
        
      - name: Generate BDD report
        run: |
          mkdir -p reports
          cp test_report.json reports/
          
      - name: Upload BDD artifacts
        uses: actions/upload-artifact@v4
        with:
          name: bdd-report
          path: reports/

  security_scan:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: analyze
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run security audit
        run: flutter pub audit
        
      - name: Check for known vulnerabilities
        run: flutter pub deps --json | jq '.packages[] | select(.kind == "direct")' > dependencies.json
        
      - name: Upload security artifacts
        uses: actions/upload-artifact@v4
        with:
          name: security-report
          path: dependencies.json

  build:
    name: Build Apps
    runs-on: ubuntu-latest
    needs: [test, integration_test]
    strategy:
      matrix:
        platform: [android, web]
        
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true
          
      - name: Setup Java (Android only)
        if: matrix.platform == 'android'
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Generate code
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
        
      - name: Build Android APK
        if: matrix.platform == 'android'
        run: flutter build apk --release
        
      - name: Build Web
        if: matrix.platform == 'web'
        run: flutter build web --release
        
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ matrix.platform }}
          path: |
            build/app/outputs/flutter-apk/*.apk
            build/web/

  deploy_staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    
    steps:
      - name: Download web build
        uses: actions/download-artifact@v4
        with:
          name: build-web
          path: build/web/
          
      - name: Deploy to staging
        run: |
          # Deploy to staging environment
          echo "Deploying to staging..."
          # Add your deployment commands here

  deploy_production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-web
          path: build/web/
          
      - name: Deploy to production
        run: |
          # Deploy to production environment
          echo "Deploying to production..."
          # Add your deployment commands here
```

### Automated Testing Workflows

```yaml
# .github/workflows/nightly-tests.yml
name: Nightly Tests

on:
  schedule:
    - cron: '0 2 * * *'  # Run at 2 AM UTC daily
  workflow_dispatch:

jobs:
  comprehensive_test:
    name: Comprehensive Test Suite
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run all tests
        run: |
          flutter test --coverage
          flutter test integration_test/
          flutter test test/bdd/
          
      - name: Performance benchmarks
        run: flutter test test/performance/
        
      - name: Generate comprehensive report
        run: |
          mkdir -p reports
          echo "Nightly test run completed at $(date)" > reports/summary.txt
          
      - name: Notify on failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          channel: '#dev-alerts'
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## Modern Mocking Patterns

### Advanced Mocking with Mocktail

```dart
// test/mocks/mock_providers.dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/todo_providers.dart';

class MockTodosNotifier extends Mock implements TodosNotifier {
  @override
  AsyncValue<List<Todo>> build() => const AsyncValue.loading();
}

class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  AsyncValue<User?> build() => const AsyncValue.data(null);
}

// Mock provider overrides for testing
final mockProviderOverrides = [
  todosProvider.overrideWith(() => MockTodosNotifier()),
  authProvider.overrideWith(() => MockAuthNotifier()),
];
```

### Test Data Factories

```dart
// test/helpers/test_data.dart
import 'package:todo_app/models/todo.dart';

class TodoFactory {
  static Todo create({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? description,
  }) {
    return Todo(
      id: id ?? 'test-id-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Todo',
      isCompleted: isCompleted ?? false,
      createdAt: createdAt ?? DateTime.now(),
      description: description,
    );
  }

  static List<Todo> createList({
    int count = 3,
    bool? isCompleted,
  }) {
    return List.generate(count, (index) => create(
      id: 'test-id-$index',
      title: 'Test Todo $index',
      isCompleted: isCompleted ?? (index % 2 == 0),
    ));
  }

  static Todo completed() => create(isCompleted: true);
  static Todo pending() => create(isCompleted: false);
  
  static Todo withLongTitle() => create(
    title: 'This is a very long todo title that should test text wrapping and overflow behavior in the UI components',
  );
}

class UserFactory {
  static User create({
    String? id,
    String? email,
    Map<String, dynamic>? userMetadata,
  }) {
    return User(
      id: id ?? 'test-user-id',
      email: email ?? 'test@example.com',
      appMetadata: const {},
      userMetadata: userMetadata ?? const {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
```

## Offline Persistence Testing

### Testing Offline Functionality

```dart
// test/offline/offline_persistence_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/services/offline_service.dart';
import 'package:todo_app/providers/connectivity_provider.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}
class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  group('Offline Persistence Tests', () {
    late OfflineService offlineService;
    late MockConnectivityService mockConnectivity;
    late MockLocalStorage mockStorage;

    setUp(() {
      mockConnectivity = MockConnectivityService();
      mockStorage = MockLocalStorage();
      offlineService = OfflineService(
        connectivity: mockConnectivity,
        localStorage: mockStorage,
      );
    });

    test('saves todo locally when offline', () async {
      // Arrange
      final todo = TodoFactory.create();
      when(() => mockConnectivity.isOnline).thenReturn(false);
      when(() => mockStorage.saveTodo(any())).thenAnswer((_) async {});

      // Act
      await offlineService.saveTodo(todo);

      // Assert
      verify(() => mockStorage.saveTodo(todo)).called(1);
      verifyNever(() => mockStorage.syncToServer(any()));
    });

    test('syncs pending todos when coming back online', () async {
      // Arrange
      final pendingTodos = TodoFactory.createList(count: 3);
      when(() => mockConnectivity.isOnline).thenReturn(true);
      when(() => mockStorage.getPendingTodos()).thenAnswer((_) async => pendingTodos);
      when(() => mockStorage.syncToServer(any())).thenAnswer((_) async {});
      when(() => mockStorage.clearPending()).thenAnswer((_) async {});

      // Act
      await offlineService.syncPendingChanges();

      // Assert
      verify(() => mockStorage.getPendingTodos()).called(1);
      verify(() => mockStorage.syncToServer(any())).called(3);
      verify(() => mockStorage.clearPending()).called(1);
    });

    test('handles sync conflicts gracefully', () async {
      // Arrange
      final localTodo = TodoFactory.create(id: '1', title: 'Local Version');
      final serverTodo = TodoFactory.create(id: '1', title: 'Server Version');
      
      when(() => mockStorage.getConflicts()).thenAnswer((_) async => [
        ConflictPair(local: localTodo, server: serverTodo),
      ]);
      when(() => mockStorage.resolveConflict(any(), any())).thenAnswer((_) async {});

      // Act
      await offlineService.resolveConflicts(ConflictResolution.useServer);

      // Assert
      verify(() => mockStorage.resolveConflict(any(), serverTodo)).called(1);
    });

    test('queues operations when offline', () async {
      // Arrange
      final todo = TodoFactory.create();
      when(() => mockConnectivity.isOnline).thenReturn(false);
      when(() => mockStorage.queueOperation(any())).thenAnswer((_) async {});

      // Act
      await offlineService.deleteTodo(todo.id);

      // Assert
      verify(() => mockStorage.queueOperation(
        argThat(predicate<OfflineOperation>((op) => 
          op.type == OperationType.delete && op.todoId == todo.id)),
      )).called(1);
    });
  });
}
```

### Testing Riverpod 3.0 Offline Features

```dart
// test/providers/offline_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/offline_todo_provider.dart';

void main() {
  group('Offline Todo Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) => 
            Stream.value(ConnectivityResult.none)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('provider pauses when offline', () async {
      // The provider should automatically pause when offline
      final provider = container.read(offlineTodosProvider.notifier);
      
      // Verify provider is paused
      expect(provider.isPaused, true);
      
      // Attempt to add todo
      final todo = TodoFactory.create();
      await provider.addTodo(todo);
      
      // Should be queued locally
      final queuedOperations = container.read(queuedOperationsProvider);
      expect(queuedOperations.value, isNotEmpty);
    });

    test('provider resumes and syncs when online', () async {
      // Start offline
      container.updateOverrides([
        connectivityProvider.overrideWith((ref) => 
          Stream.value(ConnectivityResult.wifi)),
      ]);

      final provider = container.read(offlineTodosProvider.notifier);
      
      // Verify provider resumes
      expect(provider.isPaused, false);
      
      // Should trigger sync
      await container.pump();
      
      final syncState = container.read(syncStatusProvider);
      expect(syncState.value, SyncStatus.syncing);
    });

    test('handles automatic retry on failure', () async {
      final mockRepository = MockTodoRepository();
      container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Simulate network failure then success
      when(() => mockRepository.getTodos())
          .thenThrow(const SocketException('Network error'))
          .thenAnswer((_) async => TodoFactory.createList());

      final provider = container.read(todosProvider.notifier);
      
      // First attempt should fail and schedule retry
      await provider.loadTodos();
      
      // Wait for retry
      await Future.delayed(const Duration(seconds: 2));
      
      // Should eventually succeed
      final state = container.read(todosProvider);
      expect(state.hasValue, true);
    });
  });
}
```

## Best Practices

### 1. Modern Test Naming (2025)
- Use descriptive test names that explain the scenario
- Include context, action, and expected outcome
- Use natural language for BDD scenarios

```dart
// Good: Descriptive and clear
test('should create todo with validation when user provides valid input', () {});
test('should show error message when network request fails', () {});
test('should persist todo locally when device is offline', () {});

// BDD style for complex scenarios
test('given user is offline when creating todo then saves locally and syncs when online', () {});
```

### 2. Test Organization and Structure
- Use consistent file structure with clear separation
- Group related tests logically
- Use `setUpAll`, `setUp`, `tearDown`, and `tearDownAll` appropriately
- Keep tests independent and deterministic

```dart
group('TodoRepository', () {
  late TodoRepository repository;
  late MockSupabaseClient mockClient;

  setUpAll(() {
    // One-time setup for the entire group
    registerFallbackValue(TodoFactory.create());
  });

  setUp(() {
    // Setup before each test
    mockClient = MockSupabaseClient();
    repository = TodoRepositoryImpl(mockClient);
  });

  tearDown(() {
    // Cleanup after each test
    reset(mockClient);
  });

  group('when online', () {
    // Nested groups for different contexts
  });

  group('when offline', () {
    // Different context tests
  });
});
```

### 3. Modern Assertion Patterns
- Use specific matchers for better error messages
- Combine multiple assertions when testing complex objects
- Use custom matchers for domain-specific assertions

```dart
// Good: Specific and informative
expect(result, isA<List<Todo>>());
expect(result.length, 3);
expect(result.every((todo) => todo.isCompleted), false);

// Better: Custom matcher
expect(result, isListOfIncompleteTodos(length: 3));

// Best: Multiple related assertions
expect(result, allOf([
  isA<List<Todo>>(),
  hasLength(3),
  everyElement(predicate<Todo>((todo) => !todo.isCompleted)),
]));
```

### 4. Effective Mocking Strategies
- Mock at the right level (services, not models)
- Use behavior verification, not just state verification
- Keep mocks simple and focused on the test scenario

```dart
// Good: Mock behavior, verify interactions
when(() => mockRepository.createTodo(any()))
    .thenAnswer((_) async => TodoFactory.create());

await service.addTodo('New Todo');

verify(() => mockRepository.createTodo(
  argThat(predicate<Todo>((todo) => todo.title == 'New Todo')),
)).called(1);
```

### 5. Performance and Reliability
- Keep tests fast (< 100ms for unit tests)
- Avoid `pumpAndSettle` in widget tests when possible
- Use `tester.pump()` with specific durations for animations
- Implement proper timeout handling

```dart
// Good: Controlled timing
await tester.pump(const Duration(milliseconds: 300));
expect(find.byType(AnimatedWidget), findsOneWidget);

// Better: Wait for specific conditions
await tester.pumpAndSettle(const Duration(seconds: 1));
```

### 6. Test Data Management
- Use factories for consistent test data
- Avoid hardcoded values in tests
- Create realistic but minimal test data

```dart
// Good: Use factories
final todo = TodoFactory.create(title: 'Specific test case');

// Better: Builder pattern for complex scenarios
final todo = TodoBuilder()
    .withTitle('Complex todo')
    .withDueDate(DateTime.now().add(Duration(days: 1)))
    .withTags(['urgent', 'work'])
    .build();
```

### 7. Error Testing and Edge Cases
- Test error conditions explicitly
- Cover edge cases and boundary conditions
- Test null safety and validation

```dart
test('should handle null input gracefully', () {
  expect(() => service.processInput(null), throwsArgumentError);
});

test('should validate email format', () {
  expect(EmailValidator.isValid('invalid-email'), false);
  expect(EmailValidator.isValid('valid@email.com'), true);
});
```

### 8. Integration with CI/CD
- Ensure tests are deterministic and don't depend on external services
- Use appropriate test timeouts
- Generate meaningful test reports
- Implement proper test parallelization

### 9. Accessibility Testing
- Include accessibility tests in widget testing
- Test keyboard navigation and screen reader support
- Verify semantic labels and focus management

```dart
testWidgets('should support keyboard navigation', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  expect(tester.binding.focusManager.primaryFocus, isNotNull);
  
  expect(find.bySemanticsLabel('Add new todo'), findsOneWidget);
});
```

### 10. Maintenance and Documentation
- Keep tests up to date with code changes
- Document complex test scenarios
- Regular test review and refactoring
- Remove or fix flaky tests immediately
- Maintain test coverage reports and trends

```dart
/// Tests the complex todo synchronization logic between local storage
/// and remote server, including conflict resolution and retry mechanisms.
/// 
/// This test covers the following scenarios:
/// 1. Initial sync from server
/// 2. Local changes while offline
/// 3. Conflict detection and resolution
/// 4. Retry logic for failed operations
group('Todo Synchronization', () {
  // Test implementation
});
```
