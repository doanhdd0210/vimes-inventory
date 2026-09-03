import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/vnd_words.dart';
import '../../domain/entities/warehouse_receipt.dart';
import '../../domain/repositories/warehouse_receipt_repository.dart';

/// Read-only rendering of a saved phiếu.
class ReceiptDetailPage extends StatefulWidget {
  const ReceiptDetailPage({required this.receiptId, super.key});

  final String receiptId;

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  late final Future<WarehouseReceipt> _future = sl<WarehouseReceiptRepository>()
      .getReceiptById(widget.receiptId)
      .then((r) => r.fold((f) => throw Exception(f.message), (r) => r));

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết phiếu')),
      body: FutureBuilder<WarehouseReceipt>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final r = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _kv('Số phiếu', r.receiptNumber),
              _kv('Ngày', df.format(r.receiptDate)),
              if (r.unitName != null) _kv('Đơn vị', r.unitName!),
              if (r.department != null) _kv('Bộ phận', r.department!),
              _kv('Người giao', r.delivererName),
              _kv('Nhập tại kho', r.warehouseName),
              if (r.warehouseLocation != null)
                _kv('Địa điểm', r.warehouseLocation!),
              if (r.debitAccount != null) _kv('Nợ', r.debitAccount!),
              if (r.creditAccount != null) _kv('Có', r.creditAccount!),
              const Divider(height: 24),
              Text('Vật tư', style: context.texts.titleMedium),
              const SizedBox(height: 8),
              for (final item in r.items)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${item.lineNo}')),
                    title: Text(item.name),
                    subtitle: Text(
                      'ĐVT: ${item.unit} · '
                      'Thực nhập: ${item.quantityActual} · '
                      'Đơn giá: ${item.unitPrice.asCurrencyVnd}',
                    ),
                    trailing: Text(
                      item.amount.asCurrencyVnd,
                      style: context.texts.labelLarge,
                    ),
                  ),
                ),
              const Divider(height: 24),
              _kv('Cộng', r.totalAmount.asCurrencyVnd),
              _kv('Bằng chữ', VndWords.of(r.totalAmount)),
              _kv('Chứng từ gốc kèm theo', '${r.attachedDocumentCount}'),
            ],
          );
        },
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(k, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Text(v)),
      ],
    ),
  );
}
