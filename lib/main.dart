import 'package:flutter/material.dart';
import 'screens/app_screens.dart';
import 'services/supabase_api.dart';

void main() => runApp(const SarfealamApp());

class SarfealamApp extends StatefulWidget {
  const SarfealamApp({Key? key}) : super(key: key);

  @override
  State<SarfealamApp> createState() => _SarfealamAppState();
}

class _SarfealamAppState extends State<SarfealamApp> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final session = await SupabaseApi.getLocalSession();
    setState(() {
      _isAuthenticated = session != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatchPulse XI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFF10B981),
          background: const Color(0xFF0B1120),
          surface: const Color(0xFF162032),
          onBackground: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Plus Jakarta Sans',
        cardTheme: CardTheme(
          color: const Color(0xFF162032),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        textTheme: const TextTheme(
          headline4: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8FAFC),
          ),
          bodyText1: TextStyle(
            fontSize: 14,
            color: Color(0xFFF8FAFC),
          ),
        ),
      ),
      home: _isAuthenticated
          ? const HomeDashboardScreen()
          : LoginOrEntryScreen(
              onAuthenticated: () {
                setState(() {
                  _isAuthenticated = true;
                });
              },
            ),
      routes: {
        '/lobby': (context) => const HomeDashboardScreen(),
        '/predict': (context) => const PredictionEntryScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
      },
    );
  }
}