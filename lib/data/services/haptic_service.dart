import 'package:flutter/services.dart';

/// Centralized tactile feedback service following Apple HIG & Finale Task Core rules.
/// Respects the global [isEnabled] toggle from Settings.
class HapticService {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Triggered on toggles, segmented controls, and subtle button taps.
  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Triggered on swipe-to-complete threshold snap and destructive actions.
  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Triggered on wheel pickers (`CupertinoPicker` / `CupertinoDatePicker`).
  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Triggered on level-up celebration.
  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }
}
