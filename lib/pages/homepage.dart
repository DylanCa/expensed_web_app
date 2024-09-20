import 'package:expensed_web_app/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'dashboard.dart';

class Homepage extends StatefulWidget {
  final int initialIndex;

  Homepage({super.key, this.initialIndex = 0});

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
    Placeholder(), // Placeholder for Goals page
    Placeholder(), // Placeholder for Household page
  ];

  final List<String> _titles = [
    'Dashboard',
    'Transactions',
    'Goals',
    'Household',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.trending_up,
    Icons.flag,
    Icons.home,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor)),
          );
        }

        if (expenseProvider.error != null) {
          return Scaffold(
            body: Center(
                child: Text(expenseProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge)),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Row(
            children: [
              Container(
                width: 200,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Expensed',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (int i = 0; i < _titles.length; i++)
                            _buildNavItem(
                              icon: _icons[i],
                              label: _titles[i],
                              index: i,
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    _buildNavItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () {
                        // Handle settings
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.account_circle,
                      label: 'Account',
                      onTap: () {
                        // Handle account
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _pages[selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    int? index,
    VoidCallback? onTap,
  }) {
    final isSelected = index != null && selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      selected: isSelected,
      onTap: onTap ??
          () {
        setState(() {
              selectedIndex = index!;
        });
        switch (index) {
          case 0:
            context.go('/dashboard');
                break;
          case 1:
            context.go('/transactions');
                break;
          case 2:
            context.go('/goals');
                break;
          case 3:
            context.go('/household');
                break;
        }
          },
    );
  }
}
