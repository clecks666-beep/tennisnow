/// A single selectable avatar option. Pure domain — no Flutter dependencies;
/// the presentation layer derives [Color] swatches from [id] hex strings.
class AvatarOption {
  final String id;     // param value sent to DiceBear
  final String label;  // display name shown in the editor

  const AvatarOption({required this.id, required this.label});
}

/// Canonical catalog of available avatar customisation options.
///
/// Pure domain — mirrors the pattern of [BadgeCatalog] and [SkillCatalog].
/// Extend this list deliberately and keep [memory.md.txt] current when the
/// roster grows (e.g. new hair styles unlocked at higher levels).
class AvatarCatalog {
  AvatarCatalog._();

  static const List<AvatarOption> skinColors = [
    AvatarOption(id: 'f2d3b1', label: 'Fair'),
    AvatarOption(id: 'ffdbb4', label: 'Peach'),
    AvatarOption(id: 'edb98a', label: 'Sand'),
    AvatarOption(id: 'd08b5b', label: 'Caramel'),
    AvatarOption(id: 'ae5d29', label: 'Toffee'),
    AvatarOption(id: '614335', label: 'Espresso'),
  ];

  // Adventurer hair: only `short01`–`short19` and `long01`–`long26` are valid
  // values in the DiceBear adventurer style. A handpicked, visually distinct
  // spread across both ranges.
  static const List<AvatarOption> hairStyles = [
    AvatarOption(id: 'short01', label: 'Short'),
    AvatarOption(id: 'short04', label: 'Crew'),
    AvatarOption(id: 'short09', label: 'Buzz'),
    AvatarOption(id: 'short16', label: 'Quiff'),
    AvatarOption(id: 'long01',  label: 'Long'),
    AvatarOption(id: 'long07',  label: 'Wavy'),
    AvatarOption(id: 'long13',  label: 'Flow'),
    AvatarOption(id: 'long20',  label: 'Locks'),
  ];

  static const List<AvatarOption> hairColors = [
    AvatarOption(id: '0e0e0e', label: 'Black'),
    AvatarOption(id: '2c1b0e', label: 'Dark Brown'),
    AvatarOption(id: '8b5e3c', label: 'Brown'),
    AvatarOption(id: 'c7843e', label: 'Auburn'),
    AvatarOption(id: 'f4d150', label: 'Blonde'),
    AvatarOption(id: 'e8e1b1', label: 'Platinum'),
    AvatarOption(id: 'b0b0b0', label: 'Silver'),
    AvatarOption(id: 'fc909f', label: 'Pink'),
  ];

  static const List<AvatarOption> eyeStyles = [
    AvatarOption(id: 'variant01', label: 'Default'),
    AvatarOption(id: 'variant04', label: 'Happy'),
    AvatarOption(id: 'variant06', label: 'Wink'),
    AvatarOption(id: 'variant08', label: 'Squint'),
    AvatarOption(id: 'variant12', label: 'Sleepy'),
    AvatarOption(id: 'variant16', label: 'Wide'),
  ];

  static const List<AvatarOption> mouthStyles = [
    AvatarOption(id: 'variant01', label: 'Smile'),
    AvatarOption(id: 'variant03', label: 'Grin'),
    AvatarOption(id: 'variant05', label: 'Happy'),
    AvatarOption(id: 'variant07', label: 'Serious'),
    AvatarOption(id: 'variant09', label: 'Smirk'),
    AvatarOption(id: 'variant11', label: 'Tongue'),
  ];

  static const List<AvatarOption> bgColors = [
    AvatarOption(id: 'b6e3f4', label: 'Sky'),
    AvatarOption(id: 'c0aede', label: 'Lavender'),
    AvatarOption(id: 'c8ff00', label: 'Zest'),
    AvatarOption(id: '2e7d32', label: 'Court'),
    AvatarOption(id: 'ffd5dc', label: 'Blush'),
    AvatarOption(id: 'ffeba0', label: 'Sunny'),
    AvatarOption(id: 'e0e0e0', label: 'Silver'),
    AvatarOption(id: '1a1a2e', label: 'Night'),
  ];
}
