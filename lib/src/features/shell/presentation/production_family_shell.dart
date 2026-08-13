import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                subtitle: 'Резервная копия будет использована автоматически, если она доступна.',
                action: FilledButton(onPressed: controller.initialize, child: const Text('Повторить')),
              ),
            );
          }

          final List<Widget> pages = <Widget>[
            _Home(controller: controller, onNavigate: _select),
            _History(controller: controller),
            _Calendar(controller: controller),
            _Projects(controller: controller),
            _Family(controller: controller, onOpenProfile: () => _select(5)),
            _Profile(controller: controller),
          ];

          return Scaffold(
            extendBody: true,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(index: selectedIndex, children: pages),
            ),
            floatingActionButton: selectedIndex == 5
                ? null
                : FloatingActionButton(
                    tooltip: 'Добавить',
                    onPressed: _create,
                    child: const Icon(Icons.add_rounded),
                  ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex > 4 ? 4 : selectedIndex,
              onDestinationSelected: _select,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Главная',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: 'История',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Календарь',
                ),
                NavigationDestination(
                  icon: Icon(Icons.flag_outlined),
                  selectedIcon: Icon(Icons.flag_rounded),
                  label: 'Проекты',
                ),
                NavigationDestination(
                  icon: Icon(Icons.family_restroom_outlined),
                  selectedIcon: Icon(Icons.family_restroom_rounded),
                  label: 'Семья',
                ),
              ],
            ),
          );
        },
      );

  void _select(int value) => setState(() => selectedIndex = value);

  Future<void> _create() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController note = TextEditingController();
    String type = switch (selectedIndex) {
      2 => 'event',
      3 => 'project',
      _ => 'memory',
    };
    String? titleError;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Новая запись',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Сохраните момент, событие или семейную цель.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _TypeChip(
                    selected: type == 'memory',
                    icon: Icons.photo_outlined,
                    label: 'Память',
                    onTap: () => setSheetState(() => type = 'memory'),
                  ),
                  _TypeChip(
                    selected: type == 'event',
                    icon: Icons.event_outlined,
                    label: 'Событие',
                    onTap: () => setSheetState(() => type = 'event'),
                  ),
                  _TypeChip(
                    selected: type == 'project',
                    icon: Icons.flag_outlined,
                    label: 'Проект',
                    onTap: () => setSheetState(() => type = 'project'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                autofocus: true,
                maxLength: 160,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: 'Название', errorText: titleError),
                onChanged: (_) {
                  if (titleError != null) setSheetState(() => titleError = null);
                },
              ),
              TextField(
                controller: note,
                minLines: 3,
                maxLines: 6,
                maxLength: 20000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  if (title.text.trim().isEmpty) {
                    setSheetState(() => titleError = 'Добавьте название');
                    return;
                  }
                  await controller.create(type: type, title: title.text, note: note.text);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Сохранить'),
                ),
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
          _Hero(
            name: family.userName,
            family: family.familyName,
            initials: family.initials,
            count: controller.records.length,
            onProfile: () => onNavigate(5),
          ),
          const SizedBox(height: 22),
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
              subtitle: Text(
                controller.insights.isEmpty
                    ? 'Добавляйте семейные моменты — рекомендации станут точнее.'
                    : controller.insights.first.reason,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: 'Life Projects', action: 'Все проекты', onTap: () => onNavigate(3)),
          const SizedBox(height: 10),
          ...controller.projects.take(2).map((LocalEntryRecord item) => _EntryCard(record: item)),
          if (controller.projects.isEmpty)
            const _StateView(icon: Icons.flag_outlined, title: 'Создайте первый семейный проект'),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Family IQ'),
          const SizedBox(height: 10),
          _PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.psychology_alt_rounded),
                    SizedBox(width: 8),
                    Text('Локальный интеллект', style: TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  controller.insights.isEmpty
                      ? 'Все спокойно. Продолжайте сохранять важные моменты.'
                      : controller.insights.first.action,
                ),
                const SizedBox(height: 8),
                Text(
                  'Работает локально и показывает причину каждой рекомендации.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.name,
    required this.family,
    required this.initials,
    required this.count,
    required this.onProfile,
  });

  final String name;
  final String family;
  final String initials;
  final int count;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 320),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF211734), Color(0xFF6344B7), Color(0xFF9B6B55)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF5F3E9D).withValues(alpha: .22),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                InkWell(
                  onTap: onProfile,
                  borderRadius: BorderRadius.circular(99),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withValues(alpha: .14),
                    foregroundColor: Colors.white,
                    child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Добро пожаловать', style: TextStyle(color: Colors.white70)),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Профиль',
                  onPressed: onProfile,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: .16),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 46),
            const Text(
              'Жизнь семьи,\nкоторую стоит помнить.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(family, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                const _Pill(icon: Icons.lock_outline_rounded, text: 'Приватно'),
                _Pill(icon: Icons.offline_bolt_rounded, text: '$count записей'),
                const _Pill(icon: Icons.visibility_outlined, text: 'Понятные советы'),
              ],
            ),
          ],
        ),
      );
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: _Metric(
              value: controller.memories.length,
              label: 'Память',
              icon: Icons.photo_library_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Metric(
              value: controller.events.length,
              label: 'События',
              icon: Icons.event_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Metric(
              value: controller.projects.length,
              label: 'Проекты',
              icon: Icons.flag_outlined,
            ),
          ),
        ],
      );
}

