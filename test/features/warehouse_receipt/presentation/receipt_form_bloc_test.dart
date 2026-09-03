import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/usecases/create_warehouse_receipt.dart';
import 'package:vimes_inventory/features/warehouse_receipt/presentation/viewmodel/receipt_form_bloc.dart';
import 'package:vimes_inventory/features/warehouse_receipt/presentation/viewmodel/receipt_form_data.dart';

class _MockCreate extends Mock implements CreateWarehouseReceipt {}

class _FakeParams extends Fake implements CreateWarehouseReceiptParams {}

void main() {
  late _MockCreate create;

  setUpAll(() => registerFallbackValue(_FakeParams()));
  setUp(() => create = _MockCreate());

  ReceiptFormBloc build() => ReceiptFormBloc(createWarehouseReceipt: create);

  Future<void> fillValid(ReceiptFormBloc bloc) async {
    bloc
      ..add(
        const ReceiptHeaderChanged(
          receiptNumber: 'PN-001',
          delivererName: 'Nguyễn Văn A',
          warehouseName: 'Kho A',
        ),
      )
      ..add(const ReceiptItemAdded());
    await Future<void>.delayed(Duration.zero);
    final rowId = bloc.state.data.items.single.rowId;
    bloc.add(
      ReceiptItemChanged(
        ReceiptItemFormData(
          rowId: rowId,
          name: 'Thép hộp',
          unit: 'cây',
          quantityActual: 3,
          unitPrice: 100000,
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
  }

  test('initial state is an empty editing form', () {
    final bloc = build();
    expect(bloc.state.status, ReceiptFormStatus.editing);
    expect(bloc.state.data, const ReceiptFormData());
  });

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'ReceiptItemAdded appends a row',
    build: build,
    act: (bloc) => bloc.add(const ReceiptItemAdded()),
    verify: (bloc) => expect(bloc.state.data.items, hasLength(1)),
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'submitting an empty form fails locally with field errors and no call',
    build: build,
    act: (bloc) => bloc.add(const ReceiptSubmitted()),
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.failure);
      expect(bloc.state.errorFor('receiptNumber'), isNotNull);
      expect(bloc.state.errorFor('items'), isNotNull);
      verifyNever(() => create(any()));
    },
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'a valid form calls the use case and reaches success with the saved id',
    build: build,
    setUp: () => when(
      () => create(any()),
    ).thenAnswer((_) async => const Right('receipt-42')),
    act: (bloc) async {
      await fillValid(bloc);
      bloc.add(const ReceiptSubmitted());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.success);
      expect(bloc.state.savedId, 'receipt-42');
      verify(() => create(any())).called(1);
    },
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'a ValidationFailure from the use case populates errors',
    build: build,
    setUp: () => when(() => create(any())).thenAnswer(
      (_) async => const Left(ValidationFailure({'receiptNumber': 'trùng'})),
    ),
    act: (bloc) async {
      await fillValid(bloc);
      bloc.add(const ReceiptSubmitted());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (bloc) => expect(bloc.state.errorFor('receiptNumber'), 'trùng'),
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'a ServerFailure surfaces as submitError',
    build: build,
    setUp: () => when(
      () => create(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'Mất mạng'))),
    act: (bloc) async {
      await fillValid(bloc);
      bloc.add(const ReceiptSubmitted());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.failure);
      expect(bloc.state.submitError, 'Mất mạng');
    },
  );
}
