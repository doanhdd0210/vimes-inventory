import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../master_data/domain/entities/app_user.dart';
import '../../../master_data/domain/entities/department.dart';
import '../../../master_data/domain/entities/organization.dart';
import '../../../master_data/domain/entities/warehouse.dart';
import '../viewmodel/receipt_form_bloc.dart';
import 'receipt_field.dart';

/// Header block of Mẫu 01‑VT: đơn vị / bộ phận, số, ngày, Nợ/Có, người giao,
/// chứng từ tham chiếu, kho nhập. Master fields are dropdowns.
class ReceiptHeaderSection extends StatelessWidget {
  const ReceiptHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReceiptFormBloc>();
    final state = context.watch<ReceiptFormBloc>().state;
    final data = state.data;
    final options = state.options;
    final df = DateFormat('dd/MM/yyyy');

    void patch(ReceiptHeaderChanged e) => bloc.add(e);

    final currentOrg = options.organizations.firstWhereOrNull(
      (o) => o.id == data.organizationId,
    );
    final currentDept = options.departments.firstWhereOrNull(
      (d) => d.id == data.departmentId,
    );
    final currentWh = options.warehouses.firstWhereOrNull(
      (w) => w.id == data.warehouseId,
    );
    final deliverer = options.users.firstWhereOrNull(
      (u) => u.id == data.delivererUserId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ReceiptDropdown<Organization>(
                label: 'Đơn vị *',
                value: currentOrg,
                items: options.organizations,
                labelOf: (o) => o.name,
                errorText: state.errorFor('organizationId'),
                onChanged: (o) => patch(
                  ReceiptHeaderChanged(
                    organizationId: o?.id ?? '',
                    organizationName: o?.name ?? '',
                    departmentId: '',
                    departmentName: '',
                    warehouseId: '',
                    warehouseName: '',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReceiptDropdown<Department>(
                label: 'Bộ phận',
                value: currentDept,
                items: options.departmentsOf(data.organizationId),
                labelOf: (d) => d.name,
                onChanged: (d) => patch(
                  ReceiptHeaderChanged(
                    departmentId: d?.id ?? '',
                    departmentName: d?.name ?? '',
                  ),
                ),
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
        ReceiptDropdown<Warehouse>(
          label: 'Nhập tại kho *',
          value: currentWh,
          items: options.warehousesOf(data.organizationId),
          labelOf: (w) =>
              '${w.name}${w.location == null ? '' : ' — ${w.location}'}',
          errorText: state.errorFor('warehouseId'),
          onChanged: (w) => patch(
            ReceiptHeaderChanged(
              warehouseId: w?.id ?? '',
              warehouseName: w?.name ?? '',
              warehouseLocation: w?.location ?? '',
            ),
          ),
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

/// Digits-only formatter re-exported for the totals section.
final digitsOnly = FilteringTextInputFormatter.digitsOnly;
