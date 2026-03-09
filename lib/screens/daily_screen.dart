import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DAILY SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});
  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  bool _showAdd = false;
  final _taskCtrl = TextEditingController();
  String _timeOfDay = 'Morning';
  static const _times = ['Morning', 'Afternoon', 'Evening'];
  static const _tColors = {
    'Morning': AppColors.accent,
    'Afternoon': AppColors.blue,
    'Evening': AppColors.violet,
  };
  static const _tIcons = {
    'Morning': '🌅',
    'Afternoon': '☀️',
    'Evening': '🌙',
  };

  @override
  void dispose() { _taskCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final done = p.dailyTasks.where((t) => t.isDone).length;
    final pct = p.dailyTasks.isEmpty ? 0.0 : done / p.dailyTasks.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bg,
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppColors.teal.withOpacity(0.18), AppColors.bg])),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Daily Routine', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1.5)),
                    Text('☀️ Today', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
                    Text('$done of ${p.dailyTasks.length} completed', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
                  ]),
                  ProgressRing(percent: pct, size: 56, color: AppColors.teal, label: '${(pct * 100).round()}%'),
                ]),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (done == p.dailyTasks.length && p.dailyTasks.isNotEmpty)
                  Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.tealSoft, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('🎉 Perfect day! All tasks done!', style: GoogleFonts.sora(color: AppColors.teal, fontWeight: FontWeight.w700)))),
                ..._times.map((time) {
                  final tasks = p.dailyTasks.where((t) => t.timeOfDay == time).toList();
                  if (tasks.isEmpty) return const SizedBox.shrink();
                  final c = _tColors[time] ?? AppColors.accent;
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(_tIcons[time]!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(time.toUpperCase(), style: GoogleFonts.sora(fontSize: 10, color: c, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      const SizedBox(width: 6),
                      Text('${tasks.where((t) => t.isDone).length}/${tasks.length}', style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
                    ]),
                    const SizedBox(height: 8),
                    ...tasks.map((t) => ChecklistItem(text: t.text, isDone: t.isDone, onToggle: () => p.toggleDailyTask(t.id), color: c, streak: t.streak > 0 ? t.streak : null, isImportant: t.isImportant)),
                    const SizedBox(height: 16),
                  ]);
                }),
                if (_showAdd)
                  AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextField(controller: _taskCtrl, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Task name')),
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                        value: _timeOfDay, isExpanded: true, dropdownColor: AppColors.card,
                        style: GoogleFonts.sora(fontSize: 13, color: AppColors.textPrimary),
                        items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _timeOfDay = v!),
                      ))),
                    const SizedBox(height: 10),
                    Row(children: [
                      AppButton(text: 'Add', isSmall: true, onPressed: () {
                        if (_taskCtrl.text.trim().isEmpty) return;
                        p.addDailyTask(DailyTask(id: DateTime.now().millisecondsSinceEpoch, timeOfDay: _timeOfDay, text: _taskCtrl.text.trim()));
                        _taskCtrl.clear(); setState(() => _showAdd = false);
                      }),
                      const SizedBox(width: 8),
                      AppButton(text: 'Cancel', isSmall: true, isOutlined: true, color: AppColors.textMuted, onPressed: () => setState(() => _showAdd = false)),
                    ]),
                  ]))
                else
                  GestureDetector(onTap: () => setState(() => _showAdd = true),
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Center(child: Text('+ Add Task', style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 12))))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HABITS SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _showAdd = false;
  final _nameCtrl = TextEditingController();
  String _icon = '⭐';
  Color _color = AppColors.teal;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub), onPressed: () => Navigator.pop(context)),
        title: Text('🔥 Habit Tracker', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Build streaks. Break nothing.', style: GoogleFonts.sora(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ...p.habits.map((h) => _HabitCard(habit: h, onLog: () => p.logHabitToday(h.id))),
          if (_showAdd)
            AppCard(child: Column(children: [
              Row(children: [
                Container(width: 50, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                  child: TextField(onChanged: (v) => setState(() => _icon = v), style: const TextStyle(fontSize: 22),
                    decoration: InputDecoration.collapsed(hintText: _icon, hintStyle: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _nameCtrl, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Habit name'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [AppColors.teal, AppColors.blue, AppColors.violet, AppColors.accent, AppColors.rose, AppColors.success].map((c) =>
                GestureDetector(onTap: () => setState(() => _color = c),
                  child: Container(width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                      border: Border.all(color: _color == c ? Colors.white : Colors.transparent, width: 2))))).toList()),
              const SizedBox(height: 12),
              Row(children: [
                AppButton(text: 'Add', isSmall: true, onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty) return;
                  p.addHabit(HabitModel(id: DateTime.now().millisecondsSinceEpoch, name: _nameCtrl.text.trim(), icon: _icon, color: _color));
                  _nameCtrl.clear(); setState(() => _showAdd = false);
                }),
                const SizedBox(width: 8),
                AppButton(text: 'Cancel', isSmall: true, isOutlined: true, color: AppColors.textMuted, onPressed: () => setState(() => _showAdd = false)),
              ]),
            ]))
          else
            GestureDetector(onTap: () => setState(() => _showAdd = true),
              child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Center(child: Text('+ Add New Habit', style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 13))))),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onLog;
  const _HabitCard({required this.habit, required this.onLog});

  @override
  Widget build(BuildContext context) {
    final c = habit.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.withOpacity(0.15), AppColors.card]),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: c.withOpacity(0.15), border: Border.all(color: c)),
            child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.name, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('Best: ${habit.bestStreak} days', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Column(children: [
            Text('${habit.streak}', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w800, color: c, height: 1)),
            Text('days', style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
          ]),
        ]),
        const SizedBox(height: 12),
        // History dots
        Wrap(spacing: 4, runSpacing: 4, children: habit.history.reversed.take(21).toList().reversed
          .map((v) => Container(width: 10, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: v == 1 ? c : AppColors.border))).toList()),
        const SizedBox(height: 10),
        AppProgressBar(percent: (habit.bestStreak > 0.0 ? habit.streak / habit.bestStreak : 0.0).clamp(0.0, 1.0), color: c),
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerRight,
          child: AppButton(text: '✓ Log Today', isSmall: true, color: c, onPressed: onLog)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MOVING SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class MovingScreen extends StatelessWidget {
  const MovingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final m = p.moving;
    final days = m.moveDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🏠 Moving in $days days', style: GoogleFonts.sora(fontSize: 11, color: AppColors.violet, letterSpacing: 1)),
          Text('Moving Planner', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
        ]),
        actions: [ProgressRing(percent: m.progress, size: 40, color: AppColors.violet, label: '${(m.progress * 100).round()}%', strokeWidth: 3),
          const SizedBox(width: 20)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.violetSoft, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.address, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              AppProgressBar(percent: m.progress, color: AppColors.violet, height: 5),
              const SizedBox(height: 4),
              Text('${m.doneTasks}/${m.totalTasks} tasks done', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
            ])),
          ...m.rooms.map((room) => _RoomExpansion(room: room, onToggle: (tid) => p.toggleMovingTask(room.id, tid))),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Text('💡', style: TextStyle(fontSize: 18)), const SizedBox(width: 8),
                Text('AI Moving Tips', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent))]),
              const SizedBox(height: 10),
              ...['Label every box: Room + Contents + Fragile?', 'Pack an Essentials Bag for your first night', 'Admin tasks (Aadhaar, bank) take longest — start now!', 'Photograph all electronics before unplugging']
                .map((tip) => Padding(padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('• ', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 13)),
                    Expanded(child: Text(tip, style: GoogleFonts.sora(color: AppColors.textSub, fontSize: 12, height: 1.4))),
                  ]))),
            ])),
        ],
      ),
    );
  }
}

