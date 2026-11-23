import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/utils/formatters.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/inventory/presentation/inventory_tab.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({
    super.key,
    required this.store,
  });

  final PharmacyStoreController store;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddCustomerSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final symbol = widget.store.session.currencySymbol;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SingleChildScrollView(
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
                'Add New Customer',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Mahmudul Hasan',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 01715-000111',
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                backgroundColor: AppConfig.brandSoftLight,
                borderColor: Colors.transparent,
                elevated: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: AppConfig.brandPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Due balance starts at ${symbol}0 and calculates automatically from credit sales & payments.',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: AppConfig.inkPrimaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty || phone.isEmpty) {
                    return;
                  }
                  widget.store.addCustomer(name: name, phone: phone);
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Save Customer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCustomerActionSheet(CrmCustomer customer) {
    final liveDue = widget.store.dueForCustomer(customer.id);
    final ledger = widget.store.ledgerForCustomer(customer.id);
    final collectCtrl = TextEditingController(
      text: liveDue > 0 ? liveDue.toStringAsFixed(0) : '',
    );
    final symbol = widget.store.session.currencySymbol;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SingleChildScrollView(
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppConfig.brandSoftLight,
                    child: Text(
                      Formatters.initials(customer.name),
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
                          customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${customer.phone} • ${customer.loyaltyPoints} pts',
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                backgroundColor: liveDue > 0
                    ? AppConfig.roseSoftLight
                    : AppConfig.brandSoftLight,
                borderColor: Colors.transparent,
                elevated: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outstanding Due',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppConfig.inkPrimaryLight,
                            ),
                          ),
                          Text(
                            'Auto-calculated from ledger',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                      color: AppConfig.inkSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      Formatters.currency(
                        liveDue,
                        symbol: symbol,
                        decimals: liveDue % 1 == 0 ? 0 : 2,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: liveDue > 0
                            ? AppConfig.rose
                            : AppConfig.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (ledger.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Due & Payment Ledger',
                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                ...ledger.take(4).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _LedgerEntryCard(
                          title: entry.title,
                          dateLabel: entry.dateLabel,
                          signedAmount:
                              '${entry.type == CustomerLedgerType.creditSale ? '+' : '-'}${Formatters.currency(entry.amount, symbol: symbol)}',
                          amountColor:
                              entry.type == CustomerLedgerType.creditSale
                                  ? AppConfig.rose
                                  : AppConfig.brandPrimary,
                        ),
                      ),
                    ),
              ],
              if (liveDue > 0) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: collectCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Collection Amount ($symbol)',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    final amount = double.tryParse(collectCtrl.text.trim()) ?? 0;
                    if (amount <= 0) {
                      return;
                    }
                    final applied = widget.store.collectCustomerDue(
                      customer.id,
                      amount,
                    );
                    Navigator.of(ctx).pop();
                    if (applied > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Collected ${Formatters.currency(applied, symbol: symbol)} from ${customer.name}.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Receive Due Payment'),
                ),
                const SizedBox(height: 8),
              ] else
                const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  widget.store.setSelectedCustomer(customer);
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selected ${customer.name} for active POS checkout.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.point_of_sale_rounded),
                label: const Text('Attach to Active POS Bill'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final symbol = store.session.currencySymbol;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final q = _query.trim().toLowerCase();
        final filtered = store.customers.where((c) {
          if (q.isEmpty) {
            return true;
          }
          return c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customers',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  store.session.tenantName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Add Customer',
                onPressed: _openAddCustomerSheet,
                icon: const Icon(Icons.person_add_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddCustomerSheet,
            backgroundColor: AppConfig.brandPrimary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Customer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search customer by name or phone...',
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
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matching customers found.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 92),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final c = filtered[index];
                          final due = store.dueForCustomer(c.id);
                          final hasDue = due > 0;
                          return SurfaceCard(
                            onTap: () => _openCustomerActionSheet(c),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  backgroundColor: AppConfig.brandSoftLight,
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppConfig.brandPrimary,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.phone,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Due: ${Formatters.currency(due, symbol: symbol, decimals: due % 1 == 0 ? 0 : 2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: hasDue
                                        ? AppConfig.rose
                                        : AppConfig.brandPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({
    super.key,
    required this.store,
  });

  final PharmacyStoreController store;

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddSupplierSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final symbol = widget.store.session.currencySymbol;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SingleChildScrollView(
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
                'Add New Supplier',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Company / Supplier Name',
                  hintText: 'e.g. Incepta Pharmaceuticals',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  hintText: 'e.g. +880 1711-000222',
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                backgroundColor: AppConfig.brandSoftLight,
                borderColor: Colors.transparent,
                elevated: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: AppConfig.brandPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payable starts at ${symbol}0 and updates automatically from purchase bills, payments & expiry returns.',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: AppConfig.inkPrimaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty || phone.isEmpty) {
                    return;
                  }
                  widget.store.addSupplier(name: name, contactPhone: phone);
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Save Supplier'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSupplierActionSheet(SupplierAccount supplier) {
    final initialDue = widget.store.dueForSupplier(supplier.id);
    final initialAdvance = widget.store.advanceCreditForSupplier(supplier.id);
    final payCtrl = TextEditingController(
      text: initialDue > 0 ? initialDue.toStringAsFixed(0) : '',
    );
    final refundCtrl = TextEditingController(
      text: initialAdvance > 0 ? initialAdvance.toStringAsFixed(0) : '',
    );
    final symbol = widget.store.session.currencySymbol;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: widget.store,
          builder: (ctx, _) {
            final liveDue = widget.store.dueForSupplier(supplier.id);
            final liveAdvance =
                widget.store.advanceCreditForSupplier(supplier.id);
            final ledger = widget.store.ledgerForSupplier(supplier.id);
            final purchased = widget.store.supplierTotalPurchased(supplier.id);
            final paid = widget.store.supplierTotalPaid(supplier.id);
            final returned =
                widget.store.supplierTotalExpiryReturned(supplier.id);

            return SingleChildScrollView(
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
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppConfig.blueSoftLight,
                        child: Icon(
                          Icons.local_shipping_outlined,
                          color: AppConfig.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplier.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${supplier.contactPhone} • Last order ${supplier.lastOrderLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(ctx).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SurfaceCard(
                    backgroundColor: liveDue > 0
                        ? AppConfig.roseSoftLight
                        : AppConfig.brandSoftLight,
                    borderColor: Colors.transparent,
                    elevated: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Supplier Payable',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppConfig.inkPrimaryLight,
                                ),
                              ),
                              Text(
                                'Auto-calculated from ledger',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(ctx)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppConfig.inkSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          Formatters.currency(
                            liveDue,
                            symbol: symbol,
                            decimals: liveDue % 1 == 0 ? 0 : 2,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: liveDue > 0
                                ? AppConfig.rose
                                : AppConfig.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (liveAdvance > 0) ...[
                    const SizedBox(height: 8),
                    SurfaceCard(
                      backgroundColor: AppConfig.blueSoftLight,
                      borderColor: Colors.transparent,
                      elevated: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.assignment_return_outlined,
                            size: 18,
                            color: AppConfig.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Company Advance Return Credit: ${Formatters.currency(liveAdvance, symbol: symbol, decimals: liveAdvance % 1 == 0 ? 0 : 2)} • Auto-deducts from next purchase',
                              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                    color: AppConfig.inkPrimaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactStatBox(
                          label: 'Purchased',
                          value: Formatters.currency(purchased, symbol: symbol),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactStatBox(
                          label: 'Paid',
                          value: Formatters.currency(paid, symbol: symbol),
                          valueColor: AppConfig.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactStatBox(
                          label: 'Exp. Return',
                          value: Formatters.currency(returned, symbol: symbol),
                          valueColor: AppConfig.blue,
                        ),
                      ),
                    ],
                  ),
                  if (ledger.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Purchase, Payment & Expiry Ledger',
                      style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...ledger.take(5).map((entry) {
                      final isDebit = entry.type ==
                              SupplierLedgerType.purchaseBill ||
                          entry.type == SupplierLedgerType.creditRefundSettled;
                      final sign = isDebit ? '+' : '-';
                      final color = switch (entry.type) {
                        SupplierLedgerType.purchaseBill => AppConfig.rose,
                        SupplierLedgerType.supplierPayment =>
                          AppConfig.brandPrimary,
                        SupplierLedgerType.expiryReturnCredit => AppConfig.blue,
                        SupplierLedgerType.creditRefundSettled =>
                          AppConfig.amber,
                      };
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _LedgerEntryCard(
                          title: entry.title,
                          dateLabel: entry.dateLabel,
                          signedAmount:
                              '$sign${Formatters.currency(entry.amount, symbol: symbol, decimals: entry.amount % 1 == 0 ? 0 : 2)}',
                          amountColor: color,
                        ),
                      );
                    }),
                  ],
                  if (liveDue > 0) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: payCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Payment Amount ($symbol)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () {
                        final amount =
                            double.tryParse(payCtrl.text.trim()) ?? 0;
                        if (amount <= 0) {
                          return;
                        }
                        final applied = widget.store.paySupplierDue(
                          supplier.id,
                          amount,
                        );
                        Navigator.of(ctx).pop();
                        if (applied > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Paid ${Formatters.currency(applied, symbol: symbol)} to ${supplier.name}.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Pay Supplier Due'),
                    ),
                  ],
                  if (liveAdvance > 0) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: refundCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Cash Refund Received ($symbol)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () {
                        final amount =
                            double.tryParse(refundCtrl.text.trim()) ?? 0;
                        if (amount <= 0) {
                          return;
                        }
                        final settled =
                            widget.store.settleSupplierAdvanceCredit(
                          supplier.id,
                          amount,
                        );
                        Navigator.of(ctx).pop();
                        if (settled > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Recorded ${Formatters.currency(settled, symbol: symbol)} cash refund from ${supplier.name}.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.currency_exchange_rounded),
                      label: const Text('Settle Advance Credit (Cash)'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      InventoryTab.showExpiryReturnSheet(
                        context,
                        widget.store,
                        initialSupplierId: supplier.id,
                      );
                    },
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('Return Expired Product to Company'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      InventoryTab.showStockInSheet(
                        context,
                        widget.store,
                        initialSupplierId: supplier.id,
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Receive Stock / Purchase Bill'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final symbol = store.session.currencySymbol;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final q = _query.trim().toLowerCase();
        final filtered = store.suppliers.where((s) {
          if (q.isEmpty) {
            return true;
          }
          return s.name.toLowerCase().contains(q) ||
              s.contactPhone.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suppliers',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  store.session.tenantName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Add Supplier',
                onPressed: _openAddSupplierSheet,
                icon: const Icon(Icons.add_business_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddSupplierSheet,
            backgroundColor: AppConfig.brandPrimary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Supplier',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    SurfaceCard(
                      backgroundColor: AppConfig.roseSoftLight,
                      borderColor: Colors.transparent,
                      elevated: false,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Total Supplier Payable',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppConfig.inkPrimaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Formatters.currency(
                                  store.totalSupplierPayable,
                                  symbol: symbol,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppConfig.rose,
                                ),
                              ),
                            ],
                          ),
                          if (store.totalSupplierAdvanceCredit > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Advance Expiry Return Credit',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppConfig.inkSecondaryLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.currency(
                                    store.totalSupplierAdvanceCredit,
                                    symbol: symbol,
                                    decimals:
                                        store.totalSupplierAdvanceCredit % 1 ==
                                                0
                                            ? 0
                                            : 2,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: AppConfig.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search supplier by name or phone...',
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
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matching suppliers found.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 92),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final sup = filtered[index];
                          final payable = store.dueForSupplier(sup.id);
                          final advance = store.advanceCreditForSupplier(sup.id);
                          final balanceLabel = advance > 0 && payable == 0
                              ? 'Credit: ${Formatters.currency(advance, symbol: symbol, decimals: advance % 1 == 0 ? 0 : 2)}'
                              : Formatters.currency(
                                  payable,
                                  symbol: symbol,
                                  decimals: payable % 1 == 0 ? 0 : 2,
                                );
                          final balanceColor = advance > 0 && payable == 0
                              ? AppConfig.blue
                              : payable > 0
                                  ? AppConfig.rose
                                  : AppConfig.brandPrimary;

                          return SurfaceCard(
                            padding: const EdgeInsets.all(14),
                            onTap: () => _openSupplierActionSheet(sup),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 21,
                                  backgroundColor: AppConfig.blueSoftLight,
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: AppConfig.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sup.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${sup.contactPhone} • Last order ${sup.lastOrderLabel}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  balanceLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: balanceColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  const _LedgerEntryCard({
    required this.title,
    required this.dateLabel,
    required this.signedAmount,
    required this.amountColor,
  });

  final String title;
  final String dateLabel;
  final String signedAmount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      elevated: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            signedAmount,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatBox extends StatelessWidget {
  const _CompactStatBox({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SurfaceCard(
      backgroundColor: isDark ? AppConfig.elevatedDark : AppConfig.canvasLight,
      borderColor: Colors.transparent,
      elevated: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({
    super.key,
    required this.store,
  });

  final PharmacyStoreController store;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  void _openAddExpenseSheet() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    var category = 'Utilities';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                    'Record Branch Expense',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Expense Title',
                      hintText: 'e.g. Generator Fuel',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      'Utilities',
                      'Logistics',
                      'Supplies',
                      'Maintenance',
                      'Staff Welfare',
                    ]
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => category = v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          'Amount (${widget.store.session.currencySymbol})',
                      hintText: '2500',
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final amount =
                          double.tryParse(amountCtrl.text.trim()) ?? 0;
                      if (title.isEmpty || amount <= 0) {
                        return;
                      }
                      widget.store.addExpense(
                        title: title,
                        category: category,
                        amount: amount,
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Save Expense'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final symbol = store.session.currencySymbol;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final total = store.expenses.fold<double>(0, (s, e) => s + e.amount);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenses',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  store.session.branchShortName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddExpenseSheet,
            backgroundColor: AppConfig.brandPrimary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Expense',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
            children: [
              SurfaceCard(
                backgroundColor: AppConfig.amberSoftLight,
                borderColor: Colors.transparent,
                elevated: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recorded Operating Expenses',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppConfig.inkPrimaryLight,
                      ),
                    ),
                    Text(
                      Formatters.currency(total, symbol: symbol),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppConfig.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...store.expenses.map(
                (exp) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppConfig.amberSoftLight,
                          child: const Icon(
                            Icons.receipt_outlined,
                            color: AppConfig.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${exp.category} • ${exp.dateLabel}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.currency(exp.amount, symbol: symbol),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppConfig.amber,
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
      },
    );
  }
}

