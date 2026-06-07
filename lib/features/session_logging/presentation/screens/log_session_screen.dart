import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../design_system/widgets/rating_selector.dart';
import '../../../../design_system/widgets/section_label.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../../../shared/domain/session_type.dart';
import '../../../equipment/presentation/widgets/equipment_picker_field.dart';
import '../../../gamification/presentation/providers/progression_reward.dart';
import '../../../settings/presentation/providers/settings_controller.dart';
import '../../../skills/presentation/providers/skill_rating_controller.dart';
import '../../../skills/presentation/widgets/skill_rating_sheet.dart';
import '../../domain/match_result.dart';
import '../../domain/tennis_session.dart';
import '../providers/log_session_controller.dart';

/// The quick-log form — the sacred core flow (do-not-break rule #1).
///
/// Defaults to Training + now, so a user can tap Save immediately (<30s).
/// Everything except type is optional and never blocks saving (CLAUDE.md §4).
/// Local form state is ephemeral UI state, so setState is appropriate here
/// (CLAUDE.md §3 forbids setState only for app/business state).
///
/// Doubles as the EDIT form: pass [existing] to prefill and update that session
/// (its date/time is preserved). Reached from the FAB (new) or by tapping a
/// history entry (edit).
class LogSessionScreen extends ConsumerStatefulWidget {
  final TennisSession? existing;

  const LogSessionScreen({super.key, this.existing});

  @override
  ConsumerState<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _LogSessionScreenState extends ConsumerState<LogSessionScreen> {
  late SessionType _type;
  MatchResult? _result;
  int? _durationMinutes;
  int? _performance;
  int? _mood;
  int? _energy;

  /// Selected equipment NAME, chosen via the picker (stored on the session).
  String? _equipmentName;

  /// skillId -> 1..5 self-ratings captured for this session (optional).
  final Map<String, int> _skillRatings = {};

  final TextEditingController _noteController = TextEditingController();

  /// Captures the progression baseline so we can show what this save earned
  /// (XP, level-up, badges) without adding latency to the Save tap.
  late final ProgressionReward _reward;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _reward = ref.read(progressionRewardProvider)..captureBaseline();
    final existing = widget.existing;
    if (existing == null) {
      // New session: start on the user's preferred default (Settings).
      _type = ref.read(settingsControllerProvider).defaultSessionType;
    } else {
      // Editing: prefill every field from the saved session.
      _type = existing.type;
      _result = existing.result;
      _durationMinutes = existing.durationMinutes;
      _performance = existing.performance?.value;
      _mood = existing.mood?.value;
      _energy = existing.energy?.value;
      _equipmentName = existing.equipment;
      _noteController.text = existing.note ?? '';
      _loadSkillRatings(existing.id);
    }
  }

  Future<void> _loadSkillRatings(String sessionId) async {
    final saved = await ref
        .read(skillRatingControllerProvider.notifier)
        .loadForSession(sessionId);
    if (mounted && saved.isNotEmpty) {
      setState(() => _skillRatings.addAll(saved));
    }
  }

  Future<void> _editSkills() async {
    final result = await showSkillRatingSheet(context, initial: _skillRatings);
    if (result != null) {
      setState(() => _skillRatings
        ..clear()
        ..addAll(result));
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final draft = SessionDraft(
      type: _type,
      result: _result,
      durationMinutes: _durationMinutes,
      performance: _performance,
      mood: _mood,
      energy: _energy,
      equipment: _equipmentName,
      note: _noteController.text,
    );

    // Capture the messenger BEFORE any pop, so the confirmation still shows
    // after this screen's own context is gone.
    final messenger = ScaffoldMessenger.of(context);

    final saved = await ref
        .read(logSessionControllerProvider.notifier)
        .save(draft, existing: widget.existing);
    if (!mounted) return;

    if (saved != null) {
      // Attach the optional skill self-ratings to the just-saved session.
      await ref
          .read(skillRatingControllerProvider.notifier)
          .save(saved.id, saved.playedAt, _skillRatings);
      if (!mounted) return;
      // The history list updates reactively; pop back, then surface what was
      // earned — XP, a level-up or a new badge (CLAUDE.md §4: progression felt).
      context.pop();
      await _reward.showEarned(messenger, isEdit: _isEdit);
    } else {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text("Couldn't save — please try again")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(logSessionControllerProvider);
    final isSaving = saveState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit session' : 'Log session')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  const SectionLabel('Type'),
                  SelectableChipGroup<SessionType>(
                    selected: _type,
                    allowDeselect: false, // type is required
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
                    onChanged: (value) => setState(() {
                      _type = value ?? SessionType.training;
                      if (_type != SessionType.match) _result = null;
                    }),
                  ),

                  // Result only matters for matches — revealed contextually.
                  if (_type == SessionType.match) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const SectionLabel('Result', optional: true),
                    SelectableChipGroup<MatchResult>(
                      selected: _result,
                      options: const [
                        ChipOption(value: MatchResult.win, label: 'Win'),
                        ChipOption(value: MatchResult.loss, label: 'Loss'),
                        ChipOption(value: MatchResult.draw, label: 'Draw'),
                      ],
                      onChanged: (value) => setState(() => _result = value),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Duration', optional: true),
                  SelectableChipGroup<int>(
                    selected: _durationMinutes,
                    options: AppConstants.quickDurationsMinutes
                        .map((m) => ChipOption(value: m, label: '$m min'))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _durationMinutes = value),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Performance', optional: true),
                  RatingSelector(
                    value: _performance,
                    lowLabel: 'Off day',
                    highLabel: 'Played great',
                    onChanged: (value) => setState(() => _performance = value),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Mood', optional: true),
                  RatingSelector(
                    value: _mood,
                    lowLabel: 'Low',
                    highLabel: 'Great',
                    onChanged: (value) => setState(() => _mood = value),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Energy', optional: true),
                  RatingSelector(
                    value: _energy,
                    lowLabel: 'Drained',
                    highLabel: 'Full tank',
                    onChanged: (value) => setState(() => _energy = value),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Equipment', optional: true),
                  EquipmentPickerField(
                    value: _equipmentName,
                    onChanged: (name) =>
                        setState(() => _equipmentName = name),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Skills worked on', optional: true),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _editSkills,
                      icon: const Icon(Icons.fitness_center_outlined, size: 18),
                      label: Text(
                        _skillRatings.isEmpty
                            ? 'Add skills'
                            : '${_skillRatings.length} skills rated · edit',
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel('Notes', optional: true),
                  TextField(
                    controller: _noteController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Anything worth remembering about this session',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: PrimaryButton(
                label: _isEdit ? 'Save changes' : 'Save session',
                icon: Icons.check,
                isLoading: isSaving,
                onPressed: isSaving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
