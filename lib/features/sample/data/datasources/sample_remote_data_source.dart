import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';
import '../models/sample_item_model.dart';

abstract class SampleRemoteDataSource {
  Future<List<SampleItemModel>> getSampleItems();

  Future<SampleItemModel> addSampleItem(String title);
}

/// Cloud Firestore implementation. Any Firestore error is normalised to a
/// [ServerException] so the repository has a single failure type to map.
class SampleRemoteDataSourceImpl implements SampleRemoteDataSource {
  SampleRemoteDataSourceImpl(this._firestore);

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
