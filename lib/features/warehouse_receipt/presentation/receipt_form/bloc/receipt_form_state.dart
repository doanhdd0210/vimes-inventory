part of 'receipt_form_bloc.dart';

enum ReceiptFormStatus { loading, editing, submitting, success, failure }

class ReceiptFormState extends Equatable {
  const ReceiptFormState({
    required this.data,
    this.options = const ReceiptFormOptions(),
    this.errors = const {},
    this.status = ReceiptFormStatus.loading,
    this.step = 0,
    this.savedId,
    this.submitError,
  });

  static const int lastStep = 2;

  final ReceiptFormData data;
  final ReceiptFormOptions options;

  /// 0 = Thông tin phiếu · 1 = Vật tư · 2 = Tổng hợp & chữ ký.
  final int step;

  /// field key → message. Keys: `receiptNumber`, `organizationId`,
  /// `delivererUserId`, `warehouseId`, `attachedDocumentCount`, `items`,
  /// `items[i].<col>`.
  final Map<String, String> errors;
  final ReceiptFormStatus status;
  final String? savedId;
  final String? submitError;

  bool get isLoading => status == ReceiptFormStatus.loading;
  bool get isSubmitting => status == ReceiptFormStatus.submitting;
  bool get hasErrors => errors.isNotEmpty;

  String? errorFor(String key) => errors[key];
  String? itemErrorFor(int index, String column) =>
      errors['items[$index].$column'];

  ReceiptFormState copyWith({
    ReceiptFormData? data,
    ReceiptFormOptions? options,
    Map<String, String>? errors,
    ReceiptFormStatus? status,
    int? step,
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
      options: options ?? this.options,
      errors: nextErrors,
      status: status ?? this.status,
      step: step ?? this.step,
      savedId: savedId ?? this.savedId,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    data,
    options,
    errors,
    status,
    step,
    savedId,
    submitError,
  ];
}
