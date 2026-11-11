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
                    minSize: 28,
                    onPressed: () => Navigator.of(modalContext).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Copied to clipboard. You can also inspect or copy the raw JSON snapshot below:',
                style: PixelCupertinoTheme.subheadStyle(modalContext),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
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
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11.5,
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
                    minSize: 28,
                    onPressed: () => Navigator.of(modalContext).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                key: const Key('import_json_text_field'),
                controller: controller,
                maxLines: 6,
                minLines: 4,
                placeholder:
                    '{"tasks": [...], "habits": [...], "progression": {...}}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
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
                largeTitle: const Text('Settings'),
                backgroundColor: CupertinoDynamicColor.resolve(
                  PixelCupertinoTheme.translucentBarBackground,
                  context,
                ),
              ),

              // Status Notification Banner
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

              // Grouped List Section 1: Tactile Feedback & Preferences
              SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  header: Text(
                    'TACTILE ENGINE',
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
                      subtitle: Text(
                        'Tactile impact on task swipe completion & controls',
                        style: PixelCupertinoTheme.subheadStyle(context),
                      ),
                      trailing: CupertinoSwitch(
                        key: const Key('settings_haptics_switch'),
                        value: viewModel.hapticsEnabled,
                        activeTrackColor: PixelCupertinoTheme.emeraldXp,
                        onChanged: viewModel.toggleHaptics,
                      ),
                    ),
                  ],
                ),
              ),

              // Grouped List Section 2: Database Backup & Restore
              SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  header: Text(
                    'DATA MANAGEMENT (JSON)',
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
                      subtitle: Text(
                        'Serialize tasks, habits & XP snapshot',
                        style: PixelCupertinoTheme.subheadStyle(context),
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
                      subtitle: Text(
                        'Restore tasks, habits & level state from backup',
                        style: PixelCupertinoTheme.subheadStyle(context),
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _showImportSheet(context),
                    ),
                  ],
                ),
              ),

              // Grouped List Section 3: Danger Zone
              SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  header: Text(
                    'WORLD RESET',
                    style: PixelCupertinoTheme.pixelBadgeStyle(
                      color: PixelCupertinoTheme.redstoneCrimson,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryGroupedBackground,
                      context,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  children: [
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
                      subtitle: Text(
                        'Wipes all tasks, streaks, and XP with confirmation',
                        style: PixelCupertinoTheme.subheadStyle(context),
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
