import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/inventory_stock.dart';
import '../../domain/entities/stock_ledger_entry.dart';

DateTime? _date(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

class InventoryStockModel extends InventoryStock {
  const InventoryStockModel({
    required super.warehouseId,
    required super.itemId,
    required super.organizationId,
    required super.quantityOnHand,
    required super.stockValue,
    super.lastMovementAt,
    super.updatedAt,
  });

  factory InventoryStockModel.fromMap(String id, DataMap m) =>
      InventoryStockModel(
        warehouseId: m['warehouseId'] as String? ?? id.split('__').first,
        itemId: m['itemId'] as String? ?? id.split('__').last,
        organizationId: m['organizationId'] as String? ?? '',
        quantityOnHand: (m['quantityOnHand'] as num?) ?? 0,
        stockValue: (m['stockValue'] as num?) ?? 0,
        lastMovementAt: _date(m['lastMovementAt']),
        updatedAt: _date(m['updatedAt']),
      );

  DataMap toMap({bool serverTimestamp = true}) => {
    'warehouseId': warehouseId,
    'itemId': itemId,
    'organizationId': organizationId,
    'quantityOnHand': quantityOnHand,
    'stockValue': stockValue,
    'avgCost': avgCost,
    'lastMovementAt': lastMovementAt == null
        ? null
        : Timestamp.fromDate(lastMovementAt!),
    'updatedAt': serverTimestamp
        ? FieldValue.serverTimestamp()
        : (updatedAt == null ? null : Timestamp.fromDate(updatedAt!)),
  };
}

class StockLedgerEntryModel extends StockLedgerEntry {
  const StockLedgerEntryModel({
    required super.id,
    required super.organizationId,
    required super.warehouseId,
    required super.itemId,
    required super.movementType,
    required super.quantity,
    required super.unitCost,
    required super.balanceQtyAfter,
    required super.balanceValueAfter,
    required super.avgCostAfter,
    required super.sourceCollection,
    required super.sourceId,
    required super.movedAt,
    super.postedBy,
  });

  factory StockLedgerEntryModel.fromMap(String id, DataMap m) =>
      StockLedgerEntryModel(
        id: id,
        organizationId: m['organizationId'] as String? ?? '',
        warehouseId: m['warehouseId'] as String? ?? '',
        itemId: m['itemId'] as String? ?? '',
        movementType: StockMovementType.fromName(m['movementType'] as String?),
        quantity: (m['quantity'] as num?) ?? 0,
        unitCost: (m['unitCost'] as num?) ?? 0,
        balanceQtyAfter: (m['balanceQtyAfter'] as num?) ?? 0,
        balanceValueAfter: (m['balanceValueAfter'] as num?) ?? 0,
        avgCostAfter: (m['avgCostAfter'] as num?) ?? 0,
        sourceCollection: m['sourceCollection'] as String? ?? '',
        sourceId: m['sourceId'] as String? ?? '',
        movedAt: _date(m['movedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        postedBy: m['postedBy'] as String?,
      );

  DataMap toMap() => {
    'organizationId': organizationId,
    'warehouseId': warehouseId,
    'itemId': itemId,
    'movementType': movementType.name,
    'quantity': quantity,
    'unitCost': unitCost,
    'value': value,
    'balanceQtyAfter': balanceQtyAfter,
    'balanceValueAfter': balanceValueAfter,
    'avgCostAfter': avgCostAfter,
    'sourceCollection': sourceCollection,
    'sourceId': sourceId,
    'movedAt': Timestamp.fromDate(movedAt),
    'postedBy': postedBy,
  };
}
