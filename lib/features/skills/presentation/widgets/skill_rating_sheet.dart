import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../../../shared/domain/skill/skill.dart';
import '../../../../shared/domain/skill/skill_catalog.dart';
import '../../../../shared/domain/skill/skill_category.dart';

/// Opens the "skills worked on" capture sheet. Returns the chosen skill→value
/// (1..5) map, or null if dismissed. Optional and fast — it never blocks the
/// sacred log flow (CLAUDE.md ★ / §4).
Future<Map<String, int>?> showSkillRatingSheet(
  BuildContext context, {
  required Map<String, int> initial,
}) {
  return showModalBottomSheet<Map<String, int>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _SkillRatingSheet(initial: initial),
    ),
  );
}

/// Categories the player rates directly (match-craft & equipment are derived).
const _ratableCategories = [
  SkillCategory.strokes,
  SkillCategory.shotQuality,
  SkillCategory.physical,
  SkillCategory.mental,
];

class _SkillRatingSheet extends StatefulWidget {
  final Map<String, int> initial;

  const _SkillRatingSheet({required this.initial});

  @override
  State<_SkillRatingSheet> createState() => _SkillRatingSheetState();
}

class _SkillRatingSheetState extends State<_SkillRatingSheet> {
  late final Map<String, int> _values = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skills worked on', style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Rate what you focused on — optional. Tap a number again to clear.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                for (final category in _ratableCategories)
                  _CategoryBlock(
                    category: category,
                    values: _values,
                    onChanged: (skillId, value) => setState(() {
                      if (value == null) {
                        _values.remove(skillId);
                      } else {
                        _values[skillId] = value;
                      }
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: PrimaryButton(
              label: _values.isEmpty
                  ? 'Done'
                  : 'Done · ${_values.length} rated',
              onPressed: () => Navigator.of(context).pop(_values),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final SkillCategory category;
  final Map<String, int> values;
  final void Function(String skillId, int? value) onChanged;

  const _CategoryBlock({
    required this.category,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final skills = SkillCatalog.byCategory(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Text(category.label, style: AppTextStyles.label),
        ),
        for (final skill in skills)
          _SkillRow(
            skill: skill,
            value: values[skill.id],
            onChanged: (v) => onChanged(skill.id, v),
          ),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  final Skill skill;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _SkillRow({
    required this.skill,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill.name, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.xs),
          SelectableChipGroup<int>(
            selected: value,
            options: const [
              ChipOption(value: 1, label: '1'),
              ChipOption(value: 2, label: '2'),
              ChipOption(value: 3, label: '3'),
              ChipOption(value: 4, label: '4'),
              ChipOption(value: 5, label: '5'),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
