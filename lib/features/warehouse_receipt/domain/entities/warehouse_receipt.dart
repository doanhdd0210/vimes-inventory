import 'package:equatable/equatable.dart';

import 'warehouse_receipt_item.dart';

enum ReceiptStatus { draft, posted }

/// A goods-receipt note (Phiếu nhập kho — Mẫu 01‑VT): header fields plus the
/// list of received items. `totalAmount` / `totalAmountInWords` are derived and
/// never trusted from storage.
class WarehouseReceipt extends Equatable {
  const WarehouseReceipt({
    required this.id,
    required this.receiptNumber,
    required this.receiptDate,
    required this.delivererName,
    required this.warehouseName,
    required this.items,
    this.unitName,
    this.department,
    this.debitAccount,
    this.creditAccount,
    this.referenceDocNumber,
    this.referenceDocDate,
    this.referenceDocIssuer,
    this.warehouseLocation,
    this.attachedDocumentCount = 0,
    this.preparerName,
    this.storekeeperName,
    this.chiefAccountantName,
    this.status = ReceiptStatus.posted,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// Số phiếu.
  final String receiptNumber;

  /// Ngày … tháng … năm.
  final DateTime receiptDate;

  final String? unitName; // Đơn vị
  final String? department; // Bộ phận
  final String? debitAccount; // Nợ
  final String? creditAccount; // Có

  /// Họ và tên người giao.
  final String delivererName;

  final String? referenceDocNumber; // "Theo … số …"
  final DateTime? referenceDocDate; // "… ngày …"
  final String? referenceDocIssuer; // "… của …"

  /// Nhập tại kho.
  final String warehouseName;
  final String? warehouseLocation; // địa điểm

  /// Số chứng từ gốc kèm theo.
  final int attachedDocumentCount;

  final String? preparerName; // Người lập phiếu
  final String? storekeeperName; // Thủ kho
  final String? chiefAccountantName; // Kế toán trưởng

  final ReceiptStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<WarehouseReceiptItem> items;

  /// Cộng — sum of every line's thành tiền.
  num get totalAmount => items.fold<num>(0, (sum, item) => sum + item.amount);

  WarehouseReceipt copyWith({
    String? id,
    String? receiptNumber,
    DateTime? receiptDate,
    String? delivererName,
    String? warehouseName,
    List<WarehouseReceiptItem>? items,
    String? unitName,
    String? department,
    String? debitAccount,
    String? creditAccount,
    String? referenceDocNumber,
    DateTime? referenceDocDate,
    String? referenceDocIssuer,
    String? warehouseLocation,
    int? attachedDocumentCount,
    String? preparerName,
    String? storekeeperName,
    String? chiefAccountantName,
    ReceiptStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseReceipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptDate: receiptDate ?? this.receiptDate,
      delivererName: delivererName ?? this.delivererName,
      warehouseName: warehouseName ?? this.warehouseName,
      items: items ?? this.items,
      unitName: unitName ?? this.unitName,
      department: department ?? this.department,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      referenceDocNumber: referenceDocNumber ?? this.referenceDocNumber,
      referenceDocDate: referenceDocDate ?? this.referenceDocDate,
      referenceDocIssuer: referenceDocIssuer ?? this.referenceDocIssuer,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      attachedDocumentCount:
          attachedDocumentCount ?? this.attachedDocumentCount,
      preparerName: preparerName ?? this.preparerName,
      storekeeperName: storekeeperName ?? this.storekeeperName,
      chiefAccountantName: chiefAccountantName ?? this.chiefAccountantName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
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
    status,
    createdAt,
    updatedAt,
    items,
  ];
}
