import 'skill.dart';
import 'skill_category.dart';

/// The canonical Tennis Skill Model (CLAUDE.md ★ section). ONE source of truth,
/// like BadgeCatalog. Contains the directly self-ratable skills (strokes, shot
/// qualities, physical, mental). Match-craft and equipment skills are derived
/// from data, so they are not listed here as taggable items.
///
/// To extend the model: add a skill here AND update the ★ taxonomy in CLAUDE.md.
/// Never change an existing [Skill.id] — it is a stable, community-facing key.
class SkillCatalog {
  SkillCatalog._();

  static const List<Skill> all = [
    // Strokes
    Skill(id: 'serve', name: 'Serve', category: SkillCategory.strokes),
    Skill(id: 'return', name: 'Return', category: SkillCategory.strokes),
    Skill(id: 'forehand', name: 'Forehand', category: SkillCategory.strokes),
    Skill(id: 'backhand', name: 'Backhand', category: SkillCategory.strokes),
    Skill(id: 'volley', name: 'Volley', category: SkillCategory.strokes),
    Skill(id: 'smash', name: 'Smash', category: SkillCategory.strokes),
    Skill(id: 'slice', name: 'Slice', category: SkillCategory.strokes),
    Skill(id: 'lob', name: 'Lob', category: SkillCategory.strokes),
    Skill(id: 'dropshot', name: 'Drop shot', category: SkillCategory.strokes),

    // Shot qualities
    Skill(id: 'power', name: 'Power', category: SkillCategory.shotQuality),
    Skill(id: 'spin', name: 'Spin', category: SkillCategory.shotQuality),
    Skill(id: 'placement', name: 'Placement', category: SkillCategory.shotQuality),
    Skill(id: 'consistency', name: 'Consistency', category: SkillCategory.shotQuality),

    // Physical
    Skill(id: 'endurance', name: 'Endurance', category: SkillCategory.physical),
    Skill(id: 'speed', name: 'Speed & footwork', category: SkillCategory.physical),
    Skill(id: 'agility', name: 'Agility', category: SkillCategory.physical),
    Skill(id: 'strength', name: 'Strength', category: SkillCategory.physical),

    // Mental
    Skill(id: 'focus', name: 'Focus', category: SkillCategory.mental),
    Skill(id: 'composure', name: 'Composure', category: SkillCategory.mental),
    Skill(id: 'confidence', name: 'Confidence', category: SkillCategory.mental),
    Skill(id: 'tactics', name: 'Tactics', category: SkillCategory.mental),
  ];

  static List<Skill> byCategory(SkillCategory category) =>
      all.where((s) => s.category == category).toList();

  static Skill? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
