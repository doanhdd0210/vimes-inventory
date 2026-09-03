import '../../../../core/error/exceptions.dart';
import '../models/warehouse_receipt_model.dart';
import 'warehouse_receipt_data_source.dart';

/// In-memory [WarehouseReceiptDataSource] used while Firebase is disabled.
/// Mirrors the Firestore rules that matter: unique `receiptNumber`, newest
/// first, not-found on unknown id.
class WarehouseReceiptInMemoryDataSource implements WarehouseReceiptDataSource {
  final Map<String, WarehouseReceiptModel> _store = {};
  var _autoId = 0;

  @override
  Future<String> createReceipt(WarehouseReceiptModel receipt) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final number = receipt.receiptNumber.trim();
    final duplicate = _store.values.any(
      (r) => r.receiptNumber.trim() == number,
    );
    if (duplicate) {
      throw const ServerException(
        message: 'Số phiếu đã tồn tại',
        statusCode: 'already-exists',
      );
    }

    final id = 'mem-${++_autoId}';
    _store[id] = WarehouseReceiptModel.fromEntity(
      receipt.copyWith(id: id, createdAt: DateTime.now()),
    );
    return id;
  }

  @override
  Future<List<WarehouseReceiptModel>> getReceipts() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final list = _store.values.toList()
      ..sort((a, b) {
        final ac = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bc = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bc.compareTo(ac);
      });
    return List.unmodifiable(list);
  }

  @override
  Future<WarehouseReceiptModel> getReceiptById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final found = _store[id];
    if (found == null) {
      throw const ServerException(
        message: 'Không tìm thấy phiếu',
        statusCode: 'not-found',
      );
    }
    return found;
  }
}
