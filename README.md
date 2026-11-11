# Finale Task Core

A high-response task and habit engine inspired by **Finale To Do**, engineered with **Cupertino-First iOS HIG ergonomics (60/120fps physics)** and a **Minecraft Voxel / Pixel-Art aesthetic**, targeting **Android SDK 34+** and **iOS**.

---

## Core Architecture & Tech Stack
- **Framework:** Flutter (Dart 3, Android `compileSdk = 34` / `targetSdk = 34`, iOS Cupertino)
- **Architecture:** Clean MVVM (`domain/`, `data/`, `ui/`) with strict separation of concerns
- **State Management:** `Provider` (`ChangeNotifier` ViewModels & single-source-of-truth Repository)
- **Persistence:** Offline-first `sqflite` SQLite database (`tasks` & `habits` tables) synchronized with `SharedPreferences` + full JSON snapshot export/import
- **Physics & Micro-Interactions:**
  - `SpringSimulation(SpringDescription(mass: 1, stiffness: 300, damping: 25))` for interactive gestures and `PressableScale` buttons
  - `BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())` on all scroll views
  - GPU-composited animations (`Transform`, `Opacity`, `ScaleTransition`, `FadeTransition`) wrapped in `RepaintBoundary`
  - Centralized `HapticService` (`lightImpact`, `mediumImpact`, `selectionClick`, `heavyImpact`)

---

## Functional Specifications Implemented

1. **Home / Main Task Screen (`lib/ui/features/tasks/`)**
   - Chronological task grouping: `Today`, `Upcoming`, `Completed`.
   - **Tactile Dismiss Gesture (`TactileDismissTaskCard`):** Horizontal slide-to-mine gesture replacing static checkboxes, triggering `HapticFeedback.mediumImpact()` upon crossing the completion threshold and animating out smoothly.
   - **Quick Task Creator (`QuickTaskCreatorSheet`):** Frosted modal bottom sheet (`ImageFilter.blur(sigmaX: 15, sigmaY: 15)`) with top pill handle (`36x5`), required Title, optional Due Date/Time (`CupertinoDatePicker`), and Priority/Tag (`Low`, `Medium`, `High`).
   - **Gamification Hook:** Awards `+10 XP` per task and `+5 XP` on-time bonus when completed on or before the due timestamp.

2. **Habit Tracker Screen (`lib/ui/features/habits/`)**
   - Daily frequency toggles (`CupertinoSwitch`) + 7-day interactive hotbar slots.
   - Consecutive day streak engine (`StreakCalculator`) with configurable grace period (`0d`, `1d`, `2d`) before reset.
   - Segmented voxel progress bar calculating today's completion percentage (`Completed Habits / Total Active Habits`).

3. **Progression & Stats Screen (`lib/ui/features/progression/`)**
   - **User Level Engine:** $\text{Level} = \lfloor\sqrt{\text{XP} / 100}\rfloor + 1$.
   - Displays Current Level, Current XP, and XP required for next level.
   - Displays Total tasks completed, Current task completion streak, and On-time completion rate percentage.

4. **Settings & Data Management Screen (`lib/ui/features/settings/`)**
   - Built with `CupertinoListSection.insetGrouped` and `CupertinoListTile`.
   - Export database to JSON & Import from JSON.
   - Reset progression & data action with destructive `CupertinoAlertDialog` confirmation.
   - Vibration/haptics `CupertinoSwitch`.
