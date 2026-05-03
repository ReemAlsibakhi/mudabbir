# iOS Setup — تثبيت على الآيفون

## الخطوة الوحيدة المطلوبة منك (دقيقتان)

### 1. افتحي Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. أضيفي Apple ID
- اضغطي **Runner** في الشريط الأيسر
- اختاري **Runner** تحت TARGETS
- اذهبي لـ **Signing & Capabilities**
- من **Team** → **Add an Account** → سجّلي بأي Apple ID

### 3. شغّلي على الجهاز
- وصّلي الآيفون بالـ Mac عبر USB
- اختاري اسم الجهاز من القائمة العلوية ▼
- اضغطي ▶️

### 4. ثقي بالشهادة على الآيفون
```
Settings → General → VPN & Device Management
→ [اسمك] → Trust
```

---

## أو من Terminal مباشرة
```bash
# تأكدي من توصيل الجهاز وفتح Xcode أولاً
flutter run -d [device-id]

# لمعرفة ID الجهاز
flutter devices
```

---

## ملاحظة
- الحساب المجاني يعمل 7 أيام ثم يحتاج إعادة تثبيت
- Bundle ID: com.mudabbir.reemapp
