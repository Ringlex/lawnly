import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class Palette {
  Brightness get brightness;

  Color get backgroundColor;
  Color get cardColor;
  Color get outlineColor;

  Color get trackColor;

  Color get tintColor;

  Color get selectedTintColor;

  Color get windowColor;

  Color get primaryColor;
  Color get onPrimaryColor;

  Color get headingColor;
  Color get textColor;
  Color get secondaryTextColor;
  Color get mutedTextColor;

  Color get accentColor;

  Color get springColor;

  Color get heroColor;
  Color get onHeroColor;
  Color get heroMutedColor;
  Color get heroOutlineColor;

  Color get rainColor;

  Color get warningTintColor;
  Color get onWarningColor;
  Color get warningOutlineColor;
  Color get rainTintColor;
  Color get sunColor;
  Color get errorColor;
  Color get shadowColor;
}

class LightPalette extends Palette {
  @override
  final Brightness brightness = Brightness.light;
  @override
  final Color backgroundColor = const Color(0xFFF4F7F2);
  @override
  final Color cardColor = Colors.white;
  @override
  final Color outlineColor = const Color(0xFFCFDDD1);
  @override
  final Color trackColor = const Color(0xFFE3EBE4);
  @override
  final Color tintColor = const Color(0xFFE6EFE7);
  @override
  final Color selectedTintColor = const Color(0xFFEEF5EF);
  @override
  final Color windowColor = const Color(0xFFE2EEDC);
  @override
  final Color primaryColor = const Color(0xFF1E5631);
  @override
  final Color onPrimaryColor = Colors.white;
  @override
  final Color headingColor = const Color(0xFF10301B);
  @override
  final Color textColor = const Color(0xFF17251B);
  @override
  final Color secondaryTextColor = const Color(0xFF3A4D40);
  @override
  final Color mutedTextColor = const Color(0xFF4A6B52);
  @override
  final Color accentColor = const Color(0xFF6FB34F);
  @override
  final Color springColor = const Color(0xFFC6E8A6);
  @override
  final Color heroColor = const Color(0xFF1E5631);
  @override
  final Color onHeroColor = const Color(0xFFE4F2DA);
  @override
  final Color heroMutedColor = const Color(0xFFCFE7C1);
  @override
  final Color heroOutlineColor = const Color(0xFF4E8A5E);
  @override
  final Color rainColor = const Color(0xFF2F6F8F);
  @override
  final Color warningTintColor = const Color(0xFFF8EFD9);
  @override
  final Color onWarningColor = const Color(0xFF4A3300);
  @override
  final Color warningOutlineColor = const Color(0xFFD9B66A);
  @override
  final Color rainTintColor = const Color(0xFFE3EFF4);
  @override
  final Color sunColor = const Color(0xFFB07A12);
  @override
  final Color errorColor = const Color(0xFFB3261E);
  @override
  final Color shadowColor = const Color(0x1410301B);
}

class DarkPalette extends Palette {
  @override
  final Brightness brightness = Brightness.dark;
  @override
  final Color backgroundColor = const Color(0xFF0B1A10);
  @override
  final Color cardColor = const Color(0xFF13261A);
  @override
  final Color outlineColor = const Color(0xFF2B4733);
  @override
  final Color trackColor = const Color(0xFF1B3322);
  @override
  final Color tintColor = const Color(0xFF173020);
  @override
  final Color selectedTintColor = const Color(0xFF1C3A26);
  @override
  final Color windowColor = const Color(0xFF1F3A27);
  @override
  final Color primaryColor = const Color(0xFF9FD27A);
  @override
  final Color onPrimaryColor = const Color(0xFF10301B);
  @override
  final Color headingColor = const Color(0xFFC6E8A6);
  @override
  final Color textColor = const Color(0xFFE4F2DA);
  @override
  final Color secondaryTextColor = const Color(0xFFB9D0BD);
  @override
  final Color mutedTextColor = const Color(0xFF9DB8A3);
  @override
  final Color accentColor = const Color(0xFF6FB34F);
  @override
  final Color springColor = const Color(0xFFC6E8A6);
  @override
  final Color heroColor = const Color(0xFF1E5631);
  @override
  final Color onHeroColor = const Color(0xFFE4F2DA);
  @override
  final Color heroMutedColor = const Color(0xFFCFE7C1);
  @override
  final Color heroOutlineColor = const Color(0xFF4E8A5E);
  @override
  final Color rainColor = const Color(0xFF7DB8D6);
  @override
  final Color warningTintColor = const Color(0xFF3A2E12);
  @override
  final Color onWarningColor = const Color(0xFFF2D9A0);
  @override
  final Color warningOutlineColor = const Color(0xFF7A5F22);
  @override
  final Color rainTintColor = const Color(0xFF16303B);
  @override
  final Color sunColor = const Color(0xFFE2B04A);
  @override
  final Color errorColor = const Color(0xFFFF8A80);
  @override
  final Color shadowColor = const Color(0x66000000);
}

class AppTheme {
  static const cardRadius = 18.0;
  static const heroRadius = 22.0;
  static const fieldRadius = 14.0;
  static const buttonRadius = 16.0;
  static const buttonHeight = 56.0;
  static const fieldHeight = 52.0;

