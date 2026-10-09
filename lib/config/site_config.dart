class SiteConfig {
  static const siteUrl = 'https://www.cakeyousef.ir';

  /// GitHub repo used for in-app updates via Releases.
  /// Repository must be public so users can read releases and download APK.
  static const githubOwner = 'Pouya-Mohammadi-Parsa';
  static const githubRepo = 'cakeyousef';

  /// Latest published release (non-draft, non-prerelease).
  static const githubLatestReleaseUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  /// Public fallback JSON (useful if GitHub API is unreachable).
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
