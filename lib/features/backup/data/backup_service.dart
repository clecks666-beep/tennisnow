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
  const BackupImportResult({required this.sessions, required this.equipment});
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

  /// Current envelope format. Bump only if the JSON shape changes.
  static const int formatVersion = 1;
  static const String _appTag = 'tennisnow';

  Future<String> export() async {
    final sessions = await _db.allActiveSessionsOnce();
    final equipment = await _db.allActiveEquipmentOnce();

    final envelope = <String, dynamic>{
      'app': _appTag,
      'format': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessions': sessions.map(_sessionToJson).toList(),
      'equipment': equipment.map(_equipmentToJson).toList(),
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

    try {
      for (final s in sessions) {
        await _db.upsertSession(_sessionFromJson(s as Map));
      }
      for (final e in equipment) {
        await _db.upsertEquipment(_equipmentFromJson(e as Map));
      }
    } catch (_) {
      throw const BackupFormatException('This backup is missing some fields.');
    }

    return BackupImportResult(
      sessions: sessions.length,
      equipment: equipment.length,
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
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  static EquipmentItemsCompanion _equipmentFromJson(Map j) =>
      EquipmentItemsCompanion(
        id: Value(j['id'] as String),
        name: Value(j['name'] as String),
        type: Value(j['type'] as String),
        createdAt: Value(DateTime.parse(j['createdAt'] as String)),
        updatedAt: Value(DateTime.parse(j['updatedAt'] as String)),
        deletedAt: const Value(null),
      );
}
