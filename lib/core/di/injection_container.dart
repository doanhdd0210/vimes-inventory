import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../features/master_data/data/master_seed.dart';
import '../../features/master_data/data/models/master_models.dart';
import '../../features/master_data/domain/entities/app_user.dart';
import '../../features/master_data/domain/entities/department.dart';
import '../../features/master_data/domain/entities/item.dart';
import '../../features/master_data/domain/entities/item_category.dart';
import '../../features/master_data/domain/entities/organization.dart';
import '../../features/master_data/domain/entities/unit_of_measure.dart';
import '../../features/master_data/domain/entities/warehouse.dart';
import '../../features/stock/data/in_memory_stock_store.dart';
import '../../features/stock/data/stock_data_source.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/warehouse_receipt/data/datasources/warehouse_receipt_data_source.dart';
import '../../features/warehouse_receipt/data/datasources/warehouse_receipt_in_memory_data_source.dart';
import '../../features/warehouse_receipt/data/repositories/warehouse_receipt_repository_impl.dart';
import '../../features/warehouse_receipt/domain/repositories/warehouse_receipt_repository.dart';
import '../../features/warehouse_receipt/domain/usecases/create_warehouse_receipt.dart';
import '../../features/warehouse_receipt/domain/usecases/get_warehouse_receipts.dart';
import '../../features/warehouse_receipt/presentation/viewmodel/receipt_form_bloc.dart';
import '../../features/warehouse_receipt/presentation/viewmodel/receipt_list_bloc.dart';
import '../constants/firestore_collections.dart';
import '../data/crud_data_source.dart';
import '../domain/crud_repository.dart';
import '../domain/entity.dart';
import '../flavors/flavor_config.dart';
import '../helpers/app_logger.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../theme/theme_cubit.dart';
import '../utils/typedefs.dart';

/// Service locator. `sl` is the single access point; registration is grouped
/// core-first, then per feature, and within a feature
/// presentation -> domain -> data -> external.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies({bool? useFirebase}) async {
  final firebaseEnabled =
      useFirebase ??
      (FlavorConfig.isInitialized ? FlavorConfig.instance.useFirebase : true);

  await _initCore(firebaseEnabled: firebaseEnabled);
  _initMasterData(firebaseEnabled: firebaseEnabled);
  _initStock(firebaseEnabled: firebaseEnabled);
  _initWarehouseReceipt(firebaseEnabled: firebaseEnabled);
}

void _initStock({required bool firebaseEnabled}) {
  // Shared mutable store for the offline path (posted by the receipt datasource,
  // read by the stock screens).
  sl.registerLazySingleton<InMemoryStockStore>(() => InMemoryStockStore());

  sl.registerLazySingleton<StockDataSource>(
    () => firebaseEnabled
        ? StockFirestoreDataSource(sl())
        : StockInMemoryDataSource(sl()),
  );
  sl.registerLazySingleton<StockRepository>(() => StockRepositoryImpl(sl()));
}

Future<void> _initCore({required bool firebaseEnabled}) async {
  // Storage
  final localStorage = await SharedPrefsLocalStorage.create();
  sl.registerSingleton<LocalStorage>(localStorage);
  sl.registerLazySingleton<SecureStorage>(() => FlutterSecureStorageImpl());

  // Cross-cutting
  sl.registerLazySingleton<AppLogger>(() => AppLogger.instance);
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));

  // External
  if (firebaseEnabled) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }
}

/// Registers `CrudDataSource<E>` (Firestore or in-memory+seed) and
/// `CrudRepository<E>` for one master entity. `fromMap` may return a `*Model`
/// (subtype of [E]); `toMap` typically does `XModel.fromEntity(e).toMap()`.
void _registerCrud<E extends Entity>({
  required bool firebaseEnabled,
  required String collectionPath,
  required E Function(String id, DataMap map) fromMap,
  required DataMap Function(E entity) toMap,
  required E Function(E entity, String id) assignId,
  required Iterable<E> seed,
  String? orderByField,
  int Function(E a, E b)? compare,
}) {
  sl.registerLazySingleton<CrudDataSource<E>>(
    () => firebaseEnabled
        ? FirestoreCrudDataSource<E>(
            firestore: sl(),
            collectionPath: collectionPath,
            fromMap: fromMap,
            toMap: toMap,
            orderByField: orderByField,
          )
        : InMemoryCrudDataSource<E>(
            assignId: assignId,
            seed: seed,
            compare: compare,
          ),
  );
  sl.registerLazySingleton<CrudRepository<E>>(
    () => CrudRepositoryImpl<E>(sl<CrudDataSource<E>>()),
  );
}

