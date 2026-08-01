import 'package:flutter/material.dart';

import '../../../core/data/local_entry_store.dart';
import '../../../core/state/family_store.dart';
import '../application/local_family_controller.dart';

class FamilyIqWorldShell extends StatefulWidget {
  const FamilyIqWorldShell({required this.familyId, super.key});

  final String familyId;

  @override
  State<FamilyIqWorldShell> createState() => _FamilyIqWorldShellState();
}

class _FamilyIqWorldShellState extends State<FamilyIqWorldShell> {
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        if (controller.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF070914),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final List<Widget> pages = <Widget>[
          _HomePage(controller: controller, navigate: _selectPage),
          _RecordsPage(
            title: 'Семейная история',
            subtitle: 'Дни, которые становятся наследием',
            records: controller.records,
            controller: controller,
          ),
          _CalendarPage(controller: controller),
          _ProjectsPage(controller: controller),
          const _FamilyPage(),
          _ProfilePage(controller: controller),
        ];

        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFF070914),
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
          floatingActionButton: _CreateButton(onPressed: _openCreate),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _WorldNavigation(
            index: selectedIndex,
            onSelected: _selectPage,
          ),
        );
      },
    );
  }

  void _selectPage(int index) => setState(() => selectedIndex = index);

  Future<void> _openCreate() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    String type = 'memory';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF111421),
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Добавить в FamilyIQ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _TypeChip(
                          label: 'Память',
                          value: 'memory',
                          selected: type,
                          icon: Icons.photo_library_rounded,
                          onTap: (String value) =>
                              setModalState(() => type = value),
                        ),
                        _TypeChip(
                          label: 'Событие',
                          value: 'event',
                          selected: type,
                          icon: Icons.calendar_month_rounded,
                          onTap: (String value) =>
                              setModalState(() => type = value),
                        ),
                        _TypeChip(
                          label: 'Проект',
                          value: 'project',
                          selected: type,
                          icon: Icons.folder_rounded,
                          onTap: (String value) =>
                              setModalState(() => type = value),
                        ),
                        _TypeChip(
                          label: 'Традиция',
                          value: 'tradition',
                          selected: type,
                          icon: Icons.auto_awesome_rounded,
                          onTap: (String value) =>
                              setModalState(() => type = value),
                        ),
                        _TypeChip(
                          label: 'Ребёнок',
                          value: 'child',
                          selected: type,
                          icon: Icons.child_care_rounded,
                          onTap: (String value) =>
                              setModalState(() => type = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      maxLength: 160,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Название'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      minLines: 3,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () async {
                        final String title = titleController.text.trim();
                        if (title.isEmpty) return;
                        await controller.create(
                          type: type,
                          title: title,
                          note: noteController.text.trim(),
                        );
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text('Сохранить локально'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    noteController.dispose();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.controller, required this.navigate});

  final LocalFamilyController controller;
  final ValueChanged<int> navigate;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _Hero(
              name: family.userName,
              recordCount: controller.records.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 132),
            sliver: SliverList.list(
              children: <Widget>[
                _Pulse(controller: controller),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: 'Сегодня',
                  action: 'Смотреть все',
                  onTap: () => navigate(1),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 206,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      const _TodayCard(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Рекомендация дня',
                        title: 'Вечерняя прогулка',
                        subtitle: 'Лучшее время — 19:45',
                        colors: <Color>[Color(0xFF402461), Color(0xFF171526)],
                      ),
                      _TodayCard(
                        icon: Icons.cake_rounded,
                        label: 'Ближайшее событие',
                        title: controller.events.isEmpty
                            ? 'Добавьте событие'
                            : controller.events.first.title,
                        subtitle: 'Семейный календарь',
                        colors: const <Color>[
                          Color(0xFF22335C),
                          Color(0xFF131725),
                        ],
                      ),
                      _TodayCard(
                        icon: Icons.home_work_rounded,
                        label: 'Активный проект',
                        title: controller.projects.isEmpty
                            ? 'Дом мечты'
                            : controller.projects.first.title,
                        subtitle: 'Следующий шаг готов',
                        colors: const <Color>[
                          Color(0xFF1C4B3A),
                          Color(0xFF111A19),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: 'Популярные проекты',
                  action: 'Все проекты',
                  onTap: () => navigate(3),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 205,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: controller.projects.isEmpty
                        ? const <Widget>[
                            _ProjectCard(title: 'Дом мечты', progress: .65),
                            _ProjectCard(title: 'Отпуск 2026', progress: .47),
                            _ProjectCard(title: 'Семейная книга', progress: .30),
                          ]
                        : controller.projects
                            .take(4)
                            .map(
                              (LocalEntryRecord record) => _ProjectCard(
                                title: record.title,
                                progress: _progress(record),
                              ),
                            )
                            .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget iq = _IntelligenceCard(controller: controller);
                    final Widget recent = _RecentCard(controller: controller);
                    if (constraints.maxWidth > 760) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: iq),
                          const SizedBox(width: 14),
                          Expanded(child: recent),
                        ],
                      );
                    }
                    return Column(
                      children: <Widget>[
                        iq,
                        const SizedBox(height: 14),
                        recent,
                      ],
                    );
                  },
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
  const _Hero({required this.name, required this.recordCount});

  final String name;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 455,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF34223A),
            Color(0xFF745040),
            Color(0xFF15131D),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            right: -90,
            top: 30,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB46A).withValues(alpha: .18),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x44FF9A55), blurRadius: 90),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, Color(0xFF070914)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 29,
                      backgroundColor: Color(0xFF8B63FF),
                      child: Text(
                        'БТ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Добрый вечер,',
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          Text(
                            '$name 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.black38,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Важны не дни в жизни,\nа жизнь в днях.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1.02,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Сделаем этот день особенным ✨',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    const _GlassPill(icon: Icons.lock_rounded, text: 'Private'),
                    _GlassPill(
                      icon: Icons.offline_bolt_rounded,
                      text: '$recordCount локально',
                    ),
                    const _GlassPill(icon: Icons.sunny, text: '20° Житомир'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              _IconBox(
                icon: Icons.monitor_heart_rounded,
                color: Color(0xFF8D5CFF),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Family Pulse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Tag(text: 'За неделю'),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<_PulseMetric> metrics = <_PulseMetric>[
                const _PulseMetric(
                  value: 92,
                  label: 'Связь',
                  icon: Icons.favorite_rounded,
                  color: Color(0xFFAA63FF),
                ),
                _PulseMetric(
                  value: controller.memories.length,
                  label: 'Воспоминания',
                  icon: Icons.photo_rounded,
                  color: const Color(0xFF617CFF),
                ),
                _PulseMetric(
                  value: controller.projects.length,
                  label: 'Проекты',
                  icon: Icons.home_rounded,
                  color: const Color(0xFF58D092),
                ),
                _PulseMetric(
                  value: controller.events.length,
                  label: 'События',
                  icon: Icons.event_rounded,
                  color: const Color(0xFFFFB45B),
                ),
              ];

              if (constraints.maxWidth > 700) {
                return Row(
                  children: metrics
                      .map((Widget metric) => Expanded(child: metric))
                      .toList(growable: false),
                );
              }

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: metrics,
              );
            },
          ),
          const Divider(color: Colors.white12, height: 28),
          const Row(
            children: <Widget>[
              Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 17),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Все данные хранятся локально на вашем устройстве',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({
    required this.title,
    required this.subtitle,
    required this.records,
    required this.controller,
  });

  final String title;
  final String subtitle;
  final List<LocalEntryRecord> records;
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _StandardPage(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: <Widget>[
          const _FeatureBanner(
            title: 'Ваше лето',
            subtitle:
                'Лучшие моменты, незавершённые планы и идеи на следующий сезон',
            icon: Icons.wb_sunny_rounded,
          ),
          const SizedBox(height: 18),
          if (records.isEmpty)
            const _EmptyState(
              icon: Icons.auto_stories_rounded,
              title: 'Сохраните первый семейный момент',
            ),
          ...records.map(
            (LocalEntryRecord record) => _RecordCard(
              record: record,
              onDelete: () => controller.delete(record.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarPage extends StatelessWidget {
  const _CalendarPage({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _StandardPage(
      title: 'Календарь семьи',
      subtitle: 'События, дни рождения и важные шаги',
      child: Column(
        children: <Widget>[
          _GlassCard(
            child: Column(
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.chevron_left_rounded, color: Colors.white),
                    Text(
                      'Август 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 18),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 7,
                  children: List<Widget>.generate(35, (int index) {
                    final bool selected = index == 0;
                    return Center(
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF7448F5)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (controller.events.isEmpty)
            const _EmptyState(
              icon: Icons.event_available_rounded,
              title: 'Добавьте первое семейное событие',
            ),
          ...controller.events.map(
            (LocalEntryRecord record) => _RecordCard(
              record: record,
              onDelete: () => controller.delete(record.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsPage extends StatelessWidget {
  const _ProjectsPage({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _StandardPage(
      title: 'Life Projects',
      subtitle: 'Большие мечты, превращённые в следующие шаги',
      child: Column(
        children: <Widget>[
          const _FeatureBanner(
            title: 'Дом мечты',
            subtitle:
                'Бюджет, район, документы, этапы и накопительная цель',
            icon: Icons.home_work_rounded,
          ),
          const SizedBox(height: 18),
          if (controller.projects.isEmpty)
            const _EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'Создайте первый семейный проект',
            ),
          ...controller.projects.map(
            (LocalEntryRecord record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProjectCard(
                title: record.title,
                progress: _progress(record),
                wide: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyPage extends StatelessWidget {
  const _FamilyPage();

  @override
  Widget build(BuildContext context) {
    return const _StandardPage(
      title: 'Семейный круг',
      subtitle: 'Люди, доверие и общее будущее',
      child: Column(
        children: <Widget>[
          _FamilyGraph(),
          SizedBox(height: 18),
          _TrustTile(
            icon: Icons.lock_rounded,
            title: 'Приватность по умолчанию',
            subtitle: 'Каждая чувствительная запись получает уровень доступа.',
          ),
          _TrustTile(
            icon: Icons.child_care_rounded,
            title: 'Безопасность детей',
            subtitle:
                'Здоровье и настроение не анализируются без согласия родителей.',
          ),
          _TrustTile(
            icon: Icons.visibility_rounded,
            title: 'Explainable Intelligence',
            subtitle: 'Каждый совет показывает причину и использованные данные.',
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return _StandardPage(
      title: 'Профиль',
      subtitle: family.familyName,
      child: Column(
        children: <Widget>[
          _GlassCard(
            child: Column(
              children: <Widget>[
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFF7046EE),
                  child: Text(
                    'БТ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  family.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${controller.records.length} записей · 100% локально',
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _TrustTile(
            icon: Icons.palette_rounded,
            title: 'Оформление',
            subtitle: 'Премиальная тёмная тема FamilyIQ',
          ),
          const _TrustTile(
            icon: Icons.language_rounded,
            title: 'Язык',
            subtitle: 'Украинский, русский и английский',
          ),
          const _TrustTile(
            icon: Icons.download_rounded,
            title: 'Архив семьи',
            subtitle: 'Локальный JSON-экспорт и восстановление',
          ),
          _TrustTile(
            icon: Icons.logout_rounded,
            title: 'Выйти',
            subtitle: 'Локальные данные сохранятся',
            onTap: family.signOut,
          ),
        ],
      ),
    );
  }
}

class _StandardPage extends StatelessWidget {
  const _StandardPage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 132),
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 15),
        ),
        const SizedBox(height: 22),
        child,
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151827),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white60)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ((value % 10) + 1) / 10,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: const Color(0xFF9B75FF), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(subtitle, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white12,
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.progress,
    this.wide = false,
  });

  final String title;
  final double progress;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : 205,
      margin: EdgeInsets.only(right: wide ? 0 : 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF151827),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: wide ? 100 : 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF6244B9), Color(0xFF263251)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(Icons.home_work_rounded, color: Colors.white70, size: 38),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF8057FF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntelligenceCard extends StatelessWidget {
  const _IntelligenceCard({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFC16B)),
              SizedBox(width: 8),
              Text(
                'Family IQ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      Colors.white,
                      Color(0xFF9C7CFF),
                      Color(0xFF432080),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Color(0x886A42D7), blurRadius: 34),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Лучшее время для прогулки — 19:45',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.memories.isEmpty
                          ? 'Причина: на этой неделе ещё нет общего воспоминания.'
                          : 'Причина: последняя совместная прогулка была давно.',
                      style: const TextStyle(color: Colors.white60, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Последние моменты',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (controller.records.isEmpty)
            const Text('Пока нет записей', style: TextStyle(color: Colors.white54)),
          ...controller.records.take(3).map(
                (LocalEntryRecord record) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      _IconBox(
                        icon: _iconFor(record.type),
                        color: _colorFor(record.type),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              record.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              record.note.isEmpty ? 'Семейная запись' : record.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white45,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onDelete});

  final LocalEntryRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF151827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: <Widget>[
          _IconBox(icon: _iconFor(record.type), color: _colorFor(record.type)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  record.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  record.note.isEmpty ? 'FamilyIQ' : record.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white50, height: 1.35),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Удалить',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF5D39B5), Color(0xFF26203B)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 42),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: _GlassCard(
          child: Row(
            children: <Widget>[
              _IconBox(icon: icon, color: const Color(0xFF8B63FF)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white50, height: 1.35),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyGraph extends StatelessWidget {
  const _FamilyGraph();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: SizedBox(
        height: 330,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: <Widget>[
                const Positioned(
                  left: 22,
                  top: 40,
                  child: _FamilyNode(initials: 'БТ', name: 'Богдан', role: 'Владелец'),
                ),
                const Positioned(
                  right: 22,
                  top: 40,
                  child: _FamilyNode(initials: 'КВ', name: 'Карина', role: 'Партнёр'),
                ),
                Positioned(
                  left: constraints.maxWidth / 2 - 48,
                  bottom: 24,
                  child: const _FamilyNode(
                    initials: '∞',
                    name: 'Будущее',
                    role: 'Капсула',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FamilyNode extends StatelessWidget {
  const _FamilyNode({
    required this.initials,
    required this.name,
    required this.role,
  });

  final String initials;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 41,
          backgroundColor: const Color(0xFF7149EF),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(role, style: const TextStyle(color: Colors.white45, fontSize: 12)),
      ],
    );
  }
}

class _WorldNavigation extends StatelessWidget {
  const _WorldNavigation({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xF2141624),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x88000000), blurRadius: 30),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Главная',
              value: 0,
              index: index,
              onTap: onSelected,
            ),
            _NavItem(
              icon: Icons.history_rounded,
              label: 'История',
              value: 1,
              index: index,
              onTap: onSelected,
            ),
            _NavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Календарь',
              value: 2,
              index: index,
              onTap: onSelected,
            ),
            const SizedBox(width: 58),
            _NavItem(
              icon: Icons.folder_rounded,
              label: 'Проекты',
              value: 3,
              index: index,
              onTap: onSelected,
            ),
            _NavItem(
              icon: Icons.family_restroom_rounded,
              label: 'Семья',
              value: 4,
              index: index,
              onTap: onSelected,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Профиль',
              value: 5,
              index: index,
              onTap: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.index,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == index;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: selected ? 1.13 : 1,
                child: Icon(
                  icon,
                  color: selected ? const Color(0xFF8B63FF) : Colors.white38,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF9B75FF) : Colors.white38,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Добавить семейную запись',
      child: Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF8F63FF), Color(0xFF5A2CD1)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x996F3FE8),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: IconButton(
          tooltip: 'Добавить',
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selected;
  final IconData icon;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected == value,
      onSelected: (_) => onTap(value),
      avatar: Icon(icon, size: 17),
      label: Text(label),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white60, size: 15),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        children: <Widget>[
          Icon(icon, color: Colors.white38, size: 42),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

double _progress(LocalEntryRecord record) {
  final int seed = record.id.codeUnits.fold<int>(0, (int a, int b) => a + b);
  return .3 + (seed % 55) / 100;
}

IconData _iconFor(String type) {
  return switch (type) {
    'memory' => Icons.photo_rounded,
    'event' => Icons.calendar_month_rounded,
    'project' => Icons.folder_rounded,
    'tradition' => Icons.auto_awesome_rounded,
    'child' => Icons.child_care_rounded,
    _ => Icons.notes_rounded,
  };
}

Color _colorFor(String type) {
  return switch (type) {
    'memory' => const Color(0xFF8B63FF),
    'event' => const Color(0xFF557BFF),
    'project' => const Color(0xFF54D394),
    'tradition' => const Color(0xFFFFBE65),
    'child' => const Color(0xFFFF7FA0),
    _ => const Color(0xFF9A9FB3),
  };
}
