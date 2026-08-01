import 'dart:math' as math;

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
          if (controller.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return Scaffold(
            extendBody: true,
            backgroundColor: const Color(0xFF070914),
            body: SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOutCubic,
                child: IndexedStack(
                  key: ValueKey<int>(tab),
                  index: tab,
                  children: <Widget>[
                    _Home(controller: controller, onNavigate: _select),
                    _Timeline(controller: controller),
                    _Calendar(controller: controller),
                    _Projects(controller: controller),
                    _Family(controller: controller),
                    _Profile(controller: controller),
                  ],
                ),
              ),
            ),
            floatingActionButton: _CreateButton(onPressed: _openCreate),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: _WorldNav(index: tab, onSelected: _select),
          );
        },
      );

  void _select(int value) => setState(() => tab = value);

  Future<void> _openCreate() async {
    final TextEditingController title = TextEditingController();
    final TextEditingController note = TextEditingController();
    String type = 'memory';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 28),
          decoration: const BoxDecoration(
            color: Color(0xFF111421),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 22),
              const Text('Добавить в FamilyIQ', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _TypeChip(label: 'Память', value: 'memory', selected: type, icon: Icons.photo_library_rounded, onTap: (v) => setSheetState(() => type = v)),
                  _TypeChip(label: 'Событие', value: 'event', selected: type, icon: Icons.calendar_month_rounded, onTap: (v) => setSheetState(() => type = v)),
                  _TypeChip(label: 'Проект', value: 'project', selected: type, icon: Icons.folder_rounded, onTap: (v) => setSheetState(() => type = v)),
                  _TypeChip(label: 'Традиция', value: 'tradition', selected: type, icon: Icons.auto_awesome_rounded, onTap: (v) => setSheetState(() => type = v)),
                  _TypeChip(label: 'Ребёнок', value: 'child', selected: type, icon: Icons.child_care_rounded, onTap: (v) => setSheetState(() => type = v)),
                ],
              ),
              const SizedBox(height: 18),
              TextField(controller: title, autofocus: true, maxLength: 160, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Название')),
              const SizedBox(height: 10),
              TextField(controller: note, minLines: 3, maxLines: 6, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Описание')),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  if (title.text.trim().isEmpty) return;
                  await controller.create(type: type, title: title.text, note: note.text);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Сохранить локально')),
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
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _Hero(name: family.userName, records: controller.records.length)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
            sliver: SliverList.list(
              children: <Widget>[
                _Pulse(controller: controller),
                const SizedBox(height: 24),
                _Section(title: 'Сегодня', action: 'Смотреть все', onTap: () => onNavigate(1)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _TodayCard(icon: Icons.auto_awesome_rounded, label: 'Рекомендация дня', title: 'Вечерняя прогулка', subtitle: 'Лучшее время — 19:45', gradient: const <Color>[Color(0xFF402461), Color(0xFF171526)]),
                      _TodayCard(icon: Icons.cake_rounded, label: 'Ближайшее событие', title: controller.events.isEmpty ? 'Добавьте событие' : controller.events.first.title, subtitle: 'Семейный календарь', gradient: const <Color>[Color(0xFF22335C), Color(0xFF131725)]),
                      _TodayCard(icon: Icons.home_work_rounded, label: 'Активный проект', title: controller.projects.isEmpty ? 'Дом мечты' : controller.projects.first.title, subtitle: 'Следующий шаг готов', gradient: const <Color>[Color(0xFF1C4B3A), Color(0xFF111A19)]),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _Section(title: 'Популярные проекты', action: 'Все проекты', onTap: () => onNavigate(3)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 205,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: controller.projects.isEmpty
                        ? const <Widget>[_ProjectPreview(title: 'Дом мечты', progress: .65), _ProjectPreview(title: 'Отпуск 2026', progress: .47), _ProjectPreview(title: 'Семейная книга', progress: .30)]
                        : controller.projects.take(4).map((item) => _ProjectPreview(title: item.title, progress: _progress(item))).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) => c.maxWidth > 720
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          Expanded(child: _IqCard(controller: controller)),
                          const SizedBox(width: 14),
                          Expanded(child: _Recent(controller: controller)),
                        ])
                      : Column(children: <Widget>[
                          _IqCard(controller: controller),
                          const SizedBox(height: 14),
                          _Recent(controller: controller),
                        ]),
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
  const _Hero({required this.name, required this.records});
  final String name;
  final int records;

  @override
  Widget build(BuildContext context) => Container(
        height: 455,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF34223A), Color(0xFF745040), Color(0xFF15131D)]),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(right: -90, top: 30, child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFB46A).withValues(alpha: .18), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x44FF9A55), blurRadius: 90)]))),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Colors.transparent, Color(0xFF070914)]))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    const CircleAvatar(radius: 29, backgroundColor: Color(0xFF8B63FF), child: Text('БТ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      const Text('Доброе утро,', style: TextStyle(color: Colors.white70, fontSize: 15)),
                      Text('$name 👋', style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
                    ])),
                    _CircleAction(icon: Icons.notifications_none_rounded, badge: true),
                  ]),
                  const Spacer(),
                  const Text('Важны не дни в жизни,\nа жизнь в днях.', style: TextStyle(color: Colors.white, fontSize: 38, height: 1.02, fontWeight: FontWeight.w500, letterSpacing: -1.5)),
                  const SizedBox(height: 12),
                  const Text('Сделаем этот день особенным ✨', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(children: <Widget>[
                    _GlassPill(icon: Icons.lock_rounded, text: 'Private'),
                    const SizedBox(width: 8),
                    _GlassPill(icon: Icons.offline_bolt_rounded, text: '$records локально'),
                    const Spacer(),
                    const _Weather(),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            const _IconBox(icon: Icons.monitor_heart_rounded, color: Color(0xFF8D5CFF)),
            const SizedBox(width: 10),
            const Expanded(child: Text('Family Pulse', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))),
            _Tag(text: 'За неделю'),
          ]),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, c) {
            final metrics = <Widget>[
              _PulseMetric(value: 92, label: 'Связь', icon: Icons.favorite_rounded, color: const Color(0xFFAA63FF)),
              _PulseMetric(value: controller.memories.length, label: 'Воспоминания', icon: Icons.photo_rounded, color: const Color(0xFF617CFF)),
              _PulseMetric(value: controller.projects.length, label: 'Проекты', icon: Icons.home_rounded, color: const Color(0xFF58D092)),
              _PulseMetric(value: controller.events.length, label: 'События', icon: Icons.event_rounded, color: const Color(0xFFFFB45B)),
            ];
            return c.maxWidth > 700 ? Row(children: metrics.map((e) => Expanded(child: e)).toList()) : Wrap(runSpacing: 10, children: metrics.map((e) => SizedBox(width: c.maxWidth / 2, child: e)).toList());
          }),
          const Divider(color: Colors.white12, height: 28),
          const Row(children: <Widget>[Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 17), SizedBox(width: 8), Expanded(child: Text('Все данные хранятся локально на вашем устройстве', style: TextStyle(color: Colors.white54))), Text('Подробнее', style: TextStyle(color: Color(0xFF9B75FF), fontWeight: FontWeight.w700))]),
        ]),
      );
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _StandardPage(
        title: 'Семейная история',
        subtitle: 'Дни, которые становятся наследием',
        child: Column(children: <Widget>[
          const _FeatureBanner(title: 'Ваше лето', subtitle: 'Лучшие моменты, незавершённые планы и идеи на следующий сезон', icon: Icons.wb_sunny_rounded),
          const SizedBox(height: 18),
          ...controller.records.map((item) => _RecordCard(record: item, onDelete: () => controller.delete(item.id))),
        ]),
      );
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _StandardPage(
        title: 'Календарь семьи',
        subtitle: 'События, дни рождения и важные шаги',
        child: Column(children: <Widget>[
          _GlassCard(child: Column(children: <Widget>[
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Icon(Icons.chevron_left_rounded, color: Colors.white), Text('Август 2026', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), Icon(Icons.chevron_right_rounded, color: Colors.white)]),
            const SizedBox(height: 18),
            GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 7, children: List<Widget>.generate(35, (i) => Center(child: Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: i == 0 ? const Color(0xFF7448F5) : Colors.transparent, borderRadius: BorderRadius.circular(14)), child: Text('${i + 1}', style: TextStyle(color: i == 0 ? Colors.white : Colors.white70))))),
          ])),
          const SizedBox(height: 18),
          ...controller.events.map((e) => _RecordCard(record: e, onDelete: () => controller.delete(e.id))),
        ]),
      );
}

