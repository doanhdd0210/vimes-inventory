import 'package:equatable/equatable.dart';

import '../../../master_data/domain/entities/item.dart';
import '../../domain/entities/warehouse_receipt.dart';
import '../../domain/entities/warehouse_receipt_item.dart';

const Object _keep = Object();

/// Editable draft of one line. Picking an [Item] fills the snapshot fields.
class ReceiptItemFormData extends Equatable {
  const ReceiptItemFormData({
    required this.rowId,
    this.itemId,
    this.name = '',
    this.code = '',
    this.unit = '',
    this.uomId,
    this.quantityDoc,
    this.quantityActual,
    this.unitPrice,
  });

  final String rowId;
  final String? itemId;
  final String name;
  final String code;
  final String unit;
  final String? uomId;
  final num? quantityDoc;
  final num? quantityActual;
  final num? unitPrice;

  num get amount => ((quantityActual ?? 0) * (unitPrice ?? 0)).roundToDouble();

  ReceiptItemFormData fromItem(Item item, {String? unitName}) => copyWith(
    itemId: item.id,
    name: item.name,
    code: item.code,
    unit: unitName ?? unit,
    uomId: item.uomId,
    unitPrice: unitPrice ?? item.defaultUnitPrice,
  );

  ReceiptItemFormData copyWith({
    Object? itemId = _keep,
    String? name,
    String? code,
    String? unit,
    Object? uomId = _keep,
    Object? quantityDoc = _keep,
    Object? quantityActual = _keep,
    Object? unitPrice = _keep,
  }) {
    return ReceiptItemFormData(
      rowId: rowId,
      itemId: identical(itemId, _keep) ? this.itemId : itemId as String?,
      name: name ?? this.name,
      code: code ?? this.code,
      unit: unit ?? this.unit,
      uomId: identical(uomId, _keep) ? this.uomId : uomId as String?,
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
    itemId: itemId ?? '',
    name: name.trim(),
    code: code.trim().isEmpty ? null : code.trim(),
    unit: unit.trim(),
    uomId: uomId,
    quantityDoc: quantityDoc,
    quantityActual: quantityActual ?? 0,
    unitPrice: unitPrice ?? 0,
  );

  @override
  List<Object?> get props => [
    rowId,
    itemId,
    name,
    code,
    unit,
    uomId,
    quantityDoc,
    quantityActual,
    unitPrice,
  ];
}

/// Full form draft: header (ids + name snapshots) + line drafts.
class ReceiptFormData extends Equatable {
  const ReceiptFormData({
    this.receiptNumber = '',
    this.receiptDate,
    this.organizationId = '',
    this.organizationName = '',
    this.departmentId,
    this.departmentName,
    this.debitAccount = '',
    this.creditAccount = '',
    this.delivererUserId = '',
    this.delivererName = '',
    this.referenceDocNumber = '',
    this.referenceDocDate,
    this.referenceDocIssuer = '',
    this.warehouseId = '',
    this.warehouseName = '',
    this.warehouseLocation,
    this.attachedDocumentCount = 0,
    this.preparerUserId,
    this.preparerName,
    this.storekeeperUserId,
    this.storekeeperName,
    this.chiefAccountantUserId,
    this.chiefAccountantName,
    this.items = const [],
  });

  final String receiptNumber;
  final DateTime? receiptDate;
  final String organizationId;
  final String organizationName;
  final String? departmentId;
  final String? departmentName;
  final String debitAccount;
  final String creditAccount;
  final String delivererUserId;
  final String delivererName;
  final String referenceDocNumber;
  final DateTime? referenceDocDate;
  final String referenceDocIssuer;
  final String warehouseId;
  final String warehouseName;
  final String? warehouseLocation;
  final int attachedDocumentCount;
  final String? preparerUserId;
  final String? preparerName;
  final String? storekeeperUserId;
  final String? storekeeperName;
  final String? chiefAccountantUserId;
  final String? chiefAccountantName;
  final List<ReceiptItemFormData> items;

  num get totalAmount => items.fold<num>(0, (sum, item) => sum + item.amount);

