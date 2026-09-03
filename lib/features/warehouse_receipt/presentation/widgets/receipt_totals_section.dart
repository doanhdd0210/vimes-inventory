import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/vnd_words.dart';
import '../viewmodel/receipt_form_bloc.dart';
import 'receipt_field.dart';

/// Cộng, tổng tiền bằng chữ, số chứng từ gốc kèm theo, chữ ký.
class ReceiptTotalsSection extends StatelessWidget {
  const ReceiptTotalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final data = state.data;
    final total = data.totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cộng', style: context.texts.titleMedium),
                  Text(total.asCurrencyVnd, style: context.texts.titleLarge),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Bằng chữ: ${VndWords.of(total)}',
                style: context.texts.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ReceiptField(
          label: 'Số chứng từ gốc kèm theo',
          value: data.attachedDocumentCount.toString(),
          errorText: state.errorFor('attachedDocumentCount'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => bloc.add(
            ReceiptHeaderChanged(attachedDocumentCount: int.tryParse(v) ?? 0),
          ),
        ),
        const SizedBox(height: 16),
        Text('Chữ ký', style: context.texts.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ReceiptField(
                label: 'Người lập phiếu',
                value: data.preparerName,
                onChanged: (v) =>
                    bloc.add(ReceiptHeaderChanged(preparerName: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReceiptField(
                label: 'Thủ kho',
                value: data.storekeeperName,
                onChanged: (v) =>
                    bloc.add(ReceiptHeaderChanged(storekeeperName: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReceiptField(
          label: 'Kế toán trưởng',
          value: data.chiefAccountantName,
          textInputAction: TextInputAction.done,
          onChanged: (v) =>
              bloc.add(ReceiptHeaderChanged(chiefAccountantName: v)),
        ),
      ],
    );
  }
}