class _History extends StatelessWidget {
  const _History({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'История',
        subtitle: 'Моменты, которые становятся наследием',
        child: Column(
          children: <Widget>[
            if (controller.onThisDay.isNotEmpty) ...<Widget>[
              const _SectionTitle(title: 'В этот день'),
              const SizedBox(height: 10),
              ...controller.onThisDay.map((LocalEntryRecord item) => _EntryCard(record: item)),
              const SizedBox(height: 16),
            ],
            if (controller.records.isEmpty)
              const _StateView(icon: Icons.history_rounded, title: 'История пока пуста'),
            ...controller.records.map(
              (LocalEntryRecord item) => _EntryCard(
                record: item,
                onDelete: () => _confirmDelete(context, controller, item),
              ),
            ),
          ],
        ),
      );
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'Календарь',
        subtitle: 'События и важные шаги',
        child: Column(
          children: <Widget>[
            _PremiumCard(child: _MonthGrid(now: DateTime.now())),
            const SizedBox(height: 16),
            if (controller.events.isEmpty)
              const _StateView(icon: Icons.event_busy_outlined, title: 'Добавьте первое событие'),
            ...controller.events.map((LocalEntryRecord item) => _EntryCard(record: item)),
          ],
        ),
      );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.now});

  final DateTime now;

  static const List<String> weekdays = <String>['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const List<String> months = <String>[
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  @override
  Widget build(BuildContext context) {
    final int days = DateUtils.getDaysInMonth(now.year, now.month);
    final int offset = DateTime(now.year, now.month, 1).weekday - DateTime.monday;
    final int totalCells = ((offset + days + 6) ~/ 7) * 7;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${months[now.month - 1]} ${now.year}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Row(
          children: weekdays
              .map(
                (String value) => Expanded(
                  child: Center(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: totalCells,
          itemBuilder: (BuildContext context, int index) {
            final int day = index - offset + 1;
            if (day < 1 || day > days) return const SizedBox.shrink();
            final bool today = day == now.day;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: today ? colors.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: today ? colors.onPrimaryContainer : colors.onSurface,
                    fontWeight: today ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Projects extends StatelessWidget {
  const _Projects({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _Page(
        title: 'Life Projects',
        subtitle: 'Мечты, превращённые в действия',
        child: Column(
          children: <Widget>[
            if (controller.projects.isEmpty)
              const _StateView(icon: Icons.flag_outlined, title: 'Создайте семейный проект'),
            ...controller.projects.map((LocalEntryRecord item) => _EntryCard(record: item)),
            const SizedBox(height: 8),
            const _PremiumCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _IconBadge(icon: Icons.auto_awesome_rounded),
                title: Text('Следующий шаг', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  'Разбейте большую цель на маленький шаг, который можно завершить на этой неделе.',
                ),
              ),
            ),
          ],
        ),
      );
}

class _Family extends StatelessWidget {
  const _Family({required this.controller, required this.onOpenProfile});

  final LocalFamilyController controller;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return _Page(
      title: 'Семья',
      subtitle: 'Люди, доверие и общее будущее',
      child: Column(
        children: <Widget>[
          _PremiumCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _Person(initials: family.initials, name: family.userName),
                const _Person(initials: '∞', name: 'Будущее'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Trust(
            icon: Icons.person_outline_rounded,
            title: 'Мой профиль',
            subtitle: family.email.isEmpty ? family.familyName : family.email,
            onTap: onOpenProfile,
          ),
          _Trust(
            icon: Icons.child_care_rounded,
            title: 'Детские профили',
            subtitle: '${controller.children.length} записей · отдельные правила приватности',
          ),
          const _Trust(
            icon: Icons.lock_rounded,
            title: 'Trust Center',
            subtitle: 'Локальные данные отделены от защищённого PIN',
          ),
          const _Trust(
            icon: Icons.visibility_outlined,
            title: 'Explainable Intelligence',
            subtitle: 'Каждая рекомендация имеет понятную причину',
          ),
        ],
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    final String memberSince = family.memberSince == null
        ? 'Локальный профиль'
        : 'С ${family.memberSince!.toLocal().year} года';

    return _Page(
      title: 'Профиль',
      subtitle: family.familyName,
      child: Column(
        children: <Widget>[
          _PremiumCard(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 42,
                  child: Text(
                    family.initials,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  family.userName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                if (family.email.isNotEmpty)
                  Text(
                    family.email,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${controller.records.length} записей · $memberSince',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Trust(
            icon: Icons.edit_outlined,
            title: 'Профиль и семья',
            subtitle: 'Имя и название семейного пространства',
            onTap: () => _editProfile(context, family),
          ),
          _Trust(
            icon: Icons.password_rounded,
            title: 'Безопасность',
            subtitle: 'Изменить 6-значный PIN устройства',
            onTap: () => _changePin(context, family),
          ),
          const _Trust(
            icon: Icons.storage_rounded,
            title: 'Данные',
            subtitle: 'Локальное хранилище с версионированием и резервной копией',
          ),
          const _Trust(
            icon: Icons.language_rounded,
            title: 'Локализация',
            subtitle: 'Украинский, русский и английский',
          ),
          _Trust(
            icon: Icons.logout_rounded,
            title: 'Выйти',
            subtitle: 'Локальные записи останутся на устройстве',
            onTap: family.signOut,
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          child,
        ],
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
            title: Text(
              record.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                record.note.isEmpty ? 'Без описания' : record.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: onDelete == null
                ? null
                : IconButton(
                    tooltip: 'Удалить',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
          ),
        ),
      );
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .5)),
        boxShadow: theme.brightness == Brightness.light
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF2B163F).withValues(alpha: .055),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: child,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.icon});

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _PremiumCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 7),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(label, maxLines: 1, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
        ],
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Colors.white70, size: 15),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
      );
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
        child: _PremiumCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onTap,
            leading: _IconBadge(icon: icon),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(subtitle),
            trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
          ),
        ),
      );
}

class _Person extends StatelessWidget {
  const _Person({required this.initials, required this.name});

  final String initials;
  final String name;

  @override
  Widget build(BuildContext context) => Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 31,
              child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 7),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: Icon(icon, size: 18),
        label: Text(label),
      );
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.title, this.subtitle, this.action});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 42),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
              if (action != null) ...<Widget>[const SizedBox(height: 14), action!],
            ],
          ),
        ),
      );
}

