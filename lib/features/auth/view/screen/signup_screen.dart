import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/validators.dart';
import 'package:starter_codes/features/auth/view_model/signup_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Create an account.
///
/// **Two fields, not four.** The prototype shows full name and phone number here, but
/// `users/register` accepts only an email and a password — name, phone and region are
/// collected on the profile screen afterwards, against `users/update-profile`. Adding fields
/// the endpoint discards would be inventing a feature (D-10), and a user who typed them
/// would reasonably expect them saved.
///
/// **No Google or Apple button.** The reference design shows both under an "or" divider.
/// There is no social-auth package in the app and no endpoint that accepts a provider token,
/// so a button here would be a control that cannot work. When the backend gains
/// `users/oauth`, they belong under [primaryAction] with a divider between.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _termsError;
  bool _agreed = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(SignUpViewModel vm) {
    final emailError = Validator.email(_email.text);
    final passwordError = Validator.password(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      // The terms failure is stated in words too. An unchecked box with a greyed-out button
      // and no explanation is the most common dead end in a sign-up form.
      _termsError = _agreed ? null : 'Accept the terms to create an account.';
    });
    if (emailError != null || passwordError != null || !_agreed) return;
    vm.signUp(
      email: _email.text,
      password: _password.text,
      termsAgreed: _agreed,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final vm = ref.watch(signUpViewModelProvider);

    return VinkolAuthScaffold(
      title: l10n.authSignUp,
      body: l10n.authCreateAnAccountWithFew,
      fields: <Widget>[
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              VinkolFormField(
                pill: true,
                label: l10n.authEmailAddress,
                controller: _email,
                hint: l10n.authEmailHint,
                error: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                leading:
                    Icon(Icons.mail_outline, size: 19, color: v.textTertiary),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolPasswordField(
                pill: true,
                label: l10n.authPassword,
                controller: _password,
                hint: l10n.authPasswordHint,
                helper: l10n.authPasswordHelper,
                error: _passwordError,
                autofillHint: AutofillHints.newPassword,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
            ],
          ),
        ),
      ],
      aside: VinkolCheckboxRow(
        value: _agreed,
        label: l10n.authAcceptTerms,
        error: _termsError,
        onChanged: (value) => setState(() {
          _agreed = value;
          if (value) _termsError = null;
        }),
      ),
      primaryAction: VinkolPrimaryButton(
        label: l10n.authNext,
        loading: vm.isBusy,
        onPressed: () => _submit(vm),
      ),
      footer: VinkolFooterLink(
        lead: l10n.authHaveAnAccount,
        action: l10n.authLoginAction,
        onTap: () =>
            NavigationService.instance.navigateTo(NavigatorRoutes.loginScreen),
      ),
    );
  }
}
