import 'package:equatable/equatable.dart';

/// The signed-in identity. Maps to a Firebase Auth user (or the fake one used
/// while Firebase is off). [uid] is also the `users/{uid}` document id.
class AuthAccount extends Equatable {
  const AuthAccount({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}
