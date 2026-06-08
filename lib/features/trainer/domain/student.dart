/// Sync-ready invariant (id/createdAt/updatedAt/deletedAt) included, matching
/// the entity pattern across the app (CLAUDE.md §2 do-not-break rule #3).
enum StudentCategory {
  child,
  youth,
  adult,
  tournament;

  /// Human-readable label, Flutter-free (domain stays pure).
  String get label {
    switch (this) {
      case StudentCategory.child:
        return 'Child';
      case StudentCategory.youth:
        return 'Youth';
      case StudentCategory.adult:
        return 'Adult';
      case StudentCategory.tournament:
        return 'Tournament';
    }
  }
}

/// A student in the trainer's roster.
class Student {
  final String id;
  final String name;
  final int? birthYear;
  final StudentCategory category;
  final String? notes;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Student({
    required this.id,
    required this.name,
    this.birthYear,
    required this.category,
    this.notes,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isActive => deletedAt == null && archivedAt == null;

  Student copyWith({
    String? name,
    int? birthYear,
    bool clearBirthYear = false,
    StudentCategory? category,
    String? notes,
    bool clearNotes = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      birthYear: clearBirthYear ? null : (birthYear ?? this.birthYear),
      category: category ?? this.category,
      notes: clearNotes ? null : (notes ?? this.notes),
      archivedAt:
          clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
    );
  }
}
