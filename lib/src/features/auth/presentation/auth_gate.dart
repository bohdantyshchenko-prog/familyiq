import 'package:flutter/material.dart';

import '../../../core/state/family_store.dart';
import '../../shell/presentation/local_family_shell.dart';

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
  Widget build(BuildContext context) {
    return FamilyScope(
      store: store,
      child: AnimatedBuilder(
        animation: store,
        builder: (BuildContext context, Widget? child) {
          if (!store.initialized) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            child: store.signedIn
                ? const LocalFamilyShell(key: ValueKey<String>('local-app'))
                : const _WelcomeScreen(key: ValueKey<String>('welcome')),
          );
        },
      ),
    );
  }
}

class _WelcomeScreen extends StatefulWidget {
  const _WelcomeScreen({super.key});

  @override
  State<_WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<_WelcomeScreen> {
  final TextEditingController nameController = TextEditingController(text: 'Богдан');
  final TextEditingController familyController = TextEditingController(text: 'Семья Тищенко');
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    familyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: <Color>[Color(0xFF5D3FD3), Color(0xFF9C7CFF)]),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 28),
                  Text('FamilyIQ', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.8)),
                  const SizedBox(height: 10),
                  Text('Ваше приватное пространство для семьи, памяти, планов и решений.', style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.45)),
                  const SizedBox(height: 32),
                  TextField(controller: nameController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Ваше имя', prefixIcon: Icon(Icons.person_outline_rounded))),
                  const SizedBox(height: 14),
                  TextField(controller: familyController, decoration: const InputDecoration(labelText: 'Название семейного пространства', prefixIcon: Icon(Icons.home_outlined))),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: loading ? null : _continue,
                    icon: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward_rounded),
                    label: const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Создать бесплатное пространство')),
                  ),
                  const SizedBox(height: 18),
                  const Row(children: <Widget>[Icon(Icons.lock_outline_rounded, size: 18), SizedBox(width: 8), Expanded(child: Text('Записи хранятся локально. Платные сервисы не требуются.'))]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => loading = true);
    await FamilyScope.of(context).signIn(name: nameController.text, family: familyController.text);
    if (mounted) setState(() => loading = false);
  }
}
