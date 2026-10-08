class ApiConfig {
  static const String host = 'http://62.60.222.55';

  static String get baseUrl => '$host/api/v1';

  /// Relative media paths → absolute URL on API host.
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$host$path';
    return '$host/$path';
  }
}
