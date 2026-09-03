import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../features/warehouse_receipt/data/datasources/warehouse_receipt_data_source.dart';
import '../../features/warehouse_receipt/data/datasources/warehouse_receipt_in_memory_data_source.dart';
import '../../features/warehouse_receipt/data/repositories/warehouse_receipt_repository_impl.dart';
import '../../features/warehouse_receipt/domain/repositories/warehouse_receipt_repository.dart';
import '../../features/warehouse_receipt/domain/usecases/create_warehouse_receipt.dart';
import '../../features/warehouse_receipt/domain/usecases/get_warehouse_receipts.dart';
import '../../features/warehouse_receipt/presentation/viewmodel/receipt_form_bloc.dart';
import '../../features/warehouse_receipt/presentation/viewmodel/receipt_list_bloc.dart';
import '../flavors/flavor_config.dart';
import '../helpers/app_logger.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../theme/theme_cubit.dart';

/// Service locator. `sl` is the single access point; registration is grouped
/// core-first, then per feature, and within a feature
/// presentation -> domain -> data -> external.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies({bool? useFirebase}) async {
  final firebaseEnabled =
      useFirebase ??
      (FlavorConfig.isInitialized ? FlavorConfig.instance.useFirebase : true);

  await _initCore(firebaseEnabled: firebaseEnabled);
  _initWarehouseReceipt(firebaseEnabled: firebaseEnabled);
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

void _initWarehouseReceipt({required bool firebaseEnabled}) {
  // Presentation (ViewModel)
  sl.registerFactory(() => ReceiptFormBloc(createWarehouseReceipt: sl()));
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
        : WarehouseReceiptInMemoryDataSource(),
  );
}

/// For widget/unit tests: wipe the locator between cases.
Future<void> resetDependencies() => sl.reset();
