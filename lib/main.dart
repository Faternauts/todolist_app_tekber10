import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/task_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: SupabaseConfig.adminEmail,
      password: SupabaseConfig.adminPassword,
    );
    print('Auto-login successful');
  } catch (e) {
    print('Auto-login failed: $e');
  }

  final taskProvider = TaskProvider();
  final profileProvider = ProfileProvider();
  final themeProvider = ThemeProvider();

  await Future.wait([
    taskProvider.loadTasks(),
    profileProvider.loadProfile(),
    themeProvider.loadTheme(),
  ]);

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
          home: const HomeScreen(),
        );
      },
    );
  }
}
