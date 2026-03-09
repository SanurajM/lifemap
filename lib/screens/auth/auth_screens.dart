import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/widgets.dart';

// ── LOGIN SCREEN ──────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name', style: GoogleFonts.sora()), backgroundColor: AppColors.rose),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await context.read<AppProvider>().login(_nameCtrl.text.trim());
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Ambient glows
            Positioned(top: -80, right: -60,
              child: Container(width: 280, height: 280,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.accent.withOpacity(0.12), Colors.transparent])))),
            Positioned(bottom: 0, left: -80,
              child: Container(width: 260, height: 260,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.blue.withOpacity(0.10), Colors.transparent])))),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                                colors: [AppColors.accent, AppColors.rose]),
                              boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 20)]),
                            child: const Center(child: Text('🧭', style: TextStyle(fontSize: 38)))),
                          const SizedBox(height: 16),
                          Text('LifeMap', style: GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text('Your Life, Mapped.', style: GoogleFonts.sora(fontSize: 13, color: AppColors.accent, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text('Welcome back 👋', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text('Sign in to continue organizing your life', style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSub)),
                    const SizedBox(height: 32),
                    // Fields
                    Text('Your Name', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(hintText: 'Alex', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20)),
                    ),
                    const SizedBox(height: 16),
                    Text('Email', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(hintText: 'alex@example.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20)),
                    ),
                    const SizedBox(height: 16),
                    Text('Password', style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () {}, child: Text('Forgot password?', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 13))),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                            : Text('Sign In', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account? ", style: GoogleFonts.sora(color: AppColors.textSub, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Text('Sign Up', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Quick access
                    Center(
                      child: Column(
                        children: [
                          Text('— or continue as guest —', style: GoogleFonts.sora(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _login(),
                            child: Text('Enter with name above →', style: GoogleFonts.sora(color: AppColors.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── REGISTER SCREEN ───────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name', style: GoogleFonts.sora()), backgroundColor: AppColors.rose),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await context.read<AppProvider>().login(_nameCtrl.text.trim());
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSub),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -60, left: -80,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.teal.withOpacity(0.10), Colors.transparent])))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Create Account 🚀', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Start organizing your life today', style: GoogleFonts.sora(fontSize: 13, color: AppColors.textSub)),
                  const SizedBox(height: 36),
                  _label('Full Name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Your full name', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20)),
                  ),
                  const SizedBox(height: 16),
                  _label('Email'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20)),
                  ),
                  const SizedBox(height: 16),
                  _label('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: GoogleFonts.sora(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'At least 8 characters',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                          : Text('Create Account', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Already have an account? ', style: GoogleFonts.sora(color: AppColors.textSub, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Sign In', style: GoogleFonts.sora(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500));
  }
}
