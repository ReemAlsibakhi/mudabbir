<div align="center">

# مدبّر 🏦

### تطبيق إدارة المصروف العائلي العربي
**Arabic Family Budget App — Phase 1 Complete**

[![Flutter](https://img.shields.io/badge/Flutter-3.22-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4-blue?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-green)](https://github.com/ReemAlsibakhi/mudabbir)

</div>

---

## ✅ المرحلة الأولى — مكتملة

| الميزة | الحالة |
|--------|--------|
| 🏗️ Clean Architecture (Domain/Data/Presentation) | ✅ |
| 🌍 22 دولة عربية + كشف تلقائي | ✅ |
| 👤 4 مراحل حياة (أعزب/مخطوب/متزوج/أسرة) | ✅ |
| 📋 Onboarding Flow كامل | ✅ |
| 🌙 شاشة اليوم + Quick Add | ✅ |
| 🔥 نظام السلسلة (Streak) | ✅ |
| 💰 إدارة الدخل الشهري | ✅ |
| 💸 المصاريف (ثابت + يومي) | ✅ |
| 🎯 الأهداف المالية مع حاسبة ذكية | ✅ |
| 📈 التقارير (شهري + مقارنة + أهداف) | ✅ |
| 🦁 شخصية الأسرة (أسد/نمر/ثعلب...) | ✅ |
| 🔔 نظام الإشعارات | ✅ |
| ⚙️ الإعدادات + الخصوصية | ✅ |
| Result\<T\> — كل الحالات مغطاة | ✅ |
| GoRouter + NavigationShell | ✅ |

---

## 🏗️ البنية التقنية

```
lib/
├── core/                    # لا يعتمد على أي feature
│   ├── constants/           # App constants, countries, categories
│   ├── errors/              # Result<T> + sealed Failures
│   ├── extensions/          # DateTime, double, String, BuildContext
│   ├── router/              # GoRouter + redirect guard
│   ├── theme/               # AppColors, AppTextStyles, AppTheme
│   └── utils/               # Validators, AppLogger
│
├── shared/
│   ├── data/models/         # Hive models (UserModel, Expense, Goal...)
│   └── ui/widgets/          # MudCard, MudButton, MudProgressBar...
│
└── features/
    └── [feature]/
        ├── domain/
        │   ├── entities/    # Pure Dart + Equatable + copyWith
        │   ├── repositories/ # abstract interface
        │   └── usecases/    # Business logic + ALL cases
        ├── data/
        │   └── repositories/ # Hive implementation + safe decode
        └── presentation/
            ├── providers/   # sealed State + StateNotifier
            ├── screens/     # UI only — no logic
            └── widgets/     # single responsibility each
```

---

## ⚡ Cases Coverage

كل UseCase يغطي:
- ✅ **Happy Path** — السيناريو الطبيعي
- ❌ **Unhappy Path** — الفشل المتوقع
- ⚠️ **Edge Cases** — الحالات الغريبة

مثال:
```dart
// Arabic numerals → normalized automatically
// Future dates → rejected
// amount > 100M → rejected
// Corrupted Hive data → safe default returned
// Widget disposed mid-save → mounted guard
// Stream error → continues (cancelOnError: false)
// Division by zero → never (clamp + guard)
```

---

## 🚀 تشغيل المشروع

```bash
# 1. Clone
git clone https://github.com/ReemAlsibakhi/mudabbir.git
cd mudabbir

# 2. Install dependencies
flutter pub get

# 3. Generate Hive adapters (REQUIRED before running)
dart run build_runner build --delete-conflicting-outputs

# 4. Run
flutter run

# 5. Build APK
flutter build apk --release
```

---

## 📋 الخطوات المتبقية قبل النشر

```bash
# أ. أضف خط Cairo من Google Fonts إلى assets/fonts/
# ب. أضف أيقونة التطبيق إلى assets/icons/
# ج. flutter_launcher_icons لتوليد الأيقونات
# د. اختبر على Android + iOS device حقيقي
# هـ. flutter build apk --release
# و. Google Play Console → Internal Testing
```

---

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.22 |
| State | Riverpod 2 (StateNotifier + autoDispose) |
| Local DB | Hive (Plain + Typed boxes) |
| Navigation | GoRouter 13 |
| Notifications | flutter_local_notifications |
| Error Handling | Result\<T\> sealed class |
| Architecture | Feature-Sliced Clean Architecture |

---

<div align="center">

**صُنع بـ ❤️ للأسرة العربية — 22 دولة، ثقافة واحدة**

</div>
