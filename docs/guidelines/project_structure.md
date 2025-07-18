# Project Structure Guidelines

## Directory Layout

```
lib/
├── core/                  # Core functionality
│   ├── constants/        # App-wide constants
│   ├── errors/           # Custom error classes
│   ├── utils/            # Utility functions and helpers
│   └── theme/            # App theming
├── features/             # Feature-based modules
│   └── feature_name/     # Feature directory
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
│           └── providers/ # Feature-specific providers
└── main.dart             # App entry point
```

## Core Directory

### constants/
- Contains app-wide constants like API endpoints, app constants, etc.
- Example: `app_constants.dart`, `api_endpoints.dart`

### errors/
- Custom exception and error classes
- Error handling utilities
- Example: `app_exceptions.dart`, `error_handler.dart`

### utils/
- Helper functions and utilities
- Extensions, validators, formatters
- Example: `date_utils.dart`, `string_extensions.dart`

### theme/
- App theming configurations
- Colors, typography, and styling
- Example: `app_theme.dart`, `text_styles.dart`

## Features Directory

### Feature Module Structure
Each feature should be self-contained and follow this structure:

#### data/
- **models/**: Data transfer objects (DTOs)
- **sources/**: Data sources (API clients, local storage)
- **repositories/**: Implementation of repository interfaces

#### domain/
- **entities/**: Business objects and domain models
- **repositories/**: Abstract repository interfaces
- **usecases/**: Business logic components

#### presentation/
- **screens/**: Full page widgets
- **widgets/**: Reusable UI components
- **providers/**: Feature-specific state management

## Flutter Version Management (FVM)

### Installation and Setup

Use FVM to manage Flutter SDK versions across projects:

```bash
# Install a specific Flutter version
fvm install 3.16.0

# Use a specific version for the current project
fvm use 3.16.0

# Use the latest stable channel
fvm use stable

# Pin the stable channel to current latest release
fvm use stable --pin
```

### Project Configuration

Add `.fvm/` to your `.gitignore`:

```gitignore
# FVM Version Cache
.fvm/
```

### IDE Configuration

For VS Code, update `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  }
}
```

## Best Practices

1. **Feature Organization**
   - Keep features independent and modular
   - Minimize dependencies between features
   - Use dependency injection for cross-feature communication

2. **File Naming**
   - Use `snake_case` for file names
   - Suffix files with their type (e.g., `_screen.dart`, `_widget.dart`)
   - Group related files in the same directory

3. **Imports**
   - Use relative imports within the same package
   - Use package imports for external dependencies
   - Keep imports organized and clean

4. **Code Splitting**
   - Split large files into smaller, focused ones
   - Keep classes and functions small and focused
   - Use `part` and `part of` for related files

5. **Testing**
   - Mirror the source directory structure in `test/`
   - Place test files next to the code they test
   - Use descriptive test names

## Example Feature: Todos

```
lib/
└── features/
    └── todos/
        ├── data/
        │   ├── models/
        │   │   └── todo_model.dart
        │   ├── sources/
        │   │   ├── local_todo_source.dart
        │   │   └── remote_todo_source.dart
        │   └── repositories/
        │       └── todo_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── todo.dart
        │   ├── repositories/
        │   │   └── todo_repository.dart
        │   └── usecases/
        │       ├── get_todos.dart
        │       └── add_todo.dart
        └── presentation/
            ├── screens/
            │   ├── todo_list_screen.dart
            │   └── todo_detail_screen.dart
            ├── widgets/
            │   ├── todo_item.dart
            │   └── todo_form.dart
            └── providers/
                └── todo_provider.dart
```

## Asset Organization

```
assets/
├── images/       # App images
├── icons/        # App icons
├── fonts/        # Custom fonts
└── translations/ # Localization files
```

## Test Organization

```
test/
├── unit/         # Unit tests
│   └── features/
│       └── todos/
│           ├── data/
│           │   └── models/
│           │       └── todo_model_test.dart
│           └── domain/
│               └── usecases/
│                   └── get_todos_test.dart
├── widget/       # Widget tests
│   └── features/
│       └── todos/
│           └── presentation/
│               └── widgets/
│                   └── todo_item_test.dart
└── integration/  # Integration tests
    └── app_test.dart
```

## Documentation

- Document public APIs using `///`
- Keep documentation up to date
- Include examples for complex functionality
- Document edge cases and error conditions

## Dependencies

- Keep dependencies minimal and well-maintained
- Document the purpose of each dependency
- Keep dependencies updated to their latest stable versions
