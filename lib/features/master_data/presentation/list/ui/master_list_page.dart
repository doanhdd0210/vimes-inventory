import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/domain/crud_repository.dart';
import '../../../../../core/domain/entity.dart';
import '../../../../../core/extensions/extensions.dart';
import '../bloc/master_list_cubit.dart';

/// Generic read-only catalog list. `titleOf` / `subtitleOf` render one row.
class MasterListPage<E extends Entity> extends StatelessWidget {
  const MasterListPage({
    required this.title,
    required this.titleOf,
    this.subtitleOf,
    super.key,
  });

  final String title;
  final String Function(E entity) titleOf;
  final String Function(E entity)? subtitleOf;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MasterListCubit<E>(sl<CrudRepository<E>>())..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: BlocBuilder<MasterListCubit<E>, MasterListState<E>>(
          builder: (context, state) {
            return switch (state.status) {
              MasterListStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              MasterListStatus.failure => Center(
                child: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
              ),
              MasterListStatus.success when state.items.isEmpty => const Center(
                child: Text('Chưa có dữ liệu'),
              ),
              MasterListStatus.success => RefreshIndicator(
                onRefresh: () => context.read<MasterListCubit<E>>().load(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final e = state.items[i];
                    return ListTile(
                      dense: true,
                      title: Text(titleOf(e)),
                      subtitle: subtitleOf == null
                          ? null
                          : Text(subtitleOf!(e)),
                    );
                  },
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Small helper for a "N mục" trailing count.
Widget countBadge(BuildContext context, int n) => Text(
  '$n',
  style: context.texts.labelLarge?.copyWith(color: context.colors.primary),
);
