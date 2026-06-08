import '../../../core/constants/game_balance.dart';

/// A single selectable avatar option. Pure domain — no Flutter dependencies;
/// the presentation layer derives [Color] swatches from [id] hex strings.
///
/// [unlockLevel] gates the option behind a player level (★C/D): cosmetics are
/// an earned reward. Default [GameBalance.cosmeticTierStart] means "available
/// from the first session". Because a player's level is derived from monotonic
/// XP, [unlockedAt] is monotonic too — an unlock is permanent without storing
/// anything (derived-not-stored, community-ready).
class AvatarOption {
  final String id; // param value sent to DiceBear
  final String label; // display name shown in the editor
  final int unlockLevel; // player level required to use this option

  const AvatarOption({
    required this.id,
    required this.label,
    this.unlockLevel = GameBalance.cosmeticTierStart,
  });

  /// Whether a player at [playerLevel] may select this option.
  bool unlockedAt(int playerLevel) => playerLevel >= unlockLevel;

  /// Available from the start (no progression required).
  bool get isStarter => unlockLevel <= GameBalance.cosmeticTierStart;
}

/// Canonical catalog of available avatar customisation options.
///
/// Pure domain — mirrors the pattern of [BadgeCatalog] and [SkillCatalog].
/// Extend this list deliberately and keep [memory.md.txt] current when the
/// roster grows. Every category keeps several starter options so a brand-new
/// player always has real, satisfying choice immediately (first-use experience,
/// §12) — only aspirational extras are gated.
class AvatarCatalog {
  AvatarCatalog._();

  // Skin tones are an IDENTITY choice, never a reward — ALL start-tier.
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
  // spread across both ranges, with richer styles gated higher.
  static const List<AvatarOption> hairStyles = [
    AvatarOption(id: 'short01', label: 'Short'),
    AvatarOption(id: 'short04', label: 'Crew'),
    AvatarOption(id: 'short09', label: 'Buzz'),
    AvatarOption(id: 'long01', label: 'Long'),
    AvatarOption(
        id: 'short16',
        label: 'Quiff',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'long07',
        label: 'Wavy',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'long13',
        label: 'Flow',
        unlockLevel: GameBalance.cosmeticTierContender),
    AvatarOption(
        id: 'long20',
        label: 'Locks',
        unlockLevel: GameBalance.cosmeticTierChallenger),
  ];

  // Natural hair colours from the start; statement colours are earned.
  static const List<AvatarOption> hairColors = [
    AvatarOption(id: '0e0e0e', label: 'Black'),
    AvatarOption(id: '2c1b0e', label: 'Dark Brown'),
    AvatarOption(id: '8b5e3c', label: 'Brown'),
    AvatarOption(id: 'c7843e', label: 'Auburn'),
    AvatarOption(id: 'f4d150', label: 'Blonde'),
    AvatarOption(
        id: 'e8e1b1',
        label: 'Platinum',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'b0b0b0',
        label: 'Silver',
        unlockLevel: GameBalance.cosmeticTierContender),
    AvatarOption(
        id: 'fc909f',
        label: 'Pink',
        unlockLevel: GameBalance.cosmeticTierChallenger),
  ];

  static const List<AvatarOption> eyeStyles = [
    AvatarOption(id: 'variant01', label: 'Default'),
    AvatarOption(id: 'variant04', label: 'Happy'),
    AvatarOption(id: 'variant06', label: 'Wink'),
    AvatarOption(
        id: 'variant08',
        label: 'Squint',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'variant12',
        label: 'Sleepy',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'variant16',
        label: 'Wide',
        unlockLevel: GameBalance.cosmeticTierContender),
  ];

  static const List<AvatarOption> mouthStyles = [
    AvatarOption(id: 'variant01', label: 'Smile'),
    AvatarOption(id: 'variant03', label: 'Grin'),
    AvatarOption(id: 'variant05', label: 'Happy'),
    AvatarOption(
        id: 'variant07',
        label: 'Serious',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'variant09',
        label: 'Smirk',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'variant11',
        label: 'Tongue',
        unlockLevel: GameBalance.cosmeticTierContender),
  ];

  static const List<AvatarOption> bgColors = [
    AvatarOption(id: 'b6e3f4', label: 'Sky'),
    AvatarOption(id: 'c0aede', label: 'Lavender'),
    AvatarOption(id: 'ffd5dc', label: 'Blush'),
    AvatarOption(id: 'ffeba0', label: 'Sunny'),
    AvatarOption(
        id: 'e0e0e0',
        label: 'Silver',
        unlockLevel: GameBalance.cosmeticTierRallyer),
    AvatarOption(
        id: 'c8ff00',
        label: 'Zest',
        unlockLevel: GameBalance.cosmeticTierContender),
    AvatarOption(
        id: '2e7d32',
        label: 'Court',
        unlockLevel: GameBalance.cosmeticTierChallenger),
    AvatarOption(
        id: '1a1a2e',
        label: 'Night',
        unlockLevel: GameBalance.cosmeticTierAce),
  ];
}
