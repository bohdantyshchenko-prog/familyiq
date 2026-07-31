import 'package:flutter/material.dart';

class FamilyShell extends StatefulWidget {
  const FamilyShell({super.key});

  @override
  State<FamilyShell> createState() => _FamilyShellState();
}

class _FamilyShellState extends State<FamilyShell> {
  int index = 0;

  final List<Widget> pages = const <Widget>[
    _HomeScreen(),
    _TimelineScreen(),
    _BrainScreen(),
    _FamilyScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
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

  Future<void> _showCreateSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Создать', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const _CreateGrid(),
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: const <Widget>[
        _TopBar(title: 'Добрый день, Богдан', subtitle: 'Пятница · Житомир'),
        SizedBox(height: 20),
        _HeroBrief(),
        SizedBox(height: 22),
        _SectionHeader(title: 'Family Pulse', action: 'Подробнее'),
        SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(child: _ScoreCard(value: '84', label: 'Связь', icon: Icons.favorite_rounded)),
          SizedBox(width: 10),
          Expanded(child: _ScoreCard(value: '76', label: 'Память', icon: Icons.photo_library_rounded)),
          SizedBox(width: 10),
          Expanded(child: _ScoreCard(value: '91', label: 'Доверие', icon: Icons.shield_rounded)),
        ]),
        SizedBox(height: 22),
        _SectionHeader(title: 'Сегодня для вас', action: 'Все'),
        SizedBox(height: 10),
        _TodayCard(icon: Icons.calendar_month_rounded, title: 'Спокойный вечер вдвоём', body: 'После 19:00 нет общих событий. FamilyIQ предлагает выделить час без телефонов.', tag: 'На основе календаря'),
        _TodayCard(icon: Icons.savings_outlined, title: 'Цель «Дом мечты»', body: 'До месячного плана накоплений осталось 4 200 ₴.', tag: 'Финансовая цель'),
        SizedBox(height: 22),
        _SectionHeader(title: 'Живые проекты', action: 'Открыть'),
        SizedBox(height: 10),
        _ProjectCard(title: 'Дом мечты', progress: .72, note: 'Следующий шаг: утвердить бюджет участка', icon: Icons.home_work_rounded),
        _ProjectCard(title: 'Семейная книга', progress: .35, note: 'Добавьте историю родителей', icon: Icons.menu_book_rounded),
      ],
    );
  }
}

class _TimelineScreen extends StatelessWidget {
  const _TimelineScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: const <Widget>[
        _TopBar(title: 'Семейная история', subtitle: 'Моменты, места и решения'),
        SizedBox(height: 18),
        _FilterChips(),
        SizedBox(height: 18),
        _MemoryFeature(),
        SizedBox(height: 14),
        _MemoryCard(icon: Icons.restaurant_rounded, title: 'Семейный ужин', meta: 'Вчера · AI Story', body: 'Из четырёх фотографий и короткой заметки создана история вечера.'),
        _MemoryCard(icon: Icons.landscape_rounded, title: 'Карпаты', meta: 'Май · 26 моментов', body: 'Поездка объединяет фотографии, маршрут, расходы и семейные впечатления.'),
        _MemoryCard(icon: Icons.celebration_rounded, title: 'День рождения Карины', meta: '27 июля · 18 моментов', body: 'Фото, поздравления и голосовые истории собраны в одном месте.'),
      ],
    );
  }
}

class _BrainScreen extends StatefulWidget {
  const _BrainScreen();

  @override
  State<_BrainScreen> createState() => _BrainScreenState();
}

class _BrainScreenState extends State<_BrainScreen> {
  final TextEditingController controller = TextEditingController();
  final List<String> userMessages = <String>[];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.fromLTRB(18, 12, 18, 0), child: _TopBar(title: 'Family Brain', subtitle: 'Ваш семейный AI-компаньон')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            children: <Widget>[
              const _BrainOrb(),
              const SizedBox(height: 18),
              const _AssistantBubble(text: 'Я собрал краткий обзор семьи. Сегодня главное — спокойный вечер, цель по накоплениям и одно несохранённое воспоминание.'),
              const SizedBox(height: 14),
              const _PromptGrid(),
              ...userMessages.map((message) => _UserBubble(text: message)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 112),
          child: Row(children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Спросите о семье, планах или памяти',
                  prefixIcon: const Icon(Icons.auto_awesome_rounded),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _send, icon: const Icon(Icons.arrow_upward_rounded)),
          ]),
        ),
      ],
    );
  }

  void _send() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() => userMessages.add(value));
    controller.clear();
  }
}

