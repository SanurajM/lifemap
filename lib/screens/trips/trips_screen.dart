import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

// ── TRIPS LIST ────────────────────────────────────────────────────────────────
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});
  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  bool _showCreate = false;
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String _type = 'Beach';
  DateTime _start = DateTime.now().add(const Duration(days: 30));
  DateTime _end = DateTime.now().add(const Duration(days: 35));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _create(AppProvider p) {
    if (_nameCtrl.text.trim().isEmpty || _destCtrl.text.trim().isEmpty) return;
    p.addTrip(TripModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameCtrl.text.trim(),
      destination: _destCtrl.text.trim(),
      startDate: _start,
      endDate: _end,
      tripType: _type,
      budget: double.tryParse(_budgetCtrl.text) ?? 0,
      items: [
        PackingItem(id: 1, category: 'Documents', text: 'ID / Passport'),
        PackingItem(id: 2, category: 'Clothing', text: 'Clothes for each day'),
        PackingItem(id: 3, category: 'Electronics', text: 'Phone charger'),
        PackingItem(id: 4, category: 'Health', text: 'Personal medication'),
        PackingItem(id: 5, category: 'Money', text: 'Cash / Cards'),
      ],
    ));
    _nameCtrl.clear(); _destCtrl.clear(); _budgetCtrl.clear();
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
            title: Text('✈️ Trips', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _showCreate = !_showCreate),
                child: Container(margin: const EdgeInsets.only(right: 20), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
                  child: Text('+ New', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black))),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_showCreate) ...[
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Plan New Trip', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 14)),
                      const SizedBox(height: 12),
                      TextField(controller: _nameCtrl, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Trip name (e.g. Kerala Road Trip)')),
                      const SizedBox(height: 8),
                      TextField(controller: _destCtrl, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Destination')),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: GestureDetector(
                          onTap: () async {
                            final d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)));
                            if (d != null) setState(() => _start = d);
                          },
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Text('${_start.day}/${_start.month}/${_start.year}', style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSub))),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: GestureDetector(
                          onTap: () async {
                            final d = await showDatePicker(context: context, initialDate: _end, firstDate: _start, lastDate: DateTime.now().add(const Duration(days: 730)));
                            if (d != null) setState(() => _end = d);
                          },
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Text('${_end.day}/${_end.month}/${_end.year}', style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSub))),
                        )),
                      ]),
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                          value: _type, isExpanded: true,
                          dropdownColor: AppColors.card,
                          style: GoogleFonts.sora(fontSize: 13, color: AppColors.textPrimary),
                          items: ['Beach', 'Adventure', 'Business', 'Cultural', 'Leisure', 'Family', 'Romantic']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _type = v!),
                        ))),
                      const SizedBox(height: 8),
                      TextField(controller: _budgetCtrl, keyboardType: TextInputType.number,
                        style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Budget (₹)')),
                      const SizedBox(height: 14),
                      Row(children: [
                        AppButton(text: 'Create Trip', onPressed: () => _create(p), isSmall: true),
                        const SizedBox(width: 10),
                        AppButton(text: 'Cancel', onPressed: () => setState(() => _showCreate = false), color: AppColors.textMuted, isOutlined: true, isSmall: true),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                ...p.trips.map((trip) => _TripCard(trip: trip, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id))))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        accentColor: AppColors.blue,
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AppBadge(text: trip.daysUntil > 0 ? 'In ${trip.daysUntil}d' : 'Active', color: trip.daysUntil > 0 ? AppColors.blue : AppColors.teal),
            const SizedBox(width: 6),
            AppBadge(text: trip.tripType, color: AppColors.textMuted),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${trip.emoji} ${trip.name}', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(trip.destination, style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text('Budget: ₹${trip.budget.toStringAsFixed(0)} · Spent: ₹${trip.spent.toStringAsFixed(0)}', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSub)),
            ])),
            ProgressRing(percent: trip.packingPercent, size: 48, color: AppColors.blue, label: '${(trip.packingPercent * 100).round()}%'),
          ]),
          const SizedBox(height: 10),
          AppProgressBar(percent: trip.packingPercent, color: AppColors.blue),
        ]),
      ),
    );
  }
}

