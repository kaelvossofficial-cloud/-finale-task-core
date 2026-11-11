import 'package:flutter/cupertino.dart';

import '../../../../domain/models/task_item.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../core/widgets/tactile_dismiss_card.dart';
import '../view_models/tasks_view_model.dart';
import 'quick_task_creator_sheet.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.viewModel,
  });

  final TasksViewModel viewModel;

  void _openQuickTaskCreator(BuildContext context, {TaskItem? existingTask}) {
    viewModel.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) => QuickTaskCreatorSheet(
        hapticService: viewModel.haptics,
        existingTask: existingTask,
        onUpdateTask: viewModel.updateTask,
        onCreateTask: ({
          required String title,
          DateTime? dueDate,
          required TaskPriority priority,
          DateTime? reminderAt,
          bool isAlarmEnabled = false,
          String? blockId,
        }) {
          return viewModel.addTask(
            title: title,
            dueDate: dueDate,
            priority: priority,
            reminderAt: reminderAt,
            isAlarmEnabled: isAlarmEnabled,
            blockId: blockId,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final prog = viewModel.progression;
        final todayTasks = viewModel.todayTasks;
        final upcomingTasks = viewModel.upcomingTasks;
        final completedTasks = viewModel.completedTasks;

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
                largeTitle: const Text('Finale Quests'),
                backgroundColor: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.translucentBarBackground,
                  context,
                ),
                trailing: PressableScale(
                  onTap: () => _openQuickTaskCreator(context),
                  child: Container(
                    key: const Key('nav_add_task_button'),
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
                          size: 14,
                          primaryColor: Color(0xFF0A1F10),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Craft',
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

              // Pull-down refresh control
              CupertinoSliverRefreshControl(
                onRefresh: viewModel.refresh,
              ),

              // Top Experience & Level HUD Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: VoxelBlockCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const PixelSpriteIcon(
                                  type: PixelSpriteType.xpOrb,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'LVL ${prog.level}',
                                  style: PixelCupertinoTheme.pixelBadgeStyle(
                                    color: PixelCupertinoTheme.emeraldXp,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            PixelTagChip(
                              label: '${prog.totalXp}xp',
                              color: PixelCupertinoTheme.emeraldXp,
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        VoxelSegmentedProgressBar(
                          progress: prog.levelProgress,
                          segments: 12,
                          height: 11,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Gamification XP Toast Banner (AnimatedSwitcher with Glow)
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: viewModel.lastRewardBanner == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey<String>(
                            viewModel.lastRewardBanner!,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: PressableScale(
                            onTap: viewModel.dismissRewardBanner,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: PixelCupertinoTheme.emeraldDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PixelCupertinoTheme.emeraldXp,
                                  width: 1.5,
                                ),
                                boxShadow: PixelCupertinoTheme.glowShadows(
                                  PixelCupertinoTheme.emeraldXp,
                                  intensity: 0.4,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const PixelSpriteIcon(
                                    type: PixelSpriteType.xpOrb,
                                    size: 16,
                                    primaryColor: CupertinoColors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      viewModel.lastRewardBanner!,
                                      style:
                                          PixelCupertinoTheme.pixelBadgeStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    size: 15,
                                    color: CupertinoColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              // Chronological Section 1: Today
              _buildSectionHeader(
                context,
                title: TaskChronologicalGroup.today.title,
                count: todayTasks.length,
                badgeColor: PixelCupertinoTheme.emeraldXp,
              ),
              _buildTaskListSliver(
                context,
                tasks: todayTasks,
                emptyText: 'All Today quests cleared!',
              ),

              // Chronological Section 2: Upcoming
              _buildSectionHeader(
                context,
                title: TaskChronologicalGroup.upcoming.title,
                count: upcomingTasks.length,
                badgeColor: PixelCupertinoTheme.diamondCyan,
              ),
              _buildTaskListSliver(
                context,
                tasks: upcomingTasks,
                emptyText: 'No upcoming quests.',
              ),

              // Chronological Section 3: Completed
              _buildSectionHeader(
                context,
                title: TaskChronologicalGroup.completed.title,
                count: completedTasks.length,
                badgeColor: PixelCupertinoTheme.goldIngot,
              ),
              _buildTaskListSliver(
                context,
                tasks: completedTasks,
                emptyText: 'Slide right to complete · Slide left for reminder.',
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required Color badgeColor,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: PixelCupertinoTheme.headlineStyle(context),
            ),
            const SizedBox(width: 8),
            PixelTagChip(
              label: '$count',
              color: badgeColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListSliver(
    BuildContext context, {
    required List<TaskItem> tasks,
    required String emptyText,
  }) {
    if (tasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: VoxelBlockCard(
            child: Text(
              emptyText,
              style: PixelCupertinoTheme.subheadStyle(context),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TactileDismissTaskCard(
            key: ValueKey<String>(task.id),
            task: task,
            hapticService: viewModel.haptics,
            onCompleted: viewModel.completeTask,
            onEditReminder: () =>
                _openQuickTaskCreator(context, existingTask: task),
            onDelayTask: (delay) => viewModel.delayTask(task.id, delay),
            onDelete: () => viewModel.deleteTask(task.id),
          );
        },
      ),
    );
  }
}
