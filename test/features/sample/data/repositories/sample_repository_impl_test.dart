import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/error/exceptions.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/sample/data/datasources/sample_data_source.dart';
import 'package:vimes_inventory/features/sample/data/models/sample_item_model.dart';
import 'package:vimes_inventory/features/sample/data/repositories/sample_repository_impl.dart';

class _MockSampleDataSource extends Mock implements SampleDataSource {}

void main() {
  late _MockSampleDataSource dataSource;
  late SampleRepositoryImpl repository;

  final tModels = [
    SampleItemModel(id: 'a', title: 'A', createdAt: DateTime(2026, 1, 1)),
  ];

  setUp(() {
    dataSource = _MockSampleDataSource();
    repository = SampleRepositoryImpl(dataSource);
  });

  group('getSampleItems', () {
    test('returns Right with data from the datasource', () async {
      when(() => dataSource.getSampleItems()).thenAnswer((_) async => tModels);

      final result = await repository.getSampleItems();

      expect(result, Right<Failure, List<SampleItemModel>>(tModels));
    });

    test('maps ServerException to ServerFailure', () async {
      when(() => dataSource.getSampleItems()).thenThrow(
        const ServerException(message: 'offline', statusCode: 'unavailable'),
      );

      final result = await repository.getSampleItems();

      expect(
        result,
        const Left<Failure, dynamic>(
          ServerFailure(message: 'offline', statusCode: 'unavailable'),
        ),
      );
    });
  });

  group('addSampleItem', () {
    test('returns Right on success', () async {
      when(
        () => dataSource.addSampleItem(any()),
      ).thenAnswer((_) async => tModels.first);

      final result = await repository.addSampleItem('A');

      expect(result.isRight(), isTrue);
      verify(() => dataSource.addSampleItem('A')).called(1);
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => dataSource.addSampleItem(any()),
      ).thenThrow(const ServerException(message: 'denied'));

      final result = await repository.addSampleItem('A');

      expect(result.isLeft(), isTrue);
    });
  });
}
