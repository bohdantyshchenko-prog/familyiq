import 'package:flutter/material.dart';

import '../../../core/data/local_entry_store.dart';
import '../../../core/state/family_store.dart';
import '../application/local_family_controller.dart';

class LocalFamilyShell extends StatefulWidget {
  const LocalFamilyShell({super.key});

  @override
  State<LocalFamilyShell> createState() => _LocalFamilyShellState();
}

class _LocalFamilyShellState extends State<LocalFamilyShell> {
  LocalFamilyController? controller;
  int index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller != null) return;
    controller = LocalFamilyController(familyId: FamilyScope.of(context).familyName)..initialize();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocalFamilyController state = controller!;
    return AnimatedBuilder(
      animation: state,
      builder: (BuildContext context, Widget? child) {
        if (state.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          extendBody: true,
          body: SafeArea(
            child: IndexedStack(
              index: index,
              children: <Widget>[
                _HomePage(controller: state, onNavigate: _select),
                _TimelinePage(controller: state),
                _ProjectsPage(controller: state),
                _FamilyPage(controller: state),
                _ProfilePage(controller: state),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: () => _showCreate(context, state),
            child: const Icon(Icons.add_rounded, size: 30),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _select,
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
              NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'История'),
              NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag_rounded), label: 'Проекты'),
              NavigationDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub_rounded), label: 'Семья'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Профиль'),
            ],
          ),
        );
      },
    );
  }

  void _select(int value) => setState(() => index = value);

  Future<void> _showCreate(BuildContext context, LocalFamilyController state) async {
    final TextEditingController title = TextEditingController();
    final TextEditingController note = TextEditingController();
    String type = 'memory';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.viewInsetsOf(context).bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Создать', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'memory', icon: Icon(Icons.photo_library_outlined), label: Text('Память')),
                  ButtonSegment<String>(value: 'event', icon: Icon(Icons.event_outlined), label: Text('Событие')),
                  ButtonSegment<String>(value: 'project', icon: Icon(Icons.flag_outlined), label: Text('Проект')),
                ],
                selected: <String>{type},
                onSelectionChanged: (Set<String> value) => setSheetState(() => type = value.first),
              ),
              const SizedBox(height: 16),
              TextField(controller: title, maxLength: 160, decoration: const InputDecoration(labelText: 'Название', prefixIcon: Icon(Icons.edit_outlined))),
              const SizedBox(height: 10),
              TextField(controller: note, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Описание', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_rounded))),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  if (title.text.trim().isEmpty) return;
                  await state.create(type: type, title: title.text, note: note.text);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Сохранить')),
              ),
            ],
          ),
        ),
      ),
    );
    title.dispose();
    note.dispose();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.controller, required this.onNavigate});
  final LocalFamilyController controller;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
        children: <Widget>[
          _TopBar(title: 'Доброе утро, ${family.userName}', subtitle: family.familyName),
          const SizedBox(height: 18),
          _LivingHero(records: controller.records.length),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Family Pulse', action: 'Живые данные'),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: _Metric(value: controller.memories.length, label: 'Память', icon: Icons.favorite_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _Metric(value: controller.events.length, label: 'События', icon: Icons.calendar_month_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _Metric(value: controller.projects.length, label: 'Проекты', icon: Icons.flag_rounded)),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Сегодня для вас', action: 'Offline intelligence'),
          const SizedBox(height: 10),
          const _InsightCard(
            icon: Icons.nightlight_round,
            title: 'Спокойный вечер вдвоём',
            body: 'Оставьте один час без телефонов и сохраните короткую заметку о дне.',
            reason: 'На основе локального ритма семьи',
          ),
          const _InsightCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Соберите историю недели',
            body: 'У вас уже достаточно моментов, чтобы сделать короткое недельное резюме.',
            reason: 'Объяснимая рекомендация',
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: 'Продолжить', action: 'Открыть', onTap: () => onNavigate(2)),
          const SizedBox(height: 10),
          if (controller.projects.isEmpty)
            const _EmptyCard(icon: Icons.flag_outlined, title: 'Создайте первый семейный проект')
          else
            ...controller.projects.take(2).map((LocalEntryRecord item) => _ProjectCard(record: item)),
          const SizedBox(height: 22),
          _SectionTitle(title: 'Последние моменты', action: 'Вся история', onTap: () => onNavigate(1)),
          const SizedBox(height: 10),
          ...controller.records.take(3).map((LocalEntryRecord item) => _RecordTile(record: item)),
        ],
      ),
    );
  }
}

