import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pharmacy_saas_mobile/features/workspace/domain/workspace_session.dart';

enum SaleUnit { piece, strip, box }

class MedicineItem {
  const MedicineItem({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.sku,
    required this.barcode,
    required this.dosageForm,
    required this.strength,
    required this.unitLabel,
    required this.unitsPerStrip,
    required this.unitsPerBox,
    required this.sellingPrice,
    required this.boxSellingPrice,
    required this.reorderLevel,
    required this.requiresPrescription,
  });

  final int id;
  final String name;
  final String genericName;
  final String manufacturer;
  final String sku;
  final String barcode;
  final String dosageForm;
  final String strength;
  final String unitLabel;
  final int unitsPerStrip;
  final int unitsPerBox;
  final double sellingPrice;
  final double boxSellingPrice;
  final int reorderLevel;
  final bool requiresPrescription;

  int packSize(SaleUnit unit) {
    switch (unit) {
      case SaleUnit.piece:
        return 1;
      case SaleUnit.strip:
        return math.max(1, unitsPerStrip);
      case SaleUnit.box:
        return math.max(1, unitsPerBox);
    }
  }

  double unitPrice(SaleUnit unit) {
    switch (unit) {
      case SaleUnit.piece:
        return sellingPrice;
      case SaleUnit.strip:
        return double.parse(
          (sellingPrice * packSize(SaleUnit.strip)).toStringAsFixed(2),
        );
      case SaleUnit.box:
        return boxSellingPrice > 0
            ? boxSellingPrice
            : double.parse(
                (sellingPrice * packSize(SaleUnit.box)).toStringAsFixed(2),
              );
    }
  }
}

class MedicineBatchItem {
  const MedicineBatchItem({
    required this.id,
    required this.medicineId,
    required this.branchId,
    required this.batchNumber,
    required this.rackLocation,
    required this.expiryLabel,
    required this.daysRemaining,
    required this.quantityAvailable,
    required this.costPrice,
    this.supplierId,
  });

  final int id;
  final int medicineId;
  final int branchId;
  final String batchNumber;
  final String rackLocation;
  final String expiryLabel;
  final int daysRemaining;
  final int quantityAvailable;
  final double costPrice;
  final int? supplierId;

  MedicineBatchItem copyWith({
    int? quantityAvailable,
    int? branchId,
    int? supplierId,
  }) {
    return MedicineBatchItem(
      id: id,
      medicineId: medicineId,
      branchId: branchId ?? this.branchId,
      batchNumber: batchNumber,
      rackLocation: rackLocation,
      expiryLabel: expiryLabel,
      daysRemaining: daysRemaining,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      costPrice: costPrice,
      supplierId: supplierId ?? this.supplierId,
    );
  }
}

class CrmCustomer {
  const CrmCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.dueAmount,
    required this.loyaltyPoints,
    this.allergies,
  });

  final int id;
  final String name;
  final String phone;
  final double dueAmount;
  final int loyaltyPoints;
  final String? allergies;

  CrmCustomer copyWith({double? dueAmount, int? loyaltyPoints}) {
    return CrmCustomer(
      id: id,
      name: name,
      phone: phone,
      dueAmount: dueAmount ?? this.dueAmount,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      allergies: allergies,
    );
  }
}

class SupplierAccount {
  const SupplierAccount({
    required this.id,
    required this.name,
    required this.contactPhone,
    required this.payableAmount,
    required this.lastOrderLabel,
  });

  final int id;
  final String name;
  final String contactPhone;
  final double payableAmount;
  final String lastOrderLabel;

  SupplierAccount copyWith({
    double? payableAmount,
    String? lastOrderLabel,
  }) {
    return SupplierAccount(
      id: id,
      name: name,
      contactPhone: contactPhone,
      payableAmount: payableAmount ?? this.payableAmount,
      lastOrderLabel: lastOrderLabel ?? this.lastOrderLabel,
    );
  }
}

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dateLabel,
  });

  final int id;
  final String title;
  final String category;
  final double amount;
  final String dateLabel;
}

enum CustomerLedgerType { creditSale, duePayment }

class CustomerLedgerEntry {
  const CustomerLedgerEntry({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.title,
    required this.dateLabel,
    this.referenceNumber,
  });

  final int id;
  final int customerId;
  final CustomerLedgerType type;
  final double amount;
  final String title;
  final String dateLabel;
  final String? referenceNumber;
}

enum SupplierLedgerType {
  purchaseBill,
  supplierPayment,
  expiryReturnCredit,
  creditRefundSettled,
}

enum ExpiryReturnMode { adjustDue, cashRefund, writeOff }

class SupplierLedgerEntry {
  const SupplierLedgerEntry({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    required this.title,
    required this.dateLabel,
    this.referenceNumber,
  });

  final int id;
  final int supplierId;
  final SupplierLedgerType type;
  final double amount;
  final String title;
  final String dateLabel;
  final String? referenceNumber;
}

class SupplierPurchaseReceipt {
  const SupplierPurchaseReceipt({
    required this.referenceNumber,
    required this.supplierName,
    required this.purchaseTotal,
    required this.advanceCreditApplied,
    required this.paidNow,
    required this.changeReturn,
    required this.newSupplierPayable,
    required this.remainingAdvanceCredit,
  });

  final String referenceNumber;
  final String supplierName;
  final double purchaseTotal;
  final double advanceCreditApplied;
  final double paidNow;
  final double changeReturn;
  final double newSupplierPayable;
  final double remainingAdvanceCredit;
}

class ExpiryReturnResult {
  const ExpiryReturnResult({
    required this.batchNumber,
    required this.medicineName,
    required this.quantityRemoved,
    required this.mode,
    required this.creditAmount,
    required this.dueReduced,
    required this.advanceCreditAdded,
    required this.newSupplierPayable,
    required this.newAdvanceCredit,
    this.supplierName,
  });

  final String batchNumber;
  final String medicineName;
  final int quantityRemoved;
  final ExpiryReturnMode mode;
  final double creditAmount;
  final double dueReduced;
  final double advanceCreditAdded;
  final double newSupplierPayable;
  final double newAdvanceCredit;
  final String? supplierName;
}

class InvoiceLineSummary {
  const InvoiceLineSummary({
    required this.medicineName,
    required this.quantity,
    required this.unitName,
    required this.lineTotal,
  });

  final String medicineName;
  final int quantity;
  final String unitName;
  final double lineTotal;
}

class RecentSaleInvoice {
  const RecentSaleInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.cashierName,
    required this.branchCode,
    required this.paymentMethod,
    required this.totalAmount,
    required this.soldAtLabel,
    required this.lines,
    this.customerId,
    double? paidAmount,
    this.dueAmount = 0,
    this.previousDueCleared = 0,
    this.remainingCustomerDue,
  }) : paidAmount = paidAmount ?? totalAmount;

  final int id;
  final String invoiceNumber;
  final String customerName;
  final String cashierName;
  final String branchCode;
  final String paymentMethod;
  final double totalAmount;
  final String soldAtLabel;
  final List<InvoiceLineSummary> lines;
  final int? customerId;
  final double paidAmount;
  final double dueAmount;
  final double previousDueCleared;
  final double? remainingCustomerDue;

  double get totalCashCollected => paidAmount + previousDueCleared;
}

class CartLine {
  const CartLine({
    required this.medicine,
    required this.qty,
    required this.saleUnit,
  });

  final MedicineItem medicine;
  final int qty;
  final SaleUnit saleUnit;

  int get totalPieces => qty * medicine.packSize(saleUnit);

  double get lineTotal => medicine.unitPrice(saleUnit) * qty;

  CartLine copyWith({int? qty, SaleUnit? saleUnit}) {
    return CartLine(
      medicine: medicine,
      qty: qty ?? this.qty,
      saleUnit: saleUnit ?? this.saleUnit,
    );
  }
}

