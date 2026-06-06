import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// A compact metric card (value + label, optional icon/caption). Reusable for
/// any dashboard-style summary, so summaries stay visually consistent
/// (CLAUDE.md §5). Renders a graceful placeholder when [value] is null.
class StatCard extends StatelessWidget {
  final String label;
  final String? value;
  final String? caption;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value ?? '—',
              style: AppTextStyles.titleLarge.copyWith(
                color: value == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(caption!, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
