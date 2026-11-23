import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 5,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ?? theme.colorScheme.surface;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderColor != null
          ? BorderSide(color: borderColor!, width: 1.4)
          : BorderSide.none,
    );

    final surface = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              hoverColor: backgroundColor != null
                  ? Colors.white.withValues(alpha: isDark ? 0.04 : 0.18)
                  : AppConfig.brandPrimary.withValues(
                      alpha: isDark ? 0.06 : 0.025,
                    ),
              highlightColor: AppConfig.brandPrimary.withValues(alpha: 0.05),
              splashColor: AppConfig.brandPrimary.withValues(alpha: 0.08),
              child: Padding(
                padding: padding,
                child: child,
              ),
            )
          : Padding(
              padding: padding,
              child: child,
            ),
    );

    if (!elevated || isDark) {
      return surface;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: surface,
    );
  }
}

enum StatusTone { brand, emerald, amber, rose, blue, purple, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _resolvePalette(tone, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: palette.foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: palette.foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: palette.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _PillPalette _resolvePalette(StatusTone tone, bool isDark) {
    switch (tone) {
      case StatusTone.brand:
      case StatusTone.emerald:
        return _PillPalette(
          foreground: isDark
              ? const Color(0xFF34D399)
              : AppConfig.brandPrimary,
          background: AppConfig.brandPrimary.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        );
      case StatusTone.amber:
        return _PillPalette(
          foreground: isDark ? const Color(0xFFFBBF24) : AppConfig.amber,
          background: AppConfig.amber.withValues(alpha: isDark ? 0.2 : 0.1),
        );
      case StatusTone.rose:
        return _PillPalette(
          foreground: isDark ? const Color(0xFFF87171) : AppConfig.rose,
          background: AppConfig.rose.withValues(alpha: isDark ? 0.2 : 0.1),
        );
      case StatusTone.blue:
        return _PillPalette(
          foreground: isDark ? const Color(0xFF60A5FA) : AppConfig.blue,
          background: AppConfig.blue.withValues(alpha: isDark ? 0.2 : 0.1),
        );
      case StatusTone.purple:
        return _PillPalette(
          foreground: isDark ? const Color(0xFFA78BFA) : AppConfig.purple,
          background: AppConfig.purple.withValues(alpha: isDark ? 0.2 : 0.1),
        );
      case StatusTone.neutral:
        return _PillPalette(
          foreground: isDark
              ? AppConfig.inkSecondaryDark
              : AppConfig.inkSecondaryLight,
          background: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF1F5F9),
        );
    }
  }
}

class _PillPalette {
  const _PillPalette({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppConfig.brandPrimary,
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class FilterPillChip extends StatelessWidget {
  const FilterPillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppConfig.brandPrimary
              : (isDark ? AppConfig.elevatedDark : const Color(0xFFEDF1F5)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class MenuTileCard extends StatelessWidget {
  const MenuTileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor = AppConfig.brandPrimary,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      borderRadius: 5,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ],
      ),
    );
  }
}
