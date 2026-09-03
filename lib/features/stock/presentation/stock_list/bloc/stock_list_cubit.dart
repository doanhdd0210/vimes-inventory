import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/domain/crud_repository.dart';
import '../../../../master_data/domain/entities/item.dart';
import '../../../../master_data/domain/entities/organization.dart';
import '../../../../master_data/domain/entities/warehouse.dart';
import '../../../domain/entities/inventory_stock.dart';
import '../../../domain/repositories/stock_repository.dart';

enum StockListStatus { loading, success, failure }

class StockRow extends Equatable {
  const StockRow({
    required this.stock,
    required this.itemName,
    required this.itemCode,
    required this.warehouseName,
    required this.belowMin,
  });

  final InventoryStock stock;
  final String itemName;
  final String itemCode;
  final String warehouseName;
  final bool belowMin;

  @override
  List<Object?> get props => [
    stock,
    itemName,
    itemCode,
    warehouseName,
    belowMin,
  ];
}

class StockListState extends Equatable {
  const StockListState({
    this.status = StockListStatus.loading,
    this.rows = const [],
    this.errorMessage,
  });

  final StockListStatus status;
  final List<StockRow> rows;
  final String? errorMessage;

  StockListState copyWith({
    StockListStatus? status,
    List<StockRow>? rows,
    String? errorMessage,
  }) => StockListState(
    status: status ?? this.status,
    rows: rows ?? this.rows,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, rows, errorMessage];
}

class StockListCubit extends Cubit<StockListState> {
  StockListCubit({
    required StockRepository stockRepository,
    required CrudRepository<Organization> organizations,
    required CrudRepository<Item> items,
    required CrudRepository<Warehouse> warehouses,
  }) : _stock = stockRepository,
       _organizations = organizations,
       _items = items,
       _warehouses = warehouses,
       super(const StockListState());

  final StockRepository _stock;
  final CrudRepository<Organization> _organizations;
  final CrudRepository<Item> _items;
  final CrudRepository<Warehouse> _warehouses;

  Future<void> load() async {
    emit(state.copyWith(status: StockListStatus.loading));

    final orgsResult = await _organizations.getAll();
    final orgId = orgsResult.fold(
      (_) => null,
      (list) => list.isEmpty ? null : list.first.id,
    );
    if (orgId == null) {
      emit(state.copyWith(status: StockListStatus.success, rows: const []));
      return;
    }

    final stockResult = await _stock.getInventory(orgId);
    final itemsResult = await _items.getAll();
    final whResult = await _warehouses.getAll();

    await stockResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: StockListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stock) async {
        final items = itemsResult.getOrElse(() => const []);
        final whs = whResult.getOrElse(() => const []);
        final rows = stock.map((s) {
          final item = items.where((i) => i.id == s.itemId).firstOrNull;
          final wh = whs.where((w) => w.id == s.warehouseId).firstOrNull;
          return StockRow(
            stock: s,
            itemName: item?.name ?? s.itemId,
            itemCode: item?.code ?? '',
            warehouseName: wh?.name ?? s.warehouseId,
            belowMin:
                item?.minStock != null && s.quantityOnHand < item!.minStock!,
          );
        }).toList()..sort((a, b) => a.itemName.compareTo(b.itemName));
        emit(state.copyWith(status: StockListStatus.success, rows: rows));
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
