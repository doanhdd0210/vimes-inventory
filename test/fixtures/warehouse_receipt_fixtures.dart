import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/entities/warehouse_receipt_item.dart';

WarehouseReceiptItem itemFixture({
  int lineNo = 1,
  String itemId = 'item-1',
  String name = 'Thép hộp 40x40',
  String? code = 'VT001',
  String unit = 'cây',
  String? uomId = 'uom-cay',
  num? quantityDoc = 10,
  num quantityActual = 10,
  num unitPrice = 120000,
}) {
  return WarehouseReceiptItem(
    lineNo: lineNo,
    itemId: itemId,
    name: name,
    code: code,
    unit: unit,
    uomId: uomId,
    quantityDoc: quantityDoc,
    quantityActual: quantityActual,
    unitPrice: unitPrice,
  );
}

WarehouseReceipt receiptFixture({
  String id = 'r1',
  String receiptNumber = 'PN-001',
  String organizationId = 'org-1',
  String organizationName = 'Công ty VIMES',
  String warehouseId = 'wh-1',
  String warehouseName = 'Kho A',
  String delivererUserId = 'user-1',
  String delivererName = 'Nguyễn Văn A',
  List<WarehouseReceiptItem>? items,
  int attachedDocumentCount = 1,
}) {
  return WarehouseReceipt(
    id: id,
    receiptNumber: receiptNumber,
    receiptDate: DateTime(2026, 2, 3),
    organizationId: organizationId,
    organizationName: organizationName,
    warehouseId: warehouseId,
    warehouseName: warehouseName,
    delivererUserId: delivererUserId,
    delivererName: delivererName,
    attachedDocumentCount: attachedDocumentCount,
    items: items ?? [itemFixture()],
  );
}
