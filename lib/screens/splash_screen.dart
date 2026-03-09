import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../services/llm_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoCtrl, curve: const Interval(0.0, 0.5)));
    _textOpacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(_textCtrl);
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _textCtrl, curve: Curves.easeOut));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 2600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final appProvider = context.read<AppProvider>();
    final llmService = context.read<LLMService>();

    if (!appProvider.onboardingDone) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (!appProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
    } else if (!llmService.isReady &&
        llmService.status == LLMStatus.needsDownload) {
      // First time after login — prompt to download model
      Navigator.pushReplacementNamed(context, '/download');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Ambient glows
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.blue.withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 50, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.teal.withOpacity(0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accent, AppColors.rose],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                            child: Text('🧭',
                                style: TextStyle(fontSize: 48))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(children: [
                        Text(
                          'LifeMap',
                          style: GoogleFonts.sora(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Life, Mapped.',
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: AppColors.accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Powered by Gemma 3 · On-Device AI',
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom loader
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: 40, height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.accent),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
