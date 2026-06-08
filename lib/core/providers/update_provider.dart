import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  static const String forkLatestReleaseUrl =
      'https://api.github.com/repos/ShinozakiKasumi/kelivo/releases/latest';

  final String app;
  final String version;
  final int? build;
  final DateTime? releasedAt;
  final String? notes;
  final bool mandatory;
  final Map<String, String> downloads;

  const UpdateInfo({
    required this.app,
    required this.version,
    this.build,
    this.releasedAt,
    this.notes,
    this.mandatory = false,
    this.downloads = const {},
  });

  String? bestDownloadUrl() {
    if (Platform.isIOS) {
      return downloads['ios'] ??
          downloads['iosAppStore'] ??
          downloads['universal'];
    }
    if (Platform.isAndroid) {
      return downloads['android'] ?? downloads['universal'];
    }
    if (Platform.isMacOS) {
      return downloads['macos'] ??
          downloads['mac'] ??
          downloads['darwin'] ??
          downloads['universal'];
    }
    if (Platform.isWindows) {
      return downloads['windows'] ?? downloads['win'] ?? downloads['universal'];
    }
    if (Platform.isLinux) {
      return downloads['linux'] ?? downloads['universal'];
    }
    return downloads['universal'] ?? downloads['android'] ?? downloads['ios'];
  }

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('tag_name')) {
      return UpdateInfo.fromGitHubRelease(json);
    }

    final latest = (json['latest'] as Map?) ?? const {};
    final downloads =
        (latest['downloads'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ??
        const {};
    DateTime? released;
    final releasedRaw = latest['releasedAt']?.toString();
    if (releasedRaw != null && releasedRaw.isNotEmpty) {
      try {
        released = DateTime.parse(releasedRaw);
      } catch (_) {}
    }
    return UpdateInfo(
      app: (json['app'] ?? '').toString(),
      version: (latest['version'] ?? '').toString(),
      build: int.tryParse((latest['build'] ?? '').toString()),
      releasedAt: released,
      notes: (latest['notes'] ?? '').toString(),
      mandatory: (latest['mandatory'] as bool?) ?? false,
      downloads: downloads,
    );
  }

  factory UpdateInfo.fromGitHubRelease(Map<String, dynamic> json) {
    final rawTag = json['tag_name']?.toString();
    final rawName = json['name']?.toString();
    final fullVersion = _normalizeGitHubReleaseVersion(rawTag ?? rawName ?? '');
    final version = _displayVersion(fullVersion);
    final body = json['body']?.toString();
    final releasedAt = _tryParseDate(json['published_at']?.toString());
    final assets = json['assets'] as List? ?? const [];
    final downloads = <String, String>{};
    for (final asset in assets) {
      if (asset is! Map) continue;
      final url = asset['browser_download_url']?.toString();
      if (url == null || url.isEmpty) continue;
      final name = asset['name']?.toString().toLowerCase() ?? '';
      if (name.endsWith('.apk')) {
        downloads['android'] = url;
      } else if (name.endsWith('.ipa')) {
        downloads['ios'] = url;
      } else if (name.endsWith('.dmg') || name.contains('macos')) {
        downloads['macos'] = url;
      } else if (name.endsWith('.exe') || name.endsWith('.msix')) {
        downloads['windows'] = url;
      } else if (name.endsWith('.appimage') || name.endsWith('.deb')) {
        downloads['linux'] = url;
      }
    }

    final htmlUrl = json['html_url']?.toString();
    if (htmlUrl != null && htmlUrl.isNotEmpty) {
      downloads.putIfAbsent('universal', () => htmlUrl);
    }

    return UpdateInfo(
      app: 'Kelivo',
      version: version,
      build: _buildNumberFromVersion(fullVersion),
      releasedAt: releasedAt,
      notes: body,
      mandatory: false,
      downloads: downloads,
    );
  }

  static DateTime? _tryParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static String _normalizeGitHubReleaseVersion(String version) {
    final trimmed = version.trim();
    if (trimmed.startsWith('v') || trimmed.startsWith('V')) {
      return trimmed.substring(1);
    }
    return trimmed;
  }

  static int? _buildNumberFromVersion(String version) {
    final plusIndex = version.indexOf('+');
    if (plusIndex == -1 || plusIndex == version.length - 1) return null;
    return int.tryParse(version.substring(plusIndex + 1));
  }

  static String _displayVersion(String version) {
    final plusIndex = version.indexOf('+');
    if (plusIndex == -1) return version;
    return version.substring(0, plusIndex);
  }
}

