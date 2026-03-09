import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/llm_service.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});
  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Auto-check status after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _checkAndNavigate() {
    final llm = context.read<LLMService>();
    // If already ready, go straight home
    if (llm.isReady) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onStatusChange(LLMService llm) {
    if (llm.isReady && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LLMService>(
      builder: (context, llm, _) {
        // Navigate when ready
        WidgetsBinding.instance.addPostFrameCallback((_) => _onStatusChange(llm));

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              // Ambient glow
              Positioned(
                top: 0, left: -80,
                child: Container(
                  width: 350, height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.violet.withOpacity(0.12),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: -60,
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.teal.withOpacity(0.10),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Animated icon
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Transform.scale(
                          scale: llm.status == LLMStatus.downloading
                              ? _pulseAnim.value
                              : 1.0,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _iconColors(llm.status),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _iconColors(llm.status).first
                                      .withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _icon(llm.status),
                                style: const TextStyle(fontSize: 46),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        _title(llm.status),
                        style: GoogleFonts.sora(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        llm.statusMessage,
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          color: AppColors.textSub,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Progress bar (downloading)
                      if (llm.status == LLMStatus.downloading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: llm.downloadProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.violet),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(llm.downloadProgress * 100).toStringAsFixed(1)}%',
                              style: GoogleFonts.sora(
                                  fontSize: 12, color: AppColors.violet, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Gemma 3 1B · ~600 MB',
                              style: GoogleFonts.sora(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],

                      // Loading spinner
                      if (llm.status == LLMStatus.loading ||
                          llm.status == LLMStatus.checking)
                        SizedBox(
                          width: 36, height: 36,
                          child: CircularProgressIndicator(
                            color: _iconColors(llm.status).first,
                            strokeWidth: 3,
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Info cards — shown before download
                      if (llm.status == LLMStatus.needsDownload ||
                          llm.status == LLMStatus.error) ...[
                        ..._infoItems.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: (item['color'] as Color).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(item['icon']?.toString()??"",
                                          style: const TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title']?.toString()??"",
                                            style: GoogleFonts.sora(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary)),
                                        Text(item['sub']?.toString()??"",
                                            style: GoogleFonts.sora(
                                                fontSize: 11,
                                                color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],

                      const Spacer(flex: 3),

                      // Action button
                      if (llm.status == LLMStatus.needsDownload ||
                          llm.status == LLMStatus.error) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => llm.downloadModel(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.violet,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              llm.status == LLMStatus.error
                                  ? '🔄 Retry Download'
                                  : '⬇️ Download AI Model (600 MB)',
                              style: GoogleFonts.sora(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Skip for now
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/home'),
                          child: Text(
                            'Skip for now (limited AI)',
                            style: GoogleFonts.sora(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _icon(LLMStatus s) {
    switch (s) {
      case LLMStatus.needsDownload: return '🤖';
      case LLMStatus.downloading: return '⬇️';
      case LLMStatus.loading: return '⚙️';
      case LLMStatus.ready: return '✅';
      case LLMStatus.error: return '⚠️';
      default: return '🔍';
    }
  }

  String _title(LLMStatus s) {
    switch (s) {
      case LLMStatus.needsDownload: return 'Download\nOn-Device AI';
      case LLMStatus.downloading: return 'Downloading\nGemma 3 1B...';
      case LLMStatus.loading: return 'Loading\nAI Model...';
      case LLMStatus.ready: return 'AI Ready!';
      case LLMStatus.error: return 'Download\nFailed';
      default: return 'Checking...';
    }
  }

  List<Color> _iconColors(LLMStatus s) {
    switch (s) {
      case LLMStatus.downloading: return [AppColors.violet, AppColors.blue];
      case LLMStatus.loading: return [AppColors.teal, AppColors.blue];
      case LLMStatus.ready: return [AppColors.teal, AppColors.blue];
      case LLMStatus.error: return [AppColors.rose, AppColors.accent];
      default: return [AppColors.violet, AppColors.rose];
    }
  }

  static final _infoItems = [
    {
      'icon': '🔒',
      'title': '100% Private',
      'sub': 'Runs entirely on your device. No data leaves your phone.',
      'color': AppColors.teal,
    },
    {
      'icon': '✈️',
      'title': 'Works Offline',
      'sub': 'Full AI even without internet — perfect for travel.',
      'color': AppColors.blue,
    },
    {
      'icon': '⚡',
      'title': 'GPU Accelerated',
      'sub': 'Fast responses using your phone\'s GPU via MediaPipe.',
      'color': AppColors.accent,
    },
    {
      'icon': '📦',
      'title': 'One-Time Download',
      'sub': 'Gemma 3 1B int4 · ~600 MB · Stored on device forever.',
      'color': AppColors.violet,
    },
  ];
}