class _RoomExpansion extends StatelessWidget {
  final MovingRoom room;
  final Function(int) onToggle;
  const _RoomExpansion({required this.room, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = room.tasks.where((t) => t.isDone).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(children: [
          Text(room.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(room.name, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$done/${room.tasks.length}', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more, color: AppColors.textMuted),
        ]),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(children: room.tasks.map((t) => ChecklistItem(text: t.text, isDone: t.isDone, onToggle: () => onToggle(t.id), color: AppColors.violet)).toList()),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STATS SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub), onPressed: () => Navigator.pop(context)),
        title: Text('📊 Life Stats', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Your life at a glance', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2,
            children: [
              _BigStat('🔥', 'Best Streak', '${p.topStreak}d', 'Meditation', AppColors.teal),
              _BigStat('✅', 'Tasks Today', '${p.totalDailyDone}/${p.dailyTasks.length}', '${p.dailyTasks.isEmpty ? 0 : (p.totalDailyDone / p.dailyTasks.length * 100).round()}% done', AppColors.accent),
              _BigStat('📦', 'Items Packed', '${p.totalPacked}/${p.totalItems}', '${p.totalItems == 0 ? 0 : (p.totalPacked / p.totalItems * 100).round()}% ready', AppColors.blue),
              _BigStat('💰', 'Budget Left', '₹${p.totalBudgetLeft.toStringAsFixed(0)}', 'Across all trips', AppColors.rose),
            ],
          ),
          const SizedBox(height: 24),
          const SectionLabel('Habit Performance'),
          ...p.habits.map((h) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [Text(h.icon, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8),
                  Text(h.name, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
                Row(children: [
                  Text('🔥 ${h.streak}', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: h.color)),
                  const SizedBox(width: 10),
                  Text('Best: ${h.bestStreak}', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                ]),
              ]),
              const SizedBox(height: 8),
              AppProgressBar(percent: h.bestStreak > 0 ? h.streak / h.bestStreak : 0, color: h.color),
            ]),
          )),
          const SizedBox(height: 16),
          const SectionLabel('Trips Overview'),
          ...p.trips.map((trip) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${trip.emoji} ${trip.name}', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('${(trip.packingPercent * 100).round()}%', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blue)),
              ]),
              const SizedBox(height: 8),
              AppProgressBar(percent: trip.packingPercent, color: AppColors.blue),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Budget: ₹${trip.budget.toStringAsFixed(0)}', style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
                Text('Spent: ₹${trip.spent.toStringAsFixed(0)}', style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
              ]),
            ]),
          )),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String icon, title, value, sub;
  final Color color;
  const _BigStat(this.icon, this.title, this.value, this.sub, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.15), AppColors.card]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const Spacer(),
        Text(value, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: color, height: 1)),
        Text(title, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(sub, style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late String _avatar;
  late String _travelStyle;
  late String _diet;

  static const _avatars = ['🧭', '🧳', '🌍', '🚀', '🎯', '🌟', '🦋', '⚡'];
  static const _styles = ['Adventure', 'Luxury', 'Budget', 'Business', 'Cultural', 'Beach', 'Family'];
  static const _diets = ['No restrictions', 'Vegetarian', 'Vegan', 'Gluten-free', 'Diabetic', 'Halal'];

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().profile;
    _nameCtrl = TextEditingController(text: profile.name);
    _avatar = profile.avatar;
    _travelStyle = profile.travelStyle;
    _diet = profile.diet;
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _save() {
    context.read<AppProvider>().updateProfile(ProfileModel(
      name: _nameCtrl.text.trim().isEmpty ? 'Alex' : _nameCtrl.text.trim(),
      avatar: _avatar, travelStyle: _travelStyle, diet: _diet, completeness: 85,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Life DNA saved! ✅', style: GoogleFonts.sora()), backgroundColor: AppColors.teal, behavior: SnackBarBehavior.floating));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub), onPressed: () => Navigator.pop(context)),
        title: Text('🧬 Life DNA', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: _save, child: Text('Save', style: GoogleFonts.sora(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 15))),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // Profile header
          Center(child: Column(children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.accent, AppColors.rose])),
              child: Center(child: Text(_avatar, style: const TextStyle(fontSize: 40)))),
            const SizedBox(height: 12),
            Text(_nameCtrl.text.isEmpty ? 'Your Name' : _nameCtrl.text,
              style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ])),
          const SizedBox(height: 28),
          const SectionLabel('Your Name'),
          TextField(controller: _nameCtrl, onChanged: (_) => setState(() {}),
            style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(hintText: 'Enter your name', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20))),
          const SizedBox(height: 24),
          const SectionLabel('Choose Avatar'),
          Wrap(spacing: 10, runSpacing: 10, children: _avatars.map((a) =>
            GestureDetector(onTap: () => setState(() => _avatar = a),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                width: 52, height: 52,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _avatar == a ? AppColors.accent : AppColors.border, width: 2),
                  color: _avatar == a ? AppColors.accentSoft : AppColors.card),
                child: Center(child: Text(a, style: const TextStyle(fontSize: 26)))))).toList()),
          const SizedBox(height: 24),
          const SectionLabel('Travel Style'),
          Wrap(spacing: 8, runSpacing: 8, children: _styles.map((s) =>
            GestureDetector(onTap: () => setState(() => _travelStyle = s),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  color: _travelStyle == s ? AppColors.blue : AppColors.card,
                  border: Border.all(color: _travelStyle == s ? AppColors.blue : AppColors.border)),
                child: Text(s, style: GoogleFonts.sora(fontSize: 12, color: _travelStyle == s ? Colors.white : AppColors.textSub))))).toList()),
          const SizedBox(height: 24),
          const SectionLabel('Dietary Preference'),
          Wrap(spacing: 8, runSpacing: 8, children: _diets.map((d) =>
            GestureDetector(onTap: () => setState(() => _diet = d),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  color: _diet == d ? AppColors.teal : AppColors.card,
                  border: Border.all(color: _diet == d ? AppColors.teal : AppColors.border)),
                child: Text(d, style: GoogleFonts.sora(fontSize: 12, color: _diet == d ? Colors.black : AppColors.textSub))))).toList()),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text('Save Life DNA →', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)))),
          const SizedBox(height: 20),
          Center(child: GestureDetector(
            onTap: () { context.read<AppProvider>().logout(); Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); },
            child: Text('Sign Out', style: GoogleFonts.sora(color: AppColors.rose, fontSize: 13, fontWeight: FontWeight.w600)))),
        ],
      ),
    );
  }
}
