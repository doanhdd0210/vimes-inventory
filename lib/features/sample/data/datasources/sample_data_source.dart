import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';
import '../models/sample_item_model.dart';

/// Contract for the Sample feature's backing store. Implemented by
/// [SampleFirestoreDataSource] (production) and `SampleInMemoryDataSource`
/// (tests / offline).
abstract class SampleDataSource {
  Future<List<SampleItemModel>> getSampleItems();

  Future<SampleItemModel> addSampleItem(String title);
}

/// Cloud Firestore implementation. Every Firestore error is normalised to a
/// [ServerException] so the repository has a single failure type to map.
class SampleFirestoreDataSource implements SampleDataSource {
  SampleFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<DataMap> get _collection =>
      _firestore.collection(FirestoreCollections.sampleItems);

  @override
  Future<List<SampleItemModel>> getSampleItems() async {
    try {
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(SampleItemModel.fromSnapshot).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<SampleItemModel> addSampleItem(String title) async {
    try {
      final now = DateTime.now();
      final model = SampleItemModel(id: '', title: title, createdAt: now);
      final ref = await _collection.add(model.toMap());
      return SampleItemModel(id: ref.id, title: title, createdAt: now);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }
}
