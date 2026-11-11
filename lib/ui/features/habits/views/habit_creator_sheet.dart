import 'package:flutter/cupertino.dart';

import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/habit_item.dart';
import '../../../../domain/models/time_block.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';

class HabitCreatorSheet extends StatefulWidget {
  const HabitCreatorSheet({
    super.key,
    required this.hapticService,
    required this.onCreateHabit,
    this.existingHabit,
    this.onUpdateHabit,
  });

  final HapticService hapticService;
  final Future<void> Function({
    required String title,
    required int gracePeriodDays,
    String iconKey,
    int colorArgb,
    String blockId,
    String? reminderTime,
    bool isAlarmEnabled,
  }) onCreateHabit;
  final HabitItem? existingHabit;
  final Future<void> Function(HabitItem updated)? onUpdateHabit;

  @override
  State<HabitCreatorSheet> createState() => _HabitCreatorSheetState();
}

class _HabitCreatorSheetState extends State<HabitCreatorSheet> {
  late final TextEditingController _titleController;
  late int _gracePeriodDays;
  late String _selectedIconKey;
  late int _selectedColorArgb;
  late String _selectedBlockId;
  late bool _hasReminder;
  late String _reminderTime;
  late bool _isAlarmEnabled;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingHabit;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _gracePeriodDays = existing?.gracePeriodDays ?? 1;
    _selectedIconKey = existing?.iconKey ?? 'potion';
    _selectedColorArgb = existing?.colorArgb ?? HabitItem.defaultColorArgb;
    _selectedBlockId = existing?.blockId ?? 'dawn';
    _hasReminder = existing?.reminderTime != null;
    _reminderTime = existing?.reminderTime ?? '08:00';
    _isAlarmEnabled = existing?.isAlarmEnabled ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trimmed = _titleController.text.trim();
    if (trimmed.isEmpty) {
      await widget.hapticService.mediumImpact();
      setState(() {
        _error = 'Habit title is required.';
      });
      return;
    }
    if (widget.existingHabit != null && widget.onUpdateHabit != null) {
      final updated = widget.existingHabit!.copyWith(
        title: trimmed,
        gracePeriodDays: _gracePeriodDays,
        iconKey: _selectedIconKey,
        colorArgb: _selectedColorArgb,
        blockId: _selectedBlockId,
        reminderTime: _hasReminder ? _reminderTime : null,
        clearReminder: !_hasReminder,
        isAlarmEnabled: _isAlarmEnabled,
      );
      await widget.onUpdateHabit!(updated);
    } else {
      await widget.onCreateHabit(
        title: trimmed,
        gracePeriodDays: _gracePeriodDays,
        iconKey: _selectedIconKey,
        colorArgb: _selectedColorArgb,
        blockId: _selectedBlockId,
        reminderTime: _hasReminder ? _reminderTime : null,
        isAlarmEnabled: _isAlarmEnabled,
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingHabit != null;
    final activeColor = Color(_selectedColorArgb);

    return FrostedSheetContainer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PixelSpriteIcon.fromKey(
                      _selectedIconKey,
                      size: 20,
                      primaryColor: activeColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Customize Habit' : 'Forge Habit Block',
                      style: PixelCupertinoTheme.headlineStyle(context),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: PixelCupertinoTheme.subheadStyle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            CupertinoTextField(
              key: const Key('habit_title_input'),
              controller: _titleController,
              autofocus: !isEditing,
              placeholder: 'Habit name...',
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              style: PixelCupertinoTheme.bodyStyle(context),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.secondaryGroupedBackground,
                  context,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 5),
              Text(
                _error!,
                style: PixelCupertinoTheme.subheadStyle(context).copyWith(
                  color: PixelCupertinoTheme.redstoneCrimson,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // 1. Custom Pixel Icon Selector
            Text(
              'PIXEL ICON',
              style: PixelCupertinoTheme.pixelBadgeStyle(
                color: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.secondaryLabel,
                  context,
                ),
                fontSize: 9.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PixelSpriteIcon.habitIconCatalog.map((item) {
                final (key, _, spriteType) = item;
                final selected = key == _selectedIconKey;
                return PressableScale(
                  onTap: () {
                    widget.hapticService.selectionClick();
                    setState(() {
                      _selectedIconKey = key;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? activeColor.withValues(alpha: 0.22)
                          : CupertinoDynamicColor.resolve(
                              PixelCupertinoTheme.tertiarySlotBackground,
                              context,
                            ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? activeColor
                            : CupertinoColors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: PixelSpriteIcon(
                      type: spriteType,
                      size: 17,
                      primaryColor: selected
                          ? activeColor
                          : CupertinoDynamicColor.resolve(
                              PixelCupertinoTheme.secondaryLabel,
                              context,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // 2. Custom Color Swatches
            Text(
              'BLOCK COLOR',
              style: PixelCupertinoTheme.pixelBadgeStyle(
                color: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.secondaryLabel,
                  context,
                ),
                fontSize: 9.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: PixelCupertinoTheme.habitPaletteArgb.map((argb) {
                final selected = argb == _selectedColorArgb;
                final swatch = Color(argb);
                return PressableScale(
                  onTap: () {
                    widget.hapticService.selectionClick();
                    setState(() {
                      _selectedColorArgb = argb;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: swatch,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? CupertinoColors.white
                            : CupertinoColors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: selected
                          ? PixelCupertinoTheme.glowShadows(swatch)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // 3. Time Block Selector (Dawn / Day / Dusk / Night)
            Text(
              'TIME BLOCK',
              style: PixelCupertinoTheme.pixelBadgeStyle(
                color: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.secondaryLabel,
                  context,
                ),
                fontSize: 9.5,
              ),
            ),
            const SizedBox(height: 6),
            CupertinoSlidingSegmentedControl<String>(
              groupValue: _selectedBlockId,
              children: <String, Widget>{
                for (final b in TimeBlock.defaults)
                  b.id: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      b.name,
                      style: PixelCupertinoTheme.subheadStyle(context),
                    ),
                  ),
              },
              onValueChanged: (val) {
                if (val == null) return;
                widget.hapticService.lightImpact();
                setState(() {
                  _selectedBlockId = val;
                });
              },
            ),
            const SizedBox(height: 12),

            // 4. Grace Period Selector
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _gracePeriodDays,
              children: const <int, Widget>{
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('0d Strict'),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('1d Grace'),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('2d Grace'),
                ),
              },
              onValueChanged: (val) {
                if (val == null) return;
                widget.hapticService.lightImpact();
                setState(() {
                  _gracePeriodDays = val;
                });
              },
            ),
            const SizedBox(height: 12),

            // 5. Reminder & Alarm Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const PixelSpriteIcon(
                      type: PixelSpriteType.bell,
                      size: 15,
                      primaryColor: PixelCupertinoTheme.diamondCyan,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Reminder ($_reminderTime)',
                      style: PixelCupertinoTheme.bodyStyle(context),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: _hasReminder,
                  activeTrackColor: activeColor,
                  onChanged: (val) {
                    widget.hapticService.lightImpact();
                    setState(() {
                      _hasReminder = val;
                    });
                  },
                ),
              ],
            ),
            if (_hasReminder)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ring Alarm (iOS/Android)',
                    style: PixelCupertinoTheme.subheadStyle(context),
                  ),
                  CupertinoSwitch(
                    value: _isAlarmEnabled,
                    activeTrackColor: PixelCupertinoTheme.goldIngot,
                    onChanged: (val) {
                      widget.hapticService.lightImpact();
                      setState(() {
                        _isAlarmEnabled = val;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),

            PressableScale(
              onTap: _submit,
              child: Container(
                key: const Key('habit_submit_button'),
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: PixelCupertinoTheme.glowShadows(activeColor),
                ),
                child: Text(
                  isEditing ? 'Save Habit' : 'Forge Habit',
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.41,
                    color: Color(0xFF0A1F10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
