# Todo App – Material 3 UX/UI Design Guide

This document summarizes modern Material Design 3 (M3) guidelines and current (2024-2025) mobile UX trends, with concrete recommendations for the Todo App’s visual and interaction design.

---

## 1  Theming & Branding

| Guideline | App Application |
|-----------|-----------------|
| **Dynamic color** (Material You) | Use `colorSchemeSeed` with user-selected seed; support Android 12+ dynamic colors when available. |
| **Light + Dark schemes** | Provide `ThemeMode.system`, ensuring WCAG contrast ≥ 4.5. |
| **Shape & Radius** | Default M3 radius (4 dp) for containers, **Fabs** 16 dp. |
| **Typography 2023 update** | Adopt `Display`, `Headline`, `Title`, `Body`, `Label` styles via `Typography.material2021()`. |

```dart
return MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
  ),
  darkTheme: ThemeData.dark(useMaterial3: true),
  themeMode: settings.themeMode,
);
```

---

## 2  Navigation Structure

| Screen Size | Pattern | Notes |
|-------------|---------|-------|
| Phone (<600 dp) | **Bottom Navigation Bar** (3 tabs: Today, Upcoming, Completed). | Keep labels visible, 80 dp height incl. system gesture area. |
| Foldable / Tablet | **Navigation Rail** on the left. | Auto‐hide behind hamburger <840 dp width. |
| Desktop | **Navigation Drawer** + Rail. | Drawer collapses to rail at ≤1200 dp. |

Use **large top app bar** with scroll behavior `SliverAppBar.medium()`; include actions: filter, settings.

---

## 3  Key Components

| Component | M3 Spec | App Use |
|-----------|---------|---------|
| **FAB** | Filled FAB, color = tertiary. | “Add Task” floating bottom-right, animates into modal sheet. |
| **Modal bottom sheet** | Elevated, corner radius = 24 dp. | Task creation / editing. Avoid keyboard overlap. |
| **Cards** | Elevated card + checkbox. | Task list items; use `ListTile` with leading status icon. |
| **Elevated Assist Chips** | For tags. | Scrollable horizontally in add/edit sheet. |
| **Date Picker** | `showDatePicker` M3 variant. | Due‐date selection. |
| **Snackbars** | Filled variant for confirmations/errors. | Auto-dismiss after 4 s. |

---

## 4  Motion & Interaction

* Use **implicit animations** (`AnimatedSwitcher`, `AnimatedList`) for inserting/removing tasks.
* **Container Transform** (Material Motion 2) from list item → edit sheet.
* Haptic feedback on task complete (`Feedback.forSelection(context)`).
* Swipe actions via `Dismissible` / `Slidable`:  
  • Right → Complete  
  • Left → Delete (confirm via snackbar Undo).

---

## 5  Accessibility & Responsiveness

* Minimum touch target 48 × 48 dp.
* Support dynamic type – text scales up to 200 % without overflow.
* Provide semantic labels for icons/buttons (`tooltip`, `Semantics`).
* High-contrast color scheme toggle in Settings.
* Respect `MediaQuery.padding` for gesture bars & notches.

---

## 6  Modern UX Trends (2024-2025)

1. **Personalization** – Dynamic color, user-selectable themes.
2. **Glanceable Widgets** – Plan to add home-screen widgets in Phase 3.
3. **Motion-minimalism** – Subtle, purposeful animations; no gratuitous motion.
4. **Micro-interactions** – Small feedback (haptics, animated icons) for task actions.
5. **Edge-to-Edge UI** – Use `SystemUiOverlayStyle` to draw behind status/navigation bars.
6. **Empty-state illustrations** – Use outlined icons + concise copy when no tasks.
7. **Privacy-forward UX** – Inform users about cloud sync & encryption (Phase 4).

---

## 7  Implementation Checklist

- [ ] Add `hooks_riverpod` providers for theme & settings.
- [ ] Implement `ThemeController` with dynamic color support.
- [ ] Build adaptive navigation (`AdaptiveScaffold`).
- [ ] Create `AddTaskSheet` as M3 modal.
- [ ] Animate list changes with `AnimatedList`.
- [ ] Verify accessibility with Flutter `accessibility_inspector`.

---

_Last updated: 2025-07-20_
