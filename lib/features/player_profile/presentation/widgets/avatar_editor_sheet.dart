import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/avatar_widget.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../shared/domain/avatar/avatar_catalog.dart';
import '../../../../shared/domain/avatar/avatar_config.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../providers/avatar_provider.dart';

/// Modal bottom sheet for customising the player avatar.
///
/// Edits are kept in local [_draft] state for live preview; only committed to
/// the provider (and thus [AppPreferences]) when the player taps Save. Tapping
/// the backdrop or using the handle to dismiss discards unsaved changes.
///
/// Options are gated by player level (★C/D): cosmetics are an earned reward.
/// Locked options are shown — never hidden — with their level requirement, so
/// the player sees what's next to chase (motivating, not punishing; same
/// pattern as locked badges). The current level comes from the public
/// [gamificationProvider]; while it loads we assume level 1 (only starter
/// options selectable), so the editor never blocks.
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

  /// Transient hint shown when the player taps a locked option. Cleared on a
  /// successful selection or a tab change so it never lingers.
  String? _lockHint;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(avatarConfigProvider);
  }

  void _select(AvatarConfig updated) => setState(() {
        _draft = updated;
        _lockHint = null;
      });

  void _onLockedTap(AvatarOption opt) => setState(() {
        _lockHint = 'Reach Level ${opt.unlockLevel} to unlock ${opt.label}';
      });

  void _switchTab(_Category cat) => setState(() {
        _tab = cat;
        _lockHint = null;
      });

  Future<void> _save() async {
    await ref.read(avatarConfigProvider.notifier).update(_draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    // Public cross-feature surface — level drives which options are unlocked.
    final playerLevel =
        ref.watch(gamificationProvider).valueOrNull?.level.level ?? 1;

    return Container(
      // ~80 % of screen; expand a bit when keyboard is up
      height: MediaQuery.of(context).size.height * 0.80 + bottomInset,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildTitle(playerLevel),
          _buildPreview(),
          const SizedBox(height: AppSpacing.md),
          _buildCategoryTabs(),
          const Divider(height: 1, color: AppColors.outline),
          _buildLockHint(),
          Expanded(child: _buildOptions(playerLevel)),
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

  // ── Sheet title + level chip ───────────────────────────────────────────────
  Widget _buildTitle(int playerLevel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.md, AppSpacing.screen, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('Customize your avatar',
                style: AppTextStyles.titleMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Level $playerLevel',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              onTap: () => _switchTab(cat),
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
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Transient locked-tap hint ───────────────────────────────────────────────
  Widget _buildLockHint() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: _lockHint == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: AppColors.draw.withValues(alpha: 0.10),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.draw),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _lockHint!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.draw),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Options for the current tab ───────────────────────────────────────────
  Widget _buildOptions(int playerLevel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: switch (_tab) {
        _Category.skin => _ColorGrid(
            options: AvatarCatalog.skinColors,
            selected: _draft.skinColor,
            playerLevel: playerLevel,
            onSelect: (id) => _select(_draft.copyWith(skinColor: id)),
            onLockedTap: _onLockedTap,
          ),
        _Category.hairStyle => _StyleGrid(
            options: AvatarCatalog.hairStyles,
            selected: _draft.hairStyle,
            playerLevel: playerLevel,
            onSelect: (id) => _select(_draft.copyWith(hairStyle: id)),
            onLockedTap: _onLockedTap,
          ),
        _Category.hairColor => _ColorGrid(
            options: AvatarCatalog.hairColors,
            selected: _draft.hairColor,
            playerLevel: playerLevel,
            onSelect: (id) => _select(_draft.copyWith(hairColor: id)),
            onLockedTap: _onLockedTap,
          ),
        _Category.eyes => _StyleGrid(
            options: AvatarCatalog.eyeStyles,
            selected: _draft.eyeStyle,
            playerLevel: playerLevel,
            onSelect: (id) => _select(_draft.copyWith(eyeStyle: id)),
            onLockedTap: _onLockedTap,
          ),
        _Category.mouth => _StyleGrid(
            options: AvatarCatalog.mouthStyles,
            selected: _draft.mouthStyle,
            playerLevel: playerLevel,
            onSelect: (id) => _select(_draft.copyWith(mouthStyle: id)),
            onLockedTap: _onLockedTap,
          ),
        _Category.background => _ColorGrid(
            options: AvatarCatalog.bgColors,
            selected: _draft.bgColor,
            playerLevel: playerLevel,
            onSelect: (id) => _select(_draft.copyWith(bgColor: id)),
            onLockedTap: _onLockedTap,
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
  final int playerLevel;
  final ValueChanged<String> onSelect;
  final ValueChanged<AvatarOption> onLockedTap;

  const _ColorGrid({
    required this.options,
    required this.selected,
    required this.playerLevel,
    required this.onSelect,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: options.map((opt) {
        final color = _hexColor(opt.id);
        final unlocked = opt.unlockedAt(playerLevel);
        final isSelected = unlocked && opt.id == selected;
        return GestureDetector(
          onTap: () => unlocked ? onSelect(opt.id) : onLockedTap(opt),
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
            child: !unlocked
                ? _LockOverlay(level: opt.unlockLevel, onColor: color)
                : isSelected
                    ? Icon(Icons.check_rounded,
                        size: 22, color: _contrastColor(color))
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
  final int playerLevel;
  final ValueChanged<String> onSelect;
  final ValueChanged<AvatarOption> onLockedTap;

  const _StyleGrid({
    required this.options,
    required this.selected,
    required this.playerLevel,
    required this.onSelect,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final unlocked = opt.unlockedAt(playerLevel);
        final isSelected = unlocked && opt.id == selected;
        return GestureDetector(
          onTap: () => unlocked ? onSelect(opt.id) : onLockedTap(opt),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!unlocked) ...[
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  unlocked ? opt.label : '${opt.label} · Lv ${opt.unlockLevel}',
                  style: AppTextStyles.label.copyWith(
                    color: !unlocked
                        ? AppColors.textSecondary
                        : isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Lock treatment painted over a locked colour swatch: a scrim + lock icon and
/// the required level, so the requirement is always legible (recognition over
/// recall) without an extra tap.
class _LockOverlay extends StatelessWidget {
  final int level;
  final Color onColor;

  const _LockOverlay({required this.level, required this.onColor});

  @override
  Widget build(BuildContext context) {
    final fg = _contrastColor(onColor);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 16, color: fg),
          Text(
            'Lv $level',
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _hexColor(String hex) => Color(int.parse('FF$hex', radix: 16));

/// Returns black or white, whichever contrasts better against [bg].
Color _contrastColor(Color bg) {
  final luminance = bg.computeLuminance();
  return luminance > 0.4 ? AppColors.textPrimary : AppColors.surface;
}
