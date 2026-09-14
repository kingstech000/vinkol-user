import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/copy_to_clipboard_util.dart';
import 'package:starter_codes/core/utils/launch_link.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';
import 'package:starter_codes/features/delivery/view/widget/order_status_widgets.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/circular_network_image.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';

/// The pieces an order's own screen is built from, shared by the package
/// delivery and the store order so the two read as one product: the same
/// header, the same Line, the same receipt, the same handover code. Each screen
/// only decides which of them to stack and what to feed them.

// ---------------------------------------------------------------------------
// Chrome
// ---------------------------------------------------------------------------

/// What sits under the sheet while the map has nothing to draw.
class OrderMapPlaceholder extends StatelessWidget {
  const OrderMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: VinkolPalette.neutral100);
}

/// The sheet's empty and error states: one icon, one line, nothing to do.
class OrderSheetMessage extends StatelessWidget {
  const OrderSheetMessage({
    super.key,
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? VinkolPalette.dangerText : VinkolPalette.neutral500;
    return Padding(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32.w, color: color),
          Gap.h12,
          AppText.body(
            message,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
            centered: true,
          ),
        ],
      ),
    );
  }
}

/// A content block: white, hairline, no shadow (e0).
class OrderDetailCard extends StatelessWidget {
  const OrderDetailCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }
}

/// The small-caps label above a value.
class OrderDetailLabel extends StatelessWidget {
  const OrderDetailLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText.caption(
      text.toUpperCase(),
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: VinkolPalette.neutral400,
      letterSpacing: 0.6,
      maxLines: 1,
    );
  }
}

class OrderHairline extends StatelessWidget {
  const OrderHairline({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: VinkolPalette.neutral100);
}

String orderTitleCase(String value) =>
    value[0].toUpperCase() + value.substring(1).toLowerCase();

// ---------------------------------------------------------------------------
// Header — the reference, what kind of order it is, and where it stands
// ---------------------------------------------------------------------------

class OrderHeaderCard extends StatelessWidget {
  const OrderHeaderCard({
    super.key,
    required this.delivery,
    required this.status,
    required this.subtitle,
  });

  final DeliveryModel delivery;
  final OrderStatus status;

  /// What kind of order this is, e.g. `Package delivery · Regular · Bike` —
  /// only the parts the order carries.
  final String subtitle;

