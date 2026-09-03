import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../domain/entities/auth_account.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Stream<AuthAccount?> authStateChanges() => _dataSource.authStateChanges();

  @override
  AuthAccount? get currentAccount => _dataSource.current;

  @override
  ResultFuture<AuthAccount> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return Right(await _dataSource.signIn(email, password));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      return Right(await _dataSource.signOut());
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
