import 'package:dartz/dartz.dart';

import '../data/crud_data_source.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../utils/typedefs.dart';
import 'entity.dart';

/// Read/write contract the presentation layer depends on for a master entity.
abstract class CrudRepository<E extends Entity> {
  ResultFuture<List<E>> getAll();
  ResultFuture<E?> getById(String id);
  ResultFuture<String> create(E entity);
  ResultVoid update(E entity);
  ResultVoid delete(String id);
}

/// Generic implementation: forwards to a [CrudDataSource] and maps
/// [ServerException] to [ServerFailure].
class CrudRepositoryImpl<E extends Entity> implements CrudRepository<E> {
  const CrudRepositoryImpl(this._dataSource);

  final CrudDataSource<E> _dataSource;

  @override
  ResultFuture<List<E>> getAll() => _guard(_dataSource.getAll);

  @override
  ResultFuture<E?> getById(String id) => _guard(() => _dataSource.getById(id));

  @override
  ResultFuture<String> create(E entity) =>
      _guard(() => _dataSource.create(entity));

  @override
  ResultVoid update(E entity) => _guard(() => _dataSource.update(entity));

  @override
  ResultVoid delete(String id) => _guard(() => _dataSource.delete(id));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
