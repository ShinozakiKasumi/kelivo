import 'package:Kelivo/core/providers/update_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateInfo', () {
    test('parses latest fork GitHub release metadata', () {
      final info = UpdateInfo.fromJson({
        'tag_name': 'v1.1.16-fork.1+60',
        'published_at': '2026-06-08T03:06:24Z',
        'body': 'Fork Android release notes',
        'html_url': 'https://github.com/ShinozakiKasumi/kelivo/releases/tag/v1',
        'assets': [
          {
            'name': 'Kelivo-android-1.1.16-fork.1+60-signed.apk',
            'browser_download_url': 'https://example.com/kelivo.apk',
          },
          {
            'name': 'Kelivo-android-1.1.16-fork.1+60-signed.aab',
            'browser_download_url': 'https://example.com/kelivo.aab',
          },
        ],
      });

      expect(UpdateInfo.forkLatestReleaseUrl, contains('ShinozakiKasumi'));
      expect(info.app, 'Kelivo');
      expect(info.version, '1.1.16-fork.1');
      expect(info.build, 60);
      expect(info.releasedAt, DateTime.utc(2026, 6, 8, 3, 6, 24));
      expect(info.notes, 'Fork Android release notes');
      expect(info.downloads['android'], 'https://example.com/kelivo.apk');
      expect(
        info.downloads['universal'],
        'https://github.com/ShinozakiKasumi/kelivo/releases/tag/v1',
      );
    });

    test('falls back to release page when no matching asset exists', () {
      final info = UpdateInfo.fromJson({
        'tag_name': 'V1.2.0',
        'published_at': 'not-a-date',
        'html_url': 'https://github.com/ShinozakiKasumi/kelivo/releases/latest',
        'assets': const [],
      });

      expect(info.version, '1.2.0');
      expect(info.build, isNull);
      expect(info.releasedAt, isNull);
      expect(info.bestDownloadUrl(), info.downloads['universal']);
    });

    test('parses multi-digit fork prerelease and build from tag', () {
      final info = UpdateInfo.fromJson({
        'tag_name': 'v1.1.16-fork.10+61',
        'html_url': 'https://github.com/ShinozakiKasumi/kelivo/releases/tag/v1',
        'assets': const [],
      });

      expect(info.version, '1.1.16-fork.10');
      expect(info.build, 61);
    });
  });
}
