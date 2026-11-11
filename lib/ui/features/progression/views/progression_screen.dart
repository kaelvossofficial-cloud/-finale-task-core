import 'package:flutter/cupertino.dart';

import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../view_models/progression_view_model.dart';

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({
    super.key,
    required this.viewModel,
  });

  final ProgressionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final onTimeRateStr =
            '${viewModel.onTimeCompletionRate.toStringAsFixed(1)}%';

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

              // Hero User Level Engine Voxel Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: VoxelBlockCard(
                    accentBorderColor: PixelCupertinoTheme.emeraldXp,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
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
                                size: 28,
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
                                    'USER LEVEL ENGINE',
                                    style: PixelCupertinoTheme.pixelBadgeStyle(
                                      color: PixelCupertinoTheme.emeraldXp,
                                      fontSize: 11,
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
                                  Text(
                                    'Formula: Level = ⌊√(XP / 100)⌋ + 1',
                                    style: PixelCupertinoTheme.subheadStyle(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Segmented Emerald Experience Bar
                        VoxelSegmentedProgressBar(
                          progress: viewModel.levelProgress,
                          segments: 14,
                          height: 16,
                          activeColor: PixelCupertinoTheme.emeraldXp,
                        ),
                        const SizedBox(height: 14),

                        // Current XP vs XP Required for Next Level
                        Row(
                          children: [
                            Expanded(
                              child: _XpMetricBox(
                                label: 'CURRENT XP',
                                value: '${viewModel.currentXp} XP',
                                valueKey: const Key('stats_current_xp_text'),
                                accent: PixelCupertinoTheme.emeraldXp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _XpMetricBox(
                                label: 'XP FOR NEXT LEVEL',
                                value: '${viewModel.xpRequiredForNextLevel} XP',
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

              // Section Header: Completion Metrics
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Text(
                    'Completion Metrics',
                    style: PixelCupertinoTheme.headlineStyle(context),
                  ),
                ),
              ),

              // 3 Core Completion Metric Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatVoxelRowCard(
                      title: 'Total Tasks Completed',
                      subtitle: 'Global count of mined task blocks (+10 XP/ea)',
                      value: '${viewModel.totalTasksCompleted}',
                      valueKey: const Key('stats_total_completed_text'),
                      spriteType: PixelSpriteType.pickaxe,
                      accentColor: PixelCupertinoTheme.emeraldXp,
                    ),
                    const SizedBox(height: 10),
                    _StatVoxelRowCard(
                      title: 'Current Task Completion Streak',
                      subtitle: 'Consecutive days with at least 1 mined task',
                      value: '${viewModel.currentTaskStreak}d',
                      valueKey: const Key('stats_task_streak_text'),
                      spriteType: PixelSpriteType.flame,
                      accentColor: PixelCupertinoTheme.goldIngot,
                    ),
                    const SizedBox(height: 10),
                    _StatVoxelRowCard(
                      title: 'On-Time Completion Rate',
                      subtitle:
                          'Tasks finished before due timestamp (+5 XP bonus)',
                      value: onTimeRateStr,
                      valueKey: const Key('stats_on_time_rate_text'),
                      spriteType: PixelSpriteType.xpOrb,
                      accentColor: PixelCupertinoTheme.diamondCyan,
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              fontSize: 10,
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
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.65),
                width: 1.5,
              ),
            ),
            child: PixelSpriteIcon(
              type: spriteType,
              size: 20,
              primaryColor: accentColor,
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 2),
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
            style: PixelCupertinoTheme.headlineStyle(context).copyWith(
              color: accentColor,
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }
}
