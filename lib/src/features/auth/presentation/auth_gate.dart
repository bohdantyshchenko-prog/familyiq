import 'package:flutter/material.dart';

import '../../../core/state/family_store.dart';
import '../../shell/presentation/family_iq_world_shell.dart';

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
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              child: store.signedIn
                  ? FamilyIqWorldShell(
                      key: ValueKey<String>('world-${store.familyName}'),
                      familyId: store.familyName,
                    )
                  : const _WelcomeScreen(key: ValueKey<String>('welcome')),
            );
          },
        ),
      );
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF070914),
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
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: <Color>[Color(0xFF9066FF), Color(0xFF5427C8)]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x775E36D9), blurRadius: 35, offset: Offset(0, 16))],
                      ),
                      child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 30),
                    const Text('FamilyIQ', style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    const SizedBox(height: 10),
                    const Text('Приватная операционная система семьи: память, проекты, календарь и понятные советы.', style: TextStyle(color: Colors.white60, fontSize: 17, height: 1.45)),
                    const SizedBox(height: 32),
                    TextField(controller: nameController, textInputAction: TextInputAction.next, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Ваше имя', prefixIcon: Icon(Icons.person_outline_rounded))),
                    const SizedBox(height: 14),
                    TextField(controller: familyController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Название семейного пространства', prefixIcon: Icon(Icons.home_outlined))),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: loading ? null : _continue,
                      icon: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward_rounded),
                      label: const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Создать бесплатное пространство')),
                    ),
                    const SizedBox(height: 18),
                    const Row(children: <Widget>[Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 18), SizedBox(width: 8), Expanded(child: Text('Записи хранятся локально. Платные сервисы не требуются.', style: TextStyle(color: Colors.white54)))]),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _continue() async {
    setState(() => loading = true);
    await FamilyScope.of(context).signIn(name: nameController.text, family: familyController.text);
    if (mounted) setState(() => loading = false);
  }
}
