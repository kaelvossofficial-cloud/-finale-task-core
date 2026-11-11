import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../data/repositories/task_habit_repository.dart';
import '../../../../data/services/haptic_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required TaskHabitRepository repository})
      : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final TaskHabitRepository _repository;

  bool get hapticsEnabled => _repository.progression.hapticsEnabled;
  HapticService get haptics => _repository.haptics;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool _isErrorStatus = false;
  bool get isErrorStatus => _isErrorStatus;

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
