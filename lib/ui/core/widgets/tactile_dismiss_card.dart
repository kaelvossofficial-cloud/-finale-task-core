import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

import '../../../data/services/haptic_service.dart';
import '../../../domain/models/task_item.dart';
import '../theme/pixel_cupertino_theme.dart';
import 'pixel_art_painters.dart';

/// Bi-directional interactive swipe card:
/// - **Swipe Right**: Mark task complete (`HapticFeedback.mediumImpact()` + GPU-composited slide-out + `+15xp`)
/// - **Swipe Left**: Edit reminder / alarm (`HapticFeedback.lightImpact()` + snaps back and opens reminder editor)
/// - **Three-dots menu (`...`)**: Quick options (Edit Reminder, Delay +1h, Delete)
/// - **Minimalist pixel labels**: Bar sprite only (no `MEDIUM · GOLD`), `+10xp`, `Nov 11 14:30` in corner, no `>>>`.
class TactileDismissTaskCard extends StatefulWidget {
  const TactileDismissTaskCard({
    super.key,
    required this.task,
    required this.hapticService,
    required this.onCompleted,
    this.onEditReminder,
    this.onDelayTask,
    this.onDelete,
  });

  final TaskItem task;
  final HapticService hapticService;
  final Future<void> Function(TaskItem task) onCompleted;
  final VoidCallback? onEditReminder;
  final void Function(Duration delay)? onDelayTask;
  final VoidCallback? onDelete;

  @override
  State<TactileDismissTaskCard> createState() => _TactileDismissTaskCardState();
}

