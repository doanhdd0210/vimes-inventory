import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/core/usecase/usecase.dart';
import 'package:vimes_inventory/features/sample/domain/entities/sample_item.dart';
import 'package:vimes_inventory/features/sample/domain/repositories/sample_repository.dart';
import 'package:vimes_inventory/features/sample/domain/usecases/get_sample_items.dart';

import '../../../../fixtures/sample_fixtures.dart';

class _MockSampleRepository extends Mock implements SampleRepository {}

void main() {
  late _MockSampleRepository repository;
  late GetSampleItems usecase;

  setUp(() {
    repository = _MockSampleRepository();
    usecase = GetSampleItems(repository);
  });

  test('forwards the repository list on success', () async {
    when(
      () => repository.getSampleItems(),
    ).thenAnswer((_) async => Right(tSampleItems));

    final result = await usecase(const NoParams());

    expect(result, Right<Failure, List<SampleItem>>(tSampleItems));
    verify(() => repository.getSampleItems()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('forwards a failure unchanged', () async {
    const failure = ServerFailure(message: 'boom');
    when(
      () => repository.getSampleItems(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(const NoParams());

    expect(result, const Left<Failure, List<SampleItem>>(failure));
  });
}
