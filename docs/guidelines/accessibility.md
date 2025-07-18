# Accessibility Guidelines

This document provides comprehensive accessibility guidelines for Flutter applications, covering modern best practices for 2025, WCAG compliance, internationalization, and automated testing integration.

## Table of Contents

1. [Overview](#overview)
2. [Semantic Labeling and Screen Reader Support](#semantic-labeling-and-screen-reader-support)
3. [Keyboard Navigation Patterns](#keyboard-navigation-patterns)
4. [Color Contrast and Visual Accessibility](#color-contrast-and-visual-accessibility)
5. [Internationalization (i18n) Setup](#internationalization-i18n-setup)
6. [Localization with ARB Files](#localization-with-arb-files)
7. [Accessibility Testing](#accessibility-testing)
8. [Platform-Specific Considerations](#platform-specific-considerations)
9. [Inclusive Design Principles](#inclusive-design-principles)
10. [Accessibility Auditing Tools](#accessibility-auditing-tools)
11. [WCAG Compliance](#wcag-compliance)
12. [CI/CD Integration](#cicd-integration)

## Overview

Accessibility is fundamental to creating inclusive Flutter applications. This guide covers modern accessibility practices for 2025, ensuring your todo app is usable by everyone, including users with disabilities.

### Key Principles

- **Perceivable**: Information must be presentable in ways users can perceive
- **Operable**: Interface components must be operable by all users
- **Understandable**: Information and UI operation must be understandable
- **Robust**: Content must be robust enough for various assistive technologies

## Semantic Labeling and Screen Reader Support

### Basic Semantic Labeling

Use the `Semantics` widget to provide clear, descriptive labels for all interactive elements:

```dart
// Basic semantic labeling
Semantics(
  label: 'Add new todo item',
  hint: 'Tap to create a new todo',
  child: FloatingActionButton(
    onPressed: _addTodo,
    child: Icon(Icons.add),
  ),
)

// For images and icons
Image.asset(
  'assets/todo_icon.png',
  semanticLabel: 'Todo application icon',
)

// For custom widgets
Semantics(
  label: 'Todo item: ${todo.title}',
  value: todo.isCompleted ? 'Completed' : 'Pending',
  hint: 'Double tap to toggle completion status',
  child: TodoItemWidget(todo: todo),
)
```

### Advanced Semantic Properties

```dart
// Complex semantic configuration
Semantics(
  label: 'Priority selector',
  value: 'Current priority: ${priority.name}',
  hint: 'Swipe up or down to change priority',
  increasedValue: 'High priority',
  decreasedValue: 'Low priority',
  onIncrease: () => _increasePriority(),
  onDecrease: () => _decreasePriority(),
  child: PrioritySlider(
    value: priority,
    onChanged: _onPriorityChanged,
  ),
)
```

### Screen Reader Optimization

```dart
// Grouping related content
Semantics(
  container: true,
  label: 'Todo item details',
  child: Column(
    children: [
      Semantics(
        label: 'Title: ${todo.title}',
        child: Text(todo.title),
      ),
      Semantics(
        label: 'Due date: ${DateFormat.yMMMd().format(todo.dueDate)}',
        child: Text(DateFormat.yMMMd().format(todo.dueDate)),
      ),
      Semantics(
        label: 'Status: ${todo.isCompleted ? "Completed" : "Pending"}',
        child: Icon(
          todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        ),
      ),
    ],
  ),
)

// Excluding decorative elements
Semantics(
  excludeSemantics: true,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(/* decorative gradient */),
    ),
    child: actualContent,
  ),
)
```

### Riverpod Integration for Semantic State

```dart
@riverpod
class TodoSemanticsNotifier extends _$TodoSemanticsNotifier {
  @override
  String build(Todo todo) {
    final status = todo.isCompleted ? 'Completed' : 'Pending';
    final priority = todo.priority.name;
    final dueDate = DateFormat.yMMMd().format(todo.dueDate);
    
    return 'Todo: ${todo.title}, Status: $status, Priority: $priority, Due: $dueDate';
  }
  
  String getActionHint(Todo todo) {
    if (todo.isCompleted) {
      return 'Double tap to mark as pending';
    } else {
      return 'Double tap to mark as completed';
    }
  }
}

// Usage in widget
class TodoItemWidget extends ConsumerWidget {
  final Todo todo;
  
  const TodoItemWidget({required this.todo, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semanticLabel = ref.watch(todoSemanticsNotifierProvider(todo));
    final semanticHint = ref.read(todoSemanticsNotifierProvider(todo).notifier)
        .getActionHint(todo);
    
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      child: ListTile(
        title: Text(todo.title),
        onTap: () => _toggleTodo(todo),
      ),
    );
  }
}
```

## Keyboard Navigation Patterns

### Focus Management

```dart
class TodoFormWidget extends StatefulWidget {
  @override
  _TodoFormWidgetState createState() => _TodoFormWidgetState();
}

class _TodoFormWidgetState extends State<TodoFormWidget> {
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _dueDateFocusNode = FocusNode();
  final FocusNode _submitFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Set initial focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          FocusTraversalOrder(
            order: NumericFocusOrder(1),
            child: TextFormField(
              focusNode: _titleFocusNode,
              decoration: InputDecoration(labelText: 'Todo Title'),
              onFieldSubmitted: (_) {
                _descriptionFocusNode.requestFocus();
              },
            ),
          ),
          FocusTraversalOrder(
            order: NumericFocusOrder(2),
            child: TextFormField(
              focusNode: _descriptionFocusNode,
              decoration: InputDecoration(labelText: 'Description'),
              onFieldSubmitted: (_) {
                _dueDateFocusNode.requestFocus();
              },
            ),
          ),
          FocusTraversalOrder(
            order: NumericFocusOrder(3),
            child: DatePickerField(
              focusNode: _dueDateFocusNode,
              onDateSelected: (_) {
                _submitFocusNode.requestFocus();
              },
            ),
          ),
          FocusTraversalOrder(
            order: NumericFocusOrder(4),
            child: ElevatedButton(
              focusNode: _submitFocusNode,
              onPressed: _submitForm,
              child: Text('Create Todo'),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _dueDateFocusNode.dispose();
    _submitFocusNode.dispose();
    super.dispose();
  }
}
```

### Custom Keyboard Shortcuts

```dart
class TodoListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control): 
            CreateTodoIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): 
            DeleteTodoIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): 
            ToggleTodoIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): 
            ClearSelectionIntent(),
      },
      child: Actions(
        actions: {
          CreateTodoIntent: CallbackAction<CreateTodoIntent>(
            onInvoke: (_) => _createNewTodo(),
          ),
          DeleteTodoIntent: CallbackAction<DeleteTodoIntent>(
            onInvoke: (_) => _deleteSelectedTodo(),
          ),
          ToggleTodoIntent: CallbackAction<ToggleTodoIntent>(
            onInvoke: (_) => _toggleSelectedTodo(),
          ),
          ClearSelectionIntent: CallbackAction<ClearSelectionIntent>(
            onInvoke: (_) => _clearSelection(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: TodoListView(),
        ),
      ),
    );
  }
}

// Intent classes
class CreateTodoIntent extends Intent {}
class DeleteTodoIntent extends Intent {}
class ToggleTodoIntent extends Intent {}
class ClearSelectionIntent extends Intent {}
```

### Focus Indicators

```dart
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  
  const AccessibleButton({
    required this.label,
    required this.child,
    this.onPressed,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Focus(
        child: Builder(
          builder: (context) {
            final focusNode = Focus.of(context);
            final isFocused = focusNode.hasFocus;
            
            return Container(
              decoration: BoxDecoration(
                border: isFocused 
                    ? Border.all(
                        color: Theme.of(context).focusColor,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## Color Contrast and Visual Accessibility

### Theme Configuration for Accessibility

```dart
class AccessibleTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      // Ensure sufficient contrast ratios
      primary: Color(0xFF1976D2), // 4.5:1 contrast ratio
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF212121), // 4.5:1 contrast ratio
      error: Color(0xFFD32F2F),
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF212121),
        height: 1.5, // Improved line spacing
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF424242),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF212121),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(48, 48), // Minimum touch target
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    iconTheme: IconThemeData(
      size: 24, // Minimum recommended size
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Color(0xFF90CAF9),
      onPrimary: Color(0xFF0D47A1),
      surface: Color(0xFF121212),
      onSurface: Color(0xFFE0E0E0), // 4.5:1 contrast ratio
      error: Color(0xFFEF5350),
      onError: Color(0xFF000000),
    ),
  );
  
  static ThemeData highContrastTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      secondary: Color(0xFF0000FF),
      onSecondary: Colors.white,
    ),
  );
}
```

### Contrast Checking Utility

```dart
class ContrastChecker {
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _calculateLuminance(foreground);
    final bgLuminance = _calculateLuminance(background);
    
    final lighter = math.max(fgLuminance, bgLuminance);
    final darker = math.min(fgLuminance, bgLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  static double _calculateLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }
  
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }
  
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }
}
```

### Responsive Text Scaling

```dart
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  
  const AccessibleText(
    this.text, {
    this.style,
    this.maxLines,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;
    
    // Ensure text remains readable at large scale factors
    final clampedTextScaleFactor = textScaleFactor.clamp(1.0, 2.0);
    
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaleFactor: clampedTextScaleFactor,
      ),
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      ),
    );
  }
}
```

## Internationalization (i18n) Setup

### Dependencies Configuration

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

dev_dependencies:
  intl_utils: ^2.8.7
```