class _FamilyScreen extends StatelessWidget {
  const _FamilyScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: const <Widget>[
        _TopBar(title: 'Семейный круг', subtitle: 'Люди, отношения и общее пространство'),
        SizedBox(height: 20),
        _GraphCard(),
        SizedBox(height: 20),
        _SectionHeader(title: 'Ближайшее', action: 'Календарь'),
        SizedBox(height: 10),
        _EventTile(day: '02', month: 'АВГ', title: 'Вечерняя прогулка', subtitle: '19:30 · Богдан и Карина'),
        _EventTile(day: '05', month: 'АВГ', title: 'Оплата квартиры', subtitle: 'Напоминание · Общая задача'),
        SizedBox(height: 20),
        _SectionHeader(title: 'Trust Center', action: 'Настроить'),
        SizedBox(height: 10),
        _TrustTile(icon: Icons.lock_rounded, title: 'Приватность включена', subtitle: 'Личные данные доступны только выбранным членам семьи'),
        _TrustTile(icon: Icons.visibility_rounded, title: 'Explainable AI', subtitle: 'Каждый совет показывает, какие данные использованы'),
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: const <Widget>[
        _TopBar(title: 'Профиль', subtitle: 'Ваше семейное пространство'),
        SizedBox(height: 20),
        _ProfileHero(),
        SizedBox(height: 20),
        _SectionHeader(title: 'Ваш прогресс', action: 'Статистика'),
        SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(child: _MiniStat(value: '128', label: 'моментов')),
          SizedBox(width: 10),
          Expanded(child: _MiniStat(value: '14', label: 'традиций')),
          SizedBox(width: 10),
          Expanded(child: _MiniStat(value: '6', label: 'проектов')),
        ]),
        SizedBox(height: 20),
        _SettingsTile(icon: Icons.notifications_rounded, title: 'Уведомления', subtitle: 'События, задачи и воспоминания'),
        _SettingsTile(icon: Icons.palette_rounded, title: 'Оформление', subtitle: 'Светлая, тёмная и системная тема'),
        _SettingsTile(icon: Icons.security_rounded, title: 'Безопасность', subtitle: 'Устройства, сессии и резервное восстановление'),
        _SettingsTile(icon: Icons.download_rounded, title: 'Экспорт данных', subtitle: 'Скачайте полный семейный архив'),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.7)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
        const CircleAvatar(radius: 22, child: Text('БТ', style: TextStyle(fontWeight: FontWeight.w900))),
      ]);
}

class _HeroBrief extends StatelessWidget {
  const _HeroBrief();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF24123F), Color(0xFF6941C6), Color(0xFFD17A74)]),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x336941C6), blurRadius: 30, offset: Offset(0, 16))],
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[Icon(Icons.auto_awesome_rounded, color: Colors.white), SizedBox(width: 8), Text('FAMILY BRIEF', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
          SizedBox(height: 38),
          Text('Сегодня достаточно одного хорошего момента.', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.08, fontWeight: FontWeight.w900)),
          SizedBox(height: 12),
          Text('Сохраните вечер и обсудите один общий план на август.', style: TextStyle(color: Colors.white70, height: 1.4)),
          SizedBox(height: 20),
          FilledButton.tonal(onPressed: null, child: Text('Открыть дневной обзор')),
        ]),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
        Text(action, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
      ]);
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(children: <Widget>[Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 12))]),
        ),
      );
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.icon, required this.title, required this.body, required this.tag});
  final IconData icon;
  final String title;
  final String body;
  final String tag;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 6),
              Text(body, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 10),
              Text(tag, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
            ])),
          ]),
        ),
      );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.title, required this.progress, required this.note, required this.icon});
  final String title;
  final double progress;
  final String note;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Row(children: <Widget>[CircleAvatar(child: Icon(icon)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900))]),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(99)),
            const SizedBox(height: 10),
            Text(note, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();
  @override
  Widget build(BuildContext context) => const Wrap(spacing: 8, children: <Widget>[Chip(label: Text('Все')), Chip(label: Text('Фото')), Chip(label: Text('Истории')), Chip(label: Text('Поездки'))]);
}

