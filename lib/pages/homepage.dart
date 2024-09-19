import 'package:expensed_web_app/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
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

  final List<String> _titles = [
    'Dashboard',
    'Transactions',
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
                child: Column(
                  children: [
                    AppBar(
                      title: Text(_titles[selectedIndex]),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () {
                            // Add notification functionality here
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.account_circle),
                          offset: Offset(0, 56),
                          onSelected: (String value) {
                            switch (value) {
                              case 'profile':
                                // Handle profile action
                                print('Profile selected');
                                break;
                              case 'logout':
                                // Handle logout action
                                print('Logout selected');
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              enabled: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('John Doe',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('john.doe@example.com',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'profile',
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Profile'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.exit_to_app),
                                title: Text('Logout'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: _pages[selectedIndex],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