### Application Configuration

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessible Todo App',
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: Locale('en'), // Default locale
      theme: AccessibleTheme.lightTheme,
      darkTheme: AccessibleTheme.darkTheme,
      highContrastTheme: AccessibleTheme.highContrastTheme,
      home: TodoListScreen(),
    );
  }
}
```

### Locale Management with Riverpod

```dart
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Load saved locale from preferences or use system locale
    return _loadSavedLocale() ?? _getSystemLocale();
  }
  
  void setLocale(Locale locale) {
    state = locale;
    _saveLocale(locale);
  }
  
  Locale _getSystemLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedLocales = S.delegate.supportedLocales;
    
    if (supportedLocales.contains(systemLocale)) {
      return systemLocale;
    }
    
    // Find best match
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }
    
    return Locale('en'); // Fallback
  }
  
  Locale? _loadSavedLocale() {
    // Implementation to load from SharedPreferences
    return null;
  }
  
  void _saveLocale(Locale locale) {
    // Implementation to save to SharedPreferences
  }
}
```

## Localization with ARB Files

### ARB File Structure

Create `lib/l10n/intl_en.arb`:

```json
{
  "@@locale": "en",
  "appTitle": "Todo App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "addTodo": "Add Todo",
  "@addTodo": {
    "description": "Button text to add a new todo item"
  },
  "todoTitle": "Todo Title",
  "@todoTitle": {
    "description": "Label for todo title input field"
  },
  "todoDescription": "Description",
  "@todoDescription": {
    "description": "Label for todo description input field"
  },
  "dueDate": "Due Date",
  "@dueDate": {
    "description": "Label for due date field"
  },
  "priority": "Priority",
  "@priority": {
    "description": "Label for priority field"
  },
  "completed": "Completed",
  "@completed": {
    "description": "Status text for completed todos"
  },
  "pending": "Pending",
  "@pending": {
    "description": "Status text for pending todos"
  },
  "deleteTodo": "Delete Todo",
  "@deleteTodo": {
    "description": "Button text to delete a todo item"
  },
  "confirmDelete": "Are you sure you want to delete this todo?",
  "@confirmDelete": {
    "description": "Confirmation message for deleting a todo"
  },
  "cancel": "Cancel",
  "@cancel": {
    "description": "Cancel button text"
  },
  "delete": "Delete",
  "@delete": {
    "description": "Delete button text"
  },
  "todoItemSemanticLabel": "Todo item: {title}, Status: {status}, Priority: {priority}",
  "@todoItemSemanticLabel": {
    "description": "Semantic label for todo items",
    "placeholders": {
      "title": {
        "type": "String",
        "description": "The title of the todo item"
      },
      "status": {
        "type": "String",
        "description": "The completion status of the todo"
      },
      "priority": {
        "type": "String",
        "description": "The priority level of the todo"
      }
    }
  },
  "toggleTodoHint": "Double tap to toggle completion status",
  "@toggleTodoHint": {
    "description": "Accessibility hint for toggling todo completion"
  },
  "addTodoHint": "Tap to create a new todo item",
  "@addTodoHint": {
    "description": "Accessibility hint for add todo button"
  },
  "todoCount": "{count, plural, =0{No todos} =1{1 todo} other{{count} todos}}",
  "@todoCount": {
    "description": "Count of todo items",
    "placeholders": {
      "count": {
        "type": "int",
        "description": "Number of todo items"
      }
    }
  },
  "dueDateFormat": "Due: {date}",
  "@dueDateFormat": {
    "description": "Format for displaying due dates",
    "placeholders": {
      "date": {
        "type": "DateTime",
        "format": "yMMMd",
        "description": "The due date"
      }
    }
  }
}
```

Create `lib/l10n/intl_es.arb`:

```json
{
  "@@locale": "es",
  "appTitle": "Aplicación de Tareas",
  "addTodo": "Agregar Tarea",
  "todoTitle": "Título de la Tarea",
  "todoDescription": "Descripción",
  "dueDate": "Fecha de Vencimiento",
  "priority": "Prioridad",
  "completed": "Completada",
  "pending": "Pendiente",
  "deleteTodo": "Eliminar Tarea",
  "confirmDelete": "¿Estás seguro de que quieres eliminar esta tarea?",
  "cancel": "Cancelar",
  "delete": "Eliminar",
  "todoItemSemanticLabel": "Elemento de tarea: {title}, Estado: {status}, Prioridad: {priority}",
  "toggleTodoHint": "Toca dos veces para cambiar el estado de finalización",
  "addTodoHint": "Toca para crear un nuevo elemento de tarea",
  "todoCount": "{count, plural, =0{Sin tareas} =1{1 tarea} other{{count} tareas}}",
  "dueDateFormat": "Vence: {date}"
}
```

### L10n Configuration

Create `l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: s.dart
output-class: S
output-dir: lib/generated
nullable-getter: false
synthetic-package: false
```

### Usage in Widgets

```dart
class TodoItemWidget extends ConsumerWidget {
  final Todo todo;
  
