import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market.dart';
import 'package:starter_codes/features/auth/view_model/profile_setting_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

class ProfileSettingScreen extends ConsumerStatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  ConsumerState<ProfileSettingScreen> createState() =>
      _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends ConsumerState<ProfileSettingScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _surname = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  String? _firstNameError;
  String? _surnameError;
  String? _regionError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    final vm = ref.read(profileSettingViewModelProvider);
    _firstName.text = vm.firstName;
    _surname.text = vm.surname;
    _region.text = vm.selectedState.trim();
    _phone.text = vm.phoneNumber;

    _firstName.addListener(() => vm.setFirstName(_firstName.text));
    _surname.addListener(() => vm.setSurname(_surname.text));
    _region.addListener(() => vm.setSelectedState(_region.text));
    _phone.addListener(() => vm.setPhoneNumber(_phone.text));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _surname.dispose();
    _region.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit(ProfileSettingViewModel vm, Market market) {
    final l10n = context.l10n;
    setState(() {
      // The same three checks Personal info makes, and the same wording — it is the same
      // data, and a rule that changes between the screen that collects it and the screen
      // that edits it is a bug the user finds for you.
      _firstNameError =
          _firstName.text.trim().isEmpty ? l10n.profileNameRequired : null;
      _surnameError =
          _surname.text.trim().isEmpty ? l10n.profileNameRequired : null;
      _regionError =
          _region.text.trim().isEmpty ? l10n.profileRegionRequired : null;
      _phoneError = market.phone.isValidNational(_phone.text)
          ? null
          : l10n.profilePhoneRequired(market.phone.nationalDigits);
    });
    if (_firstNameError != null ||
        _surnameError != null ||
        _regionError != null ||
        _phoneError != null) {
      return;
    }
    vm.submitProfile(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final vm = ref.watch(profileSettingViewModelProvider);
    final market = ref.watch(currentMarketProvider);

    return VinkolAuthScaffold(
      title: l10n.authCompleteProfile,
      body: l10n.authCompleteDetailsToCompleteProfile,
      fields: <Widget>[
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VinkolFormField(
                pill: true,
                label: l10n.authFirstName,
                controller: _firstName,
                hint: l10n.authFirstNameHint,
                error: _firstNameError,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.givenName],
                leading:
                    Icon(Icons.person_outline, size: 19, color: v.textTertiary),
                onChanged: (_) {
                  if (_firstNameError != null) {
                    setState(() => _firstNameError = null);
                  }
                },
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolFormField(
                pill: true,
                label: l10n.authLastName,
                controller: _surname,
                hint: l10n.authLastNameHint,
                error: _surnameError,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.familyName],
                leading:
                    Icon(Icons.person_outline, size: 19, color: v.textTertiary),
                onChanged: (_) {
                  if (_surnameError != null) {
                    setState(() => _surnameError = null);
                  }
                },
              ),
              const SizedBox(height: VinkolSpace.lg),
              _RegionField(
                market: market,
                controller: _region,
                error: _regionError,
                onSelected: (String name) => setState(() {
                  _region.text = name;
                  _regionError = null;
                }),
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolFormField(
                pill: true,
                label: l10n.authPhoneNumber,
                controller: _phone,
                hint: market.phone.example,
                helper: l10n.profilePhoneHelper(market.phone.example),
                error: _phoneError,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[
                  AutofillHints.telephoneNumberLocal
                ],
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  // One more than the market allows, so a paste with a trunk zero still
                  // parses instead of being clipped mid-number.
                  LengthLimitingTextInputFormatter(
                      market.phone.nationalDigits + 1),
                ],
                // The dial code reads inside the field rather than in a disabled box beside
                // it: it is not something the user can change, so it should not look like an
                // input they failed to fill.
                leading: Text(
                  market.phone.dialCode,
                  style: VinkolType.num.copyWith(color: v.textTertiary),
                ),
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),
            ],
          ),
        ),
      ],
      primaryAction: VinkolPrimaryButton(
        label: l10n.authSubmit,
        loading: vm.isBusy,
        onPressed: () => _submit(vm, market),
      ),
    );
  }
}

/// The region picker — "State" in Nigeria, "Province" in Canada.
///
/// A read-only field that opens a sheet, the same object the country picker on
/// `MarketSelectScreen` uses, so the two pickers in the app are one pattern.
class _RegionField extends StatelessWidget {
  const _RegionField({
    required this.market,
    required this.controller,
    required this.onSelected,
    this.error,
  });

  final Market market;
  final TextEditingController controller;
  final ValueChanged<String> onSelected;
  final String? error;

  Future<void> _open(BuildContext context) async {
    final v = context.vinkol;
    final String? picked = await showModalBottomSheet<String>(
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
        child: _RegionSheet(market: market, selected: controller.text),
      ),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return VinkolFormField(
      pill: true,
      label: market.regionLabel,
      controller: controller,
      error: error,
      readOnly: true,
      hint: context.l10n.profileSelectRegion(market.regionLabel.toLowerCase()),
      onTap: () => _open(context),
      leading:
          Icon(Icons.location_on_outlined, size: 19, color: v.textTertiary),
      trailing: Icon(Icons.expand_more, size: 19, color: v.textTertiary),
    );
  }
}

class _RegionSheet extends StatelessWidget {
  const _RegionSheet({required this.market, required this.selected});

  final Market market;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final names = market.regionNames;

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
            padding: const EdgeInsetsDirectional.fromSTEB(
              VinkolSpace.xl,
              VinkolSpace.lg,
              VinkolSpace.xl,
              VinkolSpace.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                market.regionLabel,
                style: VinkolType.h3.copyWith(color: v.textPrimary),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsetsDirectional.fromSTEB(
                VinkolSpace.xl,
                0,
                VinkolSpace.xl,
                VinkolSpace.xxl,
              ),
              itemCount: names.length,
              itemBuilder: (BuildContext context, int i) => VinkolRow(
                title: names[i],
                icon: null,
                showDivider: i > 0,
                onTap: () => Navigator.of(context).pop(names[i]),
                trailing: names[i] == selected
                    ? Icon(Icons.check, size: 18, color: v.brand)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
