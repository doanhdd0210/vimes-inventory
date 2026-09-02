import 'package:vimes_inventory/features/sample/domain/entities/sample_item.dart';

final tSampleItem = SampleItem(
  id: 'id-1',
  title: 'First item',
  createdAt: DateTime(2026, 1, 2, 3, 4),
);

final tSampleItems = <SampleItem>[
  tSampleItem,
  SampleItem(id: 'id-2', title: 'Second item', createdAt: DateTime(2026, 1, 3)),
];
