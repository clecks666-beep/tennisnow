import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/shared/domain/skill/skill_catalog.dart';
import 'package:tennisnow/shared/domain/skill/skill_category.dart';

void main() {
  group('SkillCatalog', () {
    test('is non-empty and has unique, stable ids', () {
      expect(SkillCatalog.all, isNotEmpty);
      final ids = SkillCatalog.all.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'skill ids must be unique');
    });

    test('covers the self-ratable categories', () {
      for (final c in [
        SkillCategory.strokes,
        SkillCategory.shotQuality,
        SkillCategory.physical,
        SkillCategory.mental,
      ]) {
        expect(SkillCatalog.byCategory(c), isNotEmpty, reason: '$c has skills');
      }
    });

    test('includes the headline strokes', () {
      final ids = SkillCatalog.all.map((s) => s.id).toSet();
      expect(ids.containsAll({'serve', 'forehand', 'backhand', 'lob', 'spin'}),
          isTrue);
    });

    test('byId resolves known and unknown ids', () {
      expect(SkillCatalog.byId('serve')?.name, 'Serve');
      expect(SkillCatalog.byId('does_not_exist'), isNull);
    });
  });
}
