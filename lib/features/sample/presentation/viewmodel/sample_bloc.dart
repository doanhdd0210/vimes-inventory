import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/sample_item.dart';
import '../../domain/usecases/add_sample_item.dart';
import '../../domain/usecases/get_sample_items.dart';

part 'sample_event.dart';
part 'sample_state.dart';

/// ViewModel for the Sample feature.
///
/// In this codebase the BLoC *is* the MVVM ViewModel: it holds no widgets,
/// exposes an immutable [SampleState], and turns [SampleEvent]s from the View
/// into use-case calls. The View (`SamplePage`) only renders state and adds
/// events.
class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc({
    required GetSampleItems getSampleItems,
    required AddSampleItem addSampleItem,
  }) : _getSampleItems = getSampleItems,
       _addSampleItem = addSampleItem,
       super(const SampleState()) {
    on<SampleItemsRequested>(_onItemsRequested);
    on<SampleItemAdded>(_onItemAdded);
  }

  final GetSampleItems _getSampleItems;
  final AddSampleItem _addSampleItem;

  Future<void> _onItemsRequested(
    SampleItemsRequested event,
    Emitter<SampleState> emit,
  ) async {
    emit(state.copyWith(status: SampleStatus.loading));
    final result = await _getSampleItems(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SampleStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) =>
          emit(state.copyWith(status: SampleStatus.success, items: items)),
    );
  }

  Future<void> _onItemAdded(
    SampleItemAdded event,
    Emitter<SampleState> emit,
  ) async {
    final title = event.title.trim();
    if (title.isEmpty) return;

    emit(state.copyWith(isSubmitting: true));
    final result = await _addSampleItem(AddSampleItemParams(title));
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          isSubmitting: false,
          status: SampleStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(isSubmitting: false));
        add(const SampleItemsRequested());
      },
    );
  }
}
