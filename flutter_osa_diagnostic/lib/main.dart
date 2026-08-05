import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/app_state.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/upload_scan_screen.dart';
import 'screens/analyses_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const AeroDiagApp(),
    ),
  );
}

class AeroDiagApp extends StatelessWidget {
  const AeroDiagApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final textTheme = GoogleFonts.interTextTheme();

    return MaterialApp(
      title: 'AeroDiag OSA Diagnostic',
      debugShowCheckedModeBanner: false,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue.shade700,
        textTheme: textTheme,
        scaffoldBackgroundColor: const Color(0xFFAFAFA),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue.shade400,
        textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: appState.currentUserEmail != null ? '/dashboard' : '/sign-in',
      routes: {
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/patients': (context) => const PatientsScreen(),
        '/upload': (context) => const UploadScanScreen(),
        '/analyses': (context) => const AnalysesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
