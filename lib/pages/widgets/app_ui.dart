/// Small, reusable Material 3 building blocks shared by all LexiGo screens.
///
/// The widgets here encode the visual language of the app (grouped surface
/// cards, tonal icon badges, section headers, empty states, ...). Keeping them
/// in one place means page files only express layout and content, and the whole
/// app stays visually consistent when the design tokens evolve.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/theme/app_theme.dart';

/// Standard page body padding (20dp gutters, extra room at the bottom).
abstract final class AppInsets {
  /// Padding used by scrollable tab pages.
  static const EdgeInsets page = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.xs,
    AppSpacing.lg,
    AppSpacing.xxl,
  );

  /// Padding used by pushed pages that scroll.
  static const EdgeInsets formPage = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.md,
    AppSpacing.lg,
    AppSpacing.xxl,
  );

  /// Inner padding of standard surfaces.
  static const EdgeInsets surface = EdgeInsets.all(AppSpacing.md);

  /// Inner padding of grouped settings cards.
  static const EdgeInsets group = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xs,
  );
}

/// Constrains page content to a readable width and centres it on large screens.
class AppContent extends StatelessWidget {
  /// Creates a responsive content wrapper.
  const AppContent({
    super.key,
    required this.child,
    this.maxWidth = AppTheme.contentMaxWidth,
    this.alignment = Alignment.topCenter,
  });

  /// The content to constrain.
  final Widget child;

  /// Maximum width of the content.
  final double maxWidth;

  /// Alignment of the content inside the available space.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Rounded surface used for cards, settings groups and hero panels.
class AppSurface extends StatelessWidget {
  /// Creates a tonal surface.
  const AppSurface({
    super.key,
    required this.child,
    this.padding = AppInsets.surface,
    this.color,
    this.borderRadius,
    this.onTap,
    this.semanticLabel,
  });

  /// Content of the surface.
  final Widget child;

  /// Padding around [child].
  final EdgeInsetsGeometry padding;

  /// Solid background color from the active [ColorScheme].
  final Color? color;

  /// Corner radius, defaults to [AppRadius.card].
  final BorderRadius? borderRadius;

  /// Makes the whole surface tappable when set.
  final VoidCallback? onTap;

  /// Optional semantics label for tappable surfaces.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius radius = borderRadius ?? AppRadius.card;
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: colors.outlineVariant),
    );
    final Widget content = Padding(padding: padding, child: child);
    final BoxDecoration decoration = BoxDecoration(
      color: color ?? colors.surfaceContainerLow,
      borderRadius: radius,
    );

    Widget surface = Ink(decoration: decoration, child: content);
    if (onTap != null) {
      surface = InkWell(onTap: onTap, child: surface);
    }

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: surface,
      ),
    );
  }
}

/// Section header with an optional supporting line and trailing action.
class AppSectionHeader extends StatelessWidget {
  /// Creates a section header.
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xxs,
      0,
      AppSpacing.xxs,
      AppSpacing.xs,
    ),
  });

  /// Main section title.
  final String title;

  /// Optional supporting description.
  final String? subtitle;

  /// Optional trailing widget (for example a text button).
  final Widget? trailing;

  /// Padding around the header.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Small eyebrow label rendered above a page title.
class AppEyebrow extends StatelessWidget {
  /// Creates an eyebrow label.
  const AppEyebrow(this.text, {super.key, this.icon});

  /// Text to display.
  final String text;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
        ],
        Text(
          text.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Rounded tonal square holding an icon.
class AppIconBadge extends StatelessWidget {
  /// Creates an icon badge.
  const AppIconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 44,
    this.iconSize,
    this.radius,
  });

  /// Icon to display.
  final IconData icon;

  /// Foreground color, defaults to the theme primary color.
  final Color? color;

  /// Width and height of the badge.
  final double size;

  /// Size of the icon, defaults to roughly half of [size].
  final double? iconSize;

  /// Corner radius, defaults to a rounded square.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color foreground = color ?? colors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius ?? size * 0.32),
      ),
      child: Icon(icon, color: foreground, size: iconSize ?? size * 0.5),
    );
  }
}

/// Compact pill label, used for language chips, "today" markers and badges.
class AppPill extends StatelessWidget {
  /// Creates a pill.
  const AppPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.trailing,
  });

  /// Text content.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Foreground color.
  final Color? color;

  /// Background color.
  final Color? backgroundColor;

  /// Makes the pill interactive when set.
  final VoidCallback? onTap;

  /// Optional trailing widget.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color foreground = color ?? colors.onSurfaceVariant;
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 4),
            trailing!,
          ],
        ],
      ),
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: content,
    );
  }
}

