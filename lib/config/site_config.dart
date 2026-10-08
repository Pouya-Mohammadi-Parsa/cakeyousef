class SiteConfig {
  static const siteUrl = 'https://www.cakeyousef.ir';

  /// GitHub repo used for in-app updates via Releases.
  static const githubOwner = 'Pouya-Mohammadi-Parsa';
  static const githubRepo = 'cakeyousef';

  /// Latest published release (non-draft, non-prerelease).
  static const githubLatestReleaseUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static String courseCheckoutUrl(String? slug) {
    if (slug == null || slug.isEmpty) return siteUrl;
    return '$siteUrl/course/${Uri.encodeComponent(slug)}';
  }

  static String productCheckoutUrl(String? id) {
    if (id == null || id.isEmpty) return '$siteUrl/shop';
    return '$siteUrl/product/${Uri.encodeComponent(id)}';
  }
}
