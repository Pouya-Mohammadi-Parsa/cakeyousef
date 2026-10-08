class SiteConfig {
  static const siteUrl = 'https://www.cakeyousef.ir';

  static String courseCheckoutUrl(String? slug) {
    if (slug == null || slug.isEmpty) return siteUrl;
    return '$siteUrl/course/${Uri.encodeComponent(slug)}';
  }

  static String productCheckoutUrl(String? id) {
    if (id == null || id.isEmpty) return '$siteUrl/shop';
    return '$siteUrl/product/${Uri.encodeComponent(id)}';
  }
}
