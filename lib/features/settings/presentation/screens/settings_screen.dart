import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/avatar_editable_hero.dart';
import '../../../../design_system/widgets/section_label.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../../../shared/data/app_preferences.dart';
import '../../../../shared/domain/session_type.dart';
import '../../../player_profile/presentation/providers/avatar_provider.dart';
import '../../../player_profile/presentation/widgets/avatar_editor_sheet.dart';
import '../providers/settings_controller.dart';

/// Settings: light personalization + control. Reachable from the Sessions tab.
/// Device-local only (ADR-005) — nothing here leaves the phone.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Seed once from current state; the field owns its own text afterwards.
    _nameController = TextEditingController(
      text: ref.read(settingsControllerProvider).displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _replayOnboarding() async {
    await ref.read(appPreferencesProvider).setOnboardingComplete(false);
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final avatarConfig = ref.watch(avatarConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          // Identity card — avatar + name + quick path to the editor.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AvatarEditableHero(
                config: avatarConfig,
                displayName: settings.displayName,
                onEdit: () => AvatarEditorSheet.show(context),
                avatarSize: 64,
                nameStyle: AppTextStyles.titleMedium,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Your name', optional: true),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'How should we greet you?',
            ),
            // Persist live so the greeting updates as you type.
            onChanged: controller.setDisplayName,
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Default when logging'),
          Text(
            'The quick-log form starts on this type.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableChipGroup<SessionType>(
            selected: settings.defaultSessionType,
            allowDeselect: false,
            options: const [
              ChipOption(
                value: SessionType.training,
                label: 'Training',
                icon: Icons.sports_tennis_outlined,
              ),
              ChipOption(
                value: SessionType.match,
                label: 'Match',
                icon: Icons.emoji_events_outlined,
              ),
            ],
            onChanged: (type) {
              if (type != null) controller.setDefaultSessionType(type);
            },
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Gear'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sports_tennis_rounded,
                  color: AppColors.primary),
              title: const Text('My equipment'),
              subtitle: const Text('Manage your rackets, strings and shoes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/equipment'),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Data'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
              title: const Text('Backup & restore'),
              subtitle: const Text('Export or import your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/backup'),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Help'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.replay_rounded, color: AppColors.primary),
              title: const Text('Replay the intro'),
              subtitle: const Text('See the welcome tour again'),
              onTap: _replayOnboarding,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppConstants.appName}  ·  v${AppConstants.appVersion}',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(AppConstants.tagline, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Your data stays on this device.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