class AnalyticsPeriodData {
  const AnalyticsPeriodData({
    required this.label,
    required this.totalRevenue,
    required this.netProfit,
    required this.purchaseCost,
    required this.expenses,
    required this.xLabels,
    required this.salesPoints,
    required this.profitPoints,
  });

  final String label;
  final double totalRevenue;
  final double netProfit;
  final double purchaseCost;
  final double expenses;
  final List<String> xLabels;
  final List<double> salesPoints;
  final List<double> profitPoints;
}

class PharmacyDirectory {
  const PharmacyDirectory._();

  static const List<DemoAccountPreset> demoAccounts = [
    DemoAccountPreset(
      label: 'Mamon Owner',
      badge: 'Owner',
      email: 'mamon@pharmacy.com',
      password: 'password',
      userName: 'Mamon Hasan',
      roleTitle: 'Store Owner',
    ),
    DemoAccountPreset(
      label: 'Pharmacist',
      badge: 'Rx & Stock',
      email: 'pharmacist@pharmacy.com',
      password: 'password',
      userName: 'Nusrat Jahan',
      roleTitle: 'Pharmacist',
    ),
    DemoAccountPreset(
      label: 'Cashier',
      badge: 'POS',
      email: 'cashier@pharmacy.com',
      password: 'password',
      userName: 'Rafiqul Islam',
      roleTitle: 'POS Cashier',
    ),
    DemoAccountPreset(
      label: 'Manager',
      badge: 'Branch Ops',
      email: 'manager@pharmacy.com',
      password: 'password',
      userName: 'Tariqul Islam',
      roleTitle: 'Branch Manager',
    ),
  ];

  static final List<TenantWorkspace> defaultWorkspaces = [
    const TenantWorkspace(
      id: 1,
      name: 'Mamon Pharmacy',
      domain: 'mamon.pharma.com',
      city: 'Dhaka',
      licenseNumber: 'DGDA-DHK-2026-4418',
      planName: 'Growth Plan',
      branches: [
        BranchInfo(
          id: 1,
          code: 'DHK-01',
          name: 'Main Branch (Head Office)',
          location: 'Dhanmondi, Dhaka',
          isHeadOffice: true,
        ),
        BranchInfo(
          id: 2,
          code: 'DHK-02',
          name: 'Malibagh Branch',
          location: 'Malibagh, Dhaka',
        ),
        BranchInfo(
          id: 3,
          code: 'DHK-03',
          name: 'Uttara Branch',
          location: 'Uttara, Dhaka',
        ),
        BranchInfo(
          id: 4,
          code: 'WH-01',
          name: 'Warehouse',
          location: 'Stock & Distribution',
        ),
      ],
    ),
    const TenantWorkspace(
      id: 2,
      name: 'CarePlus Pharmacy',
      domain: 'careplus.pharma.com',
      city: 'Chattogram',
      licenseNumber: 'DGDA-CTG-2026-8821',
      planName: 'Growth Plan',
      branches: [
        BranchInfo(
          id: 5,
          code: 'CTG-01',
          name: 'GEC Circle Branch (Head Office)',
          location: 'GEC Circle, Chattogram',
          isHeadOffice: true,
        ),
        BranchInfo(
          id: 6,
          code: 'CTG-02',
          name: 'Agrabad Care Point',
          location: 'Agrabad, Chattogram',
        ),
      ],
    ),
    const TenantWorkspace(
      id: 3,
      name: 'City Health Pharmacy',
      domain: 'cityhealth.pharma.com',
      city: 'Sylhet',
      licenseNumber: 'DGDA-SYL-2026-1190',
      planName: 'Starter Plan',
      branches: [
        BranchInfo(
          id: 7,
          code: 'SYL-01',
          name: 'Zindabazar Flagship (Head Office)',
          location: 'Zindabazar, Sylhet',
          isHeadOffice: true,
        ),
      ],
    ),
  ];

  /// Resolves the user profile & accessible businesses automatically from
  /// their email or phone without requiring a domain field on Login.
  static WorkspaceSession resolveSessionForLogin(String rawIdentifier) {
    final normalized = rawIdentifier.trim().toLowerCase();
    final primaryWs = defaultWorkspaces.first;
    final primaryBranch = primaryWs.branches.first;

    switch (normalized) {
      case 'pharmacist@pharmacy.com':
        return WorkspaceSession(
          tenantDomain: primaryWs.domain,
          userEmail: normalized,
          userName: 'Nusrat Jahan, B.Pharm',
          userPhone: '+880 1711-000202',
          roleLabel: 'Pharmacist',
          tenantName: primaryWs.name,
          licenseNumber: primaryWs.licenseNumber,
          planName: primaryWs.planName,
          branchId: primaryBranch.id,
          branchName: primaryBranch.name,
          branchShortName: _shortBranchName(primaryBranch.name),
          branchCode: primaryBranch.code,
          availableWorkspaces: defaultWorkspaces,
        );
      case 'cashier@pharmacy.com':
        return WorkspaceSession(
          tenantDomain: primaryWs.domain,
          userEmail: normalized,
          userName: 'Rafiqul Islam',
          userPhone: '+880 1711-000303',
          roleLabel: 'POS Cashier',
          tenantName: primaryWs.name,
          licenseNumber: primaryWs.licenseNumber,
          planName: primaryWs.planName,
          branchId: primaryBranch.id,
          branchName: primaryBranch.name,
          branchShortName: _shortBranchName(primaryBranch.name),
          branchCode: primaryBranch.code,
          availableWorkspaces: defaultWorkspaces,
        );
      case 'manager@pharmacy.com':
        return WorkspaceSession(
          tenantDomain: primaryWs.domain,
          userEmail: normalized,
          userName: 'Tariqul Islam',
          userPhone: '+880 1711-000155',
          roleLabel: 'Branch Manager',
          tenantName: primaryWs.name,
          licenseNumber: primaryWs.licenseNumber,
          planName: primaryWs.planName,
          branchId: primaryBranch.id,
          branchName: primaryBranch.name,
          branchShortName: _shortBranchName(primaryBranch.name),
          branchCode: primaryBranch.code,
          availableWorkspaces: defaultWorkspaces,
        );
      case 'mamon@pharmacy.com':
        return WorkspaceSession(
          tenantDomain: primaryWs.domain,
          userEmail: normalized,
          userName: 'Mamon Hasan',
          userPhone: '+880 1712-345678',
          roleLabel: 'Store Owner',
          tenantName: primaryWs.name,
          licenseNumber: primaryWs.licenseNumber,
          planName: primaryWs.planName,
          branchId: primaryBranch.id,
          branchName: primaryBranch.name,
          branchShortName: _shortBranchName(primaryBranch.name),
          branchCode: primaryBranch.code,
          availableWorkspaces: defaultWorkspaces,
        );
      default:
        final displayName = normalized.contains('@')
            ? _nameFromEmail(normalized)
            : 'Mamon Pharmacy Staff';
        return WorkspaceSession(
          tenantDomain: primaryWs.domain,
          userEmail: normalized,
          userName: displayName,
          userPhone: '+880 1712-345678',
          roleLabel: 'Store Owner',
          tenantName: primaryWs.name,
          licenseNumber: primaryWs.licenseNumber,
          planName: primaryWs.planName,
          branchId: primaryBranch.id,
          branchName: primaryBranch.name,
          branchShortName: _shortBranchName(primaryBranch.name),
          branchCode: primaryBranch.code,
          availableWorkspaces: defaultWorkspaces,
        );
    }
  }

