# CakeAcademy / کیک‌اکادمی

آکادمی آنلاین کیک و شیرینی — اپ موبایل Flutter (Android / iOS).

## اجرا

```bash
flutter pub get
flutter run
```

## انتشار آپدیت (GitHub Releases)

ریپو باید **Public** باشد تا اپ بتواند Release و APK را بدون لاگین بخواند.

1. ورژن را در `pubspec.yaml` بالا ببر (مثلاً `1.0.1+2`)
2. بیلد بگیر:
   ```bash
   flutter build apk --release
   ```
3. فایل را به نام `cakeyousef-1.0.1.apk` کپی کن
4. در GitHub → Releases → New release:
   - Tag: `1.0.1` (یا `1.0.1+2`)
   - Asset: همان فایل `.apk`
5. (اختیاری) `app-version.json` را روی سایت هم آپلود کن (fallback)

در سایدبار: نسخه فعلی / نسخه جدید + دکمه «دانلود و بروزرسانی».
