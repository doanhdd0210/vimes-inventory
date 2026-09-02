import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Trivial secondary route to demonstrate nested navigation with go_router.
class SampleDetailPage extends StatelessWidget {
  const SampleDetailPage({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final title = GoRouterState.of(context).extra as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('id: $itemId'),
            if (title != null) Text('title: $title'),
          ],
        ),
      ),
    );
  }
}
