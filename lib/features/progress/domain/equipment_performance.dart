/// Average performance recorded with a given piece of equipment. Pure domain
/// value powering the "Performance by equipment" view.
class EquipmentPerformance {
  final String name;
  final double avgPerformance; // 1..5
  final int sessions;

  const EquipmentPerformance({
    required this.name,
    required this.avgPerformance,
    required this.sessions,
  });
}
