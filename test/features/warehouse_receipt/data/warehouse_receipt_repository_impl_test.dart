import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/exceptions.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/datasources/warehouse_receipt_data_source.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/models/warehouse_receipt_model.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/repositories/warehouse_receipt_repository_impl.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

class _MockDataSource extends Mock implements WarehouseReceiptDataSource {}

class _FakeModel extends Fake implements WarehouseReceiptModel {}

void main() {
  late _MockDataSource ds;
  late WarehouseReceiptRepositoryImpl repo;

  setUpAll(() => registerFallbackValue(_FakeModel()));

  setUp(() {
    ds = _MockDataSource();
    repo = WarehouseReceiptRepositoryImpl(ds);
  });

  test('createReceipt maps the entity to a model and returns the id', () async {
    when(() => ds.createReceipt(any())).thenAnswer((_) async => 'id-1');

    final result = await repo.createReceipt(receiptFixture());

    expect(result, const Right<Failure, String>('id-1'));
  });

  test('createReceipt maps ServerException to ServerFailure', () async {
    when(() => ds.createReceipt(any())).thenThrow(
      const ServerException(message: 'x', statusCode: 'already-exists'),
    );

    final result = await repo.createReceipt(receiptFixture());

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect((f as ServerFailure).statusCode, 'already-exists'),
      (_) => fail('expected Left'),
    );
  });

  test('getReceipts returns the datasource list', () async {
    final models = [WarehouseReceiptModel.fromEntity(receiptFixture(id: 'a'))];
    when(() => ds.getReceipts()).thenAnswer((_) async => models);

    final result = await repo.getReceipts();

    expect(result, Right<Failure, List<WarehouseReceiptModel>>(models));
  });
}
