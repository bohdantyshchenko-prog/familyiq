import 'package:flutter/material.dart';

import '../../../core/data/local_entry_store.dart';
import '../../../core/state/family_store.dart';
import '../application/local_family_controller.dart';

class ProductionFamilyShell extends StatefulWidget {
  const ProductionFamilyShell({required this.familyId, super.key});

  final String familyId;

  @override
  State<ProductionFamilyShell> createState() => _ProductionFamilyShellState();
}

class _ProductionFamilyShellState extends State<ProductionFamilyShell> {
  late final LocalFamilyController controller;
  int selectedIndex = 0;

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
          if (controller.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (controller.errorCode != null) {
            return Scaffold(
              body: _StateView(
                icon: Icons.shield_outlined,
                title: 'Не удалось открыть локальные данные',
                action: FilledButton(onPressed: controller.initialize, child: const Text('Повторить')),
              ),
            );
          }
          final List<Widget> pages = <Widget>[
            _Home(controller: controller, onNavigate: _select),
            _History(controller: controller),
            _Calendar(controller: controller),
            _Projects(controller: controller),
            _Family(controller: controller),
            _Profile(controller: controller),
          ];
          return Scaffold(
            extendBody: true,
            body: SafeArea(bottom: false, child: IndexedStack(index: selectedIndex, children: pages)),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Добавить',
              onPressed: _create,
              child: const Icon(Icons.add_rounded),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: _select,
              destinations: const <NavigationDestination>[
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Главная'),
                NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history_rounded), label: 'История'),
                NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Календарь'),
                NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag_rounded), label: 'Проекты'),
                NavigationDestination(icon: Icon(Icons.family_restroom_outlined), selectedIcon: Icon(Icons.family_restroom_rounded), label: 'Семья'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Профиль'),
              ],
            ),
          );
        },
      );

  void _select(int value) => setState(() => selectedIndex = value);

  Future<void> _create() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController note = TextEditingController();
    String type = switch (selectedIndex) { 2 => 'event', 3 => 'project', _ => 'memory' };
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Новая запись', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment(value: 'memory', icon: Icon(Icons.photo_outlined), label: Text('Память')),
                  ButtonSegment(value: 'event', icon: Icon(Icons.event_outlined), label: Text('Событие')),
                  ButtonSegment(value: 'project', icon: Icon(Icons.flag_outlined), label: Text('Проект')),
                ],
                selected: <String>{type},
                onSelectionChanged: (Set<String> value) => setSheetState(() => type = value.first),
              ),
              const SizedBox(height: 16),
              TextField(controller: title, autofocus: true, maxLength: 160, decoration: const InputDecoration(labelText: 'Название')),
              TextField(controller: note, minLines: 3, maxLines: 6, maxLength: 20000, decoration: const InputDecoration(labelText: 'Описание')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  if (title.text.trim().isEmpty) return;
                  await controller.create(type: type, title: title.text, note: note.text);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Сохранить локально')),
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

class _Home extends StatelessWidget {
  const _Home({required this.controller, required this.onNavigate});
  final LocalFamilyController controller;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: <Widget>[
          _Hero(name: family.userName, family: family.familyName, count: controller.records.length),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Family Pulse', action: 'История', onTap: () => onNavigate(1)),
          const SizedBox(height: 10),
          _Pulse(controller: controller),
          const SizedBox(height: 22),
          _SectionTitle(title: 'Сегодня', action: 'Календарь', onTap: () => onNavigate(2)),
          const SizedBox(height: 10),
          _PremiumCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const _IconBadge(icon: Icons.auto_awesome_rounded),
              title: const Text('Совместное время', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(controller.insights.isEmpty ? 'Добавляйте семейные моменты — рекомендации станут точнее.' : controller.insights.first.reason),
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: 'Life Projects', action: 'Все проекты', onTap: () => onNavigate(3)),
          const SizedBox(height: 10),
          ...controller.projects.take(2).map((LocalEntryRecord item) => _EntryCard(record: item)),
          if (controller.projects.isEmpty) const _StateView(icon: Icons.flag_outlined, title: 'Создайте первый семейный проект'),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Family IQ'),
          const SizedBox(height: 10),
          _PremiumCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              const Row(children: <Widget>[Icon(Icons.psychology_alt_rounded), SizedBox(width: 8), Text('Локальный интеллект', style: TextStyle(fontWeight: FontWeight.w900))]),
              const SizedBox(height: 10),
              Text(controller.insights.isEmpty ? 'Все спокойно. Продолжайте сохранять важные моменты.' : controller.insights.first.action),
              const SizedBox(height: 8),
              const Text('Работает без облака и объясняет причину каждого совета.', style: TextStyle(fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.name, required this.family, required this.count});
  final String name;
  final String family;
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 330),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF26183E), Color(0xFF7047C8), Color(0xFF9A654F)]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
          Row(children: <Widget>[
            const CircleAvatar(radius: 25, child: Icon(Icons.family_restroom_rounded)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('Добро пожаловать', style: TextStyle(color: Colors.white70)), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900))])),
            const Icon(Icons.lock_rounded, color: Colors.white70),
          ]),
          const SizedBox(height: 48),
          const Text('Жизнь семьи,\nкоторую стоит помнить.', style: TextStyle(color: Colors.white, fontSize: 34, height: 1.05, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(family, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            const _Pill(icon: Icons.lock_outline_rounded, text: 'Private'),
            _Pill(icon: Icons.offline_bolt_rounded, text: '$count локально'),
            const _Pill(icon: Icons.visibility_outlined, text: 'Explainable'),
          ]),
        ]),
      );
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(child: _Metric(value: controller.memories.length, label: 'Память', icon: Icons.photo_library_outlined)),
        const SizedBox(width: 8),
        Expanded(child: _Metric(value: controller.events.length, label: 'События', icon: Icons.event_outlined)),
        const SizedBox(width: 8),
        Expanded(child: _Metric(value: controller.projects.length, label: 'Проекты', icon: Icons.flag_outlined)),
      ]);
}

