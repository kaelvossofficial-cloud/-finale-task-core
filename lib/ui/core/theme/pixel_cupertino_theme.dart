import 'package:flutter/cupertino.dart';

/// Combines Apple HIG Dynamic Colors & SF Pro typography rules (`-0.41` body, `-0.78` headlines)
/// with a Minecraft-inspired Voxel / Pixel-Art palette (Obsidian/Deepslate Dark & Birch/Sandstone Light).
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
    color: Color(0xCCF2EFE9),
    darkColor: Color(0xCC1B1E24),
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

  // Typography following iOS HIG Dynamic Type scale & exact letterSpacing rules
  static TextStyle largeTitleStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.78,
      color: CupertinoDynamicColor.resolve(primaryLabel, context),
    );
  }

  static TextStyle headlineStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 19,
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
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.41,
      color: CupertinoDynamicColor.resolve(primaryLabel, context),
    );
  }

  static TextStyle subheadStyle(BuildContext context) {
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
      color: CupertinoDynamicColor.resolve(secondaryLabel, context),
    );
  }

  static TextStyle pixelBadgeStyle({
    Color color = emeraldXp,
    double fontSize = 11,
  }) {
    return TextStyle(
      fontFamily: 'Courier',
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
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
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.78,
          color: primaryLabel,
        ),
      ),
    );
  }
}
