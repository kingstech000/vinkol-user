import 'package:intl/intl.dart';

extension DateEX on DateTime {
  isSameDay(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  /// this is to check how many days form today
  /// the date is
  int isDayOld() {
    return DateTime.now().difference(this).inDays;
  }

  bool isDayOldLessThan(int count) {
    return DateTime.now().difference(this).inDays < count;
  }

  /// Returns a formatted date string if the current date is different from the previous date.
  /// If the dates are the same, null is returned.
  String? getFormattedDateIfDayDiffers(DateTime previousDate) {
    final currentDate = this;

    if (currentDate.isSameDay(previousDate)) {
      // The dates are the same, so return null to indicate that no special string is needed
      return null;
    }

    return getFormattedDate();
  }

  /// Returns a string that represents the date of [this] DateTime instance, with special
  /// strings for "Today" and "Yesterday" if applicable.
  /// If the date is neither "Today" nor "Yesterday", it will be formatted with the pattern "dd-EEE-yyyy".
  String getFormattedDate() {
    if (isSameDay(DateTime.now())) {
      // The current date is today
      return "Today";
    } else if (isSameDay(DateTime.now().subtract(const Duration(days: 1)))) {
      // The current date is yesterday
      return "Yesterday";
    } else {
      // The current date is neither today nor yesterday, so format it with the given pattern
      return DateFormat("dd-MMM-yyyy").format(this);
    }
  }
}
