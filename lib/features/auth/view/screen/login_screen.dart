import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/core/utils/validators.dart';
import 'package:starter_codes/features/auth/view_model/login_view_model.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// Sign in. Built on the auth archetype: the mark, a centred heading, pill fields, one
/// saturated action, and the way to Sign up pinned to the bottom edge.
///
/// Errors are held in state and shown on submit rather than through Flutter's `Form`
/// validator plumbing, because [VinkolFormField] renders the failure as a sentence with an
/// icon and announces it to a screen reader — a red outline alone is not an error message.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Where "Remember me" keeps the address. Local only — this is a convenience on this
  /// device, not an account setting, so it never goes to the backend.
  static const String _rememberedEmailKey = 'rememberedEmail';

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    final vm = ref.read(loginViewModelProvider);
    _email.text = vm.email;
    _password.text = vm.password;

    // A remembered address fills the field and leaves the box checked, so the state the user
    // is looking at is the state they left behind.
    final remembered =
        locator<LocalCache>().getFromLocalCache(_rememberedEmailKey);
    if (remembered is String && remembered.isNotEmpty && _email.text.isEmpty) {
      _email.text = remembered;
      _remember = true;
    }

    // Listeners go on last, and deliberately: assigning `.text` above notifies the
    // controller, and a listener that writes to the view model would be modifying a
    // provider while the tree is building. The seeded values reach the view model in
    // [_submit] instead.
    _email.addListener(
        () => ref.read(loginViewModelProvider).setEmail(_email.text));
    _password.addListener(
        () => ref.read(loginViewModelProvider).setPassword(_password.text));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _persistRemembered() async {
    final cache = locator<LocalCache>();
    if (_remember) {
      await cache.saveToLocalCache(
          key: _rememberedEmailKey, value: _email.text.trim());
    } else {
      await cache.removeFromLocalCache(_rememberedEmailKey);
    }
  }

  void _submit(LoginViewModel vm) {
    final emailError = Validator.email(_email.text);
    final passwordError = Validator.password(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) return;
    // Written before the request, not after it: a user who mistyped their password and has
    // to come back still wants the address they typed to be there.
    _persistRemembered();
    // The fields are the truth at this point — a seeded value the user never touched
    // fired no listener, so push both across before the request goes out.
    vm.setEmail(_email.text);
    vm.setPassword(_password.text);
    vm.login(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final vm = ref.watch(loginViewModelProvider);

    return VinkolAuthScaffold(
      title: l10n.authLoginAction,
      body: l10n.authLoginHeading,
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
                error: _passwordError,
                hint: '*******',
                autofillHint: AutofillHints.password,
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
        value: _remember,
        label: l10n.authRememberMe,
        onChanged: (value) => setState(() => _remember = value),
        trailing: VinkolTextLink(
          label: l10n.authForgotPassword,
          onTap: vm.navigateToResetPassword,
        ),
      ),
      primaryAction: VinkolPrimaryButton(
        label: l10n.authLoginAction,
        loading: vm.isBusy,
        onPressed: () => _submit(vm),
      ),
      footer: VinkolFooterLink(
        lead: l10n.authNewHere,
        action: l10n.authCreateAccount,
        onTap: () =>
            NavigationService.instance.navigateTo(NavigatorRoutes.signupScreen),
      ),
    );
  }
}
