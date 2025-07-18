# Error Handling Guidelines

## Table of Contents
1. [Error Types](#error-types)
2. [Error Handling Strategies](#error-handling-strategies)
3. [Error UI Components](#error-ui-components)
4. [Logging and Monitoring](#logging-and-monitoring)
5. [Testing Error Cases](#testing-error-cases)
6. [Best Practices](#best-practices)

## Error Types

### 1. Network Errors
- Connection timeouts
- Server errors (5xx)
- Client errors (4xx)
- No internet connection

### 2. Data Validation Errors
- Invalid input format
- Required fields missing
- Data type mismatches
- Business rule violations

### 3. Authentication/Authorization Errors
- Invalid credentials
- Expired sessions
- Insufficient permissions
- Rate limiting

### 4. Platform/Device Errors
- Storage permissions
- Camera/GPS access
- Low disk space
- Out of memory

### 5. Business Logic Errors
- Invalid state transitions
- Conflicting operations
- Resource not found
- Operation not allowed

## Error Handling Strategies

### 1. Defensive Programming

```dart
// Check for null values
String getUserName(User? user) {
  if (user == null) {
    throw const AppException('User not found');
  }
  return user.name;
}

// Use null-aware operators
String? getUserEmail(User? user) => user?.email;

// Provide default values
int getItemCount(List<Item>? items) => items?.length ?? 0;
```

### 2. Try-Catch Blocks

```dart
Future<void> fetchData() async {
  try {
    final data = await repository.getData();
    // Process data
  } on SocketException catch (e) {
    // Handle network errors
    showErrorSnackbar('No internet connection');
  } on FormatException catch (e) {
    // Handle parsing errors
    showErrorSnackbar('Invalid data format');
  } on TimeoutException {
    // Handle timeouts
    showErrorSnackbar('Request timed out');
  } on ApiException catch (e) {
    // Handle API errors
    showErrorSnackbar(e.message);
  } catch (e, stackTrace) {
    // Log unexpected errors
    logError(e, stackTrace);
    showErrorSnackbar('An unexpected error occurred');
  }
}
```

### 3. Result Pattern

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;
}

// Usage
Future<Result<User>> getUser(String id) async {
  try {
    final user = await userRepository.getUser(id);
    return Success(user);
  } catch (e, stackTrace) {
    return Failure(AppError.fromException(e, stackTrace));
  }
}

// In UI
final result = await getUser('123');
result.when(
  (user) => _showUser(user),
  (error) => _showError(error),
);
```

### 4. Error Boundaries

```dart
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    required this.child,
    this.fallback,
    this.onError,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final WidgetBuilder? fallback;
  final void Function(Object error, StackTrace stackTrace)? onError;

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didCatchError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
    widget.onError?.call(error, stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback?.call(context) ?? const SizedBox.shrink();
    }
    return widget.child;
  }
}
```

## Error UI Components

### 1. Error Snackbar

```dart
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Theme.of(context).colorScheme.onError,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
```

### 2. Error Screen

```dart
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    required this.error,
    this.onRetry,
    Key? key,
  }) : super(key: key);

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 3. Error Widget

```dart
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.error,
    this.onRetry,
    this.retryText = 'Retry',
    Key? key,
  }) : super(key: key);

  final Object error;
  final VoidCallback? onRetry;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorMessage(error),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryText),
            ),
          ],
        ],
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error is TimeoutException) {
      return 'Request timed out';
    } else if (error is ApiException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
```

## Logging and Monitoring

### 1. Error Logging

```dart
void logError(Object error, StackTrace stackTrace) {
  // Log to console in debug mode
  debugPrint('ERROR: $error\n$stackTrace');
  
  // Send to crash reporting service in production
  if (kReleaseMode) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // or Sentry.captureException(error, stackTrace: stackTrace);
  }
}
```

### 2. Performance Monitoring

```dart
Future<void> trackApiCall(Future<T> Function() apiCall, String endpoint) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await apiCall();
    stopwatch.stop();
    
    // Log successful API call
    analytics.logEvent(
      'api_call',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'status': 'success',
      },
    );
    
    return result;
  } catch (error, stackTrace) {
    stopwatch.stop();
    
    // Log failed API call
    analytics.logEvent(
      'api_call',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'status': 'error',
        'error': error.toString(),
      },
    );
    
    rethrow;
  }
}
```

## Testing Error Cases

### 1. Unit Testing

```dart
group('UserRepository', () {
  late MockApiClient mockApiClient;
  late UserRepository userRepository;
  
  setUp(() {
    mockApiClient = MockApiClient();
    userRepository = UserRepository(apiClient: mockApiClient);
  });
  
  test('getUser throws NetworkException on socket error', () async {
    // Arrange
    when(() => mockApiClient.getUser('123'))
        .thenThrow(SocketException('No internet'));
    
    // Act & Assert
    expect(
      () => userRepository.getUser('123'),
      throwsA(isA<NetworkException>()),
    );
  });
  
  test('getUser returns user on success', () async {
    // Arrange
    const user = User(id: '123', name: 'John');
    when(() => mockApiClient.getUser('123')).thenAnswer((_) async => user);
    
    // Act
    final result = await userRepository.getUser('123');
    
    // Assert
    expect(result, user);
  });
});
```

### 2. Widget Testing

```dart
testWidgets('shows error when loading fails', (tester) async {
  // Arrange
  when(() => mockRepository.getData())
      .thenThrow(const NetworkException('No internet'));
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: MyWidget(repository: mockRepository),
    ),
  );
  
  // Wait for loading to complete
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.text('No internet'), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

## Best Practices

### 1. User Experience
- Show clear, actionable error messages
- Provide recovery options when possible
- Don't expose sensitive information in error messages
- Use appropriate error states (empty states, loading states, etc.)

### 2. Development
- Use specific exception types for different error cases
- Include context in error messages
- Log errors with sufficient detail
- Handle errors at the appropriate level

### 3. Monitoring
- Track errors in production
- Set up alerts for critical errors
- Monitor error rates and trends
- Regularly review and address common errors

### 4. Security
- Sanitize error messages before displaying to users
- Don't log sensitive information
- Handle authentication errors securely
- Implement rate limiting to prevent abuse
