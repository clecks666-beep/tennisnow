import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/equipment/domain/equipment_type.dart';

void main() {
  group('EquipmentType', () {
    test('round-trips through storage values', () {
      for (final type in EquipmentType.values) {
        expect(EquipmentType.fromStorage(type.storageValue), type);
      }
    });

    test('falls back to other for unknown values', () {
      expect(EquipmentType.fromStorage('unknown'), EquipmentType.other);
    });
  });
}
