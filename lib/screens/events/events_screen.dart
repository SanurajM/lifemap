import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

// ── EVENTS LIST ───────────────────────────────────────────────────────────────
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _showCreate = false;
  final _nameCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 20));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _venueCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _create(AppProvider p) {
    if (_nameCtrl.text.trim().isEmpty) return;
    p.addEvent(EventModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameCtrl.text.trim(),
      date: _date,
      venue: _venueCtrl.text.trim(),
      budget: double.tryParse(_budgetCtrl.text) ?? 0,
      tasks: [
        EventTask(id: 1, text: 'Send invites'),
        EventTask(id: 2, text: 'Arrange venue'),
        EventTask(id: 3, text: 'Plan food / catering'),
      ],
    ));
    _nameCtrl.clear();
    _venueCtrl.clear();
    _budgetCtrl.clear();
    setState(() => _showCreate = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text('🎉 Events', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _showCreate = !_showCreate),
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(20)),
                  child: Text('+ New', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_showCreate) ...[
                  AppCard(
                    accentColor: AppColors.rose,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Create New Event', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.rose, fontSize: 14)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(hintText: "Event name (e.g. Priya's Wedding)"),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _venueCtrl,
                        style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Venue'),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 16),
                            const SizedBox(width: 10),
                            Text('${_date.day}/${_date.month}/${_date.year}',
                                style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSub)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _budgetCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Budget (₹)'),
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        AppButton(text: 'Create Event', onPressed: () => _create(p), color: AppColors.rose, isSmall: true),
                        const SizedBox(width: 10),
                        AppButton(text: 'Cancel', onPressed: () => setState(() => _showCreate = false),
                            color: AppColors.textMuted, isOutlined: true, isSmall: true),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                if (p.events.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(children: [
                        const Text('🎉', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No events yet', style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 6),
                        Text('Tap + New to plan one', style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 12)),
                      ]),
                    ),
                  )
                else
                  ...p.events.map((event) => _EventCard(
                        event: event,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id))),
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        accentColor: AppColors.rose,
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AppBadge(text: 'In ${event.daysUntil}d', color: AppColors.rose),
            const SizedBox(width: 6),
            AppBadge(text: '👥 ${event.confirmedGuests} coming', color: AppColors.teal),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${event.emoji} ${event.name}',
                    style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(event.venue, style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  'Budget: ₹${event.budget.toStringAsFixed(0)} · Tasks: ${event.tasksDone}/${event.tasks.length}',
                  style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSub),
                ),
              ]),
            ),
            ProgressRing(
                percent: event.taskPercent, size: 48, color: AppColors.rose,
                label: '${(event.taskPercent * 100).round()}%'),
          ]),
          const SizedBox(height: 10),
          AppProgressBar(percent: event.taskPercent, color: AppColors.rose),
        ]),
      ),
    );
  }
}

// ── EVENT DETAIL ──────────────────────────────────────────────────────────────
class EventDetailScreen extends StatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _taskCtrl = TextEditingController();
  final _guestCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _taskCtrl.dispose();
    _guestCtrl.dispose();
    super.dispose();
  }

  Color _guestColor(String status) {
    switch (status) {
      case 'confirmed': return AppColors.teal;
      case 'declined': return AppColors.textMuted;
      case 'host': return AppColors.accent;
      default: return AppColors.warning;
    }
  }

  String _guestEmoji(String status) {
    switch (status) {
      case 'confirmed': return '✅';
      case 'declined': return '❌';
      case 'host': return '👑';
      default: return '⏳';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final event = p.events.firstWhere((e) => e.id == widget.eventId);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppColors.bg,
            expandedHeight: 190,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.rose.withOpacity(0.25), AppColors.bg],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${event.emoji} ${event.name}',
                          style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text(event.venue, style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Row(children: [
                        AppBadge(text: 'In ${event.daysUntil} days', color: AppColors.rose),
                        const SizedBox(width: 6),
                        AppBadge(text: '👥 ${event.confirmedGuests} coming', color: AppColors.teal),
                      ]),
                    ]),
                    ProgressRing(percent: event.taskPercent, size: 52, color: AppColors.rose,
                        label: '${(event.taskPercent * 100).round()}%'),
                  ]),
                  if (event.daysUntil <= 30) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      _CountdownBox('${event.daysUntil}', 'Days Left', AppColors.rose),
                      const SizedBox(width: 8),
                      _CountdownBox('${event.tasks.length - event.tasksDone}', 'Tasks Left', AppColors.warning),
                      const SizedBox(width: 8),
                      _CountdownBox(
                          '${event.guests.where((g) => g.status == 'pending').length}',
                          'Pending RSVPs', AppColors.blue),
                    ]),
                  ],
                ]),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.rose,
              labelColor: AppColors.rose,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: const [Tab(text: '✅ Tasks'), Tab(text: '👥 Guests')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // Tasks Tab
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...event.tasks.map((t) => ChecklistItem(
                      text: t.text,
                      isDone: t.isDone,
                      onToggle: () => p.toggleEventTask(event.id, t.id),
                      color: AppColors.rose,
                    )),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _taskCtrl,
                      style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Add a task...'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    text: 'Add',
                    isSmall: true,
                    color: AppColors.rose,
                    onPressed: () {
                      if (_taskCtrl.text.trim().isEmpty) return;
                      p.addEventTask(event.id,
                          EventTask(id: DateTime.now().millisecondsSinceEpoch, text: _taskCtrl.text.trim()));
                      _taskCtrl.clear();
                    },
                  ),
                ]),
              ],
            ),

            // Guests Tab
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(children: [
                  GlowDot(color: AppColors.teal), const SizedBox(width: 6),
                  Text('confirmed', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(width: 14),
                  GlowDot(color: AppColors.warning), const SizedBox(width: 6),
                  Text('pending', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(width: 14),
                  GlowDot(color: AppColors.textMuted), const SizedBox(width: 6),
                  Text('declined', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                ]),
                const SizedBox(height: 14),
                ...event.guests.map((g) => GestureDetector(
                      onTap: () => p.cycleGuestStatus(event.id, g.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surface,
                          border: Border.all(color: _guestColor(g.status).withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _guestColor(g.status).withOpacity(0.15),
                              border: Border.all(color: _guestColor(g.status)),
                            ),
                            child: Center(child: Text(_guestEmoji(g.status), style: const TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(g.name,
                                style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ),
                          AppBadge(text: g.status, color: _guestColor(g.status)),
                        ]),
                      ),
                    )),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _guestCtrl,
                      style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'Guest name...'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    text: 'Invite',
                    isSmall: true,
                    color: AppColors.rose,
                    onPressed: () {
                      if (_guestCtrl.text.trim().isEmpty) return;
                      p.addGuest(event.id,
                          EventGuest(id: DateTime.now().millisecondsSinceEpoch, name: _guestCtrl.text.trim()));
                      _guestCtrl.clear();
                    },
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _CountdownBox(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.sora(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
