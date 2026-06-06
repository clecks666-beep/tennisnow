import '../../../shared/domain/rating.dart';
import 'match_result.dart';
import 'session_type.dart';

/// A single logged tennis session — the central entity of the core loop.
///
/// Pure domain object (CLAUDE.md §2): immutable, no Flutter, no persistence
/// concerns. Carries the sync-ready invariant fields (id/createdAt/updatedAt/
/// deletedAt) required by do-not-break rule #3.
///
/// Connecting [performance] with [mood], [energy] and [equipment] is the
/// product's differentiator — these live together on the session on purpose.
class TennisSession {
  final String id;
  final SessionType type;
  final DateTime playedAt;

  /// Match outcome — only set for matches.
  final MatchResult? result;

  final int? durationMinutes;

  /// Self-rated 1–5 scales. Optional so logging is never blocked (CLAUDE.md §4).
  final Rating? performance;
  final Rating? mood;
  final Rating? energy;

  /// Free-text equipment note for now (e.g. "Pure Aero / new strings").
  /// A structured Equipment entity is intentionally postponed.
  final String? equipment;

  final String? note;

  // Sync-ready invariant fields.
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TennisSession({
    required this.id,
    required this.type,
    required this.playedAt,
    required this.createdAt,
    required this.updatedAt,
    this.result,
    this.durationMinutes,
    this.performance,
    this.mood,
    this.energy,
    this.equipment,
    this.note,
    this.deletedAt,
  });

  bool get isMatch => type == SessionType.match;
  bool get isDeleted => deletedAt != null;

  TennisSession copyWith({
    SessionType? type,
    DateTime? playedAt,
    MatchResult? result,
    int? durationMinutes,
    Rating? performance,
    Rating? mood,
    Rating? energy,
    String? equipment,
    String? note,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TennisSession(
      id: id,
      type: type ?? this.type,
      playedAt: playedAt ?? this.playedAt,
      result: result ?? this.result,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      performance: performance ?? this.performance,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      equipment: equipment ?? this.equipment,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
