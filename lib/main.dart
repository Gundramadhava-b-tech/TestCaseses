import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/upload_scan_screen.dart';
import 'screens/analysis_results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_topbar.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting();
  } catch (e) {
    debugPrint('DateFormatting error: $e');
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const AeroDiagApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AeroDiagApp extends StatefulWidget {
  const AeroDiagApp({super.key});

  @override
  State<AeroDiagApp> createState() => _AeroDiagAppState();
}

class _AeroDiagAppState extends State<AeroDiagApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _router = GoRouter(
      initialLocation: '/',
      navigatorKey: _rootNavigatorKey,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isSignInPage = state.matchedLocation == '/sign-in';
        final isSignUpPage = state.matchedLocation == '/sign-up';
        final isLandingPage = state.matchedLocation == '/';

        if (!isAuthenticated && !isSignInPage && !isSignUpPage && !isLandingPage) {
          return '/sign-in';
        }
        if (isAuthenticated && (isSignInPage || isSignUpPage)) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            final isMobile = MediaQuery.of(context).size.width < 1024;
            return Scaffold(
              drawer: isMobile ? AppSidebar(activeRoute: state.matchedLocation) : null,
              body: SafeArea(
                child: Row(
                  children: [
                    if (!isMobile) AppSidebar(activeRoute: state.matchedLocation),
                    Expanded(
                      child: Column(
                        children: [
                          const AppTopBar(),
                          Expanded(child: child),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/patients',
              builder: (context, state) => const PatientsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return PatientDetailScreen(patientId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/upload',
              builder: (context, state) {
                final patientId = state.uri.queryParameters['patientId'];
                return UploadScanScreen(preSelectedPatientId: patientId);
              },
            ),
            GoRoute(
              path: '/analyses',
              builder: (context, state) {
                final filter = state.uri.queryParameters['filter'];
                return AnalysisResultsScreen(initialFilter: filter);
              },
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return MaterialApp.router(
      title: 'AeroDiag',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('te', 'IN'),
        Locale('ta', 'IN'),
        Locale('hi', 'IN'),
      ],
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
