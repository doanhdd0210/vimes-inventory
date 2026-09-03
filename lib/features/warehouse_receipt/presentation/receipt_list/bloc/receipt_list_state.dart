part of 'receipt_list_bloc.dart';

enum ReceiptListStatus { initial, loading, success, failure }

class ReceiptListState extends Equatable {
  const ReceiptListState({
    this.status = ReceiptListStatus.initial,
    this.receipts = const [],
    this.errorMessage,
  });

  final ReceiptListStatus status;
  final List<WarehouseReceipt> receipts;
  final String? errorMessage;

  ReceiptListState copyWith({
    ReceiptListStatus? status,
    List<WarehouseReceipt>? receipts,
    String? errorMessage,
  }) {
    return ReceiptListState(
      status: status ?? this.status,
      receipts: receipts ?? this.receipts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, receipts, errorMessage];
}
