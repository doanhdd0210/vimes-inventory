import 'package:equatable/equatable.dart';

/// Tồn kho hiện tại của một vật tư trong một kho (snapshot số dư).
class InventoryStock extends Equatable {
  const InventoryStock({
    required this.warehouseId,
    required this.itemId,
    required this.organizationId,
    required this.quantityOnHand,
    required this.stockValue,
    this.lastMovementAt,
    this.updatedAt,
  });

  final String warehouseId;
  final String itemId;
  final String organizationId;
  final num quantityOnHand;
  final num stockValue;
  final DateTime? lastMovementAt;
  final DateTime? updatedAt;

  /// Đơn giá bình quân gia quyền.
  num get avgCost =>
      quantityOnHand > 0 ? (stockValue / quantityOnHand).roundToDouble() : 0;

  /// Khoá tài liệu Firestore: `{warehouseId}__{itemId}`.
  String get docId => '${warehouseId}__$itemId';

  @override
  List<Object?> get props => [
    warehouseId,
    itemId,
    organizationId,
    quantityOnHand,
    stockValue,
    lastMovementAt,
    updatedAt,
  ];
}