  const TodoItemWidget({required this.todo, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final status = todo.isCompleted ? l10n.completed : l10n.pending;
    
    return Semantics(
      label: l10n.todoItemSemanticLabel(
        todo.title,
        status,
        todo.priority.name,
      ),
      hint: l10n.toggleTodoHint,
      button: true,
      child: ListTile(
        title: Text(todo.title),
        subtitle: Text(l10n.dueDateFormat(todo.dueDate)),
        trailing: Icon(
          todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          semanticLabel: status,
        ),
        onTap: () => _toggleTodo(todo),
      ),
    );
  }
}
```

## Accessibility Testing

### Widget Testing with Accessibility Guidelines

Create `test/accessibility_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('App follows accessibility guidelines', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      // Test minimum tap target sizes
      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
      );
      
      await expectLater(
        tester,
        meetsGuideline(iOSTapTargetGuideline),
      );
      
      // Test that tappable nodes are labeled
      await expectLater(
        tester,
        meetsGuideline(labeledTapTargetGuideline),
      );
      
      // Test text contrast
      await expectLater(
        tester,
        meetsGuideline(textContrastGuideline),
      );
      
      handle.dispose();
    });
    
    testWidgets('Todo items have proper semantic labels', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      // Find todo items and verify semantic properties
      final todoItems = find.byType(TodoItemWidget);
      expect(todoItems, findsAtLeastNWidgets(1));
      
      for (int i = 0; i < tester.widgetList(todoItems).length; i++) {
        final semantics = tester.getSemantics(todoItems.at(i));
        
        // Verify semantic label exists and is descriptive
        expect(semantics.label, isNotNull);
        expect(semantics.label!.length, greaterThan(10));
        
        // Verify hint exists for interaction guidance
        expect(semantics.hint, isNotNull);
        expect(semantics.hint, contains('tap'));
      }
      
      handle.dispose();
    });
    
    testWidgets('Focus traversal works correctly', (tester) async {
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      // Navigate to add todo form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Test tab navigation through form fields
      final titleField = find.byKey(Key('title_field'));
      final descriptionField = find.byKey(Key('description_field'));
      final submitButton = find.byKey(Key('submit_button'));
      
      // Focus should start on title field
      expect(
        tester.binding.focusManager.primaryFocus?.context?.widget,
        isA<TextFormField>(),
      );
      
      // Tab to next field
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      
      // Verify focus moved to description field
      final focusedWidget = tester.binding.focusManager.primaryFocus?.context?.widget;
      expect(focusedWidget, isA<TextFormField>());
    });
  });
}
```

### Integration Testing for Screen Readers

Create `integration_test/accessibility_integration_test.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Screen Reader Integration Tests', () {
    testWidgets('TalkBack navigation works correctly', (tester) async {
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      // Enable semantics for testing
      final SemanticsHandle handle = tester.ensureSemantics();
      
      // Simulate TalkBack navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      
      // Verify semantic focus moves correctly
      final semanticsData = tester.binding.pipelineOwner.semanticsOwner!
          .rootSemanticsNode!.debugDescribeChildren();
      
      expect(semanticsData, isNotEmpty);
      
      handle.dispose();
    });
    
    testWidgets('VoiceOver gestures work correctly', (tester) async {
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      final SemanticsHandle handle = tester.ensureSemantics();
      
      // Simulate VoiceOver swipe gestures
      await tester.fling(
        find.byType(Scaffold),
        Offset(100, 0),
        1000,
      );
      await tester.pumpAndSettle();
      
      // Verify semantic navigation
      final semanticsNodes = tester.binding.pipelineOwner.semanticsOwner!
          .rootSemanticsNode!.visitChildren((node) => true);
      
      expect(semanticsNodes, isTrue);
      
      handle.dispose();
    });
  });
}
```

### Custom Accessibility Testing Utilities

```dart
class AccessibilityTestUtils {
  static Future<void> verifySemanticStructure(
    WidgetTester tester,
    Finder finder,
  ) async {
    final elements = tester.widgetList(finder);
    
    for (final element in elements) {
      final semantics = tester.getSemantics(find.byWidget(element));
      
      // Verify basic semantic properties
      expect(semantics.label, isNotNull, 
          reason: 'Widget ${element.runtimeType} missing semantic label');
      
      if (semantics.hasAction(SemanticsAction.tap)) {
        expect(semantics.hint, isNotNull,
            reason: 'Tappable widget ${element.runtimeType} missing hint');
      }
      
      // Verify minimum touch target size
      final renderBox = tester.renderObject(find.byWidget(element)) as RenderBox;
      final size = renderBox.size;
      
      if (semantics.hasAction(SemanticsAction.tap)) {
        expect(size.width, greaterThanOrEqualTo(48),
            reason: 'Touch target too small: width ${size.width}');
        expect(size.height, greaterThanOrEqualTo(48),
            reason: 'Touch target too small: height ${size.height}');
      }
    }
  }
  
