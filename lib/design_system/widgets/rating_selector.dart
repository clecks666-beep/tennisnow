import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// A reusable 1–5 rating selector (performance, mood, energy).
///
/// Optional by design: tapping the selected value clears it, so the user can
/// skip context without friction (CLAUDE.md §4). One component, reused for all
/// three scales (CLAUDE.md §3).
class RatingSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  /// Labels for the two extremes, e.g. ('Poor', 'Great').
  final String lowLabel;
  final String highLabel;

  const RatingSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.lowLabel,
    required this.highLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (int i = AppConstants.minRating; i <= AppConstants.maxRating; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == AppConstants.maxRating ? 0 : AppSpacing.sm,
                  ),
                  child: _RatingDot(
                    number: i,
                    selected: value == i,
                    onTap: () => onChanged(value == i ? null : i),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lowLabel, style: Theme.of(context).textTheme.bodySmall),
            Text(highLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _RatingDot extends StatelessWidget {
  final int number;
  final bool selected;
  final VoidCallback onTap;

  const _RatingDot({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
