/// Lightweight, dependency-free date formatting for the history list.
/// Kept in core/ so any feature can reuse it (CLAUDE.md §3).
class DateFormatX {
  DateFormatX._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Human, relative-aware label: "Today", "Yesterday", or "12 Mar".
  static String relativeDay(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(reference.year, reference.month, reference.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day} ${_months[date.month - 1]}';
  }

  /// "14:05" 24-hour clock.
  static String time(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
