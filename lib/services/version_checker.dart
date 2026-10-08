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
  VersionChecker({http.Client? client, String? versionUrl})
      : _client = client ?? http.Client(),
        _versionUrl = versionUrl ?? SiteConfig.appVersionUrl;

  final http.Client _client;
  final String _versionUrl;

  Future<UpdateCheckResult> check() async {
    final package = await PackageInfo.fromPlatform();
    final currentVersion = package.version;
    final currentBuild = int.tryParse(package.buildNumber) ?? 0;

    try {
      final response = await _client
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return UpdateCheckResult(
          kind: UpdateKind.none,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return UpdateCheckResult(
          kind: UpdateKind.none,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
        );
      }

      final remote = AppVersionInfo.fromJson(decoded);
      final kind = _resolveKind(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        remote: remote,
      );

      return UpdateCheckResult(
        kind: kind,
        remote: remote,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );
    } catch (_) {
      // Network / parse errors: skip silently so the app still opens.
      return UpdateCheckResult(
        kind: UpdateKind.none,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );
    }
  }

  UpdateKind _resolveKind({
    required String currentVersion,
    required int currentBuild,
    required AppVersionInfo remote,
  }) {
    if (_compareVersions(currentVersion, remote.minVersion) < 0) {
      return UpdateKind.force;
    }

    final behindLatestVersion =
        _compareVersions(currentVersion, remote.latestVersion) < 0;
    final behindLatestBuild = currentBuild < remote.latestBuild;
    if (behindLatestVersion || behindLatestBuild) {
      return UpdateKind.soft;
    }

    return UpdateKind.none;
  }

  /// Compares dotted versions like `1.0.2`. Returns -1 / 0 / 1.
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
