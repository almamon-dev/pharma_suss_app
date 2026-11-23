import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/reports/presentation/analytics_screen.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({
    super.key,
    required this.store,
    this.onBackToHome,
  });

  final PharmacyStoreController store;
  final VoidCallback? onBackToHome;

  static void openAnalytics(
    BuildContext context,
    PharmacyStoreController store, {
    String reportTitle = 'Business Overview',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnalyticsScreen(
          store: store,
          reportTitle: reportTitle,
        ),
      ),
    );
  }

  static const List<_ReportMenuEntry> _entries = [
    _ReportMenuEntry(
      title: 'Sales Report',
      icon: Icons.show_chart_rounded,
    ),
    _ReportMenuEntry(
      title: 'Profit & Loss Report',
      icon: Icons.trending_up_rounded,
    ),
    _ReportMenuEntry(
      title: 'Customer Due Report',
      icon: Icons.person_outline_rounded,
    ),
    _ReportMenuEntry(
      title: 'Supplier Payable Report',
      icon: Icons.local_shipping_outlined,
    ),
    _ReportMenuEntry(
      title: 'Inventory Valuation',
      icon: Icons.inventory_2_outlined,
    ),
    _ReportMenuEntry(
      title: 'Expiry Report',
      icon: Icons.verified_user_outlined,
    ),
    _ReportMenuEntry(
      title: 'Medicine Demand Report',
      icon: Icons.analytics_outlined,
    ),
    _ReportMenuEntry(
      title: 'Branch Performance',
      icon: Icons.bar_chart_rounded,
    ),
    _ReportMenuEntry(
      title: 'Expense Report',
      icon: Icons.receipt_long_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Header matching Screen 9
        Container(
          color: isDark ? AppConfig.cardDark : Colors.white,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back to Home',
                    onPressed: onBackToHome,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reports',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          store.session.tenantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Business Analytics',
                    onPressed: () => openAnalytics(context, store),
                    icon: const Icon(Icons.person_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            itemCount: _entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return MenuTileCard(
                icon: entry.icon,
                title: entry.title,
                onTap: () => openAnalytics(
                  context,
                  store,
                  reportTitle: entry.title,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReportMenuEntry {
  const _ReportMenuEntry({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

