import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/warehouse_receipt.dart';
import '../../domain/usecases/get_warehouse_receipts.dart';

part 'receipt_list_event.dart';
part 'receipt_list_state.dart';

class ReceiptListBloc extends Bloc<ReceiptListEvent, ReceiptListState> {
  ReceiptListBloc({required GetWarehouseReceipts getWarehouseReceipts})
    : _getWarehouseReceipts = getWarehouseReceipts,
      super(const ReceiptListState()) {
    on<ReceiptListRequested>(_onRequested);
  }

  final GetWarehouseReceipts _getWarehouseReceipts;

  Future<void> _onRequested(
    ReceiptListRequested event,
    Emitter<ReceiptListState> emit,
  ) async {
    emit(state.copyWith(status: ReceiptListStatus.loading));
    final result = await _getWarehouseReceipts(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ReceiptListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (receipts) => emit(
        state.copyWith(status: ReceiptListStatus.success, receipts: receipts),
      ),
    );
  }
}
