import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../theme/pixel_cupertino_theme.dart';

/// Enforces Rule 3 & Rule 5:
/// - Apple-style modal sheet with top pill handle (`width: 36, height: 5, borderRadius: 2.5`)
/// - Rounded top corners (`Radius.circular(16)`)
/// - `ImageFilter.blur(sigmaX: 15, sigmaY: 15)` with semi-transparent system background
class FrostedSheetContainer extends StatelessWidget {
  const FrostedSheetContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bgColor = CupertinoDynamicColor.resolve(
      PixelCupertinoTheme.translucentBarBackground,
      context,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: bottomInset + 24,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(
                PixelCupertinoTheme.bevelHighlight,
                context,
              ),
              width: 1.5,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Pill Handle (exact spec: width 36, height 5, borderRadius 2.5)
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                      PixelCupertinoTheme.secondaryLabel,
                      context,
                    ).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
