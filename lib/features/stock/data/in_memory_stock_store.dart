import '../domain/entities/inventory_stock.dart';
import '../domain/entities/stock_ledger_entry.dart';
import '../domain/weighted_average.dart';

/// Process-wide mutable stock state used while Firebase is off. Shared (as a DI
/// singleton) between the receipt in-memory datasource that *posts* and the
/// stock read datasource that *displays*.
class InMemoryStockStore {
  final Map<String, InventoryStock> _stock = {}; // key: "{wh}__{item}"
  final List<StockLedgerEntry> _ledger = [];
  var _ledgerSeq = 0;

  List<InventoryStock> stockFor(String organizationId) => List.unmodifiable(
    _stock.values.where((s) => s.organizationId == organizationId),
  );

  List<StockLedgerEntry> ledgerFor(String warehouseId, String itemId) {
    final rows =
        _ledger
            .where((e) => e.warehouseId == warehouseId && e.itemId == itemId)
            .toList()
          ..sort((a, b) => a.movedAt.compareTo(b.movedAt));
    return List.unmodifiable(rows);
  }

  bool hasPosted(String sourceCollection, String sourceId) => _ledger.any(
    (e) => e.sourceCollection == sourceCollection && e.sourceId == sourceId,
  );

  /// Post one receipt line (goods-in) with weighted-average cost.
  void postReceiptLine({
    required String organizationId,
    required String warehouseId,
    required String itemId,
    required num quantity,
    required num unitPrice,
    required String sourceCollection,
    required String sourceId,
    required DateTime movedAt,
    String? postedBy,
  }) {
    final key = '${warehouseId}__$itemId';
    final current =
        _stock[key] ??
        InventoryStock(
          warehouseId: warehouseId,
          itemId: itemId,
          organizationId: organizationId,
          quantityOnHand: 0,
          stockValue: 0,
        );

    final next = WeightedAverage.applyReceipt(
      currentQty: current.quantityOnHand,
      currentValue: current.stockValue,
      inQty: quantity,
      inValue: (quantity * unitPrice).roundToDouble(),
    );

    _ledger.add(
      StockLedgerEntry(
        id: 'mem-ledger-${++_ledgerSeq}',
        organizationId: organizationId,
        warehouseId: warehouseId,
        itemId: itemId,
        movementType: StockMovementType.receipt,
        quantity: quantity,
        unitCost: unitPrice,
        balanceQtyAfter: next.qty,
        balanceValueAfter: next.value,
        avgCostAfter: next.avg,
        sourceCollection: sourceCollection,
        sourceId: sourceId,
        movedAt: movedAt,
        postedBy: postedBy,
      ),
    );

    _stock[key] = InventoryStock(
      warehouseId: warehouseId,
      itemId: itemId,
      organizationId: organizationId,
      quantityOnHand: next.qty,
      stockValue: next.value,
      lastMovementAt: movedAt,
      updatedAt: DateTime.now(),
    );
  }
}
