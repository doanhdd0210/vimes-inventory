import '../entities/warehouse_receipt.dart';

/// Pure business rules for a phiếu nhập kho. Returns a field→message map;
/// empty means valid. Keys match the form fields and `items[i].<col>`.
class WarehouseReceiptRules {
  const WarehouseReceiptRules._();

  /// Which wizard step owns a given error key.
  /// 0 = Thông tin phiếu · 1 = Vật tư · 2 = Tổng hợp.
  static int stepOfKey(String key) {
    if (key.startsWith('items')) return 1;
    if (key == 'attachedDocumentCount') return 2;
    return 0;
  }

  static Map<String, String> validate(WarehouseReceipt receipt) {
    final errors = <String, String>{};

    if (receipt.receiptNumber.trim().isEmpty) {
      errors['receiptNumber'] = 'Bắt buộc nhập số phiếu';
    }
    if (receipt.organizationId.trim().isEmpty) {
      errors['organizationId'] = 'Chọn đơn vị';
    }
    if (receipt.warehouseId.trim().isEmpty) {
      errors['warehouseId'] = 'Chọn kho nhập';
    }
    if (receipt.delivererUserId.trim().isEmpty) {
      errors['delivererUserId'] = 'Chọn người giao';
    }
    if (receipt.attachedDocumentCount < 0) {
      errors['attachedDocumentCount'] = 'Không được âm';
    }

    if (receipt.items.isEmpty) {
      errors['items'] = 'Phiếu phải có ít nhất một dòng vật tư';
    }

    for (var i = 0; i < receipt.items.length; i++) {
      final item = receipt.items[i];
      if (item.itemId.trim().isEmpty && item.name.trim().isEmpty) {
        errors['items[$i].itemId'] = 'Chọn vật tư';
      }
      if (item.unit.trim().isEmpty) {
        errors['items[$i].unit'] = 'Thiếu đơn vị tính';
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
