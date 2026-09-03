import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/auth/data/auth_data_source.dart';
import 'package:vimes_inventory/features/auth/data/auth_repository_impl.dart';
import 'package:vimes_inventory/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:vimes_inventory/features/master_data/data/master_seed.dart';

void main() {
  group('FakeAuthDataSource + AuthRepositoryImpl', () {
    late AuthRepositoryImpl repo;

    setUp(() => repo = AuthRepositoryImpl(FakeAuthDataSource()));

    test('a seeded account signs in to its user id', () async {
      final result = await repo.signIn(
        email: 'admin@vimes.local',
        password: '123456',
      );
      final account = result.getOrElse(() => throw Exception());
      expect(account.uid, MasterSeed.userAdmin);
      expect(repo.currentAccount?.uid, MasterSeed.userAdmin);
    });

    test('a short password is rejected', () async {
      final result = await repo.signIn(email: 'x@y.z', password: '123');
      expect(result.isLeft(), isTrue);
    });

    test('signOut clears the current account', () async {
      await repo.signIn(email: 'admin@vimes.local', password: '123456');
      await repo.signOut();
      expect(repo.currentAccount, isNull);
    });
  });

  group('AuthCubit', () {
    test('starts unauthenticated then authenticates on signIn', () async {
      final cubit = AuthCubit(AuthRepositoryImpl(FakeAuthDataSource()));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, AuthStatus.unauthenticated);

      final ok = await cubit.signIn('thukho@vimes.local', '123456');
      expect(ok, isTrue);
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.account?.uid, MasterSeed.userKeeper);

      await cubit.signOut();
      expect(cubit.state.status, AuthStatus.unauthenticated);
      await cubit.close();
    });
  });
}
