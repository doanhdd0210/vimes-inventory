import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/helpers/vnd_words.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/warehouse_receipt.dart';
import 'warehouse_receipt_item_model.dart';

class WarehouseReceiptModel extends WarehouseReceipt {
  const WarehouseReceiptModel({
    required super.id,
    required super.receiptNumber,
    required super.receiptDate,
    required super.organizationId,
    required super.organizationName,
    required super.warehouseId,
    required super.warehouseName,
    required super.delivererUserId,
    required super.delivererName,
    required super.items,
    super.departmentId,
    super.departmentName,
    super.warehouseLocation,
    super.debitAccount,
    super.creditAccount,
    super.referenceDocNumber,
    super.referenceDocDate,
    super.referenceDocIssuer,
    super.attachedDocumentCount,
    super.preparerUserId,
    super.preparerName,
    super.preparerSignature,
    super.storekeeperUserId,
    super.storekeeperName,
    super.storekeeperSignature,
    super.chiefAccountantUserId,
    super.chiefAccountantName,
    super.chiefAccountantSignature,
    super.delivererSignature,
    super.status,
    super.postedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory WarehouseReceiptModel.fromEntity(WarehouseReceipt e) =>
      WarehouseReceiptModel(
        id: e.id,
        receiptNumber: e.receiptNumber,
        receiptDate: e.receiptDate,
        organizationId: e.organizationId,
        organizationName: e.organizationName,
        warehouseId: e.warehouseId,
        warehouseName: e.warehouseName,
        delivererUserId: e.delivererUserId,
        delivererName: e.delivererName,
        items: e.items
            .map(WarehouseReceiptItemModel.fromEntity)
            .toList(growable: false),
        departmentId: e.departmentId,
        departmentName: e.departmentName,
        warehouseLocation: e.warehouseLocation,
        debitAccount: e.debitAccount,
        creditAccount: e.creditAccount,
        referenceDocNumber: e.referenceDocNumber,
        referenceDocDate: e.referenceDocDate,
        referenceDocIssuer: e.referenceDocIssuer,
        attachedDocumentCount: e.attachedDocumentCount,
        preparerUserId: e.preparerUserId,
        preparerName: e.preparerName,
        preparerSignature: e.preparerSignature,
        storekeeperUserId: e.storekeeperUserId,
        storekeeperName: e.storekeeperName,
        storekeeperSignature: e.storekeeperSignature,
        chiefAccountantUserId: e.chiefAccountantUserId,
        chiefAccountantName: e.chiefAccountantName,
        chiefAccountantSignature: e.chiefAccountantSignature,
        delivererSignature: e.delivererSignature,
        status: e.status,
        postedAt: e.postedAt,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory WarehouseReceiptModel.fromMap(String id, DataMap map) {
    final rawItems =
        (map['items'] as List<dynamic>? ?? const [])
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (e) =>
                  WarehouseReceiptItemModel.fromMap(e.cast<String, dynamic>()),
            )
            .toList(growable: false)
          ..sort((a, b) => a.lineNo.compareTo(b.lineNo));

    return WarehouseReceiptModel(
      id: id,
      receiptNumber: map['receiptNumber'] as String? ?? '',
      receiptDate:
          _date(map['receiptDate']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      organizationId: map['organizationId'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      warehouseId: map['warehouseId'] as String? ?? '',
      warehouseName: map['warehouseName'] as String? ?? '',
      delivererUserId: map['delivererUserId'] as String? ?? '',
      delivererName: map['delivererName'] as String? ?? '',
      items: rawItems,
      departmentId: map['departmentId'] as String?,
      departmentName: map['departmentName'] as String?,
      warehouseLocation: map['warehouseLocation'] as String?,
      debitAccount: map['debitAccount'] as String?,
      creditAccount: map['creditAccount'] as String?,
      referenceDocNumber: map['referenceDocNumber'] as String?,
      referenceDocDate: _date(map['referenceDocDate']),
      referenceDocIssuer: map['referenceDocIssuer'] as String?,
      attachedDocumentCount:
          (map['attachedDocumentCount'] as num?)?.toInt() ?? 0,
      preparerUserId: map['preparerUserId'] as String?,
      preparerName: map['preparerName'] as String?,
      preparerSignature: map['preparerSignature'] as String?,
      storekeeperUserId: map['storekeeperUserId'] as String?,
      storekeeperName: map['storekeeperName'] as String?,
      storekeeperSignature: map['storekeeperSignature'] as String?,
      chiefAccountantUserId: map['chiefAccountantUserId'] as String?,
      chiefAccountantName: map['chiefAccountantName'] as String?,
      chiefAccountantSignature: map['chiefAccountantSignature'] as String?,
      delivererSignature: map['delivererSignature'] as String?,
      status: _status(map['status']),
      postedAt: _date(map['postedAt']),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  factory WarehouseReceiptModel.fromSnapshot(
    DocumentSnapshot<DataMap> snapshot,
  ) => WarehouseReceiptModel.fromMap(
    snapshot.id,
    snapshot.data() ?? const <String, dynamic>{},
  );

  /// Writeable map. [serverTimestamps] swaps `createdAt`/`updatedAt` for
  /// [FieldValue.serverTimestamp] on create.
  DataMap toMap({bool serverTimestamps = true}) => {
    'receiptNumber': receiptNumber,
    'receiptDate': Timestamp.fromDate(receiptDate),
    'organizationId': organizationId,
    'organizationName': organizationName,
    'departmentId': departmentId,
    'departmentName': departmentName,
    'debitAccount': debitAccount,
    'creditAccount': creditAccount,
    'delivererUserId': delivererUserId,
    'delivererName': delivererName,
    'referenceDocNumber': referenceDocNumber,
    'referenceDocDate': referenceDocDate == null
        ? null
        : Timestamp.fromDate(referenceDocDate!),
    'referenceDocIssuer': referenceDocIssuer,
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'warehouseLocation': warehouseLocation,
    'attachedDocumentCount': attachedDocumentCount,
    'totalAmount': totalAmount,
    'totalAmountInWords': VndWords.of(totalAmount),
    'preparerUserId': preparerUserId,
    'preparerName': preparerName,
    'preparerSignature': preparerSignature,
    'storekeeperUserId': storekeeperUserId,
    'storekeeperName': storekeeperName,
    'storekeeperSignature': storekeeperSignature,
    'chiefAccountantUserId': chiefAccountantUserId,
    'chiefAccountantName': chiefAccountantName,
    'chiefAccountantSignature': chiefAccountantSignature,
    'delivererSignature': delivererSignature,
    'status': status.name,
    'items': items
        .map(WarehouseReceiptItemModel.fromEntity)
        .map((e) => e.toMap())
        .toList(growable: false),
    'postedAt': postedAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(postedAt!),
    'createdAt': serverTimestamps
        ? FieldValue.serverTimestamp()
        : (createdAt == null ? null : Timestamp.fromDate(createdAt!)),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static ReceiptStatus _status(Object? value) => ReceiptStatus.values
      .firstWhere((s) => s.name == value, orElse: () => ReceiptStatus.posted);
}
