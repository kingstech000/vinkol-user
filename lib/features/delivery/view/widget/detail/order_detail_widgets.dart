import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/utils/copy_to_clipboard_util.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/l10n/status_labels.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';
import 'package:url_launcher/url_launcher.dart';

/// The tracking id, and the one useful thing you can do with it.
///
/// Real, and copyable, because people paste it into a support chat and read it aloud on the
/// phone. Live rider tracking is *not* real — there is no location endpoint — so nothing on
/// this screen offers a map that pretends to follow anyone.
class TrackingIdRow extends StatelessWidget {
  const TrackingIdRow({super.key, required this.trackingId});

  final String trackingId;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.deliveryTrackingId,
                    style: VinkolType.labelS.copyWith(color: v.textTertiary)),
                const SizedBox(height: VinkolSpace.xs),
                Text(
                  trackingId,
                  // Mono: this is a string people transcribe, so 0/O and 1/l must differ.
                  style: VinkolType.mono.copyWith(color: v.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: VinkolSpace.md),
          Semantics(
            button: true,
            label: l10n.deliveryCopyTrackingId,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => copyToClipboard(context, trackingId),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.copy_outlined, size: 19, color: v.textBrand),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Whoever is carrying the order.
///
/// Name, vehicle, rating and a call button — and nothing else, because a phone number is the
/// only contact channel the API exposes. There is no chat endpoint, so there is no chat
/// button pretending there might be.
class OrderCarrierCard extends ConsumerWidget {
  const OrderCarrierCard({super.key, required this.agent});

  final AgentModel agent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final String name =
        '${agent.firstname ?? ''} ${agent.lastname ?? ''}'.trim();
    final String? phone = agent.phone;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: v.brandSubtle,
              borderRadius: VinkolRadius.brFull,
            ),
            child: Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: VinkolType.h4.copyWith(color: v.textBrand),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name.isEmpty ? l10n.deliveryYourRider : name,
                  style: VinkolType.h4.copyWith(color: v.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: VinkolSpace.xxs),
                if (agent.id != null)
                  ref.watch(riderRatingProvider(agent.id!)).maybeWhen(
                        data: (rating) => Text(
                          l10n.deliveryRatingSummary(
                            rating.avgRating.toStringAsFixed(1),
                            rating.ratingsCount,
                          ),
                          style:
                              VinkolType.bodyS.copyWith(color: v.textSecondary),
                        ),
                        orElse: () => Text(
                          phone ?? '',
                          style:
                              VinkolType.bodyS.copyWith(color: v.textSecondary),
                        ),
                      )
                else
                  Text(
                    phone ?? '',
                    style: VinkolType.bodyS.copyWith(color: v.textSecondary),
                  ),
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty) ...<Widget>[
            const SizedBox(width: VinkolSpace.sm),
            Semantics(
              button: true,
              label: l10n.deliveryCallRider,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => launchUrl(
                  Uri.parse('tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}'),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: v.brand,
                    borderRadius: VinkolRadius.brFull,
                  ),
                  child: Icon(Icons.call, size: 19, color: v.onBrand),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The order's status history.
///
/// **Derived, not fetched.** The API returns one current status and a creation timestamp; it
/// has no events array. So this shows exactly what those two facts support — the order was
/// created, it reached the status it is in, and delivery either happened or has not yet — and
/// invents no timestamps for steps it cannot date.
class OrderStatusHistory extends StatelessWidget {
  const OrderStatusHistory({
    super.key,
    required this.status,
    required this.carrierStatus,
    required this.createdLabel,
    required this.currentMeta,
  });

  final VinkolStatus? status;

  /// The middle step this order type passes through — a rider for a courier booking, a
  /// shopper for a store order. Derived from the order type rather than from [status],
  /// because a store order that is still pending has not reached its shopper yet and must
  /// not be told it is waiting on a rider.
  final VinkolStatus carrierStatus;

  /// When the order was placed, already formatted.
  final String createdLabel;

  /// Who has it now — the rider's name, or the store's.
  final String currentMeta;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final bool delivered = status == VinkolStatus.delivered;
    final bool stopped =
        status == VinkolStatus.cancelled || status == VinkolStatus.unattended;
    final bool carried = status == VinkolStatus.withRider ||
        status == VinkolStatus.withShopper ||
        delivered;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Column(
        children: <Widget>[
          VinkolEventRow(
            title: VinkolStatus.pending.labelIn(context),
            meta: l10n.deliveryOrderCreated,
            date: createdLabel,
            done: true,
            showDivider: false,
          ),
          if (stopped)
            VinkolEventRow(
              title: status!.labelIn(context),
              meta: currentMeta,
              done: true,
            )
          else ...<Widget>[
            VinkolEventRow(
              title: carrierStatus.labelIn(context),
              meta: carried ? currentMeta : l10n.deliveryNotYet,
              done: carried,
            ),
            VinkolEventRow(
              title: VinkolStatus.delivered.labelIn(context),
              meta: delivered ? currentMeta : l10n.deliveryNotYet,
              done: delivered,
            ),
          ],
        ],
      ),
    );
  }
}

/// The two quiet actions every finished order offers, and the one destructive one it
/// sometimes does.
class OrderDetailActions extends StatelessWidget {
  const OrderDetailActions({
    super.key,
    required this.onDirections,
    required this.onGetHelp,
    this.onCancel,
    this.cancelling = false,
  });

  final VoidCallback onDirections;
  final VoidCallback onGetHelp;

  /// Null hides the cancel action entirely.
  final VoidCallback? onCancel;
  final bool cancelling;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: VinkolPrimaryButton(
                label: l10n.deliveryDirections,
                tone: VinkolButtonTone.quiet,
                icon: Icons.directions_outlined,
                onPressed: onDirections,
              ),
            ),
            const SizedBox(width: VinkolSpace.md),
            Expanded(
              child: VinkolPrimaryButton(
                label: l10n.deliveryGetHelp,
                tone: VinkolButtonTone.quiet,
                onPressed: onGetHelp,
              ),
            ),
          ],
        ),
        if (onCancel != null) ...<Widget>[
          const SizedBox(height: VinkolSpace.md),
          VinkolPrimaryButton(
            label: l10n.deliveryCancelOrder,
            tone: VinkolButtonTone.plain,
            loading: cancelling,
            onPressed: onCancel,
          ),
        ],
      ],
    );
  }
}
