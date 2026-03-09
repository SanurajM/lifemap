import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/widgets.dart';
import 'daily_screen.dart' show HabitsScreen, MovingScreen, StatsScreen, ProfileScreen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<int> _dismissedTips = [];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final trip = p.trips.isNotEmpty ? p.trips.first : null;
    final event = p.events.isNotEmpty ? p.events.first : null;

    final tips = <Map<String, dynamic>>[
      if (trip != null) {'icon': '🌧️', 'text': 'Rain expected in ${trip.destination.split(',')[0]} Day 3 — pack a raincoat!', 'color': AppColors.blue},
      if (trip != null) {'icon': '⚡', 'text': 'Power bank is still unpacked! ${trip.daysUntil} days to go.', 'color': AppColors.warning},
      if (event != null) {'icon': '🎂', 'text': '${event.name} in ${event.daysUntil} days — ${(event.taskPercent * 100).round()}% tasks done.', 'color': AppColors.rose},
      {'icon': '🔥', 'text': '${p.topStreak}-day streak! Keep it going tonight.', 'color': AppColors.teal},
    ].asMap().entries.where((e) => !_dismissedTips.contains(e.key)).map((e) => e.value).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bg,
            expandedHeight: 0,
            floating: true,
            snap: true,
            elevation: 0,
            actions: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 2),
                    color: AppColors.accentSoft,
                  ),
                  child: Center(child: Text(p.profile.avatar, style: const TextStyle(fontSize: 20))),
                ),
              ),
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1.5)),
                RichText(text: TextSpan(children: [
                  TextSpan(text: "${p.profile.name}'s ", style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w300, color: AppColors.textPrimary)),
                  TextSpan(text: 'LifeMap', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ])),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats
                Row(children: [
                  StatMiniCard(icon: '✈️', value: '${p.trips.length}', label: 'Trips', color: AppColors.blue),
                  const SizedBox(width: 10),
                  StatMiniCard(icon: '🔥', value: '${p.topStreak}d', label: 'Streak', color: AppColors.teal),
                  const SizedBox(width: 10),
                  StatMiniCard(icon: '☀️', value: '${p.totalDailyDone}/${p.dailyTasks.length}', label: 'Today', color: AppColors.accent),
                ]),
                const SizedBox(height: 24),

                // AI Suggestions
                if (tips.isNotEmpty) ...[
                  SectionLabel('🤖 AI Suggestions'),
                  ...tips.asMap().entries.map((entry) => _TipCard(
                    tip: entry.value,
                    onDismiss: () => setState(() => _dismissedTips.add(entry.key)),
                  )),
                  AppCard(
                    onTap: () {},
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('💬 Ask AI anything', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 16),
                    ]),
                  ),
                  const SizedBox(height: 24),
                ],

                // Upcoming Trip
                if (trip != null) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const SectionLabel('Upcoming Trip'),
                    TextButton(onPressed: () {}, child: Text('View all →', style: GoogleFonts.sora(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.w600))),
                  ]),
                  AppCard(
                    accentColor: AppColors.blue,
                    onTap: () {},
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [GlowDot(color: AppColors.blue), const SizedBox(width: 6),
                            Text('In ${trip.daysUntil} days', style: GoogleFonts.sora(fontSize: 10, color: AppColors.blue, letterSpacing: 1))]),
                          const SizedBox(height: 4),
                          Text('${trip.emoji} ${trip.name}', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
                          Text(trip.destination, style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          Row(children: [
                            AppBadge(text: trip.tripType, color: AppColors.blue),
                            const SizedBox(width: 6),
                            AppBadge(text: '₹${(trip.budget - trip.spent).toStringAsFixed(0)} left', color: AppColors.accent),
                          ]),
                        ]),
                        ProgressRing(percent: trip.packingPercent, size: 56, color: AppColors.blue, label: '${(trip.packingPercent * 100).round()}%'),
                      ]),
                      const SizedBox(height: 12),
                      AppProgressBar(percent: trip.packingPercent, color: AppColors.blue, secondColor: AppColors.teal, height: 5),
                      const SizedBox(height: 6),
                      Text('${trip.packedCount}/${trip.totalItems} packed', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                    ]),
                  ),
                  const SizedBox(height: 24),
                ],

                // Life moments 2x2 grid
                SectionLabel('Life Moments'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                  children: [
                    _MomentCard(icon: '☀️', title: 'Daily Routine', subtitle: '${p.totalDailyDone}/${p.dailyTasks.length} done',
                      color: AppColors.teal, progress: p.dailyTasks.isEmpty ? 0 : p.totalDailyDone / p.dailyTasks.length, onTap: () {}),
                    if (event != null)
                      _MomentCard(icon: '🎉', title: 'Events', subtitle: 'In ${event.daysUntil} days',
                        color: AppColors.rose, progress: event.taskPercent, onTap: () {}),
                    _MomentCard(icon: '🏠', title: 'Moving Home', subtitle: 'May 1 · ${p.moving.moveDate.difference(DateTime.now()).inDays}d',
                      color: AppColors.violet, progress: p.moving.progress,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MovingScreen()))),
                    _MomentCard(icon: '🔥', title: 'Habits', subtitle: 'Best: ${p.topStreak}-day streak',
                      color: AppColors.accent, progress: p.topStreak / 30,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitsScreen()))),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick links
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Center(child: Text('📊 Life Stats', style: GoogleFonts.sora(color: AppColors.textSub, fontSize: 13, fontWeight: FontWeight.w600)))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accent.withOpacity(0.4))),
                        child: Center(child: Text('🤖 AI Assistant', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)))),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Life DNA
                AppCard(
                  child: Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [AppColors.accent, AppColors.rose])),
                      child: const Center(child: Text('🧬', style: TextStyle(fontSize: 22)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Life DNA — ${p.profile.completeness}% complete',
                        style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                      Text('Complete for smarter AI suggestions', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      AppProgressBar(percent: p.profile.completeness / 100, color: AppColors.accent, secondColor: AppColors.rose),
                    ])),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
                        child: Text('Edit', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700))),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Map<String, dynamic> tip;
  final VoidCallback onDismiss;
  const _TipCard({required this.tip, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final color = tip['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Text(tip['icon'], style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(tip['text'], style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSub, height: 1.5))),
        GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, color: AppColors.textMuted, size: 16)),
      ]),
    );
  }
}

class _MomentCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final double progress;
  final VoidCallback onTap;
  const _MomentCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), AppColors.card]),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const Spacer(),
          Text(title, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(subtitle, style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          AppProgressBar(percent: progress.clamp(0.0, 1.0), color: color),
        ]),
      ),
    );
  }
}
