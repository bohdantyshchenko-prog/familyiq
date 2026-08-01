import 'package:flutter/material.dart';

import '../../../core/data/local_entry_store.dart';
import '../../../core/state/family_store.dart';
import '../../deep_local/domain/deep_local_models.dart';
import '../application/local_family_controller.dart';

class FamilyIq24Shell extends StatefulWidget {
  const FamilyIq24Shell({required this.familyId, super.key});
  final String familyId;

  @override
  State<FamilyIq24Shell> createState() => _FamilyIq24ShellState();
}

class _FamilyIq24ShellState extends State<FamilyIq24Shell> {
  late final LocalFamilyController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    controller = LocalFamilyController(familyId: widget.familyId)..initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final List<Widget> pages = <Widget>[
            _Home(controller: controller),
            _Timeline(controller: controller),
            _Calendar(controller: controller),
            _Projects(controller: controller),
            _Intelligence(controller: controller),
            _Family(controller: controller),
          ];
          return Scaffold(
            extendBody: true,
            body: SafeArea(child: IndexedStack(index: index, children: pages)),
            floatingActionButton: FloatingActionButton.large(onPressed: _create, child: const Icon(Icons.add_rounded)),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (int value) => setState(() => index = value),
              destinations: const <NavigationDestination>[
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
                NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'История'),
                NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Календарь'),
                NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag_rounded), label: 'Проекты'),
                NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'IQ'),
                NavigationDestination(icon: Icon(Icons.family_restroom_outlined), selectedIcon: Icon(Icons.family_restroom_rounded), label: 'Семья'),
              ],
            ),
          );
        },
      );

  Future<void> _create() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController note = TextEditingController();
    String type = 'memory';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext modalContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Text('Добавить в FamilyIQ', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: type,
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'memory', child: Text('Воспоминание')),
                DropdownMenuItem(value: 'event', child: Text('Событие')),
                DropdownMenuItem(value: 'project', child: Text('Проект')),
                DropdownMenuItem(value: 'tradition', child: Text('Традиция')),
                DropdownMenuItem(value: 'child', child: Text('Детская запись')),
              ],
              onChanged: (String? value) => setModalState(() => type = value ?? type),
            ),
            const SizedBox(height: 12),
            TextField(controller: title, maxLength: 160, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: note, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Описание')),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                await controller.create(type: type, title: title.text, note: note.text);
                if (modalContext.mounted) Navigator.pop(modalContext);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Сохранить локально')),
            ),
          ]),
        ),
      ),
    );
    title.dispose();
    note.dispose();
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
        _Header(title: 'Добрый день, ${family.userName}', subtitle: family.familyName),
        const SizedBox(height: 18),
        _Hero(count: controller.records.length),
        const SizedBox(height: 20),
        _Metrics(controller: controller),
        const SizedBox(height: 22),
        const _Title('Сегодня для вас'),
        ...controller.insights.take(3).map((LocalInsight insight) => _InsightCard(insight: insight)),
        const SizedBox(height: 22),
        const _Title('Последние моменты'),
        ...controller.records.take(4).map((LocalEntryRecord record) => _RecordCard(record: record)),
      ]),
    );
  }
}

class _Timeline extends StatefulWidget {
  const _Timeline({required this.controller});
  final LocalFamilyController controller;

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
        children: <Widget>[
          const _Header(title: 'Memory Engine', subtitle: 'Поиск, сезоны и «В этот день»'),
          const SizedBox(height: 16),
          TextField(
            onChanged: (String value) => widget.controller.setSearch(value: value),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Найти в семейной истории'),
          ),
          const SizedBox(height: 16),
          if (widget.controller.onThisDay.isNotEmpty) ...<Widget>[
            const _Title('В этот день'),
            ...widget.controller.onThisDay.map((LocalEntryRecord record) => _RecordCard(record: record)),
          ],
          const _Title('Вся история'),
          ...widget.controller.filteredRecords.map((LocalEntryRecord record) => _RecordCard(record: record)),
        ],
      );
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final List<CalendarOccurrence> values = controller.month(DateTime.now());
    return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
      const _Header(title: 'Семейный календарь', subtitle: 'Месяц, события и общие планы'),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: CalendarDatePicker(initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2035), onDateChanged: (_) {}))),
      const SizedBox(height: 18),
      const _Title('События месяца'),
      if (values.isEmpty) const _Empty('В этом месяце событий пока нет'),
      ...values.map((CalendarOccurrence item) => ListTile(leading: const CircleAvatar(child: Icon(Icons.event_rounded)), title: Text(item.title), subtitle: Text('${item.startsAt.day}.${item.startsAt.month}.${item.startsAt.year}'))),
    ]);
  }
}

class _Projects extends StatelessWidget {
  const _Projects({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
        const _Header(title: 'Life Projects', subtitle: 'Этапы, цели и семейные традиции'),
        const SizedBox(height: 18),
        ...controller.projects.map((LocalEntryRecord record) => _ProjectCard(record: record)),
        const SizedBox(height: 18),
        const _Title('Традиции'),
        ...controller.traditions.map((LocalEntryRecord record) => _RecordCard(record: record)),
      ]);
}

