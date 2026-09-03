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
    required super.delivererName,
    required super.warehouseName,
    required super.items,
    super.unitName,
    super.department,
    super.debitAccount,
    super.creditAccount,
    super.referenceDocNumber,
    super.referenceDocDate,
    super.referenceDocIssuer,
    super.warehouseLocation,
    super.attachedDocumentCount,
    super.preparerName,
    super.storekeeperName,
    super.chiefAccountantName,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory WarehouseReceiptModel.fromEntity(WarehouseReceipt e) =>
      WarehouseReceiptModel(
        id: e.id,
        receiptNumber: e.receiptNumber,
        receiptDate: e.receiptDate,
        delivererName: e.delivererName,
        warehouseName: e.warehouseName,
        items: e.items
            .map(WarehouseReceiptItemModel.fromEntity)
            .toList(growable: false),
        unitName: e.unitName,
        department: e.department,
        debitAccount: e.debitAccount,
        creditAccount: e.creditAccount,
        referenceDocNumber: e.referenceDocNumber,
        referenceDocDate: e.referenceDocDate,
        referenceDocIssuer: e.referenceDocIssuer,
        warehouseLocation: e.warehouseLocation,
        attachedDocumentCount: e.attachedDocumentCount,
        preparerName: e.preparerName,
        storekeeperName: e.storekeeperName,
        chiefAccountantName: e.chiefAccountantName,
        status: e.status,
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
      delivererName: map['delivererName'] as String? ?? '',
      warehouseName: map['warehouseName'] as String? ?? '',
      items: rawItems,
      unitName: map['unitName'] as String?,
      department: map['department'] as String?,
      debitAccount: map['debitAccount'] as String?,
      creditAccount: map['creditAccount'] as String?,
      referenceDocNumber: map['referenceDocNumber'] as String?,
      referenceDocDate: _date(map['referenceDocDate']),
      referenceDocIssuer: map['referenceDocIssuer'] as String?,
      warehouseLocation: map['warehouseLocation'] as String?,
      attachedDocumentCount:
          (map['attachedDocumentCount'] as num?)?.toInt() ?? 0,
      preparerName: map['preparerName'] as String?,
      storekeeperName: map['storekeeperName'] as String?,
      chiefAccountantName: map['chiefAccountantName'] as String?,
      status: _status(map['status']),
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
    'unitName': unitName,
    'department': department,
    'debitAccount': debitAccount,
    'creditAccount': creditAccount,
    'delivererName': delivererName,
    'referenceDocNumber': referenceDocNumber,
    'referenceDocDate': referenceDocDate == null
        ? null
        : Timestamp.fromDate(referenceDocDate!),
    'referenceDocIssuer': referenceDocIssuer,
    'warehouseName': warehouseName,
    'warehouseLocation': warehouseLocation,
    'attachedDocumentCount': attachedDocumentCount,
    'totalAmount': totalAmount,
    'totalAmountInWords': VndWords.of(totalAmount),
    'preparerName': preparerName,
    'storekeeperName': storekeeperName,
    'chiefAccountantName': chiefAccountantName,
    'status': status.name,
    'items': items
        .map(WarehouseReceiptItemModel.fromEntity)
        .map((e) => e.toMap())
        .toList(growable: false),
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
