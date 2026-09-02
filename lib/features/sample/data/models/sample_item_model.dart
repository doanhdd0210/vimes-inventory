import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/sample_item.dart';

/// Data-layer representation of [SampleItem]: knows how to (de)serialise itself.
class SampleItemModel extends SampleItem {
  const SampleItemModel({
    required super.id,
    required super.title,
    required super.createdAt,
  });

  factory SampleItemModel.fromEntity(SampleItem entity) => SampleItemModel(
    id: entity.id,
    title: entity.title,
    createdAt: entity.createdAt,
  );

  factory SampleItemModel.fromMap(String id, DataMap map) => SampleItemModel(
    id: id,
    title: map['title'] as String? ?? '',
    createdAt: _readTimestamp(map['createdAt']),
  );

  /// Firestore document snapshot -> model.
  factory SampleItemModel.fromSnapshot(DocumentSnapshot<DataMap> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return SampleItemModel.fromMap(snapshot.id, data);
  }

  DataMap toMap() => {
    'title': title,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static DateTime _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
