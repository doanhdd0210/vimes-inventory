import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_account.dart';
import '../../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.account});

  const AuthState.authenticated(AuthAccount account)
    : this(status: AuthStatus.authenticated, account: account);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final AuthAccount? account;

  @override
  List<Object?> get props => [status, account];
}

/// App-wide auth holder. Drives the router redirect. [onAuthenticated] runs
/// once, the first time a user is signed in (used to seed Firestore, which
/// needs an authenticated request).
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, {Future<void> Function()? onAuthenticated})
    : _onAuthenticated = onAuthenticated,
      super(const AuthState()) {
    _sub = _repository.authStateChanges().listen((account) {
      if (account != null && !_ranOnAuthenticated) {
        _ranOnAuthenticated = true;
        _onAuthenticated?.call();
      }
      emit(
        account == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(account),
      );
    });
  }

  final AuthRepository _repository;
  final Future<void> Function()? _onAuthenticated;
  bool _ranOnAuthenticated = false;
  late final StreamSubscription<AuthAccount?> _sub;

  bool signingIn = false;
  String? signInError;

  Future<bool> signIn(String email, String password) async {
    signingIn = true;
    signInError = null;
    emit(AuthState(status: state.status, account: state.account));

    final result = await _repository.signIn(email: email, password: password);
    signingIn = false;

    return result.fold(
      (failure) {
        signInError = failure.message;
        emit(AuthState(status: state.status, account: state.account));
        return false;
      },
      (account) {
        emit(AuthState.authenticated(account));
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthState.unauthenticated());
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
