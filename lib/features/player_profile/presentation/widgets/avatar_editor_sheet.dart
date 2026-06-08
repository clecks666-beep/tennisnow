import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/avatar_widget.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../shared/domain/avatar/avatar_catalog.dart';
import '../../../../shared/domain/avatar/avatar_config.dart';
import '../providers/avatar_provider.dart';

/// Modal bottom sheet for customising the player avatar.
///
/// Edits are kept in local [_draft] state for live preview; only committed to
/// the provider (and thus [AppPreferences]) when the player taps Save. Tapping
/// the backdrop or using the handle to dismiss discards unsaved changes.
class AvatarEditorSheet extends ConsumerStatefulWidget {
  const AvatarEditorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AvatarEditorSheet(),
    );
  }

  @override
  ConsumerState<AvatarEditorSheet> createState() => _AvatarEditorSheetState();
}

enum _Category {
  skin('Skin'),
  hairStyle('Style'),
  hairColor('Hair'),
  eyes('Eyes'),
  mouth('Mouth'),
  background('BG');

  final String label;
  const _Category(this.label);
}

class _AvatarEditorSheetState extends ConsumerState<AvatarEditorSheet> {
  late AvatarConfig _draft;
  _Category _tab = _Category.skin;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(avatarConfigProvider);
  }

  void _select(AvatarConfig updated) => setState(() => _draft = updated);

  Future<void> _save() async {
    await ref.read(avatarConfigProvider.notifier).update(_draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      // ~78 % of screen; expand a bit when keyboard is up
      height: MediaQuery.of(context).size.height * 0.78 + bottomInset,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildTitle(),
          _buildPreview(),
          const SizedBox(height: AppSpacing.md),
          _buildCategoryTabs(),
          const Divider(height: 1, color: AppColors.outline),
          Expanded(child: _buildOptions()),
          _buildSaveButton(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.sm),
        ],
      ),
    );
  }

  // ── Drag handle ──────────────────────────────────────────────────────────
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ),
    );
  }

  // ── Sheet title ───────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.md, AppSpacing.screen, 0),
      child: Text('Customize your avatar', style: AppTextStyles.titleMedium),
    );
  }

  // ── Live avatar preview ───────────────────────────────────────────────────
  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline, width: 2),
          ),
          child: AvatarWidget(config: _draft, size: 96),
        ),
      ),
    );
  }

  // ── Category tab row ─────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        children: _Category.values.map((cat) {
          final selected = cat == _tab;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _tab = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  cat.label,
                  style: AppTextStyles.label.copyWith(
                    color: selected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Options for the current tab ───────────────────────────────────────────
  Widget _buildOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: switch (_tab) {
        _Category.skin => _ColorGrid(
            options: AvatarCatalog.skinColors,
            selected: _draft.skinColor,
            onSelect: (id) => _select(_draft.copyWith(skinColor: id)),
          ),
        _Category.hairStyle => _StyleGrid(
            options: AvatarCatalog.hairStyles,
            selected: _draft.hairStyle,
            onSelect: (id) => _select(_draft.copyWith(hairStyle: id)),
          ),
        _Category.hairColor => _ColorGrid(
            options: AvatarCatalog.hairColors,
            selected: _draft.hairColor,
            onSelect: (id) => _select(_draft.copyWith(hairColor: id)),
          ),
        _Category.eyes => _StyleGrid(
            options: AvatarCatalog.eyeStyles,
            selected: _draft.eyeStyle,
            onSelect: (id) => _select(_draft.copyWith(eyeStyle: id)),
          ),
        _Category.mouth => _StyleGrid(
            options: AvatarCatalog.mouthStyles,
            selected: _draft.mouthStyle,
            onSelect: (id) => _select(_draft.copyWith(mouthStyle: id)),
          ),
        _Category.background => _ColorGrid(
            options: AvatarCatalog.bgColors,
            selected: _draft.bgColor,
            onSelect: (id) => _select(_draft.copyWith(bgColor: id)),
          ),
      },
    );
  }

  // ── Save button (reuses the design-system PrimaryButton, §3/§5) ─────────────
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen, vertical: AppSpacing.sm),
      child: PrimaryButton(
        label: 'Save avatar',
        icon: Icons.check_rounded,
        onPressed: _save,
      ),
    );
  }
}

// ── Color swatch grid ─────────────────────────────────────────────────────────

class _ColorGrid extends StatelessWidget {
  final List<AvatarOption> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ColorGrid({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: options.map((opt) {
        final color = _hexColor(opt.id);
        final isSelected = opt.id == selected;
        return GestureDetector(
          onTap: () => onSelect(opt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outline,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 22,
                    color: _contrastColor(color),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ── Labeled style chip grid ────────────────────────────────────────────────────

class _StyleGrid extends StatelessWidget {
  final List<AvatarOption> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _StyleGrid({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final isSelected = opt.id == selected;
        return GestureDetector(
          onTap: () => onSelect(opt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt.label,
              style: AppTextStyles.label.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _hexColor(String hex) =>
    Color(int.parse('FF$hex', radix: 16));

/// Returns black or white, whichever contrasts better against [bg].
Color _contrastColor(Color bg) {
  final luminance = bg.computeLuminance();
  return luminance > 0.4 ? AppColors.textPrimary : AppColors.surface;
}