class _TimelinePage extends StatelessWidget {
  const _TimelinePage({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
          children: <Widget>[
            const _TopBar(title: 'Семейная история', subtitle: 'Моменты, решения и места'),
            const SizedBox(height: 18),
            const _FeatureStory(),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Вся лента', action: 'Свайп для удаления'),
            const SizedBox(height: 10),
            if (controller.records.isEmpty)
              const _EmptyCard(icon: Icons.auto_stories_outlined, title: 'История пока пуста')
            else
              ...controller.records.map(
                (LocalEntryRecord item) => Dismissible(
                  key: ValueKey<String>(item.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Удалить запись?'),
                      content: Text(item.title),
                      actions: <Widget>[
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
                      ],
                    ),
                  ),
                  onDismissed: (_) => controller.delete(item.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(right: 24),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(24)),
                    child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  child: _RecordTile(record: item),
                ),
              ),
          ],
        ),
      );
}

class _ProjectsPage extends StatelessWidget {
  const _ProjectsPage({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
        children: <Widget>[
          const _TopBar(title: 'Life Projects', subtitle: 'Большие мечты, понятные шаги'),
          const SizedBox(height: 18),
          const _ProjectSummary(),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Активные проекты', action: 'Локально'),
          const SizedBox(height: 10),
          if (controller.projects.isEmpty)
            const _EmptyCard(icon: Icons.flag_outlined, title: 'Проектов пока нет')
          else
            ...controller.projects.map((LocalEntryRecord item) => _ProjectCard(record: item)),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Семейные традиции', action: 'Legacy'),
          const SizedBox(height: 10),
          ...controller.traditions.map((LocalEntryRecord item) => _RecordTile(record: item)),
        ],
      );
}

class _FamilyPage extends StatelessWidget {
  const _FamilyPage({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
        children: <Widget>[
          const _TopBar(title: 'Семейный круг', subtitle: 'Связи, доверие и общее будущее'),
          const SizedBox(height: 18),
          const _FamilyGraph(),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Ближайшее', action: 'События'),
          const SizedBox(height: 10),
          if (controller.events.isEmpty)
            const _EmptyCard(icon: Icons.event_outlined, title: 'Событий пока нет')
          else
            ...controller.events.map((LocalEntryRecord item) => _RecordTile(record: item)),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Trust Center', action: 'Privacy first'),
          const SizedBox(height: 10),
          const _TrustTile(icon: Icons.lock_rounded, title: 'Локальная приватность', subtitle: 'Сейчас семейные записи остаются только на устройстве.'),
          const _TrustTile(icon: Icons.visibility_rounded, title: 'Explainable AI', subtitle: 'Каждая рекомендация должна объяснять источник и причину.'),
          const _TrustTile(icon: Icons.child_care_rounded, title: 'Безопасность детей', subtitle: 'Детские профили проектируются с отдельными правилами доступа.'),
        ],
      );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: <Widget>[
        const _TopBar(title: 'Профиль', subtitle: 'Ваше семейное пространство'),
        const SizedBox(height: 18),
        _ProfileHero(name: family.userName, family: family.familyName, count: controller.records.length),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Настройки', action: 'FamilyIQ 2.1'),
        const SizedBox(height: 10),
        const _TrustTile(icon: Icons.palette_rounded, title: 'Оформление', subtitle: 'Светлая, тёмная и системная тема.'),
        const _TrustTile(icon: Icons.language_rounded, title: 'Язык', subtitle: 'Украинский, русский и английский.'),
        const _TrustTile(icon: Icons.download_rounded, title: 'Архив семьи', subtitle: 'Основа JSON-экспорта и импорта уже подготовлена.'),
        const _TrustTile(icon: Icons.security_rounded, title: 'Безопасность', subtitle: 'Локальный режим без платных сервисов и внешнего облака.'),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.7)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const CircleAvatar(radius: 23, child: Text('БТ', style: TextStyle(fontWeight: FontWeight.w900))),
        ],
      );
}

class _LivingHero extends StatelessWidget {
  const _LivingHero({required this.records});
  final int records;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 310),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF171025), Color(0xFF5B36B8), Color(0xFFB66B78)],
          ),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x385B36B8), blurRadius: 38, offset: Offset(0, 18))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(children: <Widget>[Icon(Icons.auto_awesome_rounded, color: Colors.white), SizedBox(width: 8), Text('FAMILY BRIEF', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
            const Spacer(),
            const Text('Жизнь семьи становится историей.', style: TextStyle(color: Colors.white, fontSize: 32, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.1)),
            const SizedBox(height: 12),
            Text('$records локальных записей уже формируют память вашего семейного пространства.', style: const TextStyle(color: Colors.white70, height: 1.45)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                _HeroPill(icon: Icons.lock_outline_rounded, label: 'Private'),
                _HeroPill(icon: Icons.offline_bolt_outlined, label: 'Offline'),
                _HeroPill(icon: Icons.auto_awesome_outlined, label: 'Explainable'),
              ],
            ),
          ],
        ),
      );
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white24)),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, size: 17, color: Colors.white), const SizedBox(width: 7), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action, this.onTap});
  final String title;
  final String action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
        TextButton(onPressed: onTap, child: Text(action)),
      ]);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.icon});
  final int value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(children: <Widget>[Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 12))]),
        ),
      );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.icon, required this.title, required this.body, required this.reason});
  final IconData icon;
  final String title;
  final String body;
  final String reason;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 7), Text(body, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4)), const SizedBox(height: 10), Text(reason, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w700))])),
          ]),
        ),
      );
}