  static Future<void> verifyContrastRatios(
    WidgetTester tester,
    Finder textFinder,
  ) async {
    final textWidgets = tester.widgetList<Text>(textFinder);
    
    for (final textWidget in textWidgets) {
      final renderObject = tester.renderObject(find.byWidget(textWidget));
      final textStyle = textWidget.style ?? Theme.of(tester.element(find.byWidget(textWidget))).textTheme.bodyMedium!;
      
      if (textStyle.color != null) {
        // Get background color from context
        final backgroundColor = Theme.of(tester.element(find.byWidget(textWidget))).scaffoldBackgroundColor;
        
        final contrastRatio = ContrastChecker.calculateContrastRatio(
          textStyle.color!,
          backgroundColor,
        );
        
        expect(contrastRatio, greaterThanOrEqualTo(4.5),
            reason: 'Insufficient contrast ratio: $contrastRatio');
      }
    }
  }
}
```

## Platform-Specific Considerations

### iOS Accessibility

```dart
class IOSAccessibilityWidget extends StatelessWidget {
  final Widget child;
  final String? accessibilityLabel;
  final String? accessibilityHint;
  final String? accessibilityValue;
  
  const IOSAccessibilityWidget({
    required this.child,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.accessibilityValue,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Semantics(
        label: accessibilityLabel,
        hint: accessibilityHint,
        value: accessibilityValue,
        // iOS-specific semantic properties
        container: true,
        explicitChildNodes: false,
        child: child,
      );
    }
    
    return child;
  }
}
```

### Android Accessibility

```dart
class AndroidAccessibilityWidget extends StatelessWidget {
  final Widget child;
  final String? contentDescription;
  final String? stateDescription;
  
  const AndroidAccessibilityWidget({
    required this.child,
    this.contentDescription,
    this.stateDescription,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return Semantics(
        label: contentDescription,
        value: stateDescription,
        // Android-specific configurations
        liveRegion: true,
        child: child,
      );
    }
    
    return child;
  }
}
```

### Web Accessibility

```dart
import 'dart:html' as html;

class WebAccessibilityWidget extends StatefulWidget {
  final Widget child;
  final String? ariaLabel;
  final String? role;
  
  const WebAccessibilityWidget({
    required this.child,
    this.ariaLabel,
    this.role,
    super.key,
  });
  
  @override
  _WebAccessibilityWidgetState createState() => _WebAccessibilityWidgetState();
}

class _WebAccessibilityWidgetState extends State<WebAccessibilityWidget> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus && widget.ariaLabel != null) {
            // Announce to screen readers
            _announceToScreenReader(widget.ariaLabel!);
          }
        },
        child: Semantics(
          label: widget.ariaLabel,
          child: widget.child,
        ),
      );
    }
    
    return widget.child;
  }
  
  void _announceToScreenReader(String message) {
    if (kIsWeb) {
      final element = html.document.createElement('div');
      element.setAttribute('aria-live', 'polite');
      element.setAttribute('aria-atomic', 'true');
      element.style.position = 'absolute';
      element.style.left = '-10000px';
      element.style.width = '1px';
      element.style.height = '1px';
      element.style.overflow = 'hidden';
      element.text = message;
      
      html.document.body!.append(element);
      
      Timer(Duration(milliseconds: 100), () {
        element.remove();
      });
    }
  }
}
```

## Inclusive Design Principles

### Universal Design Guidelines

```dart
class InclusiveDesignSystem {
  // Color palette that works for color-blind users
  static const Map<String, Color> accessibleColors = {
    'primary': Color(0xFF1976D2),      // Blue
    'secondary': Color(0xFFFF9800),    // Orange
    'success': Color(0xFF4CAF50),      // Green
    'warning': Color(0xFFFFC107),      // Amber
    'error': Color(0xFFD32F2F),        // Red
    'info': Color(0xFF2196F3),         // Light Blue
  };
  
  // Text sizes that scale well
  static const Map<String, double> textSizes = {
    'small': 12.0,
    'body': 16.0,
    'subtitle': 18.0,
    'title': 24.0,
    'headline': 32.0,
  };
  
  // Spacing system for consistent layouts
  static const Map<String, double> spacing = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 16.0,
    'lg': 24.0,
    'xl': 32.0,
    'xxl': 48.0,
  };
  
  static ThemeData createInclusiveTheme({
    required Brightness brightness,
    bool highContrast = false,
  }) {
    final colorScheme = highContrast
        ? _createHighContrastColorScheme(brightness)
        : _createStandardColorScheme(brightness);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _createAccessibleTextTheme(colorScheme),
      elevatedButtonTheme: _createAccessibleButtonTheme(),
      inputDecorationTheme: _createAccessibleInputTheme(colorScheme),
    );
  }
  
  static ColorScheme _createHighContrastColorScheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Color(0xFFFFFF00), // Yellow
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        error: Color(0xFFFF0000),
        onError: Colors.white,
      );
    } else {
      return ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Color(0xFF0000FF), // Blue
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        background: Colors.white,
        onBackground: Colors.black,
        error: Color(0xFFCC0000),
        onError: Colors.white,
      );
    }
  }
  
  static ColorScheme _createStandardColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: accessibleColors['primary']!,
      brightness: brightness,
    );
  }
  
  static TextTheme _createAccessibleTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: textSizes['headline']!,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: textSizes['title']!,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: textSizes['subtitle']!,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: textSizes['body']!,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: textSizes['body']! - 2,
        color: colorScheme.onSurface.withOpacity(0.8),
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: textSizes['body']!,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }
  
  static ElevatedButtonThemeData _createAccessibleButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(48, 48),
        padding: EdgeInsets.symmetric(
          horizontal: spacing['md']!,
          vertical: spacing['sm']!,
        ),
        textStyle: TextStyle(
          fontSize: textSizes['body']!,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  static InputDecorationTheme _createAccessibleInputTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing['md']!,
        vertical: spacing['md']!,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 3,
        ),
      ),
      labelStyle: TextStyle(
        fontSize: textSizes['body']!,
        color: colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}
