import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/state/family_store.dart';
import '../../shell/presentation/production_family_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FamilyStore store = FamilyStore();

  @override
  void initState() {
    super.initState();
    store.initialize();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FamilyScope(
        store: store,
        child: AnimatedBuilder(
          animation: store,
          builder: (BuildContext context, Widget? child) {
            if (!store.initialized) {
              return const Scaffold(body: _LaunchLoader());
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: store.signedIn
                  ? ProductionFamilyShell(
                      key: ValueKey<String>('family-${store.familyId}'),
                      familyId: store.familyId,
                    )
                  : _AccountScreen(
                      key: ValueKey<String>(store.hasAccount ? 'signin' : 'create'),
                    ),
            );
          },
        ),
      );
}

class _LaunchLoader extends StatelessWidget {
  const _LaunchLoader();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      );
}

class _AccountScreen extends StatefulWidget {
  const _AccountScreen({super.key});

  @override
  State<_AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<_AccountScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController familyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocus = FocusNode();

  bool loading = false;
  bool obscurePin = true;
  String? errorCode;
  bool hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hydrated) return;
    final FamilyStore store = FamilyScope.of(context);
    nameController.text = store.userName;
    familyController.text = store.familyName;
    emailController.text = store.email;
    hydrated = true;
  }

  @override
  void dispose() {
    nameController.dispose();
    familyController.dispose();
    emailController.dispose();
    pinController.dispose();
    pinFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final FamilyStore store = FamilyScope.of(context);
    final bool signIn = store.hasAccount;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      _BrandMark(colors: colors),
                      SizedBox(height: constraints.maxHeight > 780 ? 38 : 24),
                      Text(
                        signIn ? 'С возвращением' : 'Ваше семейное пространство',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        signIn
                            ? 'Войдите в защищённый профиль на этом устройстве.'
                            : 'Память, события и семейные планы — в одном приватном пространстве.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),
                        ),
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (!signIn) ...<Widget>[
                                TextField(
                                  controller: nameController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const <String>[AutofillHints.name],
                                  decoration: const InputDecoration(
                                    labelText: 'Ваше имя',
                                    prefixIcon: Icon(Icons.person_outline_rounded),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: familyController,
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Название семьи',
                                    prefixIcon: Icon(Icons.home_outlined),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextField(
                                controller: emailController,
                                enabled: !signIn,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const <String>[AutofillHints.email],
                                autocorrect: false,
                                enableSuggestions: false,
                                onSubmitted: (_) => pinFocus.requestFocus(),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.alternate_email_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: pinController,
                                focusNode: pinFocus,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                autofillHints: const <String>[AutofillHints.password],
                                obscureText: obscurePin,
                                maxLength: 6,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                onSubmitted: (_) => _submit(signIn: signIn),
                                decoration: InputDecoration(
                                  labelText: signIn ? '6-значный PIN' : 'Придумайте 6-значный PIN',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  counterText: '',
                                  suffixIcon: IconButton(
                                    tooltip: obscurePin ? 'Показать PIN' : 'Скрыть PIN',
                                    onPressed: () => setState(() => obscurePin = !obscurePin),
                                    icon: Icon(obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                ),
                              ),
                              if (errorCode != null) ...<Widget>[
                                const SizedBox(height: 12),
                                _InlineError(message: _messageFor(errorCode!)),
                              ],
                              const SizedBox(height: 18),
                              FilledButton(
                                onPressed: loading ? null : () => _submit(signIn: signIn),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  child: loading
                                      ? const SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2.2),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(signIn ? 'Войти' : 'Создать пространство'),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward_rounded, size: 19),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _PrivacyNote(signIn: signIn),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit({required bool signIn}) async {
    if (loading) return;
    setState(() {
      loading = true;
      errorCode = null;
    });

    final FamilyStore store = FamilyScope.of(context);
    final String? result = signIn
        ? await store.signIn(
            emailAddress: emailController.text,
            pin: pinController.text,
          )
        : await store.createAccount(
            name: nameController.text,
            family: familyController.text,
            emailAddress: emailController.text,
            pin: pinController.text,
          );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        loading = false;
        errorCode = result;
      });
      return;
    }
    TextInput.finishAutofillContext();
  }

  String _messageFor(String code) => switch (code) {
        'invalid_name' => 'Укажите имя от 2 до 80 символов.',
        'invalid_family' => 'Укажите название семьи от 2 до 100 символов.',
        'invalid_email' => 'Проверьте формат email.',
        'invalid_pin' => 'PIN должен состоять ровно из 6 цифр.',
        'pin_not_configured' => 'Для старого профиля PIN ещё не настроен.',
        'account_not_found' => 'Локальный профиль не найден.',
        _ => 'Email или PIN не совпадают.',
      };
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[colors.primary, colors.tertiary],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.primary.withValues(alpha: .22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 13),
          Text(
            'FamilyIQ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
          ),
        ],
      );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.signIn});

  final bool signIn;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.shield_outlined, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            signIn
                ? 'PIN хранится в защищённом хранилище устройства. Выход не удаляет семейные записи.'
                : 'Профиль создаётся на этом устройстве. PIN хранится отдельно от семейных данных в защищённом системном хранилище.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, height: 1.45),
          ),
        ),
      ],
    );
  }
}
