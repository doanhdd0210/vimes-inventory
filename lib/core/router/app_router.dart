import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/master_data/presentation/master_data_hub_page.dart';
import '../../features/stock/presentation/stock_list_page.dart';
import '../../features/warehouse_receipt/presentation/view/receipt_detail_page.dart';
import '../../features/warehouse_receipt/presentation/view/receipt_form_page.dart';
import '../../features/warehouse_receipt/presentation/view/receipt_list_page.dart';
import '../di/injection_container.dart';
import 'app_route.dart';
import 'go_router_refresh_stream.dart';

/// Application router. Redirects to `/login` until authenticated; each page
/// pulls its own BLoC from the service locator.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    redirect: (context, state) {
      final status = sl<AuthCubit>().state.status;
      final loggingIn = state.matchedLocation == AppRoute.login.path;

      if (status == AuthStatus.unknown) return null;
      if (status == AuthStatus.unauthenticated) {
        return loggingIn ? null : AppRoute.login.path;
      }
      return loggingIn ? AppRoute.home.path : null;
    },
    routes: [
      GoRoute(
        name: AppRoute.login.name,
        path: AppRoute.login.path,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: AppRoute.home.name,
        path: AppRoute.home.path,
        builder: (context, state) => const ReceiptListPage(),
        routes: [
          GoRoute(
            name: AppRoute.receiptForm.name,
            path: AppRoute.receiptForm.path,
            builder: (context, state) => const ReceiptFormPage(),
          ),
          GoRoute(
            name: AppRoute.receiptDetail.name,
            path: AppRoute.receiptDetail.path,
            builder: (context, state) =>
                ReceiptDetailPage(receiptId: state.pathParameters['id']!),
          ),
          GoRoute(
            name: AppRoute.masterData.name,
            path: AppRoute.masterData.path,
            builder: (context, state) => const MasterDataHubPage(),
          ),
          GoRoute(
            name: AppRoute.stock.name,
            path: AppRoute.stock.path,
            builder: (context, state) => const StockListPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}
