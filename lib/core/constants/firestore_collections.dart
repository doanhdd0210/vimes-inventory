/// Centralised Cloud Firestore collection names so string literals never leak
/// into datasources.
class FirestoreCollections {
  const FirestoreCollections._();

  // Master data
  static const String organizations = 'organizations';
  static const String departments = 'departments';
  static const String users = 'users';
  static const String warehouses = 'warehouses';
  static const String itemCategories = 'item_categories';
  static const String unitsOfMeasure = 'units_of_measure';
  static const String items = 'items';

  // Chứng từ
  static const String warehouseReceipts = 'warehouse_receipts';

  /// Mirror collection: doc id == receiptNumber, enforces uniqueness in a
  /// transaction.
  static const String receiptNumbers = 'receipt_numbers';

  // Tồn kho
  static const String stockLedger = 'stock_ledger';
  static const String inventoryStock = 'inventory_stock';
}
