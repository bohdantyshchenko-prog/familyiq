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
            backgroundColor: _Colors.canvas,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final List<Widget> pages = <Widget>[
          _HomePage(controller: controller, onNavigate: _selectPage),
          _RecordsPage(controller: controller),
          _CalendarPage(controller: controller),
          _ProjectsPage(controller: controller),
          const _FamilyPage(),
          _ProfilePage(controller: controller),
        ];

        return Scaffold(
          extendBody: true,
          backgroundColor: _Colors.canvas,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
          floatingActionButton: Semantics(
            button: true,
            label: 'Добавить семейную запись',
            child: FloatingActionButton(
              tooltip: 'Добавить',
              onPressed: _openCreate,
              backgroundColor: _Colors.violet,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded, size: 32),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _Navigation(
            selectedIndex: selectedIndex,
            onSelected: _selectPage,
          ),
        );
      },
    );
  }

  void _selectPage(int index) {
    setState(() => selectedIndex = index);
  }

  Future<void> _openCreate() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    String selectedType = 'memory';
    const List<_TypeOption> options = <_TypeOption>[
      _TypeOption('Память', 'memory', Icons.photo_library_rounded),
      _TypeOption('Событие', 'event', Icons.event_rounded),
      _TypeOption('Проект', 'project', Icons.folder_rounded),
      _TypeOption('Традиция', 'tradition', Icons.auto_awesome_rounded),
      _TypeOption('Ребёнок', 'child', Icons.child_care_rounded),
    ];

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
                color: _Colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: _SheetHandle()),
                    const SizedBox(height: 20),
                    const Text(
                      'Новая семейная запись',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((_TypeOption option) {
                        return ChoiceChip(
                          selected: selectedType == option.value,
                          avatar: Icon(option.icon, size: 18),
                          label: Text(option.label),
                          onSelected: (bool selected) {
                            if (selected) {
                              setModalState(() => selectedType = option.value);
                            }
                          },
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 16),
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
                      maxLength: 20000,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 16),
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
  const _HomePage({required this.controller, required this.onNavigate});

  final LocalFamilyController controller;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final FamilyStore family = FamilyScope.of(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 126),
        children: <Widget>[
          _Hero(
            name: family.userName,
            familyName: family.familyName,
            recordCount: controller.records.length,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _PulseCard(controller: controller),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Сегодня',
                  action: 'История',
                  onPressed: () => onNavigate(1),
                ),
                const SizedBox(height: 12),
                _TodayGrid(controller: controller),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Life Projects',
                  action: 'Все проекты',
                  onPressed: () => onNavigate(3),
                ),
                const SizedBox(height: 12),
                _ProjectList(controller: controller, horizontal: true),
                const SizedBox(height: 22),
                _IntelligenceCard(controller: controller),
                const SizedBox(height: 14),
                _RecentCard(controller: controller),
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
      height: 410,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF3A263F), Color(0xFF76513F), _Colors.canvas],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 28,
                backgroundColor: _Colors.violet,
                child: Text('БТ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Добро пожаловать,', style: TextStyle(color: Colors.white70)),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 23,
                backgroundColor: Colors.black38,
                child: Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Важны не дни в жизни,\nа жизнь в днях.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.04,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(familyName, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              const _StatusPill(icon: Icons.lock_rounded, text: 'Private'),
              _StatusPill(icon: Icons.offline_bolt_rounded, text: '$recordCount локально'),
              const _StatusPill(icon: Icons.auto_awesome_rounded, text: 'Explainable'),
            ],
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
    final List<_Metric> metrics = <_Metric>[
      const _Metric('Связь', 92, Icons.favorite_rounded, Color(0xFFB06CFF)),
      _Metric('Память', controller.memories.length, Icons.photo_rounded, const Color(0xFF6380FF)),
      _Metric('Проекты', controller.projects.length, Icons.folder_rounded, const Color(0xFF58D092)),
      _Metric('События', controller.events.length, Icons.event_rounded, const Color(0xFFFFB45B)),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Family Pulse',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth / 2;
              return Wrap(
                children: metrics.map((_Metric metric) {
                  return SizedBox(
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(metric.icon, color: metric.color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${metric.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(metric.label, style: const TextStyle(color: Colors.white60)),
                        ],
                      ),
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayGrid extends StatelessWidget {
  const _TodayGrid({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _InfoCard(
          icon: Icons.auto_awesome_rounded,
          label: 'Рекомендация',
          title: 'Совместная прогулка',
          subtitle: 'Спокойное окно — 19:45',
        ),
        const SizedBox(height: 10),
        _InfoCard(
          icon: Icons.event_rounded,
          label: 'Ближайшее событие',
          title: controller.events.isEmpty ? 'Добавьте событие' : controller.events.first.title,
          subtitle: 'Семейный календарь',
        ),
      ],
    );
  }
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({required this.controller});

  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Семейная история',
      subtitle: 'Дни, которые становятся наследием',
      children: <Widget>[
        const _FeatureBanner(
          icon: Icons.wb_sunny_rounded,
          title: 'Ваше лето',
          subtitle: 'Лучшие моменты, незавершённые планы и идеи на новый сезон.',
        ),
        const SizedBox(height: 16),
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
    return _Page(
      title: 'Календарь семьи',
      subtitle: 'События и важные шаги',
      children: <Widget>[
        _Card(
          child: Column(
            children: <Widget>[
              const Text(
                'Август 2026',
                style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                children: List<Widget>.generate(35, (int index) {
                  final bool selected = index == 0;
                  return Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? _Colors.violet : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white70)),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
    return _Page(
      title: 'Life Projects',
      subtitle: 'Мечты, превращённые в действия',
      children: <Widget>[
        const _FeatureBanner(
          icon: Icons.home_work_rounded,
          title: 'Дом мечты',
          subtitle: 'Бюджет, район, документы, этапы и накопительная цель.',
        ),
        const SizedBox(height: 16),
        _ProjectList(controller: controller),
      ],
    );
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.controller, this.horizontal = false});

  final LocalFamilyController controller;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final List<LocalEntryRecord> projects = controller.projects;
    if (projects.isEmpty) {
      return const _EmptyState(icon: Icons.folder_open_rounded, title: 'Создайте семейный проект');
    }
    final List<Widget> cards = projects.map((LocalEntryRecord record) {
      return _ProjectCard(title: record.title, progress: _progressFor(record));
    }).toList(growable: false);
    if (horizontal) {
      return SizedBox(
        height: 185,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 12),
          itemBuilder: (BuildContext context, int index) => SizedBox(width: 210, child: cards[index]),
        ),
      );
    }
    return Column(
      children: cards
          .map((Widget card) => Padding(padding: const EdgeInsets.only(bottom: 12), child: card))
          .toList(growable: false),
    );
  }
}

class _FamilyPage extends StatelessWidget {
  const _FamilyPage();

  @override
  Widget build(BuildContext context) {
    return const _Page(
      title: 'Семейный круг',
      subtitle: 'Люди, доверие и общее будущее',
      children: <Widget>[
        _FamilyGraph(),
        SizedBox(height: 16),
        _TrustTile(
          icon: Icons.lock_rounded,
          title: 'Приватность по умолчанию',
          subtitle: 'Чувствительные записи остаются под контролем семьи.',
        ),
        _TrustTile(
          icon: Icons.child_care_rounded,
          title: 'Безопасность детей',
          subtitle: 'Чувствительные данные детей требуют согласия родителей.',
        ),
        _TrustTile(
          icon: Icons.visibility_rounded,
          title: 'Explainable Intelligence',
          subtitle: 'Каждый совет показывает понятную причину.',
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
    return _Page(
      title: 'Профиль',
      subtitle: family.familyName,
      children: <Widget>[
        _Card(
          child: Column(
            children: <Widget>[
              const CircleAvatar(
                radius: 46,
                backgroundColor: _Colors.violet,
                child: Text('БТ', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              const SizedBox(height: 12),
              Text(
                family.userName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.records.length} записей · 100% локально',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _TrustTile(
          icon: Icons.language_rounded,
          title: 'Языки',
          subtitle: 'Украинский, русский и английский.',
        ),
        const _TrustTile(
          icon: Icons.download_rounded,
          title: 'Архив семьи',
          subtitle: 'Локальный экспорт и восстановление.',
        ),
        _TrustTile(
          icon: Icons.logout_rounded,
          title: 'Выйти',
          subtitle: 'Локальные записи сохранятся.',
          onTap: family.signOut,
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.subtitle, required this.children});

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
          style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<(IconData, String)> destinations = <(IconData, String)>[
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
      height: 88,
      decoration: const BoxDecoration(
        color: Color(0xF2141624),
        boxShadow: <BoxShadow>[BoxShadow(color: Color(0x88000000), blurRadius: 28)],
      ),
      child: Row(
        children: List<Widget>.generate(destinations.length, (int index) {
          final bool selected = selectedIndex == index;
          final (IconData, String) destination = destinations[index];
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: destination.$2,
              child: InkWell(
                onTap: () => onSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      destination.$1,
                      color: selected ? _Colors.violetLight : Colors.white38,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.$2,
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? _Colors.violetLight : Colors.white38,
                        fontSize: 9,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x55000000), blurRadius: 28, offset: Offset(0, 14)),
        ],
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.title, required this.subtitle});

  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: <Widget>[
          _AccentIcon(icon: icon, color: _Colors.violetLight),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.title, required this.progress});

  final String title;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.home_work_rounded, color: _Colors.violetLight, size: 34),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: Colors.white12,
            color: _Colors.violetLight,
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
    final String reason = controller.memories.isEmpty
        ? 'За неделю ещё нет нового общего воспоминания.'
        : 'У семьи есть свежие моменты — поддержите этот ритм.';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Family IQ',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          const Text(
            'Лучшее время для прогулки — 19:45',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Причина: $reason', style: const TextStyle(color: Colors.white60, height: 1.4)),
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
    return _Card(
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Card(
        child: Row(
          children: <Widget>[
            _AccentIcon(icon: _iconFor(record.type), color: _colorFor(record.type)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(record.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    record.note.isEmpty ? 'FamilyIQ' : record.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60),
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
        gradient: const LinearGradient(colors: <Color>[_Colors.violet, Color(0xFF26203B)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
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
    return const _Card(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _FamilyNode('БТ', 'Богдан', 'Владелец'),
              _FamilyNode('КВ', 'Карина', 'Партнёр'),
            ],
          ),
          SizedBox(height: 24),
          _FamilyNode('∞', 'Будущее', 'Капсула'),
        ],
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
          radius: 38,
          backgroundColor: _Colors.violet,
          child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 7),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        Text(role, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: _Card(
          child: Row(
            children: <Widget>[
              _AccentIcon(icon: icon, color: _Colors.violetLight),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white60, height: 1.35)),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action, required this.onPressed});

  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: <Widget>[
          Icon(icon, color: Colors.white38, size: 40),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
    );
  }
}

class _TypeOption {
  const _TypeOption(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _Metric {
  const _Metric(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

abstract final class _Colors {
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
    'memory' => _Colors.violetLight,
    'event' => const Color(0xFF557BFF),
    'project' => const Color(0xFF54D394),
    'tradition' => const Color(0xFFFFBE65),
    'child' => const Color(0xFFFF7FA0),
    _ => const Color(0xFF9A9FB3),
  };
}
