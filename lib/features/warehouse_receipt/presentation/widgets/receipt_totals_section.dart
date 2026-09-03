import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/vnd_words.dart';
import '../../../master_data/domain/entities/app_user.dart';
import '../viewmodel/receipt_form_bloc.dart';
import 'form_section.dart';
import 'receipt_field.dart';

/// "Tổng hợp & chữ ký" — cộng, tiền bằng chữ, số chứng từ gốc, người ký.
class ReceiptTotalsSection extends StatelessWidget {
  const ReceiptTotalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final data = state.data;
    final users = state.options.users;
    final total = data.totalAmount;

    AppUser? byId(String? id) => users.firstWhereOrNull((u) => u.id == id);

    return FormSection(
      title: 'Tổng hợp & chữ ký',
      icon: Icons.summarize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primaryContainer,
                  context.colors.primaryContainer.withValues(alpha: 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cộng', style: context.texts.titleMedium),
                    Text(
                      total.asCurrencyVnd,
                      style: context.texts.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  VndWords.of(total),
                  style: context.texts.bodySmall?.copyWith(
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
          Text(
            'Người ký',
            style: context.texts.labelLarge?.copyWith(
              color: context.colors.outline,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SignPicker(
                  label: 'Người lập phiếu',
                  value: byId(data.preparerUserId),
                  users: users,
                  onChanged: (u) => bloc.add(
                    ReceiptHeaderChanged(
                      preparerUserId: u?.id ?? '',
                      preparerName: u?.fullName ?? '',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SignPicker(
                  label: 'Thủ kho',
                  value: byId(data.storekeeperUserId),
                  users: users,
                  onChanged: (u) => bloc.add(
                    ReceiptHeaderChanged(
                      storekeeperUserId: u?.id ?? '',
                      storekeeperName: u?.fullName ?? '',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SignPicker(
            label: 'Kế toán trưởng',
            value: byId(data.chiefAccountantUserId),
            users: users,
            onChanged: (u) => bloc.add(
              ReceiptHeaderChanged(
                chiefAccountantUserId: u?.id ?? '',
                chiefAccountantName: u?.fullName ?? '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignPicker extends StatelessWidget {
  const _SignPicker({
    required this.label,
    required this.value,
    required this.users,
    required this.onChanged,
  });

  final String label;
  final AppUser? value;
  final List<AppUser> users;
  final ValueChanged<AppUser?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ReceiptDropdown<AppUser>(
      label: label,
      value: value,
      items: users,
      labelOf: (u) => u.fullName,
      onChanged: onChanged,
    );
  }
}
