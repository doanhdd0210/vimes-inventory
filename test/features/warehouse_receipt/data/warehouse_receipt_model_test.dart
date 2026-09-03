import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/models/warehouse_receipt_item_model.dart';
import 'package:vimes_inventory/features/warehouse_receipt/data/models/warehouse_receipt_model.dart';

import '../../../fixtures/warehouse_receipt_fixtures.dart';

void main() {
  group('WarehouseReceiptItemModel', () {
    test('round-trips through toMap / fromMap', () {
      final model = WarehouseReceiptItemModel.fromEntity(
        itemFixture(quantityActual: 4, unitPrice: 1000),
      );
      final restored = WarehouseReceiptItemModel.fromMap(model.toMap());

      expect(restored.props, model.props);
      expect(model.toMap()['amount'], 4000);
    });

    test('fromMap tolerates missing / wrong-typed fields', () {
      final model = WarehouseReceiptItemModel.fromMap(const {});
      expect(model.name, '');
      expect(model.quantityActual, 0);
      expect(model.unitPrice, 0);
    });
  });

  group('WarehouseReceiptModel', () {
    test('toMap embeds items and derived totals', () {
      final model = WarehouseReceiptModel.fromEntity(
        receiptFixture(
          items: [
            itemFixture(lineNo: 1, quantityActual: 2, unitPrice: 100),
            itemFixture(lineNo: 2, quantityActual: 1, unitPrice: 50),
          ],
        ),
      );

      final map = model.toMap();
      expect((map['items'] as List).length, 2);
      expect(map['totalAmount'], 250);
      expect(map['totalAmountInWords'], 'Hai trăm năm mươi đồng');
      expect(map['status'], 'posted');
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('fromMap parses timestamps and sorts items by lineNo', () {
      final map = {
        'receiptNumber': 'PN-9',
        'receiptDate': Timestamp.fromDate(DateTime(2026, 5, 6)),
        'delivererName': 'B',
        'warehouseName': 'Kho X',
        'attachedDocumentCount': 2,
        'items': [
          {
            'lineNo': 2,
            'name': 'Second',
            'unit': 'cái',
            'quantityActual': 1,
            'unitPrice': 10,
          },
          {
            'lineNo': 1,
            'name': 'First',
            'unit': 'cái',
            'quantityActual': 1,
            'unitPrice': 10,
          },
        ],
      };

      final model = WarehouseReceiptModel.fromMap('doc-9', map);

      expect(model.id, 'doc-9');
      expect(model.receiptDate, DateTime(2026, 5, 6));
      expect(model.items.map((i) => i.lineNo), [1, 2]);
      expect(model.items.first.name, 'First');
      expect(model.totalAmount, 20);
    });
  });
}
