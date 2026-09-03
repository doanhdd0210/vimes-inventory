import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/core/data/crud_data_source.dart';
import 'package:vimes_inventory/core/domain/crud_repository.dart';
import 'package:vimes_inventory/features/master_data/data/master_seed.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/item.dart';

void main() {
  group('InMemoryCrudDataSource + CrudRepositoryImpl (Item)', () {
    late InMemoryCrudDataSource<Item> ds;
    late CrudRepository<Item> repo;

    setUp(() {
      ds = InMemoryCrudDataSource<Item>(
        assignId: (e, id) => e.copyWith(id: id),
        seed: MasterSeed.items,
        compare: (a, b) => a.code.compareTo(b.code),
      );
      repo = CrudRepositoryImpl<Item>(ds);
    });

    test('getAll returns the seed sorted by code', () async {
      final result = await repo.getAll();
      final items = result.getOrElse(() => []);
      expect(items, isNotEmpty);
      expect(items.first.code, 'VT001');
      expect(
        items.map((e) => e.code).toList(),
        List.of(items.map((e) => e.code))..sort(),
      );
    });

    test('create assigns an id then getById finds it', () async {
      final created = await repo.create(
        const Item(
          id: '',
          code: 'VT999',
          name: 'Ống nhựa PVC',
          uomId: 'uom-met',
        ),
      );
      final id = created.getOrElse(() => '');
      expect(id, isNotEmpty);

      final found = await repo.getById(id);
      expect(found.getOrElse(() => null)?.code, 'VT999');
    });

    test('update then delete', () async {
      final seedItem = MasterSeed.items.first;
      await repo.update(seedItem.copyWith(name: 'Đổi tên'));
      expect(
        (await repo.getById(seedItem.id)).getOrElse(() => null)?.name,
        'Đổi tên',
      );

      await repo.delete(seedItem.id);
      expect((await repo.getById(seedItem.id)).getOrElse(() => null), isNull);
    });
  });

  test('MasterSeed is internally consistent', () {
    final uomIds = MasterSeed.unitsOfMeasure.map((u) => u.id).toSet();
    final catIds = MasterSeed.itemCategories.map((c) => c.id).toSet();
    for (final item in MasterSeed.items) {
      expect(uomIds, contains(item.uomId), reason: '${item.code} uom');
      if (item.categoryId != null) {
        expect(catIds, contains(item.categoryId), reason: '${item.code} cat');
      }
    }
    final orgIds = MasterSeed.organizations.map((o) => o.id).toSet();
    for (final d in MasterSeed.departments) {
      expect(orgIds, contains(d.organizationId));
    }
    for (final w in MasterSeed.warehouses) {
      expect(orgIds, contains(w.organizationId));
    }
  });
}