Future<void> _confirmDelete(
  BuildContext context,
  LocalFamilyController controller,
  LocalEntryRecord item,
) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Удалить запись?'),
      content: Text('«${item.title}» будет скрыта из семейной истории.'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  if (confirmed == true) await controller.delete(item.id);
}

Future<void> _editProfile(BuildContext context, FamilyStore family) async {
  final TextEditingController name = TextEditingController(text: family.userName);
  final TextEditingController familyName = TextEditingController(text: family.familyName);
  String? error;

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
        title: const Text('Профиль и семья'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Ваше имя'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: familyName,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Название семьи'),
              ),
              if (error != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final String? result = await family.updateProfile(name: name.text, family: familyName.text);
              if (!dialogContext.mounted) return;
              if (result != null) {
                setDialogState(() => error = 'Проверьте имя и название семьи.');
                return;
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    ),
  );

  name.dispose();
  familyName.dispose();
}

Future<void> _changePin(BuildContext context, FamilyStore family) async {
  final TextEditingController current = TextEditingController();
  final TextEditingController next = TextEditingController();
  String? error;

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
        title: const Text('Изменить PIN'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: current,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(labelText: 'Текущий PIN', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: next,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(labelText: 'Новый PIN', counterText: ''),
              ),
              if (error != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final String? result = await family.changePin(currentPin: current.text, newPin: next.text);
              if (!dialogContext.mounted) return;
              if (result != null) {
                setDialogState(() {
                  error = switch (result) {
                    'invalid_pin' => 'Новый PIN должен содержать 6 цифр.',
                    'same_pin' => 'Новый PIN должен отличаться от текущего.',
                    _ => 'Текущий PIN указан неверно.',
                  };
                });
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN обновлён')),
              );
            },
            child: const Text('Обновить'),
          ),
        ],
      ),
    ),
  );

  current.dispose();
  next.dispose();
}

IconData _entryIcon(String type) => switch (type) {
      'event' => Icons.event_rounded,
      'project' => Icons.flag_rounded,
      'tradition' => Icons.favorite_rounded,
      'child' => Icons.child_care_rounded,
      _ => Icons.photo_library_rounded,
    };
