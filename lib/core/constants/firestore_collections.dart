/// Centralised Cloud Firestore collection / sub-collection names so string
/// literals never leak into datasources.
class FirestoreCollections {
  const FirestoreCollections._();

  static const String warehouseReceipts = 'warehouse_receipts';

  /// Mirror collection: doc id == receiptNumber, used to enforce uniqueness in
  /// a transaction.
  static const String receiptNumbers = 'receipt_numbers';
}
