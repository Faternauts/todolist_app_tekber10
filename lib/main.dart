import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/supabase_config.dart';
import 'providers/task_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");

      // Initialize Supabase
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );

      final taskProvider = TaskProvider();
      final profileProvider = ProfileProvider();
      final themeProvider = ThemeProvider();

      // Load theme first (doesn't require auth)
      try {
        await themeProvider.loadTheme();
      } catch (e) {
        print('Warning: Could not load theme: $e');
      }

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: profileProvider),
            ChangeNotifierProvider.value(value: themeProvider),
          ],
          child: const MyApp(),
        ),
      );

    },
    (error, stack) {
      print('Stack trace: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'To-Do List App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthCheck(),
        );
      },
    );
  }
}

/// Widget to check authentication state
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid navigation during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Check if user is logged in
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      // User is logged in, load data      
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      try {
        await Future.wait([
          taskProvider.loadTasks(),
          profileProvider.loadProfile(),
        ]);
      } catch (e) {
        print(' Warning: Could not load data: $e');
      }
      
      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Always go to onboarding if not logged in
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking auth
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
