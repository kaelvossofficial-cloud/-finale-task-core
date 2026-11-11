import 'package:finale_task_core/data/repositories/task_habit_repository.dart';
import 'package:finale_task_core/data/services/haptic_service.dart';
import 'package:finale_task_core/data/services/local_storage_service.dart';
import 'package:finale_task_core/domain/models/habit_item.dart';
import 'package:finale_task_core/domain/models/task_item.dart';
import 'package:finale_task_core/domain/use_cases/level_calculator.dart';
import 'package:finale_task_core/domain/use_cases/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelCalculator & Gamification Hook', () {
    test('calculates Level = floor(sqrt(XP / 100)) + 1 accurately', () {
      expect(LevelCalculator.calculateLevel(0), 1);
      expect(LevelCalculator.calculateLevel(99), 1);
      expect(LevelCalculator.calculateLevel(100), 2);
      expect(LevelCalculator.calculateLevel(399), 2);
      expect(LevelCalculator.calculateLevel(400), 3);
      expect(LevelCalculator.calculateLevel(900), 4);
    });

    test(
        'awards +10 base XP and +5 on-time bonus when completed before dueDate',
        () {
      final due = DateTime(2026, 11, 11, 18, 0);
      final beforeDue = DateTime(2026, 11, 11, 15, 0);
      final afterDue = DateTime(2026, 11, 11, 19, 0);

      final onTimeReward = LevelCalculator.evaluateTaskReward(
        completedAt: beforeDue,
        dueDate: due,
      );
      expect(onTimeReward.xp, 15);
      expect(onTimeReward.onTime, isTrue);

      final lateReward = LevelCalculator.evaluateTaskReward(
        completedAt: afterDue,
        dueDate: due,
      );
      expect(lateReward.xp, 10);
      expect(lateReward.onTime, isFalse);
    });
  });

  group('StreakCalculator & Grace Period Logic', () {
    test('counts consecutive days and respects gracePeriodDays before reset',
        () {
      final refDate = DateTime(2026, 11, 11);
      final keysConsecutive = <String>[
        '2026-11-09',
        '2026-11-10',
        '2026-11-11',
      ];
      expect(
        StreakCalculator.calculateStreak(
          completedDateKeys: keysConsecutive,
          referenceDate: refDate,
          gracePeriodDays: 0,
        ),
        3,
      );

      // 1 day missed ('2026-11-10' skipped) with 1-day grace period -> keeps streak
      final keysWithOneGap = <String>[
        '2026-11-09',
        '2026-11-11',
      ];
      expect(
        StreakCalculator.calculateStreak(
          completedDateKeys: keysWithOneGap,
          referenceDate: refDate,
          gracePeriodDays: 1,
        ),
        2,
      );

      // Missed beyond grace period -> resets to 0
      final keysExpired = <String>[
        '2026-11-01',
        '2026-11-02',
      ];
      expect(
        StreakCalculator.calculateStreak(
          completedDateKeys: keysExpired,
          referenceDate: refDate,
          gracePeriodDays: 1,
        ),
        0,
      );
    });

    test('calculates today completion percentage accurately', () {
      final today = DateTime(2026, 11, 11);
      final habits = <HabitItem>[
        HabitItem(
          id: 'h1',
          title: 'H1',
          createdAt: today,
          completedDateKeys: const <String>['2026-11-11'],
        ),
        HabitItem(
          id: 'h2',
          title: 'H2',
          createdAt: today,
          completedDateKeys: const <String>[],
        ),
      ];
      expect(
        StreakCalculator.calculateTodayCompletionRatio(
          habits: habits,
          today: today,
        ),
        0.5,
      );
    });
  });

  group('TaskHabitRepository Persistence, JSON Export/Import & Reset', () {
    test('completes tasks, updates XP & metrics, exports and imports JSON',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final fixedNow = DateTime(2026, 11, 11, 12, 0);
      final repo = TaskHabitRepository(
        storageService: LocalStorageService(enableSqlite: false),
        hapticService: HapticService(),
        clock: () => fixedNow,
      );
      await repo.initialize(seedDefaultsIfEmpty: false);

      final task = await repo.addTask(
        title: 'Test On-Time Quest',
        dueDate: fixedNow.add(const Duration(hours: 2)),
        priority: TaskPriority.high,
      );

      final reward = await repo.completeTask(task.id);
      expect(reward.awardedXp, 15);
      expect(reward.onTime, isTrue);
      expect(repo.progression.totalXp, 15);
      expect(repo.progression.totalCompletedTasks, 1);
      expect(repo.progression.onTimeCompletionRate, 100.0);

      final exported = repo.exportDatabaseToJson();
      await repo.resetProgressionAndData();
      expect(repo.tasks, isEmpty);
      expect(repo.progression.totalXp, 0);

      await repo.importDatabaseFromJson(exported);
      expect(repo.tasks.length, 1);
      expect(repo.progression.totalXp, 15);
      expect(repo.progression.totalCompletedTasks, 1);
    });
  });
}
