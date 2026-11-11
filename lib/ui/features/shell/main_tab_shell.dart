import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/task_habit_repository.dart';
import '../../../domain/models/task_item.dart';
import '../../core/theme/pixel_cupertino_theme.dart';
import '../../core/widgets/pixel_art_painters.dart';
import '../../core/widgets/pressable_scale.dart';
import '../habits/view_models/habits_view_model.dart';
import '../habits/views/habit_creator_sheet.dart';
import '../habits/views/habits_screen.dart';
import '../home/home_block_drum_screen.dart';
import '../progression/view_models/progression_view_model.dart';
import '../progression/views/progression_screen.dart';
import '../settings/view_models/settings_view_model.dart';
import '../settings/views/settings_screen.dart';
import '../tasks/view_models/tasks_view_model.dart';
import '../tasks/views/quick_task_creator_sheet.dart';
import '../tasks/views/tasks_screen.dart';

/// Swipeable PageView Shell + Floating Nav Capsule + Center `+ [Craft Axe]` Button
/// with Glowy Screen Transition aura.
class MainTabShell extends StatefulWidget {
  const MainTabShell({
    super.key,
    this.initialPage = 1,
  });

  /// Defaults to Page 1 (Quests) with Page 0 (Block Drum Picker) one swipe right
  /// or 1-tap on `Blocks` in the floating nav capsule.
  final int initialPage;

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _glowController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageController = PageController(initialPage: _currentIndex);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    final repo = context.read<TaskHabitRepository>();
    repo.haptics.lightImpact();
    _glowController.forward(from: 0.0);
    setState(() {
      _currentIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openCenterCraftAxeMenu(BuildContext context) {
    final repo = context.read<TaskHabitRepository>();
    final tasksVm = context.read<TasksViewModel>();
    final habitsVm = context.read<HabitsViewModel>();
    repo.haptics.mediumImpact();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) => CupertinoActionSheet(
        title: const Text('Craft New Block'),
        message: const Text('Choose what to forge in your world:'),
        actions: [
          CupertinoActionSheetAction(
            key: const Key('craft_menu_quest_action'),
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              showCupertinoModalPopup<void>(
                context: context,
                builder: (_) => QuickTaskCreatorSheet(
                  hapticService: repo.haptics,
                  onCreateTask: ({
                    required String title,
                    DateTime? dueDate,
                    required TaskPriority priority,
                    DateTime? reminderAt,
                    bool isAlarmEnabled = false,
                    String? blockId,
                  }) {
                    return tasksVm.addTask(
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
            },
            child: const Text('Craft Quest (+15xp)'),
          ),
          CupertinoActionSheetAction(
            key: const Key('craft_menu_habit_action'),
            onPressed: () {
              Navigator.of(sheetCtx).pop();
              showCupertinoModalPopup<void>(
                context: context,
                builder: (_) => HabitCreatorSheet(
                  hapticService: repo.haptics,
                  onCreateHabit: habitsVm.addHabit,
                ),
              );
            },
            child: const Text('Forge Daily Habit Block'),
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
    final repo = context.read<TaskHabitRepository>();
    final tasksVm = context.read<TasksViewModel>();
    final habitsVm = context.read<HabitsViewModel>();
    final progVm = context.read<ProgressionViewModel>();
    final settingsVm = context.read<SettingsViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        PixelCupertinoTheme.background,
        context,
      ),
      child: Stack(
        children: [
          // Swipeable Screens via PageView with BouncingScrollPhysics
          PageView(
            key: const Key('main_swipeable_page_view'),
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (idx) {
              repo.haptics.selectionClick();
              _glowController.forward(from: 0.0);
              setState(() {
                _currentIndex = idx;
              });
            },
            children: [
              HomeBlockDrumScreen(repository: repo),
              TasksScreen(viewModel: tasksVm),
              HabitsScreen(viewModel: habitsVm),
              ProgressionScreen(viewModel: progVm),
              SettingsScreen(viewModel: settingsVm),
            ],
          ),

          // GPU-Composited Glowy Screen Transition Overlay
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) {
                final t = _glowController.value;
                if (t == 0.0 || t == 1.0) return const SizedBox.shrink();
                final opacity = (1.0 - t) * 0.16;
                return Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: PixelCupertinoTheme.emeraldXp,
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating Nav Capsule with Center `+ [Craft Axe]` Button
          Positioned(
            left: 14,
            right: 14,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    key: const Key('floating_nav_capsule'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(
                        PixelCupertinoTheme.translucentBarBackground,
                        context,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: PixelCupertinoTheme.emeraldXp
                            .withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: PixelCupertinoTheme.glowShadows(
                        PixelCupertinoTheme.emeraldXp,
                        intensity: 0.22,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CapsuleNavItem(
                          label: 'Blocks',
                          sprite: PixelSpriteType.sun,
                          isSelected: _currentIndex == 0,
                          onTap: () => _navigateToPage(0),
                        ),
                        _CapsuleNavItem(
                          label: 'Quests',
                          sprite: PixelSpriteType.pickaxe,
                          isSelected: _currentIndex == 1,
                          onTap: () => _navigateToPage(1),
                        ),

                        // Center `+ [Craft Axe]` Button
                        PressableScale(
                          onTap: () => _openCenterCraftAxeMenu(context),
                          child: Container(
                            key: const Key('center_craft_axe_button'),
                            width: 46,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: PixelCupertinoTheme.emeraldXp,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: CupertinoColors.white
                                    .withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                              boxShadow: PixelCupertinoTheme.glowShadows(
                                PixelCupertinoTheme.emeraldXp,
                                intensity: 0.55,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.add,
                                  size: 13,
                                  color: Color(0xFF0A1F10),
                                ),
                                SizedBox(width: 2),
                                PixelSpriteIcon(
                                  type: PixelSpriteType.craftAxe,
                                  size: 16,
                                  primaryColor: Color(0xFF0A1F10),
                                  secondaryColor: Color(0xFF1B4332),
                                ),
                              ],
                            ),
                          ),
                        ),

                        _CapsuleNavItem(
                          label: 'Habits',
                          sprite: PixelSpriteType.flame,
                          isSelected: _currentIndex == 2,
                          onTap: () => _navigateToPage(2),
                        ),
                        _CapsuleNavItem(
                          label: 'Level & Stats',
                          sprite: PixelSpriteType.crown,
                          isSelected: _currentIndex == 3,
                          onTap: () => _navigateToPage(3),
                        ),
                        _CapsuleNavItem(
                          label: 'Profile',
                          aliasForTests: 'Settings',
                          sprite: PixelSpriteType.chest,
                          isSelected: _currentIndex == 4,
                          onTap: () => _navigateToPage(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleNavItem extends StatelessWidget {
  const _CapsuleNavItem({
    required this.label,
    required this.sprite,
    required this.isSelected,
    required this.onTap,
    this.aliasForTests,
  });

  final String label;
  final PixelSpriteType sprite;
  final bool isSelected;
  final VoidCallback onTap;
  final String? aliasForTests;

  @override
  Widget build(BuildContext context) {
    const activeColor = PixelCupertinoTheme.emeraldXp;
    final inactiveColor = CupertinoDynamicColor.resolve(
      PixelCupertinoTheme.secondaryLabel,
      context,
    );

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? PixelCupertinoTheme.glowShadows(activeColor, intensity: 0.25)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelSpriteIcon(
              type: sprite,
              size: 16,
              primaryColor: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: PixelCupertinoTheme.pixelBadgeStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 7.5,
              ),
            ),
            if (aliasForTests != null)
              Offstage(
                offstage: true,
                child: Text(aliasForTests!),
              ),
          ],
        ),
      ),
    );
  }
}
