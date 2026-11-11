import 'package:flutter/cupertino.dart';

import '../../../../data/services/haptic_service.dart';
import '../../../../domain/models/task_item.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pressable_scale.dart';

/// Quick Task Creator modal bottom sheet:
/// - Title (string, required)
/// - Due Date/Time (timestamp, optional)
/// - Priority/Tag (enum: Low, Medium, High)
class QuickTaskCreatorSheet extends StatefulWidget {
  const QuickTaskCreatorSheet({
    super.key,
    required this.hapticService,
    required this.onCreateTask,
  });

  final HapticService hapticService;
  final Future<void> Function({
    required String title,
    DateTime? dueDate,
    required TaskPriority priority,
  }) onCreateTask;

  @override
  State<QuickTaskCreatorSheet> createState() => _QuickTaskCreatorSheetState();
}

class _QuickTaskCreatorSheetState extends State<QuickTaskCreatorSheet> {
  final TextEditingController _titleController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _hasDueDate = true;
  late DateTime _selectedDueDate;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedDueDate = DateTime.now().add(const Duration(hours: 2));
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
        _validationError = 'Task title is required to craft a quest.';
      });
      return;
    }

    await widget.onCreateTask(
      title: trimmed,
      dueDate: _hasDueDate ? _selectedDueDate : null,
      priority: _selectedPriority,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FrostedSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Craft New Task Block',
                style: PixelCupertinoTheme.headlineStyle(context),
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
          const SizedBox(height: 14),

          // Task Title Field (Required)
          CupertinoTextField(
            key: const Key('quick_task_title_input'),
            controller: _titleController,
            autofocus: true,
            placeholder: 'Task title (e.g., Mine 16 Obsidian Blocks)...',
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
            onChanged: (_) {
              if (_validationError != null) {
                setState(() {
                  _validationError = null;
                });
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 6),
            Text(
              _validationError!,
              style: PixelCupertinoTheme.subheadStyle(context).copyWith(
                color: PixelCupertinoTheme.redstoneCrimson,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Priority / Tag Selector (Low, Medium, High)
          Text(
            'PRIORITY / ORE TAG',
            style: PixelCupertinoTheme.pixelBadgeStyle(
              color: CupertinoDynamicColor.resolve(
                PixelCupertinoTheme.secondaryLabel,
                context,
              ),
            ),
          ),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<TaskPriority>(
            key: const Key('quick_task_priority_control'),
            groupValue: _selectedPriority,
            children: <TaskPriority, Widget>{
              for (final p in TaskPriority.values)
                p: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${p.label} (${p.craftTag})',
                    style: PixelCupertinoTheme.subheadStyle(context).copyWith(
                      fontWeight: _selectedPriority == p
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: CupertinoDynamicColor.resolve(
                        PixelCupertinoTheme.primaryLabel,
                        context,
                      ),
                    ),
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
          const SizedBox(height: 16),

          // Optional Due Date/Time Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Due Date & Time',
                    style: PixelCupertinoTheme.bodyStyle(context),
                  ),
                  Text(
                    'Complete before due time for +5 XP bonus',
                    style: PixelCupertinoTheme.subheadStyle(context),
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
            const SizedBox(height: 10),
            Container(
              height: 136,
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
          const SizedBox(height: 18),

          // Primary Craft Button with PressableScale
          PressableScale(
            onTap: _submit,
            child: Container(
              key: const Key('quick_task_submit_button'),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PixelCupertinoTheme.emeraldXp,
                borderRadius: BorderRadius.circular(11),
                border: const Border(
                  top: BorderSide(color: Color(0x88FFFFFF), width: 1.5),
                  left: BorderSide(color: Color(0x88FFFFFF), width: 1.5),
                  right: BorderSide(color: Color(0x66000000), width: 2.0),
                  bottom: BorderSide(color: Color(0x88000000), width: 2.5),
                ),
              ),
              child: const Text(
                'Add Task (+10 XP / +5 Bonus)',
                style: TextStyle(
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
