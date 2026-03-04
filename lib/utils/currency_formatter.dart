import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat('#,###', 'ko_KR');

  static String format(double value) {
    return _formatter.format(value.round());
  }

  static String formatWithWon(double value) {
    return '${_formatter.format(value.round())}원';
  }

  static double parse(String value) {
    if (value.isEmpty) return 0;
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanValue) ?? 0;
  }
}

class DateFormatter {
  static final _formatter = DateFormat('yyyy-MM-dd');
  static final _koreanFormatter = DateFormat('yyyy년 MM월 dd일');

  static String format(DateTime date) {
    return _formatter.format(date);
  }

  static String formatKorean(DateTime date) {
    return _koreanFormatter.format(date);
  }
}


