import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/utils/formatters.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({
    super.key,
    required this.store,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onOpenBusinessSwitcher,
    required this.onOpenBranchSwitcher,
    required this.onOpenCustomers,
    required this.onOpenSuppliers,
    required this.onOpenExpenses,
    required this.onOpenAnalytics,
    required this.onSignOut,
    this.onBackToHome,
  });

  final PharmacyStoreController store;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onOpenBusinessSwitcher;
  final VoidCallback onOpenBranchSwitcher;
  final VoidCallback onOpenCustomers;
  final VoidCallback onOpenSuppliers;
  final VoidCallback onOpenExpenses;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onSignOut;
  final VoidCallback? onBackToHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final session = store.session;

    return Column(
      children: [
        // Top Header
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
                          'Menu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${session.tenantName} • ${session.branchShortName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              // Account Summary Card
              SurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: AppConfig.brandSoftLight,
                      child: Text(
                        Formatters.initials(session.userName),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppConfig.brandPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      label: session.roleLabel,
                      tone: StatusTone.emerald,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(
                title: 'Workspace & Locations',
                subtitle: 'Switch pharmacy business or branch instantly',
              ),
              const SizedBox(height: 8),
              MenuTileCard(
                icon: Icons.storefront_rounded,
                title: 'Switch Business',
                subtitle: '${session.tenantName} (${session.tenantDomain})',
                onTap: onOpenBusinessSwitcher,
              ),
              const SizedBox(height: 8),
              MenuTileCard(
                icon: Icons.location_on_outlined,
                title: 'Switch Branch',
                subtitle: '${session.branchName} • ${session.branchCode}',
                onTap: onOpenBranchSwitcher,
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Operations',
                subtitle: 'CRM, accounts, and business analytics',
              ),
              const SizedBox(height: 8),
              MenuTileCard(
                icon: Icons.people_outline_rounded,
                title: 'Customers',
                subtitle:
                    '${store.customers.length} customers • Due ${Formatters.currency(store.totalCustomerDue, symbol: session.currencySymbol)}',
                onTap: onOpenCustomers,
              ),
              const SizedBox(height: 8),
              MenuTileCard(
                icon: Icons.local_shipping_outlined,
                title: 'Suppliers',
                subtitle:
                    '${store.suppliers.length} suppliers • Payable ${Formatters.currency(store.totalSupplierPayable, symbol: session.currencySymbol)}',
                onTap: onOpenSuppliers,
              ),
              const SizedBox(height: 8),
              MenuTileCard(
                icon: Icons.receipt_long_outlined,
                title: 'Expenses',
                subtitle: '${store.expenses.length} entries recorded',
                onTap: onOpenExpenses,
              ),
              const SizedBox(height: 8),
              MenuTileCard(
                icon: Icons.analytics_outlined,
                title: 'Business Overview & Analytics',
                subtitle: 'Revenue, profit margins & sales trend',
                onTap: onOpenAnalytics,
              ),
              const SizedBox(height: 18),
              // Theme Mode selector
              SurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.palette_outlined,
                          size: 19,
                          color: AppConfig.brandPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Appearance',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (set) {
                          if (set.isNotEmpty) {
                            onThemeModeChanged(set.first);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Collapsed Connection & Sync Details
              SurfaceCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.hub_outlined,
                      color: AppConfig.brandPrimary,
                    ),
                    title: const Text(
                      'Connection & Sync Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      session.apiConnected
                          ? 'Connected to live tenant gateway'
                          : 'Verified Offline-First Workspace',
                      style: theme.textTheme.bodySmall,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    children: [
                      _DiagLine(label: 'Tenant', value: session.tenantDomain),
                      const SizedBox(height: 6),
                      _DiagLine(label: 'License', value: session.licenseNumber),
                      const SizedBox(height: 6),
                      _DiagLine(label: 'Plan', value: session.planName),
                      const SizedBox(height: 6),
                      _DiagLine(label: 'Endpoint', value: AppConfig.apiBaseUrl),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppConfig.rose,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppConfig.rose,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppConfig.rose.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagLine extends StatelessWidget {
  const _DiagLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

