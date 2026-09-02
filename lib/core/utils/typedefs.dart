import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Result of an operation that can fail with a [Failure] or succeed with [T].
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Result of a synchronous operation that can fail with a [Failure].
typedef ResultVoid = ResultFuture<void>;

/// Plain JSON map alias used by data-layer models.
typedef DataMap = Map<String, dynamic>;
