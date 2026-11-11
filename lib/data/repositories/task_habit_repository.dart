import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../domain/models/habit_item.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/time_block.dart';
import '../../domain/models/user_progression.dart';
import '../../domain/use_cases/level_calculator.dart';
import '../../domain/use_cases/streak_calculator.dart';
import '../services/haptic_service.dart';
import '../services/local_storage_service.dart';

/// Single source of truth for Tasks, Habits, TimeBlocks, Reminders, and Progression.
class TaskHabitRepository extends ChangeNotifier {
  TaskHabitRepository({
    required LocalStorageService storageService,
    required HapticService hapticService,
    DateTime Function()? clock,
  })  : _storage = storageService,
        _haptics = hapticService,
        _clock = clock ?? DateTime.now;

  final LocalStorageService _storage;
  final HapticService _haptics;
  final DateTime Function() _clock;

  List<TaskItem> _tasks = <TaskItem>[];
  List<HabitItem> _habits = <HabitItem>[];
  UserProgression _progression = const UserProgression();
  bool _isInitialized = false;

  List<TaskItem> get tasks => List<TaskItem>.unmodifiable(_tasks);
  List<HabitItem> get habits => List<HabitItem>.unmodifiable(_habits);
  UserProgression get progression => _progression;
  bool get isInitialized => _isInitialized;
  HapticService get haptics => _haptics;
  DateTime get now => _clock();

