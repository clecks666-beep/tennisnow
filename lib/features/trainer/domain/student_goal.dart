enum GoalHorizon {
  short,
  mid,
  long;

  String get label {
    switch (this) {
      case GoalHorizon.short:
        return 'Short-term';
      case GoalHorizon.mid:
        return 'Mid-term';
      case GoalHorizon.long:
        return 'Long-term';
    }
  }
}

enum GoalStatus {
  open,
  inProgress,
  done,
  archived;

  String get label {
    switch (this) {
      case GoalStatus.open:
        return 'Open';
      case GoalStatus.inProgress:
        return 'In Progress';
      case GoalStatus.done:
        return 'Done';
      case GoalStatus.archived:
        return 'Archived';
    }
  }
}

/// A development goal set for a student.
class StudentGoal {
  final String id;
  final String studentId;
  final GoalHorizon horizon;
  final GoalStatus status;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const StudentGoal({
    required this.id,
    required this.studentId,
    required this.horizon,
    required this.status,
    required this.title,
    this.description,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
