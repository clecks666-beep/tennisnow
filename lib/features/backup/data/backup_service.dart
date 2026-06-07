import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../shared/data/app_database.dart';

/// Thrown when a pasted backup can't be understood.
class BackupFormatException implements Exception {
  final String message;
  const BackupFormatException(this.message);
  @override
  String toString() => 'BackupFormatException: $message';
}

/// Result of a restore: how many records were written.
class BackupImportResult {
  final int sessions;
  final int equipment;
  final int skillRatings;
  const BackupImportResult({
    required this.sessions,
    required this.equipment,
    required this.skillRatings,
  });
}

/// Serializes the local database to a portable JSON backup and restores from it.
///
/// Works at the persistence (row) level on the shared [AppDatabase], so backup
/// depends only on shared infra — never on another feature's domain/data
/// (CLAUDE.md §2). Restore is a merge: rows are upserted by their stable UUID,
/// so importing the same backup twice is harmless and never deletes data.
class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  /// Current envelope format. v2 adds equipment stringing details and the
  /// skillRatings array; v1 backups still import fine (missing parts default to
  /// empty/null). Bump only if the JSON shape changes.
  static const int formatVersion = 2;
  static const String _appTag = 'tennisnow';

  Future<String> export() async {
    final sessions = await _db.allActiveSessionsOnce();
    final equipment = await _db.allActiveEquipmentOnce();
    final skillRatings = await _db.allActiveSkillRatingsOnce();

    final envelope = <String, dynamic>{
      'app': _appTag,
      'format': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessions': sessions.map(_sessionToJson).toList(),
      'equipment': equipment.map(_equipmentToJson).toList(),
      'skillRatings': skillRatings.map(_skillRatingToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Parses and restores [raw]. Throws [BackupFormatException] on bad input.
  Future<BackupImportResult> import(String raw) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw const BackupFormatException('That doesn\'t look like valid JSON.');
    }
    if (decoded is! Map || decoded['app'] != _appTag) {
      throw const BackupFormatException('This is not a tennisnow backup.');
    }

    final sessions = (decoded['sessions'] as List?) ?? const [];
    final equipment = (decoded['equipment'] as List?) ?? const [];
    // Absent in v1 backups — defaults to empty so older exports still import.
    final skillRatings = (decoded['skillRatings'] as List?) ?? const [];

    try {
      for (final s in sessions) {
        await _db.upsertSession(_sessionFromJson(s as Map));
      }
      for (final e in equipment) {
        await _db.upsertEquipment(_equipmentFromJson(e as Map));
      }
      for (final r in skillRatings) {
        await _db.upsertSkillRating(_skillRatingFromJson(r as Map));
      }
    } catch (_) {
      throw const BackupFormatException('This backup is missing some fields.');
    }

    return BackupImportResult(
      sessions: sessions.length,
      equipment: equipment.length,
      skillRatings: skillRatings.length,
    );
  }

  // ---- row <-> json ----

  static Map<String, dynamic> _sessionToJson(Session s) => {
        'id': s.id,
        'type': s.type,
        'playedAt': s.playedAt.toIso8601String(),
        'result': s.result,
        'durationMinutes': s.durationMinutes,
        'performance': s.performance,
        'mood': s.mood,
        'energy': s.energy,
        'equipment': s.equipment,
        'note': s.note,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
      };

  static SessionsCompanion _sessionFromJson(Map j) => SessionsCompanion(
        id: Value(j['id'] as String),
        type: Value(j['type'] as String),
        playedAt: Value(DateTime.parse(j['playedAt'] as String)),
        result: Value(j['result'] as String?),
        durationMinutes: Value((j['durationMinutes'] as num?)?.toInt()),
        performance: Value((j['performance'] as num?)?.toInt()),
        mood: Value((j['mood'] as num?)?.toInt()),
        energy: Value((j['energy'] as num?)?.toInt()),
        equipment: Value(j['equipment'] as String?),
        note: Value(j['note'] as String?),
        createdAt: Value(DateTime.parse(j['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(j['updatedAt'] as String)),
        deletedAt: const Value(null), // restored rows are active
      );

  static Map<String, dynamic> _equipmentToJson(EquipmentItem e) => {
        'id': e.id,
        'name': e.name,
        'type': e.type,
        'stringName': e.stringName,
        'tensionKg': e.tensionKg,
        'lastStrungAt': e.lastStrungAt?.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  static EquipmentItemsCompanion _equipmentFromJson(Map j) =>
      EquipmentItemsCompanion(
        id: Value(j['id'] as String),
        name: Value(j['name'] as String),
        type: Value(j['type'] as String),
        // Nullable + absent in v1 backups, so read defensively.
        stringName: Value(j['stringName'] as String?),
        tensionKg: Value((j['tensionKg'] as num?)?.toDouble()),
        lastStrungAt: Value(_parseNullableDate(j['lastStrungAt'])),
        createdAt: Value(DateTime.parse(j['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(j['updatedAt'] as String)),
        deletedAt: const Value(null),
      );

  static Map<String, dynamic> _skillRatingToJson(SkillRating r) => {
        'id': r.id,
        'sessionId': r.sessionId,
        'skillId': r.skillId,
        'value': r.value,
        'recordedAt': r.recordedAt.toIso8601String(),
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
      };

  static SkillRatingsCompanion _skillRatingFromJson(Map j) =>
      SkillRatingsCompanion(
        id: Value(j['id'] as String),
        sessionId: Value(j['sessionId'] as String),
        skillId: Value(j['skillId'] as String),
        value: Value((j['value'] as num).toInt()),
        recordedAt: Value(DateTime.parse(j['recordedAt'] as String)),
        createdAt: Value(DateTime.parse(j['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(j['updatedAt'] as String)),
        deletedAt: const Value(null),
      );

  /// Parses an optional ISO-8601 string; tolerates null/missing values.
  static DateTime? _parseNullableDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
