import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/view/widget/shop_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// One line in the cart: what it is, what one costs, and how many.
///
/// The unit price stays visible next to the quantity because that is the sum the user is
/// checking — a line total alone makes them divide to find out whether the price is right.
class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  final StoreProduct item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      margin: const EdgeInsets.only(bottom: VinkolSpace.sm),
      padding: const EdgeInsets.all(VinkolSpace.md),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Row(
        children: <Widget>[
          ShopImageBlock(
            imageUrl: item.image.imageUrl,
            width: 52,
            height: 52,
          ),
          const SizedBox(width: VinkolSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: VinkolType.h4.copyWith(color: v.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: VinkolSpace.xxs),
                Text(
                  context.l10n.storeEachPrice(MarketFormat.money(item.price)),
                  style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: VinkolSpace.sm),
          QuantityStepper(
            quantity: item.quantity ?? 1,
            onDecrement: onDecrement,
            onIncrement: onIncrement,
          ),
        ],
      ),
    );
  }
}

/// The quoted delivery options, and every state of getting them.
///
/// The fee is quoted rather than calculated, so this list has four genuinely different states
/// and each says something a user can act on: no address yet, still asking, the server had
/// nothing, and the options themselves.
class DeliveryOptionList extends ConsumerWidget {
  const DeliveryOptionList({
    super.key,
    required this.quotes,
    required this.selected,
    required this.hasAddress,
    required this.onSelected,
    required this.onAddAddress,
  });

  final AsyncValue<List<QuoteResponseModel>> quotes;
  final QuoteResponseModel? selected;
  final bool hasAddress;
  final ValueChanged<QuoteResponseModel> onSelected;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;

    if (!hasAddress) {
      return _Placeholder(
        icon: Icons.location_off_outlined,
        message: l10n.storeAddAnAddressToSeeOptions,
      );
    }

    return quotes.when(
      loading: () => const VinkolSkeletonList(count: 2),
      error: (Object error, StackTrace stack) => _Placeholder(
        icon: Icons.error_outline,
        message: l10n.storeCouldNotGetDeliveryOptions,
        action: (label: l10n.commonTryAgain, onTap: onAddAddress),
      ),
      data: (List<QuoteResponseModel> options) {
        if (options.isEmpty) {
          return _Placeholder(
            icon: Icons.no_transfer_outlined,
            message: l10n.storeNoDeliveryOptionsAvailable,
          );
        }

        return VinkolRowGroup(
          children: <VinkolRow>[
            for (final QuoteResponseModel option in options)
              VinkolRow(
                // The courier is what the user is choosing between; the tier name the API
                // returns ("express", "priority") describes our routing, not their delivery.
                title: option.id == null
                    ? l10n.storeVinkolRider
                    : l10n.storePartnerCourier,
                meta: option.isAvailable
                    ? (option.id == null
                        ? l10n.storeCarriedByVinkol
                        : l10n.storeCarriedByPartner)
                    : option.unavailableMessage ?? l10n.storeUnavailable,
                value: option.isAvailable
                    ? MarketFormat.money(option.price)
                    : null,
                icon: option.id == null
                    ? Icons.pedal_bike_outlined
                    : Icons.storefront_outlined,
                accentIcon: option == selected,
                enabled: option.isAvailable,
                trailing: option == selected
                    ? Icon(Icons.check, size: 19, color: v.brand)
                    : null,
                onTap: () => onSelected(option),
              ),
          ],
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final ({String label, VoidCallback onTap})? action;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: v.textTertiary),
          const SizedBox(width: VinkolSpace.md),
          Expanded(
            child: Text(
              message,
              style: VinkolType.bodyS.copyWith(color: v.textSecondary),
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(width: VinkolSpace.sm),
            GestureDetector(
              onTap: action!.onTap,
              behavior: HitTestBehavior.opaque,
              child: Semantics(
                button: true,
                child: Text(
                  action!.label,
                  style: VinkolType.label.copyWith(color: v.textBrand),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
