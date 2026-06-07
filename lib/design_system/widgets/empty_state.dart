import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// A motivating, action-guiding empty state (CLAUDE.md §4: empty states must
/// never be blank dead-ends and should guide the next action). Reused by any
/// list that can be empty.
///
/// Provide either [icon] or [imagePath] for the visual. [imagePath] takes
/// precedence when both are given — it shows the raster illustration from
/// assets/images/brand/empty_states/ for screens that have one.
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : assert(icon != null || imagePath != null,
            'Provide either icon or imagePath');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Image.asset(
                  imagePath!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(icon, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
