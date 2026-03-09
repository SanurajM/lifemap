import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── Progress Ring ─────────────────────────────────────────────────────────────
class ProgressRing extends StatelessWidget {
  final double percent;
  final double size;
  final Color color;
  final String label;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 48,
    required this.color,
    required this.label,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(percent: percent, color: color, strokeWidth: strokeWidth),
          ),
          Text(label, style: GoogleFonts.sora(fontSize: size * 0.2, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.percent, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Animated Progress Bar ─────────────────────────────────────────────────────
class AppProgressBar extends StatelessWidget {
  final double percent;
  final Color color;
  final double height;
  final Color? secondColor;

  const AppProgressBar({
    super.key,
    required this.percent,
    required this.color,
    this.height = 4,
    this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: AppColors.border),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            widthFactor: percent.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: secondColor != null
                    ? LinearGradient(colors: [color, secondColor!])
                    : null,
                color: secondColor == null ? color : null,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Card ──────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: accentColor != null ? null : AppColors.card,
          gradient: accentColor != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentColor!.withOpacity(0.15), AppColors.card],
                )
              : null,
          border: Border.all(
            color: accentColor != null ? accentColor!.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── App Badge ─────────────────────────────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String text;
  final Color color;

  const AppBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
      ),
    );
  }
}

// ── Glow Dot ──────────────────────────────────────────────────────────────────
class GlowDot extends StatelessWidget {
  final Color color;
  const GlowDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.sora(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: AppColors.textMuted, letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ── Checklist Item ────────────────────────────────────────────────────────────
class ChecklistItem extends StatelessWidget {
  final String text;
  final bool isDone;
  final VoidCallback onToggle;
  final Color color;
  final int? streak;
  final bool isImportant;

  const ChecklistItem({
    super.key,
    required this.text,
    required this.isDone,
    required this.onToggle,
    required this.color,
    this.streak,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDone ? color.withOpacity(0.1) : AppColors.surface,
          border: Border.all(
            color: isDone ? color.withOpacity(0.35) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isDone ? color : Colors.transparent,
                border: Border.all(color: isDone ? color : AppColors.border, width: 2),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 13, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (streak != null && streak! > 0)
              AppBadge(text: '🔥$streak', color: AppColors.accent),
            if (isImportant && (streak == null || streak == 0))
              AppBadge(text: '!', color: AppColors.rose),
          ],
        ),
      ),
    );
  }
}

// ── App Button ────────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;
  final bool isSmall;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
    this.isSmall = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 14 : 24,
          vertical: isSmall ? 8 : 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isOutlined ? c.withOpacity(0.12) : c,
          border: isOutlined ? Border.all(color: c) : null,
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: isOutlined ? c : Colors.black, strokeWidth: 2),
              )
            : Text(
                text,
                style: GoogleFonts.sora(
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? c : (c == AppColors.accent ? Colors.black : Colors.white),
                ),
              ),
      ),
    );
  }
}

// ── Stat Mini Card ────────────────────────────────────────────────────────────
class StatMiniCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const StatMiniCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.sora(fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
