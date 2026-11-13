import 'package:flutter/material.dart';
import '../../design/ds.dart';
import '../colors/colors.dart';

/// App-wide theme built from the design tokens, so every standard Material
/// component (buttons, fields, dialogs, sheets, switches, chips, tabs…) follows
/// the design system even on screens that don't use the Ds* widgets directly.
const _font = 'Inter'; // registered family → Cairo.ttf

final _shape12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.md));
const _buttonText = TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3);

ThemeData themeDataLight = ThemeData(
  useMaterial3: true,
  fontFamily: _font,
  primaryColor: AppColors.primarySwatchColor,
  primarySwatch: AppColors.primaryColor,
  colorScheme: ColorScheme.fromSeed(seedColor: DsColor.primary).copyWith(
    primary: DsColor.primary,
    onPrimary: Colors.white,
    primaryContainer: DsColor.primarySoft,
    onPrimaryContainer: DsColor.onPrimarySoft,
    secondary: DsColor.accent,
    surface: DsColor.surface,
    onSurface: DsColor.text,
    error: DsColor.danger,
    outline: DsColor.border,
    outlineVariant: DsColor.divider,
  ),
  scaffoldBackgroundColor: DsColor.page,
  splashColor: DsColor.primary.withValues(alpha: .06),
  highlightColor: Colors.transparent,
  dividerTheme: const DividerThemeData(color: DsColor.divider, thickness: 1, space: 1),
  appBarTheme: const AppBarTheme(
    backgroundColor: DsColor.surface,
    surfaceTintColor: DsColor.surface,
    foregroundColor: DsColor.text,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700, color: DsColor.text),
  ),
  cardTheme: CardThemeData(
    color: DsColor.surface,
    surfaceTintColor: DsColor.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg), side: const BorderSide(color: DsColor.border)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DsColor.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: 15),
    hintStyle: const TextStyle(fontFamily: _font, fontSize: 14, color: DsColor.textSubtle),
    labelStyle: const TextStyle(fontFamily: _font, fontSize: 14, color: DsColor.textMuted),
    errorStyle: const TextStyle(fontFamily: _font, fontSize: 12, color: DsColor.danger),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(DsRadius.md), borderSide: const BorderSide(color: DsColor.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsRadius.md), borderSide: const BorderSide(color: DsColor.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsRadius.md), borderSide: const BorderSide(color: DsColor.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsRadius.md), borderSide: const BorderSide(color: DsColor.danger)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsRadius.md), borderSide: const BorderSide(color: DsColor.danger, width: 1.5)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DsColor.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: DsColor.fill,
      disabledForegroundColor: DsColor.textSubtle,
      elevation: 0,
      minimumSize: const Size(64, DsSize.button),
      padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg),
      shape: _shape12,
      textStyle: _buttonText,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DsColor.primary,
      minimumSize: const Size(64, DsSize.button),
      shape: _shape12,
      textStyle: _buttonText,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DsColor.primary,
      minimumSize: const Size(64, DsSize.button),
      side: const BorderSide(color: DsColor.border),
      shape: _shape12,
      textStyle: _buttonText,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DsColor.primary,
      minimumSize: const Size(48, DsSize.button),
      shape: _shape12,
      textStyle: _buttonText,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(DsSize.touch, DsSize.touch))),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: DsColor.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    highlightElevation: 2,
    extendedTextStyle: _buttonText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: DsColor.surface,
    selectedColor: DsColor.primary,
    side: const BorderSide(color: DsColor.border),
    shape: const StadiumBorder(),
    labelStyle: const TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600, color: DsColor.text),
    secondaryLabelStyle: const TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
    showCheckmark: false,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
    trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? DsColor.primary : const Color(0xffD1D5DB)),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? DsColor.primary : null),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? DsColor.primary : DsColor.textSubtle)),
  dialogTheme: DialogThemeData(
    backgroundColor: DsColor.surface,
    surfaceTintColor: DsColor.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg)),
    titleTextStyle: const TextStyle(fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700, color: DsColor.text),
    contentTextStyle: const TextStyle(fontFamily: _font, fontSize: 14, color: DsColor.text2, height: 1.5),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: DsColor.surface,
    surfaceTintColor: DsColor.surface,
    showDragHandle: true,
    dragHandleColor: Color(0xffD1D5DB),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: DsColor.surface,
    surfaceTintColor: DsColor.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.md), side: const BorderSide(color: DsColor.border)),
    textStyle: const TextStyle(fontFamily: _font, fontSize: 14, color: DsColor.text),
  ),
  listTileTheme: const ListTileThemeData(
    minTileHeight: DsSize.row,
    iconColor: DsColor.textMuted,
    titleTextStyle: TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600, color: DsColor.text),
    subtitleTextStyle: TextStyle(fontFamily: _font, fontSize: 12, color: DsColor.textMuted),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: DsColor.primary,
    unselectedLabelColor: DsColor.textMuted,
    indicatorColor: DsColor.primary,
    dividerColor: DsColor.divider,
    labelStyle: TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: DsColor.text,
    contentTextStyle: const TextStyle(fontFamily: _font, fontSize: 14, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.md)),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: DsColor.primary, linearTrackColor: DsColor.fill),
  textSelectionTheme: TextSelectionThemeData(cursorColor: DsColor.primary, selectionColor: DsColor.primary.withValues(alpha: .2), selectionHandleColor: DsColor.primary),
);
