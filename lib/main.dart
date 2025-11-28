import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/task_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/debug_wrapper.dart';

void main() async {
  // Add error boundary
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Load .env file (with error handling for web)
      try {
        await dotenv.load(fileName: ".env");
        print('✅ .env file loaded successfully');
      } catch (e) {
        print('⚠️ Warning: Could not load .env file: $e');
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );

      // Auto-login
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: SupabaseConfig.adminEmail,
          password: SupabaseConfig.adminPassword,
        );
        print('✅ Auto-login successful');
      } catch (e) {
        print('⚠️ Auto-login failed: $e');
      }

      final taskProvider = TaskProvider();
      final profileProvider = ProfileProvider();
      final themeProvider = ThemeProvider();

      // Load data
      try {
        await Future.wait([
          taskProvider.loadTasks(),
          profileProvider.loadProfile(),
          themeProvider.loadTheme(),
        ]);
        print('✅ Data loaded successfully');
      } catch (e) {
        print('⚠️ Warning: Could not load data: $e');
      }

      print('🚀 Starting app...');

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

      print('✅ App started successfully');
    },
    (error, stack) {
      print('❌ Fatal error: $error');
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
          home: const DebugWrapper(screenName: 'HomeScreen', child: HomeScreen()),
          builder: (context, child) {
            // Error boundary widget
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return Material(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Oops! Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            details.exception.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            };
            return child ?? const SizedBox();
          },
        );
      },
    );
  }
}
