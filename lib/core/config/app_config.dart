import 'package:material_ui/material_ui.dart';

class AppConfig {
  const AppConfig._();

  static const String appName = 'Pharmacy SaaS';
  static const String appTagline = 'Multi-Tenant Pharmacy Management';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://demo.localhost:8001/api/v1',
  );

  static const String defaultTenantDomain = 'mamon.pharma.com';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Emerald Medical Green brand palette
  static const Color brandPrimary = Color(0xFF0A8749);
  static const Color brandPrimaryDeep = Color(0xFF056636);
  static const Color brandPrimaryBright = Color(0xFF14A85E);
  static const Color brandSoftLight = Color(0xFFE8F7EF);
  static const Color brandSoftDark = Color(0xFF0F2D1E);

  // Semantic & pastel card tones
  static const Color emerald = Color(0xFF0A8749);
  static const Color emeraldSoftLight = Color(0xFFEAF7F0);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueSoftLight = Color(0xFFEEF4FF);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoftLight = Color(0xFFF3EEFF);
  static const Color amber = Color(0xFFD97706);
  static const Color amberSoftLight = Color(0xFFFFF6E8);
  static const Color rose = Color(0xFFDC2626);
  static const Color roseSoftLight = Color(0xFFFEF0F0);

  // Neutrals & surfaces
  static const Color canvasLight = Color(0xFFF5F7FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inkPrimaryLight = Color(0xFF111827);
  static const Color inkSecondaryLight = Color(0xFF6B7280);
  static const Color slateBorderLight = Color(0xFFE5E9F0);

  static const Color canvasDark = Color(0xFF0B0F14);
  static const Color cardDark = Color(0xFF131A22);
  static const Color elevatedDark = Color(0xFF1A232E);
  static const Color inkPrimaryDark = Color(0xFFF8FAFC);
  static const Color inkSecondaryDark = Color(0xFF94A3B8);
  static const Color slateBorderDark = Color(0xFF232E3B);
}
