import 'package:flutter/foundation.dart';

class ApiConfig {
  /// On web debug, traffic goes through [tool/cors_proxy.dart] (localhost:8787)
  /// because `/api/content/*` has no CORS headers on the remote server.
  static String get host {
    if (kIsWeb && kDebugMode) return 'http://127.0.0.1:8787';
    return 'http://62.60.222.55';
  }

  static String get baseUrl => '$host/api/v1';

  /// Relative media paths → absolute URL on API host.
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$host$path';
    return '$host/$path';
  }
}
