import '../models/habit_item.dart';

/// Pure domain engine for consecutive day streak and grace period calculations.
class StreakCalculator {
  const StreakCalculator._();

  /// Calculates consecutive completion days for a given set of `YYYY-MM-DD` date keys.
  ///
  /// - [gracePeriodDays]: Maximum number of missed days tolerated before the streak
  ///   resets to 0. A standard strict daily streak has `gracePeriodDays = 0` (must be
  ///   completed today or yesterday), whereas `gracePeriodDays = 1` tolerates 1 missed day.
  static int calculateStreak({
    required Iterable<String> completedDateKeys,
    required DateTime referenceDate,
    int gracePeriodDays = 1,
  }) {
    final uniqueDates = completedDateKeys
        .map(HabitItem.parseDateKey)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending (most recent first)

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    final mostRecent = uniqueDates.first;
    final daysSinceLastCompletion = today.difference(mostRecent).inDays;

    // If the user has missed more days than allowed by the grace period
    // (Note: if not completed today yet, 1 day gap is yesterday which is 0 missed days;
    // so max allowed calendar day difference from today is gracePeriodDays + 1).
    final maxAllowedGapFromToday = gracePeriodDays + 1;
    if (daysSinceLastCompletion > maxAllowedGapFromToday) {
      return 0;
    }

    int streak = 1;
    for (var i = 0; i < uniqueDates.length - 1; i++) {
      final current = uniqueDates[i];
      final previous = uniqueDates[i + 1];
      final diffDays = current.difference(previous).inDays;

      // Consecutive days have diffDays == 1 (0 missed days between them).
      // With gracePeriodDays, up to (gracePeriodDays + 1) calendar day diff is tolerated.
      if (diffDays <= gracePeriodDays + 1) {
        streak += 1;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculates today's habit completion ratio (0.0 to 1.0):
  /// Completed Active Habits Today / Total Active Habits.
  static double calculateTodayCompletionRatio({
    required List<HabitItem> habits,
    required DateTime today,
  }) {
    final activeHabits = habits.where((h) => h.isActive).toList();
    if (activeHabits.isEmpty) return 0.0;

    final completedToday =
        activeHabits.where((h) => h.isCompletedOn(today)).length;
    return (completedToday / activeHabits.length).clamp(0.0, 1.0);
  }
}
