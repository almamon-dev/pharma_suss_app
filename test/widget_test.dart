import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/storage/workspace_preferences.dart';
import 'package:pharmacy_saas_mobile/features/crm/presentation/crm_screens.dart';
import 'package:pharmacy_saas_mobile/features/inventory/presentation/inventory_tab.dart';
import 'package:pharmacy_saas_mobile/features/pos/presentation/pos_tab.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';
import 'package:pharmacy_saas_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Complete 10-screen emerald UI flow without domain field on 360x780 viewport',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final preferences = await WorkspacePreferences.load();

      await tester.pumpWidget(
        PharmacySaasMobileApp(preferences: preferences),
      );
      await tester.pumpAndSettle();

      // Screen 1: Welcome / Splash
      expect(find.text('Pharmacy SaaS'), findsOneWidget);
      expect(find.text('Multi-Tenant Pharmacy Management'), findsOneWidget);
      expect(find.text('POS & Billing'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Screen 2: Sign In (no domain field anywhere)
      expect(find.text('Sign In to Your Account'), findsOneWidget);
      expect(find.text('Email or Phone'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.textContaining('Domain'), findsNothing);
      expect(find.textContaining('Subdomain'), findsNothing);

      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(
        find.text('Enter your email or phone number'),
        findsOneWidget,
      );
      expect(find.text('Password is required'), findsOneWidget);

      await tester.ensureVisible(find.text('Mamon Owner'));
      await tester.tap(find.text('Mamon Owner'));
      await tester.pump();
      expect(find.text('mamon@pharmacy.com'), findsWidgets);

      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Screen 3: Select Business
      expect(find.text('Select Business'), findsOneWidget);
      expect(find.text('Mamon Pharmacy'), findsOneWidget);
      expect(find.text('CarePlus Pharmacy'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Screen 4: Select Branch
      expect(find.text('Select Branch'), findsOneWidget);
      expect(find.text('Main Branch (Head Office)'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Screen 5: Home Dashboard
      expect(find.text("Today's Summary"), findsOneWidget);
      expect(find.text('Sales Revenue'), findsOneWidget);
      expect(find.text('Net Profit'), findsOneWidget);
      expect(find.text('Customer Due'), findsOneWidget);
      expect(find.text('Supplier Payable'), findsOneWidget);

      // Screen 6: POS - New Sale (via bottom nav)
      final navBar = find.byType(NavigationBar);
      await tester.tap(find.descendant(of: navBar, matching: find.text('POS')));
      await tester.pumpAndSettle();
      expect(find.text('POS - New Sale'), findsOneWidget);
      expect(find.text('Napa 500 mg Tab'), findsOneWidget);

      // Open Unit / Pata / Carton picker by tapping medicine card, pick Carton
      await tester.tap(find.text('Napa 500 mg Tab'));
      await tester.pumpAndSettle();
      expect(find.text('Select Unit (Unit / Pata / Carton)'), findsOneWidget);
      await tester.tap(find.text('Carton').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();
      expect(find.text('100 pcs • ৳ 145'), findsOneWidget);
      expect(find.text('Carton'), findsOneWidget);

      // Switch Cart item cleanly via inline unit dropdown badge
      await tester.tap(find.text('Carton'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pata (10 pcs)'));
      await tester.pumpAndSettle();
      expect(find.text('Pata'), findsOneWidget);
      expect(find.text('10 pcs • ৳ 15'), findsOneWidget);
      expect(find.text('Cart (1 item)'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Complete Sale'), findsOneWidget);

      await tester.tap(find.textContaining('Confirm & Issue Receipt'));
      await tester.pumpAndSettle();
      expect(find.text('Sale Completed'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Screen 7: Inventory
      await tester.tap(
        find.descendant(of: navBar, matching: find.text('Inventory')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Total Items'), findsOneWidget);
      expect(find.text('Total Stock'), findsOneWidget);
      expect(find.text('Medicine List'), findsOneWidget);
      expect(find.text('Batch Management'), findsOneWidget);

      // Screen 8: Customers (via Home quick action)
      await tester.tap(find.descendant(of: navBar, matching: find.text('Home')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Customers'));
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      expect(find.text('Abdur Rahman'), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);

      // Verify Add Customer has no manual Opening Due input (due auto-calculates)
      await tester.tap(find.text('Add Customer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Opening Due'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'),
        'Mahmudul Hasan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Phone Number'),
        '01715-000111',
      );
      await tester.tap(find.text('Save Customer'));
      await tester.pumpAndSettle();
      expect(find.text('Mahmudul Hasan'), findsOneWidget);

      // Attach Mahmudul Hasan to POS and record a credit (Due) sale
      await tester.tap(find.text('Mahmudul Hasan'));
      await tester.pumpAndSettle();
      expect(find.text('Auto-calculated from ledger'), findsOneWidget);
      await tester.tap(find.text('Attach to Active POS Bill'));
      await tester.pumpAndSettle();
      // Let confirmation SnackBar dismiss so bottom Checkout button is unobstructed
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(of: navBar, matching: find.text('POS')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Due'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Confirm Credit Sale'));
      await tester.pumpAndSettle();
      expect(find.text('Due Added (Auto)'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Verify updated due shows inside Customers without manual entry
      await tester.tap(find.descendant(of: navBar, matching: find.text('Home')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Customers'));
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      expect(find.text('Due: ৳ 14.25'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Screen 9 & 10: Reports -> Analytics
      await tester.tap(
        find.descendant(of: navBar, matching: find.text('Reports')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sales Report'), findsOneWidget);
      expect(find.text('Profit & Loss Report'), findsOneWidget);

      await tester.tap(find.text('Sales Report'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Sales Trend'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Menu & Sign Out
      await tester.tap(find.descendant(of: navBar, matching: find.text('Menu')));
      await tester.pumpAndSettle();
      expect(find.text('Switch Business'), findsOneWidget);
      expect(find.text('Switch Branch'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Sign Out'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In to Your Account'), findsOneWidget);
    },
  );

  test(
    'PharmacyDirectory resolves businesses without domain & store deducts FEFO stock',
    () {
      final session =
          PharmacyDirectory.resolveSessionForLogin('mamon@pharmacy.com');
      expect(session.tenantDomain, 'mamon.pharma.com');
      expect(session.availableWorkspaces.length, 3);
      expect(session.branchCode, 'DHK-01');

      final store = PharmacyStoreController(initialSession: session);
      final napa = store.medicines.firstWhere((m) => m.name == 'Napa 500 mg Tab');
      final initialStock = store.stockForMedicine(napa.id);

      expect(store.addToCart(napa, unit: SaleUnit.strip), isTrue);
      final invoice = store.completeSale();
      expect(invoice, isNotNull);
      expect(
        store.stockForMedicine(napa.id),
        initialStock - napa.packSize(SaleUnit.strip),
      );
    },
  );

  test(
    'Customer due starts at 0 and auto-calculates from credit sales & due collections',
    () {
      final session =
          PharmacyDirectory.resolveSessionForLogin('mamon@pharmacy.com');
      final store = PharmacyStoreController(initialSession: session);
      final baseTotalDue = store.totalCustomerDue;

      store.addCustomer(name: 'Test Patient', phone: '01700-000000');
      final patient = store.customers.first;
      expect(patient.name, 'Test Patient');
      expect(patient.dueAmount, 0);
      expect(store.dueForCustomer(patient.id), 0);

      final azi = store.medicines.firstWhere((m) => m.name == 'Azi 500 mg Tab');
      // Verify Unit / Pata / Carton updates via setCartLine
      expect(store.setCartLine(azi, unit: SaleUnit.piece, qty: 3), isTrue);
      expect(store.cartLineFor(azi.id)?.totalPieces, 3);
      expect(store.setCartLine(azi, unit: SaleUnit.strip, qty: 1), isTrue);
      expect(store.cartLineFor(azi.id)?.totalPieces, 10);
      store.setDiscountPercent(0);
      store.setPaymentMethod('Due');

      // Anonymous Walk-in Customer cannot complete a credit/due sale
      expect(store.completeSale(paidAmount: 0), isNull);

      // Attach customer & pay ৳50 out of ৳150 -> ৳100 due auto-calculated
      store.setSelectedCustomer(patient);
      final invoice = store.completeSale(paidAmount: 50);
      expect(invoice, isNotNull);
      expect(invoice!.totalAmount, 150);
      expect(invoice.paidAmount, 50);
      expect(invoice.dueAmount, 100);
      expect(store.dueForCustomer(patient.id), 100);
      expect(store.customers.first.dueAmount, 100);
      expect(store.totalCustomerDue, baseTotalDue + 100);
      expect(store.ledgerForCustomer(patient.id).length, 1);

      // Collect ৳40 -> remaining due auto-updates to ৳60
      final collected = store.collectCustomerDue(patient.id, 40);
      expect(collected, 40);
      expect(store.dueForCustomer(patient.id), 60);
      expect(store.customers.first.dueAmount, 60);
      expect(store.totalCustomerDue, baseTotalDue + 60);
      expect(store.ledgerForCustomer(patient.id).length, 2);

      // User scenario: Previous due ৳500 + today's bill ৳200, customer pays ৳300 -> ৳400 remaining
      store.addCustomer(name: 'Rahim Uddin', phone: '01755-112233');
      final rahim = store.customers.first;
      final napa = store.medicines.firstWhere((m) => m.name == 'Napa 500 mg Tab');
      final ace = store.medicines.firstWhere((m) => m.name == 'Ace 500 mg Tab');
      final seclo =
          store.medicines.firstWhere((m) => m.name == 'Seclo 20 mg Cap');

      store.setDiscountPercent(0);
      store.setSelectedCustomer(rahim);
      store.setPaymentMethod('Due');
      expect(store.setCartLine(napa, unit: SaleUnit.strip, qty: 20), isTrue); // ৳300
      expect(store.setCartLine(ace, unit: SaleUnit.strip, qty: 10), isTrue); // ৳200
      final prevInvoice = store.completeSale(paidAmount: 0);
      expect(prevInvoice?.totalAmount, 500);
      expect(store.dueForCustomer(rahim.id), 500);

      final revBeforeCombined = store.todaySalesRevenue;
      store.setSelectedCustomer(rahim);
      store.setPaymentMethod('Cash');
      expect(store.setCartLine(seclo, unit: SaleUnit.strip, qty: 3), isTrue); // ৳180
      expect(store.setCartLine(ace, unit: SaleUnit.strip, qty: 1), isTrue); // ৳20
      final combinedInvoice = store.completeSale(paidAmount: 300);
      expect(combinedInvoice, isNotNull);
      expect(combinedInvoice!.totalAmount, 200);
      expect(combinedInvoice.paidAmount, 200);
      expect(combinedInvoice.previousDueCleared, 100);
      expect(combinedInvoice.totalCashCollected, 300);
      expect(combinedInvoice.dueAmount, 0);
      expect(combinedInvoice.remainingCustomerDue, 400);
      expect(store.dueForCustomer(rahim.id), 400);
      expect(store.todaySalesRevenue, revBeforeCombined + 200);
    },
  );

  testWidgets(
    'Combined checkout UI with previous due + new bill settles remaining due cleanly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session =
          PharmacyDirectory.resolveSessionForLogin('mamon@pharmacy.com');
      final store = PharmacyStoreController(initialSession: session);
      store.addCustomer(name: 'Tariq Hassan', phone: '01788-990011');
      final tariq = store.customers.first;
      final napa = store.medicines.firstWhere((m) => m.name == 'Napa 500 mg Tab');
      final ace = store.medicines.firstWhere((m) => m.name == 'Ace 500 mg Tab');
      final seclo =
          store.medicines.firstWhere((m) => m.name == 'Seclo 20 mg Cap');

      // Seed ৳500 previous due
      store.setDiscountPercent(0);
      store.setSelectedCustomer(tariq);
      store.setPaymentMethod('Due');
      store.setCartLine(napa, unit: SaleUnit.strip, qty: 20);
      store.setCartLine(ace, unit: SaleUnit.strip, qty: 10);
      store.completeSale(paidAmount: 0);

      // Today's bill: ৳200 for Tariq
      store.setSelectedCustomer(tariq);
      store.setPaymentMethod('Cash');
      store.setCartLine(seclo, unit: SaleUnit.strip, qty: 3);
      store.setCartLine(ace, unit: SaleUnit.strip, qty: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PosTab(store: store)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      expect(find.text('Previous Due'), findsOneWidget);
      expect(find.text('৳ 500.00'), findsNWidgets(2));
      expect(find.text('Combined Total'), findsOneWidget);
      expect(find.text('৳ 700.00'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, '300');
      await tester.pumpAndSettle();
      expect(find.text('Cleared Prev. Due (Auto)'), findsOneWidget);
      expect(find.text('-৳ 100.00'), findsOneWidget);
      expect(find.text('Remaining Due (Auto)'), findsOneWidget);
      expect(find.text('৳ 400.00'), findsOneWidget);

      await tester.ensureVisible(find.textContaining('Clear Due'));
      await tester.tap(find.textContaining('Clear Due'));
      await tester.pumpAndSettle();

      expect(find.text('Sale Completed'), findsOneWidget);
      expect(find.text('Prev. Due Cleared'), findsOneWidget);
      expect(find.text('Remaining Due'), findsOneWidget);
      expect(store.dueForCustomer(tariq.id), 400);
    },
  );

  test(
    'Supplier payable auto-calculates from purchases, payments, expiry returns & advance credits',
    () {
      final session =
          PharmacyDirectory.resolveSessionForLogin('mamon@pharmacy.com');
      final store = PharmacyStoreController(initialSession: session);

      final initialTotalPayable = store.totalSupplierPayable;
      expect(store.dueForSupplier(1), 38500);
      expect(store.dueForSupplier(2), 44000);
      expect(initialTotalPayable, 82500);

      // New supplier starts with 0 due & 0 advance credit
      store.addSupplier(
        name: 'Incepta Pharmaceuticals',
        contactPhone: '+880 1711-000222',
      );
      final incepta = store.suppliers.first;
      expect(store.dueForSupplier(incepta.id), 0);
      expect(store.advanceCreditForSupplier(incepta.id), 0);

      // Receive purchase stock on partial credit: 100 pcs @ 10 = 1,000, paid 400 -> 600 payable
      final batch = store.branchBatches.first;
      final stockBefore = batch.quantityAvailable;
      final receipt1 = store.receiveSupplierPurchase(
        batchId: batch.id,
        supplierId: incepta.id,
        quantity: 100,
        unitCost: 10,
        paidNow: 400,
      );
      expect(receipt1, isNotNull);
      expect(receipt1!.purchaseTotal, 1000);
      expect(receipt1.newSupplierPayable, 600);
      expect(store.dueForSupplier(incepta.id), 600);
      expect(store.totalSupplierPayable, initialTotalPayable + 600);

      // Return 20 pcs expired @ cost credit 200 -> due reduces 600 -> 400
      final ret1 = store.returnOrDisposeExpiredBatch(
        batchId: batch.id,
        quantity: 20,
        mode: ExpiryReturnMode.adjustDue,
        supplierId: incepta.id,
        creditAmount: 200,
      );
      expect(ret1, isNotNull);
      expect(ret1!.dueReduced, 200);
      expect(ret1.advanceCreditAdded, 0);
      expect(store.dueForSupplier(incepta.id), 400);

      // Return MORE expired stock (500) than remaining due (400) -> 0 due & 100 advance credit
      final ret2 = store.returnOrDisposeExpiredBatch(
        batchId: batch.id,
        quantity: 50,
        mode: ExpiryReturnMode.adjustDue,
        supplierId: incepta.id,
        creditAmount: 500,
      );
      expect(ret2, isNotNull);
      expect(ret2!.dueReduced, 400);
      expect(ret2.advanceCreditAdded, 100);
      expect(store.dueForSupplier(incepta.id), 0);
      expect(store.advanceCreditForSupplier(incepta.id), 100);
      expect(store.totalSupplierAdvanceCredit, 100);

      // Next purchase of 300 auto-uses 100 advance credit -> net due becomes 200
      final receipt2 = store.receiveSupplierPurchase(
        batchId: batch.id,
        supplierId: incepta.id,
        quantity: 30,
        unitCost: 10,
        paidNow: 0,
      );
      expect(receipt2, isNotNull);
      expect(receipt2!.advanceCreditApplied, 100);
      expect(receipt2.newSupplierPayable, 200);
      expect(store.advanceCreditForSupplier(incepta.id), 0);
      expect(store.dueForSupplier(incepta.id), 200);

      // Direct cash refund mode keeps supplier payable unchanged while removing stock
      final cashReturn = store.returnOrDisposeExpiredBatch(
        batchId: batch.id,
        quantity: 10,
        mode: ExpiryReturnMode.cashRefund,
        supplierId: incepta.id,
        creditAmount: 100,
      );
      expect(cashReturn, isNotNull);
      expect(store.dueForSupplier(incepta.id), 200);

      // Write-off disposal removes stock only without changing payable
      final writeOff = store.returnOrDisposeExpiredBatch(
        batchId: batch.id,
        quantity: 10,
        mode: ExpiryReturnMode.writeOff,
      );
      expect(writeOff, isNotNull);
      expect(store.dueForSupplier(incepta.id), 200);

      // Pay off remaining 200 supplier due
      final paid = store.paySupplierDue(incepta.id, 500);
      expect(paid, 200);
      expect(store.dueForSupplier(incepta.id), 0);
      expect(
        store.branchBatches.firstWhere((b) => b.id == batch.id).quantityAvailable,
        stockBefore + 100 - 20 - 50 + 30 - 10 - 10,
      );
    },
  );

  testWidgets(
    'Suppliers screen and expiry return sheet settle due cleanly on 360x780 viewport',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session =
          PharmacyDirectory.resolveSessionForLogin('mamon@pharmacy.com');
      final store = PharmacyStoreController(initialSession: session);
      final initialSquareDue = store.dueForSupplier(2);
      expect(initialSquareDue, 44000);

      await tester.pumpWidget(
        MaterialApp(
          home: SuppliersScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Supplier Payable'), findsOneWidget);
      expect(find.text('Square Pharmaceuticals'), findsOneWidget);

      await tester.tap(find.text('Square Pharmaceuticals'));
      await tester.pumpAndSettle();

      expect(find.text('Auto-calculated from ledger'), findsOneWidget);
      expect(find.text('Purchase, Payment & Expiry Ledger'), findsOneWidget);
      expect(find.text('Pay Supplier Due'), findsOneWidget);

      await tester.ensureVisible(
        find.text('Return Expired Product to Company'),
      );
      await tester.tap(find.text('Return Expired Product to Company'));
      await tester.pumpAndSettle();

      expect(find.text('Expired Return & Settlement'), findsOneWidget);
      expect(find.text('New Supplier Payable (Auto)'), findsOneWidget);

      await tester.ensureVisible(find.textContaining('Confirm Return'));
      await tester.tap(find.textContaining('Confirm Return'));
      await tester.pumpAndSettle();

      expect(store.dueForSupplier(2), lessThan(initialSquareDue));
    },
  );

  testWidgets(
    'Inventory Stock In & Expiry Return sheets update ledger cleanly on 360x780 viewport',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session =
          PharmacyDirectory.resolveSessionForLogin('mamon@pharmacy.com');
      final store = PharmacyStoreController(initialSession: session);
      final initialPayable = store.totalSupplierPayable;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InventoryTab(store: store)),
        ),
      );
      await tester.pumpAndSettle();

      // 1) Stock In (Purchase Receive) updates stock & supplier payable
      await tester.scrollUntilVisible(
        find.text('Stock In (Purchase)'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Stock In (Purchase)'));
      await tester.pumpAndSettle();

      expect(find.text('Stock In (Purchase Receive)'), findsOneWidget);
      expect(find.text('New Supplier Payable (Auto)'), findsOneWidget);
      await tester.ensureVisible(find.textContaining('Receive +50 Units'));
      await tester.tap(find.textContaining('Receive +50 Units'));
      await tester.pumpAndSettle();
      expect(store.totalSupplierPayable, greaterThan(initialPayable));

      // Dismiss purchase SnackBar before scrolling further down
      ScaffoldMessenger.of(
        tester.element(find.byType(InventoryTab)),
      ).clearSnackBars();
      await tester.pumpAndSettle();

      // 2) Expiry & Disposal -> Return / Dispose opens settlement modes cleanly
      await tester.scrollUntilVisible(
        find.text('Expiry & Disposal'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Expiry & Disposal'));
      await tester.pumpAndSettle();

      expect(find.text('Return / Dispose'), findsWidgets);
      await tester.tap(find.text('Return / Dispose').first);
      await tester.pumpAndSettle();

      expect(find.text('Expired Return & Settlement'), findsOneWidget);
      await tester.tap(find.text('Return • Cash Refund'));
      await tester.pumpAndSettle();
      expect(find.text('Cash Refund Received'), findsOneWidget);
    },
  );
}
