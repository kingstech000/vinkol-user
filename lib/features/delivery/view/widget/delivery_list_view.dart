import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/l10n/status_labels.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// One tab of the records list.
///
/// Density is the feature here: a logistics list has to show six to eight orders on a
/// standard phone, so the settled orders are rows on a shared axis rather than a stack of
/// cards. The one exception is the live order, which is promoted out of the list into the
/// saturated hero — there is at most one of those, which is what keeps the rule "one
/// saturated object per screen" true.
class DeliveryListView extends ConsumerWidget {
  const DeliveryListView({
    super.key,
    required this.deliveries,
    required this.isStoreOrders,
    required this.onRefresh,
  });

  final List<DeliveryModel> deliveries;
  final bool isStoreOrders;
  final Future<void> Function() onRefresh;

  void _open(WidgetRef ref, DeliveryModel delivery) {
    ref.read(selectedDeliveryProvider.notifier).state = delivery;
    NavigationService.instance.navigateTo(
      isStoreOrders
          ? NavigatorRoutes.storeOrderScreen
          : NavigatorRoutes.bookingOrderScreen,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // At most one order is live at a time in practice; if the backend ever returns two, only
    // the first is promoted so the screen never grows a second saturated object.
    final DeliveryModel? live = deliveries
        .where((DeliveryModel d) => isLiveStatus(vinkolStatusFrom(d.status)))
        .firstOrNull;
    final List<DeliveryModel> rest =
        deliveries.where((DeliveryModel d) => d != live).toList();

    return RefreshIndicator(
      color: context.vinkol.brand,
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.sm,
          VinkolSpace.pageMargin,
          VinkolPod.bodyInsetOf(context),
        ),
        children: <Widget>[
          if (live != null)
            _LiveOrderHero(
              delivery: live,
              isStoreOrder: isStoreOrders,
              onTap: () => _open(ref, live),
            ),
          if (rest.isNotEmpty)
            VinkolSectionHeader(
              label:
                  live == null ? l10n.deliveryAllOrders : l10n.deliveryEarlier,
              meta: '${rest.length}',
            ),
          for (final DeliveryModel delivery in rest)
            Padding(
              padding: const EdgeInsets.only(bottom: VinkolSpace.sm),
              child: _RecordRow(
                delivery: delivery,
                isStoreOrder: isStoreOrders,
                onTap: () => _open(ref, delivery),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveOrderHero extends StatelessWidget {
  const _LiveOrderHero({
    required this.delivery,
    required this.isStoreOrder,
    required this.onTap,
  });

  final DeliveryModel delivery;
  final bool isStoreOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final VinkolStatus? status = vinkolStatusFrom(delivery.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: VinkolSpace.sm),
      child: VinkolHeroCard(
        eyebrow: status?.labelIn(context) ?? l10n.deliveryInProgress,
        live: true,
        reference: delivery.trackingId,
        badge: isStoreOrder && delivery.products != null
            ? l10n.deliveryItemCount(delivery.products!.length)
            : l10n.deliveryTrackingId,
        origin: VinkolHeroStop(
          label: isStoreOrder ? l10n.deliveryFromStore : l10n.deliveryFrom,
          place: (isStoreOrder ? delivery.store?.name : null) ??
              delivery.pickupLocation ??
              '—',
        ),
        destination: VinkolHeroStop(
          label: l10n.deliveryTo,
          place: delivery.dropoffLocation ?? '—',
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.delivery,
    required this.isStoreOrder,
    required this.onTap,
  });

  final DeliveryModel delivery;
  final bool isStoreOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final VinkolStatus? status = vinkolStatusFrom(delivery.status);

    return VinkolRecordCard(
      reference: delivery.trackingId ?? delivery.id ?? '—',
      referenceLabel:
          isStoreOrder ? l10n.deliveryOrder : l10n.deliveryTrackingId,
      status: status == null
          ? const SizedBox.shrink()
          : VinkolStatusChip(status, dense: true),
      value: delivery.totalAmount == null
          ? null
          : MarketFormat.money(delivery.totalAmount!),
      origin: (isStoreOrder ? delivery.store?.name : null) ??
          delivery.pickupLocation,
      destination: delivery.dropoffLocation,
      onTap: onTap,
    );
  }
}
