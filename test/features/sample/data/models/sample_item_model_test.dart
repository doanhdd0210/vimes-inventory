import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/features/sample/data/models/sample_item_model.dart';
import 'package:vimes_inventory/features/sample/domain/entities/sample_item.dart';

void main() {
  final createdAt = DateTime(2026, 2, 3, 4, 5);

  final tModel = SampleItemModel(
    id: 'doc-1',
    title: 'Widget',
    createdAt: createdAt,
  );

  test('is a SampleItem', () {
    expect(tModel, isA<SampleItem>());
  });

  test('fromMap reads a Firestore Timestamp', () {
    final model = SampleItemModel.fromMap('doc-1', {
      'title': 'Widget',
      'createdAt': Timestamp.fromDate(createdAt),
    });

    expect(model, tModel);
  });

  test('fromMap tolerates a missing title and bad timestamp', () {
    final model = SampleItemModel.fromMap('doc-2', const {});

    expect(model.title, '');
    expect(model.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('toMap round-trips through fromMap', () {
    final map = tModel.toMap();
    final restored = SampleItemModel.fromMap('doc-1', map);

    expect(restored, tModel);
    expect(map['createdAt'], isA<Timestamp>());
  });

  test('fromEntity copies all fields', () {
    final entity = SampleItem(id: 'x', title: 'y', createdAt: createdAt);

    final model = SampleItemModel.fromEntity(entity);

    expect(model.id, entity.id);
    expect(model.title, entity.title);
    expect(model.createdAt, entity.createdAt);
    expect(model.props, entity.props);
  });
}
