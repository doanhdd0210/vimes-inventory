import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../viewmodel/receipt_form_bloc.dart';
import 'receipt_field.dart';

/// The header block of Mẫu 01‑VT: đơn vị / bộ phận, số, ngày, Nợ/Có, người giao,
/// chứng từ tham chiếu, kho nhập.
class ReceiptHeaderSection extends StatelessWidget {
  const ReceiptHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final data = state.data;
    final df = DateFormat('dd/MM/yyyy');

    void patch(ReceiptHeaderChanged event) => bloc.add(event);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ReceiptField(
                label: 'Đơn vị',
                value: data.unitName,
                onChanged: (v) => patch(ReceiptHeaderChanged(unitName: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReceiptField(
                label: 'Bộ phận',
                value: data.department,
                onChanged: (v) => patch(ReceiptHeaderChanged(department: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReceiptField(
                label: 'Số phiếu *',
                value: data.receiptNumber,
                errorText: state.errorFor('receiptNumber'),
                onChanged: (v) => patch(ReceiptHeaderChanged(receiptNumber: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                label: 'Ngày lập phiếu',
                value: data.receiptDate,
                format: df,
                onPick: (d) => patch(ReceiptHeaderChanged(receiptDate: d)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReceiptField(
                label: 'Nợ (TK)',
                value: data.debitAccount,
                onChanged: (v) => patch(ReceiptHeaderChanged(debitAccount: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReceiptField(
                label: 'Có (TK)',
                value: data.creditAccount,
                onChanged: (v) => patch(ReceiptHeaderChanged(creditAccount: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReceiptField(
          label: 'Họ và tên người giao *',
          value: data.delivererName,
          errorText: state.errorFor('delivererName'),
          onChanged: (v) => patch(ReceiptHeaderChanged(delivererName: v)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReceiptField(
                label: 'Theo chứng từ số',
                value: data.referenceDocNumber,
                onChanged: (v) =>
                    patch(ReceiptHeaderChanged(referenceDocNumber: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                label: 'Ngày chứng từ',
                value: data.referenceDocDate,
                format: df,
                onPick: (d) => patch(ReceiptHeaderChanged(referenceDocDate: d)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReceiptField(
          label: 'Của (đơn vị/người)',
          value: data.referenceDocIssuer,
          onChanged: (v) => patch(ReceiptHeaderChanged(referenceDocIssuer: v)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ReceiptField(
                label: 'Nhập tại kho *',
                value: data.warehouseName,
                errorText: state.errorFor('warehouseName'),
                onChanged: (v) => patch(ReceiptHeaderChanged(warehouseName: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ReceiptField(
                label: 'Địa điểm',
                value: data.warehouseLocation,
                onChanged: (v) =>
                    patch(ReceiptHeaderChanged(warehouseLocation: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.format,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final DateFormat format;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value == null ? '—' : format.format(value!)),
      ),
    );
  }
}

/// Digits-only formatter for the "số chứng từ gốc kèm theo" field.
final digitsOnly = FilteringTextInputFormatter.digitsOnly;
