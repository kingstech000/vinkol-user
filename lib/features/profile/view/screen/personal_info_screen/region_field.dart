// Picking the state or province, and the searchable sheet that lists them.
part of '../personal_info_screen.dart';

/// The administrative region, named and populated by the market.
///
/// A sheet with a search rather than a dropdown: 37 Nigerian states and 13 Canadian
/// provinces are both too many to scroll blind, and the same control has to serve each.
class _RegionField extends StatefulWidget {
  const _RegionField({
    required this.market,
    required this.selected,
    required this.onSelected,
    this.error,
  });

  final Market market;
  final String selected;
  final ValueChanged<String> onSelected;
  final String? error;

  @override
  State<_RegionField> createState() => _RegionFieldState();
}

class _RegionFieldState extends State<_RegionField> {
  late final TextEditingController _display =
      TextEditingController(text: widget.selected);

  @override
  void didUpdateWidget(_RegionField old) {
    super.didUpdateWidget(old);
    if (widget.selected != _display.text) _display.text = widget.selected;
  }

  @override
  void dispose() {
    _display.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final v = context.vinkol;
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: v.surface,
            borderRadius: VinkolRadius.brSheet,
            border: BorderDirectional(top: BorderSide(color: v.borderSubtle)),
          ),
          child: _RegionSheet(
            market: widget.market,
            selected: widget.selected,
          ),
        ),
      ),
    );
    if (picked != null) widget.onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return VinkolFormField(
      label: widget.market.regionLabel,
      readOnly: true,
      hint: context.l10n.profileSelectRegion(widget.market.regionLabel),
      controller: _display,
      onTap: _open,
      helper: context.l10n.profileRegionHelper,
      error: widget.error,
      trailing: Icon(Icons.expand_more, size: 18, color: v.textTertiary),
    );
  }
}

class _RegionSheet extends StatefulWidget {
  const _RegionSheet({required this.market, required this.selected});

  final Market market;
  final String selected;

  @override
  State<_RegionSheet> createState() => _RegionSheetState();
}

class _RegionSheetState extends State<_RegionSheet> {
  final TextEditingController _search = TextEditingController();
  late List<Region> _shown = widget.market.regions;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      final String q = _search.text.trim().toLowerCase();
      setState(() {
        _shown = q.isEmpty
            ? widget.market.regions
            : widget.market.regions
                .where((Region r) => r.name.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
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
              VinkolSpace.md,
            ),
            child: VinkolFormField(
              label: l10n.profileSelectRegion(widget.market.regionLabel),
              controller: _search,
              leading: Icon(Icons.search, size: 18, color: v.textTertiary),
            ),
          ),
          Expanded(
            child: _shown.isEmpty
                ? VinkolStateView.empty(
                    icon: Icons.search_off_outlined,
                    title: l10n.profileSelectRegion(widget.market.regionLabel),
                    message: l10n.profileRegionRequired,
                    action: VinkolStateAction(
                      label: l10n.commonCancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      VinkolSpace.xl,
                      0,
                      VinkolSpace.xl,
                      VinkolSpace.xxl,
                    ),
                    itemCount: _shown.length,
                    itemBuilder: (BuildContext context, int i) {
                      final Region region = _shown[i];
                      final bool isSelected = region.name == widget.selected;
                      return VinkolRow(
                        title: region.name,
                        showDivider: i > 0,
                        onTap: () => Navigator.of(context).pop(region.name),
                        trailing: isSelected
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
