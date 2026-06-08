import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/progression_delta.dart';
import 'badge_visuals.dart';

/// Shows the "felt" progression reward after a save — what the player just
/// earned (★/§4/§5: progression must be felt, but stay meaningful & restrained,
/// never noisy). Exactly ONE SnackBar; a celebratory, on-brand one only on a
/// real level-up or a freshly unlocked badge, otherwise a quiet "+XP" confirm.
///
/// Non-blocking by design (a SnackBar, not a dialog) so the sacred fast-log flow
/// is never interrupted. Public surface composed by the log screen.
void showProgressionFeedback(
  ScaffoldMessengerState messenger, {
  required bool isEdit,
  required ProgressionDelta delta,
}) {
  final base = isEdit ? 'Session updated' : 'Session logged 🎾';
  final xp = delta.xpGained;
  final xpSuffix = xp > 0 ? ' · +$xp XP' : '';

  messenger.clearSnackBars();

  if (delta.leveledUp) {
    final avatarNote =
        delta.unlocksAvatarStyles ? ' · ✨ New avatar styles unlocked!' : '';
    messenger.showSnackBar(_celebration(
      leading: _LevelMedal(level: delta.newLevel),
      title: 'Level up! You reached level ${delta.newLevel}',
      subtitle: "You're now a ${delta.newTitle}$xpSuffix$avatarNote",
    ));
    return;
  }

  if (delta.newlyEarnedBadges.isNotEmpty) {
    final first = delta.newlyEarnedBadges.first;
    final more = delta.newlyEarnedBadges.length - 1;
    final extra = more > 0 ? ' +$more more' : '';
    messenger.showSnackBar(_celebration(
      leading: _IconMedal(icon: badgeIconFor(first.badge.id)),
      title: 'Badge unlocked: ${first.badge.title}$extra',
      subtitle: '${first.badge.description}$xpSuffix',
    ));
    return;
  }

  // Nothing milestone-worthy: a quiet, honest confirmation (with XP if any).
  messenger.showSnackBar(
    SnackBar(
      content: Text('$base$xpSuffix'),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// A celebratory, on-brand SnackBar with a leading medal and two lines.
SnackBar _celebration({
  required Widget leading,
  required String title,
  required String subtitle,
}) {
  return SnackBar(
    backgroundColor: AppColors.primaryDark,
    duration: const Duration(seconds: 4),
    content: Row(
      children: [
        leading,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textOnPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Circular medal showing the new level number (level-up).
class _LevelMedal extends StatelessWidget {
  final int level;

  const _LevelMedal({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$level',
        style: AppTextStyles.label
            .copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Circular medal showing a badge icon (badge unlock).
class _IconMedal extends StatelessWidget {
  final IconData icon;

  const _IconMedal({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryDark, size: 22),
    );
  }
}
