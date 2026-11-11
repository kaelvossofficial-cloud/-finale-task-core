import 'package:flutter/foundation.dart';

/// Priority / Tag enum as specified in the functional requirements.
enum TaskPriority {
  low('Low', 'IRON'),
  medium('Medium', 'GOLD'),
  high('High', 'REDSTONE');

  const TaskPriority(this.label, this.craftTag);
  final String label;
  final String craftTag;

  static TaskPriority fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }
}

/// Chronological buckets for the Main Task Screen.
enum TaskChronologicalGroup {
  today('Today'),
  upcoming('Upcoming'),
  completed('Completed');

  const TaskChronologicalGroup(this.title);
  final String title;
}

@immutable
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.awardedXp = 0,
    this.completedOnTime = false,
    this.reminderAt,
    this.isAlarmEnabled = false,
    this.blockId,
    this.colorArgb = 0xFFFFAA00,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int awardedXp;
  final bool completedOnTime;
  final DateTime? reminderAt;
  final bool isAlarmEnabled;
  final String? blockId;
  final int colorArgb;

  /// Determines chronological section (`Today`, `Upcoming`, `Completed`).
  TaskChronologicalGroup groupFor(DateTime referenceNow) {
    if (isCompleted) {
      return TaskChronologicalGroup.completed;
    }
    if (dueDate == null) {
      return TaskChronologicalGroup.today;
    }
    final endOfToday = DateTime(
      referenceNow.year,
      referenceNow.month,
      referenceNow.day,
      23,
      59,
      59,
      999,
    );
    if (!dueDate!.isAfter(endOfToday)) {
      return TaskChronologicalGroup.today;
    }
    return TaskChronologicalGroup.upcoming;
  }

  /// Checks whether this task has a due date that is currently overdue.
  bool isOverdue(DateTime referenceNow) {
    if (isCompleted || dueDate == null) return false;
    return referenceNow.isAfter(dueDate!);
  }

  /// True when task due time is within the next 60 minutes (or overdue) and incomplete.
  bool isDueNear(DateTime referenceNow) {
    if (isCompleted || dueDate == null) return false;
    final diff = dueDate!.difference(referenceNow).inMinutes;
    return diff <= 60;
  }

  /// Concise corner date format: `Nov 11 14:30` (no "Due" prefix).
  String get shortCornerTimestamp {
    final target = dueDate ?? reminderAt;
    if (target == null) return '';
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(target.month - 1).clamp(0, 11)];
    final d = target.day.toString().padLeft(2, '0');
    final hh = target.hour.toString().padLeft(2, '0');
    final mm = target.minute.toString().padLeft(2, '0');
    return '$m $d $hh:$mm';
  }

  TaskItem copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? awardedXp,
    bool? completedOnTime,
    DateTime? reminderAt,
    bool clearReminder = false,
    bool? isAlarmEnabled,
    String? blockId,
    int? colorArgb,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      awardedXp: awardedXp ?? this.awardedXp,
      completedOnTime: completedOnTime ?? this.completedOnTime,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      blockId: blockId ?? this.blockId,
      colorArgb: colorArgb ?? this.colorArgb,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'awardedXp': awardedXp,
      'completedOnTime': completedOnTime ? 1 : 0,
      'reminderAt': reminderAt?.toIso8601String(),
      'isAlarmEnabled': isAlarmEnabled ? 1 : 0,
      'blockId': blockId,
      'colorArgb': colorArgb,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final rawCompleted = json['isCompleted'];
    final isComp = rawCompleted == true || rawCompleted == 1;
    final rawOnTime = json['completedOnTime'];
    final onTime = rawOnTime == true || rawOnTime == 1;
    final rawAlarm = json['isAlarmEnabled'];
    final alarm = rawAlarm == true || rawAlarm == 1;

    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null && (json['dueDate'] as String).isNotEmpty
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: TaskPriority.fromString(json['priority'] as String?),
      isCompleted: isComp,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null &&
              (json['completedAt'] as String).isNotEmpty
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      awardedXp: (json['awardedXp'] as num?)?.toInt() ?? 0,
      completedOnTime: onTime,
      reminderAt: json['reminderAt'] != null &&
              (json['reminderAt'] as String).isNotEmpty
          ? DateTime.parse(json['reminderAt'] as String)
          : null,
      isAlarmEnabled: alarm,
      blockId: json['blockId'] as String?,
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFFFFAA00,
    );
  }
}
