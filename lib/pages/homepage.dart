import 'package:expensed_web_app/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:go_router/go_router.dart'; // Add this import
import 'package:expensed_web_app/providers/expense_provider.dart'; // Add this import
import 'dashboard.dart';

class Homepage extends StatefulWidget {
  final int initialIndex;

  Homepage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    Dashboard(),
    Transactions(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (expenseProvider.error != null) {
          return Scaffold(
            body: Center(child: Text(expenseProvider.error!)),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                labelType: NavigationRailLabelType.selected,
                groupAlignment: 0.0,
                minWidth: 100,
                minExtendedWidth: 200,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.trending_up),
                    label: Text('Transactions'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  if (value == 0) {
                    context.go('/dashboard');
                  } else if (value == 1) {
                    context.go('/transactions');
                  }
                },
              ),
              VerticalDivider(thickness: 2, width: 2),
              Expanded(
                child: _pages[selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }
}
