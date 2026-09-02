import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/sample/domain/entities/sample_item.dart';
import 'package:vimes_inventory/features/sample/domain/repositories/sample_repository.dart';
import 'package:vimes_inventory/features/sample/domain/usecases/add_sample_item.dart';

import '../../../../fixtures/sample_fixtures.dart';

class _MockSampleRepository extends Mock implements SampleRepository {}

void main() {
  late _MockSampleRepository repository;
  late AddSampleItem usecase;

  setUp(() {
    repository = _MockSampleRepository();
    usecase = AddSampleItem(repository);
  });

  test('delegates the title to the repository', () async {
    when(
      () => repository.addSampleItem(any()),
    ).thenAnswer((_) async => Right(tSampleItem));

    final result = await usecase(const AddSampleItemParams('First item'));

    expect(result, Right<Failure, SampleItem>(tSampleItem));
    verify(() => repository.addSampleItem('First item')).called(1);
  });

  test('propagates repository failure', () async {
    when(
      () => repository.addSampleItem(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'nope')));

    final result = await usecase(const AddSampleItemParams('x'));

    expect(result.isLeft(), isTrue);
  });
}
