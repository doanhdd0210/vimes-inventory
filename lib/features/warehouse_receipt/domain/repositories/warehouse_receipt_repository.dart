import '../../../../core/utils/typedefs.dart';
import '../entities/warehouse_receipt.dart';

abstract class WarehouseReceiptRepository {
  /// Persists a new phiếu and returns its id.
  ResultFuture<String> createReceipt(WarehouseReceipt receipt);

  /// Most recent phiếu first.
  ResultFuture<List<WarehouseReceipt>> getReceipts();

  ResultFuture<WarehouseReceipt> getReceiptById(String id);
}
