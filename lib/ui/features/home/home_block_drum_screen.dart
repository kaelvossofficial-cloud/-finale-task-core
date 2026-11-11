import 'package:flutter/cupertino.dart';

import '../../../data/repositories/task_habit_repository.dart';
import '../../../domain/models/task_item.dart';
import '../../../domain/models/time_block.dart';
import '../../../domain/use_cases/block_planner.dart';
import '../../core/theme/pixel_cupertino_theme.dart';
import '../../core/widgets/pixel_art_painters.dart';
import '../../core/widgets/pressable_scale.dart';

/// Home Drum Picker Screen:
/// - Displays Heading of Block Name & Live Time Range (`Dawn 05:00–09:00`, `Day 09:00–17:00`, etc.)
/// - Near-Time Notification Bar with 1-tap `✓ DONE` action when a task's due time is near
/// - UIPickerView / Drum Picker (`ListWheelScrollView`) animation & style where the user
///   slides right to complete and slides left to delay (`+15m`, `+1h`, `Tomorrow`).
class HomeBlockDrumScreen extends StatefulWidget {
  const HomeBlockDrumScreen({
    super.key,
    required this.repository,
  });

  final TaskHabitRepository repository;

  @override
  State<HomeBlockDrumScreen> createState() => _HomeBlockDrumScreenState();
}

class _HomeBlockDrumScreenState extends State<HomeBlockDrumScreen> {
  late TimeBlock _selectedBlock;
  late FixedExtentScrollController _wheelController;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedBlock = TimeBlock.current(widget.repository.now);
    _wheelController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void _selectBlock(TimeBlock block) {
    widget.repository.haptics.selectionClick();
    setState(() {
      _selectedBlock = block;
      _focusedIndex = 0;
    });
    if (_wheelController.hasClients) {
      _wheelController.jumpToItem(0);
    }
  }

  Future<void> _handleCompleteEntry(BlockEntry entry) async {
    await widget.repository.haptics.mediumImpact();
    if (entry is TaskEntry) {
      await widget.repository.completeTask(entry.task.id);
    } else if (entry is HabitEntry) {
      await widget.repository.toggleHabitCompletion(entry.habit.id);
    }
  }

