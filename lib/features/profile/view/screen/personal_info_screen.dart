import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/profile/view/widget/profile_widgets.dart';
import 'package:starter_codes/features/profile/view_model/personal_info_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

part 'personal_info_screen/region_field.dart';

/// **Personal info** — the four things the API will actually accept.
///
/// `users/update-profile` takes a first name, a last name, a phone number, a region and an
/// avatar. Nothing else on this screen, because nothing else would be saved.
///
/// Three of those fields are market-shaped and used to be Nigerian constants:
///
/// - the **dial code** and the digit count come from `market.phone`, so a Canadian number
///   is not rejected for failing a 10-digit `+234` rule;
/// - the **region label** is the market's word — *State* in Nigeria, *Province* in Canada —
///   and the options are that market's regions, not `nigerianStates`;
/// - the email is **read-only**, because it is the sign-in identifier and the endpoint does
///   not change it. It used to render as an editable field that silently discarded input.

/// **Personal info** — the four things the API will actually accept.
///
/// `users/update-profile` takes a first name, a last name, a phone number, a region and an
/// avatar. Nothing else on this screen, because nothing else would be saved.
///
/// Three of those fields are market-shaped and used to be Nigerian constants:
///
/// - the **dial code** and the digit count come from `market.phone`, so a Canadian number
///   is not rejected for failing a 10-digit `+234` rule;
/// - the **region label** is the market's word — *State* in Nigeria, *Province* in Canada —
///   and the options are that market's regions, not `nigerianStates`;
/// - the email is **read-only**, because it is the sign-in identifier and the endpoint does
///   not change it. It used to render as an editable field that silently discarded input.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;

  /// Set once the user has tried to save. Errors before that would scold someone for not
  /// having filled in a form they have only just opened.
  bool _validated = false;

  @override
  void initState() {
    super.initState();
    final PersonalInfoState initial = ref.read(personalInfoViewModelProvider);
    final PhoneConfig phone = MarketScope.market.phone;

    _firstName = TextEditingController(text: initial.firstname)
      ..addListener(() => ref
          .read(personalInfoViewModelProvider.notifier)
          .updateFirstName(_firstName.text));
    _lastName = TextEditingController(text: initial.lastname)
      ..addListener(() => ref
          .read(personalInfoViewModelProvider.notifier)
          .updateLastName(_lastName.text));
    // Shown as national digits; the dial code is chrome on the field, not something the
    // user has to type or delete.
    _phone =
        TextEditingController(text: phone.nationalNumber(initial.phoneNumber))
          ..addListener(() => ref
              .read(personalInfoViewModelProvider.notifier)
              .updatePhoneNumber(_phone.text));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _pickPhoto() {
    final l10n = context.l10n;
    final v = context.vinkol;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(
          VinkolSpace.xl,
          VinkolSpace.md,
          VinkolSpace.xl,
          VinkolSpace.xl,
        ),
        decoration: BoxDecoration(
          color: v.surface,
          borderRadius: VinkolRadius.brSheet,
          border: BorderDirectional(top: BorderSide(color: v.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: v.borderStrong,
                    borderRadius: VinkolRadius.brFull,
                  ),
                ),
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolRowGroup(
                children: <VinkolRow>[
                  VinkolRow(
                    icon: Icons.photo_camera_outlined,
                    title: l10n.profileTakePhoto,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      ref
                          .read(personalInfoViewModelProvider.notifier)
                          .pickImage(ImageSource.camera);
                    },
                  ),
                  VinkolRow(
                    icon: Icons.photo_library_outlined,
                    title: l10n.profileChooseFromGallery,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      ref
                          .read(personalInfoViewModelProvider.notifier)
                          .pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _validated = true);
    FocusScope.of(context).unfocus();

    final PersonalInfoState current = ref.read(personalInfoViewModelProvider);
    final Market market = ref.read(currentMarketProvider);
    if (_nameError(current) != null ||
        _phoneError(current, market) != null ||
        _regionError(current) != null) {
      return;
    }

    final bool saved =
        await ref.read(personalInfoViewModelProvider.notifier).updateProfile();

    if (saved && mounted) {
      AppStatusDialogs.showSuccess(
        context,
        context.l10n.profileSaved,
        context.l10n.profilePersonalInfoMeta,
        onClosed: () => NavigationService.instance.goBack(),
      );
    }
  }

  String? _nameError(PersonalInfoState s) =>
      (s.firstname.trim().isEmpty || s.lastname.trim().isEmpty)
          ? context.l10n.profileNameRequired
          : null;

  String? _phoneError(PersonalInfoState s, Market market) =>
      market.phone.isValidNational(s.phoneNumber)
          ? null
          : context.l10n.profilePhoneRequired(market.phone.nationalDigits);

  String? _regionError(PersonalInfoState s) =>
      s.address.trim().isEmpty ? context.l10n.profileRegionRequired : null;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final PersonalInfoState personal = ref.watch(personalInfoViewModelProvider);
    final Market market = ref.watch(currentMarketProvider);
    final user = ref.watch(userProvider);

    ref.listen<PersonalInfoState>(personalInfoViewModelProvider,
        (PersonalInfoState? previous, PersonalInfoState next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppStatusDialogs.showError(
            context, l10n.profileSaveFailed, next.errorMessage!);
      }
    });

    return VinkolFormScaffold(
      appBar: MiniAppBar(title: l10n.profilePersonalInfo),
      primaryAction: VinkolPrimaryButton(
        label: l10n.profileSave,
        loading: personal.isLoading,
        onPressed: personal.isLoading ? null : _save,
      ),
      fields: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              ProfileAvatar(
                size: 78,
                initials: profileInitials(
                  first: personal.firstname,
                  last: personal.lastname,
                  email: personal.email,
                ),
                imageUrl: user?.avatar?.imageUrl,
                file: personal.profileImage == null
                    ? null
                    : FileImage(personal.profileImage!),
              ),
              const SizedBox(height: VinkolSpace.md),
              Semantics(
                button: true,
                child: GestureDetector(
                  onTap: _pickPhoto,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VinkolSpace.md,
                      vertical: VinkolSpace.sm,
                    ),
                    child: Text(
                      l10n.profileChangePhoto,
                      style: VinkolType.label.copyWith(color: v.textBrand),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: VinkolSpace.lg),
        VinkolFormField(
          label: l10n.authFirstName,
          controller: _firstName,
          hint: l10n.authFirstNameHint,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.givenName],
          error: _validated ? _nameError(personal) : null,
        ),
        const SizedBox(height: VinkolSpace.lg),
        VinkolFormField(
          label: l10n.authLastName,
          controller: _lastName,
          hint: l10n.authLastNameHint,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.familyName],
        ),
        const SizedBox(height: VinkolSpace.lg),
        VinkolFormField(
          label: l10n.authEmailAddress,
          // Read-only rather than absent: it is the account's identity and people look for
          // it here. It just cannot be edited, and the helper says why.
          readOnly: true,
          enabled: false,
          hint: personal.email,
          helper: l10n.profileEmailHelper,
        ),
        const SizedBox(height: VinkolSpace.lg),
        VinkolFormField(
          label: l10n.authPhoneNumber,
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            // One more than the market allows, so a paste with a trunk zero still parses
            // instead of being clipped mid-number.
            LengthLimitingTextInputFormatter(market.phone.nationalDigits + 1),
          ],
          // The dial code is the market's, and it is chrome — it is never part of what the
          // user types, so it can never be half-deleted.
          leading: Text(
            market.phone.dialCode,
            style: VinkolType.num.copyWith(color: v.textTertiary),
          ),
          helper: l10n.profilePhoneHelper(market.phone.example),
          error: _validated ? _phoneError(personal, market) : null,
        ),
        const SizedBox(height: VinkolSpace.lg),
        _RegionField(
          market: market,
          selected: personal.address,
          error: _validated ? _regionError(personal) : null,
          onSelected: (String name) => ref
              .read(personalInfoViewModelProvider.notifier)
              .updateAddress(name),
        ),
      ],
    );
  }
}

/// The administrative region, named and populated by the market.
///
/// A sheet with a search rather than a dropdown: 37 Nigerian states and 13 Canadian
/// provinces are both too many to scroll blind, and the same control has to serve each.
