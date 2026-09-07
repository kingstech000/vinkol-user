import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// **Country picker** — the entry point to the market layer.
///
/// Choosing here sets currency and its decimals, whether tax is displayed and what it is
/// called, the administrative-region label, the address field order, the dial code and the
/// support contact. Nothing after this screen knows what country it is in.
///
/// One decision per screen: the country. The administrative region is picked in Personal
/// info, where the rest of the address is entered — until then the market's first region
/// stands in, which is what [MarketScope.region] already falls back to.
///
/// No flag emoji, here or anywhere — inconsistent across platforms and politically loaded.
/// Country names and the two-letter code only.
class MarketSelectScreen extends ConsumerWidget {
  const MarketSelectScreen({super.key, this.fromSettings = false});

  /// Reached from splash on first run and from Settings after that. First run replaces the
  /// stack and moves on to auth; Settings pushes, so the back control has somewhere to go
  /// and Continue simply pops.
  const MarketSelectScreen.fromSettings({super.key}) : fromSettings = true;

  final bool fromSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final market = ref.watch(marketProvider).market;

    return VinkolFormScaffold(
      appBar: MiniAppBar(title: l10n.marketSelectTitle, leading: fromSettings),
      primaryAction: VinkolPrimaryButton(
        label: l10n.marketContinueIn(market.displayName),
        onPressed: () async {
          if (fromSettings) {
            NavigationService.instance.goBack();
          } else {
            // First run ends here, not at auth: the market has to be settled before a
            // user sees a price, and it must not be asked for again on the next launch.
            await locator<LocalCache>().onBoarded();
            NavigationService.instance
                .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
          }
        },
      ),
      fields: <Widget>[
        const SizedBox(height: 2),
        Text(
          l10n.marketSelectBody,
          style: VinkolType.body.copyWith(color: v.textSecondary),
        ),
        const SizedBox(height: VinkolSpace.xxl),
        _CountryField(
          market: market,
          onSelected: (Market m) =>
              ref.read(marketProvider.notifier).setMarket(m),
        ),
      ],
    );
  }
}

/// The country picker: one field, one sheet, country names only.
///
/// The list is [Markets.all] rather than every country on earth. A country with no market
/// entry has no currency, no address shape and no dial code, so picking it would silently
/// fall back to Nigeria — a picker that offers a choice the app cannot honour is worse than
/// a short list. Adding a country is adding it to `Markets`.
class _CountryField extends StatefulWidget {
  const _CountryField({required this.market, required this.onSelected});

  final Market market;
  final ValueChanged<Market> onSelected;

  @override
  State<_CountryField> createState() => _CountryFieldState();
}

class _CountryFieldState extends State<_CountryField> {
  late final TextEditingController _display =
      TextEditingController(text: widget.market.displayName);

  @override
  void didUpdateWidget(_CountryField old) {
    super.didUpdateWidget(old);
    if (widget.market.displayName != _display.text) {
      _display.text = widget.market.displayName;
    }
  }

  @override
  void dispose() {
    _display.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final v = context.vinkol;
    final Market? picked = await showModalBottomSheet<Market>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: v.surface,
          borderRadius: VinkolRadius.brSheet,
          border: BorderDirectional(top: BorderSide(color: v.borderSubtle)),
        ),
        child: _CountrySheet(selected: widget.market),
      ),
    );
    if (picked != null && picked.code != widget.market.code) {
      widget.onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return VinkolFormField(
      label: context.l10n.marketCountry,
      readOnly: true,
      controller: _display,
      onTap: _open,
      trailing: Icon(Icons.expand_more, size: 18, color: v.textTertiary),
    );
  }
}

class _CountrySheet extends StatelessWidget {
  const _CountrySheet({required this.selected});

  final Market selected;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: VinkolSpace.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: v.borderStrong,
              borderRadius: VinkolRadius.brFull,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VinkolSpace.xl,
              VinkolSpace.lg,
              VinkolSpace.xl,
              VinkolSpace.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                context.l10n.marketAvailable,
                style: VinkolType.h3.copyWith(color: v.textPrimary),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                VinkolSpace.xl,
                0,
                VinkolSpace.xl,
                VinkolSpace.xxl,
              ),
              itemCount: Markets.all.length,
              itemBuilder: (BuildContext context, int i) {
                final Market m = Markets.all[i];
                return VinkolRow(
                  title: m.displayName,
                  icon: null,
                  showDivider: i > 0,
                  onTap: () => Navigator.of(context).pop(m),
                  trailing: m.code == selected.code
                      ? Icon(Icons.check, size: 18, color: v.brand)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
