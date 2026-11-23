import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 56,
    this.subtitle,
    this.showWordmark = true,
    this.inverted = false,
    this.vertical = false,
  });

  final double size;
  final String? subtitle;
  final bool showWordmark;
  final bool inverted;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBox = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: inverted ? Colors.white : AppConfig.brandPrimary,
        gradient: inverted
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConfig.brandPrimaryBright,
                  AppConfig.brandPrimaryDeep,
                ],
              ),
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: (inverted ? Colors.black : AppConfig.brandPrimary)
                .withValues(alpha: inverted ? 0.14 : 0.24),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size.square(size * 0.56),
          painter: _PharmacyCrossPillPainter(
            color: inverted ? AppConfig.brandPrimary : Colors.white,
            cutoutColor: inverted ? Colors.white : AppConfig.brandPrimary,
          ),
        ),
      ),
    );

    if (!showWordmark) {
      return iconBox;
    }

    final wordmark = Column(
      crossAxisAlignment:
          vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConfig.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: vertical ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: vertical ? size * 0.36 : size * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: inverted ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: vertical ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: inverted
                  ? Colors.white.withValues(alpha: 0.9)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBox,
          const SizedBox(height: 14),
          wordmark,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconBox,
        const SizedBox(width: 12),
        Flexible(child: wordmark),
      ],
    );
  }
}

class _PharmacyCrossPillPainter extends CustomPainter {
  const _PharmacyCrossPillPainter({
    required this.color,
    required this.cutoutColor,
  });

  final Color color;
  final Color cutoutColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final armThickness = size.width * 0.34;
    final radius = Radius.circular(size.width * 0.08);

    // Vertical arm
    final vRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: armThickness,
        height: size.height,
      ),
      radius,
    );
    // Horizontal arm
    final hRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: armThickness,
      ),
      radius,
    );

    canvas.drawRRect(vRect, paint);
    canvas.drawRRect(hRect, paint);

    // Subtle capsule accent badge on lower-right matching the mockup icon
    final badgeCenter = Offset(size.width * 0.72, size.height * 0.74);
    final ringPaint = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(badgeCenter, size.width * 0.16, ringPaint);
    canvas.drawCircle(badgeCenter, size.width * 0.1, paint);
  }

  @override
  bool shouldRepaint(covariant _PharmacyCrossPillPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.cutoutColor != cutoutColor;
  }
}