void _initMasterData({required bool firebaseEnabled}) {
  _registerCrud<Organization>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.organizations,
    fromMap: OrganizationModel.fromMap,
    toMap: (e) => OrganizationModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.organizations,
    orderByField: 'name',
    compare: (a, b) => a.name.compareTo(b.name),
  );
  _registerCrud<Department>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.departments,
    fromMap: DepartmentModel.fromMap,
    toMap: (e) => DepartmentModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.departments,
    orderByField: 'name',
    compare: (a, b) => a.name.compareTo(b.name),
  );
  _registerCrud<AppUser>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.users,
    fromMap: AppUserModel.fromMap,
    toMap: (e) => AppUserModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.users,
    orderByField: 'fullName',
    compare: (a, b) => a.fullName.compareTo(b.fullName),
  );
  _registerCrud<Warehouse>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.warehouses,
    fromMap: WarehouseModel.fromMap,
    toMap: (e) => WarehouseModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.warehouses,
    orderByField: 'name',
    compare: (a, b) => a.name.compareTo(b.name),
  );
  _registerCrud<ItemCategory>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.itemCategories,
    fromMap: ItemCategoryModel.fromMap,
    toMap: (e) => ItemCategoryModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.itemCategories,
    orderByField: 'name',
    compare: (a, b) => a.name.compareTo(b.name),
  );
  _registerCrud<UnitOfMeasure>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.unitsOfMeasure,
    fromMap: UnitOfMeasureModel.fromMap,
    toMap: (e) => UnitOfMeasureModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.unitsOfMeasure,
    orderByField: 'code',
    compare: (a, b) => a.code.compareTo(b.code),
  );
  _registerCrud<Item>(
    firebaseEnabled: firebaseEnabled,
    collectionPath: FirestoreCollections.items,
    fromMap: ItemModel.fromMap,
    toMap: (e) => ItemModel.fromEntity(e).toMap(),
    assignId: (e, id) => e.copyWith(id: id),
    seed: MasterSeed.items,
    orderByField: 'name',
    compare: (a, b) => a.name.compareTo(b.name),
  );
}

void _initWarehouseReceipt({required bool firebaseEnabled}) {
  // Presentation (ViewModel)
  sl.registerFactory(
    () => ReceiptFormBloc(
      createWarehouseReceipt: sl(),
      organizations: sl<CrudRepository<Organization>>(),
      departments: sl<CrudRepository<Department>>(),
      warehouses: sl<CrudRepository<Warehouse>>(),
      users: sl<CrudRepository<AppUser>>(),
      items: sl<CrudRepository<Item>>(),
      uoms: sl<CrudRepository<UnitOfMeasure>>(),
    ),
  );
  sl.registerFactory(() => ReceiptListBloc(getWarehouseReceipts: sl()));

  // Domain
  sl.registerLazySingleton(() => CreateWarehouseReceipt(sl()));
  sl.registerLazySingleton(() => GetWarehouseReceipts(sl()));

  // Data
  sl.registerLazySingleton<WarehouseReceiptRepository>(
    () => WarehouseReceiptRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WarehouseReceiptDataSource>(
    () => firebaseEnabled
        ? WarehouseReceiptFirestoreDataSource(sl())
        : WarehouseReceiptInMemoryDataSource(sl<InMemoryStockStore>()),
  );
}

/// For widget/unit tests: wipe the locator between cases.
Future<void> resetDependencies() => sl.reset();
