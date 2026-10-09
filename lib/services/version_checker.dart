import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../config/site_config.dart';

enum UpdateKind { none, soft, force }

class AppVersionInfo {
  final String latestVersion;
  final int latestBuild;
  final String minVersion;
  final String downloadUrl;
  final String message;

  const AppVersionInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.minVersion,
    required this.downloadUrl,
    required this.message,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: (json['latestVersion'] as String? ?? '0.0.0').trim(),
      latestBuild: _asInt(json['latestBuild']),
      minVersion: (json['minVersion'] as String? ?? '0.0.0').trim(),
      downloadUrl: (json['downloadUrl'] as String? ?? '').trim(),
      message: (json['message'] as String? ??
              'نسخه جدید با بهبودها آماده است.')
          .trim(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class UpdateCheckResult {
  final UpdateKind kind;
  final AppVersionInfo? remote;
  final String currentVersion;
  final int currentBuild;

  const UpdateCheckResult({
    required this.kind,
    required this.currentVersion,
    required this.currentBuild,
    this.remote,
  });

  bool get needsUpdate => kind != UpdateKind.none;
}

class VersionChecker {
  VersionChecker({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<UpdateCheckResult> check() async {
    final package = await PackageInfo.fromPlatform();
    final currentVersion = package.version;
    final currentBuild = int.tryParse(package.buildNumber) ?? 0;

    final remote = await _fetchRemote();
    if (remote == null || remote.downloadUrl.isEmpty) {
      return UpdateCheckResult(
        kind: UpdateKind.none,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );
    }

    return UpdateCheckResult(
      kind: _resolveKind(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        remote: remote,
      ),
      remote: remote,
      currentVersion: currentVersion,
      currentBuild: currentBuild,
    );
  }

  Future<AppVersionInfo?> _fetchRemote() async {
    final fromGithub = await _fetchGithubRelease();
    if (fromGithub != null) return fromGithub;
    return _fetchJsonFallback();
  }

  Future<AppVersionInfo?> _fetchGithubRelease() async {
    try {
      final response = await _client
          .get(
            Uri.parse(SiteConfig.githubLatestReleaseUrl),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'cakeyousef-android-app',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return _fromGithubRelease(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<AppVersionInfo?> _fetchJsonFallback() async {
    try {
      final response = await _client
          .get(
            Uri.parse(SiteConfig.appVersionUrl),
            headers: const {'User-Agent': 'cakeyousef-android-app'},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final info = AppVersionInfo.fromJson(decoded);
      if (info.downloadUrl.isEmpty) return null;
      return info;
    } catch (_) {
      return null;
    }
  }

  /// Expects tag like `1.0.2`, `v1.0.2`, or `1.0.2+3`.
  /// Optional body line: `minVersion: 1.0.0`
  static AppVersionInfo? _fromGithubRelease(Map<String, dynamic> json) {
    final tag = (json['tag_name'] as String? ?? '').trim();
    if (tag.isEmpty) return null;

    final parsed = _parseTag(tag);
    final downloadUrl = _apkDownloadUrl(json['assets']) ??
        _fallbackDownloadUrl(tag: tag, version: parsed.version);
    if (downloadUrl == null || downloadUrl.isEmpty) return null;

    final body = (json['body'] as String? ?? '').trim();
    final name = (json['name'] as String? ?? '').trim();
    final minVersion = _minVersionFromBody(body) ?? '0.0.0';
    final message = body.isNotEmpty
        ? body
        : (name.isNotEmpty ? name : 'نسخه جدید با بهبودها آماده است.');

    return AppVersionInfo(
      latestVersion: parsed.version,
      latestBuild: parsed.build,
      minVersion: minVersion,
      downloadUrl: downloadUrl,
      message: message.length > 400 ? '${message.substring(0, 400)}…' : message,
    );
  }

  static String? _fallbackDownloadUrl({
    required String tag,
    required String version,
  }) {
    final encodedTag = Uri.encodeComponent(tag);
    return 'https://github.com/${SiteConfig.githubOwner}/${SiteConfig.githubRepo}/releases/download/$encodedTag/cakeyousef-$version.apk';
  }

  static ({String version, int build}) _parseTag(String tag) {
    var raw = tag.trim();
    if (raw.toLowerCase().startsWith('v')) {
      raw = raw.substring(1);
    }

    var version = raw;
    var build = 0;
    final plus = raw.indexOf('+');
    if (plus >= 0) {
      version = raw.substring(0, plus);
      build = int.tryParse(raw.substring(plus + 1).trim()) ?? 0;
    }

    version = version.trim();
    if (version.isEmpty) version = '0.0.0';
    return (version: version, build: build);
  }

  static String? _apkDownloadUrl(dynamic assets) {
    if (assets is! List) return null;
    String? fallback;
    for (final item in assets) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = (map['name'] as String? ?? '').toLowerCase();
      final url = (map['browser_download_url'] as String? ?? '').trim();
      if (url.isEmpty || !name.endsWith('.apk')) continue;
      if (name.contains('cakeyousef') || name.contains('release')) {
        return url;
      }
      fallback ??= url;
    }
    return fallback;
  }

  static String? _minVersionFromBody(String body) {
    final match = RegExp(
      r'minVersion\s*[:=]\s*([0-9]+(?:\.[0-9]+)*)',
      caseSensitive: false,
    ).firstMatch(body);
    return match?.group(1);
  }

  UpdateKind _resolveKind({
    required String currentVersion,
    required int currentBuild,
    required AppVersionInfo remote,
  }) {
    if (remote.minVersion != '0.0.0' &&
        _compareVersions(currentVersion, remote.minVersion) < 0) {
      return UpdateKind.force;
    }

    final behindLatestVersion =
        _compareVersions(currentVersion, remote.latestVersion) < 0;
    final sameVersionNewerBuild =
        _compareVersions(currentVersion, remote.latestVersion) == 0 &&
            currentBuild < remote.latestBuild;
    if (behindLatestVersion || sameVersionNewerBuild) {
      return UpdateKind.soft;
    }

    return UpdateKind.none;
  }

  static int compareVersions(String a, String b) => _compareVersions(a, b);

  static int _compareVersions(String a, String b) {
    final left = _parseParts(a);
    final right = _parseParts(b);
    final len = left.length > right.length ? left.length : right.length;
    for (var i = 0; i < len; i++) {
      final l = i < left.length ? left[i] : 0;
      final r = i < right.length ? right[i] : 0;
      if (l < r) return -1;
      if (l > r) return 1;
    }
    return 0;
  }

  static List<int> _parseParts(String version) {
    return version
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .toList(growable: false);
  }
}
