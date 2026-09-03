import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../master_data/domain/entities/item.dart';
import '../viewmodel/receipt_form_bloc.dart';
import '../viewmodel/receipt_form_data.dart';
import '../viewmodel/receipt_form_options.dart';
import 'receipt_field.dart';

/// The line-items block (columns A–D and 1–4). Pick a vật tư → tên/mã/ĐVT/đơn
/// giá tự điền.
class ReceiptItemsSection extends StatelessWidget {
  const ReceiptItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final items = state.data.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Vật tư, hàng hoá', style: context.texts.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () => bloc.add(const ReceiptItemAdded()),
              icon: const Icon(Icons.add),
              label: const Text('Thêm dòng'),
            ),
          ],
        ),
        if (state.errorFor('items') != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              state.errorFor('items')!,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Chưa có dòng nào. Bấm “Thêm dòng”.')),
          )
        else
          for (var i = 0; i < items.length; i++)
            Padding(
              key: ValueKey(items[i].rowId),
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReceiptItemCard(
                index: i,
                item: items[i],
                options: state.options,
                onChanged: (row) => bloc.add(ReceiptItemChanged(row)),
                onRemove: () => bloc.add(ReceiptItemRemoved(items[i].rowId)),
                errorFor: (col) => state.itemErrorFor(i, col),
              ),
            ),
      ],
    );
  }
}

class _ReceiptItemCard extends StatelessWidget {
  const _ReceiptItemCard({
    required this.index,
    required this.item,
    required this.options,
    required this.onChanged,
    required this.onRemove,
    required this.errorFor,
  });

  final int index;
  final ReceiptItemFormData item;
  final ReceiptFormOptions options;
  final ValueChanged<ReceiptItemFormData> onChanged;
  final VoidCallback onRemove;
  final String? Function(String column) errorFor;

  @override
  Widget build(BuildContext context) {
    final selectedItem = options.items.firstWhereOrNull(
      (it) => it.id == item.itemId,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, child: Text('${index + 1}')),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dòng ${index + 1}',
                    style: context.texts.labelLarge,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Xoá dòng',
                ),
              ],
            ),
            const SizedBox(height: 4),
            ReceiptDropdown<Item>(
              label: 'Vật tư (B/C) *',
              value: selectedItem,
              items: options.items,
              labelOf: (it) => '${it.code} — ${it.name}',
              errorText: errorFor('itemId'),
              onChanged: (it) {
                if (it == null) return;
                onChanged(
                  item.fromItem(it, unitName: options.uomName(it.uomId)),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'ĐVT (D)'),
                    child: Text(item.unit.isEmpty ? '—' : item.unit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ReceiptField(
                    label: 'SL chứng từ (1)',
                    value: _numText(item.quantityDoc),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [DecimalTextInputFormatter()],
                    onChanged: (v) =>
                        onChanged(item.copyWith(quantityDoc: parseNum(v))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ReceiptField(
                    label: 'SL thực nhập (2) *',
                    value: _numText(item.quantityActual),
                    errorText: errorFor('quantityActual'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [DecimalTextInputFormatter()],
                    onChanged: (v) =>
                        onChanged(item.copyWith(quantityActual: parseNum(v))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ReceiptField(
                    label: 'Đơn giá (3)',
                    value: _numText(item.unitPrice),
                    errorText: errorFor('unitPrice'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 2),
                    ],
                    onChanged: (v) =>
                        onChanged(item.copyWith(unitPrice: parseNum(v))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Thành tiền (4)'),
              child: Text(
                item.amount.asCurrencyVnd,
                style: context.texts.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _numText(num? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return '$value';
  }
}
