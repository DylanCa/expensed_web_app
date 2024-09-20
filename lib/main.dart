import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/pages/homepage.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add a small delay
  await Future.delayed(Duration(milliseconds: 100));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpenseProvider>(create: (context) {
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
  MyApp({super.key});

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
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF3F51B5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF3F51B5),
            side: BorderSide(color: Color(0xFF7986CB)),
          ),
        ),
      ),
      routerConfig: _router,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const fixedWidth = 1600.0;
            const padding = 16.0;
            const minWidth = 1200.0;
            const minHeight = 800.0;
            final windowHeight = constraints.maxHeight;
            final windowWidth = constraints.maxWidth;

            final appWidth = math.max(
                minWidth, math.min(fixedWidth, windowWidth - 2 * padding));
            final appHeight = math.max(minHeight, windowHeight - 2 * padding);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Container(
                  width: math.max(windowWidth, minWidth + 2 * padding),
                  height: math.max(windowHeight, minHeight + 2 * padding),
                  padding: const EdgeInsets.all(padding),
                  child: Center(
                    child: Container(
                      width: appWidth,
                      height: appHeight,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Helper functions remain the same
double _lerp(double a, double b, double t) {
  return a + (b - a) * t;
}

double _smoothstep(double edge0, double edge1, double x) {
  x = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
  return x * x * (3 - 2 * x);
}

