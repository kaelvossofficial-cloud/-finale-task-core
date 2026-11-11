import '../models/habit_item.dart';
import '../models/task_item.dart';
import '../models/time_block.dart';
import 'streak_calculator.dart';

/// An item shown on the Home drum picker: either a task or a habit.
sealed class BlockEntry {
  const BlockEntry();
  String get id;
  String get title;
}

class TaskEntry extends BlockEntry {
  const TaskEntry(this.task);
  final TaskItem task;

  @override
  String get id => task.id;

  @override
  String get title => task.title;
}

class HabitEntry extends BlockEntry {
  const HabitEntry(this.habit, this.streak);
  final HabitItem habit;
  final int streak;

  @override
  String get id => habit.id;

  @override
  String get title => habit.title;
}

/// Pure rules deciding which tasks and habits belong to a [TimeBlock].
class BlockPlanner {
  const BlockPlanner._();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Which block an (incomplete) task belongs to right now, or `null` if the
  /// task is scheduled for a future day.
  static TimeBlock? blockForTask(TaskItem task, DateTime now) {
    final current = TimeBlock.current(now);
    final due = task.dueDate;
    if (due == null || due.isBefore(now)) return current;
    if (_sameDay(due, now)) return TimeBlock.current(due);
    return null;
  }

  static bool habitBelongsTo(HabitItem habit, TimeBlock block, DateTime now) {
    final assigned = TimeBlock.byId(habit.blockId);
    if (assigned == null) return block == TimeBlock.current(now);
    return assigned == block;
  }

  /// Open (not yet done) entries for [block], tasks first by due time.
  static List<BlockEntry> entriesFor({
    required TimeBlock block,
    required List<TaskItem> tasks,
    required List<HabitItem> habits,
    required DateTime now,
  }) {
    final openTasks = tasks
        .where((t) => !t.isCompleted && blockForTask(t, now) == block)
        .toList()
      ..sort((a, b) {
        final ad = a.dueDate, bd = b.dueDate;
        if (ad == null && bd == null) {
          return b.priority.index.compareTo(a.priority.index);
        }
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });

    final openHabits = habits
        .where((h) =>
            h.isActive &&
            !h.isCompletedOn(now) &&
            !h.isSnoozedAt(now) &&
            habitBelongsTo(h, block, now))
        .map(
          (h) => HabitEntry(
            h,
            StreakCalculator.calculateStreak(
              completedDateKeys: h.completedDateKeys,
              referenceDate: now,
              gracePeriodDays: h.gracePeriodDays,
            ),
          ),
        );

    return <BlockEntry>[
      ...openTasks.map(TaskEntry.new),
      ...openHabits,
    ];
  }

  /// Completed vs total items for [block] today.
  static ({int done, int total}) progressFor({
    required TimeBlock block,
    required List<TaskItem> tasks,
    required List<HabitItem> habits,
    required DateTime now,
  }) {
    final open = entriesFor(
      block: block,
      tasks: tasks,
      habits: habits,
      now: now,
    ).length;

    final doneHabits = habits
        .where((h) =>
            h.isActive && h.isCompletedOn(now) && habitBelongsTo(h, block, now))
        .length;

    final doneTasks = tasks.where((t) {
      if (!t.isCompleted) return false;
      final at = t.completedAt;
      if (at == null || !_sameDay(at, now)) return false;
      return block.contains(at);
    }).length;

    final done = doneHabits + doneTasks;
    return (done: done, total: done + open);
  }
}
