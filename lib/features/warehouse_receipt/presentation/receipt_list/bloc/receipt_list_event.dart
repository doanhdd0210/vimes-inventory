part of 'receipt_list_bloc.dart';

sealed class ReceiptListEvent extends Equatable {
  const ReceiptListEvent();

  @override
  List<Object?> get props => [];
}

class ReceiptListRequested extends ReceiptListEvent {
  const ReceiptListRequested();
}
