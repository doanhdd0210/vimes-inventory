import 'package:equatable/equatable.dart';

/// One line of a goods-receipt note — columns A/B/C/D/1/2/3/4 of Mẫu 01‑VT.
/// [itemId] / [uomId] reference the master catalogs; [name] / [code] / [unit]
/// are snapshots taken when the phiếu was written.
class WarehouseReceiptItem extends Equatable {
  const WarehouseReceiptItem({
    required this.lineNo,
    required this.itemId,
    required this.name,
    required this.unit,
    required this.quantityActual,
    required this.unitPrice,
    this.uomId,
    this.code,
    this.quantityDoc,
  });

  /// STT (A).
  final int lineNo;

  /// FK → items.
  final String itemId;

  /// Tên, nhãn hiệu, quy cách… (B) — snapshot.
  final String name;

  /// Mã số (C) — snapshot.
  final String? code;

  /// FK → units_of_measure.
  final String? uomId;

  /// Đơn vị tính (D) — snapshot.
  final String unit;

  /// Số lượng — theo chứng từ (1).
  final num? quantityDoc;

  /// Số lượng — thực nhập (2).
  final num quantityActual;

  /// Đơn giá (3).
  final num unitPrice;

  /// Thành tiền (4) = thực nhập × đơn giá, rounded to đồng.
  num get amount => (quantityActual * unitPrice).roundToDouble();

  @override
  List<Object?> get props => [
    lineNo,
    itemId,
    name,
    code,
    uomId,
    unit,
    quantityDoc,
    quantityActual,
    unitPrice,
  ];
}
