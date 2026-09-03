import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/sample_receipt_seeder.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/repositories/warehouse_receipt_repository.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

class _MockRepo extends Mock implements WarehouseReceiptRepository {}

class _FakeReceipt extends Fake implements WarehouseReceipt {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeReceipt()));

  late _MockRepo repo;
  late SampleReceiptSeeder seeder;

  setUp(() {
    repo = _MockRepo();
    seeder = SampleReceiptSeeder(repo);
  });

  test('seeds the two sample phiếu when the store is empty', () async {
    when(() => repo.getReceipts()).thenAnswer((_) async => const Right([]));
    when(
      () => repo.createReceipt(any()),
    ).thenAnswer((_) async => const Right('new-id'));

    await seeder.seedIfEmpty();

    final created = verify(
      () => repo.createReceipt(captureAny()),
    ).captured.cast<WarehouseReceipt>();
    expect(created, hasLength(2));
    expect(created.map((r) => r.receiptNumber), [
      'PN-2026-08-001',
      'PN-2026-08-002',
    ]);

    // Every sample phiếu is well-formed by the domain rules.
    expect(created.every((r) => r.items.isNotEmpty), isTrue);

    // Thép hộp (VT001) is received on both phiếu at rising prices, so the
    // Thẻ kho screen shows the weighted-average blending.
    final thepPrices = created
        .expand((r) => r.items)
        .where((i) => i.code == 'VT001')
        .map((i) => i.unitPrice)
        .toList();
    expect(thepPrices, [42000, 45000]);
  });

  test('does nothing when the store already has phiếu', () async {
    when(
      () => repo.getReceipts(),
    ).thenAnswer((_) async => Right([receiptFixture()]));

    await seeder.seedIfEmpty();

    verifyNever(() => repo.createReceipt(any()));
  });

  test('stops after the first failure instead of piling errors', () async {
    when(() => repo.getReceipts()).thenAnswer((_) async => const Right([]));
    when(() => repo.createReceipt(any())).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'permission-denied')),
    );

    await seeder.seedIfEmpty();

    verify(() => repo.createReceipt(any())).called(1);
  });

  test('does not write when the store read itself fails', () async {
    when(
      () => repo.getReceipts(),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'offline')));

    await seeder.seedIfEmpty();

    verifyNever(() => repo.createReceipt(any()));
  });
}
