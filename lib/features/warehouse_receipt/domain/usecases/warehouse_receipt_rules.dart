import '../entities/warehouse_receipt.dart';

/// Pure business rules for a phiếu nhập kho. Returns a field→message map;
/// empty means valid. Keys match the form fields and `items[i].<col>`.
class WarehouseReceiptRules {
  const WarehouseReceiptRules._();

  static Map<String, String> validate(WarehouseReceipt receipt) {
    final errors = <String, String>{};

    if (receipt.receiptNumber.trim().isEmpty) {
      errors['receiptNumber'] = 'Bắt buộc nhập số phiếu';
    }
    if (receipt.delivererName.trim().isEmpty) {
      errors['delivererName'] = 'Bắt buộc nhập họ tên người giao';
    }
    if (receipt.warehouseName.trim().isEmpty) {
      errors['warehouseName'] = 'Bắt buộc nhập kho nhập';
    }
    if (receipt.attachedDocumentCount < 0) {
      errors['attachedDocumentCount'] = 'Không được âm';
    }

    if (receipt.items.isEmpty) {
      errors['items'] = 'Phiếu phải có ít nhất một dòng vật tư';
    }

    for (var i = 0; i < receipt.items.length; i++) {
      final item = receipt.items[i];
      if (item.name.trim().isEmpty) {
        errors['items[$i].name'] = 'Bắt buộc nhập tên vật tư';
      }
      if (item.unit.trim().isEmpty) {
        errors['items[$i].unit'] = 'Bắt buộc nhập đơn vị tính';
      }
      if (item.quantityActual <= 0) {
        errors['items[$i].quantityActual'] =
            'Số lượng thực nhập phải lớn hơn 0';
      }
      if (item.quantityDoc != null && item.quantityDoc! < 0) {
        errors['items[$i].quantityDoc'] = 'Không được âm';
      }
      if (item.unitPrice < 0) {
        errors['items[$i].unitPrice'] = 'Đơn giá không được âm';
      }
    }

    return errors;
  }
}
