enum NoteType {
  observation,
  homework,
  technique,
  mental,
  injury,
  general;

  String get label {
    switch (this) {
      case NoteType.observation:
        return 'Observation';
      case NoteType.homework:
        return 'Homework';
      case NoteType.technique:
        return 'Technique';
      case NoteType.mental:
        return 'Mental';
      case NoteType.injury:
        return 'Injury';
      case NoteType.general:
        return 'General';
    }
  }
}

/// A coaching note attached to a training session with a specific student.
class TrainingNote {
  final String id;
  final String studentId;
  final NoteType type;
  final String content;
  final DateTime sessionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TrainingNote({
    required this.id,
    required this.studentId,
    required this.type,
    required this.content,
    required this.sessionDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