  void _handleDelayEntry(BuildContext context, BlockEntry entry) {
    widget.repository.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => CupertinoActionSheet(
        title: Text('Delay "${entry.title}"'),
        message: const Text('Choose how long to snooze this block item:'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              _applyDelay(entry, const Duration(minutes: 15));
            },
            child: const Text('+15 Minutes'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              _applyDelay(entry, const Duration(hours: 1));
            },
            child: const Text('+1 Hour'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              _applyDelay(entry, const Duration(days: 1));
            },
            child: const Text('Tomorrow'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetCtx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _applyDelay(BlockEntry entry, Duration duration) async {
    if (entry is TaskEntry) {
      await widget.repository.delayTask(entry.task.id, duration);
    } else if (entry is HabitEntry) {
      await widget.repository.delayHabit(entry.habit.id, duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final now = widget.repository.now;
        final entries = BlockPlanner.entriesFor(
          block: _selectedBlock,
          tasks: widget.repository.tasks,
          habits: widget.repository.habits,
          now: now,
        );
        final blockProgress = BlockPlanner.progressFor(
          block: _selectedBlock,
          tasks: widget.repository.tasks,
          habits: widget.repository.habits,
          now: now,
        );
        final ratio = blockProgress.total == 0
            ? 1.0
            : (blockProgress.done / blockProgress.total).clamp(0.0, 1.0);

        // Tasks due within 60 minutes for the in-app Notification Quick Action Bar
        final nearDueTasks = widget.repository.tasks
            .where((t) => t.isDueNear(now))
            .take(2)
            .toList();

        return CupertinoPageScaffold(
          backgroundColor: CupertinoDynamicColor.resolve(
            PixelCupertinoTheme.background,
            context,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Block Heading + Live Time Range
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: VoxelBlockCard(
                    accentBorderColor: PixelCupertinoTheme.emeraldXp,
                    glow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PixelSpriteIcon.fromKey(
                              _selectedBlock.iconKey,
                              size: 22,
                              primaryColor: PixelCupertinoTheme.goldIngot,
                              secondaryColor: PixelCupertinoTheme.emeraldXp,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_selectedBlock.name.toUpperCase()} BLOCK',
                                    key: const Key('home_block_heading_text'),
                                    style: PixelCupertinoTheme.largeTitleStyle(
                                      context,
                                    ).copyWith(fontSize: 22),
                                  ),
                                  Text(
                                    _selectedBlock.rangeLabel,
                                    style: PixelCupertinoTheme.pixelBadgeStyle(
                                      color: PixelCupertinoTheme.diamondCyan,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PixelTagChip(
                              label:
                                  '${blockProgress.done}/${blockProgress.total}',
                              color: PixelCupertinoTheme.emeraldXp,
                              glow: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        VoxelSegmentedProgressBar(
                          progress: ratio,
                          segments: 10,
                          height: 10,
                        ),
                        const SizedBox(height: 10),

                        // Block Switcher Pills (Dawn / Day / Dusk / Night)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: TimeBlock.defaults.map((b) {
                            final active = b == _selectedBlock;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: PressableScale(
                                  onTap: () => _selectBlock(b),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? PixelCupertinoTheme.emeraldXp
                                              .withValues(alpha: 0.22)
                                          : CupertinoDynamicColor.resolve(
                                              PixelCupertinoTheme
                                                  .tertiarySlotBackground,
                                              context,
                                            ),
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: active
                                            ? PixelCupertinoTheme.emeraldXp
                                            : CupertinoColors.transparent,
                                        width: 1.5,
                                      ),
                                      boxShadow: active
                                          ? PixelCupertinoTheme.glowShadows(
                                              PixelCupertinoTheme.emeraldXp,
                                              intensity: 0.28,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        PixelSpriteIcon.fromKey(
                                          b.iconKey,
                                          size: 12,
                                          primaryColor: active
                                              ? PixelCupertinoTheme.emeraldXp
                                              : PixelCupertinoTheme.ironIngot,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          b.name.toUpperCase(),
                                          style: PixelCupertinoTheme
                                              .pixelBadgeStyle(
                                            color: active
                                                ? PixelCupertinoTheme.emeraldXp
                                                : CupertinoDynamicColor.resolve(
                                                    PixelCupertinoTheme
                                                        .secondaryLabel,
                                                    context,
                                                  ),
                                            fontSize: 8.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Notification Action Bar when Task Time is Near
                if (nearDueTasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: nearDueTasks.map((TaskItem nearTask) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: VoxelBlockCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            accentBorderColor: PixelCupertinoTheme.diamondCyan,
                            glow: true,
                            child: Row(
                              children: [
                                const PixelSpriteIcon(
                                  type: PixelSpriteType.bell,
                                  size: 16,
                                  primaryColor: PixelCupertinoTheme.diamondCyan,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nearTask.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: PixelCupertinoTheme.subheadStyle(
                                      context,
                                    ).copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoDynamicColor.resolve(
                                        PixelCupertinoTheme.primaryLabel,
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                PressableScale(
                                  onTap: () => widget.repository
                                      .completeTask(nearTask.id),
                                  child: Container(
                                    key: ValueKey<String>(
                                      'notif_done_${nearTask.id}',
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PixelCupertinoTheme.emeraldXp,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'DONE',
                                      style:
                                          PixelCupertinoTheme.pixelBadgeStyle(
                                        color: const Color(0xFF0A1F10),
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // 3. UIPickerView / Drum Picker of Block Tasks & Habits
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: VoxelBlockCard(
                              accentBorderColor: PixelCupertinoTheme.emeraldXp,
                              glow: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const PixelSpriteIcon(
                                    type: PixelSpriteType.crown,
                                    size: 28,
                                    primaryColor: PixelCupertinoTheme.goldIngot,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${_selectedBlock.name} Block Cleared!',
                                    style: PixelCupertinoTheme.headlineStyle(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap the center + Craft Axe button or switch blocks above.',
                                    textAlign: TextAlign.center,
                                    style: PixelCupertinoTheme.subheadStyle(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // Center Drum Selection Highlight Frame
                            IgnorePointer(
                              child: Container(
                                height: 92,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: PixelCupertinoTheme.emeraldXp
                                        .withValues(alpha: 0.55),
                                    width: 1.5,
                                  ),
                                  boxShadow: PixelCupertinoTheme.glowShadows(
                                    PixelCupertinoTheme.emeraldXp,
                                    intensity: 0.18,
                                  ),
                                ),
                              ),
                            ),
                            ListWheelScrollView.useDelegate(
                              key: const Key('home_block_drum_picker'),
                              controller: _wheelController,
                              itemExtent: 88,
                              diameterRatio: 1.65,
                              perspective: 0.003,
                              physics: const FixedExtentScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              onSelectedItemChanged: (idx) {
                                widget.repository.haptics.selectionClick();
                                setState(() {
                                  _focusedIndex = idx;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: entries.length,
                                builder: (context, index) {
                                  if (index < 0 || index >= entries.length) {
                                    return null;
                                  }
                                  final entry = entries[index];
                                  final isFocused = index ==
                                      _focusedIndex.clamp(
                                          0, entries.length - 1);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 5,
                                    ),
                                    child: _DrumSwipeRow(
                                      key: ValueKey<String>(
                                        'drum_${entry.id}',
                                      ),
                                      entry: entry,
                                      isFocused: isFocused,
                                      onSlideRightComplete: () =>
                                          _handleCompleteEntry(entry),
                                      onSlideLeftDelay: () =>
                                          _handleDelayEntry(context, entry),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 92),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrumSwipeRow extends StatefulWidget {
  const _DrumSwipeRow({
    super.key,
    required this.entry,
    required this.isFocused,
    required this.onSlideRightComplete,
    required this.onSlideLeftDelay,
  });

  final BlockEntry entry;
  final bool isFocused;
  final Future<void> Function() onSlideRightComplete;
  final VoidCallback onSlideLeftDelay;

  @override
  State<_DrumSwipeRow> createState() => _DrumSwipeRowState();
}

class _DrumSwipeRowState extends State<_DrumSwipeRow> {
  double _dragDx = 0.0;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final Color accent;
    final Widget leadingIcon;
    final String rightBadge;

    if (entry is TaskEntry) {
      final t = entry.task;
      accent = switch (t.priority) {
        TaskPriority.high => PixelCupertinoTheme.redstoneCrimson,
        TaskPriority.medium => PixelCupertinoTheme.goldIngot,
        TaskPriority.low => PixelCupertinoTheme.ironIngot,
      };
      final sprite = switch (t.priority) {
        TaskPriority.high => PixelSpriteType.redstoneBar,
        TaskPriority.medium => PixelSpriteType.goldBar,
        TaskPriority.low => PixelSpriteType.ironBar,
      };
      leadingIcon = PixelSpriteIcon(
        type: sprite,
        size: 18,
        primaryColor: accent,
        secondaryColor: CupertinoColors.white,
      );
      rightBadge =
          t.shortCornerTimestamp.isNotEmpty ? t.shortCornerTimestamp : '+15xp';
    } else {
      final h = (entry as HabitEntry);
      accent = Color(h.habit.colorArgb);
      leadingIcon = PixelSpriteIcon.fromKey(
        h.habit.iconKey,
        size: 18,
        primaryColor: accent,
      );
      rightBadge = '${h.streak}d';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragDx = (_dragDx + (details.primaryDelta ?? 0.0)).clamp(-120, 140);
        });
      },
      onHorizontalDragEnd: (details) async {
        final dx = _dragDx;
        setState(() {
          _dragDx = 0.0;
        });
        if (dx >= 56) {
          await widget.onSlideRightComplete();
        } else if (dx <= -56) {
          widget.onSlideLeftDelay();
        }
      },
      child: Transform.translate(
        offset: Offset(_dragDx, 0),
        child: VoxelBlockCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          accentBorderColor: widget.isFocused ? accent : null,
          glow: widget.isFocused,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                ),
                child: leadingIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PixelCupertinoTheme.bodyStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '← Delay   ·   Complete →',
                      style: PixelCupertinoTheme.pixelBadgeStyle(
                        color: CupertinoDynamicColor.resolve(
                          PixelCupertinoTheme.secondaryLabel,
                          context,
                        ),
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PixelTagChip(
                label: rightBadge,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
