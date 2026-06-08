import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/shared/domain/avatar/avatar_catalog.dart';
import 'package:tennisnow/shared/domain/avatar/avatar_config.dart';

void main() {
  group('AvatarConfig.svgUrl', () {
    test('points at the DiceBear adventurer v9 SVG endpoint', () {
      final url = AvatarConfig.defaultConfig.svgUrl;
      expect(url, startsWith('https://api.dicebear.com/9.x/adventurer/svg'));
    });

    test('is deterministic — same config yields the same URL', () {
      const a = AvatarConfig.defaultConfig;
      final b = a.copyWith();
      expect(a.svgUrl, b.svgUrl);
    });

    test('encodes every customised field into the query string', () {
      const config = AvatarConfig(
        skinColor: 'ae5d29',
        hairStyle: 'long07',
        hairColor: 'f4d150',
        eyeStyle: 'variant06',
        mouthStyle: 'variant03',
        bgColor: '2e7d32',
      );
      final uri = Uri.parse(config.svgUrl);
      expect(uri.queryParameters['skinColor'], 'ae5d29');
      expect(uri.queryParameters['hair'], 'long07');
      expect(uri.queryParameters['hairColor'], 'f4d150');
      expect(uri.queryParameters['eyes'], 'variant06');
      expect(uri.queryParameters['mouth'], 'variant03');
      expect(uri.queryParameters['backgroundColor'], '2e7d32');
    });

    test('changing one field changes the URL', () {
      const base = AvatarConfig.defaultConfig;
      final changed = base.copyWith(hairColor: 'ffffff');
      expect(base.svgUrl, isNot(changed.svgUrl));
    });
  });

  group('AvatarConfig JSON', () {
    test('round-trips through a JSON string', () {
      const config = AvatarConfig(
        skinColor: 'd08b5b',
        hairStyle: 'short09',
        hairColor: '0e0e0e',
        eyeStyle: 'variant08',
        mouthStyle: 'variant05',
        bgColor: 'c0aede',
      );
      final restored = AvatarConfig.fromJsonString(config.toJsonString());
      expect(restored, config);
    });

    test('fills missing fields from the default config', () {
      final restored = AvatarConfig.fromJson({'skinColor': 'ae5d29'});
      expect(restored.skinColor, 'ae5d29');
      expect(restored.hairStyle, AvatarConfig.defaultConfig.hairStyle);
      expect(restored.bgColor, AvatarConfig.defaultConfig.bgColor);
    });
  });

  group('AvatarConfig equality', () {
    test('value equality and hashCode are consistent', () {
      const a = AvatarConfig.defaultConfig;
      final b = a.copyWith();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing configs are not equal', () {
      const a = AvatarConfig.defaultConfig;
      final b = a.copyWith(eyeStyle: 'variant16');
      expect(a, isNot(b));
    });
  });

  group('AvatarCatalog', () {
    test('every default-config value exists in its catalog list', () {
      const c = AvatarConfig.defaultConfig;
      expect(AvatarCatalog.skinColors.map((o) => o.id), contains(c.skinColor));
      expect(AvatarCatalog.hairStyles.map((o) => o.id), contains(c.hairStyle));
      expect(AvatarCatalog.hairColors.map((o) => o.id), contains(c.hairColor));
      expect(AvatarCatalog.eyeStyles.map((o) => o.id), contains(c.eyeStyle));
      expect(AvatarCatalog.mouthStyles.map((o) => o.id), contains(c.mouthStyle));
      expect(AvatarCatalog.bgColors.map((o) => o.id), contains(c.bgColor));
    });

    test('hair styles use only valid adventurer ids (short##/long##)', () {
      final valid = RegExp(r'^(short|long)\d{2}$');
      for (final option in AvatarCatalog.hairStyles) {
        expect(valid.hasMatch(option.id), isTrue,
            reason: '${option.id} is not a valid adventurer hair id');
      }
    });

    test('color ids are 6-char hex without a leading hash', () {
      final hex = RegExp(r'^[0-9a-fA-F]{6}$');
      for (final list in [
        AvatarCatalog.skinColors,
        AvatarCatalog.hairColors,
        AvatarCatalog.bgColors,
      ]) {
        for (final option in list) {
          expect(hex.hasMatch(option.id), isTrue,
              reason: '${option.id} is not a 6-char hex color');
        }
      }
    });

    test('option ids within each category are unique', () {
      for (final list in [
        AvatarCatalog.skinColors,
        AvatarCatalog.hairStyles,
        AvatarCatalog.hairColors,
        AvatarCatalog.eyeStyles,
        AvatarCatalog.mouthStyles,
        AvatarCatalog.bgColors,
      ]) {
        final ids = list.map((o) => o.id).toList();
        expect(ids.toSet().length, ids.length);
      }
    });
  });
}
