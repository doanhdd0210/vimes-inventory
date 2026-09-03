import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/warehouse_receipt.dart';
import '../../domain/repositories/warehouse_receipt_repository.dart';
import '../datasources/warehouse_receipt_data_source.dart';
import '../models/warehouse_receipt_model.dart';

class WarehouseReceiptRepositoryImpl implements WarehouseReceiptRepository {
  const WarehouseReceiptRepositoryImpl(this._dataSource);

  final WarehouseReceiptDataSource _dataSource;

  @override
  ResultFuture<String> createReceipt(WarehouseReceipt receipt) async {
    try {
      final id = await _dataSource.createReceipt(
        WarehouseReceiptModel.fromEntity(receipt),
      );
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultFuture<List<WarehouseReceipt>> getReceipts() async {
    try {
      final result = await _dataSource.getReceipts();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultFuture<WarehouseReceipt> getReceiptById(String id) async {
    try {
      final result = await _dataSource.getReceiptById(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
