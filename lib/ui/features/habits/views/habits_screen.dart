import 'package:flutter/cupertino.dart';

import '../../../../domain/models/habit_item.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../view_models/habits_view_model.dart';
import 'habit_creator_sheet.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({
    super.key,
    required this.viewModel,
  });

  final HabitsViewModel viewModel;

  void _openCreator(BuildContext context) {
    viewModel.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => HabitCreatorSheet(
        hapticService: viewModel.haptics,
        onCreateHabit: viewModel.addHabit,
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
                trailing: PressableScale(
                  onTap: () => _openCreator(context),
                  child: Container(
                    key: const Key('nav_add_habit_button'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: PixelCupertinoTheme.emeraldXp,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.add,
                          size: 16,
                          color: Color(0xFF0A1F10),
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
              ),

              // Daily Completion Progress Bar Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: VoxelBlockCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TODAY'S RITUAL PROGRESS",
                              style: PixelCupertinoTheme.pixelBadgeStyle(
                                color: PixelCupertinoTheme.diamondCyan,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '$percent% (${viewModel.completedTodayCount}/${viewModel.totalActiveCount})',
                              key: const Key('habit_progress_percentage_text'),
                              style: PixelCupertinoTheme.headlineStyle(context)
                                  .copyWith(fontSize: 17),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        VoxelSegmentedProgressBar(
                          progress: ratio,
                          segments: 10,
                          height: 14,
                          activeColor: PixelCupertinoTheme.emeraldXp,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completed Habits / Total Active Habits · Consecutive day streaks include grace period protection.',
                          style: PixelCupertinoTheme.subheadStyle(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Habit List
              if (habits.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: VoxelBlockCard(
                      child: Text(
                        'No active habits yet. Tap "+ Habit" to forge your first daily ritual.',
                        style: PixelCupertinoTheme.subheadStyle(context),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return _HabitVoxelTile(
                        key: ValueKey<String>(habit.id),
                        habit: habit,
                        viewModel: viewModel,
                      );
                    },
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HabitVoxelTile extends StatelessWidget {
  const _HabitVoxelTile({
    super.key,
    required this.habit,
    required this.viewModel,
  });

  final HabitItem habit;
  final HabitsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final completedToday = viewModel.isCompletedToday(habit);
    final streak = viewModel.streakFor(habit);
    final today = viewModel.today;

    return VoxelBlockCard(
      accentBorderColor: completedToday ? PixelCupertinoTheme.emeraldXp : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Daily Frequency Toggle Switch
              CupertinoSwitch(
                key: ValueKey<String>('habit_toggle_${habit.id}'),
                value: completedToday,
                activeTrackColor: PixelCupertinoTheme.emeraldXp,
                onChanged: (_) => viewModel.toggleToday(habit.id),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      'Grace Period: ${habit.gracePeriodDays}d · Daily Toggle',
                      style: PixelCupertinoTheme.subheadStyle(context),
                    ),
                  ],
                ),
              ),
              // Streak Flame Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: streak > 0
                      ? PixelCupertinoTheme.goldIngot.withValues(alpha: 0.16)
                      : CupertinoDynamicColor.resolve(
                          PixelCupertinoTheme.tertiarySlotBackground,
                          context,
                        ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: streak > 0
                        ? PixelCupertinoTheme.goldIngot.withValues(alpha: 0.65)
                        : CupertinoColors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PixelSpriteIcon(
                      type: PixelSpriteType.flame,
                      size: 15,
                      primaryColor: streak > 0
                          ? PixelCupertinoTheme.redstoneCrimson
                          : PixelCupertinoTheme.ironIngot,
                      secondaryColor: streak > 0
                          ? PixelCupertinoTheme.goldIngot
                          : PixelCupertinoTheme.ironIngot,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${streak}d',
                      key: ValueKey<String>('habit_streak_${habit.id}'),
                      style: PixelCupertinoTheme.pixelBadgeStyle(
                        color: streak > 0
                            ? PixelCupertinoTheme.goldIngot
                            : CupertinoDynamicColor.resolve(
                                PixelCupertinoTheme.secondaryLabel,
                                context,
                              ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7-Day Voxel Hotbar Frequency Slots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(7, (idx) {
              final dayOffset = 6 - idx;
              final date = today.subtract(Duration(days: dayOffset));
              final done = habit.isCompletedOn(date);
              final weekdayLabels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final label = weekdayLabels[date.weekday - 1];
              final isTodaySlot = dayOffset == 0;

              return PressableScale(
                onTap: () => viewModel.toggleDate(habit.id, date),
                child: Container(
                  width: 38,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: done
                        ? PixelCupertinoTheme.emeraldXp.withValues(alpha: 0.22)
                        : CupertinoDynamicColor.resolve(
                            PixelCupertinoTheme.tertiarySlotBackground,
                            context,
                          ),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: done
                          ? PixelCupertinoTheme.emeraldXp
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
                              ? PixelCupertinoTheme.emeraldXp
                              : CupertinoDynamicColor.resolve(
                                  PixelCupertinoTheme.secondaryLabel,
                                  context,
                                ),
                          fontSize: 9.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Icon(
                        done
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.square,
                        size: 13,
                        color: done
                            ? PixelCupertinoTheme.emeraldXp
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
    );
  }
}
