# Navigation Contract — مدبّر

## Rule: Two navigation patterns, each for a specific purpose

### 1. `context.go(AppRoutes.X)` — Shell routes (bottom nav visible)
Use for routes that are part of the main shell (bottom nav stays visible).
These routes are declared inside `ShellRoute` in `app_router.dart`.

**Shell routes:**
- `/home` → DailyScreen
- `/expenses` → ExpensesScreen
- `/goals` → GoalsScreen
- `/reports` → ReportsScreen
- `/chat` → ChatScreen

```dart
// ✅ correct
context.go(AppRoutes.expenses);

// ❌ wrong — pushes over shell, hides bottom nav
Navigator.push(context, MaterialPageRoute(builder: (_) => ExpensesScreen(...)));
```

### 2. `Navigator.push()` — Secondary screens (no bottom nav)
Use for screens that appear OVER the shell as a full-screen overlay.
These are standalone routes declared outside `ShellRoute`.

**Secondary screens:**
- `/income` → IncomeScreen (accessed from Daily header icon)
- `/settings` → SettingsScreen (accessed from Daily header icon)
- `ApiKeySetupScreen` (accessed from Chat screen)

```dart
// ✅ correct
Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));

// ❌ wrong — replaces shell, user loses back button
context.go(AppRoutes.settings);
```

### 3. `Navigator.pop()` / `context.popScreen()` — Dismiss overlays
Use for dismissing bottom sheets, dialogs, and secondary screens.

```dart
// ✅ correct — from a secondary screen
Navigator.of(context).pop();
context.popScreen(); // extension alias

// ❌ wrong — from a secondary screen going back to daily
context.go(AppRoutes.home); // only use inside shell routes
```

## Summary table

| Where you are | Want to go to | Use |
|---|---|---|
| Shell route | Another shell route | `context.go()` |
| Shell route | Secondary screen | `Navigator.push()` |
| Secondary screen | Back | `context.popScreen()` |
| Bottom sheet / dialog | Dismiss | `Navigator.pop()` |
