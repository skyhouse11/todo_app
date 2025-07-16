# Technology Stack

## Framework & Language
- **Flutter 3.32.5** (managed via FVM)
- **Dart SDK ^3.7.2**

## State Management & Architecture
- **Riverpod 3.0.0-dev.16** (hooks_riverpod, riverpod_annotation, riverpod_generator)
- **Flutter Hooks** for widget lifecycle management
- **Freezed** for immutable data classes and unions
- **JSON Annotation/Serializable** for data serialization

## Backend & Services
- **Supabase Flutter** for backend-as-a-service
- **Flutter DotEnv** for environment configuration

## Navigation & Routing
- **GoRouter** with code generation support

## Development Tools
- **Build Runner** for code generation
- **Custom Lint** with Riverpod and Freezed linting rules
- **Flutter Lints** for code quality

## Common Commands

### Setup
```bash
# Install FVM and use project Flutter version
fvm install
fvm use

# Get dependencies
fvm flutter pub get

# Generate code (Riverpod providers, Freezed models, etc.)
fvm flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Development
```bash
# Run app
fvm flutter run

# Run with hot reload
fvm flutter run --hot

# Run on specific platform
fvm flutter run -d chrome  # Web
fvm flutter run -d macos   # macOS
```

### Code Generation
```bash
# Watch for changes and auto-generate
fvm flutter packages pub run build_runner watch --delete-conflicting-outputs

# One-time generation
fvm flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing & Quality
```bash
# Run tests
fvm flutter test

# Analyze code
fvm flutter analyze

# Format code
fvm flutter format .
```