import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/task_habit_repository.dart';
import '../../core/theme/pixel_cupertino_theme.dart';
import '../habits/view_models/habits_view_model.dart';
import '../habits/views/habits_screen.dart';
import '../progression/view_models/progression_view_model.dart';
import '../progression/views/progression_screen.dart';
import '../settings/view_models/settings_view_model.dart';
import '../settings/views/settings_screen.dart';
import '../tasks/view_models/tasks_view_model.dart';
import '../tasks/views/tasks_screen.dart';

/// Enforces Rule 1 & Rule 2:
/// - Uses `CupertinoTabScaffold` and `CupertinoTabBar` with `BackdropFilter` translucency
/// - Exclusively uses `CupertinoPageRoute` to preserve native edge-swipe-to-go-back gestures
class MainTabShell extends StatelessWidget {
  const MainTabShell({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<TaskHabitRepository>();

    return CupertinoTabScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        PixelCupertinoTheme.background,
        context,
      ),
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoDynamicColor.resolve(
          PixelCupertinoTheme.translucentBarBackground,
          context,
        ),
        activeColor: PixelCupertinoTheme.emeraldXp,
        inactiveColor: CupertinoDynamicColor.resolve(
          PixelCupertinoTheme.secondaryLabel,
          context,
        ),
        border: Border(
          top: BorderSide(
            color: CupertinoDynamicColor.resolve(
              PixelCupertinoTheme.hairlineSeparator,
              context,
            ),
            width: 0.5,
          ),
        ),
        onTap: (_) => repo.haptics.lightImpact(),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list),
            activeIcon: Icon(CupertinoIcons.square_list_fill),
            label: 'Quests',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flame),
            activeIcon: Icon(CupertinoIcons.flame_fill),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_square),
            activeIcon: Icon(CupertinoIcons.chart_bar_square_fill),
            label: 'Level & Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.slider_horizontal_3),
            activeIcon: Icon(CupertinoIcons.slider_horizontal_3),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          onGenerateRoute: (settings) {
            return CupertinoPageRoute<void>(
              settings: settings,
              builder: (routeContext) {
                switch (index) {
                  case 0:
                    return TasksScreen(
                      viewModel: routeContext.read<TasksViewModel>(),
                    );
                  case 1:
                    return HabitsScreen(
                      viewModel: routeContext.read<HabitsViewModel>(),
                    );
                  case 2:
                    return ProgressionScreen(
                      viewModel: routeContext.read<ProgressionViewModel>(),
                    );
                  case 3:
                  default:
                    return SettingsScreen(
                      viewModel: routeContext.read<SettingsViewModel>(),
                    );
                }
              },
            );
          },
        );
      },
    );
  }
}
