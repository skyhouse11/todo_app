# Localization & Accessibility Guidelines

## Table of Contents
1. [Localization](#localization)
   - [Setup](#localization-setup)
   - [Usage](#localization-usage)
   - [Pluralization](#pluralization)
   - [Dates & Numbers](#dates--numbers)
2. [Accessibility](#accessibility)
   - [Semantic Widgets](#semantic-widgets)
   - [Screen Readers](#screen-readers)
   - [Dynamic Text](#dynamic-text)
   - [Color & Contrast](#color--contrast)
   - [Interactive Elements](#interactive-elements)
3. [Testing](#testing)
   - [Localization Testing](#localization-testing)
   - [Accessibility Testing](#accessibility-testing)
4. [Best Practices](#best-practices)

## Localization

### Setup

1. **Add Dependencies** to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_localizations:
       sdk: flutter
     intl: ^0.18.0
     flutter_localized_locales: ^2.0.0
   
   dev_dependencies:
     intl_utils: ^2.8.0
   ```

2. **Configure `l10n.yaml`** in the root of your project:
   ```yaml
   arb-dir: lib/l10n
   template-arb-file: app_en.arb
   output-localization-file: app_localizations.dart
   output-class: AppLocalizations
   preferred-supported-locales: ["en", "es", "fr"]
   nullable-getter: false
   use-escaping: true
   ```

3. **Create ARB Files** in `lib/l10n/`:
   - `app_en.arb` (English)
   - `app_es.arb` (Spanish)
   - `app_fr.arb` (French)

4. **Generate Localization Files**:
   ```bash
   flutter pub run intl_utils:generate
   ```

### Usage

1. **Initialize Localizations** in `main.dart`:
   ```dart
   return MaterialApp(
     localizationsDelegates: const [
       AppLocalizations.delegate,
       GlobalMaterialLocalizations.delegate,
       GlobalWidgetsLocalizations.delegate,
       GlobalCupertinoLocalizations.delegate,
     ],
     supportedLocales: const [
       Locale('en', ''), // English
       Locale('es', ''), // Spanish
       Locale('fr', ''), // French
     ],
     locale: const Locale('en'), // Default locale
     home: const MyHomePage(),
   );
   ```

2. **Access Localized Strings**:
   ```dart
   Text(AppLocalizations.of(context)!.welcomeMessage);
   ```

3. **Change Locale**:
   ```dart
   void _changeLanguage(Locale locale) {
     setState(() {
       _locale = locale;
     });
   }
   
   // Usage
   DropdownButton<Locale>(
     value: _locale,
     onChanged: (Locale? newLocale) {
       if (newLocale != null) {
         _changeLanguage(newLocale);
       }
     },
     items: const [
       DropdownMenuItem(
         value: Locale('en'),
         child: Text('English'),
       ),
       DropdownMenuItem(
         value: Locale('es'),
         child: Text('Español'),
       ),
     ],
   );
   ```

### Pluralization

1. **ARB File** (`app_en.arb`):
   ```json
   {
     "@taskCount": {
       "description": "The number of tasks",
       "type": "int",
       "format": "compactLong",
       "optionalParameters": {
         "count": {}
       }
     },
     "taskCount": "{count,plural, =0{No tasks}=1{1 task}other{{count} tasks}}"
   }
   ```

2. **Usage in Code**:
   ```dart
   Text(
     AppLocalizations.of(context)!.taskCount(taskList.length),
   );
   ```

### Dates & Numbers

```dart
// Format date
final date = DateTime.now();
final formattedDate = DateFormat.yMMMd(locale.languageCode).format(date);

// Format number
final number = 1234.56;
final formattedNumber = NumberFormat.currency(
  locale: locale.languageCode,
  symbol: '€',
).format(number);

// Relative time
final timeAgo = DateFormat.yMMMEd(locale.languageCode).format(
  date.subtract(const Duration(days: 1)),
);
```

## Accessibility

### Semantic Widgets

1. **Use Semantic Widgets**:
   ```dart
   // Good
   ElevatedButton(
     onPressed: _handlePress,
     child: const Text('Submit'),
   );
   
   // Bad - Less semantic
   GestureDetector(
     onTap: _handlePress,
     child: Container(
       padding: const EdgeInsets.all(8.0),
       color: Colors.blue,
       child: const Text('Submit'),
     ),
   );
   ```

2. **Add Semantic Labels**:
   ```dart
   Semantics(
     label: 'Close dialog',
     button: true,
     child: IconButton(
       icon: const Icon(Icons.close),
       onPressed: () => Navigator.pop(context),
     ),
   );
   ```

### Screen Readers

1. **Provide Text Alternatives**:
   ```dart
   // Good
   IconButton(
     icon: const Icon(Icons.delete),
     tooltip: 'Delete item',
     onPressed: _deleteItem,
   );
   
   // Better - Works with screen readers
   Semantics(
     button: true,
     label: 'Delete item',
     child: IconButton(
       icon: const Icon(Icons.delete),
       tooltip: 'Delete item',
       onPressed: _deleteItem,
     ),
   );
   ```

2. **Manage Focus**:
   ```dart
   // Move focus to a widget
   FocusScope.of(context).requestFocus(_focusNode);
   
   // Handle keyboard navigation
   Focus(
     autofocus: true,
     onKey: (node, event) {
       if (event is RawKeyDownEvent) {
         // Handle key events
       }
       return KeyEventResult.handled;
     },
     child: // Your widget
   );
   ```

### Dynamic Text

1. **Support Text Scaling**:
   ```dart
   Text(
     'Important information',
     style: Theme.of(context).textTheme.titleLarge,
     textScaleFactor: 1.0, // Allow system text scaling
   );
   ```

2. **Handle Overflow**:
   ```dart
   FittedBox(
     fit: BoxFit.scaleDown,
     child: Text(
       'This is a very long text that might not fit',
       overflow: TextOverflow.ellipsis,
       maxLines: 1,
     ),
   );
   ```

### Color & Contrast

1. **Use Theme Colors**:
   ```dart
   Text(
     'Error message',
     style: TextStyle(
       color: Theme.of(context).colorScheme.error,
     ),
   );
   ```

2. **Check Contrast**:
   ```dart
   // Ensure text is readable on background
   final contrast = ThemeData.estimateBrightnessForColor(backgroundColor) ==
           Brightness.dark
       ? Colors.white
       : Colors.black;
   ```

### Interactive Elements

1. **Touch Targets**:
   ```dart
   // Minimum touch target size
   const double kMinInteractiveDimension = 48.0;
   
   // Good
   SizedBox(
     width: kMinInteractiveDimension,
     height: kMinInteractiveDimension,
     child: IconButton(
       icon: const Icon(Icons.add),
       onPressed: _addItem,
     ),
   );
   ```

2. **Visual Feedback**:
   ```dart
   // Add visual feedback
   InkWell(
     onTap: _handleTap,
     splashColor: Colors.blue.withOpacity(0.2),
     highlightColor: Colors.blue.withOpacity(0.1),
     child: const Padding(
       padding: EdgeInsets.all(16.0),
       child: Text('Tap me'),
     ),
   );
   ```

## Testing

### Localization Testing

```dart
testWidgets('should display text in Spanish', (tester) async {
  // Build the app with Spanish locale
  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      home: MyHomePage(),
    ),
  );
  
  // Verify Spanish text is displayed
  expect(find.text('Bienvenido'), findsOneWidget);
});
```

### Accessibility Testing

```dart
testWidgets('should be accessible', (tester) async {
  // Build the widget
  await tester.pumpWidget(
    const MaterialApp(
      home: MyAccessibleWidget(),
    ),
  );
  
  // Check semantics
  final semantics = tester.getSemantics(
    find.byType(MyAccessibleWidget),
  );
  
  // Verify semantic properties
  expect(semantics, hasSemantics(
    matchesSemantics(
      hasTapAction: true,
      isButton: true,
      label: 'Submit',
    ),
  ));
});
```

## Best Practices

### Localization
1. **Use ARB files** for all user-facing strings
2. **Support RTL** languages like Arabic and Hebrew
3. **Test with long strings** to ensure UI doesn't break
4. **Keep translations in sync** with source language
5. **Use placeholders** for dynamic content

### Accessibility
1. **Test with screen readers** (TalkBack, VoiceOver)
2. **Support keyboard navigation** for all interactive elements
3. **Provide sufficient color contrast** (at least 4.5:1 for normal text)
4. **Don't rely solely on color** to convey information
5. **Add semantic labels** to all interactive elements

### Internationalization
1. **Handle different date/number formats**
2. **Support different text directions** (LTR/RTL)
3. **Be aware of text expansion** (translated text can be much longer)
4. **Use locale-aware sorting** for lists

### Performance
1. **Load only necessary locales**
2. **Cache formatted dates/numbers**
3. **Use const constructors** for widgets that don't change
4. **Minimize rebuilds** of localized widgets
