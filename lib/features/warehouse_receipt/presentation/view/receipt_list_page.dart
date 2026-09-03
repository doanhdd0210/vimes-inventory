import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/app_route.dart';
import '../../domain/usecases/get_warehouse_receipts.dart';
import '../viewmodel/receipt_list_bloc.dart';

class ReceiptListPage extends StatelessWidget {
  const ReceiptListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReceiptListBloc(getWarehouseReceipts: sl<GetWarehouseReceipts>())
            ..add(const ReceiptListRequested()),
      child: const _ReceiptListView(),
    );
  }
}

class _ReceiptListView extends StatelessWidget {
  const _ReceiptListView();

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Phiếu nhập kho')),
      body: BlocBuilder<ReceiptListBloc, ReceiptListState>(
        builder: (context, state) {
          return switch (state.status) {
            ReceiptListStatus.initial || ReceiptListStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ReceiptListStatus.failure when state.receipts.isEmpty => Center(
              child: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
            ),
            _ when state.receipts.isEmpty => const _EmptyState(),
            _ => RefreshIndicator(
              onRefresh: () async => context.read<ReceiptListBloc>().add(
                const ReceiptListRequested(),
              ),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.receipts.length,
                separatorBuilder: (_, _) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final r = state.receipts[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('Phiếu ${r.receiptNumber}'),
                    subtitle: Text(
                      '${df.format(r.receiptDate)} · ${r.warehouseName} · '
                      '${r.items.length} dòng',
                    ),
                    trailing: Text(
                      r.totalAmount.asCurrencyVnd,
                      style: context.texts.labelLarge,
                    ),
                    onTap: () => context.pushNamed(
                      AppRoute.receiptDetail.name,
                      pathParameters: {'id': r.id},
                    ),
                  );
                },
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await context.pushNamed<String>(
            AppRoute.receiptForm.name,
          );
          if (saved != null && context.mounted) {
            context.read<ReceiptListBloc>().add(const ReceiptListRequested());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Lập phiếu'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.inbox_outlined, size: 64, color: context.colors.outline),
        const SizedBox(height: 12),
        const Center(child: Text('Chưa có phiếu nào. Bấm “Lập phiếu”.')),
      ],
    );
  }
}
