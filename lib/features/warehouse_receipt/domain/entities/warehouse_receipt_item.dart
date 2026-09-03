import 'package:equatable/equatable.dart';

/// One line of a goods-receipt note — columns A/B/C/D/1/2/3/4 of Mẫu 01‑VT.
class WarehouseReceiptItem extends Equatable {
  const WarehouseReceiptItem({
    required this.lineNo,
    required this.name,
    required this.unit,
    required this.quantityActual,
    required this.unitPrice,
    this.code,
    this.quantityDoc,
  });

  /// STT (A).
  final int lineNo;

  /// Tên, nhãn hiệu, quy cách, phẩm chất vật tư… (B).
  final String name;

  /// Mã số (C).
  final String? code;

  /// Đơn vị tính (D).
  final String unit;

  /// Số lượng — theo chứng từ (1).
  final num? quantityDoc;

  /// Số lượng — thực nhập (2).
  final num quantityActual;

  /// Đơn giá (3).
  final num unitPrice;

  /// Thành tiền (4) = thực nhập × đơn giá, rounded to đồng.
  num get amount => (quantityActual * unitPrice).roundToDouble();

  WarehouseReceiptItem copyWith({
    int? lineNo,
    String? name,
    Object? code = _sentinel,
    String? unit,
    Object? quantityDoc = _sentinel,
    num? quantityActual,
    num? unitPrice,
  }) {
    return WarehouseReceiptItem(
      lineNo: lineNo ?? this.lineNo,
      name: name ?? this.name,
      code: identical(code, _sentinel) ? this.code : code as String?,
      unit: unit ?? this.unit,
      quantityDoc: identical(quantityDoc, _sentinel)
          ? this.quantityDoc
          : quantityDoc as num?,
      quantityActual: quantityActual ?? this.quantityActual,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [
    lineNo,
    name,
    code,
    unit,
    quantityDoc,
    quantityActual,
    unitPrice,
  ];
}

const Object _sentinel = Object();
