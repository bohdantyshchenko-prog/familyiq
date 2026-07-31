import 'package:flutter/material.dart';

class FamilyShell extends StatefulWidget {
  const FamilyShell({super.key});

  @override
  State<FamilyShell> createState() => _FamilyShellState();
}

class _FamilyShellState extends State<FamilyShell> {
  int index = 0;

  static const List<Widget> pages = <Widget>[
    _HomeScreen(),
    _TimelineScreen(),
    _AiScreen(),
    _GraphScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (int value) => setState(() => index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'История'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub_rounded), label: 'Семья'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        child: Wrap(
          runSpacing: 12,
          children: <Widget>[
            Text('Добавить в FamilyIQ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const _CreateAction(icon: Icons.photo_library_outlined, title: 'Воспоминание'),
            const _CreateAction(icon: Icons.event_outlined, title: 'Событие'),
            const _CreateAction(icon: Icons.flag_outlined, title: 'Семейный проект'),
            const _CreateAction(icon: Icons.mic_none_rounded, title: 'Голосовая история'),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        const _Header(title: 'Добрый день, Богдан', subtitle: 'Сегодня у семьи спокойный день'),
        const SizedBox(height: 18),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[Color(0xFF38246E), Color(0xFF8A6AF2)]),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                SizedBox(height: 38),
                Text('Family Brief', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('Сохраните один момент дня и обсудите планы на выходные.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.15, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Family Pulse'),
        const Row(
          children: <Widget>[
            Expanded(child: _Metric(label: 'Связь', value: '84', icon: Icons.favorite_outline)),
            SizedBox(width: 10),
            Expanded(child: _Metric(label: 'Память', value: '76', icon: Icons.photo_library_outlined)),
            SizedBox(width: 10),
            Expanded(child: _Metric(label: 'Доверие', value: '91', icon: Icons.shield_outlined)),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Активные проекты'),
        const _ProjectCard(title: 'Дом мечты', progress: .72, next: 'Согласовать бюджет участка'),
        const _ProjectCard(title: 'Семейная книга', progress: .35, next: 'Добавить истории родителей'),
      ],
    );
  }
}

class _TimelineScreen extends StatelessWidget {
  const _TimelineScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const <Widget>[
        _Header(title: 'Семейная история', subtitle: 'Единая лента моментов, мест и решений'),
        SizedBox(height: 18),
        _MemoryCard(icon: Icons.wb_sunny_outlined, title: 'Летняя прогулка', meta: 'Сегодня · 8 фотографий', body: 'Небольшой момент, который стоит сохранить.'),
        _MemoryCard(icon: Icons.restaurant_outlined, title: 'Семейный ужин', meta: 'Вчера · AI Story', body: 'FamilyIQ собрал короткую историю из фото и заметок.'),
        _MemoryCard(icon: Icons.landscape_outlined, title: 'Карпаты', meta: 'Май · 26 моментов', body: 'Поездка связана с людьми, местами и семейным проектом.'),
      ],
    );
  }
}

class _AiScreen extends StatefulWidget {
  const _AiScreen();

  @override
  State<_AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<_AiScreen> {
  final TextEditingController controller = TextEditingController();
  final List<String> messages = <String>['Я учитываю семейный контекст, но каждую рекомендацию объясняю и оставляю решение вам.'];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.all(18), child: _Header(title: 'Family Brain', subtitle: 'Explainable AI для повседневной жизни')),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int i) => Align(
              alignment: i == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: i == 0 ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(messages[i], style: TextStyle(color: i == 0 ? null : Colors.white, height: 1.4)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Спросите Family Brain', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _send, icon: const Icon(Icons.arrow_upward_rounded)),
            ],
          ),
        ),
      ],
    );
  }

  void _send() {
    final String value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() => messages.add(value));
    controller.clear();
  }
}

class _GraphScreen extends StatelessWidget {
  const _GraphScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        const _Header(title: 'Family Graph', subtitle: 'Люди, связи, память, проекты и события'),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: <Widget>[
                const _PersonNode(name: 'Богдан', role: 'Владелец', icon: Icons.person_rounded),
                Container(width: 2, height: 32, color: Theme.of(context).colorScheme.primary),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _PersonNode(name: 'Карина', role: 'Партнёр', icon: Icons.favorite_rounded),
                    _PersonNode(name: 'Дом мечты', role: 'Проект', icon: Icons.home_work_outlined),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Trust Center'),
        const _SettingTile(icon: Icons.lock_outline_rounded, title: 'Приватность по умолчанию', subtitle: 'Каждый тип данных имеет явные правила доступа'),
        const _SettingTile(icon: Icons.visibility_outlined, title: 'Explainable AI', subtitle: 'Рекомендации показывают причины и использованные данные'),
        const _SettingTile(icon: Icons.admin_panel_settings_outlined, title: 'Семейные роли', subtitle: 'Владелец, взрослый, ребёнок и родственник'),
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const <Widget>[
        _Header(title: 'Богдан Тищенко', subtitle: 'Создатель семейного пространства'),
        SizedBox(height: 18),
        _SettingTile(icon: Icons.notifications_none_rounded, title: 'Уведомления', subtitle: 'События, память и семейные напоминания'),
        _SettingTile(icon: Icons.download_outlined, title: 'Экспорт данных', subtitle: 'Данные остаются переносимыми'),
        _SettingTile(icon: Icons.security_rounded, title: 'Безопасность', subtitle: 'Сессии, устройства и резервное восстановление'),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 5),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(children: <Widget>[Icon(icon), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 12))]),
        ),
      );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.title, required this.progress, required this.next});
  final String title;
  final double progress;
  final String next;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(next),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(99)),
          ]),
        ),
      );
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.icon, required this.title, required this.meta, required this.body});
  final IconData icon;
  final String title;
  final String meta;
  final String body;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            CircleAvatar(radius: 25, child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text(meta, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 9),
              Text(body, style: const TextStyle(height: 1.4)),
            ])),
          ]),
        ),
      );
}

class _PersonNode extends StatelessWidget {
  const _PersonNode({required this.name, required this.role, required this.icon});
  final String name;
  final String role;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(children: <Widget>[CircleAvatar(radius: 34, child: Icon(icon, size: 30)), const SizedBox(height: 8), Text(name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(role, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))]);
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded)));
}

class _CreateAction extends StatelessWidget {
  const _CreateAction({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        onTap: () => Navigator.pop(context),
      );
}
