import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/helpers/app_logger.dart';
import 'master_seed.dart';

/// Keeps the Firestore master data in sync with [MasterSeed] on every sign-in.
///
/// Writes are an idempotent upsert (`set` + `merge` on fixed `MasterSeed.*`
/// ids), so running it repeatedly never duplicates a record and picks up new
/// seed entries added later (e.g. extra đơn vị). It is a demo convenience —
/// editing a seeded record through the app will be reset on the next launch;
/// records added by the user keep their own ids and are untouched.
class MasterDataSeeder {
  const MasterDataSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> sync() async {
    try {
      AppLogger.instance.i('Syncing Firestore master data…');
      final batch = _firestore.batch();

      void put(String collection, String id, Map<String, dynamic> data) {
        batch.set(
          _firestore.collection(collection).doc(id),
          data,
          SetOptions(merge: true),
        );
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
      AppLogger.instance.i('Firestore master data synced.');
    } on FirebaseException catch (e) {
      AppLogger.instance.w('Master data sync skipped: ${e.message ?? e.code}');
    }
  }
}
