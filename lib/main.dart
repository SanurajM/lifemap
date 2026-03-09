import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/llm_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/main_shell.dart';
import 'screens/model_download_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LifeMapApp());
}

class LifeMapApp extends StatelessWidget {
  const LifeMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        // LLMService is separate so it can be used anywhere
        // It auto-initialises on first access
        ChangeNotifierProvider(create: (_) => LLMService()..initialize()),
      ],
      child: MaterialApp(
        title: 'LifeMap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/download': (_) => const ModelDownloadScreen(),
          '/home': (_) => const MainShell(),
        },
      ),
    );
  }
}
