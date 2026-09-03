import 'package:equatable/equatable.dart';

import '../../domain/entities/warehouse_receipt.dart';
import '../../domain/entities/warehouse_receipt_item.dart';

/// Editable draft of one line, held in form state. `lineNo` is derived from
/// position at submit time, so it is not stored here.
class ReceiptItemFormData extends Equatable {
  const ReceiptItemFormData({
    required this.rowId,
    this.name = '',
    this.code = '',
    this.unit = '',
    this.quantityDoc,
    this.quantityActual,
    this.unitPrice,
  });

  final String rowId;
  final String name;
  final String code;
  final String unit;
  final num? quantityDoc;
  final num? quantityActual;
  final num? unitPrice;

  num get amount => ((quantityActual ?? 0) * (unitPrice ?? 0)).roundToDouble();

  ReceiptItemFormData copyWith({
    String? name,
    String? code,
    String? unit,
    Object? quantityDoc = _keep,
    Object? quantityActual = _keep,
    Object? unitPrice = _keep,
  }) {
    return ReceiptItemFormData(
      rowId: rowId,
      name: name ?? this.name,
      code: code ?? this.code,
      unit: unit ?? this.unit,
      quantityDoc: identical(quantityDoc, _keep)
          ? this.quantityDoc
          : quantityDoc as num?,
      quantityActual: identical(quantityActual, _keep)
          ? this.quantityActual
          : quantityActual as num?,
      unitPrice: identical(unitPrice, _keep)
          ? this.unitPrice
          : unitPrice as num?,
    );
  }

  WarehouseReceiptItem toEntity(int lineNo) => WarehouseReceiptItem(
    lineNo: lineNo,
    name: name.trim(),
    code: code.trim().isEmpty ? null : code.trim(),
    unit: unit.trim(),
    quantityDoc: quantityDoc,
    quantityActual: quantityActual ?? 0,
    unitPrice: unitPrice ?? 0,
  );

  @override
  List<Object?> get props => [
    rowId,
    name,
    code,
    unit,
    quantityDoc,
    quantityActual,
    unitPrice,
  ];
}

/// Full form draft: header fields + line drafts.
class ReceiptFormData extends Equatable {
  const ReceiptFormData({
    this.receiptNumber = '',
    this.receiptDate,
    this.unitName = '',
    this.department = '',
    this.debitAccount = '',
    this.creditAccount = '',
    this.delivererName = '',
    this.referenceDocNumber = '',
    this.referenceDocDate,
    this.referenceDocIssuer = '',
    this.warehouseName = '',
    this.warehouseLocation = '',
    this.attachedDocumentCount = 0,
    this.preparerName = '',
    this.storekeeperName = '',
    this.chiefAccountantName = '',
    this.items = const [],
  });

  final String receiptNumber;
  final DateTime? receiptDate;
  final String unitName;
  final String department;
  final String debitAccount;
  final String creditAccount;
  final String delivererName;
  final String referenceDocNumber;
  final DateTime? referenceDocDate;
  final String referenceDocIssuer;
  final String warehouseName;
  final String warehouseLocation;
  final int attachedDocumentCount;
  final String preparerName;
  final String storekeeperName;
  final String chiefAccountantName;
  final List<ReceiptItemFormData> items;

  num get totalAmount => items.fold<num>(0, (sum, item) => sum + item.amount);

  ReceiptFormData copyWith({
    String? receiptNumber,
    Object? receiptDate = _keep,
    String? unitName,
    String? department,
    String? debitAccount,
    String? creditAccount,
    String? delivererName,
    String? referenceDocNumber,
    Object? referenceDocDate = _keep,
    String? referenceDocIssuer,
    String? warehouseName,
    String? warehouseLocation,
    int? attachedDocumentCount,
    String? preparerName,
    String? storekeeperName,
    String? chiefAccountantName,
    List<ReceiptItemFormData>? items,
  }) {
    return ReceiptFormData(
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptDate: identical(receiptDate, _keep)
          ? this.receiptDate
          : receiptDate as DateTime?,
      unitName: unitName ?? this.unitName,
      department: department ?? this.department,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      delivererName: delivererName ?? this.delivererName,
      referenceDocNumber: referenceDocNumber ?? this.referenceDocNumber,
      referenceDocDate: identical(referenceDocDate, _keep)
          ? this.referenceDocDate
          : referenceDocDate as DateTime?,
      referenceDocIssuer: referenceDocIssuer ?? this.referenceDocIssuer,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      attachedDocumentCount:
          attachedDocumentCount ?? this.attachedDocumentCount,
      preparerName: preparerName ?? this.preparerName,
      storekeeperName: storekeeperName ?? this.storekeeperName,
      chiefAccountantName: chiefAccountantName ?? this.chiefAccountantName,
      items: items ?? this.items,
    );
  }

  WarehouseReceipt toEntity() {
    var line = 0;
    return WarehouseReceipt(
      id: '',
      receiptNumber: receiptNumber.trim(),
      receiptDate: receiptDate ?? DateTime.now(),
      delivererName: delivererName.trim(),
      warehouseName: warehouseName.trim(),
      items: items.map((i) => i.toEntity(++line)).toList(growable: false),
      unitName: unitName.trim().isEmpty ? null : unitName.trim(),
      department: department.trim().isEmpty ? null : department.trim(),
      debitAccount: debitAccount.trim().isEmpty ? null : debitAccount.trim(),
      creditAccount: creditAccount.trim().isEmpty ? null : creditAccount.trim(),
      referenceDocNumber: referenceDocNumber.trim().isEmpty
          ? null
          : referenceDocNumber.trim(),
      referenceDocDate: referenceDocDate,
      referenceDocIssuer: referenceDocIssuer.trim().isEmpty
          ? null
          : referenceDocIssuer.trim(),
      warehouseLocation: warehouseLocation.trim().isEmpty
          ? null
          : warehouseLocation.trim(),
      attachedDocumentCount: attachedDocumentCount,
      preparerName: preparerName.trim().isEmpty ? null : preparerName.trim(),
      storekeeperName: storekeeperName.trim().isEmpty
          ? null
          : storekeeperName.trim(),
      chiefAccountantName: chiefAccountantName.trim().isEmpty
          ? null
          : chiefAccountantName.trim(),
    );
  }

  @override
  List<Object?> get props => [
    receiptNumber,
    receiptDate,
    unitName,
    department,
    debitAccount,
    creditAccount,
    delivererName,
    referenceDocNumber,
    referenceDocDate,
    referenceDocIssuer,
    warehouseName,
    warehouseLocation,
    attachedDocumentCount,
    preparerName,
    storekeeperName,
    chiefAccountantName,
    items,
  ];
}

const Object _keep = Object();
