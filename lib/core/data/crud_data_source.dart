import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entity.dart';
import '../error/exceptions.dart';
import '../utils/typedefs.dart';

/// CRUD contract shared by every master-data collection. Works in entities
/// ([E]); the concrete `*Model` classes are just (de)serialisers used to build
/// the [fromMap] / [toMap] config.
abstract class CrudDataSource<E extends Entity> {
  Future<List<E>> getAll();
  Future<E?> getById(String id);
  Future<String> create(E entity);
  Future<void> update(E entity);
  Future<void> delete(String id);
}

/// Cloud Firestore implementation, configured per collection with a
/// (de)serialiser pair. Firestore errors are normalised to [ServerException].
class FirestoreCrudDataSource<E extends Entity> implements CrudDataSource<E> {
  FirestoreCrudDataSource({
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required this.fromMap,
    required this.toMap,
    this.orderByField,
  }) : _collection = firestore.collection(collectionPath);

  final String collectionPath;
  final E Function(String id, DataMap map) fromMap;
  final DataMap Function(E entity) toMap;
  final String? orderByField;

  final CollectionReference<DataMap> _collection;

  @override
  Future<List<E>> getAll() async {
    try {
      final query = orderByField == null
          ? _collection
          : _collection.orderBy(orderByField!);
      final snapshot = await query.get();
      return snapshot.docs
          .map((d) => fromMap(d.id, d.data()))
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<E?> getById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      final data = doc.data();
      return data == null ? null : fromMap(doc.id, data);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<String> create(E entity) async {
    try {
      final ref = await _collection.add(toMap(entity));
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<void> update(E entity) async {
    try {
      await _collection.doc(entity.id).set(toMap(entity));
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }
}

/// In-memory implementation seeded at construction. Used while Firebase is
/// disabled so the app + tests run without credentials.
class InMemoryCrudDataSource<E extends Entity> implements CrudDataSource<E> {
  InMemoryCrudDataSource({
    required this.assignId,
    Iterable<E> seed = const [],
    this.compare,
  }) {
    for (final entity in seed) {
      _store[entity.id] = entity;
    }
  }

  /// Returns a copy of [entity] carrying the freshly generated [id].
  final E Function(E entity, String id) assignId;
  final int Function(E a, E b)? compare;

  final Map<String, E> _store = {};
  var _autoId = 0;

  @override
  Future<List<E>> getAll() async {
    final list = _store.values.toList();
    if (compare != null) list.sort(compare);
    return List.unmodifiable(list);
  }

  @override
  Future<E?> getById(String id) async => _store[id];

  @override
  Future<String> create(E entity) async {
    final id = 'mem-${++_autoId}';
    _store[id] = assignId(entity, id);
    return id;
  }

  @override
  Future<void> update(E entity) async {
    _store[entity.id] = entity;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}
