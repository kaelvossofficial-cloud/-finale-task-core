import 'package:flutter/foundation.dart';
import '../use_cases/level_calculator.dart';

/// Friend / Accountability rival in a shared habit group.
@immutable
class AccountabilityFriend {
  const AccountabilityFriend({
    required this.username,
    required this.displayName,
    required this.streakDays,
    required this.weeklyXp,
    required this.avatarIconKey,
    required this.colorArgb,
    this.nudgedToday = false,
  });

  final String username;
  final String displayName;
  final int streakDays;
  final int weeklyXp;
  final String avatarIconKey;
  final int colorArgb;
  final bool nudgedToday;

  AccountabilityFriend copyWith({
    String? username,
    String? displayName,
    int? streakDays,
    int? weeklyXp,
    String? avatarIconKey,
    int? colorArgb,
    bool? nudgedToday,
  }) {
    return AccountabilityFriend(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      streakDays: streakDays ?? this.streakDays,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      avatarIconKey: avatarIconKey ?? this.avatarIconKey,
      colorArgb: colorArgb ?? this.colorArgb,
      nudgedToday: nudgedToday ?? this.nudgedToday,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'displayName': displayName,
        'streakDays': streakDays,
        'weeklyXp': weeklyXp,
        'avatarIconKey': avatarIconKey,
        'colorArgb': colorArgb,
        'nudgedToday': nudgedToday,
      };

  factory AccountabilityFriend.fromJson(Map<String, dynamic> json) {
    return AccountabilityFriend(
      username: json['username'] as String? ?? 'crafter',
      displayName: json['displayName'] as String? ?? 'Crafter',
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 1,
      weeklyXp: (json['weeklyXp'] as num?)?.toInt() ?? 50,
      avatarIconKey: json['avatarIconKey'] as String? ?? 'crown',
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFF3CE6D6,
      nudgedToday: json['nudgedToday'] as bool? ?? false,
    );
  }
}

@immutable
class UserProgression {
  const UserProgression({
    this.totalXp = 0,
    this.totalCompletedTasks = 0,
    this.onTimeCompletedTasks = 0,
    this.currentTaskStreak = 0,
    this.taskCompletionDateKeys = const <String>[],
    this.hapticsEnabled = true,
    this.username = 'kael_crafter',
    this.displayName = 'Kael Voss',
    this.avatarIconKey = 'crown',
    this.friends = const <AccountabilityFriend>[],
  });

  final int totalXp;
  final int totalCompletedTasks;
  final int onTimeCompletedTasks;
  final int currentTaskStreak;
  final List<String> taskCompletionDateKeys;
  final bool hapticsEnabled;
  final String username;
  final String displayName;
  final String avatarIconKey;
  final List<AccountabilityFriend> friends;

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
    String? username,
    String? displayName,
    String? avatarIconKey,
    List<AccountabilityFriend>? friends,
  }) {
    return UserProgression(
      totalXp: totalXp ?? this.totalXp,
      totalCompletedTasks: totalCompletedTasks ?? this.totalCompletedTasks,
      onTimeCompletedTasks: onTimeCompletedTasks ?? this.onTimeCompletedTasks,
      currentTaskStreak: currentTaskStreak ?? this.currentTaskStreak,
      taskCompletionDateKeys:
          taskCompletionDateKeys ?? this.taskCompletionDateKeys,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarIconKey: avatarIconKey ?? this.avatarIconKey,
      friends: friends ?? this.friends,
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
      'username': username,
      'displayName': displayName,
      'avatarIconKey': avatarIconKey,
      'friends': friends.map((f) => f.toJson()).toList(),
    };
  }

  factory UserProgression.fromJson(Map<String, dynamic> json) {
    final rawKeys = json['taskCompletionDateKeys'];
    final keys = rawKeys is List
        ? rawKeys.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    final rawFriends = json['friends'];
    final parsedFriends = rawFriends is List
        ? rawFriends
            .map((e) => AccountabilityFriend.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(growable: false)
        : const <AccountabilityFriend>[];

    return UserProgression(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      totalCompletedTasks: (json['totalCompletedTasks'] as num?)?.toInt() ?? 0,
      onTimeCompletedTasks:
          (json['onTimeCompletedTasks'] as num?)?.toInt() ?? 0,
      currentTaskStreak: (json['currentTaskStreak'] as num?)?.toInt() ?? 0,
      taskCompletionDateKeys: keys,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      username: json['username'] as String? ?? 'kael_crafter',
      displayName: json['displayName'] as String? ?? 'Kael Voss',
      avatarIconKey: json['avatarIconKey'] as String? ?? 'crown',
      friends: parsedFriends,
    );
  }
}
