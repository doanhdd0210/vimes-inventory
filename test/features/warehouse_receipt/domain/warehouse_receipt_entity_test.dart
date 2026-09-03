import 'package:flutter_test/flutter_test.dart';

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

  test('copyWith replaces only the given fields', () {
    final receipt = receiptFixture();
    final updated = receipt.copyWith(warehouseName: 'Kho B');
    expect(updated.warehouseName, 'Kho B');
    expect(updated.receiptNumber, receipt.receiptNumber);
    expect(updated.items, receipt.items);
  });
}
