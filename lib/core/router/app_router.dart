import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/warehouse_receipt/presentation/view/receipt_detail_page.dart';
import '../../features/warehouse_receipt/presentation/view/receipt_form_page.dart';
import '../../features/warehouse_receipt/presentation/view/receipt_list_page.dart';
import 'app_route.dart';

/// Application router. A single [GoRouter] instance is created once and exposed
/// to `MaterialApp.router`. Each page provides its own BLoC from the service
/// locator.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.home.path,
    debugLogDiagnostics: true,
    routes: [
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
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
}
