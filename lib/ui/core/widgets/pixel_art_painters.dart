import 'package:flutter/cupertino.dart';
import '../theme/pixel_cupertino_theme.dart';

enum PixelSpriteType {
  xpOrb,
  pickaxe,
  craftAxe,
  sword,
  shield,
  goldBar,
  ironBar,
  redstoneBar,
  diamond,
  potion,
  book,
  flame,
  crown,
  chest,
  checkmark,
  heart,
  sunrise,
  sun,
  sunset,
  moon,
  star,
  bell,
  alarm,
  calendar,
  code,
  water,
  dumbbell,
  leaf,
  friends,
  dots,
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

  factory PixelSpriteIcon.fromKey(
    String key, {
    Key? widgetKey,
    double size = 20,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return PixelSpriteIcon(
      key: widgetKey,
      type: typeFromKey(key),
      size: size,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  final PixelSpriteType type;
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  /// Selectable habit icons for the Habit Editor.
  static const List<(String key, String label, PixelSpriteType type)>
      habitIconCatalog = <(String, String, PixelSpriteType)>[
    ('potion', 'Potion', PixelSpriteType.potion),
    ('code', 'Redstone', PixelSpriteType.code),
    ('book', 'Tome', PixelSpriteType.book),
    ('dumbbell', 'Strength', PixelSpriteType.dumbbell),
    ('water', 'Water', PixelSpriteType.water),
    ('leaf', 'Herb', PixelSpriteType.leaf),
    ('sword', 'Blade', PixelSpriteType.sword),
    ('diamond', 'Diamond', PixelSpriteType.diamond),
    ('flame', 'Torch', PixelSpriteType.flame),
    ('moon', 'Night', PixelSpriteType.moon),
    ('sun', 'Sun', PixelSpriteType.sun),
    ('crown', 'Crown', PixelSpriteType.crown),
  ];

  static PixelSpriteType typeFromKey(String? key) {
    switch (key) {
      case 'xpOrb':
        return PixelSpriteType.xpOrb;
      case 'pickaxe':
        return PixelSpriteType.pickaxe;
      case 'craftAxe':
        return PixelSpriteType.craftAxe;
      case 'sword':
        return PixelSpriteType.sword;
      case 'shield':
        return PixelSpriteType.shield;
      case 'goldBar':
        return PixelSpriteType.goldBar;
      case 'ironBar':
        return PixelSpriteType.ironBar;
      case 'redstoneBar':
        return PixelSpriteType.redstoneBar;
      case 'diamond':
        return PixelSpriteType.diamond;
      case 'potion':
        return PixelSpriteType.potion;
      case 'book':
        return PixelSpriteType.book;
      case 'flame':
        return PixelSpriteType.flame;
      case 'crown':
        return PixelSpriteType.crown;
      case 'chest':
        return PixelSpriteType.chest;
      case 'checkmark':
        return PixelSpriteType.checkmark;
      case 'heart':
        return PixelSpriteType.heart;
      case 'sunrise':
        return PixelSpriteType.sunrise;
      case 'sun':
        return PixelSpriteType.sun;
      case 'sunset':
        return PixelSpriteType.sunset;
      case 'moon':
        return PixelSpriteType.moon;
      case 'bell':
        return PixelSpriteType.bell;
      case 'alarm':
        return PixelSpriteType.alarm;
      case 'calendar':
        return PixelSpriteType.calendar;
      case 'code':
        return PixelSpriteType.code;
      case 'water':
        return PixelSpriteType.water;
      case 'dumbbell':
        return PixelSpriteType.dumbbell;
      case 'leaf':
        return PixelSpriteType.leaf;
      case 'friends':
        return PixelSpriteType.friends;
      case 'dots':
        return PixelSpriteType.dots;
      case 'star':
      default:
        return PixelSpriteType.star;
    }
  }

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

  static const Map<PixelSpriteType, List<String>> _grids =
      <PixelSpriteType, List<String>>{
    PixelSpriteType.xpOrb: <String>[
      '..1111..',
      '.122211.',
      '12211111',
      '12111111',
      '11111211',
      '11112211',
      '.111111.',
      '..1111..',
    ],
    PixelSpriteType.pickaxe: <String>[
      '...1111.',
      '..111111',
      '..11.211',
      '....2.11',
      '...2...1',
      '..2.....',
      '.2......',
      '2.......',
    ],
    PixelSpriteType.craftAxe: <String>[
      '..1111..',
      '.111111.',
      '.111211.',
      '..122...',
      '...2....',
      '..2.11..',
      '.2..11..',
      '2.......',
    ],
    PixelSpriteType.sword: <String>[
      '......11',
      '.....121',
      '....121.',
      '...121..',
      '.2121...',
      '..22....',
      '.2..2...',
      '2.......',
    ],
    PixelSpriteType.shield: <String>[
      '11111111',
      '12222221',
      '12111121',
      '12122121',
      '12111121',
      '.122221.',
      '..1221..',
      '...11...',
    ],
    PixelSpriteType.goldBar: <String>[
      '........',
      '..11111.',
      '.1222211',
      '12211111',
      '1111111.',
      '.11111..',
      '........',
      '........',
    ],
    PixelSpriteType.ironBar: <String>[
      '........',
      '..11111.',
      '.1222211',
      '12211111',
      '1111111.',
      '.11111..',
      '........',
      '........',
    ],
    PixelSpriteType.redstoneBar: <String>[
      '...11...',
      '..1221..',
      '.122221.',
      '12211221',
      '12222221',
      '.122221.',
      '..1111..',
      '........',
    ],
    PixelSpriteType.diamond: <String>[
      '..1111..',
      '.122221.',
      '12211221',
      '12111121',
      '11111111',
      '.111111.',
      '..1111..',
      '...11...',
    ],
    PixelSpriteType.potion: <String>[
      '...22...',
      '..1221..',
      '...11...',
      '..1111..',
      '.122221.',
      '12211221',
      '12222221',
      '.111111.',
    ],
    PixelSpriteType.book: <String>[
      '.111111.',
      '12222211',
      '12111211',
      '12222211',
      '12111211',
      '12222211',
      '11111111',
      '.222222.',
    ],
    PixelSpriteType.flame: <String>[
      '....1...',
      '...111..',
      '..11211.',
      '.112221.',
      '.1222211',
      '11222211',
      '.112211.',
      '..1111..',
    ],
    PixelSpriteType.crown: <String>[
      '1..11..1',
      '11.11.11',
      '11111111',
      '12111121',
      '11122111',
      '11111111',
      '.111111.',
      '........',
    ],
    PixelSpriteType.chest: <String>[
      '.111111.',
      '12222221',
      '12222221',
      '11122111',
      '12222221',
      '12222221',
      '12222221',
      '.111111.',
    ],
    PixelSpriteType.checkmark: <String>[
      '.......1',
      '......11',
      '.....11.',
      '1...11..',
      '11.11...',
      '.111....',
      '..1.....',
      '........',
    ],
    PixelSpriteType.heart: <String>[
      '.11..11.',
      '12211111',
      '12111111',
      '11111111',
      '.111111.',
      '..1111..',
      '...11...',
      '........',
    ],
    PixelSpriteType.sunrise: <String>[
      '...11...',
      '.1.11.1.',
      '..1221..',
      '.122221.',
      '11222211',
      '22222222',
      '.22..22.',
      '........',
    ],
    PixelSpriteType.sun: <String>[
      '1..11..1',
      '.112211.',
      '..1221..',
      '11222211',
      '11222211',
      '..1221..',
      '.112211.',
      '1..11..1',
    ],
    PixelSpriteType.sunset: <String>[
      '........',
      '..1221..',
      '.122221.',
      '11222211',
      '22222222',
      '.111111.',
      '..2222..',
      '........',
    ],
    PixelSpriteType.moon: <String>[
      '...1111.',
      '..112211',
      '.1121...',
      '.1121...',
      '.1121...',
      '..112211',
      '...1111.',
      '........',
    ],
    PixelSpriteType.star: <String>[
      '...11...',
      '...11...',
      '11122111',
      '.112211.',
      '..1221..',
      '.11..11.',
      '11....11',
      '........',
    ],
    PixelSpriteType.bell: <String>[
      '...11...',
      '..1221..',
      '.122221.',
      '.122221.',
      '.122221.',
      '11111111',
      '...22...',
      '........',
    ],
    PixelSpriteType.alarm: <String>[
      '11....11',
      '1.1111.1',
      '.122221.',
      '.121221.',
      '.121121.',
      '.122221.',
      '..1111..',
      '.1....1.',
    ],
    PixelSpriteType.calendar: <String>[
      '.11..11.',
      '11111111',
      '12222221',
      '12112121',
      '12222221',
      '12122121',
      '12222221',
      '.111111.',
    ],
    PixelSpriteType.code: <String>[
      '..1..1..',
      '.1...1..',
      '1...1..1',
      '.1..1...1',
      '..1.1..1.',
      '....1.1..',
      '...1.....',
      '........',
    ],
    PixelSpriteType.water: <String>[
      '...11...',
      '..1111..',
      '.121111.',
      '.121111.',
      '12111111',
      '12211111',
      '.111111.',
      '..1111..',
    ],
    PixelSpriteType.dumbbell: <String>[
      '.11..11.',
      '111..111',
      '11111111',
      '11111111',
      '111..111',
      '.11..11.',
      '........',
      '........',
    ],
    PixelSpriteType.leaf: <String>[
      '....1111',
      '..112211',
      '.122111.',
      '.121111.',
      '.11111..',
      '..11....',
      '.2......',
      '2.......',
    ],
    PixelSpriteType.friends: <String>[
      '.11..22.',
      '.11..22.',
      '11112222',
      '11112222',
      '.11..22.',
      '.11..22.',
      '........',
      '........',
    ],
    PixelSpriteType.dots: <String>[
      '........',
      '........',
      '........',
      '11.11.11',
      '11.11.11',
      '........',
      '........',
      '........',
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final grid = _grids[type] ?? _grids[PixelSpriteType.star]!;
    final cellW = size.width / 8.0;
    final cellH = size.height / 8.0;
    final paint1 = Paint()..color = primaryColor;
    final paint2 = Paint()..color = secondaryColor;

    for (var r = 0; r < 8; r++) {
      final row = grid[r];
      final maxC = row.length < 8 ? row.length : 8;
      for (var c = 0; c < maxC; c++) {
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

/// Compact, fixed-height pixel chip (replaces uneven Courier terminal boxes).
class PixelTagChip extends StatelessWidget {
  const PixelTagChip({
    super.key,
    required this.label,
    this.color = PixelCupertinoTheme.emeraldXp,
    this.icon,
    this.glow = false,
  });

  final String label;
  final Color color;
  final PixelSpriteType? icon;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: glow
            ? PixelCupertinoTheme.glowShadows(color, intensity: 0.35)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            PixelSpriteIcon(
              type: icon!,
              size: 12,
              primaryColor: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: PixelCupertinoTheme.pixelBadgeStyle(
              color: color,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minecraft-styled 3D beveled Voxel Card with Cupertino 10.0-12.0 border radius
/// and optional glowing aura when active.
class VoxelBlockCard extends StatelessWidget {
  const VoxelBlockCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 11.0,
    this.accentBorderColor,
    this.backgroundColor,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? accentBorderColor;
  final Color? backgroundColor;
  final bool glow;

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
        border: Border.all(
          color: accentBorderColor ?? highlight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: const Offset(1.5, 2.0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          if (glow && accentBorderColor != null)
            ...PixelCupertinoTheme.glowShadows(
              accentBorderColor!,
              intensity: 0.32,
            ),
        ],
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
