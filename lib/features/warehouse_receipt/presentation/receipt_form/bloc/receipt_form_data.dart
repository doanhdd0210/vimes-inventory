import 'package:equatable/equatable.dart';

import '../../../../master_data/domain/entities/item.dart';
import '../../../domain/entities/warehouse_receipt.dart';
import '../../../domain/entities/warehouse_receipt_item.dart';

/// copyWith sentinel: an argument left at [keepField] keeps the current value;
/// passing an explicit `null` clears it. Lets callers patch one nullable field
/// without wiping the others.
const Object keepField = Object();

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
    Object? itemId = keepField,
    String? name,
    String? code,
    String? unit,
    Object? uomId = keepField,
    Object? quantityDoc = keepField,
    Object? quantityActual = keepField,
    Object? unitPrice = keepField,
  }) {
    return ReceiptItemFormData(
      rowId: rowId,
      itemId: identical(itemId, keepField) ? this.itemId : itemId as String?,
      name: name ?? this.name,
      code: code ?? this.code,
      unit: unit ?? this.unit,
      uomId: identical(uomId, keepField) ? this.uomId : uomId as String?,
      quantityDoc: identical(quantityDoc, keepField)
          ? this.quantityDoc
          : quantityDoc as num?,
      quantityActual: identical(quantityActual, keepField)
          ? this.quantityActual
          : quantityActual as num?,
      unitPrice: identical(unitPrice, keepField)
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

/// The four people who sign a phiếu nhập kho (Mẫu 01‑VT signature block).
enum SignatureRole { preparer, deliverer, storekeeper, chiefAccountant }

extension SignatureRoleX on SignatureRole {
  /// Key used in the form's error map + as the persisted field name prefix.
  String get errorKey => switch (this) {
    SignatureRole.preparer => 'preparerSignature',
    SignatureRole.deliverer => 'delivererSignature',
    SignatureRole.storekeeper => 'storekeeperSignature',
    SignatureRole.chiefAccountant => 'chiefAccountantSignature',
  };

  String get label => switch (this) {
    SignatureRole.preparer => 'Người lập phiếu',
    SignatureRole.deliverer => 'Người giao hàng',
    SignatureRole.storekeeper => 'Thủ kho',
    SignatureRole.chiefAccountant => 'Kế toán trưởng',
  };
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
    this.preparerSignature,
    this.storekeeperUserId,
    this.storekeeperName,
    this.storekeeperSignature,
    this.chiefAccountantUserId,
    this.chiefAccountantName,
    this.chiefAccountantSignature,
    this.delivererSignature,
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
  final String? preparerSignature;
  final String? storekeeperUserId;
  final String? storekeeperName;
  final String? storekeeperSignature;
  final String? chiefAccountantUserId;
  final String? chiefAccountantName;
  final String? chiefAccountantSignature;
  final String? delivererSignature;
  final List<ReceiptItemFormData> items;

  num get totalAmount => items.fold<num>(0, (sum, item) => sum + item.amount);

  /// Base64 PNG for [role], or null if not signed yet.
  String? signatureOf(SignatureRole role) => switch (role) {
    SignatureRole.preparer => preparerSignature,
    SignatureRole.deliverer => delivererSignature,
    SignatureRole.storekeeper => storekeeperSignature,
    SignatureRole.chiefAccountant => chiefAccountantSignature,
  };

  ReceiptFormData withSignature(SignatureRole role, String? png) =>
      switch (role) {
        SignatureRole.preparer => copyWith(preparerSignature: png),
        SignatureRole.deliverer => copyWith(delivererSignature: png),
        SignatureRole.storekeeper => copyWith(storekeeperSignature: png),
        SignatureRole.chiefAccountant => copyWith(
          chiefAccountantSignature: png,
        ),
      };

  /// Error keys for every signature still missing — used to gate submit.
  List<String> get missingSignatureKeys => [
    for (final r in SignatureRole.values)
      if ((signatureOf(r) ?? '').isEmpty) r.errorKey,
  ];

  ReceiptFormData copyWith({
    String? receiptNumber,
    Object? receiptDate = keepField,
    String? organizationId,
    String? organizationName,
    Object? departmentId = keepField,
    Object? departmentName = keepField,
    String? debitAccount,
    String? creditAccount,
    String? delivererUserId,
    String? delivererName,
    String? referenceDocNumber,
    Object? referenceDocDate = keepField,
    String? referenceDocIssuer,
    String? warehouseId,
    String? warehouseName,
    Object? warehouseLocation = keepField,
    int? attachedDocumentCount,
    Object? preparerUserId = keepField,
    Object? preparerName = keepField,
    Object? preparerSignature = keepField,
    Object? storekeeperUserId = keepField,
    Object? storekeeperName = keepField,
    Object? storekeeperSignature = keepField,
    Object? chiefAccountantUserId = keepField,
    Object? chiefAccountantName = keepField,
    Object? chiefAccountantSignature = keepField,
    Object? delivererSignature = keepField,
    List<ReceiptItemFormData>? items,
  }) {
    return ReceiptFormData(
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptDate: identical(receiptDate, keepField)
          ? this.receiptDate
          : receiptDate as DateTime?,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      departmentId: identical(departmentId, keepField)
          ? this.departmentId
          : departmentId as String?,
      departmentName: identical(departmentName, keepField)
          ? this.departmentName
          : departmentName as String?,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      delivererUserId: delivererUserId ?? this.delivererUserId,
      delivererName: delivererName ?? this.delivererName,
      referenceDocNumber: referenceDocNumber ?? this.referenceDocNumber,
      referenceDocDate: identical(referenceDocDate, keepField)
          ? this.referenceDocDate
          : referenceDocDate as DateTime?,
      referenceDocIssuer: referenceDocIssuer ?? this.referenceDocIssuer,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseLocation: identical(warehouseLocation, keepField)
          ? this.warehouseLocation
          : warehouseLocation as String?,
      attachedDocumentCount:
          attachedDocumentCount ?? this.attachedDocumentCount,
      preparerUserId: identical(preparerUserId, keepField)
          ? this.preparerUserId
          : preparerUserId as String?,
      preparerName: identical(preparerName, keepField)
          ? this.preparerName
          : preparerName as String?,
      preparerSignature: identical(preparerSignature, keepField)
          ? this.preparerSignature
          : preparerSignature as String?,
      storekeeperUserId: identical(storekeeperUserId, keepField)
          ? this.storekeeperUserId
          : storekeeperUserId as String?,
      storekeeperName: identical(storekeeperName, keepField)
          ? this.storekeeperName
          : storekeeperName as String?,
      storekeeperSignature: identical(storekeeperSignature, keepField)
          ? this.storekeeperSignature
          : storekeeperSignature as String?,
      chiefAccountantUserId: identical(chiefAccountantUserId, keepField)
          ? this.chiefAccountantUserId
          : chiefAccountantUserId as String?,
      chiefAccountantName: identical(chiefAccountantName, keepField)
          ? this.chiefAccountantName
          : chiefAccountantName as String?,
      chiefAccountantSignature: identical(chiefAccountantSignature, keepField)
          ? this.chiefAccountantSignature
          : chiefAccountantSignature as String?,
      delivererSignature: identical(delivererSignature, keepField)
          ? this.delivererSignature
          : delivererSignature as String?,
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
      preparerSignature: preparerSignature,
      storekeeperUserId: storekeeperUserId,
      storekeeperName: storekeeperName,
      storekeeperSignature: storekeeperSignature,
      chiefAccountantUserId: chiefAccountantUserId,
      chiefAccountantName: chiefAccountantName,
      chiefAccountantSignature: chiefAccountantSignature,
      delivererSignature: delivererSignature,
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
    preparerSignature,
    storekeeperUserId,
    storekeeperName,
    storekeeperSignature,
    chiefAccountantUserId,
    chiefAccountantName,
    chiefAccountantSignature,
    delivererSignature,
    items,
  ];
}
