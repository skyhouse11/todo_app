# Todo App – User Stories (EARS format)

## Legend
EARS pattern: _When <trigger>, the <system> shall <response>_ (Event-driven primary). Ubiquitous requirements omit the trigger.

---
### Phase 1 – MVP
1. **Authentication**  
   *When the* user launches the app for the first time, *the* system shall create an anonymous session tied to the device.*  
   *When the* user chooses “Sign in”, *the* system shall authenticate via email/password, Google, or Apple.*  
   *When the* user signs in after using an anonymous session, *the* system shall migrate local tasks to the authenticated account.*
2. **Task CRUD**  
   *When the* user taps “Add”, *the* system shall create a new task with title, optional description, due date, and priority.*  
   *When the* user edits a task, *the* system shall update the task fields and mark `updated_at`.*  
   *When the* user completes a task, *the* system shall set `is_done = true` and move it to Completed.*  
   *When the* user deletes a task, *the* system shall remove it from local cache and backend.*
3. **Ordering & Sections**  
   *When the* user drags a task, *the* system shall update `order_index` to reflect new order in list.*  
   *Ubiquitous:* The system shall present tasks in Today, Upcoming, Completed sections based on due date and `is_done`.*
4. **Offline-first**  
   *When* network is unavailable, *the* system shall persist changes to local Isar DB and queue them for sync.*  
   *When* connectivity is restored, *the* system shall reconcile queued changes against backend using `updated_at` rule.*
5. **Realtime Sync**  
   *When* a remote change to user’s tasks occurs, *the* system shall push a UI update within 1 s.*
6. **UI/UX**  
   *Ubiquitous:* The system shall follow Material 3 design with light/dark themes.*
7. **Testing**  
   *Ubiquitous:* The system shall achieve ≥ 80 % unit + widget test coverage for Phase 1 scope.*

---
### Phase 2 – Productivity & Polish
1. **Natural-language Dates**  
   *When the* user types a due-date phrase (e.g. “tomorrow 5 pm”), *the* system shall parse and set `due_date` automatically.*
2. **Reminders**  
   *When the* task has a due date and reminders are enabled, *the* system shall schedule a local/push notification 10 min before due.*
3. **Recurring Tasks**  
   *When the* user sets recurrence, *the* system shall auto-generate the next instance upon completion.*
4. **Search & Filters**  
   *When the* user inputs a query, *the* system shall filter tasks by title, description, tag, status, or priority in under 100 ms.*
5. **Tags**  
   *When the* user labels a task, *the* system shall associate the selected tag color-chip.*

---
### Phase 3 – Collaboration
1. **Shared Lists**  
   *When the* user invites another user, *the* system shall add them to `list_members` with specified role.*
2. **Permissions**  
   *When* a viewer role user attempts to modify tasks, *the* system shall deny access and display an error.*
3. **Comments & Activity Log**  
   *When the* user comments on a task, *the* system shall append comment to activity log and broadcast via realtime channel.*

---
### Phase 4 – Enhancements (selected)
• *When the* user enables AI scheduling, *the* system shall suggest optimal due dates via Edge Function.*  
• *Ubiquitous:* The system shall encrypt all task content when E2E encryption is enabled.*  
• *Ubiquitous:* The system shall store analytics events anonymized to comply with GDPR.*

---
_End of EARS user stories._
