import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/widgets/brand_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConfig.brandPrimaryDeep,
                    AppConfig.brandPrimary,
                    AppConfig.brandPrimaryBright,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: const _BottomWavesPainter(),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Center(
                        child: BrandLogo(
                          size: 74,
                          inverted: true,
                          vertical: true,
                          subtitle: AppConfig.appTagline,
                        ),
                      ),
                      const SizedBox(height: 36),
                      const _WelcomeFeatureRow(
                        icon: Icons.point_of_sale_outlined,
                        label: 'POS & Billing',
                      ),
                      const SizedBox(height: 16),
                      const _WelcomeFeatureRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Inventory & Stock',
                      ),
                      const SizedBox(height: 16),
                      const _WelcomeFeatureRow(
                        icon: Icons.people_outline_rounded,
                        label: 'Customer & Supplier',
                      ),
                      const SizedBox(height: 16),
                      const _WelcomeFeatureRow(
                        icon: Icons.query_stats_rounded,
                        label: 'Reports & Analytics',
                      ),
                      const SizedBox(height: 44),
                      FilledButton(
                        onPressed: onGetStarted,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppConfig.brandPrimaryDeep,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeFeatureRow extends StatelessWidget {
  const _WelcomeFeatureRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: 0.92),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 185,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomWavesPainter extends CustomPainter {
  const _BottomWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final backWave = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.77,
        size.width * 0.58,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.91,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, backWave);

    final frontWave = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.90)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.96,
        size.width * 0.68,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.84,
        size.width,
        size.height * 0.90,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, frontWave);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

