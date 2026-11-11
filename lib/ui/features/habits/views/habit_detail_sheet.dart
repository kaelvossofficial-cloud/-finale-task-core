import 'package:flutter/cupertino.dart';

import '../../../../domain/models/habit_item.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../view_models/habits_view_model.dart';

/// Popup modal opened when clicking a habit:
/// - Displays custom icon, color, streak, and Smart Nudge time
/// - Monthly Calendar Heatmap showing which days the habit was fulfilled
/// - Optional Daily Story / Note composer + chronological story log
class HabitDetailSheet extends StatefulWidget {
  const HabitDetailSheet({
    super.key,
    required this.habitId,
    required this.viewModel,
    required this.onEditHabit,
  });

  final String habitId;
  final HabitsViewModel viewModel;
  final VoidCallback onEditHabit;

  @override
  State<HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends State<HabitDetailSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitStoryNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await widget.viewModel.addStoryNote(widget.habitId, text);
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final match = widget.viewModel.habits
            .where((h) => h.id == widget.habitId)
            .toList();
        if (match.isEmpty) {
          return const SizedBox.shrink();
        }
        final habit = match.first;
        final color = Color(habit.colorArgb);
        final streak = widget.viewModel.streakFor(habit);
        final today = widget.viewModel.today;
        final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

        return FrostedSheetContainer(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: PixelSpriteIcon.fromKey(
                        habit.iconKey,
                        size: 20,
                        primaryColor: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: PixelCupertinoTheme.headlineStyle(context),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              PixelTagChip(
                                label: '${streak}d STREAK',
                                color: color,
                                icon: PixelSpriteType.flame,
                              ),
                              const SizedBox(width: 6),
                              PixelTagChip(
                                label: 'NUDGE ${habit.smartNudgeLabel}',
                                color: PixelCupertinoTheme.diamondCyan,
                                icon: PixelSpriteType.bell,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 30,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onEditHabit();
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Monthly Calendar Heatmap
                Text(
                  'MONTHLY HABIT CALENDAR',
                  style: PixelCupertinoTheme.pixelBadgeStyle(
                    color: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryLabel,
                      context,
                    ),
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List<Widget>.generate(daysInMonth, (index) {
                    final dayNum = index + 1;
                    final date = DateTime(today.year, today.month, dayNum);
                    final done = habit.isCompletedOn(date);
                    final isToday = dayNum == today.day;

                    return PressableScale(
                      onTap: () => widget.viewModel.toggleDate(habit.id, date),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: done
                              ? color.withValues(alpha: 0.28)
                              : CupertinoDynamicColor.resolve(
                                  PixelCupertinoTheme.tertiarySlotBackground,
                                  context,
                                ),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: done
                                ? color
                                : (isToday
                                    ? PixelCupertinoTheme.diamondCyan
                                    : CupertinoColors.transparent),
                            width: 1.5,
                          ),
                          boxShadow: done
                              ? PixelCupertinoTheme.glowShadows(
                                  color,
                                  intensity: 0.25,
                                )
                              : null,
                        ),
                        child: Text(
                          '$dayNum',
                          style: PixelCupertinoTheme.pixelBadgeStyle(
                            color: done
                                ? color
                                : CupertinoDynamicColor.resolve(
                                    PixelCupertinoTheme.secondaryLabel,
                                    context,
                                  ),
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Optional Daily Story Note Input
                Text(
                  'DAILY STORY NOTE (OPTIONAL)',
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
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        key: const Key('habit_story_note_input'),
                        controller: _noteController,
                        placeholder: 'Write today\'s story on fulfilling...',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        style: PixelCupertinoTheme.bodyStyle(context),
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            PixelCupertinoTheme.secondaryGroupedBackground,
                            context,
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        onSubmitted: (_) => _submitStoryNote(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PressableScale(
                      onTap: _submitStoryNote,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          'LOG',
                          style: PixelCupertinoTheme.pixelBadgeStyle(
                            color: const Color(0xFF0A1F10),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (habit.stories.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'STORY LOGS',
                    style: PixelCupertinoTheme.pixelBadgeStyle(
                      color: color,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...habit.stories.take(5).map((story) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: VoxelBlockCard(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PixelTagChip(
                              label: story.dateKey,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                story.note,
                                style: PixelCupertinoTheme.subheadStyle(
                                  context,
                                ).copyWith(
                                  color: CupertinoDynamicColor.resolve(
                                    PixelCupertinoTheme.primaryLabel,
                                    context,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
