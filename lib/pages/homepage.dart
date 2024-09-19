import 'package:expensed_web_app/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/models/alert.dart';
import 'package:intl/intl.dart';
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
                      title: Text(
                        _titles[selectedIndex],
                        style: TextStyle(fontSize: 22), // Increased font size
                      ),
                      toolbarHeight: 64, // Increased AppBar height
                      actions: [
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return PopupMenuButton<Alert>(
                              icon: Icon(Icons.notifications,
                                  size: 28), // Increased icon size
                              itemBuilder: (BuildContext context) {
                                return [
                                  ...expenseProvider.alerts.map((Alert alert) {
                                    return PopupMenuItem<Alert>(
                                      value: alert,
                                      child: ListTile(
                                        title: Text(alert.formattedAlert),
                                        subtitle: Text(
                                            DateFormat('MMM d, y HH:mm')
                                                .format(alert.dateTime)),
                                        trailing: IconButton(
                                          icon: Icon(Icons.close, size: 16),
                                          onPressed: () {
                                            expenseProvider
                                                .deleteAlert(alert.id);
                                            setState(
                                                () {}); // Rebuild the popup menu
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  if (expenseProvider.alerts.isEmpty)
                                    PopupMenuItem<Alert>(
                                      child: ListTile(
                                        title: Text('No alerts'),
                                      ),
                                    ),
                                ];
                              },
                              onSelected: (Alert alert) {
                                print('Alert clicked: ${alert.formattedAlert}');
                              },
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.account_circle,
                              size: 28), // Increased icon size
                          offset: Offset(
                              0, 64), // Adjusted offset for larger AppBar
                          onSelected: (String value) {
                            switch (value) {
                              case 'profile':
                                print('Profile selected');
                                break;
                              case 'logout':
                                print('Logout selected');
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              enabled: false,
                              child: ListTile(
                                leading: Icon(Icons.account_circle,
                                    size: 48), // Increased icon size
                                title: Text(
                                  'John Doe',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16, // Increased font size
                                  ),
                                ),
                                subtitle: Text(
                                  'john.doe@example.com',
                                  style: TextStyle(
                                      fontSize: 14), // Increased font size
                                ),
                              ),
                            ),
                            PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'profile',
                              child: ListTile(
                                leading: Icon(Icons.person,
                                    size: 24), // Increased icon size
                                title: Text('Profile',
                                    style: TextStyle(
                                        fontSize: 16)), // Increased font size
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.exit_to_app,
                                    size: 24), // Increased icon size
                                title: Text('Logout',
                                    style: TextStyle(
                                        fontSize: 16)), // Increased font size
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
