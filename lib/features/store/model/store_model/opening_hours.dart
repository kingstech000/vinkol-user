// lib/features/store/model/store_model.dart

// When a store is open, and how to say so.

class OpeningHours {
  final DayHours? monday;
  final DayHours? tuesday;
  final DayHours? wednesday;
  final DayHours? thursday;
  final DayHours? friday;
  final DayHours? saturday;
  final DayHours? sunday;

  OpeningHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      monday: json['monday'] != null
          ? DayHours.fromJson(json['monday'] as Map<String, dynamic>)
          : null,
      tuesday: json['tuesday'] != null
          ? DayHours.fromJson(json['tuesday'] as Map<String, dynamic>)
          : null,
      wednesday: json['wednesday'] != null
          ? DayHours.fromJson(json['wednesday'] as Map<String, dynamic>)
          : null,
      thursday: json['thursday'] != null
          ? DayHours.fromJson(json['thursday'] as Map<String, dynamic>)
          : null,
      friday: json['friday'] != null
          ? DayHours.fromJson(json['friday'] as Map<String, dynamic>)
          : null,
      saturday: json['saturday'] != null
          ? DayHours.fromJson(json['saturday'] as Map<String, dynamic>)
          : null,
      sunday: json['sunday'] != null
          ? DayHours.fromJson(json['sunday'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday?.toJson(),
      'tuesday': tuesday?.toJson(),
      'wednesday': wednesday?.toJson(),
      'thursday': thursday?.toJson(),
      'friday': friday?.toJson(),
      'saturday': saturday?.toJson(),
      'sunday': sunday?.toJson(),
    };
  }

  /// Check if store is open today
  bool isOpenToday() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday

    DayHours? todayHours;
    switch (dayOfWeek) {
      case 1:
        todayHours = monday;
        break;
      case 2:
        todayHours = tuesday;
        break;
      case 3:
        todayHours = wednesday;
        break;
      case 4:
        todayHours = thursday;
        break;
      case 5:
        todayHours = friday;
        break;
      case 6:
        todayHours = saturday;
        break;
      case 7:
        todayHours = sunday;
        break;
    }

    // If no hours data for today, assume closed
    if (todayHours == null) {
      return false;
    }

    // If isClosed is false, store is open
    return !(todayHours.isClosed ?? true);
  }
}

class DayHours {
  final bool? isClosed;
  final List<dynamic>? hours;

  DayHours({
    this.isClosed,
    this.hours,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      isClosed: json['isClosed'] as bool?,
      hours: json['hours'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isClosed': isClosed,
      'hours': hours,
    };
  }
}
