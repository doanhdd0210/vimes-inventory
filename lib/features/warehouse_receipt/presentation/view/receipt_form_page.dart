import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
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
        if (state.status == ReceiptFormStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Đã lưu phiếu nhập kho')),
            );
          Navigator.of(context).pop(state.savedId);
        } else if (state.submitError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.submitError!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Phiếu nhập kho')),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : AbsorbPointer(
                  absorbing: state.isSubmitting,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: const [
                      ReceiptHeaderSection(),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 8),
                      ReceiptItemsSection(),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 8),
                      ReceiptTotalsSection(),
                    ],
                  ),
                ),
          bottomNavigationBar: state.isLoading
              ? null
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    8 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: FilledButton.icon(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.read<ReceiptFormBloc>().add(
                            const ReceiptSubmitted(),
                          ),
                    icon: state.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(state.isSubmitting ? 'Đang lưu…' : 'Lưu phiếu'),
                  ),
                ),
        );
      },
    );
  }
}
