class ApiConfig {
  /// Production host from APP_DEVELOPER_API guide (Nginx :80 only).
  static const String host = 'http://62.60.188.164';

  static String get baseUrl => '$host/api/v1';

  /// Deep link after WebView / browser login.
  static const String authRedirectUri = 'cakeyousef://auth';

  /// Deep link after Zarinpal payment (wired with checkout later).
  static const String paymentRedirectUri = 'cakeyousef://payment';

  /// Relative media paths → absolute URL on API host.
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$host$path';
    return '$host/$path';
  }
}
