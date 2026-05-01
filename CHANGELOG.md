# Changelog — مدبّر

All notable changes are documented here.
Format: `[version] — date: what changed and why`

---

## [2.1.0] — 2025-05 — Code Quality Sprint

### Architecture improvements
- **ArabicParser** utility extracted — single place for Arabic digit
  normalization, amount parsing, and int parsing. Previously duplicated
  in AddExpenseUseCase, SaveIncomeUseCase, and income_form.dart.
- **UseCases injected into Notifiers** — ExpensesNotifier now receives
  AddExpenseUseCase, AddFixedExpenseUseCase, DeleteExpenseUseCase via
  constructor. Enables clean unit testing without touching business logic.
- **Shared repo Providers** — one `expenseRepoProvider`, `incomeRepoProvider`,
  `goalRepoProvider` per feature. ChatNotifier and ReportsProvider reuse
  these instead of creating separate Hive connections.
- **DateTimeExtension** — `.monthKey` and `.dateKey` now the single source
  of truth for Hive key formatting (was duplicated in 9 files).

### Reliability
- **HiveMigrator** — schema versioning added. Existing users silently
  migrate from v0 (unversioned) to v1. Future fields added to UserModel
  can be backfilled safely without data loss.
- **AppStrings** — all 55+ user-facing Arabic strings centralized.
  ClaudeApiService, UseCases, and Notifiers now reference constants.

### Testing
- `arabic_parser_test.dart` — 14 tests covering normalization, amount
  validation, optional parsing, and integer parsing.
- `expenses_notifier_test.dart` — tests with ProviderContainer overrides,
  verifying injected UseCase behavior end-to-end.

### Documentation
- `NAVIGATION.md` — documents the `context.go()` vs `Navigator.push()`
  contract so future developers add screens correctly.
- `CHANGELOG.md` — this file.

---

## [2.0.0] — 2025-04 — Phase 2 Launch

### New features
- **AI Chat** — Claude Haiku integration with financial context injection
- **PDF Export** — monthly report generation
- **GPS Location** — geofencing infrastructure
- **Freemium** — subscription entity with feature gates

### Phase 1 completion
- All 6 main screens: Daily, Expenses, Income, Goals, Reports, Settings
- Onboarding flow with 4 life stages
- 22 Arab countries with currency support
- Streak system with rescue tokens
- 5 notification types

---

## [1.0.0] — 2025-04 — MVP

- Initial release
- Clean Architecture with Hive offline-first storage
- Riverpod state management
- GoRouter navigation with ShellRoute
- RTL Arabic support
