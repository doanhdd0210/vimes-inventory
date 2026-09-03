import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/department.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_category.dart';
import '../../domain/entities/organization.dart';
import '../../domain/entities/unit_of_measure.dart';
import '../../domain/entities/warehouse.dart';

/// Data-layer (de)serialisers for the master entities. Kept in one file since
/// each is a handful of plain fields.

class OrganizationModel extends Organization {
  const OrganizationModel({
    required super.id,
    required super.code,
    required super.name,
    super.taxCode,
    super.address,
    super.phone,
    super.isActive,
  });

  factory OrganizationModel.fromEntity(Organization e) => OrganizationModel(
    id: e.id,
    code: e.code,
    name: e.name,
    taxCode: e.taxCode,
    address: e.address,
    phone: e.phone,
    isActive: e.isActive,
  );

  factory OrganizationModel.fromMap(String id, DataMap m) => OrganizationModel(
    id: id,
    code: m['code'] as String? ?? '',
    name: m['name'] as String? ?? '',
    taxCode: m['taxCode'] as String?,
    address: m['address'] as String?,
    phone: m['phone'] as String?,
    isActive: m['isActive'] as bool? ?? true,
  );

  DataMap toMap() => {
    'code': code,
    'name': name,
    'taxCode': taxCode,
    'address': address,
    'phone': phone,
    'isActive': isActive,
  };
}

class DepartmentModel extends Department {
  const DepartmentModel({
    required super.id,
    required super.organizationId,
    required super.code,
    required super.name,
    super.parentId,
    super.isActive,
  });

  factory DepartmentModel.fromEntity(Department e) => DepartmentModel(
    id: e.id,
    organizationId: e.organizationId,
    code: e.code,
    name: e.name,
    parentId: e.parentId,
    isActive: e.isActive,
  );

  factory DepartmentModel.fromMap(String id, DataMap m) => DepartmentModel(
    id: id,
    organizationId: m['organizationId'] as String? ?? '',
    code: m['code'] as String? ?? '',
    name: m['name'] as String? ?? '',
    parentId: m['parentId'] as String?,
    isActive: m['isActive'] as bool? ?? true,
  );

  DataMap toMap() => {
    'organizationId': organizationId,
    'code': code,
    'name': name,
    'parentId': parentId,
    'isActive': isActive,
  };
}

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.organizationId,
    required super.username,
    required super.fullName,
    super.departmentId,
    super.email,
    super.position,
    super.role,
    super.isActive,
  });

  factory AppUserModel.fromEntity(AppUser e) => AppUserModel(
    id: e.id,
    organizationId: e.organizationId,
    username: e.username,
    fullName: e.fullName,
    departmentId: e.departmentId,
    email: e.email,
    position: e.position,
    role: e.role,
    isActive: e.isActive,
  );

  factory AppUserModel.fromMap(String id, DataMap m) => AppUserModel(
    id: id,
    organizationId: m['organizationId'] as String? ?? '',
    username: m['username'] as String? ?? '',
    fullName: m['fullName'] as String? ?? '',
    departmentId: m['departmentId'] as String?,
    email: m['email'] as String?,
    position: m['position'] as String?,
    role: UserRole.fromName(m['role'] as String?),
    isActive: m['isActive'] as bool? ?? true,
  );

  DataMap toMap() => {
    'organizationId': organizationId,
    'username': username,
    'fullName': fullName,
    'departmentId': departmentId,
    'email': email,
    'position': position,
    'role': role.name,
    'isActive': isActive,
  };
}

class WarehouseModel extends Warehouse {
  const WarehouseModel({
    required super.id,
    required super.organizationId,
    required super.code,
    required super.name,
    super.location,
    super.keeperUserId,
    super.isActive,
  });

  factory WarehouseModel.fromEntity(Warehouse e) => WarehouseModel(
    id: e.id,
    organizationId: e.organizationId,
    code: e.code,
    name: e.name,
    location: e.location,
    keeperUserId: e.keeperUserId,
    isActive: e.isActive,
  );

  factory WarehouseModel.fromMap(String id, DataMap m) => WarehouseModel(
    id: id,
    organizationId: m['organizationId'] as String? ?? '',
    code: m['code'] as String? ?? '',
    name: m['name'] as String? ?? '',
    location: m['location'] as String?,
    keeperUserId: m['keeperUserId'] as String?,
    isActive: m['isActive'] as bool? ?? true,
  );

  DataMap toMap() => {
    'organizationId': organizationId,
    'code': code,
    'name': name,
    'location': location,
    'keeperUserId': keeperUserId,
    'isActive': isActive,
  };
}

class ItemCategoryModel extends ItemCategory {
  const ItemCategoryModel({
    required super.id,
    required super.code,
    required super.name,
    super.parentId,
    super.isActive,
  });

  factory ItemCategoryModel.fromEntity(ItemCategory e) => ItemCategoryModel(
    id: e.id,
    code: e.code,
    name: e.name,
    parentId: e.parentId,
    isActive: e.isActive,
  );

  factory ItemCategoryModel.fromMap(String id, DataMap m) => ItemCategoryModel(
    id: id,
    code: m['code'] as String? ?? '',
    name: m['name'] as String? ?? '',
    parentId: m['parentId'] as String?,
    isActive: m['isActive'] as bool? ?? true,
  );

  DataMap toMap() => {
    'code': code,
    'name': name,
    'parentId': parentId,
    'isActive': isActive,
  };
}

class UnitOfMeasureModel extends UnitOfMeasure {
  const UnitOfMeasureModel({
    required super.id,
    required super.code,
    required super.name,
  });

  factory UnitOfMeasureModel.fromEntity(UnitOfMeasure e) =>
      UnitOfMeasureModel(id: e.id, code: e.code, name: e.name);

  factory UnitOfMeasureModel.fromMap(String id, DataMap m) =>
      UnitOfMeasureModel(
        id: id,
        code: m['code'] as String? ?? '',
        name: m['name'] as String? ?? '',
      );

  DataMap toMap() => {'code': code, 'name': name};
}

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.code,
    required super.name,
    required super.uomId,
    super.specification,
    super.categoryId,
    super.defaultUnitPrice,
    super.minStock,
    super.isActive,
  });

  factory ItemModel.fromEntity(Item e) => ItemModel(
    id: e.id,
    code: e.code,
    name: e.name,
    uomId: e.uomId,
    specification: e.specification,
    categoryId: e.categoryId,
    defaultUnitPrice: e.defaultUnitPrice,
    minStock: e.minStock,
    isActive: e.isActive,
  );

  factory ItemModel.fromMap(String id, DataMap m) => ItemModel(
    id: id,
    code: m['code'] as String? ?? '',
    name: m['name'] as String? ?? '',
    uomId: m['uomId'] as String? ?? '',
    specification: m['specification'] as String?,
    categoryId: m['categoryId'] as String?,
    defaultUnitPrice: m['defaultUnitPrice'] as num?,
    minStock: m['minStock'] as num?,
    isActive: m['isActive'] as bool? ?? true,
  );

  DataMap toMap() => {
    'code': code,
    'name': name,
    'uomId': uomId,
    'specification': specification,
    'categoryId': categoryId,
    'defaultUnitPrice': defaultUnitPrice,
    'minStock': minStock,
    'isActive': isActive,
  };
}
