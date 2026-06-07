import 'skill_category.dart';

/// A single tennis skill in the model (CLAUDE.md ★ section). Pure data — no
/// Flutter. [id] is the stable storage/identity key (used by self-ratings and,
/// later, by community comparison), so it must never change once shipped.
class Skill {
  final String id;
  final String name;
  final SkillCategory category;

  const Skill({required this.id, required this.name, required this.category});
}
