import 'package:flutter/cupertino.dart';

/// Combines Apple HIG Dynamic Colors & SF Pro typography rules (`-0.41` body, `-0.78` headlines)
/// with the Silkscreen Pixel Font and a Minecraft Voxel palette.
class PixelCupertinoTheme {
  const PixelCupertinoTheme._();

  // Dynamic Background Colors (adapts automatically between Light & Dark Mode)
  static const CupertinoDynamicColor background =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2EFE9), // Sandstone / Birch Parchment
    darkColor: Color(0xFF141619), // Deep Slate / Obsidian
  );

  static const CupertinoDynamicColor secondaryGroupedBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF), // Polished Quartz Block
    darkColor: Color(0xFF21252B), // Cobblestone / Carved Deepslate Slot
  );

  static const CupertinoDynamicColor tertiarySlotBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE4DFD5), // Inventory Slot Light
    darkColor: Color(0xFF2C313A), // Inventory Slot Dark
  );

  static const CupertinoDynamicColor translucentBarBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xD9F2EFE9),
    darkColor: Color(0xD91B1E24),
  );

  static const CupertinoDynamicColor primaryLabel =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xFF1B1D21),
    darkColor: Color(0xFFF4F6F8),
  );

  static const CupertinoDynamicColor secondaryLabel =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xFF5C626E),
    darkColor: Color(0xFF9BA3B0),
  );

  static const CupertinoDynamicColor hairlineSeparator =
      CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  );

  // Voxel 3D Bevel Highlight & Shadow
  static const CupertinoDynamicColor bevelHighlight =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xCCFFFFFF),
    darkColor: Color(0x38FFFFFF),
  );

  static const CupertinoDynamicColor bevelShadow =
      CupertinoDynamicColor.withBrightness(
    color: Color(0x2E000000),
    darkColor: Color(0x99000000),
  );

  // Minecraft Ore & Gem Accent Colors
  static const Color emeraldXp = Color(0xFF17DD62);
  static const Color emeraldDark = Color(0xFF0E9F43);
  static const Color diamondCyan = Color(0xFF3CE6D6);
  static const Color goldIngot = Color(0xFFFFAA00);
  static const Color redstoneCrimson = Color(0xFFFF3B30);
  static const Color amethystPurple = Color(0xFFA855F7);
  static const Color ironIngot = Color(0xFF9CA3AF);
  static const Color lapisBlue = Color(0xFF3B82F6);
  static const Color copperOrange = Color(0xFFF97316);
  static const Color sakuraPink = Color(0xFFEC4899);

  /// Custom color palette swatches for Habits & Blocks.
  static const List<int> habitPaletteArgb = <int>[
    0xFF17DD62, // Emerald
    0xFF3CE6D6, // Diamond
    0xFFFFAA00, // Gold
    0xFFFF3B30, // Redstone
    0xFFA855F7, // Amethyst
    0xFF3B82F6, // Lapis
    0xFFF97316, // Copper
    0xFFEC4899, // Sakura
  ];

  /// Precomputed glow shadows for active controls and screen transitions.
  static List<BoxShadow> glowShadows(Color color, {double intensity = 0.45}) {
    return <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: intensity.clamp(0.0, 1.0)),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ];
  }

  // Typography following iOS HIG Dynamic Type scale & exact letterSpacing rules
  static TextStyle largeTitleStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.78,
      color: CupertinoDynamicColor.resolve(primaryLabel, context),
    );
  }

  static TextStyle headlineStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.78,
      color: CupertinoDynamicColor.resolve(primaryLabel, context),
    );
  }

  static TextStyle navTitleStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      color: CupertinoDynamicColor.resolve(primaryLabel, context),
    );
  }

  static TextStyle bodyStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 15.5,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.41,
      color: CupertinoDynamicColor.resolve(primaryLabel, context),
    );
  }

  static TextStyle subheadStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
      color: CupertinoDynamicColor.resolve(secondaryLabel, context),
    );
  }

  /// Uses bundled `Silkscreen` pixel font for numbers, XP chips, and badges.
  static TextStyle pixelBadgeStyle({
    Color color = emeraldXp,
    double fontSize = 10.5,
  }) {
    return TextStyle(
      fontFamily: 'Silkscreen',
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: color,
    );
  }

  static CupertinoThemeData buildCupertinoTheme() {
    return const CupertinoThemeData(
      primaryColor: emeraldXp,
      scaffoldBackgroundColor: background,
      barBackgroundColor: translucentBarBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: emeraldXp,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16,
          letterSpacing: -0.41,
          color: primaryLabel,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: primaryLabel,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.78,
          color: primaryLabel,
        ),
      ),
    );
  }
}
