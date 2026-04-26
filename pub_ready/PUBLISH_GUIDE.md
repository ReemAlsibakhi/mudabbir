# 🚀 دليل نشر مدبّر على Google Play — خطوة بخطوة

---

## الخطوة 1: تحضير الكود (على جهازك)

```bash
cd mudabbir
git pull origin main
flutter pub get
```

---

## الخطوة 2: إضافة خط Cairo

1. اذهبي لـ fonts.google.com/specimen/Cairo
2. حمّلي: Regular 400, SemiBold 600, Bold 700, ExtraBold 800, Black 900
3. ضعي الملفات في: `assets/fonts/`
   ```
   assets/fonts/
     Cairo-Regular.ttf
     Cairo-SemiBold.ttf
     Cairo-Bold.ttf
     Cairo-ExtraBold.ttf
     Cairo-Black.ttf
   ```

---

## الخطوة 3: تحديث AndroidManifest.xml

انسخي ملف `pub_ready/android/AndroidManifest.xml` إلى:
```
android/app/src/main/AndroidManifest.xml
```

---

## الخطوة 4: تحديث build.gradle

انسخي محتوى `pub_ready/android/app_build.gradle` إلى:
```
android/app/build.gradle
```

وهذا السطر في `android/build.gradle`:
```groovy
// تأكد أن kotlin_version = '1.9.10'
ext.kotlin_version = '1.9.10'
```

---

## الخطوة 5: إنشاء Keystore (مرة واحدة فقط)

```bash
# في مجلد android/
keytool -genkey -v \
  -keystore mudabbir-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias mudabbir

# ستُطلب منك:
# - كلمة مرور القائمة
# - اسمك
# - اسم المنظمة (اكتبي mudabbir)
# - الدولة (SA)
```

احفظي الملف وكلمة المرور في مكان آمن — لا يمكن استعادتهما!

---

## الخطوة 6: ملف key.properties

أنشئي ملف `android/key.properties` (لا ترفعيه على GitHub!):

```properties
storePassword=كلمة_المرور_هنا
keyPassword=كلمة_المرور_هنا
keyAlias=mudabbir
storeFile=../android/mudabbir-release.jks
```

أضيفي هذا لـ `.gitignore`:
```
android/key.properties
android/*.jks
```

---

## الخطوة 7: أيقونة التطبيق

1. افتحي `pub_ready/assets/icons/app_icon.svg` في Figma أو أي برنامج
2. صدّري PNG بحجم 1024x1024
3. احفظيها كـ `assets/icons/app_icon.png`
4. ثم شغّلي:

```bash
dart run flutter_launcher_icons
```

---

## الخطوة 8: شاشة التحميل (Splash)

1. صمّمي صورة `assets/icons/splash_logo.png` (512x512)
2. شغّلي:
```bash
dart run flutter_native_splash:create
```

---

## الخطوة 9: بناء APK للاختبار أولاً

```bash
flutter build apk --release

# الملف سيكون في:
# build/app/outputs/flutter-apk/app-release.apk
```

أرسليه لنفسك وجرّبيه على هاتف حقيقي!

---

## الخطوة 10: بناء App Bundle (للنشر)

```bash
flutter build appbundle --release

# الملف:
# build/app/outputs/bundle/release/app-release.aab
```

`.aab` أصغر من `.apk` وتفضّله Google Play.

---

## الخطوة 11: Google Play Console

1. اذهبي لـ play.google.com/console
2. ادفعي $25 رسوم التسجيل (مرة واحدة)
3. أنشئي تطبيقاً جديداً
4. المعلومات المطلوبة:
   - الاسم: مدبّر
   - اللغة الافتراضية: Arabic (Saudi Arabia)
   - النوع: Application
   - الفئة: Finance

---

## الخطوة 12: رفع .aab

في Play Console:
1. Production → Create new release
2. ارفعي ملف `app-release.aab`
3. أضيفي Release notes بالعربي:
   ```
   الإصدار 2.0.0
   - إضافة المستشار الذكي (Claude AI)
   - دعم 22 دولة عربية
   - شاشة الأهداف المالية
   - سلسلة الانضباط اليومي
   ```

---

## الخطوة 13: إعداد Store Listing

انسخي المحتوى من `pub_ready/play_store_listing.md`:
- Short description (80 حرف)
- Full description
- Screenshots (6 صور)
- Privacy policy URL: https://mudabbir.netlify.app/privacy.html

---

## الخطوة 14: Content Rating

أجيبي على الأسئلة:
- Violence: None
- Sexual content: None
- Language: None
- Controlled substances: None
- النتيجة المتوقعة: **Everyone (3+)**

---

## الخطوة 15: نشر الموقع

```bash
# اذهبي لـ netlify.com/drop
# اسحبي مجلد web/ وأفلتيه
# انسخي الرابط → ضعيه في Play Console
```

---

## ترتيب الأوامر الكامل على جهازك:

```bash
# 1. تحضير
git pull && flutter pub get

# 2. أيقونة + splash (بعد وضع الصور)
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 3. تأكد من كل شيء
flutter analyze
flutter test

# 4. بناء
flutter build appbundle --release

# 5. الملف الجاهز
open build/app/outputs/bundle/release/
```

---

## ✅ Checklist قبل النشر

- [ ] Cairo fonts في assets/fonts/
- [ ] app_icon.png 1024x1024
- [ ] key.properties + .jks جاهز
- [ ] AndroidManifest.xml محدّث
- [ ] build.gradle محدّث
- [ ] flutter test → كل الاختبارات تمر
- [ ] flutter analyze → لا warnings
- [ ] اختبار APK على هاتف حقيقي
- [ ] الموقع منشور على Netlify
- [ ] Privacy policy URL جاهز
- [ ] Play Console account مفعّل ($25)

---

🎉 عندما تنشرين التطبيق، أرسليلي الرابط!
