import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/error/exceptions.dart';
import '../domain/entities/inventory_stock.dart';
import '../domain/entities/stock_ledger_entry.dart';
import 'in_memory_stock_store.dart';
import 'models/stock_models.dart';

abstract class StockDataSource {
  Future<List<InventoryStock>> getInventory(String organizationId);

  Future<List<StockLedgerEntry>> getLedger({
    required String warehouseId,
    required String itemId,
  });
}

class StockFirestoreDataSource implements StockDataSource {
  StockFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<InventoryStock>> getInventory(String organizationId) async {
    try {
      final snap = await _firestore
          .collection(FirestoreCollections.inventoryStock)
          .where('organizationId', isEqualTo: organizationId)
          .get();
      return snap.docs
          .map((d) => InventoryStockModel.fromMap(d.id, d.data()))
          .where((s) => s.quantityOnHand != 0)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<List<StockLedgerEntry>> getLedger({
    required String warehouseId,
    required String itemId,
  }) async {
    try {
      final snap = await _firestore
          .collection(FirestoreCollections.stockLedger)
          .where('warehouseId', isEqualTo: warehouseId)
          .where('itemId', isEqualTo: itemId)
          .orderBy('movedAt')
          .get();
      return snap.docs
          .map((d) => StockLedgerEntryModel.fromMap(d.id, d.data()))
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }
}

class StockInMemoryDataSource implements StockDataSource {
  StockInMemoryDataSource(this._store);

  final InMemoryStockStore _store;

  @override
  Future<List<InventoryStock>> getInventory(String organizationId) async =>
      _store.stockFor(organizationId);

  @override
  Future<List<StockLedgerEntry>> getLedger({
    required String warehouseId,
    required String itemId,
  }) async => _store.ledgerFor(warehouseId, itemId);
}
