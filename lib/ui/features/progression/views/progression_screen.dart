import 'package:flutter/cupertino.dart';

import '../../../../domain/models/user_progression.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../view_models/progression_view_model.dart';

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({
    super.key,
    required this.viewModel,
  });

  final ProgressionViewModel viewModel;

  void _openAddFriendSheet(BuildContext context) {
    viewModel.haptics.lightImpact();
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalCtx) => FrostedSheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Accountability Friend',
                  style: PixelCupertinoTheme.headlineStyle(modalCtx),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
                  onPressed: () => Navigator.of(modalCtx).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              key: const Key('add_friend_username_input'),
              controller: usernameCtrl,
              autofocus: true,
              placeholder: 'Unique @username (e.g., nova_crafter)...',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: nameCtrl,
              placeholder: 'Display Name (optional)...',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 14),
            PressableScale(
              onTap: () async {
                if (usernameCtrl.text.trim().isEmpty) return;
                await viewModel.addFriend(
                  usernameCtrl.text,
                  nameCtrl.text,
                );
                if (modalCtx.mounted) {
                  Navigator.of(modalCtx).pop();
                }
              },
              child: Container(
                key: const Key('confirm_add_friend_button'),
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PixelCupertinoTheme.emeraldXp,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  'Join Habit Party',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final onTimeRateStr =
            '${viewModel.onTimeCompletionRate.toStringAsFixed(1)}%';
        final activityBars = viewModel.weeklyActivityBars;
        final maxBar = activityBars.fold<int>(
          1,
          (prev, el) => el.count > prev ? el.count : prev,
        );

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
                largeTitle: const Text('Progression'),
                backgroundColor: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.translucentBarBackground,
                  context,
                ),
              ),

              CupertinoSliverRefreshControl(
                onRefresh: viewModel.refresh,
              ),

              // 1. Performance Dashboard with Period Filter (Today / Week / Month / All)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: VoxelBlockCard(
                    accentBorderColor: PixelCupertinoTheme.diamondCyan,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PERFORMANCE DASHBOARD',
                              style: PixelCupertinoTheme.pixelBadgeStyle(
                                color: PixelCupertinoTheme.diamondCyan,
                                fontSize: 10.5,
                              ),
                            ),
                            PixelTagChip(
                              label: '@${viewModel.progression.username}',
                              color: PixelCupertinoTheme.emeraldXp,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CupertinoSlidingSegmentedControl<StatsPeriodFilter>(
                          key: const Key('stats_period_filter_control'),
                          groupValue: viewModel.selectedFilter,
                          children: <StatsPeriodFilter, Widget>{
                            for (final f in StatsPeriodFilter.values)
                              f: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  f.label,
                                  style:
                                      PixelCupertinoTheme.subheadStyle(context),
                                ),
                              ),
                          },
                          onValueChanged: (val) {
                            if (val != null) viewModel.setFilter(val);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _XpMetricBox(
                                label:
                                    '${viewModel.selectedFilter.label.toUpperCase()} QUESTS',
                                value:
                                    '${viewModel.filteredCompletedTasksCount}',
                                valueKey:
                                    const Key('stats_filtered_quests_text'),
                                accent: PixelCupertinoTheme.emeraldXp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _XpMetricBox(
                                label:
                                    '${viewModel.selectedFilter.label.toUpperCase()} HABITS',
                                value:
                                    '${viewModel.filteredHabitCheckInsCount}',
                                valueKey:
                                    const Key('stats_filtered_habits_text'),
                                accent: PixelCupertinoTheme.goldIngot,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 7-Day Activity Voxel Bar Graph
                        SizedBox(
                          height: 78,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: activityBars.map((bar) {
                              final frac =
                                  (bar.count / maxBar).clamp(0.12, 1.0);
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${bar.count}',
                                        style:
                                            PixelCupertinoTheme.pixelBadgeStyle(
                                          color: bar.count > 0
                                              ? PixelCupertinoTheme.emeraldXp
                                              : CupertinoDynamicColor.resolve(
                                                  PixelCupertinoTheme
                                                      .secondaryLabel,
                                                  context,
                                                ),
                                          fontSize: 8.5,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 42 * frac,
                                        decoration: BoxDecoration(
                                          color: bar.count > 0
                                              ? PixelCupertinoTheme.emeraldXp
                                              : CupertinoDynamicColor.resolve(
                                                  PixelCupertinoTheme
                                                      .tertiarySlotBackground,
                                                  context,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        bar.label,
                                        style:
                                            PixelCupertinoTheme.pixelBadgeStyle(
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
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Hero User Level Engine Voxel Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: VoxelBlockCard(
                    accentBorderColor: PixelCupertinoTheme.emeraldXp,
                    glow: true,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: PixelCupertinoTheme.emeraldXp
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: PixelCupertinoTheme.emeraldXp,
                                  width: 2,
                                ),
                              ),
                              child: const PixelSpriteIcon(
                                type: PixelSpriteType.crown,
                                size: 26,
                                primaryColor: PixelCupertinoTheme.goldIngot,
                                secondaryColor: PixelCupertinoTheme.emeraldXp,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LEVEL ENGINE',
                                    style: PixelCupertinoTheme.pixelBadgeStyle(
                                      color: PixelCupertinoTheme.emeraldXp,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Level ${viewModel.currentLevel}',
                                    key: const Key('stats_current_level_text'),
                                    style: PixelCupertinoTheme.largeTitleStyle(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        VoxelSegmentedProgressBar(
                          progress: viewModel.levelProgress,
                          segments: 14,
                          height: 14,
                          activeColor: PixelCupertinoTheme.emeraldXp,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _XpMetricBox(
                                label: 'CURRENT XP',
                                value: '${viewModel.currentXp}xp',
                                valueKey: const Key('stats_current_xp_text'),
                                accent: PixelCupertinoTheme.emeraldXp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _XpMetricBox(
                                label: 'NEXT LEVEL',
                                value: '${viewModel.xpRequiredForNextLevel}xp',
                                valueKey: const Key('stats_next_level_xp_text'),
                                accent: PixelCupertinoTheme.diamondCyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Core Completion Metric Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatVoxelRowCard(
                      title: 'Total Tasks Completed',
                      subtitle: 'Global mined quests',
                      value: '${viewModel.totalTasksCompleted}',
                      valueKey: const Key('stats_total_completed_text'),
                      spriteType: PixelSpriteType.pickaxe,
                      accentColor: PixelCupertinoTheme.emeraldXp,
                    ),
                    const SizedBox(height: 8),
                    _StatVoxelRowCard(
                      title: 'Current Task Streak',
                      subtitle: 'Consecutive days active',
                      value: '${viewModel.currentTaskStreak}d',
                      valueKey: const Key('stats_task_streak_text'),
                      spriteType: PixelSpriteType.flame,
                      accentColor: PixelCupertinoTheme.goldIngot,
                    ),
                    const SizedBox(height: 8),
                    _StatVoxelRowCard(
                      title: 'On-Time Completion Rate',
                      subtitle: '+5xp bonus efficiency',
                      value: onTimeRateStr,
                      valueKey: const Key('stats_on_time_rate_text'),
                      spriteType: PixelSpriteType.xpOrb,
                      accentColor: PixelCupertinoTheme.diamondCyan,
                    ),
                  ]),
                ),
              ),

              // 4. Accountability Party & Friends Leaderboard
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const PixelSpriteIcon(
                            type: PixelSpriteType.friends,
                            size: 18,
                            primaryColor: PixelCupertinoTheme.emeraldXp,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Accountability Party',
                            style: PixelCupertinoTheme.headlineStyle(context),
                          ),
                        ],
                      ),
                      PressableScale(
                        onTap: () => _openAddFriendSheet(context),
                        child: PixelTagChip(
                          key: const Key('add_friend_button'),
                          label: '+ FRIEND',
                          color: PixelCupertinoTheme.emeraldXp,
                          glow: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: viewModel.progression.friends.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final AccountabilityFriend friend =
                        viewModel.progression.friends[index];
                    final fColor = Color(friend.colorArgb);
                    return VoxelBlockCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: fColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: fColor, width: 1.5),
                            ),
                            child: PixelSpriteIcon.fromKey(
                              friend.avatarIconKey,
                              size: 18,
                              primaryColor: fColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.displayName,
                                  style: PixelCupertinoTheme.bodyStyle(context)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '@${friend.username} · ${friend.weeklyXp}xp',
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
                          PixelTagChip(
                            label: '${friend.streakDays}d',
                            color: PixelCupertinoTheme.goldIngot,
                            icon: PixelSpriteType.flame,
                          ),
                          const SizedBox(width: 8),
                          PressableScale(
                            onTap: () => viewModel.nudgeFriend(friend.username),
                            child: PixelTagChip(
                              label: friend.nudgedToday ? 'SENT' : 'NUDGE',
                              color: friend.nudgedToday
                                  ? PixelCupertinoTheme.ironIngot
                                  : PixelCupertinoTheme.diamondCyan,
                            ),
                          ),
                        ],
                      ),
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

class _XpMetricBox extends StatelessWidget {
  const _XpMetricBox({
    required this.label,
    required this.value,
    required this.valueKey,
    required this.accent,
  });

  final String label;
  final String value;
  final Key valueKey;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          PixelCupertinoTheme.tertiarySlotBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PixelCupertinoTheme.pixelBadgeStyle(
              color: accent,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            key: valueKey,
            style: PixelCupertinoTheme.headlineStyle(context),
          ),
        ],
      ),
    );
  }
}

class _StatVoxelRowCard extends StatelessWidget {
  const _StatVoxelRowCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueKey,
    required this.spriteType,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String value;
  final Key valueKey;
  final PixelSpriteType spriteType;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return VoxelBlockCard(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.65),
                width: 1.5,
              ),
            ),
            child: PixelSpriteIcon(
              type: spriteType,
              size: 18,
              primaryColor: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PixelCupertinoTheme.bodyStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: PixelCupertinoTheme.subheadStyle(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            key: valueKey,
            style: PixelCupertinoTheme.pixelBadgeStyle(
              color: accentColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
