import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/repositories/warehouse_receipt_repository.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/usecases/create_warehouse_receipt.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

class _MockRepo extends Mock implements WarehouseReceiptRepository {}

class _FakeReceipt extends Fake implements WarehouseReceipt {}

void main() {
  late _MockRepo repo;
  late CreateWarehouseReceipt usecase;

  setUpAll(() => registerFallbackValue(_FakeReceipt()));

  setUp(() {
    repo = _MockRepo();
    usecase = CreateWarehouseReceipt(repo);
  });

  test('validates before touching the repository', () async {
    final result = await usecase(
      CreateWarehouseReceiptParams(receiptFixture(receiptNumber: '')),
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
    verifyNever(() => repo.createReceipt(any()));
  });

  test('delegates a valid receipt and returns the new id', () async {
    when(
      () => repo.createReceipt(any()),
    ).thenAnswer((_) async => const Right('generated-id'));

    final result = await usecase(
      CreateWarehouseReceiptParams(receiptFixture()),
    );

    expect(result, const Right<Failure, String>('generated-id'));
    verify(() => repo.createReceipt(any())).called(1);
  });

  test('passes repository failure through', () async {
    when(() => repo.createReceipt(any())).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'Số phiếu đã tồn tại')),
    );

    final result = await usecase(
      CreateWarehouseReceiptParams(receiptFixture()),
    );

    expect(result.isLeft(), isTrue);
  });
}
