part of 'receipt_form_bloc.dart';

sealed class ReceiptFormEvent extends Equatable {
  const ReceiptFormEvent();

  @override
  List<Object?> get props => [];
}

/// Load master data for the dropdowns.
class ReceiptFormStarted extends ReceiptFormEvent {
  const ReceiptFormStarted();
}

/// Patch one or more header fields. Id fields carry their resolved display name
/// so the View doesn't have to round-trip through the bloc. Only non-null args
/// apply; `touchedKeys` clears the matching validation errors as the user edits.
class ReceiptHeaderChanged extends ReceiptFormEvent {
  const ReceiptHeaderChanged({
    this.receiptNumber,
    this.receiptDate,
    this.organizationId,
    this.organizationName,
    this.departmentId,
    this.departmentName,
    this.debitAccount,
    this.creditAccount,
    this.delivererUserId,
    this.delivererName,
    this.referenceDocNumber,
    this.referenceDocDate,
    this.referenceDocIssuer,
    this.warehouseId,
    this.warehouseName,
    this.warehouseLocation,
    this.attachedDocumentCount,
    this.preparerUserId,
    this.preparerName,
    this.storekeeperUserId,
    this.storekeeperName,
    this.chiefAccountantUserId,
    this.chiefAccountantName,
  });

  final String? receiptNumber;
  final DateTime? receiptDate;
  final String? organizationId;
  final String? organizationName;
  final String? departmentId;
  final String? departmentName;
  final String? debitAccount;
  final String? creditAccount;
  final String? delivererUserId;
  final String? delivererName;
  final String? referenceDocNumber;
  final DateTime? referenceDocDate;
  final String? referenceDocIssuer;
  final String? warehouseId;
  final String? warehouseName;
  final String? warehouseLocation;
  final int? attachedDocumentCount;
  final String? preparerUserId;
  final String? preparerName;
  final String? storekeeperUserId;
  final String? storekeeperName;
  final String? chiefAccountantUserId;
  final String? chiefAccountantName;

  List<String> get touchedKeys => [
    if (receiptNumber != null) 'receiptNumber',
    if (delivererUserId != null) 'delivererUserId',
    if (warehouseId != null) 'warehouseId',
    if (organizationId != null) 'organizationId',
    if (attachedDocumentCount != null) 'attachedDocumentCount',
  ];

  ReceiptFormData apply(ReceiptFormData data) => data.copyWith(
    receiptNumber: receiptNumber,
    receiptDate: receiptDate,
    organizationId: organizationId,
    organizationName: organizationName,
    departmentId: departmentId,
    departmentName: departmentName,
    debitAccount: debitAccount,
    creditAccount: creditAccount,
    delivererUserId: delivererUserId,
    delivererName: delivererName,
    referenceDocNumber: referenceDocNumber,
    referenceDocDate: referenceDocDate,
    referenceDocIssuer: referenceDocIssuer,
    warehouseId: warehouseId,
    warehouseName: warehouseName,
    warehouseLocation: warehouseLocation,
    attachedDocumentCount: attachedDocumentCount,
    preparerUserId: preparerUserId,
    preparerName: preparerName,
    storekeeperUserId: storekeeperUserId,
    storekeeperName: storekeeperName,
    chiefAccountantUserId: chiefAccountantUserId,
    chiefAccountantName: chiefAccountantName,
  );

  @override
  List<Object?> get props => [
    receiptNumber,
    receiptDate,
    organizationId,
    departmentId,
    debitAccount,
    creditAccount,
    delivererUserId,
    referenceDocNumber,
    referenceDocDate,
    referenceDocIssuer,
    warehouseId,
    warehouseLocation,
    attachedDocumentCount,
    preparerUserId,
    storekeeperUserId,
    chiefAccountantUserId,
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

/// The row widget owns its inputs and emits its whole current value.
class ReceiptItemChanged extends ReceiptFormEvent {
  const ReceiptItemChanged(this.row);

  final ReceiptItemFormData row;

  @override
  List<Object?> get props => [row];
}

/// Move to [target] step. Moving forward validates every field owned by the
/// steps being left; moving back is unconditional.
class ReceiptStepRequested extends ReceiptFormEvent {
  const ReceiptStepRequested(this.target);

  final int target;

  @override
  List<Object?> get props => [target];
}

class ReceiptSubmitted extends ReceiptFormEvent {
  const ReceiptSubmitted();
}
