import 'dart:convert';

/// Avatar customisation — a pure value object.
///
/// Stored in [AppPreferences] (device-local for now; migrates to account-level
/// for Pro). The SVG is constructed on-the-fly from the DiceBear adventurer API
/// so no image assets are shipped — the URL is deterministic for any param set.
class AvatarConfig {
  final String skinColor;  // 6-char hex, no '#'
  final String hairStyle;  // DiceBear adventurer hair param value
  final String hairColor;  // 6-char hex, no '#'
  final String eyeStyle;   // DiceBear adventurer eyes param value
  final String mouthStyle; // DiceBear adventurer mouth param value
  final String bgColor;    // 6-char hex, no '#'

  const AvatarConfig({
    required this.skinColor,
    required this.hairStyle,
    required this.hairColor,
    required this.eyeStyle,
    required this.mouthStyle,
    required this.bgColor,
  });

  static const AvatarConfig defaultConfig = AvatarConfig(
    skinColor: 'edb98a',
    hairStyle: 'short01',
    hairColor: '2c1b0e',
    eyeStyle: 'variant04',
    mouthStyle: 'variant01',
    bgColor: 'b6e3f4',
  );

  /// DiceBear adventurer SVG endpoint with this configuration.
  String get svgUrl => Uri.https(
        'api.dicebear.com',
        '/9.x/adventurer/svg',
        {
          'skinColor': skinColor,
          'hair': hairStyle,
          'hairColor': hairColor,
          'eyes': eyeStyle,
          'mouth': mouthStyle,
          'backgroundColor': bgColor,
          'backgroundType': 'solid',
          'radius': '50',
        },
      ).toString();

  AvatarConfig copyWith({
    String? skinColor,
    String? hairStyle,
    String? hairColor,
    String? eyeStyle,
    String? mouthStyle,
    String? bgColor,
  }) =>
      AvatarConfig(
        skinColor: skinColor ?? this.skinColor,
        hairStyle: hairStyle ?? this.hairStyle,
        hairColor: hairColor ?? this.hairColor,
        eyeStyle: eyeStyle ?? this.eyeStyle,
        mouthStyle: mouthStyle ?? this.mouthStyle,
        bgColor: bgColor ?? this.bgColor,
      );

  Map<String, dynamic> toJson() => {
        'skinColor': skinColor,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'eyeStyle': eyeStyle,
        'mouthStyle': mouthStyle,
        'bgColor': bgColor,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
        skinColor: (json['skinColor'] as String?) ?? defaultConfig.skinColor,
        hairStyle: (json['hairStyle'] as String?) ?? defaultConfig.hairStyle,
        hairColor: (json['hairColor'] as String?) ?? defaultConfig.hairColor,
        eyeStyle: (json['eyeStyle'] as String?) ?? defaultConfig.eyeStyle,
        mouthStyle: (json['mouthStyle'] as String?) ?? defaultConfig.mouthStyle,
        bgColor: (json['bgColor'] as String?) ?? defaultConfig.bgColor,
      );

  /// Convenience: round-trip through JSON (used by [AppPreferences]).
  String toJsonString() => jsonEncode(toJson());

  factory AvatarConfig.fromJsonString(String s) =>
      AvatarConfig.fromJson(jsonDecode(s) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarConfig &&
          skinColor == other.skinColor &&
          hairStyle == other.hairStyle &&
          hairColor == other.hairColor &&
          eyeStyle == other.eyeStyle &&
          mouthStyle == other.mouthStyle &&
          bgColor == other.bgColor;

  @override
  int get hashCode => Object.hash(
      skinColor, hairStyle, hairColor, eyeStyle, mouthStyle, bgColor);
}
