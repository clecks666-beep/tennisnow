import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../design_system/widgets/rating_selector.dart';
import '../../../../design_system/widgets/section_label.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../../../shared/domain/match_result.dart';
import '../../../../shared/domain/session_type.dart';
import '../../../equipment/presentation/widgets/equipment_picker_field.dart';
import '../../../skills/presentation/widgets/skill_rating_sheet.dart';
import '../../domain/student_session.dart';
import '../providers/log_student_session_controller.dart';
import '../providers/trainer_providers.dart';

/// Full session-logging form for a coached student — identical feature set to
/// [LogSessionScreen] (type, result, duration, performance, mood, energy,
/// equipment, skills, notes) but saves via [LogStudentSessionController] and
/// links the session to the student. No XP/gamification feedback because
/// coaching activity is separate from the trainer's own progression.
class LogStudentSessionScreen extends ConsumerStatefulWidget {
  final String studentId;
  final StudentSession? existing;

  const LogStudentSessionScreen({
    super.key,
    required this.studentId,
    this.existing,
  });

  @override
  ConsumerState<LogStudentSessionScreen> createState() =>
      _LogStudentSessionScreenState();
}

class _LogStudentSessionScreenState
    extends ConsumerState<LogStudentSessionScreen> {
  late SessionType _type;
  MatchResult? _result;
  int? _durationMinutes;
  int? _performance;
  int? _mood;
  int? _energy;
  String? _equipmentName;
  final Map<String, int> _skillRatings = {};
  final TextEditingController _noteController = TextEditingController();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing == null) {
      _type = SessionType.training;
    } else {
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
    final map = await ref
        .read(trainerRepositoryProvider)
        .studentSkillRatingsForSession(sessionId);
    if (mounted && map.isNotEmpty) {
      setState(() => _skillRatings.addAll(map));
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
    final draft = StudentSessionDraft(
      type: _type,
      result: _result,
      durationMinutes: _durationMinutes,
      performance: _performance,
      mood: _mood,
      energy: _energy,
      equipment: _equipmentName,
      note: _noteController.text,
    );

    final messenger = ScaffoldMessenger.of(context);

    final saved = await ref
        .read(logStudentSessionControllerProvider.notifier)
        .save(widget.studentId, draft, existing: widget.existing);

    if (!mounted) return;

    if (saved != null) {
      // Save skill ratings for the student session.
      await ref
          .read(trainerRepositoryProvider)
          .replaceStudentSkillRatingsForSession(
            saved.id,
            saved.playedAt,
            _skillRatings,
            DateTime.now(),
          );
      if (!mounted) return;
      context.pop();
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Session updated' : 'Session saved'),
          ),
        );
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
    final studentAsync = ref.watch(activeStudentsProvider);
    final studentName = studentAsync.valueOrNull
            ?.firstWhere(
              (s) => s.id == widget.studentId,
              orElse: () => studentAsync.valueOrNull!.first,
            )
            .name ??
        'Student';

    final saveState = ref.watch(logStudentSessionControllerProvider);
    final isSaving = saveState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit session' : 'Log for $studentName'),
      ),
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
                    onChanged: (value) => setState(() {
                      _type = value ?? SessionType.training;
                      if (_type != SessionType.match) _result = null;
                    }),
                  ),

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
