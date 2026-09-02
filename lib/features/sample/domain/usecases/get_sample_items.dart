import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/sample_item.dart';
import '../repositories/sample_repository.dart';

class GetSampleItems extends UseCase<List<SampleItem>, NoParams> {
  const GetSampleItems(this._repository);

  final SampleRepository _repository;

  @override
  ResultFuture<List<SampleItem>> call(NoParams params) {
    return _repository.getSampleItems();
  }
}