class _Projects extends StatelessWidget {
  const _Projects({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _StandardPage(
        title: 'Life Projects',
        subtitle: 'Большие мечты, превращённые в следующие шаги',
        child: Column(children: <Widget>[
          const _FeatureBanner(title: 'Дом мечты', subtitle: 'Бюджет, район, документы, этапы и накопительная цель', icon: Icons.home_work_rounded),
          const SizedBox(height: 18),
          ...controller.projects.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _ProjectPreview(title: e.title, progress: _progress(e), wide: true))),
          if (controller.projects.isEmpty) const _EmptyState(icon: Icons.folder_open_rounded, title: 'Создайте первый семейный проект'),
        ]),
      );
}

class _Family extends StatelessWidget {
  const _Family({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _StandardPage(
        title: 'Семейный круг',
        subtitle: 'Люди, доверие и общее будущее',
        child: Column(children: <Widget>[
          _GlassCard(child: SizedBox(height: 330, child: Stack(children: const <Widget>[
            Positioned(left: 40, top: 40, child: _FamilyNode(initials: 'БТ', name: 'Богдан', role: 'Владелец')),
            Positioned(right: 40, top: 40, child: _FamilyNode(initials: 'КВ', name: 'Карина', role: 'Партнёр')),
            Positioned(left: 130, bottom: 28, child: _FamilyNode(initials: '∞', name: 'Будущее', role: 'Капсула')),
          ]))),
          const SizedBox(height: 18),
          const _TrustTile(icon: Icons.lock_rounded, title: 'Приватность по умолчанию', subtitle: 'Каждая чувствительная запись получает явный уровень доступа.'),
          const _TrustTile(icon: Icons.child_care_rounded, title: 'Безопасность детей', subtitle: 'Здоровье и настроение не анализируются без согласия родителей.'),
          const _TrustTile(icon: Icons.visibility_rounded, title: 'Explainable Intelligence', subtitle: 'Каждый совет показывает причину и использованные данные.'),
        ]),
      );
}

class _Profile extends StatelessWidget {
  const _Profile({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) {
    final family = FamilyScope.of(context);
    return _StandardPage(
      title: 'Профиль',
      subtitle: family.familyName,
      child: Column(children: <Widget>[
        _GlassCard(child: Column(children: <Widget>[
          const CircleAvatar(radius: 48, backgroundColor: Color(0xFF7046EE), child: Text('БТ', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900))),
          const SizedBox(height: 14),
          Text(family.userName, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('${controller.records.length} записей · 100% локально', style: const TextStyle(color: Colors.white60)),
        ])),
        const SizedBox(height: 18),
        const _TrustTile(icon: Icons.palette_rounded, title: 'Оформление', subtitle: 'Премиальная тёмная тема FamilyIQ 3.1'),
        const _TrustTile(icon: Icons.language_rounded, title: 'Язык', subtitle: 'Украинский, русский и английский'),
        const _TrustTile(icon: Icons.download_rounded, title: 'Архив семьи', subtitle: 'JSON-экспорт и подготовка PDF/ZIP'),
        _TrustTile(icon: Icons.logout_rounded, title: 'Выйти', subtitle: 'Локальные данные сохранятся', onTap: family.signOut),
      ]),
    );
  }
}

class _StandardPage extends StatelessWidget {
  const _StandardPage({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: <Widget>[
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 15)),
          const SizedBox(height: 22),
          child,
        ],
      );
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF151827),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 16))],
        ),
        child: child,
      );
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({required this.value, required this.label, required this.icon, required this.color});
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[Icon(icon, color: color, size: 22), const SizedBox(width: 8), Text('$value', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 12),
          SizedBox(height: 26, child: CustomPaint(painter: _SparkPainter(color))),
        ]),
      );
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height * .72);
    for (int i = 1; i <= 8; i++) {
      final x = size.width * i / 8;
      final y = size.height * (.48 + math.sin(i * 1.7) * .17 - i * .025);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.color != color;
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.icon, required this.label, required this.title, required this.subtitle, required this.gradient});
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) => Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[Icon(icon, color: const Color(0xFF9B75FF), size: 18), const SizedBox(width: 8), Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700)))]),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Text(subtitle, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.bottomRight, child: CircleAvatar(radius: 18, backgroundColor: Colors.white12, child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18))),
        ]),
      );
}

