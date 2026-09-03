import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/create_warehouse_receipt.dart';
import '../../domain/usecases/warehouse_receipt_rules.dart';
import 'receipt_form_data.dart';

part 'receipt_form_event.dart';
part 'receipt_form_state.dart';

/// ViewModel for the goods-receipt entry form. Holds the [ReceiptFormData]
/// draft, exposes per-field [errors], and submits through
/// [CreateWarehouseReceipt].
class ReceiptFormBloc extends Bloc<ReceiptFormEvent, ReceiptFormState> {
  ReceiptFormBloc({required CreateWarehouseReceipt createWarehouseReceipt})
    : _createWarehouseReceipt = createWarehouseReceipt,
      super(ReceiptFormState(data: _seed())) {
    on<ReceiptHeaderChanged>(_onHeaderChanged);
    on<ReceiptItemAdded>(_onItemAdded);
    on<ReceiptItemRemoved>(_onItemRemoved);
    on<ReceiptItemChanged>(_onItemChanged);
    on<ReceiptSubmitted>(_onSubmitted);
  }

  final CreateWarehouseReceipt _createWarehouseReceipt;
  var _rowSeq = 0;

  static ReceiptFormData _seed() => const ReceiptFormData();

  String _nextRowId() => 'row-${++_rowSeq}';

  void _onHeaderChanged(
    ReceiptHeaderChanged event,
    Emitter<ReceiptFormState> emit,
  ) {
    emit(
      state.copyWith(
        data: event.apply(state.data),
        status: ReceiptFormStatus.editing,
        clearErrorsFor: event.touchedKeys,
      ),
    );
  }

  void _onItemAdded(ReceiptItemAdded event, Emitter<ReceiptFormState> emit) {
    final items = [
      ...state.data.items,
      ReceiptItemFormData(rowId: _nextRowId()),
    ];
    emit(
      state.copyWith(
        data: state.data.copyWith(items: items),
        status: ReceiptFormStatus.editing,
        clearErrorsFor: const ['items'],
      ),
    );
  }

  void _onItemRemoved(
    ReceiptItemRemoved event,
    Emitter<ReceiptFormState> emit,
  ) {
    final items = state.data.items
        .where((i) => i.rowId != event.rowId)
        .toList(growable: false);
    emit(
      state.copyWith(
        data: state.data.copyWith(items: items),
        status: ReceiptFormStatus.editing,
        // row indexes shifted — drop every per-row error, they get recomputed.
        clearRowErrors: true,
      ),
    );
  }

  void _onItemChanged(
    ReceiptItemChanged event,
    Emitter<ReceiptFormState> emit,
  ) {
    final items = state.data.items
        .map((i) => i.rowId == event.rowId ? event.row : i)
        .toList(growable: false);
    emit(
      state.copyWith(
        data: state.data.copyWith(items: items),
        status: ReceiptFormStatus.editing,
        clearRowErrors: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    ReceiptSubmitted event,
    Emitter<ReceiptFormState> emit,
  ) async {
    final receipt = state.data.toEntity();

    // Fast local check so the UI shows every error without a round-trip.
    final localErrors = WarehouseReceiptRules.validate(receipt);
    if (localErrors.isNotEmpty) {
      emit(
        state.copyWith(status: ReceiptFormStatus.failure, errors: localErrors),
      );
      return;
    }

    emit(
      state.copyWith(status: ReceiptFormStatus.submitting, errors: const {}),
    );

    final result = await _createWarehouseReceipt(
      CreateWarehouseReceiptParams(receipt),
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: ReceiptFormStatus.failure,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ReceiptFormStatus.failure,
              submitError: failure.message,
            ),
          );
        }
      },
      (id) =>
          emit(state.copyWith(status: ReceiptFormStatus.success, savedId: id)),
    );
  }
}
