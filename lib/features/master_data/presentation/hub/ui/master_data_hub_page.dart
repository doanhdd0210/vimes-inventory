import 'package:flutter/material.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/department.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/item_category.dart';
import '../../../domain/entities/organization.dart';
import '../../../domain/entities/unit_of_measure.dart';
import '../../../domain/entities/warehouse.dart';
import '../../list/ui/master_list_page.dart';

/// "Danh mục" hub — one tile per master catalog.
class MasterDataHubPage extends StatelessWidget {
  const MasterDataHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = <_Entry>[
      _Entry(
        'Đơn vị',
        Icons.business,
        () => MasterListPage<Organization>(
          title: 'Đơn vị',
          titleOf: (e) => '${e.code} — ${e.name}',
          subtitleOf: (e) => e.address ?? '',
        ),
      ),
      _Entry(
        'Bộ phận',
        Icons.account_tree_outlined,
        () => MasterListPage<Department>(
          title: 'Bộ phận',
          titleOf: (e) => '${e.code} — ${e.name}',
        ),
      ),
      _Entry(
        'Người dùng',
        Icons.people_outline,
        () => MasterListPage<AppUser>(
          title: 'Người dùng',
          titleOf: (e) => e.fullName,
          subtitleOf: (e) => '${e.position ?? e.username} · ${e.role.label}',
        ),
      ),
      _Entry(
        'Kho',
        Icons.warehouse_outlined,
        () => MasterListPage<Warehouse>(
          title: 'Kho',
          titleOf: (e) => '${e.code} — ${e.name}',
          subtitleOf: (e) => e.location ?? '',
        ),
      ),
      _Entry(
        'Nhóm sản phẩm',
        Icons.category_outlined,
        () => MasterListPage<ItemCategory>(
          title: 'Nhóm sản phẩm',
          titleOf: (e) => '${e.code} — ${e.name}',
        ),
      ),
      _Entry(
        'Đơn vị tính',
        Icons.straighten,
        () => MasterListPage<UnitOfMeasure>(
          title: 'Đơn vị tính',
          titleOf: (e) => '${e.code} — ${e.name}',
        ),
      ),
      _Entry(
        'Sản phẩm / vật tư',
        Icons.inventory_2_outlined,
        () => MasterListPage<Item>(
          title: 'Sản phẩm / vật tư',
          titleOf: (e) => '${e.code} — ${e.name}',
          subtitleOf: (e) => e.specification ?? '',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục')),
      body: ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, _) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final entry = entries[i];
          return ListTile(
            leading: Icon(entry.icon),
            title: Text(entry.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => entry.build())),
          );
        },
      ),
    );
  }
}

class _Entry {
  _Entry(this.label, this.icon, this.build);

  final String label;
  final IconData icon;
  final Widget Function() build;
}
