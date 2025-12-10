import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class AppTheme {
  // Material Theme for light mode
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white, // Body background set to white
    brightness: Brightness.light,
    fontFamily: 'SFPro',
    dividerColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // AppBar background set to white
      foregroundColor: CupertinoColors.black, // Text/icons on AppBar
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      overlayShape: SliderComponentShape.noOverlay,
      activeTrackColor: CupertinoColors.activeBlue,
      inactiveTrackColor: CupertinoColors.systemGrey4,
      thumbColor: CupertinoColors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      hintStyle: TextStyle(
        color: CupertinoColors.systemGrey,
        fontWeight: FontWeight.w400,
        fontSize: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 31, 31, 31),
          width: 1,
        ), // Viền xanh nước biển
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 30, 31, 31),
          width: 1,
        ), // Viền xanh nước biển khi không focus
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 19, 19, 20),
          width: 1.5,
        ), // Viền xanh nước biển khi focus
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 24, 25, 26),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: 'SFPro',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
  );

  // Material Theme optimized for desktop (macOS)
  static final desktopLightTheme = _buildDesktopLightTheme();

  // Material Theme for dark mode
  static final darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.dark,
    fontFamily: 'SFPro',
    dividerColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: CupertinoColors.black,
      elevation: 0,
    ),
    sliderTheme: SliderThemeData(
      overlayShape: SliderComponentShape.noOverlay,
      activeTrackColor: CupertinoColors.activeBlue,
      inactiveTrackColor: CupertinoColors.systemGrey4.darkColor,
      thumbColor: CupertinoColors.systemGrey2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CupertinoColors.systemFill.darkColor,
      contentPadding: const EdgeInsets.all(16),
      hintStyle: TextStyle(
        color: CupertinoColors.systemGrey2,
        fontWeight: FontWeight.w400,
        fontSize: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CupertinoColors.systemGrey5.darkColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CupertinoColors.systemGrey5.darkColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: CupertinoColors.activeBlue, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: 'SFPro',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
  );

  // Cupertino Theme for light mode (optional, for Cupertino-specific screens)
  static final cupertinoLightTheme = CupertinoThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: CupertinoColors.white,
    brightness: Brightness.light,
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.black,
    ),
    barBackgroundColor: CupertinoColors.white,
    primaryContrastingColor: CupertinoColors.activeBlue,
  );

  static ThemeData _buildDesktopLightTheme() {
    const scale = 1.2; // Tăng nhẹ kích thước cho desktop
    final base = lightTheme;

    TextTheme _scaleTextTheme(TextTheme theme) {
      TextStyle? _scaleStyle(TextStyle? style) {
        if (style == null || style.fontSize == null) return style;
        return style.copyWith(fontSize: style.fontSize! * scale);
      }

      return theme.copyWith(
        displayLarge: _scaleStyle(theme.displayLarge),
        displayMedium: _scaleStyle(theme.displayMedium),
        displaySmall: _scaleStyle(theme.displaySmall),
        headlineLarge: _scaleStyle(theme.headlineLarge),
        headlineMedium: _scaleStyle(theme.headlineMedium),
        headlineSmall: _scaleStyle(theme.headlineSmall),
        titleLarge: _scaleStyle(theme.titleLarge),
        titleMedium: _scaleStyle(theme.titleMedium),
        titleSmall: _scaleStyle(theme.titleSmall),
        bodyLarge: _scaleStyle(theme.bodyLarge),
        bodyMedium: _scaleStyle(theme.bodyMedium),
        bodySmall: _scaleStyle(theme.bodySmall),
        labelLarge: _scaleStyle(theme.labelLarge),
        labelMedium: _scaleStyle(theme.labelMedium),
        labelSmall: _scaleStyle(theme.labelSmall),
      );
    }

    final scaledTextTheme = _scaleTextTheme(base.textTheme);
    final scaledPrimaryTextTheme = _scaleTextTheme(base.primaryTextTheme);

    final scaledInputDecoration = base.inputDecorationTheme.copyWith(
      contentPadding: EdgeInsets.all(16 * scale),
      hintStyle: base.inputDecorationTheme.hintStyle?.copyWith(
        fontSize:
            (base.inputDecorationTheme.hintStyle?.fontSize ?? 17) * scale,
      ),
    );

    final resolvedButtonTextStyle =
        base.elevatedButtonTheme.style?.textStyle?.resolve({}) ??
            const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'SFPro',
            );

    final scaledElevatedButtonTheme = ElevatedButtonThemeData(
      style: base.elevatedButtonTheme.style?.copyWith(
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            vertical: 14 * scale,
            horizontal: 16 * scale,
          ),
        ),
        textStyle: MaterialStateProperty.all(
          resolvedButtonTextStyle.copyWith(
            fontSize: (resolvedButtonTextStyle.fontSize ?? 17) * scale,
          ),
        ),
      ),
    );

    return base.copyWith(
      textTheme: scaledTextTheme,
      primaryTextTheme: scaledPrimaryTextTheme,
      inputDecorationTheme: scaledInputDecoration,
      elevatedButtonTheme: scaledElevatedButtonTheme,
      visualDensity: VisualDensity.standard,
    );
  }
}
