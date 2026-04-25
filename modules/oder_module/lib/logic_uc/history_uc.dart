import 'package:flutter/material.dart';

class HistoryUC {
  DateTimeRange getMonthRange(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final nextMonth = month.month == 12 ? 1 : month.month + 1;
    final nextYear = month.month == 12 ? month.year + 1 : month.year;
    final end = DateTime(nextYear, nextMonth, 1);
    return DateTimeRange(start: start, end: end);
  }
}