class _TactileDismissTaskCardState extends State<TactileDismissTaskCard>
    with SingleTickerProviderStateMixin {
  static const double _completionRatioThreshold = 0.28;
  static const double _editReminderRatioThreshold = -0.24;
  static const SpringDescription _iosSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 25.0,
  );

  late final AnimationController _controller;
  double _cardWidth = 340.0;
  bool _thresholdReached = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0.0,
      lowerBound: -0.65,
      upperBound: 1.25,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.task.isCompleted || _isCompleting) return;
    final deltaRatio = (details.primaryDelta ?? 0.0) / _cardWidth;
    final minBound = widget.onEditReminder != null ? -0.50 : 0.0;
    final nextValue = (_controller.value + deltaRatio).clamp(minBound, 1.0);
    _controller.value = nextValue;

    final crossedRight = nextValue >= _completionRatioThreshold;
    final crossedLeft = nextValue <= _editReminderRatioThreshold;

    if (!_thresholdReached && (crossedRight || crossedLeft)) {
      _thresholdReached = true;
      widget.hapticService.mediumImpact();
    } else if (_thresholdReached && !crossedRight && !crossedLeft) {
      _thresholdReached = false;
      widget.hapticService.lightImpact();
    }
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    if (widget.task.isCompleted || _isCompleting) return;
    final velocityRatio = (details.primaryVelocity ?? 0.0) / _cardWidth;

    if (_controller.value >= _completionRatioThreshold || velocityRatio > 1.8) {
      if (!_thresholdReached) {
        _thresholdReached = true;
        await widget.hapticService.mediumImpact();
      }
      await _triggerSlideOutCompletion();
      return;
    }

    final shouldOpenReminder = widget.onEditReminder != null &&
        (_controller.value <= _editReminderRatioThreshold ||
            velocityRatio < -1.8);

    _thresholdReached = false;
    final spring = SpringSimulation(
      _iosSpring,
      _controller.value,
      0.0,
      velocityRatio,
    );
    _controller.animateWith(spring);

    if (shouldOpenReminder) {
      widget.onEditReminder?.call();
    }
  }

  Future<void> _triggerSlideOutCompletion() async {
    if (_isCompleting) return;
    setState(() {
      _isCompleting = true;
    });
    await _controller.animateTo(
      1.08,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    if (mounted) {
      await widget.onCompleted(widget.task);
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return PixelCupertinoTheme.redstoneCrimson;
      case TaskPriority.medium:
        return PixelCupertinoTheme.goldIngot;
      case TaskPriority.low:
        return PixelCupertinoTheme.ironIngot;
    }
  }

  PixelSpriteType _priorityBarSprite(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return PixelSpriteType.redstoneBar;
      case TaskPriority.medium:
        return PixelSpriteType.goldBar;
      case TaskPriority.low:
        return PixelSpriteType.ironBar;
    }
  }

  void _showThreeDotsMenu(BuildContext context) {
    widget.hapticService.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => CupertinoActionSheet(
        title: Text(widget.task.title),
        actions: [
          if (!widget.task.isCompleted && widget.onEditReminder != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                widget.onEditReminder?.call();
              },
              child: const Text('Set Reminder / Alarm'),
            ),
          if (!widget.task.isCompleted && widget.onDelayTask != null) ...[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                widget.onDelayTask?.call(const Duration(minutes: 15));
              },
              child: const Text('Delay +15m'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                widget.onDelayTask?.call(const Duration(hours: 1));
              },
              child: const Text('Delay +1h'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                widget.onDelayTask?.call(const Duration(days: 1));
              },
              child: const Text('Delay Tomorrow'),
            ),
          ],
          if (widget.onDelete != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                widget.onDelete?.call();
              },
              child: const Text('Delete Quest'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetCtx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final pColor = _priorityColor(task.priority);
    final barSprite = _priorityBarSprite(task.priority);
    final isOnTimeEligible =
        task.dueDate == null || !DateTime.now().isAfter(task.dueDate!);
    final potentialXp = isOnTimeEligible ? 15 : 10;
    final cornerTime = task.shortCornerTimestamp;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
          _cardWidth = constraints.maxWidth;
        }

        return RepaintBoundary(
          child: GestureDetector(
            key: ValueKey<String>('tactile_task_${task.id}'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate:
                task.isCompleted ? null : _onHorizontalDragUpdate,
            onHorizontalDragEnd: task.isCompleted ? null : _onHorizontalDragEnd,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Underlying Bi-Directional Action Track (Right = Mine +XP, Left = Reminder/Alarm)
                if (!task.isCompleted)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final val = _controller.value;
                        final isSwipingLeft = val < -0.02;
                        final reachedRight = val >= _completionRatioThreshold;
                        final reachedLeft = val <= _editReminderRatioThreshold;

                        final activeColor = isSwipingLeft
                            ? (reachedLeft
                                ? PixelCupertinoTheme.diamondCyan
                                : CupertinoDynamicColor.resolve(
                                    PixelCupertinoTheme.tertiarySlotBackground,
                                    context,
                                  ))
                            : (reachedRight
                                ? PixelCupertinoTheme.emeraldDark
                                : CupertinoDynamicColor.resolve(
                                    PixelCupertinoTheme.tertiarySlotBackground,
                                    context,
                                  ));

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: (reachedRight || reachedLeft)
                                ? PixelCupertinoTheme.glowShadows(
                                    isSwipingLeft
                                        ? PixelCupertinoTheme.diamondCyan
                                        : PixelCupertinoTheme.emeraldXp,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: isSwipingLeft
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              PixelSpriteIcon(
                                type: isSwipingLeft
                                    ? PixelSpriteType.alarm
                                    : PixelSpriteType.xpOrb,
                                size: 18,
                                primaryColor: CupertinoColors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isSwipingLeft
                                    ? 'REMINDER'
                                    : '+${potentialXp}xp',
                                style: PixelCupertinoTheme.pixelBadgeStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // GPU-Composited Foreground Task Voxel Card
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final offsetPx = _controller.value * _cardWidth;
                    final opacity = (1.0 - (_controller.value.abs() * 0.55))
                        .clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(offsetPx, 0),
                      child: Opacity(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: VoxelBlockCard(
                    accentBorderColor: task.isCompleted
                        ? PixelCupertinoTheme.emeraldXp.withValues(alpha: 0.45)
                        : null,
                    glow: task.isCompleted,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Voxel Ore Slot (Bar sprite only — no text bloat)
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: CupertinoDynamicColor.resolve(
                              PixelCupertinoTheme.tertiarySlotBackground,
                              context,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: task.isCompleted
                                  ? PixelCupertinoTheme.emeraldXp
                                  : pColor.withValues(alpha: 0.75),
                              width: 1.5,
                            ),
                          ),
                          child: PixelSpriteIcon(
                            type: task.isCompleted
                                ? PixelSpriteType.checkmark
                                : barSprite,
                            size: 16,
                            primaryColor: task.isCompleted
                                ? PixelCupertinoTheme.emeraldXp
                                : pColor,
                            secondaryColor: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Task Title + Compact Corner Timestamp & +xp Chip
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style:
                                          PixelCupertinoTheme.bodyStyle(context)
                                              .copyWith(
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.isCompleted
                                            ? CupertinoDynamicColor.resolve(
                                                PixelCupertinoTheme
                                                    .secondaryLabel,
                                                context,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (cornerTime.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (task.isAlarmEnabled) ...[
                                          const PixelSpriteIcon(
                                            type: PixelSpriteType.alarm,
                                            size: 11,
                                            primaryColor:
                                                PixelCupertinoTheme.diamondCyan,
                                          ),
                                          const SizedBox(width: 3),
                                        ],
                                        Text(
                                          cornerTime,
                                          style: PixelCupertinoTheme
                                              .pixelBadgeStyle(
                                            color:
                                                CupertinoDynamicColor.resolve(
                                              PixelCupertinoTheme
                                                  .secondaryLabel,
                                              context,
                                            ),
                                            fontSize: 9.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Just the Ore Bar Icon + concise +xxp chip
                                  PixelSpriteIcon(
                                    type: barSprite,
                                    size: 13,
                                    primaryColor: pColor,
                                    secondaryColor: CupertinoColors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  PixelTagChip(
                                    label:
                                        task.isCompleted && task.awardedXp > 0
                                            ? '+${task.awardedXp}xp'
                                            : '+${potentialXp}xp',
                                    color: PixelCupertinoTheme.emeraldXp,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Three-Dots (`...`) Action Menu Button
                        CupertinoButton(
                          padding: const EdgeInsets.only(left: 8),
                          minimumSize: const Size(28, 28),
                          onPressed: () => _showThreeDotsMenu(context),
                          child: PixelSpriteIcon(
                            type: PixelSpriteType.dots,
                            size: 15,
                            primaryColor: CupertinoDynamicColor.resolve(
                              PixelCupertinoTheme.secondaryLabel,
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
