# Development Workflow Guidelines

This document outlines the complete development workflow for the Todo App, covering everything from initial setup to production deployment. These guidelines ensure consistency, quality, and efficiency across the development lifecycle.

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Code Generation Workflows](#code-generation-workflows)
3. [Project Organization](#project-organization)
4. [Version Control Best Practices](#version-control-best-practices)
5. [Code Quality Enforcement](#code-quality-enforcement)
6. [Testing Workflows](#testing-workflows)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Debugging and Profiling](#debugging-and-profiling)
9. [Release Management](#release-management)
10. [Team Collaboration](#team-collaboration)
11. [Monitoring and Error Tracking](#monitoring-and-error-tracking)
12. [Performance Benchmarking](#performance-benchmarking)

## Development Environment Setup

### Prerequisites

Ensure you have the following tools installed:

```bash
# Flutter SDK (3.24.0+)
flutter --version

# Dart SDK (included with Flutter)
dart --version

# Git
git --version

# VS Code or Android Studio
code --version
```

### Initial Project Setup

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd todo_app
   flutter pub get
   ```

2. **Environment Configuration**
   ```bash
   # Copy environment template
   cp supabase_config.env.example supabase_config.env
   
   # Configure your Supabase credentials
   # Edit supabase_config.env with your project details
   ```

3. **IDE Configuration**
   
   **VS Code Extensions:**
   ```json
   {
     "recommendations": [
       "dart-code.dart-code",
       "dart-code.flutter",
       "ms-vscode.vscode-json",
       "bradlc.vscode-tailwindcss",
       "usernamehw.errorlens",
       "streetsidesoftware.code-spell-checker"
     ]
   }
   ```

   **VS Code Settings:**
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.lineLength": 80,
     "dart.insertArgumentPlaceholders": false,
     "dart.previewFlutterUiGuides": true,
     "dart.previewFlutterUiGuidesCustomTracking": true,
     "editor.formatOnSave": true,
     "editor.codeActionsOnSave": {
       "source.fixAll": true,
       "source.organizeImports": true
     }
   }
   ```

### Development Tools Setup

1. **Flutter Inspector**
   ```bash
   # Enable Flutter Inspector in VS Code
   # Cmd/Ctrl + Shift + P -> "Flutter: Open Flutter Inspector"
   ```

2. **Dart DevTools**
   ```bash
   # Launch DevTools
   flutter pub global activate devtools
   dart devtools
   ```

3. **Build Runner Setup**
   ```bash
   # Install build_runner globally for faster builds
   flutter pub global activate build_runner
   ```

## Code Generation Workflows

### Build Runner Configuration

The project uses `build_runner` for code generation with the following packages:
- `freezed` - Immutable data classes
- `json_serializable` - JSON serialization
- `riverpod_generator` - Riverpod providers
- `go_router_builder` - Route generation

### Code Generation Commands

1. **One-time Generation**
   ```bash
   # Generate all files
   dart run build_runner build
   
   # Generate with deletion of conflicting outputs
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Watch Mode (Development)**
   ```bash
   # Watch for changes and regenerate automatically
   dart run build_runner watch
   
   # Watch with deletion of conflicting outputs
   dart run build_runner watch --delete-conflicting-outputs
   ```

3. **Clean Generated Files**
   ```bash
   # Clean all generated files
   dart run build_runner clean
   ```

### Code Generation Best Practices

1. **File Naming Conventions**
   ```dart
   // Model files
   user.dart          // Main model
   user.freezed.dart  // Generated freezed code
   user.g.dart        // Generated JSON serialization
   
   // Provider files
   user_provider.dart          // Main provider
   user_provider.g.dart       // Generated provider code
   ```

2. **Generation Workflow**
   ```bash
   # Recommended development workflow
   
   # 1. Start watch mode in terminal
   dart run build_runner watch --delete-conflicting-outputs
   
   # 2. Make changes to source files
   # 3. Generated files update automatically
   # 4. Hot reload in Flutter app
   ```

3. **Handling Generation Conflicts**
   ```bash
   # If generation fails due to conflicts
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

### Integration with IDE

1. **VS Code Tasks**
   Create `.vscode/tasks.json`:
   ```json
   {
     "version": "2.0.0",
     "tasks": [
       {
         "label": "Build Runner: Build",
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
         "label": "Build Runner: Watch",
         "type": "shell",
         "command": "dart",
         "args": ["run", "build_runner", "watch", "--delete-conflicting-outputs"],
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

## Project Organization

### Directory Structure

```
todo_app/
├── lib/
│   ├── core/                 # Core functionality
│   │   ├── constants/        # App constants
│   │   ├── errors/          # Error handling
│   │   ├── extensions/      # Dart extensions
│   │   ├── theme/           # App theming
│   │   └── utils/           # Utility functions
│   ├── features/            # Feature modules
│   │   ├── auth/           # Authentication
│   │   ├── todos/          # Todo management
│   │   └── profile/        # User profile
│   ├── shared/             # Shared components
│   │   ├── models/         # Data models
│   │   ├── providers/      # Global providers
│   │   ├── repositories/   # Data repositories
│   │   ├── services/       # External services
│   │   └── widgets/        # Reusable widgets
│   ├── generated/          # Generated files
│   └── main.dart          # App entry point
├── test/                   # Test files
├── integration_test/       # Integration tests
├── docs/                   # Documentation
├── assets/                 # Static assets
└── build/                  # Build outputs
```

### Feature Module Structure

Each feature follows a consistent structure:

```
features/todos/
├── data/
│   ├── models/            # Data models
│   ├── repositories/      # Repository implementations
│   └── datasources/       # Data sources (local/remote)
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/         # Business logic
├── presentation/
│   ├── pages/            # UI pages
│   ├── widgets/          # Feature-specific widgets
│   ├── providers/        # Feature providers
│   └── controllers/      # UI controllers
└── tests/                # Feature tests
```

### File Naming Conventions

1. **Dart Files**
   ```
   snake_case.dart           # Standard Dart files
   widget_name.dart          # Widget files
   provider_name.dart        # Provider files
   model_name.dart          # Model files
   service_name.dart        # Service files
   ```

2. **Test Files**
   ```
   feature_test.dart         # Unit tests
   widget_test.dart         # Widget tests
   integration_test.dart    # Integration tests
   ```

3. **Asset Files**
   ```
   images/icon_name.png     # Image assets
   fonts/font_name.ttf      # Font assets
   data/sample_data.json    # Data files
   ```

## Version Control Best Practices

### Git Workflow

1. **Branch Naming Convention**
   ```
   main                     # Production branch
   develop                  # Development branch
   feature/feature-name     # Feature branches
   bugfix/bug-description   # Bug fix branches
   hotfix/critical-fix      # Hotfix branches
   release/v1.0.0          # Release branches
   ```

2. **Commit Message Format**
   ```
   type(scope): description
   
   [optional body]
   
   [optional footer]
   ```

   **Types:**
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation changes
   - `style`: Code style changes
   - `refactor`: Code refactoring
   - `test`: Test changes
   - `chore`: Build/tool changes

   **Examples:**
   ```
   feat(auth): add biometric authentication
   fix(todos): resolve duplicate todo creation
   docs(readme): update installation instructions
   style(widgets): apply consistent formatting
   refactor(providers): simplify state management
   test(auth): add unit tests for login flow
   chore(deps): update dependencies to latest versions
   ```

### Git Hooks

Create `.git/hooks/pre-commit`:
```bash
#!/bin/sh
# Pre-commit hook for code quality

echo "Running pre-commit checks..."

# Format code
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "❌ Code formatting failed. Run 'dart format .' to fix."
  exit 1
fi

# Analyze code
dart analyze
if [ $? -ne 0 ]; then
  echo "❌ Static analysis failed. Fix the issues above."
  exit 1
fi

# Run tests
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Fix failing tests before committing."
  exit 1
fi

echo "✅ Pre-commit checks passed!"
```

### .gitignore Configuration

Ensure proper `.gitignore` setup:
```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
flutter_*.png

# Generated files
*.g.dart
*.freezed.dart
*.config.dart
*.mocks.dart

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
*.env
!*.env.example

# OS
.DS_Store
Thumbs.db

# Coverage
coverage/
lcov.info

# Build outputs
*.apk
*.aab
*.ipa
*.app
```

## Code Quality Enforcement

### Code Quality Commands

1. **Run Analysis**
   ```bash
   # Standard Dart analysis
   dart analyze
   ```

2. **Format Code**
   ```bash
   # Format all Dart files
   dart format .
   
   # Check formatting without changes
   dart format --set-exit-if-changed .
   ```

3. **Fix Common Issues**
   ```bash
   # Apply automatic fixes
   dart fix --apply
   
   # Preview fixes without applying
   dart fix --dry-run
   ```

### Quality Gates

Code must pass these quality gates before merging:

1. **Static Analysis**: Zero analyzer warnings/errors
2. **Formatting**: Code must be properly formatted
3. **Metrics**: All metrics within defined thresholds
4. **Tests**: All tests must pass
5. **Coverage**: Minimum 80% test coverage

### IDE Integration

Configure your IDE for real-time quality feedback:

1. **VS Code Settings**
   ```json
   {
     "dart.analysisExcludedFolders": [
       "build",
       ".dart_tool"
     ],
     "dart.showTodos": true,
     "dart.showIgnoreQuickFixes": false,
     "editor.rulers": [80],
     "editor.wordWrap": "wordWrapColumn",
     "editor.wordWrapColumn": 80
   }
   ```

## Testing Workflows

### Test Structure

```
test/
├── unit/                   # Unit tests
│   ├── models/            # Model tests
│   ├── providers/         # Provider tests
│   ├── repositories/      # Repository tests
│   └── services/          # Service tests
├── widget/                # Widget tests
│   ├── pages/            # Page widget tests
│   └── components/       # Component tests
├── integration/           # Integration tests
├── golden/               # Golden file tests
├── helpers/              # Test helpers
└── mocks/                # Mock objects
```

### Testing Commands

1. **Run All Tests**
   ```bash
   # Run all tests
   flutter test
   
   # Run tests with coverage
   flutter test --coverage
   
   # Run specific test file
   flutter test test/unit/models/todo_test.dart
   ```

2. **Integration Tests**
   ```bash
   # Run integration tests
   flutter test integration_test/
   
   # Run on specific device
   flutter test integration_test/ -d chrome
   ```

3. **Golden Tests**
   ```bash
   # Update golden files
   flutter test --update-goldens
   
   # Run golden tests
   flutter test test/golden/
   ```

### Test Coverage

1. **Generate Coverage Report**
   ```bash
   # Generate coverage
   flutter test --coverage
   
   # Generate HTML report
   genhtml coverage/lcov.info -o coverage/html
   
   # Open coverage report
   open coverage/html/index.html
   ```

2. **Coverage Enforcement**
   ```bash
   # Check coverage threshold
   dart run test_coverage
   ```

### Testing Best Practices

1. **Test Organization**
   ```dart
   // test/unit/models/todo_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:todo_app/shared/models/todo.dart';
   
   void main() {
     group('Todo Model', () {
       group('constructor', () {
         test('should create todo with required fields', () {
           // Test implementation
         });
       });
       
       group('copyWith', () {
         test('should create copy with updated fields', () {
           // Test implementation
         });
       });
       
       group('toJson', () {
         test('should serialize to JSON correctly', () {
           // Test implementation
         });
       });
     });
   }
   ```

2. **Widget Testing**
   ```dart
   // test/widget/pages/todo_list_page_test.dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:todo_app/features/todos/presentation/pages/todo_list_page.dart';
   
   void main() {
     group('TodoListPage', () {
       testWidgets('should display todo list', (tester) async {
         await tester.pumpWidget(
           ProviderScope(
             child: MaterialApp(
               home: TodoListPage(),
             ),
           ),
         );
         
         expect(find.byType(ListView), findsOneWidget);
       });
     });
   }
   ```

3. **Mock Setup**
   ```dart
   // test/mocks/mock_todo_repository.dart
   import 'package:mocktail/mocktail.dart';
   import 'package:todo_app/features/todos/domain/repositories/todo_repository.dart';
   
   class MockTodoRepository extends Mock implements TodoRepository {}
   ```

## CI/CD Pipeline

### GitHub Actions Workflow

The project uses GitHub Actions for CI/CD. Key workflows:

1. **Continuous Integration** (`.github/workflows/ci.yml`)
2. **Release Management** (`.github/workflows/release.yml`)
3. **Dependency Updates** (`.github/workflows/dependabot.yml`)

### CI Pipeline Stages

1. **Setup**
   - Checkout code
   - Setup Flutter environment
   - Cache dependencies
   - Install dependencies

2. **Code Quality**
   - Format checking
   - Static analysis
   - Lint checking
   - Security scanning

3. **Testing**
   - Unit tests
   - Widget tests
   - Integration tests
   - Coverage reporting

4. **Build**
   - Android APK/AAB
   - iOS IPA
   - Web build
   - Desktop builds (if applicable)

5. **Deploy**
   - Staging deployment
   - Production deployment (on release)

### Environment Variables

Configure these secrets in GitHub repository settings:

```
# Supabase
SUPABASE_URL
SUPABASE_ANON_KEY

# Android Signing
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD

# iOS Signing
IOS_CERTIFICATE_BASE64
IOS_PROVISIONING_PROFILE_BASE64
IOS_CERTIFICATE_PASSWORD

# Deployment
FIREBASE_TOKEN
PLAY_STORE_SERVICE_ACCOUNT_JSON
APP_STORE_CONNECT_API_KEY
```

### Local CI Simulation

Run CI checks locally before pushing:

```bash
#!/bin/bash
# scripts/ci_check.sh

echo "🔍 Running CI checks locally..."

# Format check
echo "📝 Checking code formatting..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then exit 1; fi

# Static analysis
echo "🔬 Running static analysis..."
dart analyze
if [ $? -ne 0 ]; then exit 1; fi

# Code metrics
echo "📊 Checking code metrics..."
dart run dart_code_metrics:metrics analyze lib
if [ $? -ne 0 ]; then exit 1; fi

# Tests
echo "🧪 Running tests..."
flutter test --coverage
if [ $? -ne 0 ]; then exit 1; fi

# Coverage check
echo "📈 Checking test coverage..."
dart run test_coverage
if [ $? -ne 0 ]; then exit 1; fi

# Build check
echo "🏗️ Checking build..."
flutter build apk --debug
if [ $? -ne 0 ]; then exit 1; fi

echo "✅ All CI checks passed!"
```

## Debugging and Profiling

### Debugging Setup

1. **VS Code Debug Configuration**
   Create `.vscode/launch.json`:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Debug Flutter App",
         "type": "dart",
         "request": "launch",
         "program": "lib/main.dart",
         "args": ["--flavor", "development"]
       },
       {
         "name": "Debug Tests",
         "type": "dart",
         "request": "launch",
         "program": "test/",
         "args": ["--plain-name-format"]
       }
     ]
   }
   ```

2. **Debug Commands**
   ```bash
   # Run with debugging
   flutter run --debug
   
   # Run with profiling
   flutter run --profile
   
   # Run with release mode
   flutter run --release
   ```

### Profiling Workflows

1. **Performance Profiling**
   ```bash
   # Launch with profiling
   flutter run --profile
   
   # Open DevTools
   flutter pub global run devtools
   ```

2. **Memory Profiling**
   ```bash
   # Monitor memory usage
   flutter run --profile --trace-startup
   
   # Analyze memory leaks
   flutter analyze --suggestions
   ```

3. **Network Profiling**
   ```bash
   # Enable network logging
   flutter run --debug --verbose
   ```

### Debugging Best Practices

1. **Logging Strategy**
   ```dart
   import 'dart:developer' as developer;
   
   void debugLog(String message, {String? name}) {
     developer.log(
       message,
       name: name ?? 'TodoApp',
       time: DateTime.now(),
     );
   }
   ```

2. **Error Handling**
   ```dart
   // Global error handling
   void main() {
     FlutterError.onError = (details) {
       FlutterError.presentError(details);
       // Log to crash reporting service
     };
     
     PlatformDispatcher.instance.onError = (error, stack) {
       // Handle platform errors
       return true;
     };
     
     runApp(MyApp());
   }
   ```

3. **Debug Utilities**
   ```dart
   // Debug-only widgets
   class DebugBanner extends StatelessWidget {
     final Widget child;
     
     const DebugBanner({required this.child});
     
     @override
     Widget build(BuildContext context) {
       return kDebugMode
         ? Banner(
             message: 'DEBUG',
             location: BannerLocation.topEnd,
             child: child,
           )
         : child;
     }
   }
   ```

## Release Management

### Version Management

1. **Semantic Versioning**
   ```
   MAJOR.MINOR.PATCH+BUILD
   
   1.0.0+1    # Initial release
   1.0.1+2    # Patch release
   1.1.0+3    # Minor release
   2.0.0+4    # Major release
   ```

2. **Version Update Script**
   ```bash
   #!/bin/bash
   # scripts/bump_version.sh
   
   VERSION_TYPE=$1  # major, minor, patch
   
   if [ -z "$VERSION_TYPE" ]; then
     echo "Usage: ./bump_version.sh [major|minor|patch]"
     exit 1
   fi
   
   # Update pubspec.yaml version
   # Update version in other files
   # Create git tag
   # Push changes
   ```

### Release Process

1. **Pre-release Checklist**
   ```markdown
   - [ ] All tests passing
   - [ ] Code coverage ≥ 80%
   - [ ] No critical security vulnerabilities
   - [ ] Performance benchmarks within limits
   - [ ] Documentation updated
   - [ ] Changelog updated
   - [ ] Version bumped
   ```

2. **Release Commands**
   ```bash
   # Create release build
   flutter build apk --release
   flutter build appbundle --release
   flutter build ios --release
   flutter build web --release
   
   # Sign and upload to stores
   # (Automated via CI/CD)
   ```

3. **Post-release Tasks**
   ```markdown
   - [ ] Verify deployment
   - [ ] Monitor crash reports
   - [ ] Update documentation
   - [ ] Notify stakeholders
   - [ ] Plan next iteration
   ```

### Deployment Strategies

1. **Staging Deployment**
   - Automatic deployment on merge to `develop`
   - Internal testing environment
   - Feature validation

2. **Production Deployment**
   - Manual approval required
   - Gradual rollout (10% → 50% → 100%)
   - Rollback capability

3. **Hotfix Deployment**
   - Fast-track critical fixes
   - Bypass normal approval process
   - Immediate rollout

## Team Collaboration

### Code Review Process

1. **Pull Request Template**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Integration tests added/updated
   - [ ] Manual testing completed
   
   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No new warnings introduced
   ```

2. **Review Guidelines**
   - At least 2 reviewers for major changes
   - Focus on logic, performance, security
   - Provide constructive feedback
   - Approve only when confident

3. **Review Checklist**
   ```markdown
   - [ ] Code is readable and well-documented
   - [ ] Logic is correct and efficient
   - [ ] Error handling is appropriate
   - [ ] Tests cover new functionality
   - [ ] No security vulnerabilities
   - [ ] Performance impact considered
   ```

### Communication Guidelines

1. **Daily Standups**
   - What did you work on yesterday?
   - What will you work on today?
   - Any blockers or dependencies?

2. **Sprint Planning**
   - Review backlog items
   - Estimate effort required
   - Assign tasks to team members
   - Define sprint goals

3. **Retrospectives**
   - What went well?
   - What could be improved?
   - Action items for next sprint

### Documentation Standards

1. **Code Documentation**
   ```dart
   /// Manages todo items and their state.
   /// 
   /// This provider handles CRUD operations for todos,
   /// including synchronization with the backend.
   /// 
   /// Example usage:
   /// ```dart
   /// final todos = ref.watch(todoListProvider);
   /// ```
   @riverpod
   class TodoList extends _$TodoList {
     // Implementation
   }
   ```

2. **API Documentation**
   - Document all public APIs
   - Include usage examples
   - Specify parameters and return types
   - Document error conditions

3. **Architecture Documentation**
   - High-level system overview
   - Component interactions
   - Data flow diagrams
   - Decision records

## Monitoring and Error Tracking

### Error Tracking Setup

1. **Crash Reporting**
   ```dart
   // Initialize crash reporting
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize crash reporting service
     await CrashReporting.initialize();
     
     // Set up error handlers
     FlutterError.onError = CrashReporting.recordFlutterError;
     PlatformDispatcher.instance.onError = CrashReporting.recordError;
     
     runApp(MyApp());
   }
   ```

2. **Performance Monitoring**
   ```dart
   // Track performance metrics
   class PerformanceTracker {
     static void trackPageLoad(String pageName) {
       // Track page load times
     }
     
     static void trackUserAction(String action) {
       // Track user interactions
     }
     
     static void trackNetworkRequest(String endpoint, Duration duration) {
       // Track API performance
     }
   }
   ```

3. **Custom Metrics**
   ```dart
   // Business metrics
   class Analytics {
     static void trackTodoCreated() {
       // Track todo creation
     }
     
     static void trackUserEngagement(Duration sessionTime) {
       // Track user engagement
     }
     
     static void trackFeatureUsage(String feature) {
       // Track feature adoption
     }
   }
   ```

### Monitoring Dashboard

Key metrics to monitor:

1. **Technical Metrics**
   - Crash rate
   - App startup time
   - Memory usage
   - Network performance
   - Battery usage

2. **Business Metrics**
   - User engagement
   - Feature adoption
   - Conversion rates
   - User retention

3. **Quality Metrics**
   - Test coverage
   - Code quality scores
   - Security vulnerabilities
   - Performance benchmarks

## Performance Benchmarking

### Benchmark Setup

1. **Performance Tests**
   ```dart
   // test/performance/todo_list_performance_test.dart
   import 'package:flutter/services.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:integration_test/integration_test.dart';
   
   void main() {
     final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
     
     group('Todo List Performance', () {
       testWidgets('should load 1000 todos within 2 seconds', (tester) async {
         // Performance test implementation
         
         await binding.traceAction(() async {
           // Action to benchmark
         }, reportKey: 'todo_list_load_time');
       });
     });
   }
   ```

2. **Benchmark Commands**
   ```bash
   # Run performance tests
   flutter test integration_test/performance/
   
   # Profile app performance
   flutter run --profile --trace-startup
   
   # Analyze build size
   flutter build apk --analyze-size
   ```

### CI/CD Integration

1. **Performance Gates**
   ```yaml
   # .github/workflows/performance.yml
   name: Performance Tests
   
   on:
     pull_request:
       branches: [main, develop]
   
   jobs:
     performance:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
         
         - name: Run performance tests
           run: flutter test integration_test/performance/
           
         - name: Check performance thresholds
           run: |
             # Fail if performance degrades beyond threshold
   ```

2. **Performance Monitoring**
   ```bash
   # Monitor key metrics
   - App startup time: < 3 seconds
   - Memory usage: < 100MB baseline
   - Frame rate: 60 FPS maintained
   - Network requests: < 2 seconds response time
   ```

### Optimization Guidelines

1. **Code Optimization**
   - Use `const` constructors
   - Implement `RepaintBoundary` for expensive widgets
   - Optimize list rendering with `ListView.builder`
   - Cache expensive computations

2. **Asset Optimization**
   - Compress images
   - Use appropriate image formats (WebP, SVG)
   - Implement lazy loading
   - Optimize font loading

3. **Network Optimization**
   - Implement request caching
   - Use pagination for large datasets
   - Optimize payload sizes
   - Implement offline capabilities

---

This development workflow ensures consistent, high-quality development practices across the team while maintaining efficiency and reliability throughout the development lifecycle.