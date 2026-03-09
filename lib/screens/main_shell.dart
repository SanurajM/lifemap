import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'trips/trips_screen.dart';
import 'daily_screen.dart';
import 'events/events_screen.dart';
import 'chat_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TripsScreen(),
    DailyScreen(),
    EventsScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: '🧭', label: 'Home', index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: '✈️', label: 'Trips', index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: '☀️', label: 'Daily', index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: '🎉', label: 'Events', index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: '🤖', label: 'AI', index: 4, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? AppColors.accentSoft : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: 20, color: isActive ? null : Colors.white.withOpacity(0.3))),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.sora(
              fontSize: 9, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.accent : AppColors.textMuted,
            )),
            if (isActive) Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}
