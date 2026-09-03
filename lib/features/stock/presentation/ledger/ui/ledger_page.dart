import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/stock_ledger_entry.dart';
import '../../../domain/repositories/stock_repository.dart';

/// Thẻ kho — lịch sử nhập/xuất của một vật tư trong một kho.
class LedgerPage extends StatefulWidget {
  const LedgerPage({
    required this.warehouseId,
    required this.itemId,
    required this.title,
    super.key,
  });

  final String warehouseId;
  final String itemId;
  final String title;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late final Future<List<StockLedgerEntry>> _future = sl<StockRepository>()
      .getLedger(warehouseId: widget.warehouseId, itemId: widget.itemId)
      .then((r) => r.fold((f) => throw Exception(f.message), (rows) => rows));

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Thẻ kho')),
      body: FutureBuilder<List<StockLedgerEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const Center(child: Text('Chưa có phát sinh'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rows.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 0),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(widget.title, style: context.texts.titleMedium),
                );
              }
              final e = rows[i - 1];
              final sign = e.quantity >= 0 ? '+' : '';
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: e.quantity >= 0
                      ? context.colors.primaryContainer
                      : context.colors.errorContainer,
                  child: Text(
                    e.movementType.label.substring(0, 1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                title: Text(
                  '${e.movementType.label}  $sign${e.quantity}  '
                  '@ ${e.unitCost.asCurrencyVnd}',
                ),
                subtitle: Text(
                  '${df.format(e.movedAt)} · Tồn sau: ${e.balanceQtyAfter} '
                  '· BQ: ${e.avgCostAfter.asCurrencyVnd}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
