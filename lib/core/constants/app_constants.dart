/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Todo App';
  static const String appVersion = '1.0.0';

  // Database
  static const String tasksTable = 'tasks';
  static const String usersTable = 'users';
  static const String tagsTable = 'tags';
  static const String taskCommentsTable = 'task_comments';
  static const String userPreferencesTable = 'user_preferences';

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String tasksRoute = '/tasks';
  static const String settingsRoute = '/settings';

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
