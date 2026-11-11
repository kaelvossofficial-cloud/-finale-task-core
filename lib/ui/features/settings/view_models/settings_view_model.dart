import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../data/repositories/task_habit_repository.dart';
import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/habit_item.dart';
import '../../../../domain/models/task_item.dart';
import '../../../../domain/models/user_progression.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required TaskHabitRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final TaskHabitRepository _repository;

  UserProgression get progression => _repository.progression;
  List<TaskItem> get tasks => _repository.tasks;
  List<HabitItem> get habits => _repository.habits;
  DateTime get today => _repository.now;

  bool get hapticsEnabled => _repository.progression.hapticsEnabled;
  HapticService get haptics => _repository.haptics;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool _isErrorStatus = false;
  bool get isErrorStatus => _isErrorStatus;

  /// Returns all color ARGB dots (from habits + completed tasks) for a specific [date].
  List<int> colorDotsForDate(DateTime date) {
    final key = HabitItem.dateKey(date);
    final colors = <int>[];
    for (final h in _repository.habits) {
      if (h.completedDateKeys.contains(key)) {
        colors.add(h.colorArgb);
      }
    }
    for (final t in _repository.tasks) {
      if (t.isCompleted &&
          t.completedAt != null &&
          HabitItem.dateKey(t.completedAt!) == key) {
        colors.add(t.colorArgb);
      }
    }
    return colors.take(4).toList();
  }

  /// Recent activity logs combining completed quests and habit story notes.
  List<({String title, String badge, int colorArgb, DateTime time})>
      get recentLogs {
    final items =
        <({String title, String badge, int colorArgb, DateTime time})>[];
    for (final t in _repository.tasks) {
      if (t.isCompleted && t.completedAt != null) {
        items.add((
          title: t.title,
          badge: '+${t.awardedXp}xp',
          colorArgb: t.colorArgb,
          time: t.completedAt!,
        ));
      }
    }
    for (final h in _repository.habits) {
      for (final s in h.stories) {
        items.add((
          title: '${h.title}: "${s.note}"',
          badge: s.dateKey,
          colorArgb: h.colorArgb,
          time: s.timestamp,
        ));
      }
    }
    items.sort((a, b) => b.time.compareTo(a.time));
    return items.take(8).toList();
  }

  Future<void> updateProfile({
    required String username,
    required String displayName,
    String? avatarIconKey,
  }) async {
    await _repository.updateUserProfile(
      username: username,
      displayName: displayName,
      avatarIconKey: avatarIconKey,
    );
    _setStatus('Profile & unique @username updated.', isError: false);
  }

  Future<void> toggleHaptics(bool enabled) async {
    await _repository.setHapticsEnabled(enabled);
    _setStatus(
      enabled ? 'Tactile haptics enabled.' : 'Tactile haptics muted.',
      isError: false,
    );
  }

  String generateExportJson() {
    _repository.haptics.lightImpact();
    final json = _repository.exportDatabaseToJson();
    Clipboard.setData(ClipboardData(text: json));
    _setStatus(
      'Database JSON exported & copied to clipboard.',
      isError: false,
    );
    return json;
  }

  Future<bool> importFromJson(String rawJson) async {
    try {
      await _repository.importDatabaseFromJson(rawJson);
      await _repository.haptics.mediumImpact();
      _setStatus(
        'Database successfully imported from JSON.',
        isError: false,
      );
      return true;
    } catch (e) {
      await _repository.haptics.mediumImpact();
      _setStatus(
        'Import failed: ${e.toString()}',
        isError: true,
      );
      return false;
    }
  }

  Future<void> resetAllData() async {
    await _repository.resetProgressionAndData();
    _setStatus(
      'All progression, tasks, and habits have been reset.',
      isError: false,
    );
  }

  void _setStatus(String message, {required bool isError}) {
    _statusMessage = message;
    _isErrorStatus = isError;
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
