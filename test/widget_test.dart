import 'package:finale_task_core/data/repositories/task_habit_repository.dart';
import 'package:finale_task_core/data/services/haptic_service.dart';
import 'package:finale_task_core/data/services/local_storage_service.dart';
import 'package:finale_task_core/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Finale Task Core renders floating nav capsule, center craft axe, drum picker, and all screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final repo = TaskHabitRepository(
      storageService: LocalStorageService(enableSqlite: false),
      hapticService: HapticService(),
    );
    await repo.initialize();

    await tester.pumpWidget(FinaleTaskCoreApp(repository: repo));
    await tester.pumpAndSettle();

    // Verify Floating Nav Capsule & Center Craft Axe Button
    expect(find.byKey(const Key('floating_nav_capsule')), findsOneWidget);
    expect(find.byKey(const Key('center_craft_axe_button')), findsOneWidget);

    // Verify Quests Screen renders chronological groups
    expect(find.text('Finale Quests'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Switch to Blocks (Home Drum Picker) tab
    await tester.tap(find.text('Blocks'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_block_heading_text')), findsOneWidget);
    expect(find.byKey(const Key('home_block_drum_picker')), findsOneWidget);

    // Switch to Habits tab & test Waterfall Grid toggle
    await tester.tap(find.text('Habits'));
    await tester.pumpAndSettle();
    expect(find.text('Habit Forge'), findsWidgets);
    await tester.tap(find.byKey(const Key('habit_layout_toggle_button')));
    await tester.pumpAndSettle();

    // Switch to Level & Stats tab & verify Performance Dashboard + Friends Party
    await tester.tap(find.text('Level & Stats'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stats_current_level_text')), findsOneWidget);
    expect(
        find.byKey(const Key('stats_period_filter_control')), findsOneWidget);
    expect(find.text('Accountability Party'), findsOneWidget);

    // Switch to Profile tab & verify Activity Calendar + Data Management
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('ACTIVITY CALENDAR'), findsOneWidget);
    expect(find.byKey(const Key('settings_haptics_switch')), findsOneWidget);
    expect(find.byKey(const Key('settings_export_json_tile')), findsOneWidget);
  });
}
