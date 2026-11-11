import 'package:flutter/foundation.dart';

import '../../../../data/repositories/task_habit_repository.dart';
import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/habit_item.dart';
import '../../../../domain/use_cases/streak_calculator.dart';

class HabitsViewModel extends ChangeNotifier {
  HabitsViewModel({required TaskHabitRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final TaskHabitRepository _repository;

  bool _isWaterfallGrid = false;
  bool get isWaterfallGrid => _isWaterfallGrid;

  void toggleLayoutMode() {
    _repository.haptics.lightImpact();
    _isWaterfallGrid = !_isWaterfallGrid;
    notifyListeners();
  }

  List<HabitItem> get habits => _repository.habits;
  List<HabitItem> get activeHabits =>
      _repository.habits.where((h) => h.isActive).toList();
  HapticService get haptics => _repository.haptics;
  DateTime get today => _repository.now;

  int get completedTodayCount =>
      activeHabits.where((h) => h.isCompletedOn(today)).length;

  int get totalActiveCount => activeHabits.length;

  /// Progress bar ratio: Completed Habits / Total Active Habits (0.0 to 1.0)
  double get todayCompletionRatio =>
      StreakCalculator.calculateTodayCompletionRatio(
        habits: _repository.habits,
        today: today,
      );

  int get todayCompletionPercent => (todayCompletionRatio * 100).round();

  /// Calculates consecutive day completion count for [habit]; resets if missed beyond grace period.
  int streakFor(HabitItem habit) {
    return StreakCalculator.calculateStreak(
      completedDateKeys: habit.completedDateKeys,
      referenceDate: today,
      gracePeriodDays: habit.gracePeriodDays,
    );
  }

  bool isCompletedToday(HabitItem habit) {
    return habit.isCompletedOn(today);
  }

  Future<void> refresh() async {
    await _repository.refreshState();
  }

  Future<void> toggleToday(String habitId, {String? optionalNote}) async {
    await _repository.toggleHabitCompletion(
      habitId,
      date: today,
      optionalNote: optionalNote,
    );
  }

  Future<void> toggleDate(String habitId, DateTime date) async {
    await _repository.toggleHabitCompletion(habitId, date: date);
  }

  Future<void> addStoryNote(String habitId, String note) async {
    await _repository.addHabitStoryNote(
      habitId: habitId,
      note: note,
      date: today,
    );
  }

  Future<void> addHabit({
    required String title,
    required int gracePeriodDays,
    String iconKey = 'potion',
    int colorArgb = HabitItem.defaultColorArgb,
    String blockId = 'dawn',
    String? reminderTime,
    bool isAlarmEnabled = false,
  }) async {
    await _repository.haptics.lightImpact();
    await _repository.addHabit(
      title: title,
      gracePeriodDays: gracePeriodDays,
      iconKey: iconKey,
      colorArgb: colorArgb,
      blockId: blockId,
      reminderTime: reminderTime,
      isAlarmEnabled: isAlarmEnabled,
    );
  }

  Future<void> updateHabit(HabitItem updated) async {
    await _repository.updateHabit(updated);
  }

  Future<void> deleteHabit(String habitId) async {
    await _repository.haptics.mediumImpact();
    await _repository.deleteHabit(habitId);
  }

  void _onRepositoryChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
