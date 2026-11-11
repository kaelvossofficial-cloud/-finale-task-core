import 'dart:math' as math;

/// Pure domain engine for XP & Level progression calculations.
class LevelCalculator {
  const LevelCalculator._();

  /// Base XP awarded for completing any task.
  static const int baseTaskXp = 10;

  /// Bonus XP awarded when completing a task on or before its due timestamp.
  static const int onTimeBonusXp = 5;

  /// Calculates user level using:
  /// Level = floor(sqrt(XP / 100)) + 1
  static int calculateLevel(int xp) {
    final safeXp = math.max(0, xp);
    return math.sqrt(safeXp / 100.0).floor() + 1;
  }

  /// Calculates total cumulative XP needed to enter [level].
  /// Level 1 starts at 0 XP; Level 2 at 100 XP; Level 3 at 400 XP; Level 4 at 900 XP.
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    final n = level - 1;
    return 100 * n * n;
  }

  /// Calculates remaining XP needed from [currentXp] to reach the next level.
  static int xpRequiredForNextLevel(int currentXp) {
    final safeXp = math.max(0, currentXp);
    final currentLevel = calculateLevel(safeXp);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    return math.max(0, nextLevelXp - safeXp);
  }

  /// Calculates normalized progress (0.0 to 1.0) within the active level bracket.
  static double levelProgressFraction(int currentXp) {
    final safeXp = math.max(0, currentXp);
    final currentLevel = calculateLevel(safeXp);
    final floorXp = xpForLevel(currentLevel);
    final ceilingXp = xpForLevel(currentLevel + 1);
    final span = ceilingXp - floorXp;
    if (span <= 0) return 0.0;
    return ((safeXp - floorXp) / span).clamp(0.0, 1.0);
  }

  /// Calculates total XP reward for a task completed at [completedAt] with optional [dueDate].
  static ({int xp, bool onTime}) evaluateTaskReward({
    required DateTime completedAt,
    DateTime? dueDate,
  }) {
    final isOnTime = dueDate == null || !completedAt.isAfter(dueDate);
    final xp = baseTaskXp + (isOnTime ? onTimeBonusXp : 0);
    return (xp: xp, onTime: isOnTime);
  }
}
