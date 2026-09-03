import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../master_data/data/master_seed.dart';
import '../domain/entities/auth_account.dart';

abstract class AuthDataSource {
  Stream<AuthAccount?> authStateChanges();
  AuthAccount? get current;
  Future<AuthAccount> signIn(String email, String password);
  Future<void> signOut();
}

class FirebaseAuthDataSource implements AuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  AuthAccount? _map(User? u) => u == null
      ? null
      : AuthAccount(uid: u.uid, email: u.email, displayName: u.displayName);

  @override
  Stream<AuthAccount?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  AuthAccount? get current => _map(_auth.currentUser);

  @override
  Future<AuthAccount> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final account = _map(cred.user);
      if (account == null) {
        throw const ServerException(message: 'Đăng nhập thất bại');
      }
      return account;
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        message: switch (e.code) {
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' => 'Email hoặc mật khẩu không đúng',
          'user-disabled' => 'Tài khoản đã bị khoá',
          'too-many-requests' => 'Thử lại sau ít phút',
          _ => e.message ?? e.code,
        },
        statusCode: e.code,
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

/// Offline fake: accepts `<username>@vimes.local` / `123456` for the seeded
/// users, plus any e-mail with a ≥6-char password (returns a synthetic id).
class FakeAuthDataSource implements AuthDataSource {
  final _controller = StreamController<AuthAccount?>.broadcast();
  AuthAccount? _account;

  static final Map<String, AuthAccount> _known = {
    for (final u in MasterSeed.users)
      '${u.username}@vimes.local': AuthAccount(
        uid: u.id,
        email: '${u.username}@vimes.local',
        displayName: u.fullName,
      ),
  };

  @override
  Stream<AuthAccount?> authStateChanges() async* {
    yield _account;
    yield* _controller.stream;
  }

  @override
  AuthAccount? get current => _account;

  @override
  Future<AuthAccount> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final key = email.trim().toLowerCase();
    if (password.length < 6) {
      throw const ServerException(
        message: 'Mật khẩu tối thiểu 6 ký tự',
        statusCode: 'weak-password',
      );
    }
    final account =
        _known[key] ??
        AuthAccount(
          uid: 'fake-${key.hashCode}',
          email: key,
          displayName: key.split('@').first,
        );
    _account = account;
    _controller.add(account);
    return account;
  }

  @override
  Future<void> signOut() async {
    _account = null;
    _controller.add(null);
  }
}
