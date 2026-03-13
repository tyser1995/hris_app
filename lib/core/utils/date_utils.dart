import 'package:intl/intl.dart';

class HrisDateUtils {
  HrisDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDate = DateFormat('MMM d, yyyy');
  static final DateFormat _displayTime = DateFormat('hh:mm a');
  static final DateFormat _displayDateTime = DateFormat('MMM d, yyyy hh:mm a');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String toIso(DateTime date) => _dateFormat.format(date);

  static String toDisplay(DateTime date) => _displayDate.format(date);

  static String toDisplayTime(DateTime dateTime) => _displayTime.format(dateTime);

  static String toDisplayDateTime(DateTime dateTime) => _displayDateTime.format(dateTime);

  static String toMonthYear(DateTime date) => _monthYear.format(date);

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

  static int workingDaysInMonth(DateTime date) {
    final start = startOfMonth(date);
    final end = endOfMonth(date);
    int count = 0;
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return toDisplay(dateTime);
  }
}
