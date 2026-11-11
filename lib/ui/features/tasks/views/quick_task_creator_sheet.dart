import 'package:flutter/cupertino.dart';

import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/task_item.dart';
import '../../../../domain/models/time_block.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';

/// Quick Task Creator & Reminder/Alarm Editor sheet:
/// - Supports creating a new task or editing an existing task's reminder/alarm (via left-swipe).
/// - Includes iOS & Android compatible Reminder + Alarm switch.
class QuickTaskCreatorSheet extends StatefulWidget {
  const QuickTaskCreatorSheet({
    super.key,
    required this.hapticService,
    required this.onCreateTask,
    this.existingTask,
    this.onUpdateTask,
  });

  final HapticService hapticService;
  final Future<void> Function({
    required String title,
    DateTime? dueDate,
    required TaskPriority priority,
    DateTime? reminderAt,
    bool isAlarmEnabled,
    String? blockId,
  }) onCreateTask;
  final TaskItem? existingTask;
  final Future<void> Function(TaskItem updated)? onUpdateTask;

  @override
  State<QuickTaskCreatorSheet> createState() => _QuickTaskCreatorSheetState();
}

class _QuickTaskCreatorSheetState extends State<QuickTaskCreatorSheet> {
  late final TextEditingController _titleController;
  late TaskPriority _selectedPriority;
  late bool _hasDueDate;
  late DateTime _selectedDueDate;
  late bool _isAlarmEnabled;
  late String _selectedBlockId;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTask;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _selectedPriority = existing?.priority ?? TaskPriority.medium;
    _hasDueDate = existing != null ? existing.dueDate != null : true;
    _selectedDueDate =
        existing?.dueDate ?? DateTime.now().add(const Duration(hours: 2));
    _isAlarmEnabled = existing?.isAlarmEnabled ?? false;
    _selectedBlockId =
        existing?.blockId ?? TimeBlock.current(_selectedDueDate).id;
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
        _validationError = 'Task title is required.';
      });
      return;
    }

    if (widget.existingTask != null && widget.onUpdateTask != null) {
      final updated = widget.existingTask!.copyWith(
        title: trimmed,
        dueDate: _hasDueDate ? _selectedDueDate : null,
        clearDueDate: !_hasDueDate,
        reminderAt: _hasDueDate ? _selectedDueDate : null,
        clearReminder: !_hasDueDate,
        priority: _selectedPriority,
        isAlarmEnabled: _isAlarmEnabled,
        blockId: _selectedBlockId,
      );
      await widget.onUpdateTask!(updated);
    } else {
      await widget.onCreateTask(
        title: trimmed,
        dueDate: _hasDueDate ? _selectedDueDate : null,
        priority: _selectedPriority,
        reminderAt: _hasDueDate ? _selectedDueDate : null,
        isAlarmEnabled: _isAlarmEnabled,
        blockId: _selectedBlockId,
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  PixelSpriteType _barSprite(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return PixelSpriteType.redstoneBar;
      case TaskPriority.medium:
        return PixelSpriteType.goldBar;
      case TaskPriority.low:
        return PixelSpriteType.ironBar;
    }
  }

  Color _barColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return PixelCupertinoTheme.redstoneCrimson;
      case TaskPriority.medium:
        return PixelCupertinoTheme.goldIngot;
      case TaskPriority.low:
        return PixelCupertinoTheme.ironIngot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    return FrostedSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  PixelSpriteIcon(
                    type: isEditing
                        ? PixelSpriteType.alarm
                        : PixelSpriteType.craftAxe,
                    size: 18,
                    primaryColor: PixelCupertinoTheme.emeraldXp,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Edit Quest & Reminder' : 'Craft Quest',
                    style: PixelCupertinoTheme.headlineStyle(context),
                  ),
                ],
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(28, 28),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: PixelCupertinoTheme.subheadStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task Title Field (Required)
          CupertinoTextField(
            key: const Key('quick_task_title_input'),
            controller: _titleController,
            autofocus: !isEditing,
            placeholder: 'Quest title...',
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            style: PixelCupertinoTheme.bodyStyle(context),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                PixelCupertinoTheme.secondaryGroupedBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _validationError != null
                    ? PixelCupertinoTheme.redstoneCrimson
                    : CupertinoDynamicColor.resolve(
                        PixelCupertinoTheme.hairlineSeparator,
                        context,
                      ),
                width: 1.0,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 5),
            Text(
              _validationError!,
              style: PixelCupertinoTheme.subheadStyle(context).copyWith(
                color: PixelCupertinoTheme.redstoneCrimson,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Priority Ore Bar Selector (Just Iron / Gold / Redstone bar icons)
          CupertinoSlidingSegmentedControl<TaskPriority>(
            key: const Key('quick_task_priority_control'),
            groupValue: _selectedPriority,
            children: <TaskPriority, Widget>{
              for (final p in TaskPriority.values)
                p: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelSpriteIcon(
                        type: _barSprite(p),
                        size: 14,
                        primaryColor: _barColor(p),
                        secondaryColor: CupertinoColors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.craftTag,
                        style: PixelCupertinoTheme.pixelBadgeStyle(
                          color: _barColor(p),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
            },
            onValueChanged: (value) {
              if (value == null) return;
              widget.hapticService.lightImpact();
              setState(() {
                _selectedPriority = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Reminder & Alarm Row (iOS Time-Sensitive / Android Exact Alarm compatible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const PixelSpriteIcon(
                    type: PixelSpriteType.bell,
                    size: 16,
                    primaryColor: PixelCupertinoTheme.diamondCyan,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reminder & Due Time',
                    style: PixelCupertinoTheme.bodyStyle(context),
                  ),
                ],
              ),
              CupertinoSwitch(
                key: const Key('quick_task_due_toggle'),
                value: _hasDueDate,
                activeTrackColor: PixelCupertinoTheme.emeraldXp,
                onChanged: (val) {
                  widget.hapticService.lightImpact();
                  setState(() {
                    _hasDueDate = val;
                  });
                },
              ),
            ],
          ),

          if (_hasDueDate) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const PixelSpriteIcon(
                      type: PixelSpriteType.alarm,
                      size: 15,
                      primaryColor: PixelCupertinoTheme.goldIngot,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sound Alarm (iOS/Android)',
                      style: PixelCupertinoTheme.subheadStyle(context),
                    ),
                  ],
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
            const SizedBox(height: 8),
            Container(
              height: 126,
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.secondaryGroupedBackground,
                  context,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _selectedDueDate,
                onDateTimeChanged: (newDate) {
                  widget.hapticService.selectionClick();
                  _selectedDueDate = newDate;
                },
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Primary Craft Button
          PressableScale(
            onTap: _submit,
            child: Container(
              key: const Key('quick_task_submit_button'),
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PixelCupertinoTheme.emeraldXp,
                borderRadius: BorderRadius.circular(11),
                boxShadow: PixelCupertinoTheme.glowShadows(
                  PixelCupertinoTheme.emeraldXp,
                  intensity: 0.35,
                ),
              ),
              child: Text(
                isEditing ? 'Save Reminder' : 'Craft Quest (+15xp)',
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
    );
  }
}
