import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/habit_item.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/user_progression.dart';

/// Offline-first persistence service backed by SQLite (`sqflite`) on Android/iOS
/// and synchronized with `SharedPreferences` for instant snapshot export/import and test compatibility.
class LocalStorageService {
  LocalStorageService({this.enableSqlite = true});

  final bool enableSqlite;

  static const String _tasksPrefsKey = 'finale_core_tasks_v1';
  static const String _habitsPrefsKey = 'finale_core_habits_v1';
  static const String _progressionPrefsKey = 'finale_core_progression_v1';
  static const String _seededPrefsKey = 'finale_core_seeded_v1';

  Database? _db;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (!enableSqlite || kIsWeb) return;

    try {
      final dbDir = await getDatabasesPath();
      final dbPath = p.join(dbDir, 'finale_task_core.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              dueDate TEXT,
              priority TEXT NOT NULL,
              isCompleted INTEGER NOT NULL,
              createdAt TEXT NOT NULL,
              completedAt TEXT,
              awardedXp INTEGER NOT NULL,
              completedOnTime INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE habits (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              isActive INTEGER NOT NULL,
              gracePeriodDays INTEGER NOT NULL,
              completedDateKeys TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (_) {
      // Fallback to SharedPreferences when running in headless widget tests or desktop without FFI.
      _db = null;
    }
  }

  Future<bool> isSeeded() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_seededPrefsKey) ?? false;
  }

  Future<void> markSeeded(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_seededPrefsKey, value);
  }

  Future<List<TaskItem>> loadTasks() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_db != null) {
      try {
        final rows = await _db!.query('tasks', orderBy: 'createdAt DESC');
        if (rows.isNotEmpty) {
          return rows.map(TaskItem.fromJson).toList();
        }
      } catch (_) {}
    }

    final raw = _prefs!.getString(_tasksPrefsKey);
    if (raw == null || raw.isEmpty) return <TaskItem>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
            (item) => TaskItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs!.setString(_tasksPrefsKey, encoded);

    if (_db != null) {
      try {
        final batch = _db!.batch();
        batch.delete('tasks');
        for (final task in tasks) {
          batch.insert(
            'tasks',
            task.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      } catch (_) {}
    }
  }

  Future<List<HabitItem>> loadHabits() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_db != null) {
      try {
        final rows = await _db!.query('habits', orderBy: 'createdAt ASC');
        if (rows.isNotEmpty) {
          return rows.map(HabitItem.fromJson).toList();
        }
      } catch (_) {}
    }

    final raw = _prefs!.getString(_habitsPrefsKey);
    if (raw == null || raw.isEmpty) return <HabitItem>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) =>
            HabitItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveHabits(List<HabitItem> habits) async {
    _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _prefs!.setString(_habitsPrefsKey, encoded);

    if (_db != null) {
      try {
        final batch = _db!.batch();
        batch.delete('habits');
        for (final habit in habits) {
          batch.insert(
            'habits',
            habit.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      } catch (_) {}
    }
  }

  Future<UserProgression> loadProgression() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_progressionPrefsKey);
    if (raw == null || raw.isEmpty) {
      return const UserProgression();
    }
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return UserProgression.fromJson(decoded);
  }

  Future<void> saveProgression(UserProgression progression) async {
    _prefs ??= await SharedPreferences.getInstance();
    final encoded = jsonEncode(progression.toJson());
    await _prefs!.setString(_progressionPrefsKey, encoded);
  }

  Future<void> clearAll() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_tasksPrefsKey);
    await _prefs!.remove(_habitsPrefsKey);
    await _prefs!.remove(_progressionPrefsKey);
    await _prefs!.setBool(_seededPrefsKey, true);

    if (_db != null) {
      try {
        await _db!.delete('tasks');
        await _db!.delete('habits');
      } catch (_) {}
    }
  }
}
