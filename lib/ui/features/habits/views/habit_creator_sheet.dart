import 'package:flutter/cupertino.dart';

import '../../../../data/services/haptic_service.dart';
import '../../../core/theme/pixel_cupertino_theme.dart';
import '../../../core/widgets/frosted_sheet_container.dart';
import '../../../core/widgets/pressable_scale.dart';

class HabitCreatorSheet extends StatefulWidget {
  const HabitCreatorSheet({
    super.key,
    required this.hapticService,
    required this.onCreateHabit,
  });

  final HapticService hapticService;
  final Future<void> Function({
    required String title,
    required int gracePeriodDays,
  }) onCreateHabit;

  @override
  State<HabitCreatorSheet> createState() => _HabitCreatorSheetState();
}

class _HabitCreatorSheetState extends State<HabitCreatorSheet> {
  final TextEditingController _titleController = TextEditingController();
  int _gracePeriodDays = 1;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trimmed = _titleController.text.trim();
    if (trimmed.isEmpty) {
      await widget.hapticService.mediumImpact();
      setState(() {
        _error = 'Habit title is required.';
      });
      return;
    }
    await widget.onCreateHabit(
      title: trimmed,
      gracePeriodDays: _gracePeriodDays,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FrostedSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forge Daily Habit Ritual',
                style: PixelCupertinoTheme.headlineStyle(context),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 28,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: PixelCupertinoTheme.subheadStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CupertinoTextField(
            key: const Key('habit_title_input'),
            controller: _titleController,
            autofocus: true,
            placeholder: 'Habit name (e.g., Daily Redstone Study)...',
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            style: PixelCupertinoTheme.bodyStyle(context),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                PixelCupertinoTheme.secondaryGroupedBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: PixelCupertinoTheme.subheadStyle(context).copyWith(
                color: PixelCupertinoTheme.redstoneCrimson,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'STREAK GRACE PERIOD (DAYS ALLOWED BEFORE RESET)',
            style: PixelCupertinoTheme.pixelBadgeStyle(
              color: CupertinoDynamicColor.resolve(
                PixelCupertinoTheme.secondaryLabel,
                context,
              ),
            ),
          ),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: _gracePeriodDays,
            children: const <int, Widget>{
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('0d (Strict)'),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('1d Grace'),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('2d Grace'),
              ),
            },
            onValueChanged: (val) {
              if (val == null) return;
              widget.hapticService.lightImpact();
              setState(() {
                _gracePeriodDays = val;
              });
            },
          ),
          const SizedBox(height: 18),
          PressableScale(
            onTap: _submit,
            child: Container(
              key: const Key('habit_submit_button'),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PixelCupertinoTheme.emeraldXp,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'Create Daily Habit',
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
  }
}
