import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/core/usecase/usecase.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/usecases/get_warehouse_receipts.dart';
import 'package:vimes_inventory/features/warehouse_receipt/presentation/bloc/receipt_list_bloc.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

class _MockGet extends Mock implements GetWarehouseReceipts {}

void main() {
  late _MockGet get;

  setUpAll(() => registerFallbackValue(const NoParams()));
  setUp(() => get = _MockGet());

  final receipts = [receiptFixture(id: 'a'), receiptFixture(id: 'b')];

  blocTest<ReceiptListBloc, ReceiptListState>(
    'emits [loading, success] with the list',
    build: () {
      when(() => get(any())).thenAnswer((_) async => Right(receipts));
      return ReceiptListBloc(getWarehouseReceipts: get);
    },
    act: (bloc) => bloc.add(const ReceiptListRequested()),
    expect: () => [
      const ReceiptListState(status: ReceiptListStatus.loading),
      ReceiptListState(status: ReceiptListStatus.success, receipts: receipts),
    ],
  );

  blocTest<ReceiptListBloc, ReceiptListState>(
    'emits [loading, failure] on error',
    build: () {
      when(
        () => get(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'lỗi')));
      return ReceiptListBloc(getWarehouseReceipts: get);
    },
    act: (bloc) => bloc.add(const ReceiptListRequested()),
    expect: () => [
      const ReceiptListState(status: ReceiptListStatus.loading),
      const ReceiptListState(
        status: ReceiptListStatus.failure,
        errorMessage: 'lỗi',
      ),
    ],
  );
}
