import 'package:equatable/equatable.dart';

import '../../../../master_data/domain/entities/app_user.dart';
import '../../../../master_data/domain/entities/department.dart';
import '../../../../master_data/domain/entities/item.dart';
import '../../../../master_data/domain/entities/organization.dart';
import '../../../../master_data/domain/entities/unit_of_measure.dart';
import '../../../../master_data/domain/entities/warehouse.dart';

/// Master-data choices the receipt form offers in its dropdowns.
class ReceiptFormOptions extends Equatable {
  const ReceiptFormOptions({
    this.organizations = const [],
    this.departments = const [],
    this.warehouses = const [],
    this.users = const [],
    this.items = const [],
    this.uoms = const [],
  });

  final List<Organization> organizations;
  final List<Department> departments;
  final List<Warehouse> warehouses;
  final List<AppUser> users;
  final List<Item> items;
  final List<UnitOfMeasure> uoms;

  List<Department> departmentsOf(String organizationId) => departments
      .where((d) => d.organizationId == organizationId)
      .toList(growable: false);

  List<Warehouse> warehousesOf(String organizationId) => warehouses
      .where((w) => w.organizationId == organizationId)
      .toList(growable: false);

  String uomName(String? uomId) {
    if (uomId == null) return '';
    for (final u in uoms) {
      if (u.id == uomId) return u.name;
    }
    return '';
  }

  @override
  List<Object?> get props => [
    organizations,
    departments,
    warehouses,
    users,
    items,
    uoms,
  ];
}
