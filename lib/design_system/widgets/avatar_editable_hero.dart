import 'package:flutter/material.dart';

import '../../shared/domain/avatar/avatar_config.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'avatar_widget.dart';

/// An avatar with an edit-badge overlay, the player's display name, and a
/// "Customize avatar" tap target. Used wherever the player's identity appears
/// alongside an edit affordance (profile screen, settings screen).
///
/// Callers control outer padding and container (Card vs bare Padding). Pass
/// [avatarSize] and [nameStyle] to tune emphasis for each surface.
class AvatarEditableHero extends StatelessWidget {
  final AvatarConfig config;
  final String? displayName;
  final VoidCallback onEdit;

  /// Diameter of the avatar circle (default 80 for the full profile hero).
  final double avatarSize;

  /// Override the display-name text style. Defaults to [AppTextStyles.titleLarge].
  final TextStyle? nameStyle;

  const AvatarEditableHero({
    super.key,
    required this.config,
    required this.displayName,
    required this.onEdit,
    this.avatarSize = 80.0,
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    final badgeSize = (avatarSize * 0.325).roundToDouble();
    final iconSize = (badgeSize * 0.52).roundToDouble();

    return Row(
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarWidget(config: config, size: avatarSize),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: iconSize,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName ?? 'Tennis Player',
                style: (nameStyle ?? AppTextStyles.titleLarge).copyWith(
                  color: displayName != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Customize avatar',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
