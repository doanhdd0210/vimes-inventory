part of 'receipt_form_bloc.dart';

sealed class ReceiptFormEvent extends Equatable {
  const ReceiptFormEvent();

  @override
  List<Object?> get props => [];
}

/// Patch one or more header fields. Only non-null args are applied; pass
/// [touchedKeys] so the matching validation errors clear as the user types.
class ReceiptHeaderChanged extends ReceiptFormEvent {
  const ReceiptHeaderChanged({
    this.receiptNumber,
    this.receiptDate,
    this.unitName,
    this.department,
    this.debitAccount,
    this.creditAccount,
    this.delivererName,
    this.referenceDocNumber,
    this.referenceDocDate,
    this.referenceDocIssuer,
    this.warehouseName,
    this.warehouseLocation,
    this.attachedDocumentCount,
    this.preparerName,
    this.storekeeperName,
    this.chiefAccountantName,
  });

  final String? receiptNumber;
  final DateTime? receiptDate;
  final String? unitName;
  final String? department;
  final String? debitAccount;
  final String? creditAccount;
  final String? delivererName;
  final String? referenceDocNumber;
  final DateTime? referenceDocDate;
  final String? referenceDocIssuer;
  final String? warehouseName;
  final String? warehouseLocation;
  final int? attachedDocumentCount;
  final String? preparerName;
  final String? storekeeperName;
  final String? chiefAccountantName;

  List<String> get touchedKeys => [
    if (receiptNumber != null) 'receiptNumber',
    if (delivererName != null) 'delivererName',
    if (warehouseName != null) 'warehouseName',
    if (attachedDocumentCount != null) 'attachedDocumentCount',
  ];

  ReceiptFormData apply(ReceiptFormData data) => data.copyWith(
    receiptNumber: receiptNumber,
    receiptDate: receiptDate,
    unitName: unitName,
    department: department,
    debitAccount: debitAccount,
    creditAccount: creditAccount,
    delivererName: delivererName,
    referenceDocNumber: referenceDocNumber,
    referenceDocDate: referenceDocDate,
    referenceDocIssuer: referenceDocIssuer,
    warehouseName: warehouseName,
    warehouseLocation: warehouseLocation,
    attachedDocumentCount: attachedDocumentCount,
    preparerName: preparerName,
    storekeeperName: storekeeperName,
    chiefAccountantName: chiefAccountantName,
  );

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
  ];
}

class ReceiptItemAdded extends ReceiptFormEvent {
  const ReceiptItemAdded();
}

class ReceiptItemRemoved extends ReceiptFormEvent {
  const ReceiptItemRemoved(this.rowId);

  final String rowId;

  @override
  List<Object?> get props => [rowId];
}

/// The row widget owns its controllers and emits its whole current value on
/// every edit, so this carries the full [ReceiptItemFormData].
class ReceiptItemChanged extends ReceiptFormEvent {
  const ReceiptItemChanged(this.row);

  final ReceiptItemFormData row;

  String get rowId => row.rowId;

  @override
  List<Object?> get props => [row];
}

class ReceiptSubmitted extends ReceiptFormEvent {
  const ReceiptSubmitted();
}
