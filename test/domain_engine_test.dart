import 'package:finale_task_core/data/repositories/task_habit_repository.dart';
import 'package:finale_task_core/data/services/haptic_service.dart';
import 'package:finale_task_core/data/services/local_storage_service.dart';
import 'package:finale_task_core/domain/models/habit_item.dart';
import 'package:finale_task_core/domain/models/task_item.dart';
import 'package:finale_task_core/domain/models/time_block.dart';
import 'package:finale_task_core/domain/use_cases/block_planner.dart';
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

  group('StreakCalculator, TimeBlocks & BlockPlanner', () {
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

    test('resolves active TimeBlock and filters BlockPlanner entries', () {
      final morning = DateTime(2026, 11, 11, 7, 30);
      final dawnBlock = TimeBlock.current(morning);
      expect(dawnBlock.id, 'dawn');

      final entries = BlockPlanner.entriesFor(
        block: dawnBlock,
        tasks: <TaskItem>[
          TaskItem(
            id: 't1',
            title: 'Morning Task',
            dueDate: DateTime(2026, 11, 11, 8, 15),
            createdAt: morning,
          ),
        ],
        habits: <HabitItem>[
          HabitItem(
            id: 'h1',
            title: 'Dawn Habit',
            blockId: 'dawn',
            createdAt: morning,
          ),
        ],
        now: morning,
      );
      expect(entries.length, 2);
    });
  });

  group('TaskHabitRepository Persistence, Story Notes, Friends & JSON', () {
    test(
        'completes tasks, delays tasks, logs habit stories, manages friends, and exports/imports JSON',
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
        isAlarmEnabled: true,
      );

      await repo.delayTask(task.id, const Duration(minutes: 15));
      expect(
        repo.tasks.first.dueDate,
        fixedNow.add(const Duration(hours: 2, minutes: 15)),
      );

      final reward = await repo.completeTask(task.id);
      expect(reward.awardedXp, 15);
      expect(reward.onTime, isTrue);
      expect(repo.progression.totalXp, 15);

      final habit = await repo.addHabit(
        title: 'Custom Colored Habit',
        iconKey: 'diamond',
        colorArgb: 0xFF3CE6D6,
        blockId: 'day',
      );
      await repo.addHabitStoryNote(
        habitId: habit.id,
        note: 'Completed 30m session!',
      );
      expect(repo.habits.first.stories.length, 1);

      await repo.updateUserProfile(
        username: 'kael_voss',
        displayName: 'Kael Voss',
      );
      expect(repo.progression.username, 'kael_voss');

      await repo.addFriendByUsername(
        username: 'friend_one',
        displayName: 'Friend One',
      );
      expect(repo.progression.friends.length, 1);

      final exported = repo.exportDatabaseToJson();
      await repo.resetProgressionAndData();
      expect(repo.tasks, isEmpty);
      expect(repo.progression.totalXp, 0);

      await repo.importDatabaseFromJson(exported);
      expect(repo.tasks.length, 1);
      expect(repo.habits.first.stories.length, 1);
      expect(repo.progression.totalXp, 15);
    });
  });
}
