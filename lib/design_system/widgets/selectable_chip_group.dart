import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// One reusable single-select chip group used everywhere a user picks one
/// option from a small set (session type, result, duration, ratings).
///
/// Generic over the value type so there is ONE selection component, not a
/// one-off per field (CLAUDE.md §3 reuse-first, §5 consistency).
///
/// [allowDeselect] lets optional fields be cleared by tapping the selected chip
/// again — important so optional context never blocks the user (CLAUDE.md §4).
class SelectableChipGroup<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final bool allowDeselect;

  const SelectableChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final bool isSelected = option.value == selected;
        return ChoiceChip(
          label: Text(option.label),
          avatar: option.icon != null
              ? Icon(
                  option.icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                )
              : null,
          selected: isSelected,
          showCheckmark: false,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.outline),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          onSelected: (value) {
            if (isSelected && allowDeselect) {
              onChanged(null);
            } else {
              onChanged(option.value);
            }
          },
        );
      }).toList(),
    );
  }
}

/// A single option for [SelectableChipGroup].
class ChipOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ChipOption({required this.value, required this.label, this.icon});
}
