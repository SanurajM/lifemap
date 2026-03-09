import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '🧭',
      title: 'Welcome to\nLifeMap',
      subtitle: 'Your intelligent life organizer.\nTrips, habits, events — all in one place.',
      color: AppColors.blue,
      gradient: [Color(0xFF4A9EFF), Color(0xFF00D4AA)],
    ),
    _OnboardPage(
      emoji: '✈️',
      title: 'Plan Every\nTrip Perfectly',
      subtitle: 'AI-powered packing lists, itineraries, and budget tracking for stress-free travel.',
      color: AppColors.teal,
      gradient: [Color(0xFF00D4AA), Color(0xFF4A9EFF)],
    ),
    _OnboardPage(
      emoji: '🔥',
      title: 'Build Winning\nHabits',
      subtitle: 'Track streaks, daily routines, and life goals with your AI accountability partner.',
      color: AppColors.accent,
      gradient: [Color(0xFFF5A623), Color(0xFFFF6B8A)],
    ),
    _OnboardPage(
      emoji: '🤖',
      title: 'Your AI Life\nAssistant',
      subtitle: 'Ask anything. Get personalized suggestions based on your life profile and goals.',
      color: AppColors.violet,
      gradient: [Color(0xFFA78BFA), Color(0xFFFF6B8A)],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<AppProvider>().setOnboardingDone();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _pages[i],
          ),
          // Bottom controls
          Positioned(
            bottom: 50, left: 24, right: 24,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: WormEffect(
                    dotColor: AppColors.border,
                    activeDotColor: _pages[_currentPage].color,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _finish,
                        child: Text('Skip',
                            style: GoogleFonts.sora(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      )
                    else
                      const SizedBox(width: 80),
                    GestureDetector(
                      onTap: _next,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == _pages.length - 1 ? 180 : 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(colors: _pages[_currentPage].gradient),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[_currentPage].color.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _currentPage == _pages.length - 1
                              ? Text('Get Started!',
                                  style: GoogleFonts.sora(
                                      color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15))
                              : const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 24),
                        ),
                      ),
                    ),
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

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradient;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BG glow
        Positioned(
          top: 100, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Emoji in gradient card
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.35), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 56))),
              ),
              const SizedBox(height: 48),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSub,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
