import 'package:equatable/equatable.dart';

import '../utils/typedefs.dart';

/// A single unit of business logic.
///
/// [T] is the success payload, [P] is the input. Use [NoParams] when the use
/// case takes no input.
abstract class UseCase<T, P> {
  const UseCase();

  ResultFuture<T> call(P params);
}

/// A [UseCase] that streams results over time (e.g. Firestore snapshots).
abstract class StreamUseCase<T, P> {
  const StreamUseCase();

  Stream<T> call(P params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
