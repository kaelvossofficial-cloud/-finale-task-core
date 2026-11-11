import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Daily story / note entry recorded when fulfilling a habit.
@immutable
class HabitStoryEntry {
  const HabitStoryEntry({
    required this.dateKey,
    required this.note,
    required this.timestamp,
  });

  final String dateKey;
  final String note;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dateKey': dateKey,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HabitStoryEntry.fromJson(Map<String, dynamic> json) {
    return HabitStoryEntry(
      dateKey: json['dateKey'] as String? ?? '',
      note: json['note'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

@immutable
class HabitItem {
  const HabitItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isActive = true,
    this.gracePeriodDays = 1,
    this.completedDateKeys = const <String>[],
    this.iconKey = 'potion',
    this.colorArgb = defaultColorArgb,
    this.blockId = 'dawn',
    this.reminderTime,
    this.isAlarmEnabled = false,
    this.snoozedUntil,
    this.stories = const <HabitStoryEntry>[],
  });

  /// Emerald XP green.
  static const int defaultColorArgb = 0xFF17DD62;

  final String id;
  final String title;
  final bool isActive;
  final int gracePeriodDays;
  final List<String> completedDateKeys;
  final DateTime createdAt;

  /// Pixel glyph key for the habit icon.
  final String iconKey;

  /// ARGB colour used to tint the habit block.
  final int colorArgb;

  /// Time block id (`dawn`, `day`, `dusk`, `night`).
  final String? blockId;

  /// Optional daily reminder `HH:mm` (e.g. `08:30`).
  final String? reminderTime;

  /// Whether reminder triggers full alarm sound/vibration.
  final bool isAlarmEnabled;

  /// When set and in the future, the habit is hidden from the Home drum.
  final DateTime? snoozedUntil;

  /// Daily stories / notes logged when completing this habit.
  final List<HabitStoryEntry> stories;

  /// Formats a [DateTime] into a canonical `YYYY-MM-DD` key.
  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a canonical `YYYY-MM-DD` key into a local midnight [DateTime].
  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  bool isCompletedOn(DateTime date) {
    return completedDateKeys.contains(dateKey(date));
  }

  bool isSnoozedAt(DateTime now) {
    final until = snoozedUntil;
    return until != null && now.isBefore(until);
  }

  /// Smart Nudge label based on reminder time or block window.
  String get smartNudgeLabel {
    if (reminderTime != null && reminderTime!.isNotEmpty) {
      return reminderTime!;
    }
    switch (blockId) {
      case 'dawn':
        return '07:30';
      case 'day':
        return '13:00';
      case 'dusk':
        return '18:30';
      case 'night':
        return '21:30';
      default:
        return '09:00';
    }
  }

  HabitItem copyWith({
    String? id,
    String? title,
    bool? isActive,
    int? gracePeriodDays,
    List<String>? completedDateKeys,
    DateTime? createdAt,
    String? iconKey,
    int? colorArgb,
    String? blockId,
    bool clearBlock = false,
    String? reminderTime,
    bool clearReminder = false,
    bool? isAlarmEnabled,
    DateTime? snoozedUntil,
    bool clearSnooze = false,
    List<HabitStoryEntry>? stories,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      completedDateKeys: completedDateKeys ?? this.completedDateKeys,
      createdAt: createdAt ?? this.createdAt,
      iconKey: iconKey ?? this.iconKey,
      colorArgb: colorArgb ?? this.colorArgb,
      blockId: clearBlock ? null : (blockId ?? this.blockId),
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      snoozedUntil: clearSnooze ? null : (snoozedUntil ?? this.snoozedUntil),
      stories: stories ?? this.stories,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isActive': isActive ? 1 : 0,
      'gracePeriodDays': gracePeriodDays,
      'completedDateKeys': jsonEncode(completedDateKeys),
      'createdAt': createdAt.toIso8601String(),
      'iconKey': iconKey,
      'colorArgb': colorArgb,
      'blockId': blockId,
      'reminderTime': reminderTime,
      'isAlarmEnabled': isAlarmEnabled ? 1 : 0,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'stories': jsonEncode(stories.map((s) => s.toJson()).toList()),
    };
  }

  factory HabitItem.fromJson(Map<String, dynamic> json) {
    final rawActive = json['isActive'];
    final active =
        rawActive == null ? true : (rawActive == true || rawActive == 1);

    final rawKeys = json['completedDateKeys'];
    List<String> parsedKeys = const <String>[];
    if (rawKeys is String && rawKeys.isNotEmpty) {
      final decoded = jsonDecode(rawKeys) as List<dynamic>;
      parsedKeys = decoded.map((e) => e.toString()).toList(growable: false);
    } else if (rawKeys is List) {
      parsedKeys = rawKeys.map((e) => e.toString()).toList(growable: false);
    }

    final rawStories = json['stories'];
    List<HabitStoryEntry> parsedStories = const <HabitStoryEntry>[];
    if (rawStories is String && rawStories.isNotEmpty) {
      final decoded = jsonDecode(rawStories) as List<dynamic>;
      parsedStories = decoded
          .map((e) =>
              HabitStoryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    } else if (rawStories is List) {
      parsedStories = rawStories
          .map((e) =>
              HabitStoryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    }

    final rawSnooze = json['snoozedUntil'];
    final rawIcon = json['iconKey'];
    final rawAlarm = json['isAlarmEnabled'];

    return HabitItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isActive: active,
      gracePeriodDays: (json['gracePeriodDays'] as num?)?.toInt() ?? 1,
      completedDateKeys: parsedKeys,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      iconKey: rawIcon is String && rawIcon.isNotEmpty ? rawIcon : 'potion',
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? defaultColorArgb,
      blockId: json['blockId'] as String? ?? 'dawn',
      reminderTime: json['reminderTime'] as String?,
      isAlarmEnabled: rawAlarm == true || rawAlarm == 1,
      snoozedUntil: rawSnooze is String && rawSnooze.isNotEmpty
          ? DateTime.parse(rawSnooze)
          : null,
      stories: parsedStories,
    );
  }
}
