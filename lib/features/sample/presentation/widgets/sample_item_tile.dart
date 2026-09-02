import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sample_item.dart';

/// Dumb widget: renders one [SampleItem], reports taps upward. No logic.
class SampleItemTile extends StatelessWidget {
  const SampleItemTile({required this.item, this.onTap, super.key});

  final SampleItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.inventory_2_outlined),
      title: Text(item.title),
      subtitle: Text(DateFormat.yMMMd().add_Hm().format(item.createdAt)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
