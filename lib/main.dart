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
        primarySwatch: MaterialColor(0xFF9FA8DA, {
          50: Color(0xFFEEF0F9),
          100: Color(0xFFD4DAF0),
          200: Color(0xFFB8C1E6),
          300: Color(0xFF9BA8DC),
          400: Color(0xFF8695D5),
          500: Color(0xFF7182CE),
          600: Color(0xFF697AC9),
          700: Color(0xFF5E6FC2),
          800: Color(0xFF5465BC),
          900: Color(0xFF4252B0),
        }),
        scaffoldBackgroundColor: Color(0xFFF3F4FB),
        cardColor: Colors.white,
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5)),
          displayMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF3F51B5)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF3F51B5)),
        ),
        iconTheme: IconThemeData(color: Color(0xFF7986CB)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF7986CB),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

