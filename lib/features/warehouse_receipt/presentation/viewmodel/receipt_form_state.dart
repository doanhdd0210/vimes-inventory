part of 'receipt_form_bloc.dart';

enum ReceiptFormStatus { editing, submitting, success, failure }

class ReceiptFormState extends Equatable {
  const ReceiptFormState({
    required this.data,
    this.errors = const {},
    this.status = ReceiptFormStatus.editing,
    this.savedId,
    this.submitError,
  });

  final ReceiptFormData data;

  /// field key → message. Keys: `receiptNumber`, `delivererName`,
  /// `warehouseName`, `attachedDocumentCount`, `items`, `items[i].<col>`.
  final Map<String, String> errors;
  final ReceiptFormStatus status;
  final String? savedId;
  final String? submitError;

  bool get isSubmitting => status == ReceiptFormStatus.submitting;
  bool get isSuccess => status == ReceiptFormStatus.success;
  bool get hasErrors => errors.isNotEmpty;

  String? errorFor(String key) => errors[key];
  String? itemErrorFor(int index, String column) =>
      errors['items[$index].$column'];

  ReceiptFormState copyWith({
    ReceiptFormData? data,
    Map<String, String>? errors,
    ReceiptFormStatus? status,
    String? savedId,
    String? submitError,
    List<String>? clearErrorsFor,
    bool clearRowErrors = false,
  }) {
    var nextErrors = errors ?? this.errors;
    if (clearErrorsFor != null && nextErrors.isNotEmpty) {
      nextErrors = {...nextErrors}
        ..removeWhere((key, _) => clearErrorsFor.contains(key));
    }
    if (clearRowErrors && nextErrors.isNotEmpty) {
      nextErrors = {...nextErrors}
        ..removeWhere((key, _) => key.startsWith('items'));
    }

    return ReceiptFormState(
      data: data ?? this.data,
      errors: nextErrors,
      status: status ?? this.status,
      savedId: savedId ?? this.savedId,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [data, errors, status, savedId, submitError];
}
