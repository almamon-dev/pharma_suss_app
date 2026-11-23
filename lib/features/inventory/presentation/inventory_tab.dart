import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/utils/formatters.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class InventoryTab extends StatelessWidget {
  const InventoryTab({
    super.key,
    required this.store,
    this.onBackToHome,
  });

  final PharmacyStoreController store;
  final VoidCallback? onBackToHome;

  static void showMedicineListSheet(
    BuildContext context,
    PharmacyStoreController store, {
    bool onlyLowStock = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _MedicineListSheet(
        store: store,
        onlyLowStock: onlyLowStock,
      ),
    );
  }

  static void showBatchSheet(
    BuildContext context,
    PharmacyStoreController store, {
    String title = 'Batch Management (FEFO)',
    bool onlyExpiring = false,
    bool disposalMode = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _BatchListSheet(
        store: store,
        title: title,
        onlyExpiring: onlyExpiring,
        disposalMode: disposalMode,
      ),
    );
  }

  static void showStockInSheet(
    BuildContext context,
    PharmacyStoreController store, {
    int? initialSupplierId,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _StockInSheet(
        store: store,
        initialSupplierId: initialSupplierId,
      ),
    );
  }

  static void showExpiryReturnSheet(
    BuildContext context,
    PharmacyStoreController store, {
    MedicineBatchItem? initialBatch,
    int? initialSupplierId,
    ExpiryReturnMode initialMode = ExpiryReturnMode.adjustDue,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _ExpiryReturnSheet(
        store: store,
        initialBatch: initialBatch,
        initialSupplierId: initialSupplierId,
        initialMode: initialMode,
      ),
    );
  }

  static void showStockTransferSheet(
    BuildContext context,
    PharmacyStoreController store,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _StockTransferSheet(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final batches = store.branchBatches;
    final lowStockCount = store.lowStockMedicines.length;
    final expiringCount = store.expiringSoonBatches.length;

    return Column(
      children: [
        // Top Header matching Screen 7
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
                          'Inventory',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          store.session.branchShortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Search Medicines',
                    onPressed: () => showMedicineListSheet(context, store),
                    icon: const Icon(Icons.search_rounded),
                  ),
                  IconButton(
                    tooltip: 'Filter Low Stock & Expiring',
                    onPressed: () => showMedicineListSheet(
                      context,
                      store,
                      onlyLowStock: true,
                    ),
                    icon: const Icon(Icons.filter_alt_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              // 2x2 Summary KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _InventorySummaryCard(
                      label: 'Total Items',
                      value: '${store.medicines.length}',
                      backgroundColor: isDark
                          ? AppConfig.brandSoftDark
                          : const Color(0xFFEEFBF3),
                      onTap: () => showMedicineListSheet(context, store),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InventorySummaryCard(
                      label: 'Total Stock',
                      value: _formatInt(store.totalStockUnits),
                      backgroundColor: isDark
                          ? const Color(0xFF0E291D)
                          : const Color(0xFFEAF7F0),
                      onTap: () => showBatchSheet(context, store),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InventorySummaryCard(
                      label: 'Low Stock',
                      value: '$lowStockCount',
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppConfig.rose,
                      backgroundColor: isDark
                          ? const Color(0xFF2B1418)
                          : AppConfig.roseSoftLight,
                      onTap: () => showMedicineListSheet(
                        context,
                        store,
                        onlyLowStock: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InventorySummaryCard(
                      label: 'Expiring Soon',
                      value: '$expiringCount',
                      icon: Icons.hourglass_bottom_rounded,
                      iconColor: AppConfig.amber,
                      backgroundColor: isDark
                          ? const Color(0xFF2C1F0E)
                          : AppConfig.amberSoftLight,
                      onTap: () => showBatchSheet(
                        context,
                        store,
                        title: 'Expiring Soon Batches',
                        onlyExpiring: true,
                        disposalMode: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 6 Menu Tiles matching Screen 7
              MenuTileCard(
                icon: Icons.medication_outlined,
                title: 'Medicine List',
                subtitle:
                    '${store.medicines.length} SKUs tracked • ${Formatters.currency(store.inventoryValuation, symbol: store.session.currencySymbol)} value',
                onTap: () => showMedicineListSheet(context, store),
              ),
              const SizedBox(height: 10),
              MenuTileCard(
                icon: Icons.inventory_2_outlined,
                title: 'Batch Management',
                subtitle: '${batches.length} active FEFO batches',
                onTap: () => showBatchSheet(context, store),
              ),
              const SizedBox(height: 10),
              MenuTileCard(
                icon: Icons.add_circle_outline_rounded,
                title: 'Stock In (Purchase)',
                subtitle: 'Receive supplier delivery & add units',
                onTap: () => showStockInSheet(context, store),
              ),
              const SizedBox(height: 10),
              MenuTileCard(
                icon: Icons.tune_rounded,
                title: 'Stock Adjustment',
                subtitle: 'Reconcile physical count or damage',
                onTap: () => showBatchSheet(
                  context,
                  store,
                  title: 'Stock Adjustment',
                ),
              ),
              const SizedBox(height: 10),
              MenuTileCard(
                icon: Icons.swap_horiz_rounded,
                title: 'Stock Transfer',
                subtitle: 'Move stock between branches & warehouse',
                onTap: () => showStockTransferSheet(context, store),
              ),
              const SizedBox(height: 10),
              MenuTileCard(
                icon: Icons.delete_sweep_outlined,
                iconColor: AppConfig.amber,
                title: 'Expiry & Disposal',
                subtitle: expiringCount > 0
                    ? '$expiringCount batches expiring within 45 days'
                    : 'No urgent expiries in this branch',
                onTap: () => showBatchSheet(
                  context,
                  store,
                  title: 'Expiry & Disposal',
                  onlyExpiring: true,
                  disposalMode: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatInt(int number) {
    final s = number.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final revIdx = s.length - i;
      if (i > 0 && revIdx % 3 == 0) {
        buf.write(',');
      }
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _InventorySummaryCard extends StatelessWidget {
  const _InventorySummaryCard({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      elevated: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: iconColor),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicineListSheet extends StatefulWidget {
  const _MedicineListSheet({
    required this.store,
    this.onlyLowStock = false,
  });

  final PharmacyStoreController store;
  final bool onlyLowStock;

  @override
  State<_MedicineListSheet> createState() => _MedicineListSheetState();
}

class _MedicineListSheetState extends State<_MedicineListSheet> {
  final _searchCtrl = TextEditingController();
  late bool _lowOnly;

  @override
  void initState() {
    super.initState();
    _lowOnly = widget.onlyLowStock;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final query = _searchCtrl.text.trim().toLowerCase();
        final list = store.medicines.where((m) {
          if (_lowOnly && store.stockForMedicine(m.id) > m.reorderLevel) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          return m.name.toLowerCase().contains(query) ||
              m.genericName.toLowerCase().contains(query) ||
              m.sku.toLowerCase().contains(query);
        }).toList();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Medicine List (${list.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          FilterPillChip(
                            label: 'Low Stock Only',
                            selected: _lowOnly,
                            onTap: () => setState(() => _lowOnly = !_lowOnly),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search medicine, generic, or SKU...',
                          isDense: true,
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final m = list[index];
                      final qty = store.stockForMedicine(m.id);
                      final isLow = qty <= m.reorderLevel;
                      return SurfaceCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${m.genericName} • ${m.manufacturer} • ${m.sku}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusPill(
                              label: '$qty ${m.unitLabel}',
                              tone: isLow
                                  ? StatusTone.rose
                                  : StatusTone.emerald,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _BatchListSheet extends StatelessWidget {
  const _BatchListSheet({
    required this.store,
    required this.title,
    this.onlyExpiring = false,
    this.disposalMode = false,
  });

  final PharmacyStoreController store;
  final String title;
  final bool onlyExpiring;
  final bool disposalMode;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list = onlyExpiring
            ? store.expiringSoonBatches
            : store.branchBatches;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${store.session.branchName} • FEFO order',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const SurfaceCard(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text('No matching batches in this branch.'),
                      ),
                    ),
                  )
                else
                  ...list.map((batch) {
                    final med = store.medicineById(batch.medicineId);
                    final sup = store.supplierForBatch(batch);
                    final urgent = batch.daysRemaining <= 30;
                    final symbol = store.session.currencySymbol;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    med?.name ?? 'Medicine #${batch.medicineId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusPill(
                                  label: batch.daysRemaining <= 0
                                      ? 'Expired'
                                      : '${batch.daysRemaining}d left',
                                  tone: urgent
                                      ? StatusTone.rose
                                      : StatusTone.amber,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batch ${batch.batchNumber} • ${batch.rackLocation} • Exp ${batch.expiryLabel}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (disposalMode && sup != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${sup.name} • Cost ${Formatters.currency(batch.costPrice, symbol: symbol, decimals: 2)}/pc',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Available: ${batch.quantityAvailable} pcs',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (!disposalMode) ...[
                                  OutlinedButton(
                                    onPressed: () =>
                                        store.adjustBatchQuantity(batch.id, -10),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(52, 32),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                    ),
                                    child: const Text('-10'),
                                  ),
                                  const SizedBox(width: 6),
                                  FilledButton(
                                    onPressed: () =>
                                        store.adjustBatchQuantity(batch.id, 50),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(64, 32),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: const Text('+50'),
                                  ),
                                ] else
                                  OutlinedButton.icon(
                                    onPressed: batch.quantityAvailable > 0
                                        ? () => InventoryTab.showExpiryReturnSheet(
                                              context,
                                              store,
                                              initialBatch: batch,
                                            )
                                        : null,
                                    icon: const Icon(
                                      Icons.assignment_return_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Return / Dispose'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppConfig.rose,
                                      minimumSize: const Size(124, 34),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}

String _plainInputNumber(double value) {
  final rounded = double.parse(value.toStringAsFixed(2));
  return rounded == rounded.roundToDouble()
      ? rounded.round().toString()
      : rounded.toStringAsFixed(2);
}

class _SheetSummaryRow extends StatelessWidget {
  const _SheetSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            fontSize: bold ? 14 : 13,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StockInSheet extends StatefulWidget {
  const _StockInSheet({
    required this.store,
    this.initialSupplierId,
  });

  final PharmacyStoreController store;
  final int? initialSupplierId;

  @override
  State<_StockInSheet> createState() => _StockInSheetState();
}

class _StockInSheetState extends State<_StockInSheet> {
  int? _selectedBatchId;
  int? _selectedSupplierId;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _paidCtrl;

  @override
  void initState() {
    super.initState();
    final batches = widget.store.branchBatches;
    final initialBatch = _pickInitialBatch(batches);
    _selectedBatchId = initialBatch?.id;
    _selectedSupplierId = widget.initialSupplierId ??
        (initialBatch != null
            ? widget.store.supplierForBatch(initialBatch)?.id
            : widget.store.suppliers.firstOrNull?.id);
    _qtyCtrl = TextEditingController(text: '50');
    _costCtrl = TextEditingController(
      text: initialBatch != null ? _plainInputNumber(initialBatch.costPrice) : '0',
    );
    _paidCtrl = TextEditingController(text: '0');
  }

  MedicineBatchItem? _pickInitialBatch(List<MedicineBatchItem> batches) {
    if (batches.isEmpty) {
      return null;
    }
    if (widget.initialSupplierId != null) {
      for (final b in batches) {
        if (widget.store.supplierForBatch(b)?.id == widget.initialSupplierId) {
          return b;
        }
      }
    }
    return batches.first;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _costCtrl.dispose();
    _paidCtrl.dispose();
    super.dispose();
  }

  void _onBatchSelected(MedicineBatchItem batch) {
    setState(() {
      _selectedBatchId = batch.id;
      _costCtrl.text = _plainInputNumber(batch.costPrice);
      final mappedSupplier = widget.store.supplierForBatch(batch);
      if (mappedSupplier != null) {
        _selectedSupplierId = mappedSupplier.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final batches = widget.store.branchBatches;
    final suppliers = widget.store.suppliers;
    if (batches.isEmpty || suppliers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Need an active batch and supplier to record purchase stock.'),
      );
    }

    final symbol = widget.store.session.currencySymbol;
    final activeBatch = batches.firstWhere(
      (b) => b.id == _selectedBatchId,
      orElse: () => batches.first,
    );
    final activeSupplier = suppliers.firstWhere(
      (s) => s.id == _selectedSupplierId,
      orElse: () => suppliers.first,
    );

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final unitCost = math.max(0.0, double.tryParse(_costCtrl.text.trim()) ?? 0);
    final purchaseTotal = double.parse((qty * unitCost).toStringAsFixed(2));
    final currentDue = widget.store.dueForSupplier(activeSupplier.id);
    final advanceBefore = widget.store.advanceCreditForSupplier(activeSupplier.id);
    final advanceUsed = double.parse(
      math.min(advanceBefore, purchaseTotal).toStringAsFixed(2),
    );
    final netBillAfterCredit = double.parse(
      math.max(0.0, purchaseTotal - advanceUsed).toStringAsFixed(2),
    );
    final rawPaid = math.max(0.0, double.tryParse(_paidCtrl.text.trim()) ?? 0);
    final maxCollectible = double.parse(
      (currentDue + netBillAfterCredit).toStringAsFixed(2),
    );
    final appliedPaid = double.parse(
      math.min(rawPaid, maxCollectible).toStringAsFixed(2),
    );
    final nextDue = double.parse(
      math.max(0.0, currentDue + netBillAfterCredit - appliedPaid).toStringAsFixed(2),
    );
    final remainingAdvance = double.parse(
      math.max(0.0, advanceBefore - purchaseTotal).toStringAsFixed(2),
    );
    final canSubmit = qty > 0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stock In (Purchase Receive)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Updates ${widget.store.session.branchShortName} stock & auto-calculates supplier payable',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: activeBatch.id,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Select Medicine Batch'),
            items: batches.map((b) {
              final med = widget.store.medicineById(b.medicineId);
              return DropdownMenuItem<int>(
                value: b.id,
                child: Text(
                  '${med?.name ?? "Batch"} (${b.batchNumber})',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) {
                return;
              }
              final picked = batches.firstWhere((b) => b.id == v);
              _onBatchSelected(picked);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: activeSupplier.id,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Supplier / Company'),
            items: suppliers.map((s) {
              return DropdownMenuItem<int>(
                value: s.id,
                child: Text(s.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedSupplierId = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [20, 50, 100, 250].map((presetQty) {
              return FilterPillChip(
                label: '+$presetQty pcs',
                selected: qty == presetQty,
                onTap: () => setState(() {
                  _qtyCtrl.text = '$presetQty';
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Qty (pcs)',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _costCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Unit Cost ($symbol)',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paidCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Paid Now ($symbol) • Rest adds to Payable',
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              FilterPillChip(
                label: '${symbol}0 (Credit)',
                selected: rawPaid == 0,
                onTap: () => setState(() => _paidCtrl.text = '0'),
              ),
              FilterPillChip(
                label: '50% Bill',
                selected: netBillAfterCredit > 0 &&
                    (rawPaid - (netBillAfterCredit * 0.5)).abs() < 0.05,
                onTap: () => setState(
                  () => _paidCtrl.text =
                      _plainInputNumber(netBillAfterCredit * 0.5),
                ),
              ),
              FilterPillChip(
                label: 'Pay Full Bill',
                selected: netBillAfterCredit > 0 &&
                    (rawPaid - netBillAfterCredit).abs() < 0.05,
                onTap: () => setState(
                  () => _paidCtrl.text = _plainInputNumber(netBillAfterCredit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppConfig.elevatedDark
                : AppConfig.canvasLight,
            borderColor: Colors.transparent,
            elevated: false,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _SheetSummaryRow(
                  label: 'Purchase Total ($qty × $symbol${_plainInputNumber(unitCost)})',
                  value: Formatters.currency(purchaseTotal, symbol: symbol),
                ),
                const SizedBox(height: 5),
                _SheetSummaryRow(
                  label: 'Previous Supplier Payable',
                  value: Formatters.currency(currentDue, symbol: symbol),
                ),
                if (advanceUsed > 0) ...[
                  const SizedBox(height: 5),
                  _SheetSummaryRow(
                    label: 'Advance Return Credit Used (Auto)',
                    value: '-${Formatters.currency(advanceUsed, symbol: symbol)}',
                    valueColor: AppConfig.brandPrimary,
                  ),
                ],
                const SizedBox(height: 5),
                _SheetSummaryRow(
                  label: 'Paid Now',
                  value: Formatters.currency(appliedPaid, symbol: symbol),
                  valueColor: AppConfig.brandPrimary,
                ),
                const Divider(height: 14),
                _SheetSummaryRow(
                  label: 'New Supplier Payable (Auto)',
                  value: Formatters.currency(nextDue, symbol: symbol),
                  valueColor:
                      nextDue > 0 ? AppConfig.rose : AppConfig.brandPrimary,
                  bold: true,
                ),
                if (remainingAdvance > 0) ...[
                  const SizedBox(height: 4),
                  _SheetSummaryRow(
                    label: 'Remaining Advance Credit',
                    value: Formatters.currency(remainingAdvance, symbol: symbol),
                    valueColor: AppConfig.blue,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: canSubmit
                ? () {
                    final receipt = widget.store.receiveSupplierPurchase(
                      batchId: activeBatch.id,
                      supplierId: activeSupplier.id,
                      quantity: qty,
                      unitCost: unitCost,
                      paidNow: appliedPaid,
                    );
                    Navigator.of(context).pop();
                    if (receipt != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Received +$qty pcs (${receipt.referenceNumber}) • ${receipt.supplierName} payable: ${Formatters.currency(receipt.newSupplierPayable, symbol: symbol)}.',
                          ),
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text('Receive +$qty Units • Update Ledger'),
          ),
        ],
      ),
    );
  }
}

class _ExpiryReturnSheet extends StatefulWidget {
  const _ExpiryReturnSheet({
    required this.store,
    this.initialBatch,
    this.initialSupplierId,
    this.initialMode = ExpiryReturnMode.adjustDue,
  });

  final PharmacyStoreController store;
  final MedicineBatchItem? initialBatch;
  final int? initialSupplierId;
  final ExpiryReturnMode initialMode;

  @override
  State<_ExpiryReturnSheet> createState() => _ExpiryReturnSheetState();
}

class _ExpiryReturnSheetState extends State<_ExpiryReturnSheet> {
  int? _selectedBatchId;
  int? _selectedSupplierId;
  late ExpiryReturnMode _mode;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _creditCtrl;
  bool _customCreditEdited = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    final availableBatches = _candidateBatches();
    final initialBatch = widget.initialBatch ?? availableBatches.firstOrNull;
    _selectedBatchId = initialBatch?.id;
    _selectedSupplierId = widget.initialSupplierId ??
        (initialBatch != null
            ? widget.store.supplierForBatch(initialBatch)?.id
            : widget.store.suppliers.firstOrNull?.id);
    final defaultQty = initialBatch != null
        ? math.min(initialBatch.quantityAvailable, 20)
        : 0;
    _qtyCtrl = TextEditingController(
      text: defaultQty > 0 ? '$defaultQty' : '0',
    );
    _creditCtrl = TextEditingController(
      text: initialBatch != null
          ? _plainInputNumber(defaultQty * initialBatch.costPrice)
          : '0',
    );
  }

  List<MedicineBatchItem> _candidateBatches() {
    final available = widget.store.branchBatches
        .where((b) => b.quantityAvailable > 0)
        .toList();
    available.sort((a, b) {
      if (widget.initialSupplierId != null) {
        final aMatch =
            widget.store.supplierForBatch(a)?.id == widget.initialSupplierId;
        final bMatch =
            widget.store.supplierForBatch(b)?.id == widget.initialSupplierId;
        if (aMatch != bMatch) {
          return aMatch ? -1 : 1;
        }
      }
      return a.daysRemaining.compareTo(b.daysRemaining);
    });
    return available;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _creditCtrl.dispose();
    super.dispose();
  }

  void _syncAutoCredit(MedicineBatchItem batch, int qty) {
    if (_customCreditEdited) {
      return;
    }
    _creditCtrl.text = _plainInputNumber(qty * batch.costPrice);
  }

  void _onBatchChanged(MedicineBatchItem batch) {
    final defaultQty = math.min(batch.quantityAvailable, 20);
    setState(() {
      _selectedBatchId = batch.id;
      _customCreditEdited = false;
      _qtyCtrl.text = '$defaultQty';
      _creditCtrl.text = _plainInputNumber(defaultQty * batch.costPrice);
      final mapped = widget.store.supplierForBatch(batch);
      if (mapped != null) {
        _selectedSupplierId = mapped.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableBatches = _candidateBatches();
    if (availableBatches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No available stock batches to return or dispose.'),
      );
    }

    final batch = availableBatches.firstWhere(
      (b) => b.id == _selectedBatchId,
      orElse: () => availableBatches.first,
    );
    final med = widget.store.medicineById(batch.medicineId);
    final suppliers = widget.store.suppliers;
    final activeSupplier = suppliers.isEmpty
        ? null
        : suppliers.firstWhere(
            (s) => s.id == _selectedSupplierId,
            orElse: () =>
                widget.store.supplierForBatch(batch) ?? suppliers.first,
          );

    final symbol = widget.store.session.currencySymbol;
    final maxQty = batch.quantityAvailable;
    final rawQty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final validQty = rawQty.clamp(0, maxQty);
    final autoCreditValue = double.parse(
      (validQty * batch.costPrice).toStringAsFixed(2),
    );
    final creditValue = _mode == ExpiryReturnMode.writeOff
        ? 0.0
        : double.parse(
            math
                .max(0.0, double.tryParse(_creditCtrl.text.trim()) ?? 0)
                .toStringAsFixed(2),
          );

    final currentDue = activeSupplier != null
        ? widget.store.dueForSupplier(activeSupplier.id)
        : 0.0;
    final currentAdvance = activeSupplier != null
        ? widget.store.advanceCreditForSupplier(activeSupplier.id)
        : 0.0;

    final double nextDue;
    final double nextAdvance;
    if (_mode == ExpiryReturnMode.adjustDue && activeSupplier != null) {
      final netBalanceAfter = currentDue - currentAdvance - creditValue;
      nextDue = double.parse(math.max(0.0, netBalanceAfter).toStringAsFixed(2));
      nextAdvance = double.parse(
        math.max(0.0, -netBalanceAfter).toStringAsFixed(2),
      );
    } else {
      nextDue = currentDue;
      nextAdvance = currentAdvance;
    }

    final presets = <int>{
      if (maxQty >= 10) 10,
      if (maxQty >= 25) 25,
      if (maxQty >= 50) 50,
      maxQty,
    }.toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Expired Return & Settlement',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Return expired stock to company to adjust due or recover cash',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          if (widget.initialBatch == null)
            DropdownButtonFormField<int>(
              initialValue: batch.id,
              isExpanded: true,
              decoration:
                  const InputDecoration(labelText: 'Select Batch to Return'),
              items: availableBatches.map((b) {
                final bMed = widget.store.medicineById(b.medicineId);
                return DropdownMenuItem<int>(
                  value: b.id,
                  child: Text(
                    '${bMed?.name ?? "Batch"} (${b.batchNumber} • ${b.quantityAvailable} pcs)',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) {
                  return;
                }
                final picked = availableBatches.firstWhere((b) => b.id == v);
                _onBatchChanged(picked);
              },
            )
          else
            SurfaceCard(
              backgroundColor: AppConfig.amberSoftLight,
              borderColor: Colors.transparent,
              elevated: false,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med?.name ?? 'Batch ${batch.batchNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: AppConfig.inkPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Batch ${batch.batchNumber} • Exp ${batch.expiryLabel} • Available: $maxQty pcs @ $symbol${_plainInputNumber(batch.costPrice)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConfig.inkSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterPillChip(
                label: 'Return • Adjust Due',
                selected: _mode == ExpiryReturnMode.adjustDue,
                onTap: () =>
                    setState(() => _mode = ExpiryReturnMode.adjustDue),
              ),
              FilterPillChip(
                label: 'Return • Cash Refund',
                selected: _mode == ExpiryReturnMode.cashRefund,
                onTap: () =>
                    setState(() => _mode = ExpiryReturnMode.cashRefund),
              ),
              FilterPillChip(
                label: 'Dispose Only',
                selected: _mode == ExpiryReturnMode.writeOff,
                onTap: () =>
                    setState(() => _mode = ExpiryReturnMode.writeOff),
              ),
            ],
          ),
          if (_mode != ExpiryReturnMode.writeOff &&
              activeSupplier != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: activeSupplier.id,
              isExpanded: true,
              decoration:
                  const InputDecoration(labelText: 'Return to Supplier / Company'),
              items: suppliers.map((s) {
                return DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedSupplierId = v),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((preset) {
              return FilterPillChip(
                label: preset == maxQty ? 'All ($maxQty pcs)' : '$preset pcs',
                selected: rawQty == preset,
                onTap: () => setState(() {
                  _qtyCtrl.text = '$preset';
                  _syncAutoCredit(batch, preset);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {
                    final nextQty =
                        (int.tryParse(_qtyCtrl.text.trim()) ?? 0).clamp(0, maxQty);
                    _syncAutoCredit(batch, nextQty);
                  }),
                  decoration: InputDecoration(
                    labelText: 'Return Qty (Max $maxQty)',
                    isDense: true,
                  ),
                ),
              ),
              if (_mode != ExpiryReturnMode.writeOff) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _creditCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {
                      _customCreditEdited = true;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Return Credit ($symbol)',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppConfig.elevatedDark
                : (_mode == ExpiryReturnMode.writeOff
                    ? AppConfig.roseSoftLight
                    : AppConfig.canvasLight),
            borderColor: Colors.transparent,
            elevated: false,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _SheetSummaryRow(
                  label: 'Stock After Removal',
                  value: '$maxQty pcs → ${maxQty - validQty} pcs',
                ),
                if (_mode == ExpiryReturnMode.adjustDue &&
                    activeSupplier != null) ...[
                  const SizedBox(height: 5),
                  _SheetSummaryRow(
                    label: 'Current Supplier Payable',
                    value: Formatters.currency(currentDue, symbol: symbol),
                  ),
                  const SizedBox(height: 5),
                  _SheetSummaryRow(
                    label: 'Expiry Return Deduction',
                    value: '-${Formatters.currency(creditValue, symbol: symbol)}',
                    valueColor: AppConfig.brandPrimary,
                  ),
                  const Divider(height: 14),
                  _SheetSummaryRow(
                    label: 'New Supplier Payable (Auto)',
                    value: Formatters.currency(nextDue, symbol: symbol),
                    valueColor: nextDue > 0
                        ? AppConfig.rose
                        : AppConfig.brandPrimary,
                    bold: true,
                  ),
                  if (nextAdvance > 0) ...[
                    const SizedBox(height: 4),
                    _SheetSummaryRow(
                      label: 'Advance Credit (Next Bill)',
                      value: '+${Formatters.currency(nextAdvance, symbol: symbol)}',
                      valueColor: AppConfig.blue,
                      bold: true,
                    ),
                  ],
                ] else if (_mode == ExpiryReturnMode.cashRefund) ...[
                  const SizedBox(height: 5),
                  _SheetSummaryRow(
                    label: 'Cash Refund Received',
                    value: '+${Formatters.currency(creditValue, symbol: symbol)}',
                    valueColor: AppConfig.brandPrimary,
                    bold: true,
                  ),
                  const SizedBox(height: 5),
                  _SheetSummaryRow(
                    label: 'Supplier Payable',
                    value: '${Formatters.currency(currentDue, symbol: symbol)} (Unchanged)',
                  ),
                ] else ...[
                  const SizedBox(height: 5),
                  _SheetSummaryRow(
                    label: 'Cost Write-Off Value',
                    value: Formatters.currency(autoCreditValue, symbol: symbol),
                    valueColor: AppConfig.rose,
                    bold: true,
                  ),
                  const SizedBox(height: 5),
                  const _SheetSummaryRow(
                    label: 'Supplier Payable',
                    value: 'No company adjustment',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: validQty > 0
                ? () {
                    final result = widget.store.returnOrDisposeExpiredBatch(
                      batchId: batch.id,
                      quantity: validQty,
                      mode: _mode,
                      supplierId: activeSupplier?.id,
                      creditAmount: creditValue,
                    );
                    Navigator.of(context).pop();
                    if (result != null) {
                      final msg = switch (result.mode) {
                        ExpiryReturnMode.adjustDue =>
                          result.advanceCreditAdded > 0
                              ? 'Returned ${result.quantityRemoved} pcs to ${result.supplierName}. Payable ${Formatters.currency(result.newSupplierPayable, symbol: symbol)} • Advance Credit ${Formatters.currency(result.newAdvanceCredit, symbol: symbol)}.'
                              : 'Returned ${result.quantityRemoved} pcs to ${result.supplierName}. Due reduced by ${Formatters.currency(result.dueReduced, symbol: symbol)} → Payable ${Formatters.currency(result.newSupplierPayable, symbol: symbol)}.',
                        ExpiryReturnMode.cashRefund =>
                          'Returned ${result.quantityRemoved} pcs to ${result.supplierName} for ${Formatters.currency(result.creditAmount, symbol: symbol)} cash refund.',
                        ExpiryReturnMode.writeOff =>
                          'Disposed ${result.quantityRemoved} pcs from batch ${result.batchNumber}.',
                      };
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  }
                : null,
            icon: Icon(
              _mode == ExpiryReturnMode.writeOff
                  ? Icons.delete_outline_rounded
                  : Icons.assignment_return_outlined,
            ),
            label: Text(
              _mode == ExpiryReturnMode.writeOff
                  ? 'Confirm Dispose ($validQty pcs)'
                  : 'Confirm Return ($validQty pcs)',
            ),
          ),
        ],
      ),
    );
  }
}

class _StockTransferSheet extends StatefulWidget {
  const _StockTransferSheet({required this.store});

  final PharmacyStoreController store;

  @override
  State<_StockTransferSheet> createState() => _StockTransferSheetState();
}

class _StockTransferSheetState extends State<_StockTransferSheet> {
  int? _targetBranchId;
  int? _selectedBatchId;
  int _qty = 20;

  @override
  Widget build(BuildContext context) {
    final session = widget.store.session;
    final otherBranches = session.currentBranches
        .where((b) => b.id != session.branchId)
        .toList();
    final batches = widget.store.branchBatches;

    if (batches.isEmpty || otherBranches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Need an active batch and another branch to transfer stock.'),
      );
    }

    final targetBranch = otherBranches.firstWhere(
      (b) => b.id == _targetBranchId,
      orElse: () => otherBranches.first,
    );
    final batch = batches.firstWhere(
      (b) => b.id == _selectedBatchId,
      orElse: () => batches.first,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Inter-Branch Stock Transfer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: targetBranch.id,
            decoration: const InputDecoration(labelText: 'Destination Branch'),
            items: otherBranches
                .map(
                  (b) => DropdownMenuItem<int>(
                    value: b.id,
                    child: Text(b.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _targetBranchId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: batch.id,
            decoration: const InputDecoration(labelText: 'Batch to Transfer'),
            items: batches.map((b) {
              final med = widget.store.medicineById(b.medicineId);
              return DropdownMenuItem<int>(
                value: b.id,
                child: Text(
                  '${med?.name ?? "Batch"} (${b.quantityAvailable} pcs)',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedBatchId = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [10, 20, 50].map((q) {
              return FilterPillChip(
                label: '$q pcs',
                selected: _qty == q,
                onTap: () => setState(() => _qty = q),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: batch.quantityAvailable >= _qty
                ? () {
                    widget.store.adjustBatchQuantity(batch.id, -_qty);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Dispatched $_qty pcs (${batch.batchNumber}) to ${targetBranch.name}.',
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: Text('Dispatch $_qty pcs'),
          ),
        ],
      ),
    );
  }
}
