import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../features/sample/data/datasources/sample_data_source.dart';
import '../../features/sample/data/datasources/sample_in_memory_data_source.dart';
import '../../features/sample/data/repositories/sample_repository_impl.dart';
import '../../features/sample/domain/repositories/sample_repository.dart';
import '../../features/sample/domain/usecases/add_sample_item.dart';
import '../../features/sample/domain/usecases/get_sample_items.dart';
import '../../features/sample/presentation/viewmodel/sample_bloc.dart';
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
  _initSample(firebaseEnabled: firebaseEnabled);
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

void _initSample({required bool firebaseEnabled}) {
  // Presentation (ViewModel) — factory: a fresh instance per screen.
  sl.registerFactory(
    () => SampleBloc(getSampleItems: sl(), addSampleItem: sl()),
  );

  // Domain
  sl.registerLazySingleton(() => GetSampleItems(sl()));
  sl.registerLazySingleton(() => AddSampleItem(sl()));

  // Data
  sl.registerLazySingleton<SampleRepository>(() => SampleRepositoryImpl(sl()));
  sl.registerLazySingleton<SampleDataSource>(
    () => firebaseEnabled
        ? SampleFirestoreDataSource(sl())
        : SampleInMemoryDataSource(),
  );
}

/// For widget/unit tests: wipe the locator between cases.
Future<void> resetDependencies() => sl.reset();