class _FeatureStory extends StatelessWidget {
  const _FeatureStory();
  @override
  Widget build(BuildContext context) => Container(
        height: 235,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: <Color>[Color(0xFF2A2340), Color(0xFF7658D6)])),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('MEMORY REPLAY', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.1)), Spacer(), Text('Ваше лето — уже часть семейной истории.', style: TextStyle(color: Colors.white, fontSize: 26, height: 1.08, fontWeight: FontWeight.w900)), SizedBox(height: 10), Text('Позже здесь появятся локальные фото, музыка и сезонные итоги.', style: TextStyle(color: Colors.white70, height: 1.4))]),
      );
}

class _ProjectSummary extends StatelessWidget {
  const _ProjectSummary();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(30)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Icon(Icons.explore_rounded, color: Theme.of(context).colorScheme.primary, size: 32), const SizedBox(height: 22), Text('Мечты превращаются в следующие шаги.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 9), Text('FamilyIQ связывает проект, события и семейную память, не требуя облачной подписки.', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, height: 1.4))]),
      );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.record});
  final LocalEntryRecord record;
  @override
  Widget build(BuildContext context) {
    final double progress = ((record.title.codeUnits.fold<int>(0, (int a, int b) => a + b) % 55) + 25) / 100;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[CircleAvatar(child: const Icon(Icons.flag_rounded)), const SizedBox(width: 12), Expanded(child: Text(record.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))), Text('${(progress * 100).round()}%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(99)),
          const SizedBox(height: 12),
          Text(record.note.isEmpty ? 'Следующий шаг пока не добавлен.' : record.note, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.35)),
        ]),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});
  final LocalEntryRecord record;
  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (record.type) { 'event' => Icons.event_rounded, 'project' => Icons.flag_rounded, 'tradition' => Icons.workspace_premium_rounded, _ => Icons.photo_library_rounded };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(record.note.isEmpty ? 'Без описания' : record.note, maxLines: 2, overflow: TextOverflow.ellipsis)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _FamilyGraph extends StatelessWidget {
  const _FamilyGraph();
  @override
  Widget build(BuildContext context) => Container(
        height: 330,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(32)),
        child: Stack(children: const <Widget>[
          Positioned(left: 75, right: 75, top: 86, child: Divider(thickness: 2)),
          Positioned(left: 74, top: 45, child: _GraphNode(label: 'Богдан', subtitle: 'Владелец', icon: Icons.person_rounded)),
          Positioned(right: 74, top: 45, child: _GraphNode(label: 'Карина', subtitle: 'Партнёр', icon: Icons.favorite_rounded)),
          Positioned(left: 0, right: 0, bottom: 28, child: Center(child: _GraphNode(label: 'Будущее', subtitle: 'Семейная капсула', icon: Icons.auto_awesome_rounded))),
        ]),
      );
}

class _GraphNode extends StatelessWidget {
  const _GraphNode({required this.label, required this.subtitle, required this.icon});
  final String label;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(children: <Widget>[CircleAvatar(radius: 34, child: Icon(icon, size: 30)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w900)), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)]);
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.name, required this.family, required this.count});
  final String name;
  final String family;
  final int count;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(children: <Widget>[
            const CircleAvatar(radius: 46, child: Text('БТ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
            const SizedBox(height: 14),
            Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text(family, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Row(children: <Widget>[Expanded(child: _MiniScore(value: '$count', label: 'записей')), const SizedBox(width: 8), const Expanded(child: _MiniScore(value: '100%', label: 'локально')), const SizedBox(width: 8), const Expanded(child: _MiniScore(value: '3', label: 'языка'))]),
          ]),
        ),
      );
}

class _MiniScore extends StatelessWidget {
  const _MiniScore({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .55), borderRadius: BorderRadius.circular(18)), child: Column(children: <Widget>[Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 11))]));
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded)));
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(26), child: Column(children: <Widget>[Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))])));
}
