import 'package:flutter/cupertino.dart';

import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pixel_art_painters.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.viewModel,
  });

  final SettingsViewModel viewModel;

  void _openEditProfileSheet(BuildContext context) {
    viewModel.haptics.lightImpact();
    final userCtrl =
        TextEditingController(text: viewModel.progression.username);
    final nameCtrl =
        TextEditingController(text: viewModel.progression.displayName);
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
                  'Edit Profile & Unique @Username',
                  style: PixelCupertinoTheme.headlineStyle(modalCtx),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  onPressed: () => Navigator.of(modalCtx).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: nameCtrl,
              placeholder: 'Display Name',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: userCtrl,
              placeholder: 'Unique username (e.g. kael_crafter)',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 14),
            PressableScale(
              onTap: () async {
                await viewModel.updateProfile(
                  username: userCtrl.text,
                  displayName: nameCtrl.text,
                );
                if (modalCtx.mounted) {
                  Navigator.of(modalCtx).pop();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PixelCupertinoTheme.emeraldXp,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  'Save Profile',
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

  void _showExportSheet(BuildContext context) {
    final exportedJson = viewModel.generateExportJson();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) {
        return FrostedSheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exported Database JSON',
                    style: PixelCupertinoTheme.headlineStyle(modalContext),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                    onPressed: () => Navigator.of(modalContext).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    PixelCupertinoTheme.secondaryGroupedBackground,
                    modalContext,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    exportedJson,
                    key: const Key('exported_json_preview_text'),
                    style: PixelCupertinoTheme.pixelBadgeStyle(
                      color: CupertinoDynamicColor.resolve(
                        PixelCupertinoTheme.primaryLabel,
                        modalContext,
                      ),
                      fontSize: 9.5,
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

  void _showImportSheet(BuildContext context) {
    viewModel.haptics.lightImpact();
    final controller = TextEditingController();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) {
        return FrostedSheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Import Database from JSON',
                    style: PixelCupertinoTheme.headlineStyle(modalContext),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                    onPressed: () => Navigator.of(modalContext).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                key: const Key('import_json_text_field'),
                controller: controller,
                maxLines: 5,
                minLines: 3,
                placeholder:
                    '{"tasks": [...], "habits": [...], "progression": {...}}',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    PixelCupertinoTheme.secondaryGroupedBackground,
                    modalContext,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              PressableScale(
                onTap: () async {
                  final ok = await viewModel.importFromJson(controller.text);
                  if (ok && modalContext.mounted) {
                    Navigator.of(modalContext).pop();
                  }
                },
                child: Container(
                  key: const Key('confirm_import_json_button'),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PixelCupertinoTheme.emeraldXp,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Text(
                    'Restore Snapshot',
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
        );
      },
    );
  }

  void _confirmResetDialog(BuildContext context) {
    viewModel.haptics.mediumImpact();
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Reset Progression & Data?'),
          content: const Text(
            'This will permanently clear all tasks, daily habit streaks, and reset your User Level back to Level 1 (0 XP).',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              key: const Key('confirm_reset_dialog_button'),
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await viewModel.resetAllData();
              },
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final prog = viewModel.progression;
        final today = viewModel.today;
        final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
        final logs = viewModel.recentLogs;

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
                largeTitle: const Text('Profile'),
                backgroundColor: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.translucentBarBackground,
                  context,
                ),
              ),

              if (viewModel.statusMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: VoxelBlockCard(
                      accentBorderColor: viewModel.isErrorStatus
                          ? PixelCupertinoTheme.redstoneCrimson
                          : PixelCupertinoTheme.emeraldXp,
                      child: Text(
                        viewModel.statusMessage!,
                        key: const Key('settings_status_banner'),
                        style:
                            PixelCupertinoTheme.subheadStyle(context).copyWith(
                          color: viewModel.isErrorStatus
                              ? PixelCupertinoTheme.redstoneCrimson
                              : PixelCupertinoTheme.emeraldXp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              // 1. User Profile & Unique @Username Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: VoxelBlockCard(
                    accentBorderColor: PixelCupertinoTheme.emeraldXp,
                    glow: true,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: PixelCupertinoTheme.emeraldXp
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PixelCupertinoTheme.emeraldXp,
                              width: 1.5,
                            ),
                          ),
                          child: PixelSpriteIcon.fromKey(
                            prog.avatarIconKey,
                            size: 24,
                            primaryColor: PixelCupertinoTheme.goldIngot,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prog.displayName,
                                style:
                                    PixelCupertinoTheme.headlineStyle(context),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  PixelTagChip(
                                    label: '@${prog.username}',
                                    color: PixelCupertinoTheme.emeraldXp,
                                  ),
                                  const SizedBox(width: 6),
                                  PixelTagChip(
                                    label: 'LVL ${prog.level}',
                                    color: PixelCupertinoTheme.goldIngot,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(30, 30),
                          onPressed: () => _openEditProfileSheet(context),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Combined Habit & Task Color Calendar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
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
                                  type: PixelSpriteType.calendar,
                                  size: 16,
                                  primaryColor: PixelCupertinoTheme.diamondCyan,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ACTIVITY CALENDAR',
                                  style: PixelCupertinoTheme.pixelBadgeStyle(
                                    color: PixelCupertinoTheme.diamondCyan,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Habit & Quest Colors',
                              style: PixelCupertinoTheme.subheadStyle(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List<Widget>.generate(daysInMonth, (index) {
                            final dayNum = index + 1;
                            final date =
                                DateTime(today.year, today.month, dayNum);
                            final dots = viewModel.colorDotsForDate(date);
                            final isToday = dayNum == today.day;

                            return Container(
                              width: 36,
                              height: 38,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(
                                color: CupertinoDynamicColor.resolve(
                                  PixelCupertinoTheme.tertiarySlotBackground,
                                  context,
                                ),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: isToday
                                      ? PixelCupertinoTheme.emeraldXp
                                      : (dots.isNotEmpty
                                          ? Color(dots.first)
                                              .withValues(alpha: 0.7)
                                          : CupertinoColors.transparent),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$dayNum',
                                    style: PixelCupertinoTheme.pixelBadgeStyle(
                                      color: CupertinoDynamicColor.resolve(
                                        PixelCupertinoTheme.primaryLabel,
                                        context,
                                      ),
                                      fontSize: 9,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: dots.map((argb) {
                                      return Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(argb),
                                          borderRadius:
                                              BorderRadius.circular(1.5),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Custom Home-Screen Widget Preview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: VoxelBlockCard(
                    accentBorderColor: PixelCupertinoTheme.goldIngot,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HOME WIDGET (PIXEL THEME)',
                              style: PixelCupertinoTheme.pixelBadgeStyle(
                                color: PixelCupertinoTheme.goldIngot,
                                fontSize: 10,
                              ),
                            ),
                            const PixelTagChip(
                              label: 'ACTIVE',
                              color: PixelCupertinoTheme.emeraldXp,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        VoxelSegmentedProgressBar(
                          progress: prog.levelProgress,
                          segments: 8,
                          height: 9,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Synced with Android AppWidget & iOS WidgetKit · Shows current Block Quests & XP.',
                          style: PixelCupertinoTheme.subheadStyle(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Logs & History Timeline
              if (logs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                    child: VoxelBlockCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOGS & HISTORY',
                            style: PixelCupertinoTheme.pixelBadgeStyle(
                              color: PixelCupertinoTheme.emeraldXp,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...logs.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(entry.colorArgb),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                  const SizedBox(width: 6),
                                  PixelTagChip(
                                    label: entry.badge,
                                    color: Color(entry.colorArgb),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

              // 5. Grouped List Section: Tactile Engine & Data Management
              SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  header: Text(
                    'TACTILE & DATA ENGINE',
                    style: PixelCupertinoTheme.pixelBadgeStyle(
                      color: CupertinoDynamicColor.resolve(
                        PixelCupertinoTheme.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryGroupedBackground,
                      context,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  separatorColor: CupertinoDynamicColor.resolve(
                    PixelCupertinoTheme.hairlineSeparator,
                    context,
                  ),
                  children: [
                    CupertinoListTile(
                      leading: const PixelSpriteIcon(
                        type: PixelSpriteType.xpOrb,
                        size: 20,
                      ),
                      title: Text(
                        'Vibration & Haptics',
                        style: PixelCupertinoTheme.bodyStyle(context),
                      ),
                      trailing: CupertinoSwitch(
                        key: const Key('settings_haptics_switch'),
                        value: viewModel.hapticsEnabled,
                        activeTrackColor: PixelCupertinoTheme.emeraldXp,
                        onChanged: viewModel.toggleHaptics,
                      ),
                    ),
                    CupertinoListTile(
                      key: const Key('settings_export_json_tile'),
                      leading: const PixelSpriteIcon(
                        type: PixelSpriteType.chest,
                        size: 20,
                        primaryColor: PixelCupertinoTheme.emeraldXp,
                      ),
                      title: Text(
                        'Export Database to JSON',
                        style: PixelCupertinoTheme.bodyStyle(context),
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _showExportSheet(context),
                    ),
                    CupertinoListTile(
                      key: const Key('settings_import_json_tile'),
                      leading: const PixelSpriteIcon(
                        type: PixelSpriteType.chest,
                        size: 20,
                        primaryColor: PixelCupertinoTheme.diamondCyan,
                      ),
                      title: Text(
                        'Import from JSON',
                        style: PixelCupertinoTheme.bodyStyle(context),
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _showImportSheet(context),
                    ),
                    CupertinoListTile(
                      key: const Key('settings_reset_all_tile'),
                      leading: const Icon(
                        CupertinoIcons.trash_fill,
                        color: PixelCupertinoTheme.redstoneCrimson,
                        size: 20,
                      ),
                      title: Text(
                        'Reset Progression & Data',
                        style: PixelCupertinoTheme.bodyStyle(context).copyWith(
                          color: PixelCupertinoTheme.redstoneCrimson,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _confirmResetDialog(context),
                    ),
                  ],
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
