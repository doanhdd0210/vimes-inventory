import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../master_data/domain/entities/item.dart';
import '../bloc/receipt_form_bloc.dart';
import '../bloc/receipt_form_data.dart';
import '../bloc/receipt_form_options.dart';
import 'form_section.dart';
import 'receipt_field.dart';

/// "Vật tư, hàng hoá" — chọn vật tư → tên/mã/ĐVT/đơn giá tự điền.
class ReceiptItemsSection extends StatelessWidget {
  const ReceiptItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final items = state.data.items;

    return FormSection(
      title: 'Vật tư, hàng hoá',
      icon: Icons.inventory_2_outlined,
      trailing: FilledButton.tonalIcon(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: () => bloc.add(const ReceiptItemAdded()),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Thêm'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.errorFor('items') != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.errorFor('items')!,
                style: TextStyle(color: context.colors.error),
              ),
            ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Chưa có dòng nào — bấm "Thêm".',
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.colors.outline,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++)
              Padding(
                key: ValueKey(items[i].rowId),
                padding: EdgeInsets.only(
                  bottom: i == items.length - 1 ? 0 : 10,
                ),
                child: _ItemRow(
                  index: i,
                  item: items[i],
                  options: state.options,
                  onChanged: (row) => bloc.add(ReceiptItemChanged(row)),
                  onRemove: () => bloc.add(ReceiptItemRemoved(items[i].rowId)),
                  errorFor: (col) => state.itemErrorFor(i, col),
                ),
              ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
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
    final selected = options.items.firstWhereOrNull(
      (it) => it.id == item.itemId,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: context.colors.primaryContainer,
                child: Text(
                  '${index + 1}',
                  style: context.texts.labelSmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ItemPickerField(
                  selected: selected,
                  items: options.items,
                  errorText: errorFor('itemId'),
                  onPicked: (it) => onChanged(
                    item.fromItem(it, unitName: options.uomName(it.uomId)),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: context.colors.outline,
                ),
                tooltip: 'Xoá dòng',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NumField(
                  label: 'SL thực nhập *',
                  value: item.quantityActual,
                  errorText: errorFor('quantityActual'),
                  decimalRange: 3,
                  onChanged: (n) => onChanged(item.copyWith(quantityActual: n)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumField(
                  label: 'Đơn giá',
                  value: item.unitPrice,
                  errorText: errorFor('unitPrice'),
                  decimalRange: 2,
                  onChanged: (n) => onChanged(item.copyWith(unitPrice: n)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniNum(
                label: 'SL theo CT',
                value: item.quantityDoc,
                onChanged: (n) => onChanged(item.copyWith(quantityDoc: n)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Thành tiền',
                    style: context.texts.labelSmall?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                  Text(
                    item.amount.asCurrencyVnd,
                    style: context.texts.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemPickerField extends StatelessWidget {
  const _ItemPickerField({
    required this.selected,
    required this.items,
    required this.onPicked,
    this.errorText,
  });

  final Item? selected;
  final List<Item> items;
  final ValueChanged<Item> onPicked;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showModalBottomSheet<Item>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => _ItemSheet(items: items),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Vật tư (B/C) *',
          errorText: errorText,
          suffixIcon: const Icon(Icons.expand_more),
        ),
        child: Text(
          selected == null
              ? 'Chọn vật tư…'
              : '${selected!.code} — ${selected!.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: selected == null
              ? TextStyle(color: context.colors.outline)
              : null,
        ),
      ),
    );
  }
}

class _ItemSheet extends StatefulWidget {
  const _ItemSheet({required this.items});

  final List<Item> items;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((i) {
      final q = _q.trim().toLowerCase();
      return q.isEmpty ||
          i.name.toLowerCase().contains(q) ||
          i.code.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tên hoặc mã…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final it = filtered[i];
                  return ListTile(
                    title: Text(it.name),
                    subtitle: Text(
                      'Mã: ${it.code}'
                      '${it.defaultUnitPrice == null ? '' : ' · ĐG: ${it.defaultUnitPrice!.asCurrencyVnd}'}',
                    ),
                    onTap: () => Navigator.of(context).pop(it),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.decimalRange,
    this.errorText,
  });

  final String label;
  final num? value;
  final ValueChanged<num?> onChanged;
  final int decimalRange;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return ReceiptField(
      label: label,
      value: _numText(value),
      errorText: errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [DecimalTextInputFormatter(decimalRange: decimalRange)],
      onChanged: (v) => onChanged(parseNum(v)),
    );
  }
}

class _MiniNum extends StatelessWidget {
  const _MiniNum({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final num? value;
  final ValueChanged<num?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextFormField(
        initialValue: _numText(value),
        style: context.texts.bodySmall,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [DecimalTextInputFormatter()],
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
        ),
        onChanged: (v) => onChanged(parseNum(v)),
      ),
    );
  }
}

String _numText(num? value) {
  if (value == null) return '';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return '$value';
}