  static Palette paletteOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? LightPalette() : DarkPalette();

  static TextStyle display({double? fontSize, FontWeight fontWeight = FontWeight.w800}) =>
      GoogleFonts.bricolageGrotesque(fontSize: fontSize, fontWeight: fontWeight);

  static TextStyle body({double? fontSize, FontWeight fontWeight = FontWeight.w400}) =>
      GoogleFonts.dmSans(fontSize: fontSize, fontWeight: fontWeight);

  ThemeData theme(Palette palette) {
    final textTheme = _textTheme(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: _scheme(palette),
      scaffoldBackgroundColor: palette.backgroundColor,
      canvasColor: palette.backgroundColor,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: palette.headingColor),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.backgroundColor,
        foregroundColor: palette.headingColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayStyle(palette),
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          backgroundColor: palette.primaryColor,
          foregroundColor: palette.onPrimaryColor,
          disabledBackgroundColor: palette.trackColor,
          disabledForegroundColor: palette.mutedTextColor,
          textStyle: body(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          side: BorderSide(color: palette.outlineColor),
          foregroundColor: palette.headingColor,
          textStyle: body(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primaryColor,
          textStyle: body(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.cardColor,
        hintStyle: body(fontSize: 16).copyWith(color: palette.mutedTextColor),
        helperStyle: body(fontSize: 13).copyWith(color: palette.mutedTextColor),
        helperMaxLines: 3,
        suffixStyle: body(fontSize: 16).copyWith(color: palette.mutedTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: _fieldBorder(palette.outlineColor),
        enabledBorder: _fieldBorder(palette.outlineColor),
        focusedBorder: _fieldBorder(palette.primaryColor, width: 1.5),
        errorBorder: _fieldBorder(palette.errorColor),
        focusedErrorBorder: _fieldBorder(palette.errorColor, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primaryColor),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.headingColor,
        contentTextStyle: body(fontSize: 15).copyWith(color: palette.backgroundColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(fieldRadius)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.backgroundColor,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(heroRadius)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.backgroundColor,
        headerBackgroundColor: palette.primaryColor,
        headerForegroundColor: palette.onPrimaryColor,
      ),
      dividerTheme: DividerThemeData(color: palette.outlineColor, space: 1, thickness: 1),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(fieldRadius),
    borderSide: BorderSide(color: color, width: width),
  );

  static SystemUiOverlayStyle overlayStyle(Palette palette, {Color? navigationBarColor}) {
    final iconBrightness = palette.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: palette.brightness,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarColor: navigationBarColor ?? palette.backgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: false,
    );
  }

  TextTheme _textTheme(Palette palette) {
    TextStyle heading(double size, FontWeight weight, {double height = 1.1}) => display(
      fontSize: size,
      fontWeight: weight,
    ).copyWith(color: palette.headingColor, height: height);

    TextStyle text(double size, FontWeight weight, Color color, {double height = 1.45}) =>
        body(fontSize: size, fontWeight: weight).copyWith(color: color, height: height);

    return TextTheme(
      displayLarge: heading(56, FontWeight.w800, height: 1),
      displayMedium: heading(40, FontWeight.w800),
      displaySmall: heading(30, FontWeight.w800),
      headlineMedium: heading(26, FontWeight.w800, height: 1.15),
      headlineSmall: heading(22, FontWeight.w700),
      titleLarge: heading(19, FontWeight.w700, height: 1.2),
      titleMedium: text(15, FontWeight.w600, palette.headingColor, height: 1.3),
      titleSmall: text(14, FontWeight.w600, palette.headingColor, height: 1.3),
      bodyLarge: text(16, FontWeight.w400, palette.textColor, height: 1.5),
      bodyMedium: text(15, FontWeight.w400, palette.secondaryTextColor, height: 1.5),
      bodySmall: text(13, FontWeight.w400, palette.mutedTextColor),
      labelLarge: text(17, FontWeight.w600, palette.headingColor, height: 1.2),
      labelMedium: text(12, FontWeight.w600, palette.secondaryTextColor, height: 1.2),
      labelSmall: text(11, FontWeight.w500, palette.mutedTextColor, height: 1.2),
    );
  }

  ColorScheme _scheme(Palette palette) => ColorScheme(
    brightness: palette.brightness,
    primary: palette.primaryColor,
    onPrimary: palette.onPrimaryColor,
    secondary: palette.accentColor,
    onSecondary: palette.headingColor,
    surface: palette.backgroundColor,
    onSurface: palette.textColor,
    surfaceContainerHighest: palette.cardColor,
    surfaceContainerHigh: palette.cardColor,
    surfaceContainer: palette.cardColor,
    surfaceContainerLow: palette.backgroundColor,
    onSurfaceVariant: palette.mutedTextColor,
    outline: palette.outlineColor,
    outlineVariant: palette.outlineColor,
    error: palette.errorColor,
    onError: palette.backgroundColor,
  );
}

extension AppThemes on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colors => Theme.of(this).colorScheme;

  Palette get palette => AppTheme.paletteOf(this);
}
