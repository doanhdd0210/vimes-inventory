part of 'sample_bloc.dart';

sealed class SampleEvent extends Equatable {
  const SampleEvent();

  @override
  List<Object?> get props => [];
}

/// View asks the ViewModel to (re)load the list.
class SampleItemsRequested extends SampleEvent {
  const SampleItemsRequested();
}

/// View submits a new item from the input field.
class SampleItemAdded extends SampleEvent {
  const SampleItemAdded(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}
