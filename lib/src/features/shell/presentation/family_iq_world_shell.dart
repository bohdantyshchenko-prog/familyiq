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
            backgroundColor: _Palette.canvas,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final List<Widget> pages = <Widget>[
          _HomePage(controller: controller, navigate: _selectPage),
          _RecordsPage(controller: controller),
          _CalendarPage(controller: controller),
          _ProjectsPage(controller: controller),
          const _FamilyPage(),
          _ProfilePage(controller: controller),
        ];

        return Scaffold(
          extendBody: true,
          backgroundColor: _Palette.canvas,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
          floatingActionButton: Semantics(
            button: true,
            label: 'Добавить семейную запись',
            child: _CreateButton(onPressed: _openCreate),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _PremiumNavigation(
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
    String selectedType = 'memory';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: _Palette.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Новая семейная запись',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _TypeChip('Память', 'memory', Icons.photo_library_rounded),
                        _TypeChip('Событие', 'event', Icons.event_rounded),
                        _TypeChip('Проект', 'project', Icons.folder_rounded),
                        _TypeChip('Традиция', 'tradition', Icons.auto_awesome_rounded),
                        _TypeChip('Ребёнок', 'child', Icons.child_care_rounded),
                      ].map((Widget value) {
                        final _TypeChip chip = value as _TypeChip;
                        return ChoiceChip(
                          selected: selectedType == chip.value,
                          avatar: Icon(chip.icon, size: 18),
                          label: Text(chip.label),
                          onSelected: (_) => setModalState(() => selectedType = chip.value),
                        );
                      }).toList(growable: false),
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
                        if (titleController.text.trim().isEmpty) {
                          return;
                        }
                        await controller.create(
                          type: selectedType,
                          title: titleController.text,
                          note: noteController.text,
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
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
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _Hero(
              name: family.userName,
              familyName: family.familyName,
              recordCount: controller.records.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 126),
            sliver: SliverList.list(
              children: <Widget>[
                _PulseCard(controller: controller),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Сегодня',
                  action: 'Смотреть все',
                  onPressed: () => navigate(1),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 205,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      const _TodayCard(
                        icon: Icons.auto_awesome_rounded,
                        eyebrow: 'Рекомендация дня',
                        title: 'Семейная прогулка',
                        subtitle: 'Спокойное окно — 19:45',
                        colors: <Color>[_Palette.violet, Color(0xFF191323)],
                      ),
                      _TodayCard(
                        icon: Icons.cake_rounded,
                        eyebrow: 'Ближайшее событие',
                        title: controller.events.isEmpty
                            ? 'Добавьте событие'
                            : controller.events.first.title,
                        subtitle: 'Семейный календарь',
                        colors: const <Color>[Color(0xFF27416B), Color(0xFF111725)],
                      ),
                      _TodayCard(
                        icon: Icons.home_work_rounded,
                        eyebrow: 'Активный проект',
                        title: controller.projects.isEmpty
                            ? 'Дом мечты'
                            : controller.projects.first.title,
                        subtitle: 'Следующий шаг готов',
                        colors: const <Color>[Color(0xFF245443), Color(0xFF101A18)],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Живые проекты',
                  action: 'Все проекты',
                  onPressed: () => navigate(3),
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
                                progress: _progressFor(record),
                              ),
                            )
                            .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget intelligence = _IntelligenceCard(controller: controller);
                    final Widget recent = _RecentCard(controller: controller);
                    if (constraints.maxWidth >= 760) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: intelligence),
                          const SizedBox(width: 14),
                          Expanded(child: recent),
                        ],
                      );
                    }
                    return Column(
                      children: <Widget>[
                        intelligence,
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
  const _Hero({required this.name, required this.familyName, required this.recordCount});

  final String name;
  final String familyName;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF3B263E), Color(0xFF7A5140), _Palette.canvas],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            right: -70,
            top: 30,
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB46A).withValues(alpha: .16),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x55FF9A55), blurRadius: 90),
                ],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, _Palette.canvas],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 29,
                      backgroundColor: _Palette.violet,
                      child: Text(
                        'БТ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Добро пожаловать,', style: TextStyle(color: Colors.white70)),
                          Text(
                            '$name 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _RoundIcon(icon: Icons.notifications_none_rounded),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Важны не дни в жизни,\nа жизнь в днях.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 37,
                    height: 1.03,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  familyName,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    const _StatusPill(icon: Icons.lock_rounded, text: 'Private'),
                    _StatusPill(
                      icon: Icons.offline_bolt_rounded,
                      text: '$recordCount локально',
                    ),
                    const _StatusPill(icon: Icons.wb_sunny_rounded, text: 'Житомир · 20°'),
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

class _PulseCard extends StatelessWidget {
  const _PulseCard({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final List<_MetricData> metrics = <_MetricData>[
      const _MetricData('Связь', 92, Icons.favorite_rounded, Color(0xFFB06CFF)),
      _MetricData('Воспоминания', controller.memories.length, Icons.photo_rounded, const Color(0xFF6380FF)),
      _MetricData('Проекты', controller.projects.length, Icons.home_rounded, const Color(0xFF58D092)),
      _MetricData('События', controller.events.length, Icons.event_rounded, const Color(0xFFFFB45B)),
    ];

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              _AccentIcon(icon: Icons.monitor_heart_rounded, color: _Palette.violet),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Family Pulse',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
              ),
              _SmallTag(text: 'За неделю'),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth >= 700
                  ? constraints.maxWidth / 4
                  : constraints.maxWidth / 2;
              return Wrap(
                runSpacing: 8,
                children: metrics
                    .map((_) => SizedBox(width: width, child: _Metric(data: _)))
                    .toList(growable: false),
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
  const _RecordsPage({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _StandardPage(
      title: 'Семейная история',
      subtitle: 'Дни, которые становятся наследием',
      children: <Widget>[
        const _FeatureBanner(
          icon: Icons.wb_sunny_rounded,
          title: 'Ваше лето',
          subtitle: 'Лучшие моменты, незавершённые планы и идеи на новый сезон.',
        ),
        const SizedBox(height: 18),
        if (controller.records.isEmpty)
          const _EmptyState(icon: Icons.history_rounded, title: 'История пока пуста'),
        ...controller.records.map(
          (LocalEntryRecord record) => _RecordTile(
            record: record,
            onDelete: () => controller.delete(record.id),
          ),
        ),
      ],
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
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                childAspectRatio: 1,
                children: List<Widget>.generate(35, (int index) {
                  final bool highlighted = index == 0;
                  return Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: highlighted ? _Palette.violet : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: highlighted ? Colors.white : Colors.white70),
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
          const _EmptyState(icon: Icons.event_busy_rounded, title: 'Добавьте первое событие'),
        ...controller.events.map(
          (LocalEntryRecord record) => _RecordTile(
            record: record,
            onDelete: () => controller.delete(record.id),
          ),
        ),
      ],
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
      children: <Widget>[
        const _FeatureBanner(
          icon: Icons.home_work_rounded,
          title: 'Дом мечты',
          subtitle: 'Бюджет, район, документы, этапы и накопительная цель.',
        ),
        const SizedBox(height: 18),
        if (controller.projects.isEmpty)
          const _EmptyState(icon: Icons.folder_open_rounded, title: 'Создайте семейный проект'),
        ...controller.projects.map(
          (LocalEntryRecord record) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProjectCard(
              title: record.title,
              progress: _progressFor(record),
              wide: true,
            ),
          ),
        ),
      ],
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
      children: <Widget>[
        _FamilyGraph(),
        SizedBox(height: 18),
        _TrustTile(
          icon: Icons.lock_rounded,
          title: 'Приватность по умолчанию',
          subtitle: 'Каждая чувствительная запись получает явный уровень доступа.',
        ),
        _TrustTile(
          icon: Icons.child_care_rounded,
          title: 'Безопасность детей',
          subtitle: 'Чувствительные данные детей не анализируются без согласия родителей.',
        ),
        _TrustTile(
          icon: Icons.visibility_rounded,
          title: 'Explainable Intelligence',
          subtitle: 'Каждый совет показывает причину и использованный контекст.',
        ),
      ],
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
      children: <Widget>[
        _GlassCard(
          child: Column(
            children: <Widget>[
              const CircleAvatar(
                radius: 48,
                backgroundColor: _Palette.violet,
                child: Text(
                  'БТ',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                family.userName,
                style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
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
          subtitle: 'Премиальная тёмная система FamilyIQ.',
        ),
        const _TrustTile(
          icon: Icons.language_rounded,
          title: 'Язык',
          subtitle: 'Украинский, русский и английский.',
        ),
        const _TrustTile(
          icon: Icons.download_rounded,
          title: 'Архив семьи',
          subtitle: 'Локальный JSON-экспорт и восстановление.',
        ),
        _TrustTile(
          icon: Icons.logout_rounded,
          title: 'Выйти',
          subtitle: 'Локальные записи останутся на устройстве.',
          onTap: family.signOut,
        ),
      ],
    );
  }
}

class _PremiumNavigation extends StatelessWidget {
  const _PremiumNavigation({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  static const List<(IconData, String)> items = <(IconData, String)>[
    (Icons.home_rounded, 'Главная'),
    (Icons.history_rounded, 'История'),
    (Icons.calendar_month_rounded, 'Календарь'),
    (Icons.folder_rounded, 'Проекты'),
    (Icons.family_restroom_rounded, 'Семья'),
    (Icons.person_rounded, 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xF2141624),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .08))),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x88000000), blurRadius: 30)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(items.length, (int itemIndex) {
          final bool selected = itemIndex == index;
          final (IconData, String) item = items[itemIndex];
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: item.$2,
              child: InkWell(
                onTap: () => onSelected(itemIndex),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: 10,
                    left: itemIndex == 2 ? 0 : 4,
                    right: itemIndex == 3 ? 0 : 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedScale(
                        scale: selected ? 1.15 : 1,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          item.$1,
                          color: selected ? _Palette.violetLight : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: selected ? _Palette.violetLight : Colors.white38,
                          fontSize: 9,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: <Color>[_Palette.violetLight, Color(0xFF5A2CD1)]),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0x996F3FE8), blurRadius: 28, offset: Offset(0, 10)),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
      ),
    );
  }
}

class _StandardPage extends StatelessWidget {
  const _StandardPage({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 126),
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
        Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 15)),
        const SizedBox(height: 22),
        ...children,
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
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 16)),
        ],
      ),
      child: child,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(data.icon, color: data.color, size: 22),
              const SizedBox(width: 8),
              Text(
                '${data.value}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(data.label, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: LinearGradient(
                colors: <Color>[data.color.withValues(alpha: .25), data.color],
              ),
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
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String eyebrow;
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
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: _Palette.violetLight, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  eyebrow,
                  style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
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
  const _ProjectCard({required this.title, required this.progress, this.wide = false});

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
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: wide ? 100 : 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xFF6244B9), Color(0xFF263251)]),
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
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(_Palette.violetLight),
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
    final bool hasRecentMemory = controller.memories.isNotEmpty;
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
                style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
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
                  gradient: RadialGradient(colors: <Color>[Colors.white, _Palette.violetLight, Color(0xFF432080)]),
                  boxShadow: <BoxShadow>[BoxShadow(color: Color(0x886A42D7), blurRadius: 34)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Лучшее время для прогулки — 19:45',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasRecentMemory
                          ? 'Причина: у семьи есть недавние моменты — поддержите этот ритм.'
                          : 'Причина: за неделю ещё не создано общего воспоминания.',
                      style: TextStyle(color: Colors.white.withValues(alpha: .62), height: 1.4),
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
            style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (controller.records.isEmpty)
            const Text('Пока нет записей', style: TextStyle(color: Colors.white54)),
          ...controller.records.take(3).map(
            (LocalEntryRecord record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  _AccentIcon(icon: _iconFor(record.type), color: _colorFor(record.type)),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          record.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          record.note.isEmpty ? 'Семейная запись' : record.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: .45), fontSize: 12),
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

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onDelete});

  final LocalEntryRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: <Widget>[
          _AccentIcon(icon: _iconFor(record.type), color: _colorFor(record.type)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  record.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  record.note.isEmpty ? 'FamilyIQ' : record.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: .5), height: 1.35),
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
  const _FeatureBanner({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[Color(0xFF5D39B5), Color(0xFF26203B)]),
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
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.35)),
              ],
            ),
          ),
        ],
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
        child: Stack(
          children: const <Widget>[
            Positioned(left: 32, top: 40, child: _FamilyNode('БТ', 'Богдан', 'Владелец')),
            Positioned(right: 32, top: 40, child: _FamilyNode('КВ', 'Карина', 'Партнёр')),
            Positioned(left: 118, bottom: 25, child: _FamilyNode('∞', 'Будущее', 'Капсула')),
          ],
        ),
      ),
    );
  }
}

