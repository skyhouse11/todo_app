# Todo App – Implementation Task List

This backlog derives from EARS user stories and the design document. Use labels `[P1]`, `[P2]`, `[P3]` for priority.

## Phase 0 – Foundation
- [P1] ~~Set up Flutter project with FVM & `fvm install 3.32.5`~~ ✅
- [P1] ~~Configure Supabase credentials in `supabase_config.env`~~ ✅
- [P1] ~~Add GitHub Actions workflow: `flutter analyze`, `flutter test`, build artifacts~~ ✅
- [P2] ~~Integrate Sentry and remote config placeholders~~ ✅

## Phase 1 – MVP
### Auth
- [P1] Implement anonymous sign-in via `supabase.auth.signInWithPasswordless` (device ID)  
- [P1] Email/password sign-up & sign-in screens  
- [P2] Google & Apple OAuth flows (platform-specific config)

### Data Layer
- [P1] Define Freezed models (`Task`, `TaskList`, `Tag`)
- [P1] Generate Supabase types with CLI & compare
- [P1] Implement `TaskRepository` (local Isar + Supabase sync)
- [P1] Implement `SyncQueue` for offline writes

### UI
- [P1] Home screen with Today/Upcoming/Completed tabs
- [P1] Add-task modal sheet with validation
- [P1] Swipe complete/delete actions (Slidable)
- [P2] Drag & drop reorder using `ReorderableListView`

### Realtime & Offline
- [P1] Subscribe to tasks Realtime channel
- [P1] Implement connectivity listener and queue flush

### Testing
- [P1] Unit tests for models & repository
- [P1] Widget tests for add/edit flow

## Phase 2 – Productivity
- [P2] Natural-language date parser (`chrono` Dart port)
- [P2] Notification scheduling (`flutter_local_notifications`)
- [P2] Recurring tasks logic in repository
- [P2] Search & filter provider
- [P2] Tags CRUD UI

## Phase 3 – Collaboration
- [P3] Shared lists invite flow using deep links
- [P3] Role-based permission guards
- [P3] Comments sub-collection & UI thread

## Phase 4 – Extras
- [P3] AI scheduling Edge Function integration
- [P3] Desktop layout optimizations (macOS/Windows)
- [P3] End-to-end encryption proof-of-concept

---
Track progress via GitHub Projects board.
