class SiteConfig {
  static const siteUrl = 'https://www.cakeyousef.ir';

  /// Public JSON used by the app to detect soft/force updates.
  static const appVersionUrl = '$siteUrl/app-version.json';

  static String courseCheckoutUrl(String? slug) {
    if (slug == null || slug.isEmpty) return siteUrl;
    return '$siteUrl/course/${Uri.encodeComponent(slug)}';
  }

  static String productCheckoutUrl(String? id) {
    if (id == null || id.isEmpty) return '$siteUrl/shop';
    return '$siteUrl/product/${Uri.encodeComponent(id)}';
  }
}
