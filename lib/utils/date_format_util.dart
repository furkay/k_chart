import 'package:intl/intl.dart';

String dateFormat(DateTime date) {
  return DateFormat.yMMMEd().format(date);
}
