import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../master_data/domain/entities/app_user.dart';
import '../../../master_data/domain/entities/warehouse.dart';
import '../bloc/receipt_form_bloc.dart';
import 'form_section.dart';
import 'receipt_field.dart';

/// "Thông tin phiếu" — số / ngày, đơn vị·bộ phận (từ user đăng nhập, chỉ đọc),
/// kho nhập, người giao, và phần định khoản / chứng từ gốc thu gọn.
class ReceiptInfoSection extends StatelessWidget {
  const ReceiptInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final data = state.data;
    final options = state.options;
    final df = DateFormat('dd/MM/yyyy');

    void patch(ReceiptHeaderChanged e) => bloc.add(e);

    final currentWh = options.warehouses.firstWhereOrNull(
      (w) => w.id == data.warehouseId,
    );
    final deliverer = options.users.firstWhereOrNull(
      (u) => u.id == data.delivererUserId,
    );

    return FormSection(
      title: 'Thông tin phiếu',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ReadonlyField(
                  label: 'Đơn vị',
                  value: data.organizationName,
                  icon: Icons.business,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ReadonlyField(
                  label: 'Bộ phận',
                  value: data.departmentName ?? '',
                  icon: Icons.account_tree_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ReceiptField(
                  label: 'Số phiếu *',
                  value: data.receiptNumber,
                  hintText: 'VD: PN-2026-001',
                  errorText: state.errorFor('receiptNumber'),
                  onChanged: (v) =>
                      patch(ReceiptHeaderChanged(receiptNumber: v)),
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
          ReceiptDropdown<Warehouse>(
            label: 'Nhập tại kho *',
            value: currentWh,
            items: options.warehousesOf(data.organizationId),
            labelOf: (w) => w.name,
            errorText: state.errorFor('warehouseId'),
            onChanged: (w) => patch(
              ReceiptHeaderChanged(
                warehouseId: w?.id ?? '',
                warehouseName: w?.name ?? '',
                warehouseLocation: w?.location ?? '',
              ),
            ),
          ),
          if ((data.warehouseLocation ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Địa điểm: ${data.warehouseLocation}',
                style: context.texts.bodySmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),
          const SizedBox(height: 12),
          ReceiptDropdown<AppUser>(
            label: 'Họ và tên người giao *',
            value: deliverer,
            items: options.users,
            labelOf: (u) =>
                '${u.fullName}${u.position == null ? '' : ' · ${u.position}'}',
            errorText: state.errorFor('delivererUserId'),
            onChanged: (u) => patch(
              ReceiptHeaderChanged(
                delivererUserId: u?.id ?? '',
                delivererName: u?.fullName ?? '',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 4, bottom: 4),
              title: Text(
                'Định khoản & chứng từ gốc',
                style: context.texts.bodyMedium,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ReceiptField(
                        label: 'Nợ (TK)',
                        value: data.debitAccount,
                        hintText: '152',
                        onChanged: (v) =>
                            patch(ReceiptHeaderChanged(debitAccount: v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReceiptField(
                        label: 'Có (TK)',
                        value: data.creditAccount,
                        hintText: '331',
                        onChanged: (v) =>
                            patch(ReceiptHeaderChanged(creditAccount: v)),
                      ),
                    ),
                  ],
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
                        onPick: (d) =>
                            patch(ReceiptHeaderChanged(referenceDocDate: d)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ReceiptField(
                  label: 'Của (đơn vị / người)',
                  value: data.referenceDocIssuer,
                  onChanged: (v) =>
                      patch(ReceiptHeaderChanged(referenceDocIssuer: v)),
                ),
              ],
            ),
          ),
        ],
      ),
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
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(value == null ? '—' : format.format(value!)),
      ),
    );
  }
}

/// Digits-only formatter re-exported for the totals section.
final digitsOnly = FilteringTextInputFormatter.digitsOnly;
