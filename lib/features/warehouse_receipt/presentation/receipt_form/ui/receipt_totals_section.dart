import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/helpers/vnd_words.dart';
import '../../../../master_data/domain/entities/app_user.dart';
import '../bloc/receipt_form_bloc.dart';
import '../bloc/receipt_form_data.dart';
import 'form_section.dart';
import 'receipt_field.dart';
import 'signature_pad.dart';

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
            'Người ký (Ký, họ tên) — bắt buộc đủ 4 chữ ký',
            style: context.texts.labelLarge?.copyWith(
              color: context.colors.outline,
            ),
          ),
          const SizedBox(height: 8),

          // 1) Người lập phiếu — mặc định là người đăng nhập, vẫn cho chọn lại.
          _SignerTile(
            role: SignatureRole.preparer,
            signature: data.preparerSignature,
            errorText: state.errorFor(SignatureRole.preparer.errorKey),
            onSign: (png) =>
                bloc.add(ReceiptSignatureChanged(SignatureRole.preparer, png)),
            identity: _SignPicker(
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
          const Divider(height: 24),

          // 2) Người giao hàng — đồng bộ với ô ở bước "Thông tin", chọn được ở cả hai.
          _SignerTile(
            role: SignatureRole.deliverer,
            signature: data.delivererSignature,
            errorText: state.errorFor(SignatureRole.deliverer.errorKey),
            onSign: (png) =>
                bloc.add(ReceiptSignatureChanged(SignatureRole.deliverer, png)),
            identity: _SignPicker(
              label: 'Người giao hàng',
              value: byId(data.delivererUserId),
              users: users,
              onChanged: (u) => bloc.add(
                ReceiptHeaderChanged(
                  delivererUserId: u?.id ?? '',
                  delivererName: u?.fullName ?? '',
                ),
              ),
            ),
          ),
          const Divider(height: 24),

          // 3) Thủ kho.
          _SignerTile(
            role: SignatureRole.storekeeper,
            signature: data.storekeeperSignature,
            errorText: state.errorFor(SignatureRole.storekeeper.errorKey),
            onSign: (png) => bloc.add(
              ReceiptSignatureChanged(SignatureRole.storekeeper, png),
            ),
            identity: _SignPicker(
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
          const Divider(height: 24),

          // 4) Kế toán trưởng (hoặc bộ phận có nhu cầu nhập).
          _SignerTile(
            role: SignatureRole.chiefAccountant,
            signature: data.chiefAccountantSignature,
            errorText: state.errorFor(SignatureRole.chiefAccountant.errorKey),
            onSign: (png) => bloc.add(
              ReceiptSignatureChanged(SignatureRole.chiefAccountant, png),
            ),
            identity: _SignPicker(
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

/// One signer: identity (read-only chip or dropdown) + a draw-to-sign control.
class _SignerTile extends StatelessWidget {
  const _SignerTile({
    required this.role,
    required this.identity,
    required this.signature,
    required this.onSign,
    this.errorText,
  });

  final SignatureRole role;
  final Widget identity;

  /// Base64 PNG, or null when not signed.
  final String? signature;
  final ValueChanged<String?> onSign;
  final String? errorText;

  Future<void> _sign(BuildContext context) async {
    final png = await openSignaturePad(context, title: role.label);
    if (png != null) onSign(png);
  }

  @override
  Widget build(BuildContext context) {
    final signed = (signature ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        identity,
        const SizedBox(height: 8),
        if (!signed)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _sign(context),
              icon: const Icon(Icons.draw_outlined, size: 18),
              label: const Text('Ký'),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.outlineVariant),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Image.memory(
                    base64Decode(signature!),
                    height: 56,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () => _sign(context),
                child: const Text('Ký lại'),
              ),
              IconButton(
                tooltip: 'Xoá chữ ký',
                visualDensity: VisualDensity.compact,
                onPressed: () => onSign(null),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: context.colors.outline,
                ),
              ),
            ],
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: context.texts.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
      ],
    );
  }
}