  /// What the customer quotes when they call support. The tracking id is the
  /// one meant for humans; the record id is the fallback for older orders.
  String get _reference {
    final tracking = delivery.trackingId?.trim();
    if (tracking != null && tracking.isNotEmpty) return tracking.toUpperCase();
    final id = delivery.id ?? '';
    if (id.isEmpty) return '—';
    return id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final style = OrderStatusStyle.of(status);
    final canCopy = delivery.trackingId?.trim().isNotEmpty == true;

    return OrderDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OrderDetailLabel('Tracking ID'),
                    Gap.h4,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canCopy
                          ? () => copyToClipboard(
                                context,
                                delivery.trackingId!.trim(),
                                successMessage: 'Tracking ID copied!',
                              )
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: AppText.h3(
                              _reference,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: VinkolPalette.neutral900,
                              letterSpacing: 0.6,
                              maxLines: 1,
                            ),
                          ),
                          if (canCopy) ...[
                            Gap.w8,
                            Icon(
                              PhosphorIconsRegular.copy,
                              size: 18.w,
                              color: VinkolPalette.brand600,
                              semanticLabel: 'Copy tracking ID',
                            ),
                          ],
                        ],
                      ),
                    ),
                    Gap.h4,
                    AppText.caption(
                      subtitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: VinkolPalette.neutral500,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    ImageAsset.riderBikeImg,
                    height: 56.h,
                    width: 72.w,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  Gap.h8,
                  OrderStatusPill(status: style),
                ],
              ),
            ],
          ),
          if (status.isOnTrack) ...[
            Gap.h20,
            OrderStageTrack(status: status),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Agent — who has it
// ---------------------------------------------------------------------------

class OrderAgentCard extends ConsumerWidget {
  const OrderAgentCard({
    super.key,
    required this.agent,
    this.label = 'Your rider',
  });

  final AgentModel agent;

  /// Who the agent is to the customer — a rider, or a shopper while the
  /// server says the goods are still being bought.
  final String label;

  void _call(BuildContext context) {
    final raw = agent.phone?.toString().trim();
    if (raw == null || raw.isEmpty) {
      AppStatusDialogs.showError(
          context, 'No Phone Number', 'Phone number not available.');
      return;
    }
    try {
      if (raw.startsWith('+')) {
        makePhoneCall(raw);
        return;
      }
      final validated = validateAndFormatPhoneNumber(raw);
      if (validated != null) {
        makePhoneCall(validated);
      } else {
        AppStatusDialogs.showError(
            context, 'Invalid Format', 'Invalid phone number format.');
      }
    } catch (_) {
      AppStatusDialogs.showError(context, 'Call Failed',
          'Unable to make phone call. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = agent.id;
    final name = agent.fullName.trim();

    return OrderDetailCard(
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: CircularNetworkImage(
                imageUrl: agent.imageUrl ?? '',
                width: 44.w,
                height: 44.w,
              ),
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderDetailLabel(label),
                Gap.h2,
                AppText.body(
                  name.isEmpty ? '—' : name,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VinkolPalette.neutral900,
                  maxLines: 2,
                  lineHeight: 1.25,
                ),
                if (id != null) ...[
                  Gap.h2,
                  ref.watch(riderRatingProvider(id)).when(
                        data: (rating) => _Rating(
                          average: rating.avgRating,
                          count: rating.ratingsCount,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                ],
              ],
            ),
          ),
          Gap.w12,
          Semantics(
            button: true,
            label: 'Call ${label.toLowerCase().replaceFirst('your ', '')}',
            child: Material(
              color: VinkolPalette.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: const BorderSide(color: VinkolPalette.neutral200),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _call(context),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(
                    PhosphorIconsRegular.phone,
                    size: 20.w,
                    color: VinkolPalette.brand600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `★ 4.8 (12)` — the number does the work; the star is the unit.
class _Rating extends StatelessWidget {
  const _Rating({required this.average, required this.count});

  final double average;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIconsFill.star,
            size: 12.w, color: VinkolPalette.warningFill),
        Gap.w4,
        AppText.caption(
          average.toStringAsFixed(1),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: VinkolPalette.neutral700,
        ),
        if (count > 0) ...[
          Gap.w4,
          AppText.caption(
            '($count)',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: VinkolPalette.neutral500,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Route — the Line at sheet scale
// ---------------------------------------------------------------------------

/// One stop on the Line. [ordinal] draws a numbered node for bulk drop-offs;
/// otherwise the origin is hollow and the destination filled. [title] sits
/// above the address when the stop has a name of its own — a store, say.
class OrderStop {
  const OrderStop({
    required this.label,
    required this.address,
    this.title,
    this.isOrigin = false,
    this.ordinal,
    this.contact,
  });

  final String label;
  final String? address;
  final String? title;
  final bool isOrigin;
  final int? ordinal;
  final String? contact;
}

class OrderRouteLine extends StatelessWidget {
  const OrderRouteLine({super.key, required this.stops});

  final List<OrderStop> stops;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stops.length; i++)
          _StopRow(stop: stops[i], isLast: i == stops.length - 1),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.isLast});

  final OrderStop stop;
  final bool isLast;

  static const _node = 12.0;

  @override
  Widget build(BuildContext context) {
    final address = stop.address?.trim() ?? '';
    final hasAddress = address.isNotEmpty;
    final title = stop.title?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final contact = stop.contact?.trim();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20.w,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: _Node(stop: stop),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: VinkolPalette.neutral200,
                    ),
                  ),
              ],
            ),
          ),
          Gap.w10,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderDetailLabel(stop.label),
                  Gap.h4,
                  if (hasTitle) ...[
                    AppText.body(
                      title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VinkolPalette.neutral900,
                      lineHeight: 1.35,
                    ),
                    if (hasAddress) Gap.h2,
                  ],
                  if (hasAddress || !hasTitle)
                    AppText.body(
                      hasAddress ? address : 'Address not available',
                      fontSize: hasTitle ? 13 : 14,
                      fontWeight: !hasAddress || stop.isOrigin || hasTitle
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: hasAddress
                          ? (hasTitle
                              ? VinkolPalette.neutral600
                              : VinkolPalette.neutral900)
                          : VinkolPalette.neutral500,
                      lineHeight: 1.35,
                    ),
                  if (contact != null && contact.isNotEmpty) ...[
                    Gap.h2,
                    AppText.caption(
                      contact,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: VinkolPalette.neutral500,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.stop});

  final OrderStop stop;

  @override
  Widget build(BuildContext context) {
    final ordinal = stop.ordinal;
    if (ordinal != null) {
      return Container(
        width: 18.w,
        height: 18.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: VinkolPalette.brand500,
        ),
        child: AppText.caption(
          '$ordinal',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: VinkolPalette.white,
          lineHeight: 1,
        ),
      );
    }
    return Container(
      width: _StopRow._node,
      height: _StopRow._node,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: stop.isOrigin ? VinkolPalette.white : VinkolPalette.brand500,
        border: Border.all(
          color:
              stop.isOrigin ? VinkolPalette.neutral400 : VinkolPalette.brand500,
          width: 2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary — what it cost, and when
// ---------------------------------------------------------------------------

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.delivery, this.subtotal});

  final DeliveryModel delivery;

  /// The goods themselves, for a store order. When present the bill is always
  /// itemised — the customer paid for two different things and should see
  /// both — so the breakdown is drawn even where a plain delivery would not.
  final Money? subtotal;

  /// e.g. `HST (13%)`. The name is the server's; the percentage is only ever
  /// the rate it sent back, never one derived from the country.
  String get _taxLabel {
    final label = (delivery.taxLabel ?? '').trim();
    final name = label.isEmpty ? 'Tax' : label;
    final rate = delivery.taxRate;
    if (rate == null || rate <= 0) return name;

    final percent = rate * 100;
    var text = percent.toStringAsFixed(3);
    if (text.contains('.')) {
      text = text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return '$name ($text%)';
  }

  String get _placed {
    final date = delivery.date?.trim();
    final time = delivery.time?.trim();
    if (date == null || date.isEmpty) return '—';
    final pretty = prettyOrderDate(date);
    if (time == null || time.isEmpty) return pretty;
    return '$pretty · $time';
  }

  @override
  Widget build(BuildContext context) {
    final items = subtotal;
    final fee = delivery.deliveryFeeMoney;
    final service = delivery.serviceFeeMoney;
    final tax = delivery.taxMoney;
    final note = delivery.note?.trim();

    // A Nigerian delivery is one number; listing the fee and then the same
    // number again as the total says nothing. The breakdown only appears when
    // the server itemised the bill — or when there are goods on it.
    final itemised = items != null || delivery.hasItemisedCharges;

    final rows = <Widget>[
      if (itemised) ...[
        if (items != null) OrderMoneyRow(label: 'Items', money: items),
        if (fee != null) ...[
          if (items != null) Gap.h8,
          OrderMoneyRow(label: 'Delivery fee', money: fee),
        ],
        if (service != null && service.amount > 0) ...[
          Gap.h8,
          OrderMoneyRow(label: 'Service fee', money: service),
        ],
        if (tax != null && tax.amount > 0) ...[
          Gap.h8,
          OrderMoneyRow(label: _taxLabel, money: tax),
        ],
        Gap.h12,
        const OrderHairline(),
        Gap.h12,
      ],
      OrderMoneyRow(label: 'Total', money: delivery.amountDue, isTotal: true),
      Gap.h12,
      const OrderHairline(),
      Gap.h12,
      OrderTextRow(label: 'Placed', value: _placed),
      if (note != null && note.isNotEmpty) ...[
        Gap.h12,
        const OrderDetailLabel('Note'),
        Gap.h4,
        AppText.body(
          note,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: VinkolPalette.neutral900,
          lineHeight: 1.4,
        ),
      ],
    ];

    return OrderDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const OrderDetailLabel('Summary'), Gap.h12, ...rows],
      ),
    );
  }
}

/// Label on the start edge, amount flush on the end edge so the numbers line
/// up down the card. The symbol is set a step lighter so the number stays
/// the hero.
class OrderMoneyRow extends StatelessWidget {
  const OrderMoneyRow({
    super.key,
    required this.label,
    required this.money,
    this.isTotal = false,
  });

  final String label;
  final Money money;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: AppText.body(
            label,
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color:
                isTotal ? VinkolPalette.neutral900 : VinkolPalette.neutral600,
            maxLines: 1,
          ),
        ),
        Gap.w12,
        AppText.body(
          money.currency.symbol,
          fontSize: isTotal ? 14 : 12,
          fontWeight: FontWeight.w500,
          color: VinkolPalette.neutral500,
        ),
        AppText.h3(
          money.format(showSymbol: false),
          fontSize: isTotal ? 18 : 14,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          color: VinkolPalette.neutral900,
        ),
      ],
    );
  }
}

class OrderTextRow extends StatelessWidget {
  const OrderTextRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72.w,
          child: AppText.body(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: VinkolPalette.neutral600,
            maxLines: 1,
          ),
        ),
        Gap.w12,
        Expanded(
          child: AppText.body(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: VinkolPalette.neutral900,
            textAlign: TextAlign.end,
            lineHeight: 1.35,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Delivery code — what the customer needs at handover
// ---------------------------------------------------------------------------

class OrderDeliveryCode extends StatelessWidget {
  const OrderDeliveryCode({super.key, required this.code});

  final int code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: VinkolPalette.brand50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: VinkolPalette.brand100),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.lockKey,
              size: 20.w, color: VinkolPalette.brand600),
          Gap.w10,
          Expanded(
            child: AppText.body(
              'Delivery code',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: VinkolPalette.neutral900,
              maxLines: 1,
            ),
          ),
          Gap.w12,
          AppText.h3(
            '$code',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: VinkolPalette.brand600,
            letterSpacing: 2,
          ),
        ],
      ),
    );
  }
}