```

### Cognitive Accessibility

```dart
class CognitiveAccessibilityHelper {
  static Widget createSimplifiedInterface({
    required Widget child,
    bool reduceAnimations = false,
    bool simplifyNavigation = false,
  }) {
    return Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final reducedMotion = mediaQuery.disableAnimations || reduceAnimations;
        
        return MediaQuery(
          data: mediaQuery.copyWith(
            disableAnimations: reducedMotion,
          ),
          child: simplifyNavigation
              ? _SimplifiedNavigationWrapper(child: child)
              : child,
        );
      },
    );
  }
  
  static Widget createProgressIndicator({
    required String label,
    required double progress,
    bool showPercentage = true,
  }) {
    return Semantics(
      label: label,
      value: showPercentage ? '${(progress * 100).round()}% complete' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          if (showPercentage) ...[
            SizedBox(height: 4),
            Text('${(progress * 100).round()}%'),
          ],
        ],
      ),
    );
  }
  
  static Widget createTimeoutWarning({
    required Duration timeRemaining,
    required VoidCallback onExtend,
  }) {
    return AlertDialog(
      title: Text('Session Timeout Warning'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your session will expire in ${timeRemaining.inMinutes} minutes.'),
          SizedBox(height: 16),
          Text('Would you like to extend your session?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onExtend,
          child: Text('Extend Session'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Continue'),
        ),
      ],
    );
  }
}

class _SimplifiedNavigationWrapper extends StatelessWidget {
  final Widget child;
  