class _ProjectPreview extends StatelessWidget {
  const _ProjectPreview({required this.title, required this.progress, this.wide = false});
  final String title;
  final double progress;
  final bool wide;

  @override
  Widget build(BuildContext context) => Container(
        width: wide ? double.infinity : 205,
        margin: EdgeInsets.only(right: wide ? 0 : 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: const Color(0xFF151827), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(height: wide ? 100 : 90, decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xFF6244B9), Color(0xFF263251)]), borderRadius: BorderRadius.circular(18)), child: const Center(child: Icon(Icons.home_work_rounded, color: Colors.white70, size: 38))),
          const SizedBox(height: 14),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(children: <Widget>[Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white70)), const SizedBox(width: 8), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8057FF)))))]),
        ]),
      );
}

class _IqCard extends StatelessWidget {
  const _IqCard({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Row(children: <Widget>[Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFC16B)), SizedBox(width: 8), Text('Family IQ', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(width: 82, height: 82, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: <Color>[Colors.white, Color(0xFF9C7CFF), Color(0xFF432080)]), boxShadow: <BoxShadow>[BoxShadow(color: Color(0x886A42D7), blurRadius: 34)])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            const Text('Лучшее время для прогулки — 19:45', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(controller.memories.isEmpty ? 'Причина: на этой неделе ещё нет общего воспоминания.' : 'Причина: последняя совместная прогулка была давно.', style: const TextStyle(color: Colors.white60, height: 1.4)),
          ])),
        ]),
      ]));
}