class _History extends StatelessWidget {
  const _History({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'История',
        subtitle: 'Моменты, которые становятся наследием',
        child: Column(children: <Widget>[
          if (controller.onThisDay.isNotEmpty) ...<Widget>[
            const _SectionTitle(title: 'В этот день'),
            const SizedBox(height: 10),
            ...controller.onThisDay.map((LocalEntryRecord item) => _EntryCard(record: item)),
            const SizedBox(height: 16),
          ],
          if (controller.records.isEmpty) const _StateView(icon: Icons.history_rounded, title: 'История пока пуста'),
          ...controller.records.map((LocalEntryRecord item) => _EntryCard(record: item, onDelete: () => controller.delete(item.id))),
        ]),
      );
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'Календарь',
        subtitle: 'События и важные шаги',
        child: Column(children: <Widget>[
          _PremiumCard(child: _MonthGrid(now: DateTime.now())),
          const SizedBox(height: 16),
          if (controller.events.isEmpty) const _StateView(icon: Icons.event_busy_outlined, title: 'Добавьте первое событие'),
          ...controller.events.map((LocalEntryRecord item) => _EntryCard(record: item)),
        ]),
      );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final int days = DateUtils.getDaysInMonth(now.year, now.month);
    return Column(children: <Widget>[
      Text('${now.month.toString().padLeft(2, '0')}.${now.year}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
        itemCount: days,
        itemBuilder: (BuildContext context, int index) {
          final int day = index + 1;
          final bool today = day == now.day;
          return DecoratedBox(
            decoration: BoxDecoration(color: today ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('$day', style: TextStyle(fontWeight: today ? FontWeight.w900 : FontWeight.w500))),
          );
        },
      ),
    ]);
  }
}

