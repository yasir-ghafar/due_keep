extension LedgerDateTime on DateTime {
  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// e.g. Thu 27 Aug
  String get weekdayDayMonth =>
      '${_weekdays[weekday - 1]} $day ${_months[month - 1]}';

  /// e.g. 25 Aug 2026
  String get dayMonthYear => '$day ${_months[month - 1]} $year';
}
