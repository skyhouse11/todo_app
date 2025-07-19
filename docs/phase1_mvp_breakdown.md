# Phase 1 – MVP Technical Breakdown

This document details all steps and technical subtasks for the Phase 1 MVP of the Flutter + Supabase Todo App. It is based on official Supabase guides, Flutter best practices, and modern app architecture.

---

## 1. Authentication

### a. Anonymous Sign-In
- Integrate `supabase_flutter` package.
- Implement device-based anonymous auth (`signInWithPasswordless` or similar).
- Store device/user ID locally for future sessions.
- Handle auth state and session persistence.

### b. Email/Password Sign-Up & Sign-In
- Build UI for registration and login.
- Use Supabase Auth methods (`signUp`, `signInWithPassword`).
- Handle errors, loading, and success states.

### c. OAuth (Google/Apple)
- Integrate platform-specific OAuth flows.
- Configure OAuth providers in Supabase dashboard.
- Handle redirects and tokens.

### d. Auth State Management
- Use a provider or state management solution (Riverpod, Provider, Bloc).
- Listen for auth state changes and route accordingly.

---

## 2. Data Layer

### a. Define Models
- Use Freezed or built_value for immutable models: `Task`, `TaskList`, `Tag`.
- Generate JSON serialization.

### b. Supabase Types
- Use Supabase CLI to generate Dart types from DB schema.
- Compare/align with hand-written models.

### c. Repository Pattern
- Implement `TaskRepository` for CRUD (local & remote).
- Use Isar or Hive for offline/local storage.
- Sync logic between local and Supabase (conflict resolution, merge).

### d. Sync Queue
- Implement a queue for offline writes.
- Retry sync on connectivity restore.

---

## 3. UI Layer

### a. Home Screen
- Tabs: Today, Upcoming, Completed.
- List tasks, group by date/status.
- Pull-to-refresh and loading states.

### b. Add Task Modal
- Modal sheet for new task creation.
- Input validation, date picker, tags.

### c. Task Details/Edit
- View/edit task, mark complete, delete.
- UI for tags, notes, due date.

### d. Responsive & Theming
- Material 3, dark/light mode, accessibility.

---

## 4. Other MVP Features

### a. Error Handling & Reporting
- Integrate Sentry for error and crash reporting.
- Show user-friendly error messages.

### b. Remote Config Placeholders
- Set up remote config for feature flags or A/B.

### c. CI/CD
- Ensure tests, analyze, and build pass on GitHub Actions.

---

## Technical Exploration for Each Step

### 1. Authentication
- Use `Supabase.instance.client.auth` for all auth flows.
- For anonymous sign-in, use device fingerprinting or Supabase’s anonymous user support.
- For OAuth, configure callback URLs in both Supabase and app manifest (Android/iOS).
- Persist session using secure storage or built-in Supabase session management.
- Use a global provider (e.g., Riverpod) for auth state, so UI reacts to login/logout.

### 2. Data Layer
- Freezed models: run `flutter pub run build_runner build` for codegen.
- Supabase CLI: `supabase gen types dart --local > lib/types.dart`.
- Repository: abstract away Supabase/Isar logic, so UI only interacts with repository.
- Sync: use connectivity_plus to detect online/offline, queue writes locally, and sync on reconnect.

### 3. UI Layer
- Use `hooks_riverpod` to combine both hooks and Riverpod for stateful widgets and reactive state management.
    - Use `HookConsumerWidget` for widgets that need both hooks and providers.
    - Example: `useState`, `useEffect`, and `ref.watch()` can all be used in the same widget.
    - This enables concise, testable, and reactive UI code.
- Home screen: use `ListView.builder`, group tasks by status/date.
- Add Task: use `showModalBottomSheet`, validate inputs before submission.
- Responsive: use `LayoutBuilder` and media queries for tablet/desktop support.

### 4. Other
- Sentry: wrap app in Sentry widget, use DSN from env.
- Remote config: placeholder for future Firebase Remote Config or Supabase Edge Functions.
- CI: ensure .env is not committed, secrets injected in workflow.

---

For more details, see official Supabase and Flutter documentation.
