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

  void _openQuickTaskCreator(BuildContext context) {
    viewModel.haptics.lightImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) => QuickTaskCreatorSheet(
        hapticService: viewModel.haptics,
        onCreateTask: ({
          required String title,
          DateTime? dueDate,
          required TaskPriority priority,
        }) {
          return viewModel.addTask(
            title: title,
            dueDate: dueDate,
            priority: priority,
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
          child: Stack(
            children: [
              CustomScrollView(
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
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'LVL ${prog.level} CRAFTER',
                                      style:
                                          PixelCupertinoTheme.pixelBadgeStyle(
                                        color: PixelCupertinoTheme.emeraldXp,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${prog.totalXp} XP · ${prog.xpRequiredForNextLevel} XP to LVL ${prog.level + 1}',
                                  style: PixelCupertinoTheme.subheadStyle(
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            VoxelSegmentedProgressBar(
                              progress: prog.levelProgress,
                              segments: 12,
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Gamification XP Toast Banner (AnimatedSwitcher)
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
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PixelCupertinoTheme.emeraldDark,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: PixelCupertinoTheme.emeraldXp,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const PixelSpriteIcon(
                                        type: PixelSpriteType.xpOrb,
                                        size: 18,
                                        primaryColor: CupertinoColors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          viewModel.lastRewardBanner!,
                                          style: PixelCupertinoTheme
                                              .pixelBadgeStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                        size: 16,
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
                    emptyText:
                        'All Today blocks mined! Tap "+ New Task Block" below.',
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
                    emptyText: 'No upcoming scheduled blocks.',
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
                    emptyText:
                        'Slide any task card right to mine it for +10 XP (+5 on-time).',
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 150),
                  ),
                ],
              ),

              // Persistent Quick Task Creator Bar above translucent tab bar
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.paddingOf(context).bottom + 14,
                child: PressableScale(
                  onTap: () => _openQuickTaskCreator(context),
                  child: VoxelBlockCard(
                    key: const Key('quick_task_creator_bar'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    accentBorderColor: PixelCupertinoTheme.emeraldXp,
                    child: Row(
                      children: [
                        const PixelSpriteIcon(
                          type: PixelSpriteType.pickaxe,
                          size: 18,
                          primaryColor: PixelCupertinoTheme.emeraldXp,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '+ Quick Craft Task (Title, Due Time, Priority)...',
                            style:
                                PixelCupertinoTheme.bodyStyle(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PixelCupertinoTheme.emeraldXp
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+10 XP',
                            style: PixelCupertinoTheme.pixelBadgeStyle(
                              color: PixelCupertinoTheme.emeraldXp,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: PixelCupertinoTheme.headlineStyle(context),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Text(
                '$count',
                style: PixelCupertinoTheme.pixelBadgeStyle(
                  color: badgeColor,
                  fontSize: 11,
                ),
              ),
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
            onDelete: () => viewModel.deleteTask(task.id),
          );
        },
      ),
    );
  }
}
