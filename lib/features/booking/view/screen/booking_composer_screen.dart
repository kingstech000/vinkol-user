import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/booking/view/widget/ride_detail_input_field.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// Where a Single Drop booking gets its two addresses.
///
/// The home card asks *what kind of delivery*; this screen asks *from where, to where*. It
/// is deliberately thin for now — it hosts the existing stops composer unchanged so the
/// flow keeps working end to end — and is the next piece to be redesigned against the
/// prototype, together with the Find Rider step it leads to.
class BookingComposerScreen extends ConsumerWidget {
  const BookingComposerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: AppBar(
        backgroundColor: v.canvas,
        surfaceTintColor: v.canvas,
        elevation: 0,
        title: Text(
          context.l10n.bookingSetYourStops,
          style: VinkolType.h3.copyWith(color: v.textPrimary),
        ),
      ),
      body: const SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: VinkolSpace.sm,
            bottom: VinkolSpace.xxl,
          ),
          child: RideDetailsInput(embedded: true),
        ),
      ),
    );
  }
}
