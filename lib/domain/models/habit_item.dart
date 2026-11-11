import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class HabitItem {
  const HabitItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isActive = true,
    this.gracePeriodDays = 1,
    this.completedDateKeys = const <String>[],
  });

  final String id;
  final String title;
  final bool isActive;
  final int gracePeriodDays;
  final List<String> completedDateKeys;
  final DateTime createdAt;

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

  HabitItem copyWith({
    String? id,
    String? title,
    bool? isActive,
    int? gracePeriodDays,
    List<String>? completedDateKeys,
    DateTime? createdAt,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      completedDateKeys: completedDateKeys ?? this.completedDateKeys,
      createdAt: createdAt ?? this.createdAt,
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

    return HabitItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isActive: active,
      gracePeriodDays: (json['gracePeriodDays'] as num?)?.toInt() ?? 1,
      completedDateKeys: parsedKeys,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
