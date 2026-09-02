import '../models/sample_item_model.dart';
import 'sample_data_source.dart';

/// In-memory [SampleDataSource]. Wired by the DI container when Firebase is
/// disabled so the app runs (and CI passes) without Firebase credentials.
class SampleInMemoryDataSource implements SampleDataSource {
  SampleInMemoryDataSource();

  final List<SampleItemModel> _items = [
    SampleItemModel(
      id: 'seed-1',
      title: 'Clean Architecture base ready',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  var _autoId = 0;

  @override
  Future<List<SampleItemModel>> getSampleItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(
      _items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<SampleItemModel> addSampleItem(String title) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final model = SampleItemModel(
      id: 'mem-${++_autoId}',
      title: title,
      createdAt: DateTime.now(),
    );
    _items.add(model);
    return model;
  }
}
