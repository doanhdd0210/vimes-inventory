import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/warehouse_receipt.dart';
import '../repositories/warehouse_receipt_repository.dart';

class GetWarehouseReceipts extends UseCase<List<WarehouseReceipt>, NoParams> {
  const GetWarehouseReceipts(this._repository);

  final WarehouseReceiptRepository _repository;

  @override
  ResultFuture<List<WarehouseReceipt>> call(NoParams params) {
    return _repository.getReceipts();
  }
}
