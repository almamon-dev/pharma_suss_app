import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/utils/formatters.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class PosTab extends StatefulWidget {
  const PosTab({
    super.key,
    required this.store,
    this.onBackToHome,
    this.onOpenCustomers,
  });

  final PharmacyStoreController store;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenCustomers;

  @override
  State<PosTab> createState() => _PosTabState();
}

class _PosTabState extends State<PosTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addMedicine(MedicineItem medicine) {
    final added = widget.store.addToCart(medicine, unit: SaleUnit.strip);
    if (!added && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${medicine.name} has insufficient stock in ${widget.store.session.branchShortName}.',
          ),
        ),
      );
    }
  }

  void _openMedicineUnitPicker(MedicineItem medicine) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _MedicineUnitPickerSheet(
        store: widget.store,
        medicine: medicine,
        onConfirm: (unit, qty) {
          final ok = widget.store.setCartLine(medicine, unit: unit, qty: qty);
          Navigator.of(ctx).pop();
          if (!ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${medicine.name} has insufficient stock in ${widget.store.session.branchShortName}.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _openBarcodeSheet() {
    final codeCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Scan or Enter Barcode / SKU',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try 89012345001 (Napa), 89012345003 (Azi), or MED-104 (Seclo)',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: codeCtrl,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Enter EAN barcode or SKU...',
                  prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                ),
                onSubmitted: (value) {
                  Navigator.of(ctx).pop();
                  _lookupAndAddBarcode(value);
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('89012345001 • Napa'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _lookupAndAddBarcode('89012345001');
                    },
                  ),
                  ActionChip(
                    label: const Text('89012345003 • Azi'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _lookupAndAddBarcode('89012345003');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _lookupAndAddBarcode(codeCtrl.text);
                },
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Find & Add to Cart'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _lookupAndAddBarcode(String code) {
    final med = widget.store.findMedicineByBarcode(code);
    if (med == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No medicine matched code "$code".')),
      );
      return;
    }
    _addMedicine(med);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added 1 strip of ${med.name} to cart.')),
    );
  }

  void _openCustomerAndOrdersSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final store = widget.store;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.62,
          minChildSize: 0.4,
          maxChildSize: 0.88,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  'Select POS Customer',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                SurfaceCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  backgroundColor: store.selectedCustomer == null
                      ? AppConfig.brandSoftLight
                      : null,
                  onTap: () {
                    store.setSelectedCustomer(null);
                    Navigator.of(ctx).pop();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Walk-in Customer',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (store.selectedCustomer == null)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppConfig.brandPrimary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...store.customers.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      backgroundColor: store.selectedCustomer?.id == c.id
                          ? AppConfig.brandSoftLight
                          : null,
                      onTap: () {
                        store.setSelectedCustomer(c);
                        Navigator.of(ctx).pop();
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: AppConfig.brandSoftLight,
                            child: Text(
                              Formatters.initials(c.name),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppConfig.brandPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  c.dueAmount > 0
                                      ? '${c.phone} • Due ${Formatters.currency(c.dueAmount, symbol: store.session.currencySymbol)}'
                                      : c.phone,
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (store.selectedCustomer?.id == c.id)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppConfig.brandPrimary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Recent Branch Invoices',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                ...store.branchInvoices.take(3).map(
                  (inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.invoiceNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  '${inv.customerName} • ${inv.paymentMethod} • ${inv.soldAtLabel}',
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Formatters.currency(
                              inv.totalAmount,
                              symbol: store.session.currencySymbol,
                              decimals: 2,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppConfig.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openCheckoutSheet() {
    final store = widget.store;
    if (store.cart.isEmpty) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _PosCheckoutSheet(
        store: store,
        onSaleCompleted: (invoice) {
          Navigator.of(ctx).pop();
          _showReceiptDialog(invoice);
        },
      ),
    );
  }

  void _showReceiptDialog(RecentSaleInvoice invoice) {
    final symbol = widget.store.session.currencySymbol;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppConfig.brandPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sale Completed',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.invoiceNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppConfig.brandPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${invoice.customerName} • ${invoice.paymentMethod}',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const Divider(height: 18),
              ...invoice.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${line.medicineName} (${line.quantity} ${line.unitName})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.currency(
                          line.lineTotal,
                          symbol: symbol,
                          decimals: 2,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.dueAmount > 0 || invoice.previousDueCleared > 0
                          ? 'Invoice Total'
                          : 'Total Paid',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formatters.currency(
                      invoice.totalAmount,
                      symbol: symbol,
                      decimals: 2,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppConfig.brandPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (invoice.dueAmount > 0 ||
                  invoice.previousDueCleared > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Paid Now',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.currency(
                        invoice.totalCashCollected,
                        symbol: symbol,
                        decimals: 2,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                if (invoice.previousDueCleared > 0) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Prev. Due Cleared',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-${Formatters.currency(invoice.previousDueCleared, symbol: symbol, decimals: 2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppConfig.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (invoice.dueAmount > 0) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Due Added (Auto)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.rose,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.currency(
                          invoice.dueAmount,
                          symbol: symbol,
                          decimals: 2,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppConfig.rose,
                        ),
                      ),
                    ],
                  ),
                ],
                if (invoice.remainingCustomerDue != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Remaining Due',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.currency(
                          invoice.remainingCustomerDue!,
                          symbol: symbol,
                          decimals: 2,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: invoice.remainingCustomerDue! > 0
                              ? AppConfig.rose
                              : AppConfig.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final store = widget.store;
    final symbol = store.session.currencySymbol;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final filteredMedicines = store.medicines.where((m) {
      if (_query.trim().isEmpty) {
        return true;
      }
      final q = _query.trim().toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.genericName.toLowerCase().contains(q) ||
          m.barcode.toLowerCase().contains(q) ||
          m.sku.toLowerCase().contains(q);
    }).toList();

    final maxCartListHeight = (screenHeight * 0.19).clamp(62.0, 140.0);

    return Column(
      children: [
        // Top header matching Screen 6
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
                    onPressed: widget.onBackToHome,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POS - New Sale',
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
                    tooltip: store.selectedCustomer?.name ?? 'Customer & Bills',
                    onPressed: _openCustomerAndOrdersSheet,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.person_outline_rounded),
                        if (store.selectedCustomer != null)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppConfig.brandPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Search + Barcode Row
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search medicine (name, barcode, EAN)...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SurfaceCard(
                padding: EdgeInsets.zero,
                borderRadius: 5,
                onTap: _openBarcodeSheet,
                child: const SizedBox(
                  height: 44,
                  width: 44,
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 20,
                    color: AppConfig.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Medicine List
        Expanded(
          child: filteredMedicines.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No medicine found for "$_query".',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                  itemCount: filteredMedicines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final med = filteredMedicines[index];
                    final stock = store.stockForMedicine(med.id);
                    final inCart = store.cartLineFor(med.id);

                    return _MedicineCatalogCard(
                      medicine: med,
                      stockCount: stock,
                      currencySymbol: symbol,
                      inCartQty: inCart?.qty ?? 0,
                      onAdd: () => _addMedicine(med),
                      onOpenPicker: () => _openMedicineUnitPicker(med),
                    );
                  },
                ),
        ),
        // Docked Cart Section matching Screen 6
        if (store.cart.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppConfig.cardDark : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cart (N items) + Clear
                Row(
                  children: [
                    Text(
                      'Cart (${store.cartItemCount} ${store.cartItemCount == 1 ? 'item' : 'items'})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: store.clearCart,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: AppConfig.rose,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxCartListHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: store.cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final line = store.cart[index];
                      return _CartLineTile(
                        line: line,
                        stockCount: store.stockForMedicine(line.medicine.id),
                        symbol: symbol,
                        onDecrement: () =>
                            store.updateCartQty(line.medicine.id, line.qty - 1),
                        onIncrement: () =>
                            store.updateCartQty(line.medicine.id, line.qty + 1),
                        onDelete: () =>
                            store.removeFromCart(line.medicine.id),
                        onSelectUnit: (unit) {
                          if (!store.canUseSaleUnit(line.medicine, unit)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Insufficient stock for 1 ${_saleUnitLabel(unit)} of ${line.medicine.name}.',
                                ),
                              ),
                            );
                            return;
                          }
                          store.changeSaleUnit(line.medicine.id, unit);
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 14),
                _SummaryLine(
                  label: 'Subtotal',
                  value: Formatters.currency(
                    store.cartSubtotal,
                    symbol: symbol,
                    decimals: 2,
                  ),
                ),
                const SizedBox(height: 3),
                GestureDetector(
                  onTap: () {
                    final next = store.discountPercent == 5.0
                        ? 10.0
                        : (store.discountPercent == 10.0 ? 0.0 : 5.0);
                    store.setDiscountPercent(next);
                  },
                  child: _SummaryLine(
                    label:
                        'Discount (${store.discountPercent.toStringAsFixed(0)}%)',
                    value:
                        '-${Formatters.currency(store.cartDiscountAmount, symbol: symbol, decimals: 2)}',
                    valueColor: AppConfig.brandPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.currency(
                        store.cartTotal,
                        symbol: symbol,
                        decimals: 2,
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: _openCheckoutSheet,
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppConfig.cardDark : Colors.white,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: AppConfig.brandPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap + on any medicine to start billing',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openCustomerAndOrdersSheet,
                  child: const Text('Recent Bills'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _saleUnitLabel(SaleUnit unit) {
  return switch (unit) {
    SaleUnit.piece => 'Unit',
    SaleUnit.strip => 'Pata',
    SaleUnit.box => 'Carton',
  };
}

String _saleUnitSubtitle(MedicineItem medicine, SaleUnit unit) {
  return switch (unit) {
    SaleUnit.piece => '1 ${medicine.unitLabel}',
    SaleUnit.strip => '${medicine.unitsPerStrip} ${medicine.unitLabel}',
    SaleUnit.box => '${medicine.unitsPerBox} ${medicine.unitLabel}',
  };
}

class _MedicineCatalogCard extends StatelessWidget {
  const _MedicineCatalogCard({
    required this.medicine,
    required this.stockCount,
    required this.currencySymbol,
    required this.inCartQty,
    required this.onAdd,
    required this.onOpenPicker,
  });

  final MedicineItem medicine;
  final int stockCount;
  final String currencySymbol;
  final int inCartQty;
  final VoidCallback onAdd;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = stockCount <= medicine.reorderLevel;

    return SurfaceCard(
      onTap: onOpenPicker,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: medicine.id.isEven
                  ? AppConfig.blueSoftLight
                  : AppConfig.brandSoftLight,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              medicine.dosageForm == 'Capsule'
                  ? Icons.medication_liquid_rounded
                  : Icons.medication_rounded,
              color: medicine.id.isEven
                  ? AppConfig.blue
                  : AppConfig.brandPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${medicine.genericName} • $stockCount ${medicine.unitLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isLow
                        ? AppConfig.rose
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${Formatters.currency(medicine.sellingPrice, symbol: currencySymbol, decimals: 2)} / ${medicine.unitLabel}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppConfig.brandPrimary,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                height: 32,
                width: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    if (inCartQty > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE047),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.stockCount,
    required this.symbol,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDelete,
    required this.onSelectUnit,
  });

  final CartLine line;
  final int stockCount;
  final String symbol;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;
  final ValueChanged<SaleUnit> onSelectUnit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unitName = _saleUnitLabel(line.saleUnit);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppConfig.brandSoftLight,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: AppConfig.brandPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.medicine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    PopupMenuButton<SaleUnit>(
                      tooltip: 'Select Unit / Pata / Carton',
                      initialValue: line.saleUnit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onSelected: onSelectUnit,
                      itemBuilder: (ctx) => SaleUnit.values.map((unit) {
                        final available =
                            stockCount >= line.medicine.packSize(unit);
                        final isSelected = line.saleUnit == unit;
                        return PopupMenuItem<SaleUnit>(
                          value: unit,
                          enabled: available,
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 17,
                                color: isSelected
                                    ? AppConfig.brandPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_saleUnitLabel(unit)} (${_saleUnitSubtitle(line.medicine, unit)})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Formatters.currency(
                                  line.medicine.unitPrice(unit),
                                  symbol: symbol,
                                  decimals: 2,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: AppConfig.brandPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppConfig.brandSoftDark
                              : AppConfig.brandSoftLight,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              unitName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppConfig.brandPrimary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppConfig.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${line.totalPieces} ${line.medicine.unitLabel} • ${Formatters.currency(line.lineTotal, symbol: symbol, decimals: line.lineTotal % 1 == 0 ? 0 : 2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onDecrement,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(5),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.remove_rounded, size: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '${line.qty}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onIncrement,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(5),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.add_rounded, size: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AppConfig.inkSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineUnitPickerSheet extends StatefulWidget {
  const _MedicineUnitPickerSheet({
    required this.store,
    required this.medicine,
    required this.onConfirm,
  });

  final PharmacyStoreController store;
  final MedicineItem medicine;
  final void Function(SaleUnit unit, int qty) onConfirm;

  @override
  State<_MedicineUnitPickerSheet> createState() =>
      _MedicineUnitPickerSheetState();
}

class _MedicineUnitPickerSheetState extends State<_MedicineUnitPickerSheet> {
  late SaleUnit _selectedUnit;
  late int _qty;

  @override
  void initState() {
    super.initState();
    final existing = widget.store.cartLineFor(widget.medicine.id);
    if (existing != null) {
      _selectedUnit = existing.saleUnit;
      _qty = existing.qty;
    } else {
      _selectedUnit = widget.store.canUseSaleUnit(
        widget.medicine,
        SaleUnit.strip,
      )
          ? SaleUnit.strip
          : SaleUnit.piece;
      _qty = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final med = widget.medicine;
    final symbol = widget.store.session.currencySymbol;
    final available = widget.store.stockForMedicine(med.id);
    final maxForSelected = available ~/ med.packSize(_selectedUnit);
    final safeQty = maxForSelected <= 0 ? 0 : _qty.clamp(1, maxForSelected);
    final totalPieces = safeQty * med.packSize(_selectedUnit);
    final lineTotal = med.unitPrice(_selectedUnit) * safeQty;
    final hasInCart = widget.store.cartLineFor(med.id) != null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            med.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${med.genericName} • Available: $available ${med.unitLabel}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Text(
            'Select Unit (Unit / Pata / Carton)',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final unit in SaleUnit.values) ...[
            Builder(
              builder: (context) {
                final enabled = available >= med.packSize(unit);
                final selected = _selectedUnit == unit;
                final unitPrice = med.unitPrice(unit);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    backgroundColor: selected
                        ? AppConfig.brandSoftLight
                        : null,
                    borderColor: Colors.transparent,
                    elevated: !selected,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    onTap: enabled
                        ? () {
                            setState(() {
                              _selectedUnit = unit;
                              final maxQty = available ~/ med.packSize(unit);
                              if (_qty > maxQty) {
                                _qty = maxQty.clamp(1, maxQty);
                              }
                            });
                          }
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 20,
                          color: selected
                              ? AppConfig.brandPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _saleUnitLabel(unit),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: enabled
                                      ? null
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _saleUnitSubtitle(med, unit),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.currency(
                            unitPrice,
                            symbol: symbol,
                            decimals: 2,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: enabled
                                ? AppConfig.brandPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quantity (${_saleUnitLabel(_selectedUnit)})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppConfig.brandSoftLight,
                borderRadius: BorderRadius.circular(5),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: safeQty > 1
                          ? () => setState(() => _qty = safeQty - 1)
                          : null,
                      icon: const Icon(Icons.remove_rounded, size: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$safeQty',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: safeQty < maxForSelected
                          ? () => setState(() => _qty = safeQty + 1)
                          : null,
                      icon: const Icon(Icons.add_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            backgroundColor: AppConfig.brandSoftLight,
            borderColor: Colors.transparent,
            elevated: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$safeQty ${_saleUnitLabel(_selectedUnit)} ($totalPieces ${med.unitLabel})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Formatters.currency(lineTotal, symbol: symbol, decimals: 2),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppConfig.brandPrimaryDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: safeQty > 0
                ? () => widget.onConfirm(_selectedUnit, safeQty)
                : null,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: Text(hasInCart ? 'Update Cart Item' : 'Add to Cart'),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: secondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _PosCheckoutSheet extends StatefulWidget {
  const _PosCheckoutSheet({
    required this.store,
    required this.onSaleCompleted,
  });

  final PharmacyStoreController store;
  final ValueChanged<RecentSaleInvoice> onSaleCompleted;

  @override
  State<_PosCheckoutSheet> createState() => _PosCheckoutSheetState();
}

class _PosCheckoutSheetState extends State<_PosCheckoutSheet> {
  final _paidCtrl = TextEditingController();

  @override
  void dispose() {
    _paidCtrl.dispose();
    super.dispose();
  }

  double _enteredPaidAmount(double total, bool isDueMode) {
    final text = _paidCtrl.text.trim();
    if (text.isEmpty) {
      return isDueMode ? 0.0 : total;
    }
    return math.max(0.0, double.tryParse(text) ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final symbol = store.session.currencySymbol;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final total = double.parse(store.cartTotal.toStringAsFixed(2));
        final customer = store.selectedCustomer;
        final previousDue = customer != null
            ? store.dueForCustomer(customer.id)
            : 0.0;
        final combinedPayable = double.parse(
          (total + previousDue).toStringAsFixed(2),
        );
        final isDueMode = store.paymentMethod == 'Due';
        final showPaidInput = isDueMode || previousDue > 0;

        final rawEntered = _enteredPaidAmount(total, isDueMode);
        final appliedPaid = showPaidInput
            ? rawEntered.clamp(0.0, combinedPayable)
            : total;
        final paidTowardsBill = math.min(appliedPaid, total);
        final dueAdded = math.max(0.0, total - paidTowardsBill);
        final settledPrevDue = math.min(
          previousDue,
          math.max(0.0, appliedPaid - total),
        );
        final remainingDue = math.max(
          0.0,
          previousDue + dueAdded - settledPrevDue,
        );
        final changeReturn = math.max(0.0, rawEntered - combinedPayable);
        final needsCustomer = dueAdded > 0 && customer == null;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppConfig.brandPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete Sale • ${store.session.branchShortName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Cash', 'Card', 'bKash', 'Due'].map((method) {
                  return FilterPillChip(
                    label: method,
                    selected: store.paymentMethod == method,
                    onTap: () {
                      store.setPaymentMethod(method);
                      if (method == 'Due' || _paidCtrl.text.isNotEmpty) {
                        _paidCtrl.clear();
                      }
                    },
                  );
                }).toList(),
              ),
              if (showPaidInput) ...[
                const SizedBox(height: 12),
                if (needsCustomer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SurfaceCard(
                      backgroundColor: AppConfig.amberSoftLight,
                      borderColor: Colors.transparent,
                      elevated: false,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select customer to record auto due:',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppConfig.inkPrimaryLight,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: store.customers.map((c) {
                              return FilterPillChip(
                                label: c.name,
                                selected: customer?.id == c.id,
                                onTap: () => store.setSelectedCustomer(c),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                TextField(
                  controller: _paidCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: previousDue > 0
                        ? 'Paid Now ($symbol) • Covers Bill + Prev. Due'
                        : 'Paid Now ($symbol) • Optional partial',
                    hintText: isDueMode
                        ? '0 (full bill goes to due)'
                        : '${total.toStringAsFixed(0)} (or higher to clear prev. due)',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (previousDue > 0) ...[
                      FilterPillChip(
                        label:
                            'Today (${Formatters.currency(total, symbol: symbol, decimals: total % 1 == 0 ? 0 : 2)})',
                        selected: (appliedPaid - total).abs() < 0.01,
                        onTap: () {
                          _paidCtrl.text = total.toStringAsFixed(2);
                          setState(() {});
                        },
                      ),
                      FilterPillChip(
                        label:
                            'Pay All (${Formatters.currency(combinedPayable, symbol: symbol, decimals: combinedPayable % 1 == 0 ? 0 : 2)})',
                        selected:
                            (appliedPaid - combinedPayable).abs() < 0.01,
                        onTap: () {
                          _paidCtrl.text = combinedPayable.toStringAsFixed(2);
                          setState(() {});
                        },
                      ),
                    ],
                    if (isDueMode)
                      FilterPillChip(
                        label: '${symbol}0 (Full Due)',
                        selected: appliedPaid == 0,
                        onTap: () {
                          _paidCtrl.text = '0';
                          setState(() {});
                        },
                      ),
                    if (previousDue == 0 && isDueMode)
                      FilterPillChip(
                        label: '50% Paid',
                        selected:
                            (appliedPaid - (total * 0.5)).abs() < 0.01 &&
                                total > 0,
                        onTap: () {
                          _paidCtrl.text = (total * 0.5).toStringAsFixed(2);
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'Discount',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0.0, 5.0, 10.0].map((pct) {
                  return FilterPillChip(
                    label: '${pct.toInt()}%',
                    selected: store.discountPercent == pct,
                    onTap: () => store.setDiscountPercent(pct),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                backgroundColor: AppConfig.brandSoftLight,
                borderColor: Colors.transparent,
                elevated: false,
                child: Column(
                  children: [
                    _SummaryLine(
                      label: 'Customer',
                      value: customer != null ? customer.name : 'Walk-in Customer',
                    ),
                    const SizedBox(height: 6),
                    _SummaryLine(
                      label: 'Subtotal',
                      value: Formatters.currency(
                        store.cartSubtotal,
                        symbol: symbol,
                        decimals: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _SummaryLine(
                      label:
                          'Discount (${store.discountPercent.toStringAsFixed(0)}%)',
                      value:
                          '-${Formatters.currency(store.cartDiscountAmount, symbol: symbol, decimals: 2)}',
                      valueColor: AppConfig.brandPrimary,
                    ),
                    if (previousDue > 0) ...[
                      const SizedBox(height: 4),
                      _SummaryLine(
                        label: 'Previous Due',
                        value: Formatters.currency(
                          previousDue,
                          symbol: symbol,
                          decimals: 2,
                        ),
                        valueColor: AppConfig.rose,
                      ),
                    ],
                    if (showPaidInput) ...[
                      const SizedBox(height: 4),
                      _SummaryLine(
                        label: 'Paid Now',
                        value: Formatters.currency(
                          appliedPaid,
                          symbol: symbol,
                          decimals: 2,
                        ),
                      ),
                      if (settledPrevDue > 0) ...[
                        const SizedBox(height: 4),
                        _SummaryLine(
                          label: 'Cleared Prev. Due (Auto)',
                          value:
                              '-${Formatters.currency(settledPrevDue, symbol: symbol, decimals: 2)}',
                          valueColor: AppConfig.brandPrimary,
                        ),
                      ],
                      if (dueAdded > 0) ...[
                        const SizedBox(height: 4),
                        _SummaryLine(
                          label: 'Auto Due Added',
                          value:
                              '+${Formatters.currency(dueAdded, symbol: symbol, decimals: 2)}',
                          valueColor: AppConfig.rose,
                        ),
                      ],
                      if (customer != null) ...[
                        const SizedBox(height: 4),
                        _SummaryLine(
                          label: 'Remaining Due (Auto)',
                          value: Formatters.currency(
                            remainingDue,
                            symbol: symbol,
                            decimals: 2,
                          ),
                          valueColor: remainingDue > 0
                              ? AppConfig.rose
                              : AppConfig.brandPrimary,
                        ),
                      ],
                      if (changeReturn > 0) ...[
                        const SizedBox(height: 4),
                        _SummaryLine(
                          label: 'Change Return',
                          value: Formatters.currency(
                            changeReturn,
                            symbol: symbol,
                            decimals: 2,
                          ),
                          valueColor: AppConfig.blue,
                        ),
                      ],
                    ],
                    const Divider(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            previousDue > 0
                                ? 'Combined Total'
                                : (isDueMode ? 'Invoice Total' : 'Payable Total'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppConfig.inkPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.currency(
                            previousDue > 0 ? combinedPayable : total,
                            symbol: symbol,
                            decimals: 2,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppConfig.brandPrimaryDeep,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: needsCustomer
                    ? null
                    : () {
                        final invoice = store.completeSale(
                          paidAmount: showPaidInput ? appliedPaid : total,
                        );
                        if (invoice != null) {
                          widget.onSaleCompleted(invoice);
                        }
                      },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  needsCustomer
                      ? 'Select a Customer First'
                      : settledPrevDue > 0
                          ? 'Confirm (${Formatters.currency(appliedPaid, symbol: symbol, decimals: 2)} • Clear Due)'
                          : isDueMode && dueAdded > 0
                              ? 'Confirm Credit Sale (+${Formatters.currency(dueAdded, symbol: symbol, decimals: 2)} Due)'
                              : 'Confirm & Issue Receipt (${Formatters.currency(total, symbol: symbol, decimals: 2)})',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
