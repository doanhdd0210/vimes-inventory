import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/sample_item.dart';
import '../../domain/repositories/sample_repository.dart';
import '../datasources/sample_data_source.dart';

/// Bridges the domain contract to the datasource, translating exceptions into
/// [Failure]s. This is the only place `try/catch` on datasource errors lives.
class SampleRepositoryImpl implements SampleRepository {
  const SampleRepositoryImpl(this._dataSource);

  final SampleDataSource _dataSource;

  @override
  ResultFuture<List<SampleItem>> getSampleItems() async {
    try {
      final result = await _dataSource.getSampleItems();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultFuture<SampleItem> addSampleItem(String title) async {
    try {
      final result = await _dataSource.addSampleItem(title);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
