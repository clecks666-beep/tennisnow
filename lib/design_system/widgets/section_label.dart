import 'package:flutter/material.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// A small uppercase-ish section heading used to group form fields,
/// keeping the log form scannable and consistent (CLAUDE.md §5).
class SectionLabel extends StatelessWidget {
  final String text;
  final bool optional;

  const SectionLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(text, style: AppTextStyles.label),
          if (optional) ...[
            const SizedBox(width: AppSpacing.xs),
            Text('· optional', style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}
