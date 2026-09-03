import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/warehouse_receipt_item.dart';

class WarehouseReceiptItemModel extends WarehouseReceiptItem {
  const WarehouseReceiptItemModel({
    required super.lineNo,
    required super.itemId,
    required super.name,
    required super.unit,
    required super.quantityActual,
    required super.unitPrice,
    super.uomId,
    super.code,
    super.quantityDoc,
  });

  factory WarehouseReceiptItemModel.fromEntity(WarehouseReceiptItem e) =>
      WarehouseReceiptItemModel(
        lineNo: e.lineNo,
        itemId: e.itemId,
        name: e.name,
        unit: e.unit,
        quantityActual: e.quantityActual,
        unitPrice: e.unitPrice,
        uomId: e.uomId,
        code: e.code,
        quantityDoc: e.quantityDoc,
      );

  factory WarehouseReceiptItemModel.fromMap(DataMap map) =>
      WarehouseReceiptItemModel(
        lineNo: (map['lineNo'] as num?)?.toInt() ?? 0,
        itemId: map['itemId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        unit: map['unit'] as String? ?? '',
        quantityActual: (map['quantityActual'] as num?) ?? 0,
        unitPrice: (map['unitPrice'] as num?) ?? 0,
        uomId: map['uomId'] as String?,
        code: map['code'] as String?,
        quantityDoc: map['quantityDoc'] as num?,
      );

  DataMap toMap() => {
    'lineNo': lineNo,
    'itemId': itemId,
    'name': name,
    'code': code,
    'uomId': uomId,
    'unit': unit,
    'quantityDoc': quantityDoc,
    'quantityActual': quantityActual,
    'unitPrice': unitPrice,
    'amount': amount,
  };
}
