import 'package:starter_codes/features/booking/data/ride_notifier.dart';

/// What each delivery shape is called and how it is explained, in one place
/// so the chooser and the stops card say the same thing.
extension OrderTypeCopy on OrderType {
  String get title => switch (this) {
        OrderType.standard => 'Standard',
        OrderType.bulk => 'Bulk',
        OrderType.multi => 'Multi',
      };

  String get description => switch (this) {
        OrderType.standard => 'One pick-up, one drop-off.',
        OrderType.bulk => 'One pick-up, several drop-offs.',
        OrderType.multi => 'Several separate orders in one go.',
      };
}
