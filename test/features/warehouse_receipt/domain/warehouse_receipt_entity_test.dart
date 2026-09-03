import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

void main() {
  test('item.amount = quantityActual × unitPrice, rounded', () {
    final item = itemFixture(quantityActual: 3, unitPrice: 1250.5);
    expect(item.amount, 3752); // 3751.5 -> 3752
  });

  test('receipt.totalAmount sums every line', () {
    final receipt = receiptFixture(
      items: [
        itemFixture(lineNo: 1, quantityActual: 2, unitPrice: 100),
        itemFixture(lineNo: 2, quantityActual: 5, unitPrice: 30),
      ],
    );
    expect(receipt.totalAmount, 350);
  });

  test('copyWith only touches lifecycle fields', () {
    final receipt = receiptFixture();
    final posted = receipt.copyWith(
      id: 'new-id',
      status: ReceiptStatus.posted,
      postedAt: DateTime(2026, 3, 1),
    );
    expect(posted.id, 'new-id');
    expect(posted.status, ReceiptStatus.posted);
    expect(posted.postedAt, DateTime(2026, 3, 1));
    expect(posted.receiptNumber, receipt.receiptNumber);
    expect(posted.warehouseName, receipt.warehouseName);
    expect(posted.items, receipt.items);
  });
}
