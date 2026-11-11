import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

import '../../../data/services/haptic_service.dart';
import '../../../domain/models/task_item.dart';
import '../theme/pixel_cupertino_theme.dart';
import 'pixel_art_painters.dart';

/// Interactive swipe/slide gesture card that replaces static checkboxes.
///
/// - Smooth horizontal drag using `SpringSimulation(SpringDescription(mass: 1, stiffness: 300, damping: 25))`
/// - Triggers immediate `HapticFeedback.mediumImpact` upon crossing the completion threshold
/// - Animates the card out using GPU-composited `Transform.translate` and `Opacity`
class TactileDismissTaskCard extends StatefulWidget {
  const TactileDismissTaskCard({
    super.key,
    required this.task,
    required this.hapticService,
    required this.onCompleted,
    this.onDelete,
  });

  final TaskItem task;
  final HapticService hapticService;
  final Future<void> Function(TaskItem task) onCompleted;
  final VoidCallback? onDelete;

  @override
  State<TactileDismissTaskCard> createState() => _TactileDismissTaskCardState();
}

class _TactileDismissTaskCardState extends State<TactileDismissTaskCard>
    with SingleTickerProviderStateMixin {
  static const double _completionRatioThreshold = 0.32;
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
      lowerBound: 0.0,
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
    final nextValue = (_controller.value + deltaRatio).clamp(0.0, 1.0);
    _controller.value = nextValue;

    if (!_thresholdReached && nextValue >= _completionRatioThreshold) {
      _thresholdReached = true;
      widget.hapticService.mediumImpact();
    } else if (_thresholdReached && nextValue < _completionRatioThreshold) {
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
    } else {
      _thresholdReached = false;
      final spring = SpringSimulation(
        _iosSpring,
        _controller.value,
        0.0,
        velocityRatio,
      );
      _controller.animateWith(spring);
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

  String _formatDueTimestamp(DateTime dueDate) {
    final now = DateTime.now();
    final isToday = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
    final hh = dueDate.hour.toString().padLeft(2, '0');
    final mm = dueDate.minute.toString().padLeft(2, '0');
    if (isToday) {
      return 'Due Today $hh:$mm';
    }
    final month = dueDate.month.toString().padLeft(2, '0');
    final day = dueDate.day.toString().padLeft(2, '0');
    return 'Due $month/$day $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final pColor = _priorityColor(task.priority);
    final isOnTimeEligible =
        task.dueDate == null || !DateTime.now().isAfter(task.dueDate!);
    final potentialXp = isOnTimeEligible ? 15 : 10;

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
              alignment: Alignment.centerLeft,
              children: [
                // Underlying Emerald Mining Action Track
                if (!task.isCompleted)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final reached =
                            _controller.value >= _completionRatioThreshold;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: reached
                                ? PixelCupertinoTheme.emeraldDark
                                : CupertinoDynamicColor.resolve(
                                    PixelCupertinoTheme.tertiarySlotBackground,
                                    context,
                                  ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: reached
                                  ? PixelCupertinoTheme.emeraldXp
                                  : CupertinoColors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              PixelSpriteIcon(
                                type: reached
                                    ? PixelSpriteType.xpOrb
                                    : PixelSpriteType.pickaxe,
                                size: 18,
                                primaryColor: reached
                                    ? CupertinoColors.white
                                    : PixelCupertinoTheme.emeraldXp,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                reached
                                    ? 'RELEASE TO CLAIM +$potentialXp XP!'
                                    : 'SLIDE RIGHT TO MINE (+$potentialXp XP)',
                                style: PixelCupertinoTheme.pixelBadgeStyle(
                                  color: reached
                                      ? CupertinoColors.white
                                      : PixelCupertinoTheme.emeraldXp,
                                  fontSize: 11.5,
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
                    final opacity =
                        (1.0 - (_controller.value * 0.65)).clamp(0.0, 1.0);
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Voxel Status Slot (Pickaxe / Emerald Check)
                        Container(
                          width: 36,
                          height: 36,
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
                                : PixelSpriteType.pickaxe,
                            size: 16,
                            primaryColor: task.isCompleted
                                ? PixelCupertinoTheme.emeraldXp
                                : pColor,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Task Title + Metadata Row
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: PixelCupertinoTheme.bodyStyle(context)
                                    .copyWith(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? CupertinoDynamicColor.resolve(
                                          PixelCupertinoTheme.secondaryLabel,
                                          context,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Priority / Ore Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pColor.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: pColor.withValues(alpha: 0.55),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${task.priority.label.toUpperCase()} · ${task.priority.craftTag}',
                                      style:
                                          PixelCupertinoTheme.pixelBadgeStyle(
                                        color: pColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  if (task.dueDate != null)
                                    Text(
                                      _formatDueTimestamp(task.dueDate!),
                                      style: PixelCupertinoTheme.subheadStyle(
                                        context,
                                      ),
                                    ),
                                  if (task.isCompleted && task.awardedXp > 0)
                                    Text(
                                      '+${task.awardedXp} XP${task.completedOnTime ? ' (ON-TIME)' : ''}',
                                      style:
                                          PixelCupertinoTheme.pixelBadgeStyle(
                                        color: PixelCupertinoTheme.emeraldXp,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Swipe Hint or Delete Button
                        if (!task.isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '>>>',
                                  style: PixelCupertinoTheme.pixelBadgeStyle(
                                    color: CupertinoDynamicColor.resolve(
                                      PixelCupertinoTheme.secondaryLabel,
                                      context,
                                    ),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (widget.onDelete != null)
                          CupertinoButton(
                            padding: const EdgeInsets.all(4),
                            minSize: 28,
                            onPressed: widget.onDelete,
                            child: const Icon(
                              CupertinoIcons.trash,
                              size: 17,
                              color: PixelCupertinoTheme.redstoneCrimson,
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
