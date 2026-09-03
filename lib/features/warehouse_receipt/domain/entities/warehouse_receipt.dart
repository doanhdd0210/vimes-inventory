import 'package:equatable/equatable.dart';

import 'warehouse_receipt_item.dart';

enum ReceiptStatus { draft, posted, cancelled }

/// A goods-receipt note (Phiếu nhập kho — Mẫu 01‑VT). Master data is referenced
/// by id with a display-name snapshot alongside, so a renamed master never
/// rewrites history. `totalAmount` is derived.
class WarehouseReceipt extends Equatable {
  const WarehouseReceipt({
    required this.id,
    required this.receiptNumber,
    required this.receiptDate,
    required this.organizationId,
    required this.organizationName,
    required this.warehouseId,
    required this.warehouseName,
    required this.delivererUserId,
    required this.delivererName,
    required this.items,
    this.departmentId,
    this.departmentName,
    this.warehouseLocation,
    this.debitAccount,
    this.creditAccount,
    this.referenceDocNumber,
    this.referenceDocDate,
    this.referenceDocIssuer,
    this.attachedDocumentCount = 0,
    this.preparerUserId,
    this.preparerName,
    this.storekeeperUserId,
    this.storekeeperName,
    this.chiefAccountantUserId,
    this.chiefAccountantName,
    this.status = ReceiptStatus.posted,
    this.postedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// Số phiếu.
  final String receiptNumber;

  /// Ngày … tháng … năm.
  final DateTime receiptDate;

  final String organizationId; // Đơn vị
  final String organizationName;
  final String? departmentId; // Bộ phận
  final String? departmentName;

  final String? debitAccount; // Nợ
  final String? creditAccount; // Có

  /// Nhập tại kho.
  final String warehouseId;
  final String warehouseName;
  final String? warehouseLocation; // địa điểm

  /// Họ và tên người giao.
  final String delivererUserId;
  final String delivererName;

  final String? referenceDocNumber; // "Theo … số …"
  final DateTime? referenceDocDate; // "… ngày …"
  final String? referenceDocIssuer; // "… của …"

  /// Số chứng từ gốc kèm theo.
  final int attachedDocumentCount;

  final String? preparerUserId; // Người lập phiếu
  final String? preparerName;
  final String? storekeeperUserId; // Thủ kho
  final String? storekeeperName;
  final String? chiefAccountantUserId; // Kế toán trưởng
  final String? chiefAccountantName;

  final ReceiptStatus status;
  final DateTime? postedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<WarehouseReceiptItem> items;

  /// Cộng — sum of every line's thành tiền.
  num get totalAmount => items.fold<num>(0, (sum, item) => sum + item.amount);

  WarehouseReceipt copyWith({
    String? id,
    ReceiptStatus? status,
    DateTime? postedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseReceipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber,
      receiptDate: receiptDate,
      organizationId: organizationId,
      organizationName: organizationName,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      delivererUserId: delivererUserId,
      delivererName: delivererName,
      items: items,
      departmentId: departmentId,
      departmentName: departmentName,
      warehouseLocation: warehouseLocation,
      debitAccount: debitAccount,
      creditAccount: creditAccount,
      referenceDocNumber: referenceDocNumber,
      referenceDocDate: referenceDocDate,
      referenceDocIssuer: referenceDocIssuer,
      attachedDocumentCount: attachedDocumentCount,
      preparerUserId: preparerUserId,
      preparerName: preparerName,
      storekeeperUserId: storekeeperUserId,
      storekeeperName: storekeeperName,
      chiefAccountantUserId: chiefAccountantUserId,
      chiefAccountantName: chiefAccountantName,
      status: status ?? this.status,
      postedAt: postedAt ?? this.postedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    receiptNumber,
    receiptDate,
    organizationId,
    organizationName,
    departmentId,
    departmentName,
    debitAccount,
    creditAccount,
    warehouseId,
    warehouseName,
    warehouseLocation,
    delivererUserId,
    delivererName,
    referenceDocNumber,
    referenceDocDate,
    referenceDocIssuer,
    attachedDocumentCount,
    preparerUserId,
    preparerName,
    storekeeperUserId,
    storekeeperName,
    chiefAccountantUserId,
    chiefAccountantName,
    status,
    postedAt,
    createdAt,
    updatedAt,
    items,
  ];
}
