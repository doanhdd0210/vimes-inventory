import 'package:equatable/equatable.dart';

enum StockMovementType {
  receipt,
  issue,
  adjust,
  transfer;

  static StockMovementType fromName(String? name) =>
      StockMovementType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => StockMovementType.adjust,
      );

  String get label => switch (this) {
    StockMovementType.receipt => 'Nhập',
    StockMovementType.issue => 'Xuất',
    StockMovementType.adjust => 'Điều chỉnh',
    StockMovementType.transfer => 'Chuyển kho',
  };
}

/// Một dòng thẻ kho (append-only). `quantity` có dấu: + nhập, − xuất.
class StockLedgerEntry extends Equatable {
  const StockLedgerEntry({
    required this.id,
    required this.organizationId,
    required this.warehouseId,
    required this.itemId,
    required this.movementType,
    required this.quantity,
    required this.unitCost,
    required this.balanceQtyAfter,
    required this.balanceValueAfter,
    required this.avgCostAfter,
    required this.sourceCollection,
    required this.sourceId,
    required this.movedAt,
    this.postedBy,
  });

  final String id;
  final String organizationId;
  final String warehouseId;
  final String itemId;
  final StockMovementType movementType;
  final num quantity;
  final num unitCost;
  final num balanceQtyAfter;
  final num balanceValueAfter;
  final num avgCostAfter;
  final String sourceCollection;
  final String sourceId;
  final DateTime movedAt;
  final String? postedBy;

  num get value => (quantity * unitCost).roundToDouble();

  @override
  List<Object?> get props => [
    id,
    organizationId,
    warehouseId,
    itemId,
    movementType,
    quantity,
    unitCost,
    balanceQtyAfter,
    balanceValueAfter,
    avgCostAfter,
    sourceCollection,
    sourceId,
    movedAt,
    postedBy,
  ];
}
