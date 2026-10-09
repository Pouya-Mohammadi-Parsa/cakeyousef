class ApiConfig {
  /// Production host (Nginx :80). Live routes are under `/api/*`
  /// (not `/api/v1` — that path currently returns the Next.js HTML 404).
  static const String host = 'http://62.60.188.164';

  /// Account / locations / content live under `/api`.
  static String get baseUrl => '$host/api';

  /// Mobile JWT auth from the developer guide (`/api/v1/auth/...`).
  /// Kept separate so account calls keep working while v1 is being proxied.
  static String get authBaseUrl => '$host/api/v1';

  /// Deep link after WebView / browser login.
  static const String authRedirectUri = 'cakeyousef://auth';

  /// Deep link after Zarinpal payment (wired with checkout later).
  static const String paymentRedirectUri = 'cakeyousef://payment';

  /// Browser login page (Option A). Same shape as authorizeUrl in the API guide.
  static String appLoginUrl({
    String redirectUri = authRedirectUri,
  }) {
    final q = Uri.encodeQueryComponent(redirectUri);
    return '$host/app-login?redirect_uri=$q';
  }

  /// Relative media paths → absolute URL on API host.
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$host$path';
    return '$host/$path';
  }
}
