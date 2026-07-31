import 'package:flutter/material.dart';

import '../../../core/data/local_entry_store.dart';
import '../../../core/state/family_store.dart';
import '../application/local_family_controller.dart';

class ConnectedFamilyShell extends StatefulWidget {
  const ConnectedFamilyShell({required this.familyId, super.key});
  final String familyId;

  @override
  State<ConnectedFamilyShell> createState() => _ConnectedFamilyShellState();
}

class _ConnectedFamilyShellState extends State<ConnectedFamilyShell> {
  late final LocalFamilyController controller;
  int tab = 0;

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
          return Scaffold(
            extendBody: true,
            body: SafeArea(
              child: IndexedStack(index: tab, children: <Widget>[
                _Dashboard(controller: controller),
                _Records(title: 'Семейная история', records: controller.memories, controller: controller),
                _Records(title: 'Семейные проекты', records: controller.projects, controller: controller),
                _Records(title: 'События', records: controller.events, controller: controller),
                _Account(controller: controller),
              ]),
            ),
            floatingActionButton: FloatingActionButton(onPressed: _openCreate, child: const Icon(Icons.add_rounded)),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (int value) => setState(() => tab = value),
              destinations: const <NavigationDestination>[
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
                NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'История'),
                NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag_rounded), label: 'Проекты'),
                NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event_rounded), label: 'События'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль'),
              ],
            ),
          );
        },
      );

  Future<void> _openCreate() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController note = TextEditingController();
    String type = <String>['memory', 'event', 'project'][tab == 1 ? 0 : tab == 2 ? 2 : tab == 3 ? 1 : 0];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Text('Создать запись', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment(value: 'memory', label: Text('Память')),
                ButtonSegment(value: 'event', label: Text('Событие')),
                ButtonSegment(value: 'project', label: Text('Проект')),
              ],
              selected: <String>{type},
              onSelectionChanged: (Set<String> value) => setSheetState(() => type = value.first),
            ),
            const SizedBox(height: 14),
            TextField(controller: title, maxLength: 160, autofocus: true, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: note, maxLines: 4, decoration: const InputDecoration(labelText: 'Описание')),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                await controller.create(type: type, title: title.text, note: note.text);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Сохранить локально'),
            ),
          ]),
        ),
      ),
    );
    title.dispose();
    note.dispose();
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
        Text('Добрый вечер, ${family.userName}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        Text(family.familyName, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: <Color>[Color(0xFF25143D), Color(0xFF7658E8), Color(0xFFD68A79)])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            const Text('FAMILYIQ · LOCAL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 28),
            const Text('Полезное приложение без подписки и backend.', style: TextStyle(color: Colors.white, fontSize: 28, height: 1.08, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('${controller.records.length} записей защищены локальным хранением.', style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 22),
        Row(children: <Widget>[
          Expanded(child: _Metric(value: controller.memories.length, label: 'Память', icon: Icons.photo_library_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _Metric(value: controller.events.length, label: 'События', icon: Icons.event_rounded)),
          const SizedBox(width: 10),
          Expanded(child: _Metric(value: controller.projects.length, label: 'Проекты', icon: Icons.flag_rounded)),
        ]),
        const SizedBox(height: 22),
        Text('Последние записи', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        ...controller.records.take(4).map((LocalEntryRecord record) => _RecordCard(record: record)),
      ]),
    );
  }
}

class _Records extends StatelessWidget {
  const _Records({required this.title, required this.records, required this.controller});
  final String title;
  final List<LocalEntryRecord> records;
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${records.length} локальных записей', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          if (records.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('Здесь пока пусто. Нажмите +, чтобы создать запись.'))),
          ...records.map((LocalEntryRecord record) => Dismissible(
                key: ValueKey<String>(record.id),
                direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), color: Theme.of(context).colorScheme.errorContainer, child: const Icon(Icons.delete_outline_rounded)),
                confirmDismiss: (_) => showDialog<bool>(context: context, builder: (BuildContext context) => AlertDialog(title: const Text('Удалить запись?'), content: const Text('Она будет мягко удалена и останется совместимой с будущей синхронизацией.'), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить'))])),
                onDismissed: (_) => controller.delete(record.id),
                child: _RecordCard(record: record),
              )),
        ]),
      );
}

class _Account extends StatelessWidget {
  const _Account({required this.controller});
  final LocalFamilyController controller;
  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: <Widget>[
      Text('Профиль', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: <Widget>[
        const CircleAvatar(radius: 42, child: Text('БТ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
        const SizedBox(height: 12),
        Text(family.userName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        Text(family.familyName),
        const SizedBox(height: 8),
        Text('${controller.records.length} записей на устройстве'),
      ]))),
      const SizedBox(height: 14),
      const ListTile(leading: Icon(Icons.cloud_off_rounded), title: Text('Бесплатный локальный режим'), subtitle: Text('Supabase и OpenAI не требуются')),
      ListTile(leading: const Icon(Icons.refresh_rounded), title: const Text('Обновить'), onTap: controller.refresh),
      ListTile(leading: const Icon(Icons.logout_rounded), title: const Text('Выйти'), onTap: family.signOut),
    ]);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.icon});
  final int value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6), child: Column(children: <Widget>[Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 8), Text('$value', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 11))])));
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});
  final LocalEntryRecord record;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: CircleAvatar(child: Icon(_icon(record.type))),
          title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(record.note.isEmpty ? 'Без описания' : record.note, maxLines: 2, overflow: TextOverflow.ellipsis)),
          trailing: Text('${record.updatedAt.day}.${record.updatedAt.month}', style: Theme.of(context).textTheme.labelSmall),
        ),
      );

  IconData _icon(String type) => switch (type) {
        'event' => Icons.event_rounded,
        'project' => Icons.flag_rounded,
        'tradition' => Icons.favorite_rounded,
        _ => Icons.photo_library_rounded,
      };
}
