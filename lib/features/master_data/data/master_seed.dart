import '../domain/entities/app_user.dart';
import 'models/master_models.dart';

/// Demo master data used by the in-memory datasources while Firebase is off.
/// For Firestore, import the same shape once via a one-off script / console.
class MasterSeed {
  const MasterSeed._();

  static const orgId = 'org-vimes';
  static const orgIdHn = 'org-vimes-hn';
  static const orgIdSg = 'org-vimes-sg';
  static const dptWarehouse = 'dept-kho';
  static const dptAccounting = 'dept-ketoan';

  static const uomCai = 'uom-cai';
  static const uomKg = 'uom-kg';
  static const uomMet = 'uom-met';
  static const uomThung = 'uom-thung';
  static const uomBo = 'uom-bo';

  static const catThep = 'cat-thep';
  static const catDien = 'cat-dien';
  static const catVptp = 'cat-vptp';

  static const userAdmin = 'user-admin';
  static const userKeeper = 'user-thukho';
  static const userAccountant = 'user-ketoan';
  static const userDeliver = 'user-giaohang';

  static const whMain = 'wh-chinh';
  static const whSpare = 'wh-phu';

  static final organizations = <OrganizationModel>[
    const OrganizationModel(
      id: orgId,
      code: 'VIMES',
      name: 'Công ty CP VIMES',
      taxCode: '0101234567',
      address: 'Tầng 8, toà nhà License, Cầu Giấy, Hà Nội',
      phone: '024 3200 1234',
    ),
    const OrganizationModel(
      id: orgIdHn,
      code: 'VIMES-HN',
      name: 'Chi nhánh VIMES Hà Nội',
      taxCode: '0101234567-001',
      address: 'KCN Quang Minh, Mê Linh, Hà Nội',
      phone: '024 3765 8899',
    ),
    const OrganizationModel(
      id: orgIdSg,
      code: 'VIMES-SG',
      name: 'Chi nhánh VIMES TP. Hồ Chí Minh',
      taxCode: '0101234567-002',
      address: '12 Nguyễn Văn Bảo, Gò Vấp, TP. HCM',
      phone: '028 3894 5566',
    ),
  ];

  static final departments = <DepartmentModel>[
    const DepartmentModel(
      id: dptWarehouse,
      organizationId: orgId,
      code: 'KHO',
      name: 'Phòng Kho vận',
    ),
    const DepartmentModel(
      id: dptAccounting,
      organizationId: orgId,
      code: 'KT',
      name: 'Phòng Kế toán',
    ),
  ];

  static final users = <AppUserModel>[
    const AppUserModel(
      id: userAdmin,
      organizationId: orgId,
      departmentId: dptWarehouse,
      username: 'admin',
      fullName: 'Đỗ Đức Doanh',
      position: 'Quản trị hệ thống',
      role: UserRole.admin,
    ),
    const AppUserModel(
      id: userKeeper,
      organizationId: orgId,
      departmentId: dptWarehouse,
      username: 'thukho',
      fullName: 'Nguyễn Văn Kho',
      position: 'Thủ kho',
      role: UserRole.warehouseKeeper,
    ),
    const AppUserModel(
      id: userAccountant,
      organizationId: orgId,
      departmentId: dptAccounting,
      username: 'ketoan',
      fullName: 'Trần Thị Toán',
      position: 'Kế toán trưởng',
      role: UserRole.accountant,
    ),
    const AppUserModel(
      id: userDeliver,
      organizationId: orgId,
      departmentId: dptWarehouse,
      username: 'giaohang',
      fullName: 'Lê Văn Giao',
      position: 'Nhân viên giao nhận',
      role: UserRole.staff,
    ),
  ];

  static final warehouses = <WarehouseModel>[
    const WarehouseModel(
      id: whMain,
      organizationId: orgId,
      code: 'K01',
      name: 'Kho chính',
      location: 'Tầng 1 - Nhà A',
      keeperUserId: userKeeper,
    ),
    const WarehouseModel(
      id: whSpare,
      organizationId: orgId,
      code: 'K02',
      name: 'Kho phụ tùng',
      location: 'Nhà B',
      keeperUserId: userKeeper,
    ),
  ];

  static final itemCategories = <ItemCategoryModel>[
    const ItemCategoryModel(id: catThep, code: 'THEP', name: 'Thép & kim loại'),
    const ItemCategoryModel(id: catDien, code: 'DIEN', name: 'Thiết bị điện'),
    const ItemCategoryModel(id: catVptp, code: 'VPP', name: 'Văn phòng phẩm'),
  ];

  static final unitsOfMeasure = <UnitOfMeasureModel>[
    const UnitOfMeasureModel(id: uomCai, code: 'CAI', name: 'Cái'),
    const UnitOfMeasureModel(id: uomKg, code: 'KG', name: 'Kilôgam'),
    const UnitOfMeasureModel(id: uomMet, code: 'M', name: 'Mét'),
    const UnitOfMeasureModel(id: uomThung, code: 'THUNG', name: 'Thùng'),
    const UnitOfMeasureModel(id: uomBo, code: 'BO', name: 'Bộ'),
  ];

  static final items = <ItemModel>[
    const ItemModel(
      id: 'item-thephop',
      code: 'VT001',
      name: 'Thép hộp mạ kẽm 40x40x1.4mm',
      uomId: uomMet,
      categoryId: catThep,
      defaultUnitPrice: 42000,
      minStock: 100,
    ),
    const ItemModel(
      id: 'item-thepla',
      code: 'VT002',
      name: 'Thép lá cán nguội 1.0mm',
      uomId: uomKg,
      categoryId: catThep,
      defaultUnitPrice: 18500,
    ),
    const ItemModel(
      id: 'item-day-dien',
      code: 'VT010',
      name: 'Dây điện Cadivi CV 2x2.5',
      uomId: uomMet,
      categoryId: catDien,
      defaultUnitPrice: 9500,
      minStock: 200,
    ),
    const ItemModel(
      id: 'item-aptomat',
      code: 'VT011',
      name: 'Aptomat MCB 2P 32A',
      uomId: uomCai,
      categoryId: catDien,
      defaultUnitPrice: 135000,
    ),
    const ItemModel(
      id: 'item-giay-a4',
      code: 'VT020',
      name: 'Giấy in A4 Double A 70gsm',
      uomId: uomThung,
      categoryId: catVptp,
      defaultUnitPrice: 235000,
    ),
    const ItemModel(
      id: 'item-but-bi',
      code: 'VT021',
      name: 'Bút bi Thiên Long TL-08',
      uomId: uomCai,
      categoryId: catVptp,
      defaultUnitPrice: 3500,
    ),
  ];
}
