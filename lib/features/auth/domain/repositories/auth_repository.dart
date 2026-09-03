import '../../../../core/utils/typedefs.dart';
import '../entities/auth_account.dart';

abstract class AuthRepository {
  /// Emits the current account (or null) and every subsequent change.
  Stream<AuthAccount?> authStateChanges();

  AuthAccount? get currentAccount;

  ResultFuture<AuthAccount> signIn({
    required String email,
    required String password,
  });

  ResultVoid signOut();
}