class _MemoryFeature extends StatelessWidget {
  const _MemoryFeature();
  @override
  Widget build(BuildContext context) => Container(
        height: 230,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: <Color>[Color(0xFF3B2B55), Color(0xFF7D5BA6)])),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Text('СЕГОДНЯ · 8 ФОТОГРАФИЙ', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Летняя прогулка', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('Небольшой момент, который станет частью вашей семейной истории.', style: TextStyle(color: Colors.white70, height: 1.4)),
        ]),
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
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(contentPadding: const EdgeInsets.all(16), leading: CircleAvatar(radius: 26, child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('$meta\n$body', style: const TextStyle(height: 1.4))), trailing: const Icon(Icons.chevron_right_rounded)),
      );
}

class _BrainOrb extends StatelessWidget {
  const _BrainOrb();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 118,
          height: 118,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: <Color>[Color(0xFFF7D8FF), Color(0xFFA46BF5), Color(0xFF43206F)]), boxShadow: <BoxShadow>[BoxShadow(color: Color(0x665F2DA5), blurRadius: 38, spreadRadius: 8)]),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 42),
        ),
      );
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(22)), child: Text(text, style: const TextStyle(height: 1.45))));
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(22)), child: Text(text, style: const TextStyle(color: Colors.white))));
}

class _PromptGrid extends StatelessWidget {
  const _PromptGrid();
  @override
  Widget build(BuildContext context) => const Wrap(spacing: 8, runSpacing: 8, children: <Widget>[ActionChip(label: Text('План выходных'), onPressed: null), ActionChip(label: Text('Что важно сегодня?'), onPressed: null), ActionChip(label: Text('Семейная цель'), onPressed: null), ActionChip(label: Text('Создать историю'), onPressed: null)]);
}

class _GraphCard extends StatelessWidget {
  const _GraphCard();
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(children: <Widget>[
            const _PersonNode(name: 'Богдан', role: 'Владелец', icon: Icons.person_rounded),
            Container(width: 2, height: 28, color: Theme.of(context).colorScheme.primary),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
              _PersonNode(name: 'Карина', role: 'Партнёр', icon: Icons.favorite_rounded),
              _PersonNode(name: 'Дом мечты', role: 'Проект', icon: Icons.home_work_rounded),
              _PersonNode(name: 'Семья', role: '12 связей', icon: Icons.groups_rounded),
            ]),
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
  Widget build(BuildContext context) => Column(children: <Widget>[CircleAvatar(radius: 30, child: Icon(icon)), const SizedBox(height: 7), Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)), Text(role, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10))]);
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.day, required this.month, required this.title, required this.subtitle});
  final String day;
  final String month;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: Container(width: 52, padding: const EdgeInsets.symmetric(vertical: 7), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Text(day, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text(month, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))])), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded)));
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.check_circle_rounded)));
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: <Widget>[const CircleAvatar(radius: 38, child: Text('БТ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('Богдан Тищенко', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('Создатель семейного пространства', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 10), const Chip(label: Text('FamilyIQ Pioneer'))]))])));
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8), child: Column(children: <Widget>[Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 11))])));
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded)));
}

class _CreateGrid extends StatelessWidget {
  const _CreateGrid();
  @override
  Widget build(BuildContext context) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: const <Widget>[
          _CreateAction(icon: Icons.photo_library_rounded, title: 'Воспоминание'),
          _CreateAction(icon: Icons.event_rounded, title: 'Событие'),
          _CreateAction(icon: Icons.flag_rounded, title: 'Проект'),
          _CreateAction(icon: Icons.mic_rounded, title: 'Голосовая история'),
        ],
      );
}

class _CreateAction extends StatelessWidget {
  const _CreateAction({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.pop(context),
        child: Ink(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(22)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(icon), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w800))])),
      );
}
