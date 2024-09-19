import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/pages/homepage.dart';
import 'package:expensed_web_app/pages/transactions.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final provider = ExpenseProvider();
          provider.loadExpenses(); // Load expenses when the app starts
          return provider;
        }),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: '/',
      routes: {
        '/': (context) => Homepage(),
        '/transactions': (context) => Transactions(),
      },
    );
  }
}

