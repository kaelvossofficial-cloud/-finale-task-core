import 'package:flutter/foundation.dart';

import '../../../../data/repositories/task_habit_repository.dart';
import '../../../../domain/models/user_progression.dart';

class ProgressionViewModel extends ChangeNotifier {
  ProgressionViewModel({required TaskHabitRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final TaskHabitRepository _repository;

  UserProgression get progression => _repository.progression;

  int get currentLevel => progression.level;
  int get currentXp => progression.totalXp;
  int get xpRequiredForNextLevel => progression.xpRequiredForNextLevel;
  int get nextLevelTargetXp => progression.nextLevelTargetXp;
  double get levelProgress => progression.levelProgress;

  int get totalTasksCompleted => progression.totalCompletedTasks;
  int get currentTaskStreak => progression.currentTaskStreak;
  double get onTimeCompletionRate => progression.onTimeCompletionRate;

  void _onRepositoryChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
