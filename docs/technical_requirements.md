# Todo App – Technical Requirements (2025-07-19)

A living document describing architecture, constraints, and phased deliverables for the Flutter + Supabase Todo application.

## 0. Overview
* **Goal**  Deliver a cross-platform (iOS, Android, Web, Desktop) offline-first Todo application with real-time collaboration and optional productivity add-ons.
* **Stack**  Flutter 3.32 (Material 3, Impeller), Riverpod 3, Freezed 3, GoRouter 16, Supabase (Postgres + Auth + Realtime + Edge Functions), Dart 3.6.
* **Design principles**  Offline-first, responsive UI, accessibility (WCAG AA), plug-in architecture for new features, CI/CD-driven.

## 1. Phase Breakdown
| Phase | Timeline | Milestone | Key Deliverables |
|-------|----------|-----------|------------------|
| **Phase 0 — Foundation** | Week 0-1 | Project bootstrap | • Flutter workspace & FVM setup  
• Supabase project + schema (done)  
• CI (GitHub Actions) for tests & builds |
| **Phase 1 — MVP** | Week 1-4 | Private beta | • Auth (anon → email/OAuth)  
• CRUD tasks (title, desc, due, priority, status)  
• Sections: Today / Upcoming / Completed  
• Drag & drop reorder (`order_index`)  
• Local cache with optimistic updates  
• Realtime sync via Supabase channel  
• Light/dark theme  
• ≥80 % unit/widget coverage |
| **Phase 2 — Productivity & Polish** | Week 5-7 | Public launch | • Natural-language date parsing  
• Local & push reminders  
• Recurring tasks  
• Search, filters, tags with color chips  
• Widgets / quick-add shortcuts  
• Analytics events (Edge Function) |
| **Phase 3 — Collaboration** | Week 8-10 | Team beta | • Shared lists (`task_lists`, `list_members`)  
• Role-based permissions (viewer/editor)  
• Task comments & activity log  
• Calendar (iCal) export  
• Attachments (Supabase Storage) |
| **Phase 4 — Future Enhancements** | TBD | Delight layer | • Kanban & timeline views  
• AI smart-schedule (Edge + OpenAI)  
• Gamification (streaks, XP)  
• E2E encryption option  
• Desktop (macOS/Windows) UX tweaks |

> _Trend influence_: Mobile-app trend reports (Userpilot 2025, Jafton 2025) highlight offline-first UX, AI features, and CI-driven releases as retention drivers. These shaped Phases 2-4.

## 2. Functional Requirements (Phase 1)
1. **User Management**  
   • Anonymous session on first launch.  
   • Email/password, Google, Apple sign-in.  
   • Merge anonymous tasks on sign-in.
2. **Task Model**  
   `tasks(id, owner_id, list_id, title, description, due_date, priority, is_done, order_index, created_at, updated_at)`.
3. **Offline & Sync**  
   • Isar local DB.  
   • Conflict resolution by `updated_at`.  
   • Supabase Realtime filtered by `owner_id`.
4. **UI/UX**  
   • Material 3 widgets.  
   • Swipe actions, pull-to-refresh, drag reorder.
5. **Testing**  
   • Unit, widget, and integration tests in CI.

## 3. Non-Functional Requirements
* **Performance**  cold start < 2 s; list scroll 60 fps on mid-range devices.
* **Security**  RLS enforced; secure TLS; OWASP MSTG checks pass.
* **Scalability**  10 k MAU on Supabase free tier; use pagination & limits.
* **Accessibility**  Screen-reader labels; dynamic text; contrast ≥ 4.5.
* **Observability**  Supabase logs + Sentry for Flutter.

## 4. API & Data Layer
* Supabase Dart client via `supabase_flutter`.  
* Repositories expose `Stream<List<Task>> watchTasks()` and CRUD.  
* Edge Functions (TypeScript) for notifications & analytics.

## 5. DevOps
* **CI**  Flutter analyze, format, test; `supabase gen types`; build APK/IPA.  
* **CD**  Testflight / Play Console internal track weekly.  
* **Secrets**  Stored in GitHub Secrets; `supabase_config.env` template checked-in.

## 6. Compliance & Privacy
* GDPR-ready: data export & delete endpoints.  
* Store only minimal PII.  
* Analytics anonymized.

## 7. Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Sync conflicts | Data loss | Server wins by `updated_at`, audit log |
| Supabase pricing changes | Cost spike | Feature flag attachments/AI |
| AI hallucinations | User trust | Summaries only; allow correction |

## 8. Appendices
* **A. Trend References**  
  1. Userpilot – _10 Mobile App Trends for 2025_  
  2. Jafton – _Top Mobile App Development Trends 2025_  
  3. Zapier – _Best To-Do List Apps 2025_  
* **B. Schema DDL** – see `supabase/migrations/0001_init_schema.sql`  
* **C. Glossary** – MVP, RLS, PWA, etc.

---
_This document is version-controlled in `docs/technical_requirements.md`. Update as the project evolves._
