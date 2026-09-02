import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/sample/data/datasources/sample_in_memory_data_source.dart';

void main() {
  late SampleInMemoryDataSource dataSource;

  setUp(() => dataSource = SampleInMemoryDataSource());

  test('starts with the seed item', () async {
    final items = await dataSource.getSampleItems();
    expect(items, hasLength(1));
    expect(items.single.id, 'seed-1');
  });

  test('addSampleItem persists and returns a new row', () async {
    final added = await dataSource.addSampleItem('New thing');

    expect(added.id, 'mem-1');
    expect(added.title, 'New thing');

    final items = await dataSource.getSampleItems();
    expect(items, hasLength(2));
    expect(items.first.title, 'New thing'); // newest first
  });

  test('list is unmodifiable', () async {
    final items = await dataSource.getSampleItems();
    expect(() => items.clear(), throwsUnsupportedError);
  });
}
