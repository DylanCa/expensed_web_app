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
