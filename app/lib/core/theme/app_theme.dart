import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';

/// Marine Precision — ThemeData
/// Áp dụng trong MaterialApp(theme: AppTheme.light)
abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:         AppColors.primary,
        onPrimary:       AppColors.onPrimary,
        primaryContainer:AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary:       AppColors.secondary,
        onSecondary:     AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface:         AppColors.surface,
        onSurface:       AppColors.onSurface,
        error:           AppColors.error,
        onError:         AppColors.onError,
        outline:         AppColors.outline,
        outlineVariant:  AppColors.outlineVariant,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow:    AppColors.surfaceContainerLow,
        surfaceContainer:       AppColors.surfaceContainer,
        surfaceContainerHigh:   AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        tertiary:        AppColors.tertiary,
        onTertiary:      AppColors.onTertiaryContainer,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.beVietnamPro().fontFamily,
    );

    return base.copyWith(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.beVietnamPro(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          height: 24 / 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 56,
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        shadowColor: const Color(0x0F0D3B7A),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          side: const BorderSide(color: AppColors.outlineVariant),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          minimumSize: const Size(0, AppSpacing.touchTarget),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
          ),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        hintStyle: GoogleFonts.beVietnamPro(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── ListTile ─────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
