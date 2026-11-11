import 'package:flutter/foundation.dart';

import '../../../../data/repositories/task_habit_repository.dart';
import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/task_item.dart';
import '../../../../domain/models/user_progression.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel({required TaskHabitRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final TaskHabitRepository _repository;

  String? _lastRewardBanner;
  String? get lastRewardBanner => _lastRewardBanner;

  UserProgression get progression => _repository.progression;
  HapticService get haptics => _repository.haptics;

  List<TaskItem> get todayTasks {
    final ref = _repository.now;
    final list = _repository.tasks
        .where((t) => t.groupFor(ref) == TaskChronologicalGroup.today)
        .toList();
    list.sort(_compareByDueAndPriority);
    return list;
  }

  List<TaskItem> get upcomingTasks {
    final ref = _repository.now;
    final list = _repository.tasks
        .where((t) => t.groupFor(ref) == TaskChronologicalGroup.upcoming)
        .toList();
    list.sort(_compareByDueAndPriority);
    return list;
  }

  List<TaskItem> get completedTasks {
    final ref = _repository.now;
    final list = _repository.tasks
        .where((t) => t.groupFor(ref) == TaskChronologicalGroup.completed)
        .toList();
    list.sort(
      (a, b) => (b.completedAt ?? b.createdAt)
          .compareTo(a.completedAt ?? a.createdAt),
    );
    return list;
  }

  int _compareByDueAndPriority(TaskItem a, TaskItem b) {
    final priorityCompare = b.priority.index.compareTo(a.priority.index);
    if (a.dueDate != null && b.dueDate != null) {
      final dueCompare = a.dueDate!.compareTo(b.dueDate!);
      if (dueCompare != 0) return dueCompare;
    } else if (a.dueDate != null) {
      return -1;
    } else if (b.dueDate != null) {
      return 1;
    }
    return priorityCompare;
  }

  Future<void> refresh() async {
    await _repository.refreshState();
  }

  Future<void> addTask({
    required String title,
    DateTime? dueDate,
    required TaskPriority priority,
    DateTime? reminderAt,
    bool isAlarmEnabled = false,
    String? blockId,
  }) async {
    await _repository.haptics.lightImpact();
    await _repository.addTask(
      title: title,
      dueDate: dueDate,
      priority: priority,
      reminderAt: reminderAt,
      isAlarmEnabled: isAlarmEnabled,
      blockId: blockId,
    );
  }

  Future<void> updateTask(TaskItem updated) async {
    await _repository.updateTask(updated);
  }

  Future<void> delayTask(String taskId, Duration delay) async {
    await _repository.delayTask(taskId, delay);
  }

  Future<void> completeTask(TaskItem task) async {
    final result = await _repository.completeTask(task.id);
    if (result.awardedXp > 0) {
      final levelUpLabel =
          result.leveledUp ? ' · LVL ${progression.level}!' : '';
      _lastRewardBanner = '+${result.awardedXp}xp$levelUpLabel';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.haptics.mediumImpact();
    await _repository.deleteTask(taskId);
  }

  void dismissRewardBanner() {
    if (_lastRewardBanner == null) return;
    _lastRewardBanner = null;
    notifyListeners();
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
