import 'package:flutter/foundation.dart';
import '../use_cases/level_calculator.dart';

@immutable
class UserProgression {
  const UserProgression({
    this.totalXp = 0,
    this.totalCompletedTasks = 0,
    this.onTimeCompletedTasks = 0,
    this.currentTaskStreak = 0,
    this.taskCompletionDateKeys = const <String>[],
    this.hapticsEnabled = true,
  });

  final int totalXp;
  final int totalCompletedTasks;
  final int onTimeCompletedTasks;
  final int currentTaskStreak;
  final List<String> taskCompletionDateKeys;
  final bool hapticsEnabled;

  /// Formula: Level = floor(sqrt(XP / 100)) + 1
  int get level => LevelCalculator.calculateLevel(totalXp);

  /// Total XP required to reach [level] + 1.
  int get nextLevelTargetXp => LevelCalculator.xpForLevel(level + 1);

  /// Minimum XP threshold of the current [level].
  int get currentLevelFloorXp => LevelCalculator.xpForLevel(level);

  /// Remaining XP required to reach the next level.
  int get xpRequiredForNextLevel =>
      LevelCalculator.xpRequiredForNextLevel(totalXp);

  /// Progress fraction (0.0 to 1.0) within the current level band.
  double get levelProgress => LevelCalculator.levelProgressFraction(totalXp);

  /// Percentage (0.0 to 100.0) of completed tasks finished on or before due time.
  double get onTimeCompletionRate {
    if (totalCompletedTasks <= 0) return 0.0;
    final ratio = (onTimeCompletedTasks / totalCompletedTasks) * 100.0;
    return ratio.clamp(0.0, 100.0);
  }

  UserProgression copyWith({
    int? totalXp,
    int? totalCompletedTasks,
    int? onTimeCompletedTasks,
    int? currentTaskStreak,
    List<String>? taskCompletionDateKeys,
    bool? hapticsEnabled,
  }) {
    return UserProgression(
      totalXp: totalXp ?? this.totalXp,
      totalCompletedTasks: totalCompletedTasks ?? this.totalCompletedTasks,
      onTimeCompletedTasks: onTimeCompletedTasks ?? this.onTimeCompletedTasks,
      currentTaskStreak: currentTaskStreak ?? this.currentTaskStreak,
      taskCompletionDateKeys:
          taskCompletionDateKeys ?? this.taskCompletionDateKeys,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalXp': totalXp,
      'totalCompletedTasks': totalCompletedTasks,
      'onTimeCompletedTasks': onTimeCompletedTasks,
      'currentTaskStreak': currentTaskStreak,
      'taskCompletionDateKeys': taskCompletionDateKeys,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  factory UserProgression.fromJson(Map<String, dynamic> json) {
    final rawKeys = json['taskCompletionDateKeys'];
    final keys = rawKeys is List
        ? rawKeys.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    return UserProgression(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      totalCompletedTasks: (json['totalCompletedTasks'] as num?)?.toInt() ?? 0,
      onTimeCompletedTasks:
          (json['onTimeCompletedTasks'] as num?)?.toInt() ?? 0,
      currentTaskStreak: (json['currentTaskStreak'] as num?)?.toInt() ?? 0,
      taskCompletionDateKeys: keys,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }
}