  static String _shortBranchName(String fullName) {
    final idx = fullName.indexOf('(');
    return (idx > 0 ? fullName.substring(0, idx) : fullName).trim();
  }

  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local
        .split(RegExp(r'[._-]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
        .toList();
    return parts.isEmpty ? 'Pharmacy Member' : parts.join(' ');
  }
}

class PharmacyStoreController extends ChangeNotifier {
  PharmacyStoreController({required WorkspaceSession initialSession})
      : _session = initialSession,
        _medicines = _seedMedicines(),
        _batches = _seedBatches(),
        _customers = _seedCustomers(),
        _customerLedger = _seedCustomerLedger(),
        _suppliers = _seedSuppliers(),
        _supplierLedger = _seedSupplierLedger(),
        _expenses = _seedExpenses(),
        _invoices = _seedInvoices() {
    _syncAllCustomerDues();
    _syncAllSupplierPayables();
  }

  WorkspaceSession _session;
  final List<MedicineItem> _medicines;
  final List<MedicineBatchItem> _batches;
  final List<CrmCustomer> _customers;
  final List<CustomerLedgerEntry> _customerLedger;
  final List<SupplierAccount> _suppliers;
  final List<SupplierLedgerEntry> _supplierLedger;
  final List<ExpenseEntry> _expenses;
  final List<RecentSaleInvoice> _invoices;
  final List<CartLine> _cart = [];

  CrmCustomer? _selectedCustomer;
  double _discountPercent = 5;
  String _paymentMethod = 'Cash';
  int _invoiceSequence = 1048;
  int _ledgerSequence = 10;
  int _supplierLedgerSequence = 20;
  int _purchaseOrderSequence = 925;
  double _sessionExtraSales = 0;
  double _sessionExtraPurchases = 0;

  WorkspaceSession get session => _session;
  List<MedicineItem> get medicines => List.unmodifiable(_medicines);
  List<CrmCustomer> get customers => List.unmodifiable(_customers);
  List<SupplierAccount> get suppliers => List.unmodifiable(_suppliers);
  List<ExpenseEntry> get expenses => List.unmodifiable(_expenses);
  List<CartLine> get cart => List.unmodifiable(_cart);
  CrmCustomer? get selectedCustomer => _selectedCustomer;
  double get discountPercent => _discountPercent;
  String get paymentMethod => _paymentMethod;

  List<CustomerLedgerEntry> ledgerForCustomer(int customerId) => _customerLedger
      .where((entry) => entry.customerId == customerId)
      .toList();

  /// Computes a customer's outstanding due purely from their ledger
  /// transactions (credit/partial invoices minus due payments).
  double dueForCustomer(int customerId) {
    var balance = 0.0;
    for (final entry in _customerLedger) {
      if (entry.customerId != customerId) {
        continue;
      }
      switch (entry.type) {
        case CustomerLedgerType.creditSale:
          balance += entry.amount;
        case CustomerLedgerType.duePayment:
          balance -= entry.amount;
      }
    }
    return double.parse(math.max(0.0, balance).toStringAsFixed(2));
  }

  void _syncCustomerDue(int customerId) {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx < 0) {
      return;
    }
    final computed = dueForCustomer(customerId);
    final updated = _customers[idx].copyWith(dueAmount: computed);
    _customers[idx] = updated;
    if (_selectedCustomer?.id == customerId) {
      _selectedCustomer = updated;
    }
  }

  void _syncAllCustomerDues() {
    for (final customer in List<CrmCustomer>.from(_customers)) {
      _syncCustomerDue(customer.id);
    }
  }

  List<MedicineBatchItem> get branchBatches {
    final filtered = _batches
        .where((b) => b.branchId == _session.branchId)
        .toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return filtered;
  }

  List<RecentSaleInvoice> get branchInvoices =>
      _invoices.where((inv) => inv.branchCode == _session.branchCode).toList();

  int stockForMedicine(int medicineId) {
    var total = 0;
    for (final batch in _batches) {
      if (batch.branchId == _session.branchId &&
          batch.medicineId == medicineId) {
        total += batch.quantityAvailable;
      }
    }
    return total;
  }

  MedicineItem? medicineById(int id) {
    for (final med in _medicines) {
      if (med.id == id) {
        return med;
      }
    }
    return null;
  }

  double get todaySalesRevenue => 125430 + _sessionExtraSales;

  double get todayNetProfit => 34980 + (_sessionExtraSales * 0.24);

  double get totalCustomerDue {
    var sum = 0.0;
    for (final c in _customers) {
      sum += dueForCustomer(c.id);
    }
    return sum;
  }

  List<SupplierLedgerEntry> ledgerForSupplier(int supplierId) => _supplierLedger
      .where((entry) => entry.supplierId == supplierId)
      .toList();

  double _rawSupplierBalance(int supplierId) {
    var balance = 0.0;
    for (final entry in _supplierLedger) {
      if (entry.supplierId != supplierId) {
        continue;
      }
      switch (entry.type) {
        case SupplierLedgerType.purchaseBill:
        case SupplierLedgerType.creditRefundSettled:
          balance += entry.amount;
        case SupplierLedgerType.supplierPayment:
        case SupplierLedgerType.expiryReturnCredit:
          balance -= entry.amount;
      }
    }
    return double.parse(balance.toStringAsFixed(2));
  }

  /// Auto-calculated amount owed to [supplierId] from purchases minus
  /// payments and expired product return credits.
  double dueForSupplier(int supplierId) =>
      double.parse(math.max(0.0, _rawSupplierBalance(supplierId)).toStringAsFixed(2));

  /// Credit held with [supplierId] when expired stock returns exceed due.
  double advanceCreditForSupplier(int supplierId) => double.parse(
        math.max(0.0, -_rawSupplierBalance(supplierId)).toStringAsFixed(2),
      );