class _Recent extends StatelessWidget {
  const _Recent({required this.controller});
  final LocalFamilyController controller;

  @override
  Widget build(BuildContext context) => _GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Text('Последние моменты', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        if (controller.records.isEmpty) const Text('Пока нет записей', style: TextStyle(color: Colors.white54)),
        ...controller.records.take(3).map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: <Widget>[
              _IconBox(icon: _iconFor(e.type), color: _colorFor(e.type)),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(e.note.isEmpty ? 'Семейная запись' : e.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white45, fontSize: 12))])),
            ]))),
      ]));
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onDelete});
  final LocalEntryRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: const Color(0xFF151827), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
        child: Row(children: <Widget>[
          _IconBox(icon: _iconFor(record.type), color: _colorFor(record.type)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(record.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(record.note.isEmpty ? 'FamilyIQ' : record.note, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white50, height: 1.35)),
          ])),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.more_vert_rounded, color: Colors.white38)),
        ]),
      );
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xFF5D39B5), Color(0xFF26203B)]), borderRadius: BorderRadius.circular(30)),
        child: Row(children: <Widget>[Icon(icon, color: Colors.white, size: 42), const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.35))]))]),
      );
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: _GlassCard(child: Row(children: <Widget>[_IconBox(icon: icon, color: const Color(0xFF8B63FF)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white50, height: 1.35))])), const Icon(Icons.chevron_right_rounded, color: Colors.white30)]))),
      );
}

class _FamilyNode extends StatelessWidget {
  const _FamilyNode({required this.initials, required this.name, required this.role});
  final String initials;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[CircleAvatar(radius: 41, backgroundColor: const Color(0xFF7149EF), child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(height: 8), Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), Text(role, style: const TextStyle(color: Colors.white45, fontSize: 12))]);
}

