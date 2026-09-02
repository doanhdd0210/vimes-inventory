part of 'sample_bloc.dart';

enum SampleStatus { initial, loading, success, failure }

/// Immutable UI state exposed by [SampleBloc] (the ViewModel) to the View.
class SampleState extends Equatable {
  const SampleState({
    this.status = SampleStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  final SampleStatus status;
  final List<SampleItem> items;
  final String? errorMessage;
  final bool isSubmitting;

  SampleState copyWith({
    SampleStatus? status,
    List<SampleItem>? items,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return SampleState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, isSubmitting];
}
