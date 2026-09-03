import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt_item.dart';

WarehouseReceiptItem itemFixture({
  int lineNo = 1,
  String name = 'Thép hộp 40x40',
  String? code = 'VT001',
  String unit = 'cây',
  num? quantityDoc = 10,
  num quantityActual = 10,
  num unitPrice = 120000,
}) {
  return WarehouseReceiptItem(
    lineNo: lineNo,
    name: name,
    code: code,
    unit: unit,
    quantityDoc: quantityDoc,
    quantityActual: quantityActual,
    unitPrice: unitPrice,
  );
}

WarehouseReceipt receiptFixture({
  String id = 'r1',
  String receiptNumber = 'PN-001',
  String delivererName = 'Nguyễn Văn A',
  String warehouseName = 'Kho A',
  List<WarehouseReceiptItem>? items,
  int attachedDocumentCount = 1,
}) {
  return WarehouseReceipt(
    id: id,
    receiptNumber: receiptNumber,
    receiptDate: DateTime(2026, 2, 3),
    delivererName: delivererName,
    warehouseName: warehouseName,
    attachedDocumentCount: attachedDocumentCount,
    items: items ?? [itemFixture()],
  );
}