class _WorldNav extends StatelessWidget {
  const _WorldNav({required this.index, required this.onSelected});
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        height: 92,
        decoration: BoxDecoration(color: const Color(0xF2141624), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .08))), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x88000000), blurRadius: 30)]),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
          _NavItem(icon: Icons.home_rounded, label: 'Главная', value: 0, index: index, onTap: onSelected),
          _NavItem(icon: Icons.history_rounded, label: 'История', value: 1, index: index, onTap: onSelected),
          _NavItem(icon: Icons.calendar_month_rounded, label: 'Календарь', value: 2, index: index, onTap: onSelected),
          const SizedBox(width: 60),
          _NavItem(icon: Icons.folder_rounded, label: 'Проекты', value: 3, index: index, onTap: onSelected),
          _NavItem(icon: Icons.family_restroom_rounded, label: 'Семья', value: 4, index: index, onTap: onSelected),
          _NavItem(icon: Icons.person_rounded, label: 'Профиль', value: 5, index: index, onTap: onSelected),
        ]),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.value, required this.index, required this.onTap});
  final IconData icon;
  final String label;
  final int value;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == index;
    return InkWell(onTap: () => onTap(value), borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[AnimatedScale(duration: const Duration(milliseconds: 220), scale: selected ? 1.13 : 1, child: Icon(icon, color: selected ? const Color(0xFF8B63FF) : Colors.white38)), const SizedBox(height: 5), Text(label, style: TextStyle(color: selected ? const Color(0xFF9B75FF) : Colors.white38, fontSize: 10, fontWeight: selected ? FontWeight.w800 : FontWeight.w500))])));
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: <Color>[Color(0xFF8F63FF), Color(0xFF5A2CD1)]), boxShadow: <BoxShadow>[BoxShadow(color: Color(0x996F3FE8), blurRadius: 28, offset: Offset(0, 10))]),
        child: IconButton(onPressed: onPressed, icon: const Icon(Icons.add_rounded, color: Colors.white, size: 35)),
      );
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.value, required this.selected, required this.icon, required this.onTap});
  final String label;
  final String value;
  final String selected;
  final IconData icon;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(selected: selected == value, onSelected: (_) => onTap(value), avatar: Icon(icon, size: 17), label: Text(label));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(children: <Widget>[Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900))), TextButton(onPressed: onTap, child: Text(action))]);
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .07), borderRadius: BorderRadius.circular(99)), child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)));
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color));
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, this.badge = false});
  final IconData icon;
  final bool badge;
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: <Widget>[CircleAvatar(radius: 24, backgroundColor: Colors.black38, child: Icon(icon, color: Colors.white)), if (badge) const Positioned(right: -1, top: -4, child: CircleAvatar(radius: 9, backgroundColor: Color(0xFF7947FF), child: Text('2', style: TextStyle(color: Colors.white, fontSize: 10))))]);
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white12)), child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, color: Colors.white60, size: 15), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12))]));
}

class _Weather extends StatelessWidget {
  const _Weather();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('☀️ 20°', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)), Text('Житомир', style: TextStyle(color: Colors.white54, fontSize: 11))]));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => _GlassCard(child: Column(children: <Widget>[Icon(icon, color: Colors.white38, size: 42), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white70))]));
}

double _progress(LocalEntryRecord record) => .3 + (record.id.codeUnits.fold<int>(0, (a, b) => a + b) % 55) / 100;
IconData _iconFor(String type) => switch (type) {
      'memory' => Icons.photo_rounded,
      'event' => Icons.calendar_month_rounded,
      'project' => Icons.folder_rounded,
      'tradition' => Icons.auto_awesome_rounded,
      'child' => Icons.child_care_rounded,
      _ => Icons.notes_rounded,
    };
Color _colorFor(String type) => switch (type) {
      'memory' => const Color(0xFF8B63FF),
      'event' => const Color(0xFF557BFF),
      'project' => const Color(0xFF54D394),
      'tradition' => const Color(0xFFFFBE65),
      'child' => const Color(0xFFFF7FA0),
      _ => const Color(0xFF9A9FB3),
    };
