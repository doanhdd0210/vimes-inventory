import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../../../core/extensions/extensions.dart';

/// Opens a draw-to-sign bottom sheet. Returns the signature as a base64-encoded
/// PNG (transparent background), or null if the user cancelled / drew nothing.
Future<String?> openSignaturePad(
  BuildContext context, {
  required String title,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SignaturePadSheet(title: title),
  );
}

class _SignaturePadSheet extends StatefulWidget {
  const _SignaturePadSheet({required this.title});

  final String title;

  @override
  State<_SignaturePadSheet> createState() => _SignaturePadSheetState();
}

class _SignaturePadSheetState extends State<_SignaturePadSheet> {
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: const Color(0x00FFFFFF),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có nét ký nào')));
      return;
    }
    final bytes = await _controller.toPngBytes();
    if (!mounted) return;
    Navigator.of(context).pop(bytes == null ? null : base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ký: ${widget.title}', style: context.texts.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Ký bằng ngón tay trong khung dưới đây.',
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.outline,
            ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Signature(
                controller: _controller,
                height: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _controller.clear,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Xoá'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Huỷ'),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _done, child: const Text('Xong')),
            ],
          ),
        ],
      ),
    );
  }
}