class _Intelligence extends StatelessWidget {
  const _Intelligence({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final MemorySummary summary = controller.seasonalSummary;
    return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
      const _Header(title: 'Offline Family Brain', subtitle: 'Правила, причины и понятные действия'),
      const SizedBox(height: 18),
      ...controller.insights.map((LocalInsight insight) => _InsightCard(insight: insight)),
      const SizedBox(height: 20),
      _Title('Итоги: ${summary.periodLabel}'),
      _SummaryCard(summary: summary),
    ]);
  }
}

class _Family extends StatelessWidget {
  const _Family({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
        const _Header(title: 'Семья и дети', subtitle: 'Связи, приватность и развитие'),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const <Widget>[
          _Person(initials: 'БТ', name: 'Богдан', role: 'Владелец'),
          Icon(Icons.favorite_rounded),
          _Person(initials: 'КВ', name: 'Карина', role: 'Партнёр'),
        ]))),
        const SizedBox(height: 18),
        const _Title('Детские профили'),
        if (controller.children.isEmpty) const _Empty('Создайте безопасный профиль ребёнка'),
        ...controller.children.map((LocalEntryRecord record) => _RecordCard(record: record)),
        const SizedBox(height: 18),
        const _Title('Trust Center'),
        const ListTile(leading: Icon(Icons.lock_rounded), title: Text('Локальное хранение'), subtitle: Text('Данные остаются на устройстве.')),
        const ListTile(leading: Icon(Icons.child_care_rounded), title: Text('Родительский контроль'), subtitle: Text('Здоровье и настроение требуют отдельного согласия.')),
        const ListTile(leading: Icon(Icons.visibility_rounded), title: Text('Explainable intelligence'), subtitle: Text('Каждый совет показывает причину.')),
      ]);
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.7)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]);
}

class _Hero extends StatelessWidget {
  const _Hero({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(34), gradient: const LinearGradient(colors: <Color>[Color(0xFF160E24), Color(0xFF6040C5), Color(0xFFD47F77)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const Text('FAMILYIQ 2.4 · PRIVATE LIFE OS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 42),
          const Text('Память, планы и развитие семьи — без подписки.', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.08, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text('$count записей хранятся локально и остаются под вашим контролем.', style: const TextStyle(color: Colors.white70, height: 1.4)),
        ]),
      );
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.controller});
  final LocalFamilyController controller;
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(child: _Metric(value: controller.memories.length, label: 'Память')),
        const SizedBox(width: 8),
        Expanded(child: _Metric(value: controller.events.length, label: 'События')),
        const SizedBox(width: 8),
        Expanded(child: _Metric(value: controller.projects.length, label: 'Проекты')),
      ]);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Column(children: <Widget>[Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 11))])));
}

class _Title extends StatelessWidget {
  const _Title(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)));
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});
  final LocalEntryRecord record;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(child: Icon(_icon(record.type))), title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(record.note.isEmpty ? record.type : record.note, maxLines: 2, overflow: TextOverflow.ellipsis)));
  IconData _icon(String type) => switch (type) { 'event' => Icons.event_rounded, 'project' => Icons.flag_rounded, 'tradition' => Icons.volunteer_activism_rounded, 'child' => Icons.child_care_rounded, _ => Icons.photo_library_rounded };
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.record});
  final LocalEntryRecord record;
  @override
  Widget build(BuildContext context) {
    final double progress = ((record.title.hashCode.abs() % 61) + 20) / 100;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(record.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text(record.note),
      const SizedBox(height: 14),
      LinearProgressIndicator(value: progress, borderRadius: BorderRadius.circular(99)),
      const SizedBox(height: 7),
      Text('${(progress * 100).round()}% · следующий шаг сохранён локально'),
    ])));
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final LocalInsight insight;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Row(children: <Widget>[Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Expanded(child: Text(insight.title, style: const TextStyle(fontWeight: FontWeight.w900)))]),
    const SizedBox(height: 8),
    Text(insight.reason),
    const SizedBox(height: 8),
    Text(insight.action, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
  ])));
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final MemorySummary summary;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Text('Лучшие моменты: ${summary.highlights.isEmpty ? 'пока нет' : summary.highlights.join(', ')}'),
    const SizedBox(height: 10),
    Text('Не завершено: ${summary.unfinished.isEmpty ? 'ничего' : summary.unfinished.join(', ')}'),
    const SizedBox(height: 10),
    Text('Следующий сезон: ${summary.nextSuggestions.isEmpty ? 'продолжайте текущий ритм' : summary.nextSuggestions.join(' · ')}'),
  ])));
}

class _Person extends StatelessWidget {
  const _Person({required this.initials, required this.name, required this.role});
  final String initials;
  final String name;
  final String role;
  @override
  Widget build(BuildContext context) => Column(children: <Widget>[CircleAvatar(radius: 31, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w900))), const SizedBox(height: 8), Text(name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(role, style: Theme.of(context).textTheme.bodySmall)]);
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Center(child: Text(text))));
}