class _Projects extends StatelessWidget {
  const _Projects({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'Life Projects',
        subtitle: 'Мечты, превращённые в действия',
        child: Column(children: <Widget>[
          if (controller.projects.isEmpty) const _StateView(icon: Icons.flag_outlined, title: 'Создайте семейный проект'),
          ...controller.projects.map((LocalEntryRecord item) => _EntryCard(record: item)),
          const SizedBox(height: 8),
          const _PremiumCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: _IconBadge(icon: Icons.auto_awesome_rounded), title: Text('Следующий шаг', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Разбейте большую цель на маленький шаг, который можно завершить на этой неделе.'))),
        ]),
      );
}

class _Family extends StatelessWidget {
  const _Family({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'Семья',
        subtitle: 'Люди, доверие и общее будущее',
        child: Column(children: <Widget>[
          const _PremiumCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[_Person(initials: 'БТ', name: 'Богдан'), _Person(initials: 'КВ', name: 'Карина'), _Person(initials: '∞', name: 'Будущее') ])),
          const SizedBox(height: 14),
          _Trust(icon: Icons.child_care_rounded, title: 'Детские профили', subtitle: '${controller.children.length} записей · отдельные правила приватности'),
          const _Trust(icon: Icons.lock_rounded, title: 'Trust Center', subtitle: 'Локальное хранение и контроль семьи'),
          const _Trust(icon: Icons.visibility_outlined, title: 'Explainable Intelligence', subtitle: 'Каждая рекомендация имеет понятную причину'),
        ]),
      );
}

class _Profile extends StatelessWidget {
  const _Profile({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return _Page(
      title: 'Профиль',
      subtitle: family.familyName,
      child: Column(children: <Widget>[
        _PremiumCard(child: Column(children: <Widget>[
          const CircleAvatar(radius: 42, child: Icon(Icons.person_rounded, size: 34)),
          const SizedBox(height: 12),
          Text(family.userName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          Text('${controller.records.length} записей · 100% локально'),
        ])),
        const SizedBox(height: 14),
        const _Trust(icon: Icons.language_rounded, title: 'Локализация', subtitle: 'Украинский, русский и английский'),
        const _Trust(icon: Icons.archive_outlined, title: 'Архив семьи', subtitle: 'Экспорт и восстановление подготовлены локально'),
        _Trust(icon: Icons.logout_rounded, title: 'Выйти', subtitle: 'Локальные записи сохранятся', onTap: family.signOut),
      ]),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async {},
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 130), children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle),
          const SizedBox(height: 20),
          child,
        ]),
      );
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.record, this.onDelete});
  final LocalEntryRecord record;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PremiumCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _IconBadge(icon: _entryIcon(record.type)),
            title: Text(record.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(record.note.isEmpty ? 'Без описания' : record.note, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: onDelete == null ? null : IconButton(tooltip: 'Удалить', onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded)),
          ),
        ),
      );
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .4)),
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: child,
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.icon});
  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _PremiumCard(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 7),
        Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        Text(label, maxLines: 1, style: Theme.of(context).textTheme.labelSmall),
      ]));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ]);
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, color: Colors.white70, size: 15), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
      );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Theme.of(context).colorScheme.primary));
}

class _Trust extends StatelessWidget {
  const _Trust({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PremiumCard(child: ListTile(contentPadding: EdgeInsets.zero, onTap: onTap, leading: _IconBadge(icon: icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(subtitle), trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded))),
      );
}

class _Person extends StatelessWidget {
  const _Person({required this.initials, required this.name});
  final String initials;
  final String name;

  @override
  Widget build(BuildContext context) => Flexible(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        CircleAvatar(radius: 31, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w900))),
        const SizedBox(height: 7),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]));
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, size: 42), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center), if (action != null) ...<Widget>[const SizedBox(height: 14), action!]])));
}

IconData _entryIcon(String type) => switch (type) {
      'event' => Icons.event_rounded,
      'project' => Icons.flag_rounded,
      'tradition' => Icons.favorite_rounded,
      'child' => Icons.child_care_rounded,
      _ => Icons.photo_library_rounded,
    };
