import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/screen/location_search_screen.dart';
import 'package:starter_codes/features/booking/view/screen/map_picker_screen.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Everything a drop-off needs beyond its address.
class StopDetails {
  const StopDetails({
    required this.packageName,
    required this.recipientName,
    required this.recipientPhone,
    required this.note,
  });

  final String packageName;
  final String recipientName;
  final String recipientPhone;
  final String note;
}

/// Asks where a stop is — by search, or by dropping a pin.
///
/// Two ways in, because they answer different questions: search is for an address you can
/// name, the map is for a gate, a stall or a corner that has no address to name.
Future<LocationModel?> pickStopLocation(
  BuildContext context, {
  required bool isPickup,
  required String stopId,
}) async {
  final v = context.vinkol;

  final bool? useMap = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: v.surface,
    shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSheet),
    builder: (BuildContext sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.xl,
          VinkolSpace.pageMargin,
          VinkolSpace.xxl,
        ),
        child: VinkolRowGroup(
          children: <VinkolRow>[
            VinkolRow(
              title: sheetContext.l10n.bookingSearchForAPlace,
              meta: sheetContext.l10n.bookingTypeAnAddressOrLandmark,
              icon: Icons.search,
              onTap: () => Navigator.of(sheetContext).pop(false),
            ),
            VinkolRow(
              title: sheetContext.l10n.bookingPickOnMap,
              meta: sheetContext.l10n.bookingDropAPinAnywhere,
              icon: Icons.map_outlined,
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    ),
  );

  if (useMap == null || !context.mounted) return null;

  return Navigator.of(context).push<LocationModel>(
    MaterialPageRoute<LocationModel>(
      builder: (BuildContext context) => useMap
          ? MapPickerScreen(isPickupLocation: isPickup, stopId: stopId)
          : LocationSearchScreen(isPickupLocation: isPickup, stopId: stopId),
    ),
  );
}

/// Collects the package and recipient that travel with one drop-off.
///
/// It is a sheet rather than a later screen because the API models these per stop: a batch of
/// five deliveries is five packages and five recipients, and asking for them all at the end,
/// indexed by number, is how the old flow made people match "Item 3" to an address by memory.
Future<StopDetails?> showStopDetailsSheet(
  BuildContext context, {
  required StopModel stop,
  required String title,
}) {
  return showModalBottomSheet<StopDetails>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.vinkol.surface,
    shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSheet),
    builder: (BuildContext sheetContext) =>
        _StopDetailsSheet(stop: stop, title: title),
  );
}

class _StopDetailsSheet extends StatefulWidget {
  const _StopDetailsSheet({required this.stop, required this.title});

  final StopModel stop;
  final String title;

  @override
  State<_StopDetailsSheet> createState() => _StopDetailsSheetState();
}

class _StopDetailsSheetState extends State<_StopDetailsSheet> {
  late final TextEditingController _package =
      TextEditingController(text: widget.stop.packageName);
  late final TextEditingController _name =
      TextEditingController(text: widget.stop.recipientName);
  late final TextEditingController _phone =
      TextEditingController(text: widget.stop.recipientPhone);
  late final TextEditingController _note =
      TextEditingController(text: widget.stop.note);

  @override
  void dispose() {
    _package.dispose();
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _complete =>
      _package.text.trim().isNotEmpty &&
      _name.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            VinkolSpace.pageMargin,
            VinkolSpace.xl,
            VinkolSpace.pageMargin,
            VinkolSpace.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: VinkolType.h3.copyWith(color: v.textPrimary),
              ),
              if (widget.stop.location?.formattedAddress != null) ...<Widget>[
                const SizedBox(height: VinkolSpace.xs),
                Text(
                  widget.stop.location!.formattedAddress!,
                  style: VinkolType.bodyS.copyWith(color: v.textSecondary),
                ),
              ],
              const SizedBox(height: VinkolSpace.xl),
              VinkolFormField(
                label: l10n.bookingWhatIsInThePackage,
                hint: l10n.bookingEnterPackageName,
                controller: _package,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolFormField(
                label: l10n.bookingRecipientName,
                controller: _name,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolFormField(
                label: l10n.bookingRecipientPhoneNumber,
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolFormField(
                label: l10n.bookingNoteForTheRider,
                helper: l10n.bookingNoteForTheRiderHelper,
                controller: _note,
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: VinkolSpace.xxl),
              VinkolPrimaryButton(
                label: l10n.bookingSaveStop,
                onPressed: _complete
                    ? () => Navigator.of(context).pop(
                          StopDetails(
                            packageName: _package.text.trim(),
                            recipientName: _name.text.trim(),
                            recipientPhone: _phone.text.trim(),
                            note: _note.text.trim(),
                          ),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
