import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route.dart';
import '../viewmodel/sample_bloc.dart';
import '../widgets/sample_item_tile.dart';

/// The View. Observes [SampleBloc] state and forwards user intent as events.
/// It contains no business logic and never touches a repository or use case.
class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample feature')),
      body: BlocConsumer<SampleBloc, SampleState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) {
          return switch (state.status) {
            SampleStatus.initial || SampleStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            SampleStatus.failure when state.items.isEmpty => _ErrorView(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () =>
                  context.read<SampleBloc>().add(const SampleItemsRequested()),
            ),
            SampleStatus.success || SampleStatus.failure => RefreshIndicator(
              onRefresh: () async =>
                  context.read<SampleBloc>().add(const SampleItemsRequested()),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return SampleItemTile(
                    item: item,
                    onTap: () => context.goNamed(
                      AppRoute.sampleDetail.name,
                      pathParameters: {'id': item.id},
                      extra: item.title,
                    ),
                  );
                },
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final bloc = context.read<SampleBloc>();
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title != null && title.trim().isNotEmpty) {
      bloc.add(SampleItemAdded(title));
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
