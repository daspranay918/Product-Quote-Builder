import 'package:intl/intl.dart';

String money(num value, {String code = 'INR'}) {
  final format = NumberFormat.currency(
    name: code,
    symbol: NumberFormat.simpleCurrency(name: code).currencySymbol,
    decimalDigits: 2,
  );
  return format.format(value);
}

String percent(num value) {
  final format = NumberFormat.decimalPattern();
  return "${format.format(value)}%";
}