  Future<void> initialize({bool seedDefaultsIfEmpty = true}) async {
    await _storage.init();
    final alreadySeeded = await _storage.isSeeded();

    _tasks = await _storage.loadTasks();
    _habits = await _storage.loadHabits();
    _progression = await _storage.loadProgression();

    if (!alreadySeeded &&
        seedDefaultsIfEmpty &&
        _tasks.isEmpty &&
        _habits.isEmpty) {
      await _seedStarterWorld();
    }

    if (seedDefaultsIfEmpty && _progression.friends.isEmpty) {
      _progression = _progression.copyWith(
        friends: const <AccountabilityFriend>[
          AccountabilityFriend(
            username: 'aria_redstone',
            displayName: 'Aria V.',
            streakDays: 6,
            weeklyXp: 145,
            avatarIconKey: 'diamond',
            colorArgb: 0xFF3CE6D6,
          ),
          AccountabilityFriend(
            username: 'zack_nether',
            displayName: 'Zack M.',
            streakDays: 4,
            weeklyXp: 110,
            avatarIconKey: 'sword',
            colorArgb: 0xFFFFAA00,
          ),
          AccountabilityFriend(
            username: 'mira_alchemist',
            displayName: 'Mira K.',
            streakDays: 3,
            weeklyXp: 85,
            avatarIconKey: 'potion',
            colorArgb: 0xFFA855F7,
          ),
        ],
      );
      await _storage.saveProgression(_progression);
    }

    _haptics.setEnabled(_progression.hapticsEnabled);
    _recomputeTaskStreak();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshState() async {
    await _haptics.lightImpact();
    _recomputeTaskStreak();
    notifyListeners();
  }

  Future<void> _seedStarterWorld() async {
    final current = _clock();
    final todayKey = HabitItem.dateKey(current);
    final yesterdayKey =
        HabitItem.dateKey(current.subtract(const Duration(days: 1)));
    final twoDaysAgoKey =
        HabitItem.dateKey(current.subtract(const Duration(days: 2)));
    final activeBlock = TimeBlock.current(current).id;

    _tasks = <TaskItem>[
      TaskItem(
        id: 'task_seed_1',
        title: 'Mine 32 Deep-Slate Architecture Specs',
        dueDate: current.add(const Duration(minutes: 45)),
        reminderAt: current.add(const Duration(minutes: 30)),
        isAlarmEnabled: true,
        priority: TaskPriority.high,
        blockId: activeBlock,
        colorArgb: 0xFFFF3B30,
        createdAt: current.subtract(const Duration(hours: 2)),
      ),
      TaskItem(
        id: 'task_seed_2',
        title: 'Craft Enchanted Sprint Backlog Table',
        dueDate: current.add(const Duration(hours: 4)),
        reminderAt: current.add(const Duration(hours: 3, minutes: 30)),
        priority: TaskPriority.medium,
        blockId: activeBlock,
        colorArgb: 0xFFFFAA00,
        createdAt: current.subtract(const Duration(hours: 1)),
      ),
      TaskItem(
        id: 'task_seed_3',
        title: 'Smelt Raw Iron Bugs in Hotbar Queue',
        dueDate: current.add(const Duration(days: 2, hours: 4)),
        priority: TaskPriority.low,
        blockId: 'day',
        colorArgb: 0xFF9CA3AF,
        createdAt: current,
      ),
      TaskItem(
        id: 'task_seed_4',
        title: 'Fortify Stronghold CI/CD Redstone Gate',
        dueDate: current.add(const Duration(days: 4)),
        priority: TaskPriority.high,
        blockId: 'dusk',
        colorArgb: 0xFFFF3B30,
        createdAt: current,
      ),
    ];

    _habits = <HabitItem>[
      HabitItem(
        id: 'habit_seed_1',
        title: 'Brew Morning Swiftness Potion',
        iconKey: 'potion',
        colorArgb: 0xFF17DD62,
        blockId: 'dawn',
        reminderTime: '07:30',
        isAlarmEnabled: true,
        gracePeriodDays: 1,
        completedDateKeys: <String>[twoDaysAgoKey, yesterdayKey, todayKey],
        stories: <HabitStoryEntry>[
          HabitStoryEntry(
            dateKey: todayKey,
            note: 'Drank 500ml water + electrolytes before opening IDE.',
            timestamp: current.subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: current.subtract(const Duration(days: 5)),
      ),
      HabitItem(
        id: 'habit_seed_2',
        title: 'Redstone Logic Practice (30m Focus)',
        iconKey: 'code',
        colorArgb: 0xFF3CE6D6,
        blockId: activeBlock,
        reminderTime: '13:00',
        gracePeriodDays: 1,
        completedDateKeys: <String>[twoDaysAgoKey, yesterdayKey],
        createdAt: current.subtract(const Duration(days: 4)),
      ),
      HabitItem(
        id: 'habit_seed_3',
        title: 'Read Enchanted Tome in Library',
        iconKey: 'book',
        colorArgb: 0xFFA855F7,
        blockId: 'dusk',
        reminderTime: '20:00',
        gracePeriodDays: 2,
        completedDateKeys: <String>[yesterdayKey],
        createdAt: current.subtract(const Duration(days: 3)),
      ),
      HabitItem(
        id: 'habit_seed_4',
        title: 'Campfire Rest & Device Shutdown',
        iconKey: 'moon',
        colorArgb: 0xFFFFAA00,
        blockId: 'night',
        reminderTime: '22:30',
        gracePeriodDays: 1,
        completedDateKeys: <String>[yesterdayKey],
        createdAt: current.subtract(const Duration(days: 3)),
      ),
    ];

    await _storage.saveTasks(_tasks);
    await _storage.saveHabits(_habits);
    await _storage.saveProgression(_progression);
    await _storage.markSeeded(true);
  }

  /// Creates and persists a new task.
  Future<TaskItem> addTask({
    required String title,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    DateTime? reminderAt,
    bool isAlarmEnabled = false,
    String? blockId,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }
    final current = _clock();
    final color = switch (priority) {
      TaskPriority.high => 0xFFFF3B30,
      TaskPriority.medium => 0xFFFFAA00,
      TaskPriority.low => 0xFF9CA3AF,
    };
    final task = TaskItem(
      id: 'task_${current.microsecondsSinceEpoch}',
      title: trimmed,
      dueDate: dueDate,
      priority: priority,
      reminderAt: reminderAt ?? dueDate,
      isAlarmEnabled: isAlarmEnabled,
      blockId: blockId ?? TimeBlock.current(dueDate ?? current).id,
      colorArgb: color,
      createdAt: current,
    );
    _tasks = <TaskItem>[task, ..._tasks];
    await _storage.saveTasks(_tasks);
    notifyListeners();
    return task;
  }

  /// Updates an existing task (title, dueDate, reminderAt, alarm, priority, blockId).
  Future<void> updateTask(TaskItem updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    final list = List<TaskItem>.from(_tasks);
    list[idx] = updated;
    _tasks = list;
    await _storage.saveTasks(_tasks);
    await _haptics.lightImpact();
    notifyListeners();
  }

  /// Delays a task by [duration] (used by left-swipe on Home drum picker or quick actions).
  Future<void> delayTask(String taskId, Duration duration) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final existing = _tasks[idx];
    final baseTime = existing.dueDate ?? _clock();
    final nextDue = baseTime.add(duration);
    final updated = existing.copyWith(
      dueDate: nextDue,
      reminderAt: nextDue,
    );
    await updateTask(updated);
  }

  /// Marks a task complete via the tactile dismiss gesture, awards XP (+10 base, +5 on-time bonus),
  /// updates global completion & streak stats, and persists immediately.
  Future<({int awardedXp, bool onTime, bool leveledUp})> completeTask(
    String taskId,
  ) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) {
      return (awardedXp: 0, onTime: false, leveledUp: false);
    }

    final existing = _tasks[idx];
    if (existing.isCompleted) {
      return (
        awardedXp: existing.awardedXp,
        onTime: existing.completedOnTime,
        leveledUp: false,
      );
    }

    final completedAt = _clock();
    final reward = LevelCalculator.evaluateTaskReward(
      completedAt: completedAt,
      dueDate: existing.dueDate,
    );

    final updatedTask = existing.copyWith(
      isCompleted: true,
      completedAt: completedAt,
      awardedXp: reward.xp,
      completedOnTime: reward.onTime,
    );

    final updatedList = List<TaskItem>.from(_tasks);
    updatedList[idx] = updatedTask;
    _tasks = updatedList;

    final previousLevel = _progression.level;
    final todayKey = HabitItem.dateKey(completedAt);
    final updatedDateKeys = <String>{
      ..._progression.taskCompletionDateKeys,
      todayKey,
    }.toList();

    final newStreak = StreakCalculator.calculateStreak(
      completedDateKeys: updatedDateKeys,
      referenceDate: completedAt,
      gracePeriodDays: 0,
    );

    _progression = _progression.copyWith(
      totalXp: _progression.totalXp + reward.xp,
      totalCompletedTasks: _progression.totalCompletedTasks + 1,
      onTimeCompletedTasks:
          _progression.onTimeCompletedTasks + (reward.onTime ? 1 : 0),
      taskCompletionDateKeys: updatedDateKeys,
      currentTaskStreak: newStreak,
    );

    final leveledUp = _progression.level > previousLevel;

    await _storage.saveTasks(_tasks);
    await _storage.saveProgression(_progression);

    if (leveledUp) {
      await _haptics.heavyImpact();
    }
    notifyListeners();

    return (
      awardedXp: reward.xp,
      onTime: reward.onTime,
      leveledUp: leveledUp,
    );
  }

