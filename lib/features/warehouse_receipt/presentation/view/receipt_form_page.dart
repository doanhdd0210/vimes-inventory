import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/extensions.dart';
import '../viewmodel/receipt_form_bloc.dart';
import '../widgets/receipt_header_section.dart';
import '../widgets/receipt_items_section.dart';
import '../widgets/receipt_totals_section.dart';

/// Data-entry screen for a Phiếu nhập kho. Pops the saved id on success.
class ReceiptFormPage extends StatelessWidget {
  const ReceiptFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReceiptFormBloc>()..add(const ReceiptFormStarted()),
      child: const _ReceiptFormView(),
    );
  }
}

class _ReceiptFormView extends StatelessWidget {
  const _ReceiptFormView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReceiptFormBloc, ReceiptFormState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          (curr.status == ReceiptFormStatus.success ||
              curr.submitError != null),
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == ReceiptFormStatus.success) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Đã lưu phiếu nhập kho')),
            );
          Navigator.of(context).pop(state.savedId);
        } else if (state.submitError != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.submitError!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.surfaceContainerLowest,
          appBar: AppBar(title: const Text('Lập phiếu nhập kho')),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : AbsorbPointer(
                  absorbing: state.isSubmitting,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    children: const [
                      ReceiptInfoSection(),
                      SizedBox(height: 12),
                      ReceiptItemsSection(),
                      SizedBox(height: 12),
                      ReceiptTotalsSection(),
                    ],
                  ),
                ),
          bottomNavigationBar: state.isLoading
              ? null
              : _SaveBar(
                  total: state.data.totalAmount,
                  lineCount: state.data.items.length,
                  submitting: state.isSubmitting,
                  onSave: () => context.read<ReceiptFormBloc>().add(
                    const ReceiptSubmitted(),
                  ),
                ),
        );
      },
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.total,
    required this.lineCount,
    required this.submitting,
    required this.onSave,
  });

  final num total;
  final int lineCount;
  final bool submitting;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: context.colors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          10 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$lineCount dòng · Cộng',
                    style: context.texts.labelSmall?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                  Text(
                    total.asCurrencyVnd,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: submitting ? null : onSave,
              icon: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(submitting ? 'Đang lưu…' : 'Lưu phiếu'),
            ),
          ],
        ),
      ),
    );
  }
}
