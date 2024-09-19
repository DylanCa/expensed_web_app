import 'package:expensed_web_app/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:expensed_web_app/providers/expense_provider.dart'; // Add this import
import 'dashboard.dart';

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var selectedIndex = 0;
  var currentPageName = 'Dashboard';

  var destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.trending_up),
      label: Text('Transactions'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.house),
      label: Text('My Household'),
    ),
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

        Widget page;
        switch (selectedIndex) {
          case 0:
            page = Dashboard();
            currentPageName = 'Dashboard';
            break;
          case 1:
            page = Transactions();
            currentPageName = 'Transactions';
            break;
          default:
            throw UnimplementedError('no widget for $selectedIndex');
        }

        return LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    leading: FloatingActionButton(
                      onPressed: () {},
                      elevation: 0,
                      child: Icon(Icons.golf_course),
                    ),
                    labelType: NavigationRailLabelType.selected,
                    groupAlignment: 0.0,
                    minWidth: 100,
                    minExtendedWidth: 200,
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                VerticalDivider(
                  thickness: 2,
                  width: 2,
                ),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(currentPageName),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            // Implement search functionality
                          },
                        ),
                        IconButton(onPressed: () {}, icon: Icon(Icons.person))
                      ],
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(2.0),
                        child: Divider(
                          thickness: 2,
                          height: 2,
                        ),
                      ),
                    ),
                    body: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }
}