  /// Deletes a task by ID.
  Future<void> deleteTask(String taskId) async {
    _tasks = _tasks.where((t) => t.id != taskId).toList();
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Creates a new daily habit with custom icon, color, block, reminder, and grace period.
  Future<HabitItem> addHabit({
    required String title,
    int gracePeriodDays = 1,
    String iconKey = 'potion',
    int colorArgb = HabitItem.defaultColorArgb,
    String blockId = 'dawn',
    String? reminderTime,
    bool isAlarmEnabled = false,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Habit title cannot be empty.');
    }
    final current = _clock();
    final habit = HabitItem(
      id: 'habit_${current.microsecondsSinceEpoch}',
      title: trimmed,
      gracePeriodDays: gracePeriodDays.clamp(0, 7),
      iconKey: iconKey,
      colorArgb: colorArgb,
      blockId: blockId,
      reminderTime: reminderTime,
      isAlarmEnabled: isAlarmEnabled,
      createdAt: current,
    );
    _habits = <HabitItem>[..._habits, habit];
    await _storage.saveHabits(_habits);
    notifyListeners();
    return habit;
  }

  /// Updates an existing habit's customization fields.
  Future<void> updateHabit(HabitItem updated) async {
    final idx = _habits.indexWhere((h) => h.id == updated.id);
    if (idx == -1) return;
    final list = List<HabitItem>.from(_habits);
    list[idx] = updated;
    _habits = list;
    await _storage.saveHabits(_habits);
    await _haptics.lightImpact();
    notifyListeners();
  }

  /// Snoozes/delays a habit on the Home drum picker by [duration].
  Future<void> delayHabit(String habitId, Duration duration) async {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;
    final updated = _habits[idx].copyWith(
      snoozedUntil: _clock().add(duration),
    );
    await updateHabit(updated);
  }

  /// Adds an optional daily story/note to a habit and marks it complete for today if not already.
  Future<void> addHabitStoryNote({
    required String habitId,
    required String note,
    DateTime? date,
  }) async {
    final targetDate = date ?? _clock();
    final key = HabitItem.dateKey(targetDate);
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;

    final habit = _habits[idx];
    final keys = Set<String>.from(habit.completedDateKeys)..add(key);
    final trimmedNote = note.trim();
    final updatedStories = <HabitStoryEntry>[
      if (trimmedNote.isNotEmpty)
        HabitStoryEntry(
          dateKey: key,
          note: trimmedNote,
          timestamp: _clock(),
        ),
      ...habit.stories,
    ];

    final updatedHabit = habit.copyWith(
      completedDateKeys: keys.toList(),
      stories: updatedStories,
    );
    final updatedList = List<HabitItem>.from(_habits);
    updatedList[idx] = updatedHabit;
    _habits = updatedList;

    await _storage.saveHabits(_habits);
    await _haptics.lightImpact();
    notifyListeners();
  }

  /// Toggles a habit's completion status for [date] (defaults to today).
  Future<bool> toggleHabitCompletion(
    String habitId, {
    DateTime? date,
    String? optionalNote,
  }) async {
    final targetDate = date ?? _clock();
    final key = HabitItem.dateKey(targetDate);
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return false;

    final habit = _habits[idx];
    final keys = Set<String>.from(habit.completedDateKeys);
    final bool nowCompleted;
    if (keys.contains(key)) {
      keys.remove(key);
      nowCompleted = false;
    } else {
      keys.add(key);
      nowCompleted = true;
    }

    var updatedStories = habit.stories;
    if (nowCompleted &&
        optionalNote != null &&
        optionalNote.trim().isNotEmpty) {
      updatedStories = <HabitStoryEntry>[
        HabitStoryEntry(
          dateKey: key,
          note: optionalNote.trim(),
          timestamp: _clock(),
        ),
        ...habit.stories,
      ];
    }

    final updatedHabit = habit.copyWith(
      completedDateKeys: keys.toList(),
      stories: updatedStories,
    );

    final updatedList = List<HabitItem>.from(_habits);
    updatedList[idx] = updatedHabit;
    _habits = updatedList;

    await _storage.saveHabits(_habits);
    await _haptics.lightImpact();
    notifyListeners();
    return nowCompleted;
  }

  /// Toggles whether a habit is active in daily calculations.
  Future<void> setHabitActive(String habitId, bool isActive) async {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;

    final updatedList = List<HabitItem>.from(_habits);
    updatedList[idx] = _habits[idx].copyWith(isActive: isActive);
    _habits = updatedList;

    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  /// Deletes a habit by ID.
  Future<void> deleteHabit(String habitId) async {
    _habits = _habits.where((h) => h.id != habitId).toList();
    await _storage.saveHabits(_habits);
    notifyListeners();
  }

  /// Updates the user's unique @username, displayName, and avatarIconKey.
  Future<void> updateUserProfile({
    required String username,
    required String displayName,
    String? avatarIconKey,
  }) async {
    final cleanUsername = username
        .trim()
        .toLowerCase()
        .replaceAll('@', '')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (cleanUsername.isEmpty) return;

    _progression = _progression.copyWith(
      username: cleanUsername,
      displayName:
          displayName.trim().isEmpty ? cleanUsername : displayName.trim(),
      avatarIconKey: avatarIconKey ?? _progression.avatarIconKey,
    );
    await _storage.saveProgression(_progression);
    await _haptics.lightImpact();
    notifyListeners();
  }

  /// Adds an accountability friend by unique username to compete on habits & XP.
  Future<void> addFriendByUsername({
    required String username,
    String? displayName,
    String avatarIconKey = 'diamond',
    int colorArgb = 0xFF17DD62,
  }) async {
    final clean = username
        .trim()
        .toLowerCase()
        .replaceAll('@', '')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (clean.isEmpty) return;
    if (_progression.friends.any((f) => f.username == clean)) return;

    final newFriend = AccountabilityFriend(
      username: clean,
      displayName: (displayName == null || displayName.trim().isEmpty)
          ? clean.toUpperCase()
          : displayName.trim(),
      streakDays: 3,
      weeklyXp: 90,
      avatarIconKey: avatarIconKey,
      colorArgb: colorArgb,
    );
    _progression = _progression.copyWith(
      friends: <AccountabilityFriend>[..._progression.friends, newFriend],
    );
    await _storage.saveProgression(_progression);
    await _haptics.mediumImpact();
    notifyListeners();
  }

  /// Sends a habit accountability nudge to a friend.
  Future<void> nudgeFriend(String username) async {
    final updated = _progression.friends.map((f) {
      if (f.username == username) {
        return f.copyWith(nudgedToday: true);
      }
      return f;
    }).toList();
    _progression = _progression.copyWith(friends: updated);
    await _storage.saveProgression(_progression);
    await _haptics.lightImpact();
    notifyListeners();
  }

  /// Updates haptic feedback preference and persists immediately.
  Future<void> setHapticsEnabled(bool enabled) async {
    _haptics.setEnabled(enabled);
    _progression = _progression.copyWith(hapticsEnabled: enabled);
    await _storage.saveProgression(_progression);
    if (enabled) {
      await _haptics.lightImpact();
    }
    notifyListeners();
  }

  /// Exports the entire database (tasks, habits, progression) to a formatted JSON string.
  String exportDatabaseToJson() {
    final payload = <String, dynamic>{
      'schemaVersion': 2,
      'app': 'Finale Task Core',
      'exportedAt': _clock().toIso8601String(),
      'progression': _progression.toJson(),
      'tasks': _tasks.map((t) => t.toJson()).toList(),
      'habits': _habits.map((h) => h.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Imports tasks, habits, and progression from a JSON string and persists to SQLite & SharedPreferences.
  Future<void> importDatabaseFromJson(String rawJson) async {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException('Root JSON payload must be an object.');
    }
    final map = Map<String, dynamic>.from(decoded);

    if (!map.containsKey('tasks') &&
        !map.containsKey('habits') &&
        !map.containsKey('progression')) {
      throw const FormatException(
        'JSON does not contain valid Finale Task Core collections.',
      );
    }

    final rawTasks = map['tasks'] as List<dynamic>? ?? const <dynamic>[];
    final rawHabits = map['habits'] as List<dynamic>? ?? const <dynamic>[];
    final rawProg = map['progression'] as Map<dynamic, dynamic>?;

    final importedTasks = rawTasks
        .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final importedHabits = rawHabits
        .map((e) => HabitItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final importedProgression = rawProg != null
        ? UserProgression.fromJson(Map<String, dynamic>.from(rawProg))
        : const UserProgression();

    _tasks = importedTasks;
    _habits = importedHabits;
    _progression = importedProgression;
    _haptics.setEnabled(_progression.hapticsEnabled);
    _recomputeTaskStreak();

    await _storage.saveTasks(_tasks);
    await _storage.saveHabits(_habits);
    await _storage.saveProgression(_progression);
    await _storage.markSeeded(true);
    notifyListeners();
  }

  /// Completely resets all tasks, habits, and user progression to a clean slate.
  Future<void> resetProgressionAndData() async {
    await _haptics.mediumImpact();
    _tasks = <TaskItem>[];
    _habits = <HabitItem>[];
    _progression = UserProgression(hapticsEnabled: _progression.hapticsEnabled);
    await _storage.clearAll();
    await _storage.saveProgression(_progression);
    notifyListeners();
  }

  void _recomputeTaskStreak() {
    final calculated = StreakCalculator.calculateStreak(
      completedDateKeys: _progression.taskCompletionDateKeys,
      referenceDate: _clock(),
      gracePeriodDays: 0,
    );
    if (calculated != _progression.currentTaskStreak) {
      _progression = _progression.copyWith(currentTaskStreak: calculated);
    }
  }
}