/// Compact statistic tile with an icon, value and label.
class AppStatTile extends StatelessWidget {
  /// Creates a stat tile.
  const AppStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  /// Icon shown in a tonal badge.
  final IconData icon;

  /// Caption below the value.
  final String label;

  /// Highlighted value.
  final String value;

  /// Accent color, defaults to the theme primary color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = color ?? theme.colorScheme.primary;
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: <Widget>[
          AppIconBadge(icon: icon, color: accent, size: 36, iconSize: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly empty-state block.
class AppEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  /// Large decorative icon.
  final IconData icon;

  /// Main empty-state message.
  final String title;

  /// Optional supporting text.
  final String? message;

  /// Optional call to action.
  final Widget? action;

  /// Uses a more compact vertical rhythm.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppSurface(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIconBadge(
            icon: icon,
            size: compact ? 48 : 60,
            iconSize: compact ? 24 : 28,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Grouped list of settings rows inside a single rounded surface.
class AppSettingsGroup extends StatelessWidget {
  /// Creates a grouped settings card.
  const AppSettingsGroup({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.padding = AppInsets.group,
  });

  /// Optional group title.
  final String? title;

  /// Optional group description.
  final String? subtitle;

  /// Rows of the group.
  final List<Widget> children;

  /// Padding inside the surface.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int index = 0; index < children.length; index++) {
      if (index > 0) {
        rows.add(
          const Divider(height: 1, indent: 72, endIndent: AppSpacing.md),
        );
      }
      rows.add(children[index]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null) AppSectionHeader(title: title!, subtitle: subtitle),
        AppSurface(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ],
    );
  }
}

/// Settings row with a tonal leading icon, used inside [AppSettingsGroup].
class AppSettingsTile extends StatelessWidget {
  /// Creates a settings row.
  const AppSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.baseColor,
  });

  /// Leading icon.
  final IconData icon;

  /// Row title.
  final String title;

  /// Optional supporting text.
  final String? subtitle;

  /// Optional trailing widget. Defaults to a chevron when [onTap] is set.
  final Widget? trailing;

  /// Makes the row tappable.
  final VoidCallback? onTap;

  /// Tint of the leading icon.
  final Color? iconColor;

  /// Background tint of the leading icon badge.
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget? effectiveTrailing =
        trailing ??
        (onTap == null
            ? null
            : Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant,
              ));
    return ListTile(
      leading: AppIconBadge(
        icon: icon,
        color: iconColor ?? baseColor ?? colors.primary,
        size: 40,
        iconSize: 20,
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: effectiveTrailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}

/// Page header used by tab pages that do not show a global app bar.
class AppPageHeader extends StatelessWidget {
  /// Creates a page header.
  const AppPageHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.actions,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xxs,
      AppSpacing.xs,
      AppSpacing.xxs,
      AppSpacing.md,
    ),
  });

  /// Optional eyebrow line above the title.
  final String? eyebrow;

  /// Page title.
  final String title;

  /// Optional supporting text below the title.
  final String? subtitle;

  /// Optional actions aligned to the right.
  final List<Widget>? actions;

  /// Padding around the header.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow != null) ...<Widget>[
                  AppEyebrow(eyebrow!),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!
                  .map(
                    (Widget action) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xxs),
                      child: action,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Selectable row used in pickers (language, theme, font, ...).
class AppChoiceTile<T> extends StatelessWidget {
  /// Creates a selectable row.
  const AppChoiceTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onSelected,
  });

  /// Value represented by this row.
  final T value;

  /// Currently selected value.
  final T groupValue;

  /// Row title.
  final String title;

  /// Optional supporting text.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the row is tapped.
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool selected = value == groupValue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      leading: icon == null
          ? null
          : AppIconBadge(
              icon: icon!,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 40,
              iconSize: 20,
            ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: AnimatedContainer(
        duration: AppMotion.fast,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check_rounded,
                size: 16,
                color: theme.colorScheme.onPrimary,
              )
            : null,
      ),
      onTap: () => onSelected(value),
      selected: selected,
      selectedTileColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}

/// Centred loading indicator with an optional label.
class AppLoading extends StatelessWidget {
  /// Creates a loading view.
  const AppLoading({super.key, this.label});

  /// Optional message shown below the indicator.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (label != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Centred error view with a retry action.
class AppErrorView extends StatelessWidget {
  /// Creates an error view.
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  /// Error description.
  final String message;

  /// Retry callback.
  final VoidCallback? onRetry;

  /// Label for the retry button.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIconBadge(
              icon: Icons.cloud_off_rounded,
              color: theme.colorScheme.error,
              size: 56,
              iconSize: 26,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(
                  retryLabel ?? MaterialLocalizations.of(context).okButtonLabel,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
