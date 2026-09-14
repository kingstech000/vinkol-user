import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/dashboard/view/screen/dashboard_screen.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';
import 'package:starter_codes/features/delivery/view/widget/order_detail_widgets.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_detail_view_model.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_view_model.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/content_sized_sheet.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/loading_overlay.dart';
import 'package:starter_codes/widgets/map_control.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/reverse_map.dart';

/// A package delivery on its own screen: the route on a full-bleed map, and a
/// sheet that answers the questions a customer opens it for, in order — where
/// is it, who has it, where is it going, what did it cost, and what they need
/// at handover. Everything on it is a field the API returns (decision D-10).
class BookingOrderScreen extends ConsumerStatefulWidget {
  const BookingOrderScreen({super.key});

  @override
  ConsumerState<BookingOrderScreen> createState() => _BookingOrderScreenState();
}

class _BookingOrderScreenState extends ConsumerState<BookingOrderScreen> {
  /// Past this extent the sheet is under the map controls, so they step aside.
  static const _controlsHideAt = 0.82;

  bool _controlsHidden = false;

  void _onSheetExtent(double extent) {
    final hidden = extent >= _controlsHideAt;
    if (hidden != _controlsHidden) setState(() => _controlsHidden = hidden);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDelivery = ref.read(selectedDeliveryProvider);
      if (selectedDelivery != null && selectedDelivery.id != null) {
        ref
            .read(deliveryDetailsViewModelProvider.notifier)
            .fetchDeliveryById(selectedDelivery.id!);
      } else {
        debugPrint('Error: No delivery selected or ID is null.');
      }
    });
  }

  void _goBack() {
    if (ref.read(comingFromBookingsScreenProvider)) {
      ref.read(comingFromBookingsScreenProvider.notifier).state = false;
      NavigationService.instance
          .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
    } else {
      NavigationService.instance.goBack();
    }
  }

  void _openGoogleMapsDirections() {
    final delivery = ref.read(deliveryDetailsViewModelProvider).value;
    if (delivery == null) return;
    openGoogleMapsDirections(delivery.pickupLocation, delivery.dropoffLocation);
  }

  Future<void> _cancelOrder(DeliveryModel delivery) async {
    AppStatusDialogs.showConfirmation(
      context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order? '
          '${delivery.country.refundDestination}',
      confirmText: 'Confirm',
      cancelText: 'No, Keep',
      onConfirm: () async {
        ref.read(isCancellingProvider.notifier).state = true;
        final success = await ref
            .read(deliveryDetailsViewModelProvider.notifier)
            .cancelOrder(delivery.id!);
        ref.read(isCancellingProvider.notifier).state = false;

        if (!context.mounted) return;
        if (success) {
          AppStatusDialogs.showSuccess(
            context,
            'Order Cancelled',
            'Your order has been cancelled successfully.',
            onClosed: () {
              ref.read(deliveryViewModelProvider).fetchPackageDeliveries();
              ref.read(navigationIndexProvider.notifier).state = 2;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (_) => false,
              );
            },
          );
        } else {
          AppStatusDialogs.showError(context, 'Cancellation Failed',
              'Failed to cancel order. Please try again.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDetailsAsync = ref.watch(deliveryDetailsViewModelProvider);
    final isFromBookingScreen = ref.watch(comingFromBookingsScreenProvider);

    return PopScope(
      canPop: !isFromBookingScreen,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 76.w,
          leading: Padding(
            padding: EdgeInsetsDirectional.only(start: 20.w),
            child: Center(
              child: MapControl(
                icon: PhosphorIconsRegular.caretLeft,
                semanticLabel: 'Back',
                hidden: _controlsHidden,
                onTap: _goBack,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 20.w),
              child: Center(
                child: MapControl(
                  icon: PhosphorIconsRegular.navigationArrow,
                  semanticLabel: 'Open directions',
                  hidden: _controlsHidden,
                  onTap: _openGoogleMapsDirections,
                ),
              ),
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: ref.watch(isCancellingProvider),
          child: Stack(
            children: [
              Positioned.fill(
                child: deliveryDetailsAsync.when(
                  data: (delivery) {
                    if (delivery == null) return const OrderMapPlaceholder();
                    final isBulk = delivery.isBulkOrder == true;
                    final pickupLat = delivery.pickup?.location?.lat;
                    final pickupLng = delivery.pickup?.location?.lng;
                    final dropoffLat = delivery.dropoffs?.isNotEmpty == true
                        ? delivery.dropoffs!.first.location?.lat
                        : null;
                    final dropoffLng = delivery.dropoffs?.isNotEmpty == true
                        ? delivery.dropoffs!.first.location?.lng
                        : null;

                    return ReverseLocationStringMap(
                      pickupLocationString: delivery.pickupLocation,
                      dropoffLocationString: delivery.dropoffLocation,
                      pickupLatLng:
                          (isBulk && pickupLat != null && pickupLng != null)
                              ? LatLng(pickupLat, pickupLng)
                              : null,
                      dropoffLatLng:
                          (isBulk && dropoffLat != null && dropoffLng != null)
                              ? LatLng(dropoffLat, dropoffLng)
                              : null,
                    );
                  },
                  loading: () => const OrderMapPlaceholder(),
                  error: (err, stack) => const OrderMapPlaceholder(),
                ),
              ),
              ContentSizedSheet(
                color: AppColors.background,
                onExtentChanged: _onSheetExtent,
                child: deliveryDetailsAsync.when(
                  data: (delivery) => delivery == null
                      ? const OrderSheetMessage(
                          icon: PhosphorIconsRegular.tray,
                          message: 'No delivery details found',
                        )
                      : _SheetBody(
                          delivery: delivery,
                          onCancel: () => _cancelOrder(delivery),
                        ),
                  loading: () => SizedBox(
                    height: 160.h,
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  error: (err, stack) => const OrderSheetMessage(
                    icon: PhosphorIconsRegular.warningCircle,
                    message: 'Unable to load delivery details',
                    isError: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet body
// ---------------------------------------------------------------------------

class _SheetBody extends ConsumerWidget {
  const _SheetBody({
    required this.delivery,
    required this.onCancel,
  });

  final DeliveryModel delivery;
  final VoidCallback onCancel;

  /// A customer can only walk away from an order nobody has picked up yet.
  bool get _canCancel {
    final status = OrderStatus.parse(delivery.status);
    final type = delivery.deliveryType?.toLowerCase();
    return status.kind == OrderStatusKind.pending &&
        delivery.deliveryAgent == null &&
        (type == 'regular' || type == 'express');
  }

  /// `Package delivery · Regular · Bike` — only the parts the order carries.
  String get _subtitle {
    final parts = <String>['Package delivery'];
    for (final raw in [delivery.deliveryType, delivery.vehicleRequest]) {
      final value = raw?.trim();
      if (value != null && value.isNotEmpty) parts.add(orderTitleCase(value));
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = OrderStatus.parse(delivery.status);
    final agent = delivery.deliveryAgent;
    final showAgent = agent != null && status.kind != OrderStatusKind.delivered;
    final isBulk = delivery.isBulkOrder == true &&
        delivery.route != null &&
        delivery.route!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        4.h,
        20.w,
        20.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderHeaderCard(
            delivery: delivery,
            status: status,
            subtitle: _subtitle,
          ),
          Gap.h12,
          if (showAgent) ...[
            OrderAgentCard(agent: agent),
            Gap.h12,
          ],
          OrderDetailCard(
            child: isBulk
                ? _BulkRoute(delivery: delivery)
                : OrderRouteLine(stops: [
                    OrderStop(
                      label: 'Pick-up',
                      address: delivery.pickupLocation,
                      isOrigin: true,
                    ),
                    OrderStop(
                      label: 'Drop-off',
                      address: delivery.dropoffLocation,
                    ),
                  ]),
          ),
          Gap.h12,
          OrderSummaryCard(delivery: delivery),
          if (delivery.orderOtp != null &&
              status.isOnTrack &&
              status.kind != OrderStatusKind.delivered) ...[
            Gap.h12,
            OrderDeliveryCode(code: delivery.orderOtp!),
          ],
          if (_canCancel) ...[
            Gap.h20,
            AppButton.outline(
              title: 'Cancel Order',
              textColor: VinkolPalette.dangerText,
              outlineColor: VinkolPalette.dangerText,
              onTap: onCancel,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bulk route — one pick-up, numbered drop-offs
// ---------------------------------------------------------------------------

class _BulkRoute extends StatelessWidget {
  const _BulkRoute({required this.delivery});

  final DeliveryModel delivery;

  @override
  Widget build(BuildContext context) {
    final dropoffs = delivery.dropoffs ?? const <BulkContact>[];
    final stops = <OrderStop>[
      OrderStop(
        label: 'Pick-up',
        address: delivery.pickup?.location?.address,
        isOrigin: true,
      ),
      for (var i = 0; i < dropoffs.length; i++)
        OrderStop(
          label: 'Drop-off ${i + 1}',
          address: dropoffs[i].location?.address,
          ordinal: i + 1,
          contact: [
            dropoffs[i].name?.trim(),
            dropoffs[i].contact?.trim(),
          ].where((s) => s != null && s.isNotEmpty).join(' · '),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: OrderDetailLabel('Route')),
            AppText.caption(
              dropoffs.length == 1
                  ? '1 drop-off'
                  : '${dropoffs.length} drop-offs',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: VinkolPalette.neutral500,
            ),
          ],
        ),
        Gap.h12,
        OrderRouteLine(stops: stops),
      ],
    );
  }
}
