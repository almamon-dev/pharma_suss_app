import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/utils/formatters.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.store,
    required this.onOpenBranchSwitcher,
    required this.onOpenAlerts,
    required this.onOpenPos,
    required this.onOpenInventory,
    required this.onOpenCustomers,
    required this.onOpenSuppliers,
    required this.onOpenPurchase,
    required this.onOpenReports,
    required this.onOpenExpenses,
    required this.onOpenMenu,
  });

  final PharmacyStoreController store;
  final VoidCallback onOpenBranchSwitcher;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenPos;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenCustomers;
  final VoidCallback onOpenSuppliers;
  final VoidCallback onOpenPurchase;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenExpenses;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = store.session;
    final symbol = session.currencySymbol;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Curved Emerald Header matching Screen 5
        Container(
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 22),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onOpenBranchSwitcher,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onOpenBranchSwitcher,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.tenantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  session.branchShortName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.88),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Operational Alerts',
                    onPressed: onOpenAlerts,
                    icon: Badge(
                      isLabelVisible: store.alertCount > 0,
                      backgroundColor: Colors.amberAccent,
                      textColor: Colors.black,
                      label: Text('${store.alertCount}'),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Today's Summary + 2x2 Cards
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's Summary",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Oct 20, 2026',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryMetricTile(
                      value: Formatters.currency(
                        store.todaySalesRevenue,
                        symbol: symbol,
                      ),
                      label: 'Sales Revenue',
                      trend: '+12.5%',
                      icon: Icons.trending_up_rounded,
                      accentColor: AppConfig.brandPrimary,
                      onTap: onOpenReports,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryMetricTile(
                      value: Formatters.currency(
                        store.todayNetProfit,
                        symbol: symbol,
                      ),
                      label: 'Net Profit',
                      trend: '+10.2%',
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppConfig.brandPrimary,
                      onTap: onOpenReports,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryMetricTile(
                      value: Formatters.currency(
                        store.totalCustomerDue,
                        symbol: symbol,
                      ),
                      label: 'Customer Due',
                      icon: Icons.person_outline_rounded,
                      accentColor: AppConfig.blue,
                      onTap: onOpenCustomers,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryMetricTile(
                      value: Formatters.currency(
                        store.totalSupplierPayable,
                        symbol: symbol,
                      ),
                      label: 'Supplier Payable',
                      icon: Icons.receipt_long_outlined,
                      accentColor: AppConfig.rose,
                      onTap: onOpenSuppliers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4x2 Quick Action Tile Grid matching Screen 5
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.88,
                children: [
                  _QuickGridItem(
                    label: 'POS',
                    icon: Icons.point_of_sale_rounded,
                    color: AppConfig.brandPrimary,
                    onTap: onOpenPos,
                  ),
                  _QuickGridItem(
                    label: 'Inventory',
                    icon: Icons.medication_rounded,
                    color: AppConfig.brandPrimary,
                    onTap: onOpenInventory,
                  ),
                  _QuickGridItem(
                    label: 'Customers',
                    icon: Icons.people_outline_rounded,
                    color: AppConfig.brandPrimary,
                    onTap: onOpenCustomers,
                  ),
                  _QuickGridItem(
                    label: 'Suppliers',
                    icon: Icons.local_shipping_outlined,
                    color: AppConfig.brandPrimary,
                    onTap: onOpenSuppliers,
                  ),
                  _QuickGridItem(
                    label: 'Purchase',
                    icon: Icons.shopping_cart_outlined,
                    color: AppConfig.purple,
                    onTap: onOpenPurchase,
                  ),
                  _QuickGridItem(
                    label: 'Reports',
                    icon: Icons.bar_chart_rounded,
                    color: AppConfig.amber,
                    onTap: onOpenReports,
                  ),
                  _QuickGridItem(
                    label: 'Expenses',
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFFEA580C),
                    onTap: onOpenExpenses,
                  ),
                  _QuickGridItem(
                    label: 'More',
                    icon: Icons.more_horiz_rounded,
                    color: const Color(0xFF475569),
                    onTap: onOpenMenu,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  const _SummaryMetricTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.trend,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.all(13),
      borderRadius: 5,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 6),
            StatusPill(
              label: trend!,
              tone: StatusTone.emerald,
              icon: Icons.arrow_upward_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickGridItem extends StatelessWidget {
  const _QuickGridItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tintBg = color.withValues(alpha: isDark ? 0.18 : 0.10);
    final iconFg = isDark ? color.withValues(alpha: 0.95) : color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: Material(
                  color: tintBg,
                  borderRadius: BorderRadius.circular(5),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color.withValues(alpha: isDark ? 0.12 : 0.08),
                    highlightColor: color.withValues(alpha: 0.10),
                    splashColor: color.withValues(alpha: 0.14),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Icon(icon, size: 22, color: iconFg),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
