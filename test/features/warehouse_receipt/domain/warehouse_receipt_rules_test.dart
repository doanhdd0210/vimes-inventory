import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/usecases/warehouse_receipt_rules.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

void main() {
  test('a well-formed receipt has no errors', () {
    expect(WarehouseReceiptRules.validate(receiptFixture()), isEmpty);
  });

  test('flags missing header fields', () {
    final errors = WarehouseReceiptRules.validate(
      receiptFixture(
        receiptNumber: '  ',
        organizationId: '',
        delivererUserId: '',
        warehouseId: '',
      ),
    );
    expect(
      errors.keys,
      containsAll(<String>[
        'receiptNumber',
        'organizationId',
        'delivererUserId',
        'warehouseId',
      ]),
    );
  });

  test('requires at least one line', () {
    final errors = WarehouseReceiptRules.validate(
      receiptFixture(items: const []),
    );
    expect(errors['items'], isNotNull);
  });

  test('flags per-line problems with indexed keys', () {
    final errors = WarehouseReceiptRules.validate(
      receiptFixture(
        items: [
          itemFixture(
            lineNo: 1,
            itemId: '',
            name: '',
            unit: '',
            quantityActual: 0,
          ),
          itemFixture(lineNo: 2, unitPrice: -5, quantityDoc: -1),
        ],
      ),
    );
    expect(errors['items[0].itemId'], isNotNull);
    expect(errors['items[0].unit'], isNotNull);
    expect(errors['items[0].quantityActual'], isNotNull);
    expect(errors['items[1].unitPrice'], isNotNull);
    expect(errors['items[1].quantityDoc'], isNotNull);
  });
}
