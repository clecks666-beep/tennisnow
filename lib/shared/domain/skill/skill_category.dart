/// Categories of the Tennis Skill Model (CLAUDE.md ★ section). [strokes],
/// [shotQuality], [physical] and [mental] are self-rated skills; [matchCraft]
/// and [equipment] are DERIVED from match/equipment data, not tagged directly.
enum SkillCategory {
  strokes('Strokes'),
  shotQuality('Shot quality'),
  physical('Physical'),
  mental('Mental'),
  matchCraft('Match craft'),
  equipment('Equipment');

  final String label;
  const SkillCategory(this.label);
}
