import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../data/stock_data_source.dart';
import '../entities/inventory_stock.dart';
import '../entities/stock_ledger_entry.dart';

abstract class StockRepository {
  ResultFuture<List<InventoryStock>> getInventory(String organizationId);

  ResultFuture<List<StockLedgerEntry>> getLedger({
    required String warehouseId,
    required String itemId,
  });
}

class StockRepositoryImpl implements StockRepository {
  const StockRepositoryImpl(this._dataSource);

  final StockDataSource _dataSource;

  @override
  ResultFuture<List<InventoryStock>> getInventory(String organizationId) =>
      _guard(() => _dataSource.getInventory(organizationId));

  @override
  ResultFuture<List<StockLedgerEntry>> getLedger({
    required String warehouseId,
    required String itemId,
  }) => _guard(
    () => _dataSource.getLedger(warehouseId: warehouseId, itemId: itemId),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
