import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'data/repositories/task_habit_repository.dart';
import 'data/services/haptic_service.dart';
import 'data/services/local_storage_service.dart';
import 'ui/core/theme/pixel_cupertino_theme.dart';
import 'ui/features/habits/view_models/habits_view_model.dart';
import 'ui/features/progression/view_models/progression_view_model.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';
import 'ui/features/shell/main_tab_shell.dart';
import 'ui/features/tasks/view_models/tasks_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = LocalStorageService();
  final hapticService = HapticService();
  final repository = TaskHabitRepository(
    storageService: storageService,
    hapticService: hapticService,
  );
  await repository.initialize();

  runApp(FinaleTaskCoreApp(repository: repository));
}

class FinaleTaskCoreApp extends StatelessWidget {
  const FinaleTaskCoreApp({
    super.key,
    required this.repository,
  });

  final TaskHabitRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskHabitRepository>.value(value: repository),
        ChangeNotifierProvider<TasksViewModel>(
          create: (ctx) => TasksViewModel(
            repository: ctx.read<TaskHabitRepository>(),
          ),
        ),
        ChangeNotifierProvider<HabitsViewModel>(
          create: (ctx) => HabitsViewModel(
            repository: ctx.read<TaskHabitRepository>(),
          ),
        ),
        ChangeNotifierProvider<ProgressionViewModel>(
          create: (ctx) => ProgressionViewModel(
            repository: ctx.read<TaskHabitRepository>(),
          ),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (ctx) => SettingsViewModel(
            repository: ctx.read<TaskHabitRepository>(),
          ),
        ),
      ],
      child: CupertinoApp(
        title: 'Finale Task Core',
        debugShowCheckedModeBanner: false,
        theme: PixelCupertinoTheme.buildCupertinoTheme(),
        home: const MainTabShell(),
      ),
    );
  }
}
