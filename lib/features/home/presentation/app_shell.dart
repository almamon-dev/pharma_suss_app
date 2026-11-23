import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/storage/workspace_preferences.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/crm/presentation/crm_screens.dart';
import 'package:pharmacy_saas_mobile/features/home/presentation/home_tab.dart';
import 'package:pharmacy_saas_mobile/features/inventory/presentation/inventory_tab.dart';
import 'package:pharmacy_saas_mobile/features/pos/presentation/pos_tab.dart';
import 'package:pharmacy_saas_mobile/features/reports/presentation/reports_tab.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';
import 'package:pharmacy_saas_mobile/features/workspace/domain/workspace_session.dart';
import 'package:pharmacy_saas_mobile/features/workspace/presentation/menu_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.session,
    required this.preferences,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onSignOut,
  });

  final WorkspaceSession session;
  final WorkspacePreferences preferences;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late PharmacyStoreController _store;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _store = PharmacyStoreController(initialSession: widget.session);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.userEmail != widget.session.userEmail ||
        oldWidget.session.tenantDomain != widget.session.tenantDomain ||
        oldWidget.session.branchId != widget.session.branchId) {
      _store.dispose();
      _store = PharmacyStoreController(initialSession: widget.session);
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  void _openCustomers() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomersScreen(store: _store),
      ),
    );
  }

  void _openSuppliers() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SuppliersScreen(store: _store),
      ),
    );
  }

  void _openExpenses() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpensesScreen(store: _store),
      ),
    );
  }

  void _openBranchSwitcher() {
    final branches = _store.session.currentBranches;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Switch Branch',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _store.session.tenantName,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                ...branches.map((branch) {
                  final selected = branch.id == _store.session.branchId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      backgroundColor:
                          selected ? AppConfig.brandSoftLight : null,
                      onTap: () {
                        _store.switchBranch(branch);
                        widget.preferences.saveBranchId(branch.id);
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          Icon(
                            branch.isHeadOffice
                                ? Icons.store_mall_directory_rounded
                                : Icons.location_on_outlined,
                            color: AppConfig.brandPrimary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppConfig.inkPrimaryLight
                                        : null,
                                  ),
                                ),
                                Text(
                                  '${branch.location} • ${branch.code}',
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppConfig.brandPrimary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openBusinessSwitcher() {
    final workspaces = _store.session.availableWorkspaces;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Switch Pharmacy Business',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                ...workspaces.map((ws) {
                  final selected = ws.domain == _store.session.tenantDomain;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      backgroundColor:
                          selected ? AppConfig.brandSoftLight : null,
                      onTap: () {
                        _store.switchWorkspace(ws);
                        widget.preferences.saveTenantDomain(ws.domain);
                        widget.preferences.saveBranchId(
                          _store.session.branchId,
                        );
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: AppConfig.brandPrimary,
                            child: const Icon(
                              Icons.local_pharmacy_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ws.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppConfig.inkPrimaryLight
                                        : null,
                                  ),
                                ),
                                Text(
                                  '${ws.domain} • ${ws.branches.length} branches',
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppConfig.brandPrimary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAlertsSheet() {
    final lowStock = _store.lowStockMedicines;
    final expiring = _store.expiringSoonBatches;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  'Branch Alerts • ${_store.session.branchShortName}',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                if (lowStock.isEmpty && expiring.isEmpty)
                  const SurfaceCard(
                    child: Text('All stock levels and expiry windows are healthy.'),
                  ),
                ...expiring.map((b) {
                  final med = _store.medicineById(b.medicineId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: AppConfig.amberSoftLight,
                      borderColor: Colors.transparent,
                      elevated: false,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.hourglass_bottom_rounded,
                            color: AppConfig.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${med?.name ?? "Medicine"} (${b.batchNumber})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppConfig.inkPrimaryLight,
                                  ),
                                ),
                                Text(
                                  'Expires in ${b.daysRemaining} days • ${b.quantityAvailable} pcs left',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConfig.inkSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                ...lowStock.map((m) {
                  final qty = _store.stockForMedicine(m.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: AppConfig.roseSoftLight,
                      borderColor: Colors.transparent,
                      elevated: false,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppConfig.rose,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppConfig.inkPrimaryLight,
                                  ),
                                ),
                                Text(
                                  'Low stock: $qty ${m.unitLabel} (reorder at ${m.reorderLevel})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConfig.inkSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() => _selectedIndex = 2);
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Review in Inventory'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final pages = [
          HomeTab(
            store: _store,
            onOpenBranchSwitcher: _openBranchSwitcher,
            onOpenAlerts: _openAlertsSheet,
            onOpenPos: () => setState(() => _selectedIndex = 1),
            onOpenInventory: () => setState(() => _selectedIndex = 2),
            onOpenCustomers: _openCustomers,
            onOpenSuppliers: _openSuppliers,
            onOpenPurchase: () =>
                InventoryTab.showStockInSheet(context, _store),
            onOpenReports: () => setState(() => _selectedIndex = 3),
            onOpenExpenses: _openExpenses,
            onOpenMenu: () => setState(() => _selectedIndex = 4),
          ),
          PosTab(
            store: _store,
            onBackToHome: () => setState(() => _selectedIndex = 0),
            onOpenCustomers: _openCustomers,
          ),
          InventoryTab(
            store: _store,
            onBackToHome: () => setState(() => _selectedIndex = 0),
          ),
          ReportsTab(
            store: _store,
            onBackToHome: () => setState(() => _selectedIndex = 0),
          ),
          MenuTab(
            store: _store,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
            onOpenBusinessSwitcher: _openBusinessSwitcher,
            onOpenBranchSwitcher: _openBranchSwitcher,
            onOpenCustomers: _openCustomers,
            onOpenSuppliers: _openSuppliers,
            onOpenExpenses: _openExpenses,
            onOpenAnalytics: () => ReportsTab.openAnalytics(context, _store),
            onSignOut: widget.onSignOut,
            onBackToHome: () => setState(() => _selectedIndex = 0),
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) =>
                setState(() => _selectedIndex = idx),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _store.cartItemCount > 0,
                  label: Text('${_store.cartItemCount}'),
                  backgroundColor: AppConfig.brandPrimary,
                  child: const Icon(Icons.point_of_sale_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: _store.cartItemCount > 0,
                  label: Text('${_store.cartItemCount}'),
                  backgroundColor: AppConfig.brandPrimary,
                  child: const Icon(Icons.point_of_sale_rounded),
                ),
                label: 'POS',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _store.alertCount > 0,
                  label: Text('${_store.alertCount}'),
                  backgroundColor: AppConfig.amber,
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: _store.alertCount > 0,
                  label: Text('${_store.alertCount}'),
                  backgroundColor: AppConfig.amber,
                  child: const Icon(Icons.inventory_2_rounded),
                ),
                label: 'Inventory',
              ),
              const NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: 'Reports',
              ),
              const NavigationDestination(
                icon: Icon(Icons.menu_rounded),
                selectedIcon: Icon(Icons.menu_open_rounded),
                label: 'Menu',
              ),
            ],
          ),
        );
      },
    );
  }
}
