# Todo App

A comprehensive cross-platform todo application built with Flutter and Supabase, designed for learning modern app development practices and exploring advanced Flutter patterns.

## Current Status

This project is in **early development phase** with foundational architecture and routing infrastructure in place. The focus has been on establishing a solid foundation using modern Flutter development practices and tools.

## Features

### ✅ Implemented
- **Project Structure**: Clean architecture with feature-based organization
- **Cross-Platform Support**: Configured for iOS, Android, macOS, Linux, Windows, and Web
- **Modern UI Foundation**: Material Design 3 with light and dark theme support
- **Type-Safe Navigation**: GoRouter with code generation and type-safe routing
- **Authentication Routes**: Login, signup, and password reset route structure
- **State Management Setup**: Riverpod 3.0 with code generation configured
- **Development Tooling**: Build runner, linting, and code generation setup

### 🚧 In Development
- **Authentication System**: Supabase authentication integration
- **Task Management**: Core CRUD operations for tasks
- **Data Models**: Task, User, and supporting models with Freezed

### 📋 Planned
- **Real-time Sync**: Powered by Supabase for instant data synchronization
- **Task Organization**: Priorities, tags, categories, and advanced filtering
- **Due Dates & Reminders**: Notification system for task deadlines
- **Advanced Features**: Subtasks, recurring tasks, and dependencies
- **Collaboration**: Share tasks and collaborate with team members
- **Analytics**: Productivity insights and completion tracking
- **Offline Support**: Local storage with sync capabilities

## Tech Stack

- **Frontend**: Flutter 3.32.5 with Dart SDK ^3.7.2
- **State Management**: Riverpod 3.0.0-dev.16 with code generation
- **Backend**: Supabase Flutter 2.3.3 (authentication, database, real-time subscriptions)
- **Navigation**: GoRouter 16.0.0 with type-safe routing and code generation
- **Data Models**: Freezed 3.1.0 for immutable data classes
- **Architecture**: Clean architecture with feature-based organization
- **Development Tools**: Build runner, custom lint rules, Flutter hooks

## Getting Started

### Prerequisites

- Flutter SDK 3.32.5 (managed via FVM)
- Dart SDK ^3.7.2
- FVM (Flutter Version Management)

### Setup

1. **Install FVM and Flutter version**:
   ```bash
   fvm install
   fvm use
   ```

2. **Install dependencies**:
   ```bash
   fvm flutter pub get
   ```

3. **Configure Supabase** (required for backend functionality):
   - Create a new Supabase project at https://supabase.com
   - Copy your project URL and anon key
   - Create `supabase_config.env` file in the root directory:
     ```env
     SUPABASE_URL=your_supabase_project_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Generate code** (for Riverpod providers, Freezed models):
   ```bash
   fvm flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   fvm flutter run
   ```

### Development Commands

- **Hot reload development**: `fvm flutter run --hot`
- **Run on specific platform**: `fvm flutter run -d chrome` (Web) or `fvm flutter run -d macos` (macOS)
- **Watch for code generation**: `fvm flutter packages pub run build_runner watch --delete-conflicting-outputs`
- **Run tests**: `fvm flutter test`
- **Code analysis**: `fvm flutter analyze`

## Project Structure

```
lib/
├── core/                    # App-wide configuration and utilities
│   ├── constants/          # Application constants
│   ├── providers/          # Global Riverpod providers
│   ├── router/             # Navigation and routing
│   │   ├── routes/         # Route definitions
│   │   ├── app_router.dart # Main router configuration
│   │   ├── route_guards.dart # Authentication guards
│   │   └── route_paths.dart # Route path constants
│   └── theme/              # Theme configuration
├── features/               # Feature-based organization
│   └── auth/               # Authentication feature
│       └── screens/        # Auth screens (Login, SignUp, Reset)
├── shared/                 # Shared components and utilities
└── main.dart               # App entry point
```

## Contributing

This is a learning project. Feel free to explore the code and suggest improvements!

## License

This project is for educational purposes.