// ── TRIP DETAIL ───────────────────────────────────────────────────────────────
class TripDetailScreen extends StatefulWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});
  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _showAddItem = false;
  final _itemCtrl = TextEditingController();
  String _itemCat = 'Misc';
  final _expLabelCtrl = TextEditingController();
  final _expAmtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _itemCtrl.dispose();
    _expLabelCtrl.dispose();
    _expAmtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final trip = p.trips.firstWhere((t) => t.id == widget.tripId);
    final cats = trip.items.map((i) => i.category).toSet().toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppColors.bg,
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppColors.blue.withOpacity(0.25), AppColors.bg])),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('✈️ In ${trip.daysUntil} days', style: GoogleFonts.sora(fontSize: 11, color: AppColors.blue, letterSpacing: 1)),
                    Text('${trip.emoji} ${trip.name}', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
                    Text('${trip.destination} · ${trip.weather}', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    SizedBox(width: 200, child: AppProgressBar(percent: trip.packingPercent, color: AppColors.blue, secondColor: AppColors.teal, height: 5)),
                    const SizedBox(height: 4),
                    Text('${trip.packedCount}/${trip.totalItems} packed', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                  ]),
                  ProgressRing(percent: trip.packingPercent, size: 56, color: AppColors.blue, label: '${(trip.packingPercent * 100).round()}%'),
                ]),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.blue,
              labelColor: AppColors.blue,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: const [Tab(text: '📦 Packing'), Tab(text: '🗓 Plan'), Tab(text: '💰 Budget')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // TAB 1: Packing
            ListView(padding: const EdgeInsets.all(20), children: [
              Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
                child: Row(children: [const Text('🤖', style: TextStyle(fontSize: 16)), const SizedBox(width: 8),
                  Expanded(child: Text('AI: Rain expected Day 3 — pack a raincoat!', style: GoogleFonts.sora(fontSize: 12, color: AppColors.accent)))])),
              ...cats.map((cat) {
                final catItems = trip.items.where((i) => i.category == cat).toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(bottom: 6),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(cat.toUpperCase(), style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
                      Text('${catItems.where((i) => i.isDone).length}/${catItems.length}', style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
                    ])),
                  ...catItems.map((item) => ChecklistItem(text: item.text, isDone: item.isDone, onToggle: () => p.togglePackingItem(trip.id, item.id), color: AppColors.blue)),
                  const SizedBox(height: 8),
                ]);
              }),
              if (_showAddItem) ...[
                AppCard(child: Column(children: [
                  TextField(controller: _itemCtrl, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'Item name')),
                  const SizedBox(height: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                      value: _itemCat, isExpanded: true, dropdownColor: AppColors.card,
                      style: GoogleFonts.sora(fontSize: 13, color: AppColors.textPrimary),
                      items: [...cats, 'Other'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _itemCat = v!),
                    ))),
                  const SizedBox(height: 10),
                  Row(children: [
                    AppButton(text: 'Add', isSmall: true, onPressed: () {
                      if (_itemCtrl.text.trim().isEmpty) return;
                      p.addPackingItem(trip.id, PackingItem(id: DateTime.now().millisecondsSinceEpoch, category: _itemCat, text: _itemCtrl.text.trim()));
                      _itemCtrl.clear(); setState(() => _showAddItem = false);
                    }),
                    const SizedBox(width: 8),
                    AppButton(text: 'Cancel', isSmall: true, isOutlined: true, color: AppColors.textMuted, onPressed: () => setState(() => _showAddItem = false)),
                  ]),
                ])),
              ] else
                GestureDetector(onTap: () => setState(() => _showAddItem = true),
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, style: BorderStyle.solid)),
                    child: Center(child: Text('+ Add Custom Item', style: GoogleFonts.sora(color: AppColors.textMuted, fontSize: 12))))),
            ]),

            // TAB 2: Itinerary
            ListView(padding: const EdgeInsets.all(20), children: [
              if (trip.itinerary.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(40),
                  child: Column(children: [const Text('🗓', style: TextStyle(fontSize: 40)),
                    Text('No itinerary yet', style: GoogleFonts.sora(color: AppColors.textMuted))]))),
              ...trip.itinerary.asMap().entries.map((e) {
                final i = e.key; final day = e.value;
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.blue.withOpacity(0.15), border: Border.all(color: AppColors.blue)),
                      child: Center(child: Text('${i + 1}', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.blue)))),
                    if (i < trip.itinerary.length - 1) Container(width: 2, height: 32, color: AppColors.border),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 6),
                      Text(day.dayLabel.toUpperCase(), style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(day.plan, style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSub, height: 1.5)),
                    ]))),
                ]);
              }),
            ]),

            // TAB 3: Budget
            ListView(padding: const EdgeInsets.all(20), children: [
              Row(children: [
                _BudgetBox('Budget', '₹${trip.budget.toStringAsFixed(0)}', AppColors.blue),
                const SizedBox(width: 10),
                _BudgetBox('Spent', '₹${trip.spent.toStringAsFixed(0)}', AppColors.rose),
                const SizedBox(width: 10),
                _BudgetBox('Left', '₹${(trip.budget - trip.spent).toStringAsFixed(0)}', AppColors.teal),
              ]),
              const SizedBox(height: 12),
              AppProgressBar(percent: trip.budget > 0 ? trip.spent / trip.budget : 0, color: AppColors.rose, secondColor: AppColors.accent, height: 8),
              const SizedBox(height: 6),
              Text('${trip.budget > 0 ? (trip.spent / trip.budget * 100).round() : 0}% of budget used', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Log Expense', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSub)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextField(controller: _expLabelCtrl, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13), decoration: const InputDecoration(hintText: 'What was it?'))),
                  const SizedBox(width: 8),
                  SizedBox(width: 80, child: TextField(controller: _expAmtCtrl, keyboardType: TextInputType.number, style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 13), decoration: const InputDecoration(hintText: '₹'))),
                  const SizedBox(width: 8),
                  AppButton(text: 'Add', isSmall: true, onPressed: () { _expLabelCtrl.clear(); _expAmtCtrl.clear(); }),
                ]),
              ])),
            ]),
          ],
        ),
      ),
    );
  }
}

class _BudgetBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(value, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: GoogleFonts.sora(fontSize: 10, color: AppColors.textMuted)),
      ]),
    ));
  }
}
