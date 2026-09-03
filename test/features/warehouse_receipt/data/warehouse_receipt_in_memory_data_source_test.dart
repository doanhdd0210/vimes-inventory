import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/core/error/exceptions.dart';
import 'package:vimes_inventory/features/stock/data/in_memory_stock_store.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/datasources/warehouse_receipt_in_memory_data_source.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/models/warehouse_receipt_model.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

WarehouseReceiptModel model({String number = 'PN-1'}) =>
    WarehouseReceiptModel.fromEntity(receiptFixture(receiptNumber: number));

void main() {
  late WarehouseReceiptInMemoryDataSource ds;
  late InMemoryStockStore stock;

  setUp(() {
    stock = InMemoryStockStore();
    ds = WarehouseReceiptInMemoryDataSource(stock);
  });

  test('posts stock into the shared store', () async {
    await ds.createReceipt(model(number: 'PN-STOCK'));
    final rows = stock.stockFor('org-1');
    expect(rows, hasLength(1));
    expect(rows.single.quantityOnHand, 10);
    expect(rows.single.avgCost, 120000);
  });

  test('createReceipt stores and returns a generated id', () async {
    final id = await ds.createReceipt(model());
    expect(id, 'mem-1');

    final saved = await ds.getReceiptById(id);
    expect(saved.receiptNumber, 'PN-1');
  });

  test('rejects a duplicate receiptNumber', () async {
    await ds.createReceipt(model(number: 'PN-DUP'));

    expect(
      () => ds.createReceipt(model(number: 'PN-DUP')),
      throwsA(
        isA<ServerException>().having(
          (e) => e.statusCode,
          'statusCode',
          'already-exists',
        ),
      ),
    );
  });

  test('getReceipts returns newest first', () async {
    await ds.createReceipt(model(number: 'PN-1'));
    await ds.createReceipt(model(number: 'PN-2'));

    final list = await ds.getReceipts();
    expect(list.map((r) => r.receiptNumber), ['PN-2', 'PN-1']);
  });

  test('getReceiptById throws not-found for an unknown id', () {
    expect(
      () => ds.getReceiptById('nope'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.statusCode,
          'statusCode',
          'not-found',
        ),
      ),
    );
  });
}
