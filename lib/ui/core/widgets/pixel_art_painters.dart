import 'package:flutter/cupertino.dart';
import '../theme/pixel_cupertino_theme.dart';

enum PixelSpriteType {
  xpOrb,
  pickaxe,
  flame,
  crown,
  chest,
  checkmark,
  heart,
}

/// GPU-composited 8x8 Pixel Art Sprite renderer for Minecraft-themed iconography.
class PixelSpriteIcon extends StatelessWidget {
  const PixelSpriteIcon({
    super.key,
    required this.type,
    this.size = 20,
    this.primaryColor,
    this.secondaryColor,
  });

  final PixelSpriteType type;
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _PixelSpritePainter(
            type: type,
            primaryColor: primaryColor ?? PixelCupertinoTheme.emeraldXp,
            secondaryColor: secondaryColor ?? PixelCupertinoTheme.goldIngot,
          ),
        ),
      ),
    );
  }
}

class _PixelSpritePainter extends CustomPainter {
  const _PixelSpritePainter({
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final PixelSpriteType type;
  final Color primaryColor;
  final Color secondaryColor;

  static const List<String> _xpOrbGrid = <String>[
    '..1111..',
    '.122211.',
    '12211111',
    '12111111',
    '11111211',
    '11112211',
    '.111111.',
    '..1111..',
  ];

  static const List<String> _pickaxeGrid = <String>[
    '...1111.',
    '..111111',
    '..11.211',
    '....2.11',
    '...2...1',
    '..2.....',
    '.2......',
    '2.......',
  ];

  static const List<String> _flameGrid = <String>[
    '....1...',
    '...111..',
    '..11211.',
    '.112221.',
    '.1222211',
    '11222211',
    '.112211.',
    '..1111..',
  ];

  static const List<String> _crownGrid = <String>[
    '1..11..1',
    '11.11.11',
    '11111111',
    '12111121',
    '11122111',
    '11111111',
    '.111111.',
    '........',
  ];

  static const List<String> _chestGrid = <String>[
    '.111111.',
    '12222221',
    '12222221',
    '11122111',
    '12222221',
    '12222221',
    '12222221',
    '.111111.',
  ];

  static const List<String> _checkmarkGrid = <String>[
    '.......1',
    '......11',
    '.....11.',
    '1...11..',
    '11.11...',
    '.111....',
    '..1.....',
    '........',
  ];

  static const List<String> _heartGrid = <String>[
    '.11..11.',
    '12211111',
    '12111111',
    '11111111',
    '.111111.',
    '..1111..',
    '...11...',
    '........',
  ];

  List<String> _gridForType() {
    switch (type) {
      case PixelSpriteType.xpOrb:
        return _xpOrbGrid;
      case PixelSpriteType.pickaxe:
        return _pickaxeGrid;
      case PixelSpriteType.flame:
        return _flameGrid;
      case PixelSpriteType.crown:
        return _crownGrid;
      case PixelSpriteType.chest:
        return _chestGrid;
      case PixelSpriteType.checkmark:
        return _checkmarkGrid;
      case PixelSpriteType.heart:
        return _heartGrid;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final grid = _gridForType();
    final cellW = size.width / 8.0;
    final cellH = size.height / 8.0;
    final paint1 = Paint()..color = primaryColor;
    final paint2 = Paint()..color = secondaryColor;

    for (var r = 0; r < 8; r++) {
      final row = grid[r];
      for (var c = 0; c < 8; c++) {
        final ch = row[c];
        if (ch == '.') continue;
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
        canvas.drawRect(rect, ch == '1' ? paint1 : paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelSpritePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

/// Minecraft-styled 3D beveled Voxel Card with Cupertino 10.0-12.0 border radius
/// and subtle top-left highlight / bottom-right shadow border.
class VoxelBlockCard extends StatelessWidget {
  const VoxelBlockCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 11.0,
    this.accentBorderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? accentBorderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        CupertinoDynamicColor.resolve(
          PixelCupertinoTheme.secondaryGroupedBackground,
          context,
        );
    final highlight = accentBorderColor ??
        CupertinoDynamicColor.resolve(
          PixelCupertinoTheme.bevelHighlight,
          context,
        );
    final shadow = CupertinoDynamicColor.resolve(
      PixelCupertinoTheme.bevelShadow,
      context,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border(
          top: BorderSide(color: highlight, width: 1.5),
          left: BorderSide(color: highlight, width: 1.5),
          right: BorderSide(color: shadow, width: 2.0),
          bottom: BorderSide(color: shadow, width: 2.5),
        ),
      ),
      child: child,
    );
  }
}

/// Segmented Minecraft XP-bar / Heart-bar style progress bar.
/// Uses GPU-composited CustomPaint instead of layout-recalculating width loops.
class VoxelSegmentedProgressBar extends StatelessWidget {
  const VoxelSegmentedProgressBar({
    super.key,
    required this.progress,
    this.segments = 10,
    this.height = 12,
    this.activeColor = PixelCupertinoTheme.emeraldXp,
  });

  final double progress;
  final int segments;
  final double height;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final trackColor = CupertinoDynamicColor.resolve(
      PixelCupertinoTheme.tertiarySlotBackground,
      context,
    );
    final borderColor = CupertinoDynamicColor.resolve(
      PixelCupertinoTheme.hairlineSeparator,
      context,
    );

    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _VoxelBarPainter(
            progress: progress.clamp(0.0, 1.0),
            segments: segments,
            activeColor: activeColor,
            trackColor: trackColor,
            borderColor: borderColor,
          ),
        ),
      ),
    );
  }
}

class _VoxelBarPainter extends CustomPainter {
  const _VoxelBarPainter({
    required this.progress,
    required this.segments,
    required this.activeColor,
    required this.trackColor,
    required this.borderColor,
  });

  final double progress;
  final int segments;
  final Color activeColor;
  final Color trackColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    final trackPaint = Paint()..color = trackColor;
    canvas.drawRRect(rrect, trackPaint);

    const gap = 2.0;
    final totalGaps = (segments - 1) * gap;
    final segWidth = (size.width - totalGaps) / segments;
    final activePaint = Paint()..color = activeColor;
    final shinePaint = Paint()
      ..color = const Color(0x55FFFFFF)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < segments; i++) {
      final segStartRatio = i / segments;
      final segEndRatio = (i + 1) / segments;
      if (progress <= segStartRatio) break;

      final localFill =
          ((progress - segStartRatio) / (segEndRatio - segStartRatio))
              .clamp(0.0, 1.0);
      final left = i * (segWidth + gap);
      final width = segWidth * localFill;

      final segRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 1.5, width, size.height - 3.0),
        const Radius.circular(2),
      );
      canvas.drawRRect(segRect, activePaint);

      if (size.height >= 8) {
        canvas.drawRect(
          Rect.fromLTWH(left, 1.5, width, 2.5),
          shinePaint,
        );
      }
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _VoxelBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
