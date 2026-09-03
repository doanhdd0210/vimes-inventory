import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/helpers/app_logger.dart';
import 'master_seed.dart';

/// One-time Firestore seed of the demo master data. Runs at bootstrap when
/// Firebase is on and the `organizations` collection is still empty. Uses fixed
/// document ids (`MasterSeed.*`) so the same records aren't duplicated on a
/// re-run and cross-references stay valid.
class MasterDataSeeder {
  const MasterDataSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> seedIfEmpty() async {
    try {
      final orgs = await _firestore
          .collection(FirestoreCollections.organizations)
          .limit(1)
          .get();
      if (orgs.docs.isNotEmpty) return;

      AppLogger.instance.i('Seeding Firestore master data…');
      final batch = _firestore.batch();

      void put(String collection, String id, Map<String, dynamic> data) {
        batch.set(_firestore.collection(collection).doc(id), data);
      }

      for (final o in MasterSeed.organizations) {
        put(FirestoreCollections.organizations, o.id, o.toMap());
      }
      for (final d in MasterSeed.departments) {
        put(FirestoreCollections.departments, d.id, d.toMap());
      }
      for (final u in MasterSeed.users) {
        put(FirestoreCollections.users, u.id, u.toMap());
      }
      for (final w in MasterSeed.warehouses) {
        put(FirestoreCollections.warehouses, w.id, w.toMap());
      }
      for (final c in MasterSeed.itemCategories) {
        put(FirestoreCollections.itemCategories, c.id, c.toMap());
      }
      for (final m in MasterSeed.unitsOfMeasure) {
        put(FirestoreCollections.unitsOfMeasure, m.id, m.toMap());
      }
      for (final i in MasterSeed.items) {
        put(FirestoreCollections.items, i.id, i.toMap());
      }

      await batch.commit();
      AppLogger.instance.i('Firestore master data seeded.');
    } on FirebaseException catch (e) {
      AppLogger.instance.w('Seed skipped: ${e.message ?? e.code}');
    }
  }
}
