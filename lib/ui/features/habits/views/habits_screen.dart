import 'package:flutter/cupertino.dart';

import '../../../../domain/models/habit_item.dart';
import '../../../../domain/models/time_block.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../view_models/habits_view_model.dart';
import 'habit_creator_sheet.dart';
import 'habit_detail_sheet.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({
    super.key,
    required this.viewModel,
  });

  final HabitsViewModel viewModel;

  void _openCreator(BuildContext context, {HabitItem? existingHabit}) {
    viewModel.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => HabitCreatorSheet(
        hapticService: viewModel.haptics,
        existingHabit: existingHabit,
        onUpdateHabit: viewModel.updateHabit,
        onCreateHabit: viewModel.addHabit,
      ),
    );
  }

  void _openDetailPopup(BuildContext context, HabitItem habit) {
    viewModel.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => HabitDetailSheet(
        habitId: habit.id,
        viewModel: viewModel,
        onEditHabit: () => _openCreator(context, existingHabit: habit),
      ),
    );
  }

  void _showHabitThreeDotsMenu(BuildContext context, HabitItem habit) {
    viewModel.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => CupertinoActionSheet(
        title: Text(habit.title),
        message: Text('Smart Nudge @ ${habit.smartNudgeLabel}'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              _openDetailPopup(context, habit);
            },
            child: const Text('Calendar, Story Note & Details'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              _openCreator(context, existingHabit: habit);
            },
            child: const Text('Customize Icon, Color & Reminder'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              viewModel.deleteHabit(habit.id);
            },
            child: const Text('Delete Habit'),
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
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final habits = viewModel.activeHabits;
        final ratio = viewModel.todayCompletionRatio;
        final percent = viewModel.todayCompletionPercent;
        final isGrid = viewModel.isWaterfallGrid;

        return CupertinoPageScaffold(
          backgroundColor: CupertinoDynamicColor.resolve(
            PixelCupertinoTheme.background,
            context,
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Habit Forge'),
                backgroundColor: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.translucentBarBackground,
                  context,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // List vs Waterfall Grid Toggle
                    PressableScale(
                      onTap: viewModel.toggleLayoutMode,
                      child: Container(
                        key: const Key('habit_layout_toggle_button'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoDynamicColor.resolve(
                            PixelCupertinoTheme.tertiarySlotBackground,
                            context,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isGrid ? 'LIST' : 'GRID',
                          style: PixelCupertinoTheme.pixelBadgeStyle(
                            color: PixelCupertinoTheme.diamondCyan,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PressableScale(
                      onTap: () => _openCreator(context),
                      child: Container(
                        key: const Key('nav_add_habit_button'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: PixelCupertinoTheme.emeraldXp,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PixelSpriteIcon(
                              type: PixelSpriteType.craftAxe,
                              size: 13,
                              primaryColor: Color(0xFF0A1F10),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Habit',
                              style: TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.41,
                                color: Color(0xFF0A1F10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pull-down refresh
              CupertinoSliverRefreshControl(
                onRefresh: viewModel.refresh,
              ),

              // Daily Completion Progress Bar Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: VoxelBlockCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DAILY RITUALS',
                              style: PixelCupertinoTheme.pixelBadgeStyle(
                                color: PixelCupertinoTheme.diamondCyan,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '$percent% (${viewModel.completedTodayCount}/${viewModel.totalActiveCount})',
                              key: const Key('habit_progress_percentage_text'),
                              style: PixelCupertinoTheme.headlineStyle(context)
                                  .copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        VoxelSegmentedProgressBar(
                          progress: ratio,
                          segments: 10,
                          height: 12,
                          activeColor: PixelCupertinoTheme.emeraldXp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (habits.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: VoxelBlockCard(
                      child: Text(
                        'No active habits yet. Tap "+ Habit" to forge your first daily block.',
                        style: PixelCupertinoTheme.subheadStyle(context),
                      ),
                    ),
                  ),
                )
              else if (isGrid)
                // Waterfall 2-Column Masonry Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildWaterfallGrid(context, habits),
                  ),
                )
              else
                // Grouped by Time Blocks (Dawn, Day, Dusk, Night)
                ..._buildBlockGroupedSlivers(context, habits),

              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterfallGrid(BuildContext context, List<HabitItem> habits) {
    final leftColumn = <HabitItem>[];
    final rightColumn = <HabitItem>[];
    for (var i = 0; i < habits.length; i++) {
      if (i.isEven) {
        leftColumn.add(habits[i]);
      } else {
        rightColumn.add(habits[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn.map((h) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HabitWaterfallCard(
                  habit: h,
                  viewModel: viewModel,
                  onTap: () => _openDetailPopup(context, h),
                  onMenu: () => _showHabitThreeDotsMenu(context, h),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: rightColumn.map((h) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HabitWaterfallCard(
                  habit: h,
                  viewModel: viewModel,
                  onTap: () => _openDetailPopup(context, h),
                  onMenu: () => _showHabitThreeDotsMenu(context, h),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBlockGroupedSlivers(
    BuildContext context,
    List<HabitItem> habits,
  ) {
    final slivers = <Widget>[];
    for (final block in TimeBlock.defaults) {
      final blockHabits =
          habits.where((h) => (h.blockId ?? 'dawn') == block.id).toList();
      if (blockHabits.isEmpty) continue;

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                PixelSpriteIcon.fromKey(
                  block.iconKey,
                  size: 15,
                  primaryColor: PixelCupertinoTheme.goldIngot,
                ),
                const SizedBox(width: 6),
                Text(
                  '${block.name} Block',
                  style: PixelCupertinoTheme.headlineStyle(context)
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  block.rangeLabel,
                  style: PixelCupertinoTheme.pixelBadgeStyle(
                    color: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryLabel,
                      context,
                    ),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: blockHabits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final habit = blockHabits[index];
              return _HabitVoxelTile(
                key: ValueKey<String>(habit.id),
                habit: habit,
                viewModel: viewModel,
                onTapDetail: () => _openDetailPopup(context, habit),
                onTapThreeDots: () => _showHabitThreeDotsMenu(context, habit),
              );
            },
          ),
        ),
      );
    }
    return slivers;
  }
}

class _HabitWaterfallCard extends StatelessWidget {
  const _HabitWaterfallCard({
    required this.habit,
    required this.viewModel,
    required this.onTap,
    required this.onMenu,
  });

  final HabitItem habit;
  final HabitsViewModel viewModel;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final done = viewModel.isCompletedToday(habit);
    final streak = viewModel.streakFor(habit);
    final color = Color(habit.colorArgb);

    return PressableScale(
      onTap: onTap,
      child: VoxelBlockCard(
        accentBorderColor: done ? color : color.withValues(alpha: 0.45),
        glow: done,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PixelSpriteIcon.fromKey(
                    habit.iconKey,
                    size: 18,
                    primaryColor: color,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 24),
                  onPressed: onMenu,
                  child: PixelSpriteIcon(
                    type: PixelSpriteType.dots,
                    size: 14,
                    primaryColor: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              habit.title,
              style: PixelCupertinoTheme.bodyStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (habit.stories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '"${habit.stories.first.note}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PixelCupertinoTheme.subheadStyle(context),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PixelTagChip(
                  label: '${streak}d',
                  color: color,
                  icon: PixelSpriteType.flame,
                ),
                CupertinoSwitch(
                  value: done,
                  activeTrackColor: color,
                  onChanged: (_) => viewModel.toggleToday(habit.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitVoxelTile extends StatelessWidget {
  const _HabitVoxelTile({
    super.key,
    required this.habit,
    required this.viewModel,
    required this.onTapDetail,
    required this.onTapThreeDots,
  });

  final HabitItem habit;
  final HabitsViewModel viewModel;
  final VoidCallback onTapDetail;
  final VoidCallback onTapThreeDots;

  @override
  Widget build(BuildContext context) {
    final completedToday = viewModel.isCompletedToday(habit);
    final streak = viewModel.streakFor(habit);
    final today = viewModel.today;
    final color = Color(habit.colorArgb);

    return PressableScale(
      onTap: onTapDetail,
      child: VoxelBlockCard(
        accentBorderColor:
            completedToday ? color : color.withValues(alpha: 0.38),
        glow: completedToday,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Custom Pixel Icon Slot
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.65),
                      width: 1.5,
                    ),
                  ),
                  child: PixelSpriteIcon.fromKey(
                    habit.iconKey,
                    size: 17,
                    primaryColor: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: PixelCupertinoTheme.bodyStyle(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          PixelTagChip(
                            label: '${streak}d',
                            key: ValueKey<String>('habit_streak_${habit.id}'),
                            color: color,
                            icon: PixelSpriteType.flame,
                          ),
                          const SizedBox(width: 6),
                          PixelTagChip(
                            label: habit.smartNudgeLabel,
                            color: PixelCupertinoTheme.diamondCyan,
                            icon: habit.isAlarmEnabled
                                ? PixelSpriteType.alarm
                                : PixelSpriteType.bell,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Glowy Daily Toggle Switch
                CupertinoSwitch(
                  key: ValueKey<String>('habit_toggle_${habit.id}'),
                  value: completedToday,
                  activeTrackColor: color,
                  onChanged: (_) => viewModel.toggleToday(habit.id),
                ),
                // Three-dots (`...`) Menu
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 4),
                  minimumSize: const Size(26, 26),
                  onPressed: onTapThreeDots,
                  child: PixelSpriteIcon(
                    type: PixelSpriteType.dots,
                    size: 14,
                    primaryColor: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 7-Day Voxel Hotbar Frequency Slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List<Widget>.generate(7, (idx) {
                final dayOffset = 6 - idx;
                final date = today.subtract(Duration(days: dayOffset));
                final done = habit.isCompletedOn(date);
                const weekdayLabels = <String>[
                  'M',
                  'T',
                  'W',
                  'T',
                  'F',
                  'S',
                  'S',
                ];
                final label = weekdayLabels[date.weekday - 1];
                final isTodaySlot = dayOffset == 0;

                return PressableScale(
                  onTap: () => viewModel.toggleDate(habit.id, date),
                  child: Container(
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: done
                          ? color.withValues(alpha: 0.24)
                          : CupertinoDynamicColor.resolve(
                              PixelCupertinoTheme.tertiarySlotBackground,
                              context,
                            ),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: done
                            ? color
                            : (isTodaySlot
                                ? PixelCupertinoTheme.diamondCyan
                                : CupertinoColors.transparent),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isTodaySlot ? 'NOW' : label,
                          style: PixelCupertinoTheme.pixelBadgeStyle(
                            color: done
                                ? color
                                : CupertinoDynamicColor.resolve(
                                    PixelCupertinoTheme.secondaryLabel,
                                    context,
                                  ),
                            fontSize: 8.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          done
                              ? CupertinoIcons.checkmark_alt
                              : CupertinoIcons.square,
                          size: 12,
                          color: done
                              ? color
                              : CupertinoDynamicColor.resolve(
                                  PixelCupertinoTheme.secondaryLabel,
                                  context,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
