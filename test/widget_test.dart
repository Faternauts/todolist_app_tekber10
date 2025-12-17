// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';

void main() {
  testWidgets('Providers can be used in widget tree', (WidgetTester tester) async {
    // Set up providers for testing
    final taskProvider = TaskProvider();
    final profileProvider = ProfileProvider();
    final themeProvider = ThemeProvider();

    // Build a simple widget that uses the providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: taskProvider),
          ChangeNotifierProvider.value(value: profileProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Verify providers are accessible
                final theme = Provider.of<ThemeProvider>(context);
                final task = Provider.of<TaskProvider>(context);
                final profile = Provider.of<ProfileProvider>(context);

                return Center(
                  child: Text(
                    'Theme: ${theme.themeMode}, Tasks: ${task.allTasks.length}, Profile: ${profile.profile.name}',
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Verify that the widget builds successfully and providers are accessible
    expect(find.byType(Text), findsOneWidget);
    expect(find.textContaining('Theme:'), findsOneWidget);
  });
}
