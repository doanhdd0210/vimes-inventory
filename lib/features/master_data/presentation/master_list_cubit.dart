import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/domain/crud_repository.dart';
import '../../../core/domain/entity.dart';

enum MasterListStatus { loading, success, failure }

class MasterListState<E extends Entity> extends Equatable {
  const MasterListState({
    this.status = MasterListStatus.loading,
    this.items = const [],
    this.errorMessage,
  });

  final MasterListStatus status;
  final List<E> items;
  final String? errorMessage;

  MasterListState<E> copyWith({
    MasterListStatus? status,
    List<E>? items,
    String? errorMessage,
  }) => MasterListState<E>(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, items, errorMessage];
}

/// Read-only ViewModel for a master catalog. One instance per catalog screen.
class MasterListCubit<E extends Entity> extends Cubit<MasterListState<E>> {
  MasterListCubit(this._repository) : super(MasterListState<E>());

  final CrudRepository<E> _repository;

  Future<void> load() async {
    emit(state.copyWith(status: MasterListStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MasterListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) =>
          emit(state.copyWith(status: MasterListStatus.success, items: items)),
    );
  }
}
