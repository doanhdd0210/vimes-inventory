import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Domain-level representation of something that went wrong.
///
/// The presentation layer only ever deals with [Failure], never exceptions.
abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});

  ServerFailure.fromException(ServerException exception)
    : this(message: exception.message, statusCode: exception.statusCode);

  final String? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});

  CacheFailure.fromException(CacheException exception)
    : this(message: exception.message);
}

/// Raised by a use case when its input breaks a business rule. [errors] maps a
/// field key (e.g. `receiptNumber`, `items[2].quantityActual`) to a message.
class ValidationFailure extends Failure {
  const ValidationFailure(this.errors) : super(message: 'Dữ liệu không hợp lệ');

  final Map<String, String> errors;

  @override
  List<Object?> get props => [message, errors];
}
