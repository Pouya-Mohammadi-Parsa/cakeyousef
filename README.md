# CakeAcademy / کیک‌اکادمی

آکادمی آنلاین کیک و شیرینی — اپ موبایل Flutter (Android / iOS).

## اجرا

```bash
flutter pub get
flutter run
```

فونت Vazirmatn از `assets/fonts` و در صورت نیاز از طریق `google_fonts` بارگذاری می‌شود.

## انتشار آپدیت (GitHub Releases)

1. APK را بساز: `flutter build apk --release`
2. در GitHub یک Release بساز با تگ مثل `1.0.1` یا `1.0.1+2` (`نسخه+بیلد`)
3. فایل `.apk` را به Assets همان Release اضافه کن
4. اپ از `releases/latest` ورژن و لینک دانلود را می‌خواند

اختیاری در توضیحات Release: `minVersion: 1.0.0` برای آپدیت اجباری.
