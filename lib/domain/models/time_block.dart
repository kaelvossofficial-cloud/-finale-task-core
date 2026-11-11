import 'package:flutter/foundation.dart';

/// A named slice of the day (e.g. Dawn 05:00–09:00) used to group habits and
/// tasks on the Home drum picker. Blocks may wrap past midnight.
@immutable
class TimeBlock {
  const TimeBlock({
    required this.id,
    required this.name,
    required this.startMinute,
    required this.endMinute,
    required this.iconKey,
  });

  final String id;
  final String name;

  /// Minutes after midnight, inclusive.
  final int startMinute;

  /// Minutes after midnight, exclusive. May be smaller than [startMinute]
  /// when the block wraps past midnight.
  final int endMinute;

  /// Key of the pixel glyph used to draw this block (UI layer resolves it).
  final String iconKey;

  static const List<TimeBlock> defaults = <TimeBlock>[
    TimeBlock(
      id: 'dawn',
      name: 'Dawn',
      startMinute: 5 * 60,
      endMinute: 9 * 60,
      iconKey: 'sunrise',
    ),
    TimeBlock(
      id: 'day',
      name: 'Day',
      startMinute: 9 * 60,
      endMinute: 17 * 60,
      iconKey: 'sun',
    ),
    TimeBlock(
      id: 'dusk',
      name: 'Dusk',
      startMinute: 17 * 60,
      endMinute: 21 * 60,
      iconKey: 'sunset',
    ),
    TimeBlock(
      id: 'night',
      name: 'Night',
      startMinute: 21 * 60,
      endMinute: 5 * 60,
      iconKey: 'moon',
    ),
  ];

  static TimeBlock? byId(String? id) {
    if (id == null) return null;
    for (final b in defaults) {
      if (b.id == id) return b;
    }
    return null;
  }

  bool get wraps => endMinute <= startMinute;

  bool containsMinute(int minute) {
    if (wraps) return minute >= startMinute || minute < endMinute;
    return minute >= startMinute && minute < endMinute;
  }

  bool contains(DateTime time) => containsMinute(time.hour * 60 + time.minute);

  static TimeBlock current(DateTime now) {
    for (final b in defaults) {
      if (b.contains(now)) return b;
    }
    return defaults.first;
  }

  static String _hhmm(int minute) {
    final h = (minute ~/ 60).toString().padLeft(2, '0');
    final m = (minute % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get rangeLabel => '${_hhmm(startMinute)}–${_hhmm(endMinute)}';

  @override
  bool operator ==(Object other) => other is TimeBlock && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
