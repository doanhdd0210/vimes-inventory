import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/core/usecase/usecase.dart';
import 'package:vimes_inventory/features/sample/domain/entities/sample_item.dart';
import 'package:vimes_inventory/features/sample/domain/usecases/add_sample_item.dart';
import 'package:vimes_inventory/features/sample/domain/usecases/get_sample_items.dart';
import 'package:vimes_inventory/features/sample/presentation/viewmodel/sample_bloc.dart';

import '../../../../fixtures/sample_fixtures.dart';

class _MockGetSampleItems extends Mock implements GetSampleItems {}

class _MockAddSampleItem extends Mock implements AddSampleItem {}

void main() {
  late _MockGetSampleItems getSampleItems;
  late _MockAddSampleItem addSampleItem;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AddSampleItemParams(''));
  });

  setUp(() {
    getSampleItems = _MockGetSampleItems();
    addSampleItem = _MockAddSampleItem();
  });

  SampleBloc build() =>
      SampleBloc(getSampleItems: getSampleItems, addSampleItem: addSampleItem);

  test('initial state is SampleState()', () {
    expect(build().state, const SampleState());
  });

  blocTest<SampleBloc, SampleState>(
    'emits [loading, success] when items load',
    build: () {
      when(
        () => getSampleItems(any()),
      ).thenAnswer((_) async => Right(tSampleItems));
      return build();
    },
    act: (bloc) => bloc.add(const SampleItemsRequested()),
    expect: () => [
      const SampleState(status: SampleStatus.loading),
      SampleState(status: SampleStatus.success, items: tSampleItems),
    ],
  );

  blocTest<SampleBloc, SampleState>(
    'emits [loading, failure] with message when the use case fails',
    build: () {
      when(
        () => getSampleItems(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'down')));
      return build();
    },
    act: (bloc) => bloc.add(const SampleItemsRequested()),
    expect: () => [
      const SampleState(status: SampleStatus.loading),
      const SampleState(status: SampleStatus.failure, errorMessage: 'down'),
    ],
  );

  blocTest<SampleBloc, SampleState>(
    'ignores an empty title',
    build: build,
    act: (bloc) => bloc.add(const SampleItemAdded('   ')),
    expect: () => const <SampleState>[],
  );

  blocTest<SampleBloc, SampleState>(
    'adds an item then reloads the list',
    build: () {
      when(() => addSampleItem(any())).thenAnswer(
        (_) async => Right(
          SampleItem(id: 'n', title: 'New', createdAt: DateTime(2026, 5)),
        ),
      );
      when(
        () => getSampleItems(any()),
      ).thenAnswer((_) async => Right(tSampleItems));
      return build();
    },
    act: (bloc) => bloc.add(const SampleItemAdded('New')),
    expect: () => [
      const SampleState(isSubmitting: true),
      const SampleState(),
      const SampleState(status: SampleStatus.loading),
      SampleState(status: SampleStatus.success, items: tSampleItems),
    ],
    verify: (_) {
      verify(() => addSampleItem(any())).called(1);
      verify(() => getSampleItems(any())).called(1);
    },
  );
}