class _FamilyNode extends StatelessWidget {
  const _FamilyNode(this.initials, this.name, this.role);

  final String initials;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 41,
          backgroundColor: _Palette.violet,
          child: Text(
            initials,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        Text(role, style: TextStyle(color: Colors.white.withValues(alpha: .45), fontSize: 12)),
      ],
    );
  }
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.icon, required this.title, required this.subtitle, this.onTap});

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
              _AccentIcon(icon: icon, color: _Palette.violetLight),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white.withValues(alpha: .5), height: 1.35),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, required this.onPressed});

  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}

class _AccentIcon extends StatelessWidget {
  const _AccentIcon({required this.icon, required this.color});

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

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.black38,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.text});

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

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
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

class _TypeChip {
  const _TypeChip(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

abstract final class _Palette {
  static const Color canvas = Color(0xFF070914);
  static const Color surface = Color(0xFF151827);
  static const Color violet = Color(0xFF7448F5);
  static const Color violetLight = Color(0xFF9B75FF);
}

double _progressFor(LocalEntryRecord record) {
  final int score = record.id.codeUnits.fold<int>(0, (int sum, int value) => sum + value);
  return .3 + (score % 55) / 100;
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
    'memory' => _Palette.violetLight,
    'event' => const Color(0xFF557BFF),
    'project' => const Color(0xFF54D394),
    'tradition' => const Color(0xFFFFBE65),
    'child' => const Color(0xFFFF7FA0),
    _ => const Color(0xFF9A9FB3),
  };
}
