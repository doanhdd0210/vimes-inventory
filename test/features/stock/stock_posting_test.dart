import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/stock/data/in_memory_stock_store.dart';
import 'package:vimes_inventory/features/stock/domain/weighted_average.dart';

void main() {
  group('WeightedAverage.applyReceipt', () {
    test('first receipt sets avg = unit price', () {
      final r = WeightedAverage.applyReceipt(
        currentQty: 0,
        currentValue: 0,
        inQty: 10,
        inValue: 10 * 1000,
      );
      expect(r.qty, 10);
      expect(r.value, 10000);
      expect(r.avg, 1000);
    });

    test('second receipt at a different price blends the average', () {
      // 10 @ 1000  then  10 @ 2000  ->  20 units, value 30000, avg 1500
      final first = WeightedAverage.applyReceipt(
        currentQty: 0,
        currentValue: 0,
        inQty: 10,
        inValue: 10000,
      );
      final second = WeightedAverage.applyReceipt(
        currentQty: first.qty,
        currentValue: first.value,
        inQty: 10,
        inValue: 20000,
      );
      expect(second.qty, 20);
      expect(second.value, 30000);
      expect(second.avg, 1500);
    });
  });

  group('InMemoryStockStore', () {
    late InMemoryStockStore store;
    setUp(() => store = InMemoryStockStore());

    test('posting two receipt lines accumulates stock + ledger', () {
      store.postReceiptLine(
        organizationId: 'o1',
        warehouseId: 'w1',
        itemId: 'i1',
        quantity: 10,
        unitPrice: 1000,
        sourceCollection: 'warehouse_receipts',
        sourceId: 'r1#1',
        movedAt: DateTime(2026, 1, 1),
      );
      store.postReceiptLine(
        organizationId: 'o1',
        warehouseId: 'w1',
        itemId: 'i1',
        quantity: 10,
        unitPrice: 2000,
        sourceCollection: 'warehouse_receipts',
        sourceId: 'r2#1',
        movedAt: DateTime(2026, 1, 2),
      );

      final stock = store.stockFor('o1').single;
      expect(stock.quantityOnHand, 20);
      expect(stock.avgCost, 1500);

      final ledger = store.ledgerFor('w1', 'i1');
      expect(ledger, hasLength(2));
      expect(ledger.last.balanceQtyAfter, 20);
      expect(ledger.last.avgCostAfter, 1500);
      expect(store.hasPosted('warehouse_receipts', 'r1#1'), isTrue);
    });

    test('stockFor filters by organisation', () {
      store.postReceiptLine(
        organizationId: 'o1',
        warehouseId: 'w1',
        itemId: 'i1',
        quantity: 1,
        unitPrice: 1,
        sourceCollection: 'c',
        sourceId: 's',
        movedAt: DateTime(2026),
      );
      expect(store.stockFor('other'), isEmpty);
    });
  });
}
