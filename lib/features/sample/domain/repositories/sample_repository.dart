import '../../../../core/utils/typedefs.dart';
import '../entities/sample_item.dart';

/// Contract the domain layer depends on. The implementation lives in `data/`.
abstract class SampleRepository {
  ResultFuture<List<SampleItem>> getSampleItems();

  ResultFuture<SampleItem> addSampleItem(String title);
}
