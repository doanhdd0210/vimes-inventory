import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../stock/data/models/stock_models.dart';
import '../../../stock/domain/entities/stock_ledger_entry.dart';
import '../../../stock/domain/weighted_average.dart';
import '../models/warehouse_receipt_model.dart';

abstract class WarehouseReceiptDataSource {
  Future<String> createReceipt(WarehouseReceiptModel receipt);

  Future<List<WarehouseReceiptModel>> getReceipts();

  Future<WarehouseReceiptModel> getReceiptById(String id);
}

/// Cloud Firestore implementation. Writing a phiếu is one [runTransaction] that
/// also enforces `receiptNumber` uniqueness (mirror doc) and posts stock
/// (`stock_ledger` + `inventory_stock`) with weighted-average cost.
class WarehouseReceiptFirestoreDataSource
    implements WarehouseReceiptDataSource {
  WarehouseReceiptFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<DataMap> get _receipts =>
      _firestore.collection(FirestoreCollections.warehouseReceipts);
  CollectionReference<DataMap> get _numbers =>
      _firestore.collection(FirestoreCollections.receiptNumbers);
  CollectionReference<DataMap> get _ledger =>
      _firestore.collection(FirestoreCollections.stockLedger);
  CollectionReference<DataMap> get _inventory =>
      _firestore.collection(FirestoreCollections.inventoryStock);

  @override
  Future<String> createReceipt(WarehouseReceiptModel receipt) async {
    try {
      final receiptRef = _receipts.doc();
      final numberRef = _numbers.doc(receipt.receiptNumber.trim());

      // distinct item ids preserve first-seen order
      final itemIds = <String>{
        for (final l in receipt.items) l.itemId,
      }.toList();

      await _firestore.runTransaction((txn) async {
        // ---- reads (all before writes) ----
        final numberSnap = await txn.get(numberRef);
        if (numberSnap.exists) {
          throw const ServerException(
            message: 'Số phiếu đã tồn tại',
            statusCode: 'already-exists',
          );
        }
        final invSnaps = <String, DocumentSnapshot<DataMap>>{};
        for (final itemId in itemIds) {
          invSnaps[itemId] = await txn.get(
            _inventory.doc('${receipt.warehouseId}__$itemId'),
          );
        }

        // ---- compute ----
        final running = <String, ({num qty, num value})>{};
        for (final itemId in itemIds) {
          final data = invSnaps[itemId]!.data();
          running[itemId] = (
            qty: (data?['quantityOnHand'] as num?) ?? 0,
            value: (data?['stockValue'] as num?) ?? 0,
          );
        }

        final ledgerDocs = <({DocumentReference<DataMap> ref, DataMap data})>[];
        for (final line in receipt.items) {
          final cur = running[line.itemId]!;
          final next = WeightedAverage.applyReceipt(
            currentQty: cur.qty,
            currentValue: cur.value,
            inQty: line.quantityActual,
            inValue: line.amount,
          );
          running[line.itemId] = (qty: next.qty, value: next.value);

          ledgerDocs.add((
            ref: _ledger.doc(),
            data: StockLedgerEntryModel(
              id: '',
              organizationId: receipt.organizationId,
              warehouseId: receipt.warehouseId,
              itemId: line.itemId,
              movementType: StockMovementType.receipt,
              quantity: line.quantityActual,
              unitCost: line.unitPrice,
              balanceQtyAfter: next.qty,
              balanceValueAfter: next.value,
              avgCostAfter: next.avg,
              sourceCollection: FirestoreCollections.warehouseReceipts,
              sourceId: '${receiptRef.id}#${line.lineNo}',
              movedAt: receipt.receiptDate,
              postedBy: receipt.preparerUserId,
            ).toMap(),
          ));
        }

        // ---- writes ----
        txn.set(receiptRef, receipt.toMap());
        txn.set(numberRef, {
          'receiptId': receiptRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
        for (final d in ledgerDocs) {
          txn.set(d.ref, d.data);
        }
        for (final itemId in itemIds) {
          final r = running[itemId]!;
          txn.set(
            _inventory.doc('${receipt.warehouseId}__$itemId'),
            InventoryStockModel(
              warehouseId: receipt.warehouseId,
              itemId: itemId,
              organizationId: receipt.organizationId,
              quantityOnHand: r.qty,
              stockValue: r.value,
              lastMovementAt: receipt.receiptDate,
            ).toMap(),
            SetOptions(merge: true),
          );
        }
      });

      return receiptRef.id;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<List<WarehouseReceiptModel>> getReceipts() async {
    try {
      final snapshot = await _receipts
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map(WarehouseReceiptModel.fromSnapshot)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<WarehouseReceiptModel> getReceiptById(String id) async {
    try {
      final doc = await _receipts.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(
          message: 'Không tìm thấy phiếu',
          statusCode: 'not-found',
        );
      }
      return WarehouseReceiptModel.fromSnapshot(doc);
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }
}
