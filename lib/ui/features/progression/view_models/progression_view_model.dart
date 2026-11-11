import 'package:flutter/foundation.dart';

import '../../../../data/repositories/task_habit_repository.dart';
import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/habit_item.dart';
import '../../../../domain/models/user_progression.dart';

enum StatsPeriodFilter {
  today('Today', 1),
  week('Week', 7),
  month('Month', 30),
  all('All', 365);

  const StatsPeriodFilter(this.label, this.days);
  final String label;
  final int days;
}

class ProgressionViewModel extends ChangeNotifier {
  ProgressionViewModel({required TaskHabitRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final TaskHabitRepository _repository;

  StatsPeriodFilter _selectedFilter = StatsPeriodFilter.week;
  StatsPeriodFilter get selectedFilter => _selectedFilter;

  void setFilter(StatsPeriodFilter filter) {
    if (_selectedFilter == filter) return;
    _repository.haptics.selectionClick();
    _selectedFilter = filter;
    notifyListeners();
  }

  UserProgression get progression => _repository.progression;
  HapticService get haptics => _repository.haptics;

  int get currentLevel => progression.level;
  int get currentXp => progression.totalXp;
  int get xpRequiredForNextLevel => progression.xpRequiredForNextLevel;
  int get nextLevelTargetXp => progression.nextLevelTargetXp;
  double get levelProgress => progression.levelProgress;

  int get totalTasksCompleted => progression.totalCompletedTasks;
  int get currentTaskStreak => progression.currentTaskStreak;
  double get onTimeCompletionRate => progression.onTimeCompletionRate;

  /// Tasks completed within the active [selectedFilter] window.
  int get filteredCompletedTasksCount {
    if (_selectedFilter == StatsPeriodFilter.all) {
      return totalTasksCompleted;
    }
    final cutoff = _repository.now.subtract(
      Duration(days: _selectedFilter.days),
    );
    return _repository.tasks.where((t) {
      if (!t.isCompleted) return false;
      final at = t.completedAt ?? t.createdAt;
      return !at.isBefore(cutoff);
    }).length;
  }

  /// Habit check-ins within the active [selectedFilter] window.
  int get filteredHabitCheckInsCount {
    final now = _repository.now;
    int total = 0;
    for (var d = 0; d < _selectedFilter.days; d++) {
      final date = now.subtract(Duration(days: d));
      final key = HabitItem.dateKey(date);
      for (final h in _repository.habits) {
        if (h.completedDateKeys.contains(key)) {
          total += 1;
        }
      }
    }
    return total;
  }

  /// 7-day activity bars (tasks + habits completed per day) for the performance chart.
  List<({String label, int count})> get weeklyActivityBars {
    final now = _repository.now;
    const labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return List<({String label, int count})>.generate(7, (idx) {
      final offset = 6 - idx;
      final date = now.subtract(Duration(days: offset));
      final key = HabitItem.dateKey(date);
      final habitCount = _repository.habits
          .where((h) => h.completedDateKeys.contains(key))
          .length;
      final taskCount = _repository.tasks.where((t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return HabitItem.dateKey(t.completedAt!) == key;
      }).length;
      return (label: labels[date.weekday - 1], count: habitCount + taskCount);
    });
  }

  Future<void> refresh() async {
    await _repository.refreshState();
  }

  Future<void> addFriend(String username, String displayName) async {
    await _repository.addFriendByUsername(
      username: username,
      displayName: displayName,
    );
  }

  Future<void> nudgeFriend(String username) async {
    await _repository.nudgeFriend(username);
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
