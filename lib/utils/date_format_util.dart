import 'package:intl/intl.dart';

String formatDate(DateTime date, DateFormat dateFormatter) {
  return dateFormatter.format(date);
}
