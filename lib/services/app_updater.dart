import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Downloads the release APK and opens the system installer.
class AppUpdater {
  AppUpdater({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> downloadAndInstall(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      throw const AppUpdaterException('لینک دانلود پیدا نشد');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      throw const AppUpdaterException('لینک دانلود نامعتبر است');
    }

    if (!Platform.isAndroid) {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw const AppUpdaterException('امکان باز کردن لینک نیست');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cakeyousef-update.apk');
    if (await file.exists()) {
      await file.delete();
    }

    final request = http.Request('GET', uri);
    request.headers['User-Agent'] = 'cakeyousef-android-app';
    final response = await _client.send(request).timeout(
          const Duration(minutes: 3),
        );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppUpdaterException(
        'دانلود ناموفق بود (${response.statusCode})',
      );
    }

    final total = response.contentLength ?? 0;
    var received = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          onProgress?.call(received / total);
        }
      }
      await sink.flush();
    } finally {
      await sink.close();
    }

    if (!await file.exists() || await file.length() < 1024) {
      throw const AppUpdaterException('فایل دانلود ناقص است');
    }

    onProgress?.call(1);
    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      // Fallback: open download URL in browser/downloader.
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        throw AppUpdaterException(
          result.message.isNotEmpty
              ? result.message
              : 'نصب‌کننده سیستم باز نشد',
        );
      }
    }
  }
}

class AppUpdaterException implements Exception {
  final String message;
  const AppUpdaterException(this.message);

  @override
  String toString() => message;
}
