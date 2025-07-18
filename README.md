# Flutter Todo App with Supabase

A modern, cross-platform todo application built with Flutter and Supabase, following best practices for state management, testing, and performance.

## Features

- ✅ Real-time todo synchronization
- 🔐 Secure authentication
- 📱 Responsive design for mobile and web
- 🌐 Internationalization support
- 🎨 Customizable themes
- 🚀 Optimized for performance

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Supabase account
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended for development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/todo_app.git
   cd todo_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Fill in your Supabase URL and anon key

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── constants/       # App-wide constants
│   ├── errors/          # Error handling
│   ├── services/        # Core services
│   └── utils/           # Utility functions
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── sources/         # Data sources (local, remote)
├── domain/              # Business logic
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── use_cases/       # Business use cases
├── presentation/        # UI layer
│   ├── pages/           # App screens
│   ├── widgets/         # Reusable widgets
│   ├── providers/       # State providers
│   └── themes/          # App theming
└── main.dart           # App entry point
```

## Development Guidelines

We follow a set of guidelines to ensure code quality and maintainability. Please refer to the following documents:

1. [Project Structure](docs/guidelines/project_structure.md) - Directory layout and organization
2. [Code Style](docs/guidelines/code_style.md) - Naming conventions and formatting
3. [State Management](docs/guidelines/state_management.md) - Using Riverpod and Flutter Hooks
4. [Supabase Integration](docs/guidelines/supabase_integration.md) - Database and authentication
5. [Error Handling](docs/guidelines/error_handling.md) - Error management and reporting
6. [Testing](docs/guidelines/testing.md) - Testing strategies and best practices
7. [Performance](docs/guidelines/performance.md) - Optimization techniques
8. [Localization & Accessibility](docs/guidelines/localization_accessibility.md) - i18n and a11y

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [Supabase](https://supabase.io/)
- [Riverpod](https://riverpod.dev/)
- [Freezed](https://pub.dev/packages/freezed)
- [Flutter Hooks](https://pub.dev/packages/flutter_hooks)
