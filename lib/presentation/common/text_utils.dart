import 'package:intl/intl.dart';

String capitalized(String text) =>
    text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

String formatDecimal(num value) => NumberFormat('#0.#').format(value);
