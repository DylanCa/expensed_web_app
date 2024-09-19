import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/pages/homepage.dart';
import 'package:expensed_web_app/pages/dashboard.dart';
import 'package:expensed_web_app/pages/transactions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final provider = ExpenseProvider();
          provider.loadExpenses();
          return provider;
        }),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: Homepage(initialIndex: 0),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: Homepage(initialIndex: 0),
        ),
      ),
      GoRoute(
        path: '/transactions',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: Homepage(initialIndex: 1),
        ),
      ),
      GoRoute(
        path: '/goals',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: Homepage(initialIndex: 2),
        ),
      ),
      GoRoute(
        path: '/household',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: Homepage(initialIndex: 3),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      routerConfig: _router,
    );
  }
}

