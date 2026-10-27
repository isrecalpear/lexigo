/// Material Design 3 design system for LexiGo.
///
/// The app used to run on a bare [ThemeData] (`useMaterial3: true` plus a color
/// scheme), which left every component at its most generic default. This file
/// centralises the visual language so all screens share the same grid, shape
/// scale, typography and component styling:
///
/// - [AppSpacing] / [AppRadius] / [AppMotion] are the raw design tokens.
/// - [AppTheme.build] turns a [ColorScheme] into a fully themed [ThemeData].
///
/// Colors come exclusively from the Material [ColorScheme] roles. Solid
/// container colors are used for highlighted surfaces; gradients and custom
/// brand colors are deliberately not part of the design system.
///
/// Pages should not hardcode colors, radii or paddings; they should pull them
/// from the theme or from the shared widgets in `lib/pages/widgets/app_ui.dart`.
library;

// Flutter imports:
import 'package:flutter/material.dart';

/// Spacing scale based on a 4dp grid.
abstract final class AppSpacing {
  /// 4dp.
  static const double xxs = 4;

  /// 8dp.
  static const double xs = 8;

  /// 12dp.
  static const double sm = 12;

  /// 16dp.
  static const double md = 16;

  /// 20dp.
  static const double lg = 20;

  /// 24dp.
  static const double xl = 24;

  /// 32dp.
  static const double xxl = 32;

  /// 48dp.
  static const double huge = 48;
}

/// Corner radii following the Material 3 shape scale.
abstract final class AppRadius {
  /// 4dp.
  static const double xs = 4;

  /// 8dp.
  static const double sm = 8;

  /// 12dp.
  static const double md = 12;

  /// 16dp.
  static const double lg = 16;

  /// 20dp.
  static const double xl = 20;

  /// 24dp.
  static const double xxl = 24;

  /// 28dp, the Material 3 dialog / bottom-sheet radius.
  static const double huge = 28;

  /// Fully rounded (pill) radius.
  static const double full = 999;

  /// Radius used by standard content cards.
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));

  /// Radius used by grouped settings cards.
  static const BorderRadius group = BorderRadius.all(Radius.circular(xxl));

  /// Radius used by dialogs and sheets.
  static const BorderRadius sheet = BorderRadius.all(Radius.circular(huge));
}

/// Standard animation durations.
abstract final class AppMotion {
  /// 120ms, for micro interactions such as ripples and color changes.
  static const Duration fast = Duration(milliseconds: 120);

  /// 220ms, for size / position transitions.
  static const Duration medium = Duration(milliseconds: 220);

  /// 400ms, for larger entrance animations.
  static const Duration slow = Duration(milliseconds: 400);

  /// Standard easing curve for expressive motion.
  static const Curve curve = Curves.easeOutCubic;
}

/// Builds the light and dark [ThemeData] of the application.
abstract final class AppTheme {
  /// Brand seed used when neither dynamic color nor a user seed is available.
  static const Color defaultSeed = Color(0xFF4E5BD6);

  /// Maximum width of readable page content on large screens.
  static const double contentMaxWidth = 920;

  /// Builds a theme for [brightness].
  ///
  /// [dynamicScheme] is the wallpaper-derived scheme provided by
  /// `dynamic_color` (mobile only). [seedColor] is the user's explicit pick and
  /// always wins. When both are missing the brand [defaultSeed] is used so the
  /// app looks intentional instead of falling back to the framework default.
  static ThemeData build({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
    Color? seedColor,
    String? fontFamily,
  }) {
    final ColorScheme colorScheme = seedColor != null
        ? ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness)
        : (dynamicScheme ??
              ColorScheme.fromSeed(
                seedColor: defaultSeed,
                brightness: brightness,
              ));

    final bool isDark = colorScheme.brightness == Brightness.dark;
    final TextTheme textTheme = _buildTextTheme(brightness, fontFamily);
    final ColorScheme colors = colorScheme;

    final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.45)),
    );
    final WidgetStateProperty<OutlinedBorder?> pillButtonShape =
        WidgetStatePropertyAll<OutlinedBorder?>(StadiumBorder());

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      dividerColor: colors.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.7),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.lg,
        toolbarHeight: 64,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.onSurface, size: 22),
        actionsIconTheme: IconThemeData(
          color: colors.onSurfaceVariant,
          size: 22,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colors.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          final bool selected = states.contains(WidgetState.selected);
          return (textTheme.labelMedium ?? const TextStyle()).copyWith(
            color: selected ? colors.onSurface : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
        indicatorColor: colors.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        selectedIconTheme: IconThemeData(
          color: colors.onSecondaryContainer,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: colors.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow.withValues(alpha: 0.08),
        shape: cardShape,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        horizontalTitleGap: AppSpacing.sm,
        minVerticalPadding: AppSpacing.sm,
        iconColor: colors.onSurfaceVariant,
        textColor: colors.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
          ),
          shape: pillButtonShape,
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
          ),
          shape: pillButtonShape,
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: colors.outline.withValues(alpha: 0.6)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(48, 40)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
          ),
          shape: pillButtonShape,
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(64, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
          ),
          shape: pillButtonShape,
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconSize: const WidgetStatePropertyAll<double>(22),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
          overlayColor: WidgetStatePropertyAll<Color>(
            colors.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        isDense: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        iconColor: colors.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surfaceContainerLow,
        modalBarrierColor: colors.scrim.withValues(alpha: 0.45),
        elevation: 1,
        modalElevation: 1,
        showDragHandle: true,
        dragHandleColor: colors.onSurfaceVariant.withValues(alpha: 0.4),
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.huge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
        elevation: 3,
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerHighest,
        selectedColor: colors.secondaryContainer,
        disabledColor: colors.surfaceContainerLow,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.7),
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.bodyMedium?.copyWith(color: colors.onSurface),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colors.onInverseSurface,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceContainerHighest,
        circularTrackColor: colors.surfaceContainerHighest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.surfaceContainerHighest,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.12),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          return states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          return states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          return states.contains(WidgetState.selected)
              ? Colors.transparent
              : colors.outlineVariant;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: colors.outlineVariant.withValues(alpha: 0.8)),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll<double>(0),
        backgroundColor: WidgetStatePropertyAll<Color>(
          colors.surfaceContainerHighest.withValues(alpha: 0.7),
        ),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
        shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.bodyLarge),
        hintStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      searchViewTheme: SearchViewThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        headerTextStyle: textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
        ),
        headerHintStyle: textTheme.titleMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        dividerColor: colors.outlineVariant.withValues(alpha: 0.5),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        headerBackgroundColor: colors.surfaceContainerLow,
        headerForegroundColor: colors.onSurface,
        todayForegroundColor: WidgetStatePropertyAll<Color>(colors.primary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.24),
        selectionHandleColor: colors.primary,
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness, String? fontFamily) {
    // The generated text theme carries the base text color, so the dark theme
    // must start from the white typography (otherwise unstyled text renders
    // black on a dark surface).
    final TextTheme base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final TextTheme themed = fontFamily == null
        ? base
        : base.apply(fontFamily: fontFamily);
    final TextTheme weighted = themed.copyWith(
      displayLarge: themed.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displayMedium: themed.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: themed.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineLarge: themed.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleSmall: themed.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: themed.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: themed.bodyMedium?.copyWith(height: 1.5),
      bodySmall: themed.bodySmall?.copyWith(height: 1.4),
      labelLarge: themed.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: themed.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: themed.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
    return weighted;
  }
}
