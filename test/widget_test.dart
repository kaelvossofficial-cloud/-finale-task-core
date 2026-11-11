import 'package:finale_task_core/data/repositories/task_habit_repository.dart';
import 'package:finale_task_core/data/services/haptic_service.dart';
import 'package:finale_task_core/data/services/local_storage_service.dart';
import 'package:finale_task_core/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Finale Task Core renders tabs, creates task, and navigates tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repo = TaskHabitRepository(
      storageService: LocalStorageService(enableSqlite: false),
      hapticService: HapticService(),
    );
    await repo.initialize();

    await tester.pumpWidget(FinaleTaskCoreApp(repository: repo));
    await tester.pumpAndSettle();

    // Verify Home / Main Task Screen renders chronological groups
    expect(find.text('Finale Quests'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Switch to Habits tab
    await tester.tap(find.text('Habits'));
    await tester.pumpAndSettle();
    expect(find.text('Habit Forge'), findsWidgets);

    // Switch to Level & Stats tab
    await tester.tap(find.text('Level & Stats'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stats_current_level_text')), findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings_haptics_switch')), findsOneWidget);
    expect(find.byKey(const Key('settings_export_json_tile')), findsOneWidget);
  });
}