class UpdateProvider extends ChangeNotifier {
  UpdateInfo? _available;
  UpdateInfo? get available => _available;
  bool _checking = false;
  bool get checking => _checking;
  String? _error;
  String? get error => _error;

  Future<void> checkForUpdates() async {
    if (_checking) return;
    _checking = true;
    _error = null;
    notifyListeners();
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse('${UpdateInfo.forkLatestReleaseUrl}?kelivo=$ts');
      final resp = await http.get(
        url,
        headers: const {'Accept': 'application/vnd.github+json'},
      );
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }
      final data =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final info = UpdateInfo.fromJson(data);

      final pkg = await PackageInfo.fromPlatform();
      final currentVer = pkg.buildNumber.trim().isEmpty
          ? pkg.version
          : '${pkg.version}+${pkg.buildNumber}';
      final remoteVer = info.build == null
          ? info.version
          : '${info.version}+${info.build}';

      final hasNew = _isRemoteNewer(
        remoteVersion: remoteVer,
        currentVersion: currentVer,
      );
      _available = hasNew ? info : null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  bool _isRemoteNewer({
    required String remoteVersion,
    required String currentVersion,
  }) {
    final remote = _parseVersion(remoteVersion);
    final current = _parseVersion(currentVersion);
    for (var i = 0; i < 3; i++) {
      if (remote.core[i] != current.core[i]) {
        return remote.core[i] > current.core[i];
      }
    }

    if (remote.preRelease != current.preRelease) {
      if (remote.preRelease.isEmpty) return true;
      if (current.preRelease.isEmpty) return false;
      final preCompare = _comparePreRelease(
        remote.preRelease,
        current.preRelease,
      );
      if (preCompare != 0) return preCompare > 0;
    }

    if (remote.build != null && current.build != null) {
      return remote.build! > current.build!;
    }
    return remote.build != null && current.build == null;
  }

  ({List<int> core, String preRelease, int? build}) _parseVersion(
    String value,
  ) {
    var normalized = value.trim();
    if (normalized.startsWith('v') || normalized.startsWith('V')) {
      normalized = normalized.substring(1);
    }

    int? build;
    final plusIndex = normalized.indexOf('+');
    if (plusIndex != -1) {
      build = int.tryParse(normalized.substring(plusIndex + 1));
      normalized = normalized.substring(0, plusIndex);
    }

    var preRelease = '';
    final dashIndex = normalized.indexOf('-');
    if (dashIndex != -1) {
      preRelease = normalized.substring(dashIndex + 1);
      normalized = normalized.substring(0, dashIndex);
    }

    final parts = normalized.split('.');
    final core = <int>[];
    for (var i = 0; i < 3; i++) {
      core.add(i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0);
    }
    return (core: core, preRelease: preRelease, build: build);
  }

  int _comparePreRelease(String remote, String current) {
    final remoteParts = remote.split('.');
    final currentParts = current.split('.');
    final maxLength = remoteParts.length > currentParts.length
        ? remoteParts.length
        : currentParts.length;
    for (var i = 0; i < maxLength; i++) {
      if (i >= remoteParts.length) return -1;
      if (i >= currentParts.length) return 1;

      final remotePart = remoteParts[i];
      final currentPart = currentParts[i];
      final remoteNumber = int.tryParse(remotePart);
      final currentNumber = int.tryParse(currentPart);
      final remoteIsNumber = remoteNumber != null;
      final currentIsNumber = currentNumber != null;

      if (remoteIsNumber && currentIsNumber) {
        if (remoteNumber != currentNumber) {
          return remoteNumber.compareTo(currentNumber);
        }
        continue;
      }
      if (remoteIsNumber != currentIsNumber) {
        return remoteIsNumber ? -1 : 1;
      }

      final textCompare = remotePart.compareTo(currentPart);
      if (textCompare != 0) return textCompare;
    }
    return 0;
  }
}
