import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../shared/domain/session_type.dart';
import '../../domain/match_result.dart';
import '../../domain/tennis_session.dart';

/// One row in the history list. Surfaces the session at a glance: type, when,
/// result, and the performance/feeling signals that make tennisnow distinctive.
class SessionListTile extends StatelessWidget {
  final TennisSession session;

  const SessionListTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _TypeAvatar(type: session.type),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(session.type.label, style: AppTextStyles.titleMedium),
                      if (session.result != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _ResultBadge(result: session.result!),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _subtitle(),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            _Signals(session: session),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[
      '${DateFormatX.relativeDay(session.playedAt)} · ${DateFormatX.time(session.playedAt)}',
    ];
    if (session.durationMinutes != null) {
      parts.add('${session.durationMinutes} min');
    }
    if (session.equipment != null) {
      parts.add(session.equipment!);
    }
    return parts.join('  ·  ');
  }
}

class _TypeAvatar extends StatelessWidget {
  final SessionType type;

  const _TypeAvatar({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Icon(
        type == SessionType.match
            ? Icons.emoji_events_outlined
            : Icons.sports_tennis_outlined,
        color: AppColors.primary,
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final MatchResult result;

  const _ResultBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = switch (result) {
      MatchResult.win => AppColors.win,
      MatchResult.loss => AppColors.loss,
      MatchResult.draw => AppColors.draw,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        result.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Compact performance / mood indicators. Only shows what was actually logged,
/// so an optional-skipped value never renders noise.
class _Signals extends StatelessWidget {
  final TennisSession session;

  const _Signals({required this.session});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (session.performance != null) {
      children.add(_Signal(
        icon: Icons.trending_up_rounded,
        value: session.performance!.value,
      ));
    }
    if (session.mood != null) {
      children.add(_Signal(
        icon: Icons.sentiment_satisfied_rounded,
        value: session.mood!.value,
      ));
    }
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: child,
          ),
      ],
    );
  }
}

class _Signal extends StatelessWidget {
  final IconData icon;
  final int value;

  const _Signal({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
