/// Category of a piece of equipment. Stored by [storageValue] so persistence is
/// stable even if labels change.
enum EquipmentType {
  racket('racket', 'Racket'),
  strings('strings', 'Strings'),
  shoes('shoes', 'Shoes'),
  other('other', 'Other');

  final String storageValue;
  final String label;

  const EquipmentType(this.storageValue, this.label);

  static EquipmentType fromStorage(String value) {
    return EquipmentType.values.firstWhere(
      (t) => t.storageValue == value,
      orElse: () => EquipmentType.other,
    );
  }
}
