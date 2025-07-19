# Flutter + Supabase Todo App

A modern, offline-first todo application built with Flutter 3 and Supabase. The project follows clean architecture, Riverpod state management, and is designed for real-time collaboration.

## Documentation
| Doc | Description |
|-----|-------------|
| [`docs/technical_requirements.md`](docs/technical_requirements.md) | Phased product & technical requirements |
| [`docs/user_stories_ears.md`](docs/user_stories_ears.md) | EARS-format user stories |
| [`docs/design_document.md`](docs/design_document.md) | Architecture diagrams & implementation notes |
| [`docs/implementation_tasks.md`](docs/implementation_tasks.md) | Prioritised backlog |

## Quick Start
```bash
# Install Flutter 3.32.5 via FVM (Phase 0 task)
fvm install 3.32.5
fvm use 3.32.5

# Get packages
flutter pub get

# Configure Supabase
cp supabase_config.env .env   # then edit URL & anon key

# Run the app
fvm flutter run
```

## Contributing Workflow
1. Pick an open issue from GitHub backlog.
2. Create a feature branch (`git checkout -b feat/<issue-key>`).
3. Commit with Conventional Commits.
4. Push and open a PR.

CI runs `flutter analyze`, tests, and builds artifacts.

---
© 2025 Skyhouse11 – MIT License.
