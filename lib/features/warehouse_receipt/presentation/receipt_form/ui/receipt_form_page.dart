import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/extensions/extensions.dart';
import '../bloc/receipt_form_bloc.dart';
import 'receipt_header_section.dart';
import 'receipt_items_section.dart';
import 'receipt_totals_section.dart';

/// 3-step wizard for a Phiếu nhập kho. Pops the saved id on success.
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

const _stepTitles = ['Thông tin', 'Vật tư', 'Hoàn tất'];

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
        final bloc = context.read<ReceiptFormBloc>();
        final isLast = state.step == ReceiptFormState.lastStep;

        return Scaffold(
          backgroundColor: context.colors.surfaceContainerLowest,
          appBar: AppBar(
            title: const Text('Lập phiếu nhập kho'),
            bottom: state.isLoading
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(52),
                    child: _StepBar(current: state.step),
                  ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : AbsorbPointer(
                  absorbing: state.isSubmitting,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    children: [
                      switch (state.step) {
                        0 => const ReceiptInfoSection(),
                        1 => const ReceiptItemsSection(),
                        _ => const ReceiptTotalsSection(),
                      },
                    ],
                  ),
                ),
          bottomNavigationBar: state.isLoading
              ? null
              : _NavBar(
                  step: state.step,
                  isLast: isLast,
                  total: state.data.totalAmount,
                  lineCount: state.data.items.length,
                  submitting: state.isSubmitting,
                  onBack: state.step == 0
                      ? null
                      : () => bloc.add(ReceiptStepRequested(state.step - 1)),
                  onNext: isLast
                      ? () => bloc.add(const ReceiptSubmitted())
                      : () => bloc.add(ReceiptStepRequested(state.step + 1)),
                ),
        );
      },
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Row(
        children: [
          for (var i = 0; i < _stepTitles.length; i++) ...[
            _Dot(index: i, current: current),
            const SizedBox(width: 6),
            Text(
              _stepTitles[i],
              style: context.texts.labelMedium?.copyWith(
                color: i == current
                    ? context.colors.primary
                    : context.colors.outline,
                fontWeight: i == current ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (i < _stepTitles.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: i < current
                      ? context.colors.primary
                      : context.colors.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || active
            ? context.colors.primary
            : context.colors.surfaceContainerHighest,
      ),
      child: done
          ? Icon(Icons.check, size: 14, color: context.colors.onPrimary)
          : Text(
              '${index + 1}',
              style: context.texts.labelSmall?.copyWith(
                color: active
                    ? context.colors.onPrimary
                    : context.colors.outline,
              ),
            ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.step,
    required this.isLast,
    required this.total,
    required this.lineCount,
    required this.submitting,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final bool isLast;
  final num total;
  final int lineCount;
  final bool submitting;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: context.colors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          10,
          12,
          10 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Row(
          children: [
            if (onBack != null) ...[
              OutlinedButton(
                onPressed: submitting ? null : onBack,
                child: const Text('Quay lại'),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: isLast
                  ? Column(
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
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: submitting ? null : onNext,
              icon: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isLast ? Icons.save : Icons.arrow_forward),
              label: Text(
                submitting
                    ? 'Đang lưu…'
                    : isLast
                    ? 'Lưu phiếu'
                    : 'Tiếp',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