  ReceiptFormData copyWith({
    String? receiptNumber,
    Object? receiptDate = _keep,
    String? organizationId,
    String? organizationName,
    Object? departmentId = _keep,
    Object? departmentName = _keep,
    String? debitAccount,
    String? creditAccount,
    String? delivererUserId,
    String? delivererName,
    String? referenceDocNumber,
    Object? referenceDocDate = _keep,
    String? referenceDocIssuer,
    String? warehouseId,
    String? warehouseName,
    Object? warehouseLocation = _keep,
    int? attachedDocumentCount,
    Object? preparerUserId = _keep,
    Object? preparerName = _keep,
    Object? storekeeperUserId = _keep,
    Object? storekeeperName = _keep,
    Object? chiefAccountantUserId = _keep,
    Object? chiefAccountantName = _keep,
    List<ReceiptItemFormData>? items,
  }) {
    return ReceiptFormData(
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptDate: identical(receiptDate, _keep)
          ? this.receiptDate
          : receiptDate as DateTime?,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      departmentId: identical(departmentId, _keep)
          ? this.departmentId
          : departmentId as String?,
      departmentName: identical(departmentName, _keep)
          ? this.departmentName
          : departmentName as String?,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      delivererUserId: delivererUserId ?? this.delivererUserId,
      delivererName: delivererName ?? this.delivererName,
      referenceDocNumber: referenceDocNumber ?? this.referenceDocNumber,
      referenceDocDate: identical(referenceDocDate, _keep)
          ? this.referenceDocDate
          : referenceDocDate as DateTime?,
      referenceDocIssuer: referenceDocIssuer ?? this.referenceDocIssuer,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseLocation: identical(warehouseLocation, _keep)
          ? this.warehouseLocation
          : warehouseLocation as String?,
      attachedDocumentCount:
          attachedDocumentCount ?? this.attachedDocumentCount,
      preparerUserId: identical(preparerUserId, _keep)
          ? this.preparerUserId
          : preparerUserId as String?,
      preparerName: identical(preparerName, _keep)
          ? this.preparerName
          : preparerName as String?,
      storekeeperUserId: identical(storekeeperUserId, _keep)
          ? this.storekeeperUserId
          : storekeeperUserId as String?,
      storekeeperName: identical(storekeeperName, _keep)
          ? this.storekeeperName
          : storekeeperName as String?,
      chiefAccountantUserId: identical(chiefAccountantUserId, _keep)
          ? this.chiefAccountantUserId
          : chiefAccountantUserId as String?,
      chiefAccountantName: identical(chiefAccountantName, _keep)
          ? this.chiefAccountantName
          : chiefAccountantName as String?,
      items: items ?? this.items,
    );
  }

  WarehouseReceipt toEntity() {
    var line = 0;
    return WarehouseReceipt(
      id: '',
      receiptNumber: receiptNumber.trim(),
      receiptDate: receiptDate ?? DateTime.now(),
      organizationId: organizationId,
      organizationName: organizationName,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      warehouseLocation: warehouseLocation,
      delivererUserId: delivererUserId,
      delivererName: delivererName,
      items: items.map((i) => i.toEntity(++line)).toList(growable: false),
      departmentId: departmentId,
      departmentName: departmentName,
      debitAccount: debitAccount.trim().isEmpty ? null : debitAccount.trim(),
      creditAccount: creditAccount.trim().isEmpty ? null : creditAccount.trim(),
      referenceDocNumber: referenceDocNumber.trim().isEmpty
          ? null
          : referenceDocNumber.trim(),
      referenceDocDate: referenceDocDate,
      referenceDocIssuer: referenceDocIssuer.trim().isEmpty
          ? null
          : referenceDocIssuer.trim(),
      attachedDocumentCount: attachedDocumentCount,
      preparerUserId: preparerUserId,
      preparerName: preparerName,
      storekeeperUserId: storekeeperUserId,
      storekeeperName: storekeeperName,
      chiefAccountantUserId: chiefAccountantUserId,
      chiefAccountantName: chiefAccountantName,
    );
  }

  @override
  List<Object?> get props => [
    receiptNumber,
    receiptDate,
    organizationId,
    organizationName,
    departmentId,
    departmentName,
    debitAccount,
    creditAccount,
    delivererUserId,
    delivererName,
    referenceDocNumber,
    referenceDocDate,
    referenceDocIssuer,
    warehouseId,
    warehouseName,
    warehouseLocation,
    attachedDocumentCount,
    preparerUserId,
    preparerName,
    storekeeperUserId,
    storekeeperName,
    chiefAccountantUserId,
    chiefAccountantName,
    items,
  ];
}
