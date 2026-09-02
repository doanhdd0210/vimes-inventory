import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/sample/presentation/view/sample_detail_page.dart';
import '../../features/sample/presentation/view/sample_page.dart';
import '../../features/sample/presentation/viewmodel/sample_bloc.dart';
import '../di/injection_container.dart';
import 'app_route.dart';

/// Application router. A single [GoRouter] instance is created once and exposed
/// to `MaterialApp.router`.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: AppRoute.home.name,
        path: AppRoute.home.path,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SampleBloc>()..add(const SampleItemsRequested()),
          child: const SamplePage(),
        ),
        routes: [
          GoRoute(
            name: AppRoute.sampleDetail.name,
            path: AppRoute.sampleDetail.path,
            builder: (context, state) =>
                SampleDetailPage(itemId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}
