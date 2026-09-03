import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/warehouse_receipt.dart';
import '../repositories/warehouse_receipt_repository.dart';
import 'warehouse_receipt_rules.dart';

class CreateWarehouseReceipt
    extends UseCase<String, CreateWarehouseReceiptParams> {
  const CreateWarehouseReceipt(this._repository);

  final WarehouseReceiptRepository _repository;

  @override
  ResultFuture<String> call(CreateWarehouseReceiptParams params) async {
    final errors = WarehouseReceiptRules.validate(params.receipt);
    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors));
    }
    return _repository.createReceipt(params.receipt);
  }
}

class CreateWarehouseReceiptParams extends Equatable {
  const CreateWarehouseReceiptParams(this.receipt);

  final WarehouseReceipt receipt;

  @override
  List<Object?> get props => [receipt];
}