  double _sumSupplierLedgerType(int supplierId, SupplierLedgerType type) {
    var total = 0.0;
    for (final entry in _supplierLedger) {
      if (entry.supplierId == supplierId && entry.type == type) {
        total += entry.amount;
      }
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double supplierTotalPurchased(int supplierId) =>
      _sumSupplierLedgerType(supplierId, SupplierLedgerType.purchaseBill);

  double supplierTotalPaid(int supplierId) =>
      _sumSupplierLedgerType(supplierId, SupplierLedgerType.supplierPayment);

  double supplierTotalExpiryReturned(int supplierId) => _sumSupplierLedgerType(
        supplierId,
        SupplierLedgerType.expiryReturnCredit,
      );

  SupplierAccount? supplierById(int id) {
    for (final sup in _suppliers) {
      if (sup.id == id) {
        return sup;
      }
    }
    return null;
  }

  SupplierAccount? supplierForBatch(MedicineBatchItem batch) {
    if (batch.supplierId != null) {
      final matched = supplierById(batch.supplierId!);
      if (matched != null) {
        return matched;
      }
    }
    final med = medicineById(batch.medicineId);
    if (med != null) {
      final token = med.manufacturer.trim().toLowerCase().split(' ').first;
      for (final sup in _suppliers) {
        if (token.isNotEmpty && sup.name.toLowerCase().contains(token)) {
          return sup;
        }
      }
    }
    return _suppliers.isEmpty ? null : _suppliers.first;
  }

  void _syncSupplierPayable(int supplierId, {String? lastOrderLabel}) {
    final idx = _suppliers.indexWhere((s) => s.id == supplierId);
    if (idx < 0) {
      return;
    }
    final computed = dueForSupplier(supplierId);
    _suppliers[idx] = _suppliers[idx].copyWith(
      payableAmount: computed,
      lastOrderLabel: lastOrderLabel,
    );
  }

  void _syncAllSupplierPayables() {
    for (final supplier in List<SupplierAccount>.from(_suppliers)) {
      _syncSupplierPayable(supplier.id);
    }
  }

  double get totalSupplierPayable {
    var sum = 0.0;
    for (final s in _suppliers) {
      sum += dueForSupplier(s.id);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  double get totalSupplierAdvanceCredit {
    var sum = 0.0;
    for (final s in _suppliers) {
      sum += advanceCreditForSupplier(s.id);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  double get inventoryValuation {
    var total = 0.0;
    for (final batch in branchBatches) {
      total += batch.quantityAvailable * batch.costPrice;
    }
    return total;
  }

  int get totalStockUnits {
    var total = 0;
    for (final batch in branchBatches) {
      total += batch.quantityAvailable;
    }
    return total;
  }

  List<MedicineBatchItem> get expiringSoonBatches => branchBatches
      .where((b) => b.quantityAvailable > 0 && b.daysRemaining <= 30)
      .toList();

  List<MedicineItem> get lowStockMedicines =>
      _medicines.where((m) => stockForMedicine(m.id) <= m.reorderLevel).toList();

  int get alertCount => expiringSoonBatches.length + lowStockMedicines.length;

  int get cartItemCount {
    var count = 0;
    for (final line in _cart) {
      count += line.qty;
    }
    return count;
  }

  double get cartSubtotal {
    var sum = 0.0;
    for (final line in _cart) {
      sum += line.lineTotal;
    }
    return sum;
  }

  double get cartDiscountAmount => cartSubtotal * (_discountPercent / 100);

  double get cartTotal => math.max(0, cartSubtotal - cartDiscountAmount);

  CartLine? cartLineFor(int medicineId) {
    for (final line in _cart) {
      if (line.medicine.id == medicineId) {
        return line;
      }
    }
    return null;
  }

  void switchBranch(BranchInfo branch) {
    if (branch.id == _session.branchId) {
      return;
    }
    _cart.clear();
    _session = _session.copyWith(
      branchId: branch.id,
      branchName: branch.name,
      branchShortName: PharmacyDirectory._shortBranchName(branch.name),
      branchCode: branch.code,
    );
    notifyListeners();
  }

  void switchWorkspace(TenantWorkspace workspace) {
    if (workspace.domain == _session.tenantDomain ||
        workspace.branches.isEmpty) {
      return;
    }
    final defaultBranch = workspace.branches.first;
    _cart.clear();
    _session = _session.copyWith(
      tenantDomain: workspace.domain,
      tenantName: workspace.name,
      licenseNumber: workspace.licenseNumber,
      planName: workspace.planName,
      currencySymbol: workspace.currencySymbol,
      branchId: defaultBranch.id,
      branchName: defaultBranch.name,
      branchShortName: PharmacyDirectory._shortBranchName(defaultBranch.name),
      branchCode: defaultBranch.code,
    );
    notifyListeners();
  }

  bool addToCart(MedicineItem medicine, {SaleUnit unit = SaleUnit.strip}) {
    final available = stockForMedicine(medicine.id);
    if (available <= 0) {
      return false;
    }

    final existingIdx = _cart.indexWhere((c) => c.medicine.id == medicine.id);
    if (existingIdx >= 0) {
      final existing = _cart[existingIdx];
      final nextPieces =
          (existing.qty + 1) * medicine.packSize(existing.saleUnit);
      if (nextPieces > available) {
        return false;
      }
      _cart[existingIdx] = existing.copyWith(qty: existing.qty + 1);
      notifyListeners();
      return true;
    }

    var chosenUnit = unit;
    if (medicine.packSize(chosenUnit) > available) {
      chosenUnit = SaleUnit.piece;
    }
    if (medicine.packSize(chosenUnit) > available) {
      return false;
    }

    _cart.add(CartLine(medicine: medicine, qty: 1, saleUnit: chosenUnit));
    notifyListeners();
    return true;
  }

  void updateCartQty(int medicineId, int nextQty) {
    final idx = _cart.indexWhere((c) => c.medicine.id == medicineId);
    if (idx < 0) {
      return;
    }
    if (nextQty <= 0) {
      _cart.removeAt(idx);
      notifyListeners();
      return;
    }
    final line = _cart[idx];
    final available = stockForMedicine(medicineId);
    final neededPieces = nextQty * line.medicine.packSize(line.saleUnit);
    if (neededPieces > available) {
      return;
    }
    _cart[idx] = line.copyWith(qty: nextQty);
    notifyListeners();
  }

  bool canUseSaleUnit(MedicineItem medicine, SaleUnit unit) =>
      stockForMedicine(medicine.id) >= medicine.packSize(unit);

  bool setCartLine(
    MedicineItem medicine, {
    required SaleUnit unit,
    required int qty,
  }) {
    final idx = _cart.indexWhere((c) => c.medicine.id == medicine.id);
    if (qty <= 0) {
      if (idx >= 0) {
        _cart.removeAt(idx);
        notifyListeners();
      }
      return true;
    }

    final available = stockForMedicine(medicine.id);
    final neededPieces = qty * medicine.packSize(unit);
    if (neededPieces > available) {
      return false;
    }

    final nextLine = CartLine(medicine: medicine, qty: qty, saleUnit: unit);
    if (idx >= 0) {
      _cart[idx] = nextLine;
    } else {
      _cart.add(nextLine);
    }
    notifyListeners();
    return true;
  }

  void changeSaleUnit(int medicineId, SaleUnit unit) {
    final idx = _cart.indexWhere((c) => c.medicine.id == medicineId);
    if (idx < 0) {
      return;
    }
    final line = _cart[idx];
    final available = stockForMedicine(medicineId);
    final maxForUnit = available ~/ line.medicine.packSize(unit);
    if (maxForUnit <= 0) {
      return;
    }
    final clampedQty = math.min(line.qty, maxForUnit);
    _cart[idx] = line.copyWith(saleUnit: unit, qty: clampedQty);
    notifyListeners();
  }

  void removeFromCart(int medicineId) {
    _cart.removeWhere((c) => c.medicine.id == medicineId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _selectedCustomer = null;
    notifyListeners();
  }

  void setSelectedCustomer(CrmCustomer? customer) {
    _selectedCustomer = customer;
    if (customer == null && _paymentMethod == 'Due') {
      _paymentMethod = 'Cash';
    }
    notifyListeners();
  }

  void setDiscountPercent(double percent) {
    _discountPercent = percent;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  RecentSaleInvoice? completeSale({double? paidAmount}) {
    if (_cart.isEmpty) {
      return null;
    }

    final total = double.parse(cartTotal.toStringAsFixed(2));
    final previousDue = _selectedCustomer != null
        ? dueForCustomer(_selectedCustomer!.id)
        : 0.0;
    final maxCollectible = double.parse(
      (total + previousDue).toStringAsFixed(2),
    );
    final rawPaid =
        paidAmount ?? (_paymentMethod == 'Due' ? 0.0 : total);
    final totalPaidApplied = double.parse(
      rawPaid.clamp(0.0, maxCollectible).toStringAsFixed(2),
    );

    final paidTowardsBill = double.parse(
      math.min(totalPaidApplied, total).toStringAsFixed(2),
    );
    final invoiceDue = double.parse(
      math.max(0.0, total - paidTowardsBill).toStringAsFixed(2),
    );
    final settledPreviousDue = double.parse(
      math.min(
        previousDue,
        math.max(0.0, totalPaidApplied - total),
      ).toStringAsFixed(2),
    );

    if (invoiceDue > 0 && _selectedCustomer == null) {
      return null;
    }

    final lines = <InvoiceLineSummary>[];
    for (final item in _cart) {
      var remainingToDeduct = item.totalPieces;
      final candidateBatches = _batches
          .asMap()
          .entries
          .where((e) =>
              e.value.branchId == _session.branchId &&
              e.value.medicineId == item.medicine.id &&
              e.value.quantityAvailable > 0)
          .toList()
        ..sort((a, b) => a.value.daysRemaining.compareTo(b.value.daysRemaining));

      for (final entry in candidateBatches) {
        if (remainingToDeduct <= 0) {
          break;
        }
        final batch = entry.value;
        final take = math.min(batch.quantityAvailable, remainingToDeduct);
        _batches[entry.key] = batch.copyWith(
          quantityAvailable: batch.quantityAvailable - take,
        );
        remainingToDeduct -= take;
      }

      lines.add(
        InvoiceLineSummary(
          medicineName: item.medicine.name,
          quantity: item.qty,
          unitName: item.saleUnit.name,
          lineTotal: item.lineTotal,
        ),
      );
    }

    _invoiceSequence += 1;
    final invoiceNumber = 'INV-${_session.branchCode}-$_invoiceSequence';

    double? nextCustomerDue;
    if (_selectedCustomer != null) {
      final customerId = _selectedCustomer!.id;
      if (invoiceDue > 0) {
        _ledgerSequence += 1;
        _customerLedger.insert(
          0,
          CustomerLedgerEntry(
            id: _ledgerSequence,
            customerId: customerId,
            type: CustomerLedgerType.creditSale,
            amount: invoiceDue,
            title: paidTowardsBill > 0
                ? 'Partial due from $invoiceNumber'
                : 'Credit sale $invoiceNumber',
            dateLabel: 'Just now',
            referenceNumber: invoiceNumber,
          ),
        );
      } else if (settledPreviousDue > 0) {
        _ledgerSequence += 1;
        _customerLedger.insert(
          0,
          CustomerLedgerEntry(
            id: _ledgerSequence,
            customerId: customerId,
            type: CustomerLedgerType.duePayment,
            amount: settledPreviousDue,
            title: 'Prev. due cleared via $invoiceNumber',
            dateLabel: 'Just now',
            referenceNumber: invoiceNumber,
          ),
        );
      }
      _syncCustomerDue(customerId);
      nextCustomerDue = dueForCustomer(customerId);
    }

    final methodLabel = settledPreviousDue > 0
        ? '$_paymentMethod + Due Pay'
        : invoiceDue > 0 && paidTowardsBill > 0
            ? 'Partial ($_paymentMethod)'
            : _paymentMethod;

    final invoice = RecentSaleInvoice(
      id: _invoiceSequence,
      invoiceNumber: invoiceNumber,
      customerName: _selectedCustomer?.name ?? 'Walk-in Customer',
      customerId: _selectedCustomer?.id,
      cashierName: _session.userName,
      branchCode: _session.branchCode,
      paymentMethod: methodLabel,
      totalAmount: total,
      paidAmount: paidTowardsBill,
      dueAmount: invoiceDue,
      previousDueCleared: settledPreviousDue,
      remainingCustomerDue: nextCustomerDue,
      soldAtLabel: 'Just now',
      lines: lines,
    );

    _sessionExtraSales += total;
    _invoices.insert(0, invoice);
    _cart.clear();
    _selectedCustomer = null;
    if (_paymentMethod == 'Due') {
      _paymentMethod = 'Cash';
    }
    notifyListeners();
    return invoice;
  }

  void adjustBatchQuantity(int batchId, int delta) {
    final idx = _batches.indexWhere((b) => b.id == batchId);
    if (idx < 0) {
      return;
    }
    final batch = _batches[idx];
    final nextQty = math.max(0, batch.quantityAvailable + delta);
    _batches[idx] = batch.copyWith(quantityAvailable: nextQty);
    notifyListeners();
  }

  /// Creates a new customer with zero opening due; due balance is always
  /// calculated automatically from credit invoices minus due payments.
  void addCustomer({
    required String name,
    required String phone,
  }) {
    final nextId = _customers.isEmpty
        ? 1
        : _customers.map((c) => c.id).reduce(math.max) + 1;
    _customers.insert(
      0,
      CrmCustomer(
        id: nextId,
        name: name.trim(),
        phone: phone.trim(),
        dueAmount: 0,
        loyaltyPoints: 0,
      ),
    );
    notifyListeners();
  }

  double collectCustomerDue(int customerId, double amount) {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx < 0 || amount <= 0) {
      return 0;
    }
    final currentDue = dueForCustomer(customerId);
    final applied = double.parse(
      math.min(amount, currentDue).toStringAsFixed(2),
    );
    if (applied <= 0) {
      return 0;
    }
    _ledgerSequence += 1;
    _customerLedger.insert(
      0,
      CustomerLedgerEntry(
        id: _ledgerSequence,
        customerId: customerId,
        type: CustomerLedgerType.duePayment,
        amount: applied,
        title: 'Due Payment Received',
        dateLabel: 'Just now',
      ),
    );
    _syncCustomerDue(customerId);
    notifyListeners();
    return applied;
  }

  /// Adds a supplier with zero opening balance; payable calculates automatically
  /// from purchase invoices, payments, and expired stock return credits.
  void addSupplier({
    required String name,
    required String contactPhone,
  }) {
    final nextId = _suppliers.isEmpty
        ? 1
        : _suppliers.map((s) => s.id).reduce(math.max) + 1;
    _suppliers.insert(
      0,
      SupplierAccount(
        id: nextId,
        name: name.trim(),
        contactPhone: contactPhone.trim(),
        payableAmount: 0,
        lastOrderLabel: 'New supplier',
      ),
    );
    notifyListeners();
  }

  double paySupplierDue(int supplierId, double amount) {
    final idx = _suppliers.indexWhere((s) => s.id == supplierId);
    if (idx < 0 || amount <= 0) {
      return 0;
    }
    final currentDue = dueForSupplier(supplierId);
    final applied = double.parse(
      math.min(amount, currentDue).toStringAsFixed(2),
    );
    if (applied <= 0) {
      return 0;
    }
    _supplierLedgerSequence += 1;
    _supplierLedger.insert(
      0,
      SupplierLedgerEntry(
        id: _supplierLedgerSequence,
        supplierId: supplierId,
        type: SupplierLedgerType.supplierPayment,
        amount: applied,
        title: 'Supplier Due Payment',
        dateLabel: 'Just now',
      ),
    );
    _syncSupplierPayable(supplierId);
    notifyListeners();
    return applied;
  }

  /// Records a cash refund received from [supplierId] against advance return credit.
  double settleSupplierAdvanceCredit(int supplierId, double amount) {
    final idx = _suppliers.indexWhere((s) => s.id == supplierId);
    if (idx < 0 || amount <= 0) {
      return 0;
    }
    final currentAdvance = advanceCreditForSupplier(supplierId);
    final applied = double.parse(
      math.min(amount, currentAdvance).toStringAsFixed(2),
    );
    if (applied <= 0) {
      return 0;
    }
    _supplierLedgerSequence += 1;
    _supplierLedger.insert(
      0,
      SupplierLedgerEntry(
        id: _supplierLedgerSequence,
        supplierId: supplierId,
        type: SupplierLedgerType.creditRefundSettled,
        amount: applied,
        title: 'Cash Refund Received from Supplier',
        dateLabel: 'Just now',
      ),
    );
    _syncSupplierPayable(supplierId);
    notifyListeners();
    return applied;
  }

  /// Receives stock into [batchId] from [supplierId], automatically offsetting
  /// any advance credit on file before computing the new supplier payable.
  SupplierPurchaseReceipt? receiveSupplierPurchase({
    required int batchId,
    required int supplierId,
    required int quantity,
    required double unitCost,
    double paidNow = 0,
  }) {
    final batchIdx = _batches.indexWhere((b) => b.id == batchId);
    final supplier = supplierById(supplierId);
    if (batchIdx < 0 || supplier == null || quantity <= 0 || unitCost < 0) {
      return null;
    }

    final batch = _batches[batchIdx];
    final med = medicineById(batch.medicineId);
    final purchaseTotal = double.parse(
      (quantity * unitCost).toStringAsFixed(2),
    );
    final advanceBefore = advanceCreditForSupplier(supplierId);
    final advanceUsed = double.parse(
      math.min(advanceBefore, purchaseTotal).toStringAsFixed(2),
    );

    _batches[batchIdx] = batch.copyWith(
      quantityAvailable: batch.quantityAvailable + quantity,
      supplierId: supplierId,
    );

    _purchaseOrderSequence += 1;
    final poRef = 'PO-$_purchaseOrderSequence';

    if (purchaseTotal > 0) {
      _supplierLedgerSequence += 1;
      _supplierLedger.insert(
        0,
        SupplierLedgerEntry(
          id: _supplierLedgerSequence,
          supplierId: supplierId,
          type: SupplierLedgerType.purchaseBill,
          amount: purchaseTotal,
          title:
              'Purchase $poRef • ${med?.name ?? batch.batchNumber} (+$quantity pcs)',
          dateLabel: 'Just now',
          referenceNumber: poRef,
        ),
      );
      _sessionExtraPurchases += purchaseTotal;
    }

    final maxPayable = dueForSupplier(supplierId);
    final cleanPaidInput = math.max(0.0, paidNow);
    final appliedPayment = double.parse(
      math.min(cleanPaidInput, maxPayable).toStringAsFixed(2),
    );
    final changeReturn = double.parse(
      math.max(0.0, cleanPaidInput - appliedPayment).toStringAsFixed(2),
    );

    if (appliedPayment > 0) {
      _supplierLedgerSequence += 1;
      _supplierLedger.insert(
        0,
        SupplierLedgerEntry(
          id: _supplierLedgerSequence,
          supplierId: supplierId,
          type: SupplierLedgerType.supplierPayment,
          amount: appliedPayment,
          title: 'Paid against $poRef',
          dateLabel: 'Just now',
          referenceNumber: poRef,
        ),
      );
    }

    _syncSupplierPayable(supplierId, lastOrderLabel: 'Just now');
    notifyListeners();

    return SupplierPurchaseReceipt(
      referenceNumber: poRef,
      supplierName: supplier.name,
      purchaseTotal: purchaseTotal,
      advanceCreditApplied: advanceUsed,
      paidNow: appliedPayment,
      changeReturn: changeReturn,
      newSupplierPayable: dueForSupplier(supplierId),
      remainingAdvanceCredit: advanceCreditForSupplier(supplierId),
    );
  }

  /// Removes [quantity] pcs from an expiring/expired batch and either adjusts
  /// supplier payable / advance credit, records an immediate cash refund, or
  /// writes off the batch locally without touching supplier accounts.
  ExpiryReturnResult? returnOrDisposeExpiredBatch({
    required int batchId,
    required int quantity,
    required ExpiryReturnMode mode,
    int? supplierId,
    double? creditAmount,
  }) {
    final batchIdx = _batches.indexWhere((b) => b.id == batchId);
    if (batchIdx < 0) {
      return null;
    }
    final batch = _batches[batchIdx];
    if (batch.quantityAvailable <= 0 || quantity <= 0) {
      return null;
    }

    final removedQty = math.min(quantity, batch.quantityAvailable);
    final med = medicineById(batch.medicineId);
    final medName = med?.name ?? 'Batch ${batch.batchNumber}';
    final resolvedCredit = double.parse(
      math
          .max(0.0, creditAmount ?? (removedQty * batch.costPrice))
          .toStringAsFixed(2),
    );

    _batches[batchIdx] = batch.copyWith(
      quantityAvailable: batch.quantityAvailable - removedQty,
    );

    if (mode == ExpiryReturnMode.writeOff) {
      notifyListeners();
      return ExpiryReturnResult(
        batchNumber: batch.batchNumber,
        medicineName: medName,
        quantityRemoved: removedQty,
        mode: mode,
        creditAmount: 0,
        dueReduced: 0,
        advanceCreditAdded: 0,
        newSupplierPayable: 0,
        newAdvanceCredit: 0,
      );
    }

    final targetSupplier =
        (supplierId != null ? supplierById(supplierId) : null) ??
            supplierForBatch(batch);
    if (targetSupplier == null) {
      notifyListeners();
      return ExpiryReturnResult(
        batchNumber: batch.batchNumber,
        medicineName: medName,
        quantityRemoved: removedQty,
        mode: mode,
        creditAmount: 0,
        dueReduced: 0,
        advanceCreditAdded: 0,
        newSupplierPayable: 0,
        newAdvanceCredit: 0,
      );
    }

    final dueBefore = dueForSupplier(targetSupplier.id);
    final advanceBefore = advanceCreditForSupplier(targetSupplier.id);

    if (resolvedCredit > 0) {
      _supplierLedgerSequence += 1;
      final ref = 'EXP-$_supplierLedgerSequence';
      _supplierLedger.insert(
        0,
        SupplierLedgerEntry(
          id: _supplierLedgerSequence,
          supplierId: targetSupplier.id,
          type: SupplierLedgerType.expiryReturnCredit,
          amount: resolvedCredit,
          title: 'Expiry return • $medName (${batch.batchNumber}, $removedQty pcs)',
          dateLabel: 'Just now',
          referenceNumber: ref,
        ),
      );
      if (mode == ExpiryReturnMode.cashRefund) {
        _supplierLedgerSequence += 1;
        _supplierLedger.insert(
          0,
          SupplierLedgerEntry(
            id: _supplierLedgerSequence,
            supplierId: targetSupplier.id,
            type: SupplierLedgerType.creditRefundSettled,
            amount: resolvedCredit,
            title: 'Cash refund • $medName (${batch.batchNumber})',
            dateLabel: 'Just now',
            referenceNumber: ref,
          ),
        );
      }
      _sessionExtraPurchases = math.max(
        0.0,
        _sessionExtraPurchases - resolvedCredit,
      );
    }

    _syncSupplierPayable(targetSupplier.id);
    final dueAfter = dueForSupplier(targetSupplier.id);
    final advanceAfter = advanceCreditForSupplier(targetSupplier.id);
    notifyListeners();

    return ExpiryReturnResult(
      batchNumber: batch.batchNumber,
      medicineName: medName,
      quantityRemoved: removedQty,
      mode: mode,
      creditAmount: resolvedCredit,
      dueReduced: double.parse(
        math.max(0.0, dueBefore - dueAfter).toStringAsFixed(2),
      ),
      advanceCreditAdded: double.parse(
        math.max(0.0, advanceAfter - advanceBefore).toStringAsFixed(2),
      ),
      newSupplierPayable: dueAfter,
      newAdvanceCredit: advanceAfter,
      supplierName: targetSupplier.name,
    );
  }

  void addExpense({
    required String title,
    required String category,
    required double amount,
  }) {
    final nextId = _expenses.isEmpty
        ? 1
        : _expenses.map((e) => e.id).reduce(math.max) + 1;
    _expenses.insert(
      0,
      ExpenseEntry(
        id: nextId,
        title: title.trim(),
        category: category,
        amount: amount,
        dateLabel: 'Today',
      ),
    );
    notifyListeners();
  }

  MedicineItem? findMedicineByBarcode(String barcode) {
    final cleaned = barcode.trim();
    for (final med in _medicines) {
      if (med.barcode == cleaned ||
          med.sku.toLowerCase() == cleaned.toLowerCase()) {
        return med;
      }
    }
    return null;
  }

  AnalyticsPeriodData analyticsForPeriod(String period) {
    switch (period) {
      case 'Last 7 Days':
        return AnalyticsPeriodData(
          label: 'Last 7 Days',
          totalRevenue: 874200 + _sessionExtraSales,
          netProfit: 214500 + (_sessionExtraSales * 0.24),
          purchaseCost: 512000 + _sessionExtraPurchases,
          expenses: 34200,
          xLabels: const ['Oct 12', 'Oct 14', 'Oct 16', 'Oct 18', 'Oct 20'],
          salesPoints: const [95000, 128000, 114000, 152000, 168000],
          profitPoints: const [24000, 31000, 28000, 39000, 44000],
        );
      case 'This Quarter':
        return AnalyticsPeriodData(
          label: 'This Quarter',
          totalRevenue: 11240000 + _sessionExtraSales,
          netProfit: 2680000 + (_sessionExtraSales * 0.24),
          purchaseCost: 6540000 + _sessionExtraPurchases,
          expenses: 428000,
          xLabels: const ['Aug', 'Sep W1', 'Sep W3', 'Oct W1', 'Oct W3'],
          salesPoints: const [220000, 290000, 345000, 410000, 465000],
          profitPoints: const [52000, 74000, 88000, 108000, 126000],
        );
      case 'Last 30 Days':
      default:
        return AnalyticsPeriodData(
          label: 'Last 30 Days',
          totalRevenue: 3742500 + _sessionExtraSales,
          netProfit: 872420 + (_sessionExtraSales * 0.24),
          purchaseCost: 2125000 + _sessionExtraPurchases,
          expenses: 145300,
          xLabels: const ['Sep 20', 'Sep 27', 'Oct 4', 'Oct 11', 'Oct 18'],
          salesPoints: const [
            155000,
            210000,
            238000,
            358000,
            312000,
            378000,
            352000,
            405000,
          ],
          profitPoints: const [
            42000,
            68000,
            72000,
            92000,
            89000,
            116000,
            124000,
            142000,
          ],
        );
    }
  }

  static List<MedicineItem> _seedMedicines() {
    return const [
      MedicineItem(
        id: 1,
        name: 'Napa 500 mg Tab',
        genericName: 'Paracetamol',
        manufacturer: 'Beximco Pharma',
        sku: 'MED-101',
        barcode: '89012345001',
        dosageForm: 'Tablet',
        strength: '500 mg',
        unitLabel: 'pcs',
        unitsPerStrip: 10,
        unitsPerBox: 100,
        sellingPrice: 1.50,
        boxSellingPrice: 145.0,
        reorderLevel: 150,
        requiresPrescription: false,
      ),
      MedicineItem(
        id: 2,
        name: 'Ace 500 mg Tab',
        genericName: 'Paracetamol',
        manufacturer: 'Square Pharma',
        sku: 'MED-102',
        barcode: '89012345002',
        dosageForm: 'Tablet',
        strength: '500 mg',
        unitLabel: 'pcs',
        unitsPerStrip: 10,
        unitsPerBox: 100,
        sellingPrice: 2.00,
        boxSellingPrice: 195.0,
        reorderLevel: 120,
        requiresPrescription: false,
      ),
      MedicineItem(
        id: 3,
        name: 'Azi 500 mg Tab',
        genericName: 'Azithromycin',
        manufacturer: 'Square Pharma',
        sku: 'MED-103',
        barcode: '89012345003',
        dosageForm: 'Tablet',
        strength: '500 mg',
        unitLabel: 'pcs',
        unitsPerStrip: 10,
        unitsPerBox: 30,
        sellingPrice: 15.00,
        boxSellingPrice: 440.0,
        reorderLevel: 80,
        requiresPrescription: true,
      ),
      MedicineItem(
        id: 4,
        name: 'Seclo 20 mg Cap',
        genericName: 'Omeprazole',
        manufacturer: 'Square Pharma',
        sku: 'MED-104',
        barcode: '89012345004',
        dosageForm: 'Capsule',
        strength: '20 mg',
        unitLabel: 'pcs',
        unitsPerStrip: 10,
        unitsPerBox: 120,
        sellingPrice: 6.00,
        boxSellingPrice: 700.0,
        reorderLevel: 100,
        requiresPrescription: false,
      ),
      MedicineItem(
        id: 5,
        name: 'Monas 10 mg Tab',
        genericName: 'Montelukast',
        manufacturer: 'ACME Lab',
        sku: 'MED-105',
        barcode: '89012345005',
        dosageForm: 'Tablet',
        strength: '10 mg',
        unitLabel: 'pcs',
        unitsPerStrip: 10,
        unitsPerBox: 30,
        sellingPrice: 16.00,
        boxSellingPrice: 465.0,
        reorderLevel: 90,
        requiresPrescription: true,
      ),
      MedicineItem(
        id: 6,
        name: 'Sergel 20 mg Cap',
        genericName: 'Esomeprazole',
        manufacturer: 'Healthcare Pharma',
        sku: 'MED-106',
        barcode: '89012345006',
        dosageForm: 'Capsule',
        strength: '20 mg',
        unitLabel: 'pcs',
        unitsPerStrip: 10,
        unitsPerBox: 100,
        sellingPrice: 7.00,
        boxSellingPrice: 680.0,
        reorderLevel: 140,
        requiresPrescription: false,
      ),
    ];
  }

  static List<MedicineBatchItem> _seedBatches() {
    return [
      // Main Branch (branchId: 1)
      const MedicineBatchItem(
        id: 1,
        medicineId: 1,
        branchId: 1,
        supplierId: 1,
        batchNumber: 'NP-2604A',
        rackLocation: 'Rack A-01',
        expiryLabel: '18 Dec 2026',
        daysRemaining: 33,
        quantityAvailable: 640,
        costPrice: 1.15,
      ),
      const MedicineBatchItem(
        id: 2,
        medicineId: 2,
        branchId: 1,
        supplierId: 2,
        batchNumber: 'AC-2601F',
        rackLocation: 'Rack A-03',
        expiryLabel: '22 Nov 2026',
        daysRemaining: 7,
        quantityAvailable: 280,
        costPrice: 1.50,
      ),
      const MedicineBatchItem(
        id: 3,
        medicineId: 3,
        branchId: 1,
        supplierId: 2,
        batchNumber: 'AZ-2602K',
        rackLocation: 'Rack B-02',
        expiryLabel: '03 Dec 2026',
        daysRemaining: 18,
        quantityAvailable: 60,
        costPrice: 11.80,
      ),
      const MedicineBatchItem(
        id: 4,
        medicineId: 4,
        branchId: 1,
        supplierId: 2,
        batchNumber: 'SC-2608C',
        rackLocation: 'Rack B-05',
        expiryLabel: '14 Jun 2027',
        daysRemaining: 211,
        quantityAvailable: 210,
        costPrice: 4.80,
      ),
      const MedicineBatchItem(
        id: 5,
        medicineId: 5,
        branchId: 1,
        supplierId: 4,
        batchNumber: 'MN-2605M',
        rackLocation: 'Rack B-08',
        expiryLabel: '28 Nov 2026',
        daysRemaining: 13,
        quantityAvailable: 75,
        costPrice: 12.40,
      ),
      const MedicineBatchItem(
        id: 6,
        medicineId: 6,
        branchId: 1,
        supplierId: 3,
        batchNumber: 'SG-2609B',
        rackLocation: 'Rack A-09',
        expiryLabel: '20 Aug 2027',
        daysRemaining: 278,
        quantityAvailable: 320,
        costPrice: 5.40,
      ),
      // Other branches (2..7) seeded cleanly so switching branch shows stock
      for (var branchId = 2; branchId <= 7; branchId++) ...[
        MedicineBatchItem(
          id: 10 + branchId * 3,
          medicineId: 1,
          branchId: branchId,
          supplierId: 1,
          batchNumber: 'NP-B$branchId-01',
          rackLocation: 'Rack A-01',
          expiryLabel: '15 May 2027',
          daysRemaining: 181,
          quantityAvailable: 420,
          costPrice: 1.15,
        ),
        MedicineBatchItem(
          id: 11 + branchId * 3,
          medicineId: 2,
          branchId: branchId,
          supplierId: 2,
          batchNumber: 'AC-B$branchId-02',
          rackLocation: 'Rack A-04',
          expiryLabel: '26 Nov 2026',
          daysRemaining: 11,
          quantityAvailable: 95,
          costPrice: 1.50,
        ),
        MedicineBatchItem(
          id: 12 + branchId * 3,
          medicineId: 3,
          branchId: branchId,
          supplierId: 2,
          batchNumber: 'AZ-B$branchId-03',
          rackLocation: 'Rack B-01',
          expiryLabel: '10 Apr 2027',
          daysRemaining: 146,
          quantityAvailable: 140,
          costPrice: 11.80,
        ),
      ],
    ];
  }

  static List<CrmCustomer> _seedCustomers() {
    return [
      const CrmCustomer(
        id: 1,
        name: 'Abdur Rahman',
        phone: '01712-345678',
        dueAmount: 0,
        loyaltyPoints: 420,
      ),
      const CrmCustomer(
        id: 2,
        name: 'Nusrat Jahan',
        phone: '01798-765432',
        dueAmount: 0,
        loyaltyPoints: 890,
        allergies: 'Penicillin / Sulfa drugs',
      ),
      const CrmCustomer(
        id: 3,
        name: 'Karim Medicals',
        phone: '01811-223344',
        dueAmount: 0,
        loyaltyPoints: 1240,
      ),
      const CrmCustomer(
        id: 4,
        name: 'Saiful Islam',
        phone: '01933-556677',
        dueAmount: 0,
        loyaltyPoints: 165,
      ),
    ];
  }

  static List<CustomerLedgerEntry> _seedCustomerLedger() {
    return [
      const CustomerLedgerEntry(
        id: 4,
        customerId: 1,
        type: CustomerLedgerType.duePayment,
        amount: 1000,
        title: 'Due Payment Received',
        dateLabel: 'Oct 19, 2026',
      ),
      const CustomerLedgerEntry(
        id: 3,
        customerId: 1,
        type: CustomerLedgerType.creditSale,
        amount: 6200,
        title: 'Credit sale INV-DHK-01-1041',
        dateLabel: 'Oct 17, 2026',
        referenceNumber: 'INV-DHK-01-1041',
      ),
      const CustomerLedgerEntry(
        id: 2,
        customerId: 3,
        type: CustomerLedgerType.creditSale,
        amount: 12500,
        title: 'Credit sale INV-DHK-01-1038',
        dateLabel: 'Oct 18, 2026',
        referenceNumber: 'INV-DHK-01-1038',
      ),
      const CustomerLedgerEntry(
        id: 1,
        customerId: 4,
        type: CustomerLedgerType.creditSale,
        amount: 1000,
        title: 'Credit sale INV-DHK-01-1044',
        dateLabel: 'Oct 19, 2026',
        referenceNumber: 'INV-DHK-01-1044',
      ),
    ];
  }

  static List<SupplierAccount> _seedSuppliers() {
    return [
      const SupplierAccount(
        id: 1,
        name: 'Beximco Pharmaceuticals',
        contactPhone: '+880 1700-112233',
        payableAmount: 0,
        lastOrderLabel: '2 days ago',
      ),
      const SupplierAccount(
        id: 2,
        name: 'Square Pharmaceuticals',
        contactPhone: '+880 1800-445566',
        payableAmount: 0,
        lastOrderLabel: '5 days ago',
      ),
      const SupplierAccount(
        id: 3,
        name: 'Healthcare Pharma Ltd.',
        contactPhone: '+880 1900-778899',
        payableAmount: 0,
        lastOrderLabel: '1 week ago',
      ),
      const SupplierAccount(
        id: 4,
        name: 'ACME Laboratories Ltd.',
        contactPhone: '+880 1711-889900',
        payableAmount: 0,
        lastOrderLabel: '4 days ago',
      ),
    ];
  }

  static List<SupplierLedgerEntry> _seedSupplierLedger() {
    return [
      const SupplierLedgerEntry(
        id: 8,
        supplierId: 2,
        type: SupplierLedgerType.supplierPayment,
        amount: 20000,
        title: 'Partial payment • PO-SQR-0921',
        dateLabel: 'Oct 16, 2026',
        referenceNumber: 'PO-SQR-0921',
      ),
      const SupplierLedgerEntry(
        id: 7,
        supplierId: 2,
        type: SupplierLedgerType.purchaseBill,
        amount: 64000,
        title: 'Purchase PO-SQR-0921',
        dateLabel: 'Oct 15, 2026',
        referenceNumber: 'PO-SQR-0921',
      ),
      const SupplierLedgerEntry(
        id: 6,
        supplierId: 1,
        type: SupplierLedgerType.supplierPayment,
        amount: 13500,
        title: 'Bank payment • PO-BEX-0918',
        dateLabel: 'Oct 17, 2026',
        referenceNumber: 'PO-BEX-0918',
      ),
      const SupplierLedgerEntry(
        id: 5,
        supplierId: 1,
        type: SupplierLedgerType.purchaseBill,
        amount: 52000,
        title: 'Purchase PO-BEX-0918',
        dateLabel: 'Oct 14, 2026',
        referenceNumber: 'PO-BEX-0918',
      ),
      const SupplierLedgerEntry(
        id: 4,
        supplierId: 4,
        type: SupplierLedgerType.supplierPayment,
        amount: 9600,
        title: 'Settled with delivery • PO-ACM-0915',
        dateLabel: 'Oct 15, 2026',
        referenceNumber: 'PO-ACM-0915',
      ),
      const SupplierLedgerEntry(
        id: 3,
        supplierId: 4,
        type: SupplierLedgerType.purchaseBill,
        amount: 9600,
        title: 'Purchase PO-ACM-0915',
        dateLabel: 'Oct 15, 2026',
        referenceNumber: 'PO-ACM-0915',
      ),
      const SupplierLedgerEntry(
        id: 2,
        supplierId: 3,
        type: SupplierLedgerType.supplierPayment,
        amount: 18000,
        title: 'Full payment • PO-HPL-0912',
        dateLabel: 'Oct 12, 2026',
        referenceNumber: 'PO-HPL-0912',
      ),
      const SupplierLedgerEntry(
        id: 1,
        supplierId: 3,
        type: SupplierLedgerType.purchaseBill,
        amount: 18000,
        title: 'Purchase PO-HPL-0912',
        dateLabel: 'Oct 12, 2026',
        referenceNumber: 'PO-HPL-0912',
      ),
    ];
  }

  static List<ExpenseEntry> _seedExpenses() {
    return const [
      ExpenseEntry(
        id: 1,
        title: 'Cold Chain Electricity & Backup',
        category: 'Utilities',
        amount: 12400,
        dateLabel: 'Oct 19, 2026',
      ),
      ExpenseEntry(
        id: 2,
        title: 'Branch Courier & Delivery Riders',
        category: 'Logistics',
        amount: 6800,
        dateLabel: 'Oct 18, 2026',
      ),
      ExpenseEntry(
        id: 3,
        title: 'Thermal POS Receipt Rolls (40 pcs)',
        category: 'Supplies',
        amount: 3200,
        dateLabel: 'Oct 16, 2026',
      ),
    ];
  }

  static List<RecentSaleInvoice> _seedInvoices() {
    return [
      const RecentSaleInvoice(
        id: 1047,
        invoiceNumber: 'INV-DHK-01-1047',
        customerName: 'Abdur Rahman',
        cashierName: 'Mamon Hasan',
        branchCode: 'DHK-01',
        paymentMethod: 'Cash',
        totalAmount: 171,
        soldAtLabel: '12 mins ago',
        lines: [
          InvoiceLineSummary(
            medicineName: 'Napa 500 mg Tab',
            quantity: 2,
            unitName: 'strip',
            lineTotal: 30,
          ),
          InvoiceLineSummary(
            medicineName: 'Azi 500 mg Tab',
            quantity: 1,
            unitName: 'strip',
            lineTotal: 150,
          ),
        ],
      ),
      const RecentSaleInvoice(
        id: 1046,
        invoiceNumber: 'INV-DHK-01-1046',
        customerName: 'Nusrat Jahan',
        cashierName: 'Mamon Hasan',
        branchCode: 'DHK-01',
        paymentMethod: 'bKash',
        totalAmount: 480,
        soldAtLabel: '45 mins ago',
        lines: [
          InvoiceLineSummary(
            medicineName: 'Monas 10 mg Tab',
            quantity: 3,
            unitName: 'strip',
            lineTotal: 480,
          ),
        ],
      ),
    ];
  }
}
