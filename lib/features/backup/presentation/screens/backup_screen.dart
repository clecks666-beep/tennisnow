import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../design_system/widgets/section_label.dart';
import '../../data/backup_service.dart';
import '../providers/backup_providers.dart';

/// Local, offline backup: export everything to JSON (copied to the clipboard)
/// and restore by pasting it back. No server, no account (CLAUDE.md §7 — data
/// leaves the device only on an explicit user action).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final TextEditingController _importController = TextEditingController();

  String? _backup; // generated export JSON
  bool _exporting = false;
  bool _importing = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createBackup() async {
    setState(() => _exporting = true);
    try {
      final json = await ref.read(backupServiceProvider).export();
      await Clipboard.setData(ClipboardData(text: json));
      if (!mounted) return;
      setState(() => _backup = json);
      _snack('Backup created and copied to clipboard');
    } catch (_) {
      if (mounted) _snack("Couldn't create the backup — please try again");
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _copyAgain() async {
    if (_backup == null) return;
    await Clipboard.setData(ClipboardData(text: _backup!));
    if (mounted) _snack('Copied to clipboard');
  }

  Future<void> _restore() async {
    setState(() => _importing = true);
    try {
      final result =
          await ref.read(backupServiceProvider).import(_importController.text);
      if (!mounted) return;
      _importController.clear();
      // Sessions/equipment lists update reactively via their streams.
      _snack('Restored ${result.sessions} sessions and '
          '${result.equipment} equipment');
    } on BackupFormatException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack("Couldn't restore this backup");
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRestore =
        _importController.text.trim().isNotEmpty && !_importing;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Your data lives only on this device. Create a backup to keep it '
            'safe or move it to another device.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ---- Export ----
          const SectionLabel('Create a backup'),
          PrimaryButton(
            label: 'Create backup',
            icon: Icons.download_rounded,
            isLoading: _exporting,
            onPressed: _exporting ? null : _createBackup,
          ),
          if (_backup != null) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Copied to your clipboard. Paste it somewhere safe '
                      '(a note, an email to yourself).',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 140),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _backup!,
                          style: const TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _copyAgain,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy again'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ---- Import ----
          const SectionLabel('Restore from a backup'),
          Text(
            'Paste a backup below. Restoring merges by entry — it never deletes '
            'your current data.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _importController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste your backup JSON here',
            ),
            onChanged: (_) => setState(() {}), // refresh Restore enabled-state
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Restore',
            icon: Icons.upload_rounded,
            isLoading: _importing,
            onPressed: canRestore ? _restore : null,
          ),

          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.lock_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'A backup includes your notes and how you felt. Keep it private.',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