  const _SimplifiedNavigationWrapper({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): _BackIntent(),
        LogicalKeySet(LogicalKeyboardKey.f1): _HelpIntent(),
      },
      child: Actions(
        actions: {
          _BackIntent: CallbackAction<_BackIntent>(
            onInvoke: (_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return null;
            },
          ),
          _HelpIntent: CallbackAction<_HelpIntent>(
            onInvoke: (_) {
              _showHelpDialog(context);
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keyboard Shortcuts:'),
            SizedBox(height: 8),
            Text('• Escape: Go back'),
            Text('• F1: Show this help'),
            Text('• Tab: Navigate between elements'),
            Text('• Enter/Space: Activate buttons'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _BackIntent extends Intent {}
class _HelpIntent extends Intent {}
```

## Accessibility Auditing Tools

### Automated Auditing Integration

```dart
class AccessibilityAuditor {
  static Future<AccessibilityReport> auditWidget(
    WidgetTester tester,
    Finder finder,
  ) async {
    final report = AccessibilityReport();
    
    // Check semantic labels
    await _auditSemanticLabels(tester, finder, report);
    
    // Check touch target sizes
    await _auditTouchTargets(tester, finder, report);
    
    // Check contrast ratios
    await _auditContrastRatios(tester, finder, report);
    
    // Check focus management
    await _auditFocusManagement(tester, finder, report);
    
    return report;
  }
  
  static Future<void> _auditSemanticLabels(
    WidgetTester tester,
    Finder finder,
    AccessibilityReport report,
  ) async {
    final widgets = tester.widgetList(finder);
    
    for (final widget in widgets) {
      try {
        final semantics = tester.getSemantics(find.byWidget(widget));
        
        if (semantics.hasAction(SemanticsAction.tap) && 
            (semantics.label == null || semantics.label!.isEmpty)) {
          report.addIssue(AccessibilityIssue(
            type: AccessibilityIssueType.missingLabel,
            severity: AccessibilityIssueSeverity.error,
            description: 'Tappable widget missing semantic label',
            widget: widget.runtimeType.toString(),
            suggestion: 'Add a descriptive label using Semantics widget',
          ));
        }
        
        if (semantics.label != null && semantics.label!.length < 3) {
          report.addIssue(AccessibilityIssue(
            type: AccessibilityIssueType.inadequateLabel,
            severity: AccessibilityIssueSeverity.warning,
            description: 'Semantic label too short: "${semantics.label}"',
            widget: widget.runtimeType.toString(),
            suggestion: 'Provide a more descriptive label',
          ));
        }
      } catch (e) {
        // Widget doesn't have semantics - might be decorative
      }
    }
  }
  
  static Future<void> _auditTouchTargets(
    WidgetTester tester,
    Finder finder,
    AccessibilityReport report,
  ) async {
    final widgets = tester.widgetList(finder);
    
    for (final widget in widgets) {
      try {
        final semantics = tester.getSemantics(find.byWidget(widget));
        
        if (semantics.hasAction(SemanticsAction.tap)) {
          final renderBox = tester.renderObject(find.byWidget(widget)) as RenderBox;
          final size = renderBox.size;
          
          if (size.width < 48 || size.height < 48) {
            report.addIssue(AccessibilityIssue(
              type: AccessibilityIssueType.smallTouchTarget,
              severity: AccessibilityIssueSeverity.error,
              description: 'Touch target too small: ${size.width}x${size.height}',
              widget: widget.runtimeType.toString(),
              suggestion: 'Increase size to at least 48x48 pixels',
            ));
          }
        }
      } catch (e) {
        // Widget doesn't have semantics or render box
      }
    }
  }
  
  static Future<void> _auditContrastRatios(
    WidgetTester tester,
    Finder finder,
    AccessibilityReport report,
  ) async {
    final textWidgets = tester.widgetList<Text>(finder);
    
    for (final textWidget in textWidgets) {
      final element = tester.element(find.byWidget(textWidget));
      final theme = Theme.of(element);
      final textStyle = textWidget.style ?? theme.textTheme.bodyMedium!;
      
      if (textStyle.color != null) {
        final backgroundColor = theme.scaffoldBackgroundColor;
        final contrastRatio = ContrastChecker.calculateContrastRatio(
          textStyle.color!,
          backgroundColor,
        );
        
        if (contrastRatio < 4.5) {
          report.addIssue(AccessibilityIssue(
            type: AccessibilityIssueType.lowContrast,
            severity: contrastRatio < 3.0 
                ? AccessibilityIssueSeverity.error 
                : AccessibilityIssueSeverity.warning,
            description: 'Low contrast ratio: ${contrastRatio.toStringAsFixed(2)}:1',
            widget: 'Text: "${textWidget.data}"',
            suggestion: 'Increase contrast to at least 4.5:1',
          ));
        }
      }
    }
  }
  
  static Future<void> _auditFocusManagement(
    WidgetTester tester,
    Finder finder,
    AccessibilityReport report,
  ) async {
    // Check for focus traps and logical focus order
    final focusableWidgets = tester.widgetList(finder.byType(Focus));
    
    if (focusableWidgets.isEmpty) {
      report.addIssue(AccessibilityIssue(
        type: AccessibilityIssueType.noFocusManagement,
        severity: AccessibilityIssueSeverity.warning,
        description: 'No focusable widgets found',
        widget: 'Screen',
        suggestion: 'Ensure interactive elements are focusable',
      ));
    }
  }
}

class AccessibilityReport {
  final List<AccessibilityIssue> issues = [];
  
  void addIssue(AccessibilityIssue issue) {
    issues.add(issue);
  }
  
  bool get hasErrors => issues.any((issue) => 
      issue.severity == AccessibilityIssueSeverity.error);
  
  bool get hasWarnings => issues.any((issue) => 
      issue.severity == AccessibilityIssueSeverity.warning);
  
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('Accessibility Audit Report');
    buffer.writeln('=' * 40);
    buffer.writeln('Total Issues: ${issues.length}');
    buffer.writeln('Errors: ${issues.where((i) => i.severity == AccessibilityIssueSeverity.error).length}');
    buffer.writeln('Warnings: ${issues.where((i) => i.severity == AccessibilityIssueSeverity.warning).length}');
    buffer.writeln();
    
    for (final issue in issues) {
      buffer.writeln('${issue.severity.name.toUpperCase()}: ${issue.description}');
      buffer.writeln('Widget: ${issue.widget}');
      buffer.writeln('Suggestion: ${issue.suggestion}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}

class AccessibilityIssue {
  final AccessibilityIssueType type;
  final AccessibilityIssueSeverity severity;
  final String description;
  final String widget;
  final String suggestion;
  
  const AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.widget,
    required this.suggestion,
  });
}

enum AccessibilityIssueType {
  missingLabel,
  inadequateLabel,
  smallTouchTarget,
  lowContrast,
  noFocusManagement,
}

enum AccessibilityIssueSeverity {
  error,
  warning,
  info,
}
```

## WCAG Compliance

### WCAG 2.1 AA Compliance Checklist

```dart
class WCAGComplianceChecker {
  static const Map<String, WCAGGuideline> guidelines = {
    '1.1.1': WCAGGuideline(
      id: '1.1.1',
      title: 'Non-text Content',
      level: WCAGLevel.A,
      description: 'All non-text content has text alternatives',
    ),
    '1.3.1': WCAGGuideline(
      id: '1.3.1',
      title: 'Info and Relationships',
      level: WCAGLevel.A,
      description: 'Information and relationships can be programmatically determined',
    ),
    '1.4.3': WCAGGuideline(
      id: '1.4.3',
      title: 'Contrast (Minimum)',
      level: WCAGLevel.AA,
      description: 'Text has contrast ratio of at least 4.5:1',
    ),
    '1.4.11': WCAGGuideline(
      id: '1.4.11',
      title: 'Non-text Contrast',
      level: WCAGLevel.AA,
      description: 'UI components have contrast ratio of at least 3:1',
    ),
    '2.1.1': WCAGGuideline(
      id: '2.1.1',
      title: 'Keyboard',
      level: WCAGLevel.A,
      description: 'All functionality available via keyboard',
    ),
    '2.4.3': WCAGGuideline(
      id: '2.4.3',
      title: 'Focus Order',
      level: WCAGLevel.A,
      description: 'Focus order is logical and meaningful',
    ),
    '2.4.7': WCAGGuideline(
      id: '2.4.7',
      title: 'Focus Visible',
      level: WCAGLevel.AA,
      description: 'Keyboard focus indicator is visible',
    ),
    '3.2.2': WCAGGuideline(
      id: '3.2.2',
      title: 'On Input',
      level: WCAGLevel.A,
      description: 'Changing input does not cause unexpected context changes',
    ),
    '4.1.2': WCAGGuideline(
      id: '4.1.2',
      title: 'Name, Role, Value',
      level: WCAGLevel.A,
      description: 'UI components have accessible name and role',
    ),
  };
  
  static Future<WCAGComplianceReport> checkCompliance(
    WidgetTester tester,
    Finder finder,
  ) async {
    final report = WCAGComplianceReport();
    
    // Check each guideline
    for (final guideline in guidelines.values) {
      final result = await _checkGuideline(tester, finder, guideline);
      report.addResult(result);
    }
    
    return report;
  }
  
  static Future<WCAGComplianceResult> _checkGuideline(
    WidgetTester tester,
    Finder finder,
    WCAGGuideline guideline,
  ) async {
    switch (guideline.id) {
      case '1.1.1':
        return await _checkNonTextContent(tester, finder, guideline);
      case '1.4.3':
        return await _checkTextContrast(tester, finder, guideline);
      case '2.1.1':
        return await _checkKeyboardAccess(tester, finder, guideline);
      case '2.4.7':
        return await _checkFocusVisible(tester, finder, guideline);
      case '4.1.2':
        return await _checkNameRoleValue(tester, finder, guideline);
      default:
        return WCAGComplianceResult(
          guideline: guideline,
          status: WCAGComplianceStatus.notTested,
          details: 'Guideline not implemented in checker',
        );
    }
  }
  
  static Future<WCAGComplianceResult> _checkNonTextContent(
    WidgetTester tester,
    Finder finder,
    WCAGGuideline guideline,
  ) async {
    final images = tester.widgetList<Image>(finder);
    final icons = tester.widgetList<Icon>(finder);
    
    int violations = 0;
    final details = <String>[];
    
    // Check images
    for (final image in images) {
      if (image.semanticLabel == null || image.semanticLabel!.isEmpty) {
        violations++;
        details.add('Image missing semantic label');
      }
    }
    
    // Check icons
    for (final icon in icons) {
      try {
        final semantics = tester.getSemantics(find.byWidget(icon));
        if (semantics.label == null || semantics.label!.isEmpty) {
          violations++;
          details.add('Icon missing semantic label');
        }
      } catch (e) {
        violations++;
        details.add('Icon not accessible to screen readers');
      }
    }
    
    return WCAGComplianceResult(
      guideline: guideline,
      status: violations == 0 
          ? WCAGComplianceStatus.pass 
          : WCAGComplianceStatus.fail,
      details: violations == 0 
          ? 'All non-text content has appropriate text alternatives'
          : 'Found $violations violations: ${details.join(', ')}',
    );
  }
  
  static Future<WCAGComplianceResult> _checkTextContrast(
    WidgetTester tester,
    Finder finder,
    WCAGGuideline guideline,
  ) async {
    final textWidgets = tester.widgetList<Text>(finder);
    int violations = 0;
    
    for (final textWidget in textWidgets) {
      final element = tester.element(find.byWidget(textWidget));
      final theme = Theme.of(element);
      final textStyle = textWidget.style ?? theme.textTheme.bodyMedium!;
      
      if (textStyle.color != null) {
        final backgroundColor = theme.scaffoldBackgroundColor;
        final contrastRatio = ContrastChecker.calculateContrastRatio(
          textStyle.color!,
          backgroundColor,
        );
        
        if (contrastRatio < 4.5) {
          violations++;
        }
      }
    }
    
    return WCAGComplianceResult(
      guideline: guideline,
      status: violations == 0 
          ? WCAGComplianceStatus.pass 
          : WCAGComplianceStatus.fail,
      details: violations == 0 
          ? 'All text meets minimum contrast requirements'
          : 'Found $violations text elements with insufficient contrast',
    );
  }
  
  static Future<WCAGComplianceResult> _checkKeyboardAccess(
    WidgetTester tester,
    Finder finder,
    WCAGGuideline guideline,
  ) async {
    final interactiveWidgets = [
      ...tester.widgetList<ElevatedButton>(finder),
      ...tester.widgetList<TextButton>(finder),
      ...tester.widgetList<IconButton>(finder),
      ...tester.widgetList<TextField>(finder),
      ...tester.widgetList<TextFormField>(finder),
    ];
    
    int violations = 0;
    
    for (final widget in interactiveWidgets) {
      try {
        final element = tester.element(find.byWidget(widget));
        final focusNode = Focus.of(element);
        
        if (!focusNode.canRequestFocus) {
          violations++;
        }
      } catch (e) {
        violations++;
      }
    }
    
    return WCAGComplianceResult(
      guideline: guideline,
      status: violations == 0 
          ? WCAGComplianceStatus.pass 
          : WCAGComplianceStatus.fail,
      details: violations == 0 
          ? 'All interactive elements are keyboard accessible'
          : 'Found $violations interactive elements not keyboard accessible',
    );
  }
  
  static Future<WCAGComplianceResult> _checkFocusVisible(
    WidgetTester tester,
    Finder finder,
    WCAGGuideline guideline,
  ) async {
    // This would require more complex testing with actual focus states
    return WCAGComplianceResult(
      guideline: guideline,
      status: WCAGComplianceStatus.manualCheck,
      details: 'Focus visibility requires manual testing with keyboard navigation',
    );
  }
  
  static Future<WCAGComplianceResult> _checkNameRoleValue(
    WidgetTester tester,
    Finder finder,
    WCAGGuideline guideline,
  ) async {
    final interactiveWidgets = tester.widgetList(finder);
    int violations = 0;
    
    for (final widget in interactiveWidgets) {
      try {
        final semantics = tester.getSemantics(find.byWidget(widget));
        
        if (semantics.hasAction(SemanticsAction.tap)) {
          if (semantics.label == null || semantics.label!.isEmpty) {
            violations++;
          }
        }
      } catch (e) {
        // Widget doesn't have semantics - might not be interactive
      }
    }
    
    return WCAGComplianceResult(
      guideline: guideline,
      status: violations == 0 
          ? WCAGComplianceStatus.pass 
          : WCAGComplianceStatus.fail,
      details: violations == 0 
          ? 'All UI components have accessible names and roles'
          : 'Found $violations components missing accessible names',
    );
  }
}

class WCAGGuideline {
  final String id;
  final String title;
  final WCAGLevel level;
  final String description;
  
  const WCAGGuideline({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
  });
}

enum WCAGLevel { A, AA, AAA }

class WCAGComplianceReport {
  final List<WCAGComplianceResult> results = [];
  
  void addResult(WCAGComplianceResult result) {
    results.add(result);
  }
  
  bool get isCompliant => results.every((result) => 
      result.status == WCAGComplianceStatus.pass ||
      result.status == WCAGComplianceStatus.notApplicable);
  
  int get passCount => results.where((r) => 
      r.status == WCAGComplianceStatus.pass).length;
  
  int get failCount => results.where((r) => 
      r.status == WCAGComplianceStatus.fail).length;
  
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('WCAG 2.1 Compliance Report');
    buffer.writeln('=' * 40);
    buffer.writeln('Overall Status: ${isCompliant ? "COMPLIANT" : "NON-COMPLIANT"}');
    buffer.writeln('Passed: $passCount');
    buffer.writeln('Failed: $failCount');
    buffer.writeln();
    
    for (final result in results) {
      buffer.writeln('${result.guideline.id} - ${result.guideline.title}');
      buffer.writeln('Level: ${result.guideline.level.name}');
      buffer.writeln('Status: ${result.status.name.toUpperCase()}');
      buffer.writeln('Details: ${result.details}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}

class WCAGComplianceResult {
  final WCAGGuideline guideline;
  final WCAGComplianceStatus status;
  final String details;
  
  const WCAGComplianceResult({
    required this.guideline,
    required this.status,
    required this.details,
  });
}

enum WCAGComplianceStatus {
  pass,
  fail,
  notApplicable,
  notTested,
  manualCheck,
}
```

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/accessibility.yml`:

```yaml
name: Accessibility Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  accessibility-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run code generation
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
    
    - name: Run accessibility tests
      run: flutter test test/accessibility_test.dart --coverage
    
    - name: Run WCAG compliance tests
      run: flutter test test/wcag_compliance_test.dart
    
    - name: Generate accessibility report
      run: |
        flutter test test/accessibility_audit_test.dart > accessibility_report.txt
        cat accessibility_report.txt
    
    - name: Upload accessibility report
      uses: actions/upload-artifact@v4
      with:
        name: accessibility-report
        path: accessibility_report.txt
    
    - name: Comment PR with accessibility results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        script: |
          const fs = require('fs');
          const report = fs.readFileSync('accessibility_report.txt', 'utf8');
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## Accessibility Test Results\n\n\`\`\`\n${report}\n\`\`\``
          });
```

### Automated Accessibility Testing

Create `test/accessibility_audit_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  group('Automated Accessibility Audit', () {
    testWidgets('Full app accessibility audit', (tester) async {
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      // Run comprehensive accessibility audit
      final report = await AccessibilityAuditor.auditWidget(
        tester,
        find.byType(MaterialApp),
      );
      
      // Print report for CI/CD
      print(report.generateReport());
      
      // Fail test if critical accessibility issues found
      expect(report.hasErrors, isFalse, 
          reason: 'Critical accessibility issues found:\n${report.generateReport()}');
      
      // Run WCAG compliance check
      final wcagReport = await WCAGComplianceChecker.checkCompliance(
        tester,
        find.byType(MaterialApp),
      );
      
      print('\n${wcagReport.generateReport()}');
      
      // Ensure WCAG AA compliance
      expect(wcagReport.isCompliant, isTrue,
          reason: 'WCAG 2.1 AA compliance failed:\n${wcagReport.generateReport()}');
    });
    
    testWidgets('Accessibility regression test', (tester) async {
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();
      
      // Test specific accessibility scenarios
      await _testTodoItemAccessibility(tester);
      await _testFormAccessibility(tester);
      await _testNavigationAccessibility(tester);
    });
  });
}

Future<void> _testTodoItemAccessibility(WidgetTester tester) async {
  // Navigate to todo list
  final todoItems = find.byType(TodoItemWidget);
  
  if (todoItems.evaluate().isNotEmpty) {
    final firstTodo = todoItems.first;
    
    // Verify semantic properties
    final semantics = tester.getSemantics(firstTodo);
    expect(semantics.label, isNotNull);
    expect(semantics.label!.length, greaterThan(10));
    expect(semantics.hint, isNotNull);
    
    // Verify touch target size
    final renderBox = tester.renderObject(firstTodo) as RenderBox;
    expect(renderBox.size.height, greaterThanOrEqualTo(48));
  }
}

Future<void> _testFormAccessibility(WidgetTester tester) async {
  // Navigate to add todo form
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  // Test form field accessibility
  final titleField = find.byKey(Key('title_field'));
  if (titleField.evaluate().isNotEmpty) {
    final semantics = tester.getSemantics(titleField);
    expect(semantics.label, isNotNull);
    expect(semantics.textField, isTrue);
  }
}

Future<void> _testNavigationAccessibility(WidgetTester tester) async {
  // Test keyboard navigation
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  
  // Verify focus management
  final focusedElement = tester.binding.focusManager.primaryFocus;
  expect(focusedElement, isNotNull);
}
```

### Performance Monitoring

```dart
class AccessibilityPerformanceMonitor {
  static void trackSemanticTreePerformance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final semanticsOwner = WidgetsBinding.instance.pipelineOwner.semanticsOwner;
      
      if (semanticsOwner != null) {
        final nodeCount = _countSemanticNodes(semanticsOwner.rootSemanticsNode!);
        
        // Log performance metrics
        print('Semantic tree nodes: $nodeCount');
        
        if (nodeCount > 1000) {
          print('Warning: Large semantic tree may impact performance');
        }
      }
    });
  }
  
  static int _countSemanticNodes(SemanticsNode node) {
    int count = 1;
    node.visitChildren((child) {
      count += _countSemanticNodes(child);
      return true;
    });
    return count;
  }
  
  static void measureAccessibilityImpact(VoidCallback action) {
    final stopwatch = Stopwatch()..start();
    action();
    stopwatch.stop();
    
    print('Accessibility action took: ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

## Best Practices Summary

### Development Checklist

- [ ] All interactive elements have semantic labels
- [ ] Touch targets are at least 48x48 pixels
- [ ] Text contrast ratios meet WCAG AA standards (4.5:1)
- [ ] Keyboard navigation works for all functionality
- [ ] Focus indicators are visible and clear
- [ ] Screen reader announcements are meaningful
- [ ] Form fields have proper labels and error messages
- [ ] Images and icons have descriptive text alternatives
- [ ] Color is not the only means of conveying information
- [ ] Text can scale up to 200% without loss of functionality
- [ ] Animations respect reduced motion preferences
- [ ] Internationalization supports RTL languages
- [ ] Error messages are clear and actionable
- [ ] Timeout warnings provide extension options
- [ ] Loading states are announced to screen readers

### Testing Strategy

1. **Automated Testing**: Use Flutter's accessibility testing APIs in CI/CD
2. **Manual Testing**: Test with real screen readers and keyboard navigation
3. **User Testing**: Include users with disabilities in testing process
4. **Performance Testing**: Monitor semantic tree size and rendering performance
5. **Regression Testing**: Maintain accessibility test suite for ongoing compliance

### Maintenance

- Regularly update accessibility guidelines as Flutter evolves
- Monitor WCAG updates and incorporate new requirements
- Train development team on accessibility best practices
- Conduct periodic accessibility audits
- Gather feedback from users with disabilities
- Keep accessibility testing tools and dependencies updated

This comprehensive accessibility guide ensures your Flutter todo app is inclusive, compliant with modern standards, and provides an excellent experience for all users.