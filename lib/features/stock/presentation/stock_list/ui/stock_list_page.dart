import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/domain/crud_repository.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../master_data/domain/entities/item.dart';
import '../../../../master_data/domain/entities/organization.dart';
import '../../../../master_data/domain/entities/warehouse.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../ledger/ui/ledger_page.dart';
import '../bloc/stock_list_cubit.dart';

/// Tồn kho hiện tại — một dòng cho mỗi (kho, vật tư). Tap để mở thẻ kho.
class StockListPage extends StatelessWidget {
  const StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockListCubit(
        stockRepository: sl<StockRepository>(),
        organizations: sl<CrudRepository<Organization>>(),
        items: sl<CrudRepository<Item>>(),
        warehouses: sl<CrudRepository<Warehouse>>(),
      )..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tồn kho')),
        body: BlocBuilder<StockListCubit, StockListState>(
          builder: (context, state) {
            return switch (state.status) {
              StockListStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              StockListStatus.failure => Center(
                child: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
              ),
              StockListStatus.success when state.rows.isEmpty => const Center(
                child: Text('Chưa có tồn kho. Hãy lập một phiếu nhập.'),
              ),
              StockListStatus.success => RefreshIndicator(
                onRefresh: () => context.read<StockListCubit>().load(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final row = state.rows[i];
                    return ListTile(
                      title: Text('${row.itemCode} — ${row.itemName}'),
                      subtitle: Text(
                        '${row.warehouseName} · SL: ${row.stock.quantityOnHand} '
                        '· ĐG bình quân: ${row.stock.avgCost.asCurrencyVnd}',
                      ),
                      trailing: row.belowMin
                          ? Icon(
                              Icons.warning_amber,
                              color: context.colors.error,
                            )
                          : Text(
                              row.stock.stockValue.asCurrencyVnd,
                              style: context.texts.labelLarge,
                            ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LedgerPage(
                            warehouseId: row.stock.warehouseId,
                            itemId: row.stock.itemId,
                            title: '${row.itemCode} — ${row.itemName}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}
