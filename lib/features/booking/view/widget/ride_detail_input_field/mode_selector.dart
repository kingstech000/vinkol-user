// Picks between the single, batch and multi-drop ways of ordering.
part of '../ride_detail_input_field.dart';

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.state, required this.notifier});

  final RideLocationState state;
  final RideLocationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: OrderType.values.map((type) {
          final isSelected = state.orderType == type;
          return Expanded(
            child: GestureDetector(
              // The two multi-stop products get their own editor: the stop list, its order
              // and the per-stop recipients do not fit in the home card, and the API's own
              // names for them ("bulk", "multi") describe the payload rather than the job.
              onTap: () {
                switch (type) {
                  case OrderType.standard:
                    notifier.setOrderType(type);
                  case OrderType.bulk:
                    NavigationService.instance
                        .navigateTo(NavigatorRoutes.multidropStopsScreen);
                  case OrderType.multi:
                    NavigationService.instance
                        .navigateTo(NavigatorRoutes.batchStopsScreen);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  _orderTypeLabel(context, type).toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? _textOnAccent : _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
