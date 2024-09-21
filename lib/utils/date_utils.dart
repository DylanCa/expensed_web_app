import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMMM d, yyyy').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('MMM d, y').format(date);
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String getMonthAbbreviation(int month) {
  return DateFormat('MMM').format(DateTime(2023, month, 1));
}
