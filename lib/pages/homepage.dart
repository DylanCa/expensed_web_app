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
  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    Dashboard(),
    Transactions(),
    // Add your other pages here
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

  final List<IconData> _outlinedIcons = [
    Icons.dashboard_outlined,
    Icons.trending_up_outlined,
    Icons.flag_outlined,
    Icons.home_outlined,
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWideLayout = constraints.maxWidth > 1400;
              final menuWidth = isWideLayout ? 175.0 : 75.0;

              return Row(
                children: [
                  Container(
                    width: menuWidth,
                    color: Colors.blue[50],
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.all(12.0), // Reduced padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 40, // Reduced icon size
                                color: Colors.blue,
                              ),
                              if (isWideLayout) SizedBox(width: 8),
                              if (isWideLayout)
                                Text(
                                  'Expensed',
                                  style: TextStyle(
                                    fontSize: 18, // Reduced font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < _titles.length; i++)
                                _buildNavItem(
                                  icon: _icons[i],
                                  outlinedIcon: _outlinedIcons[i],
                                  label: _titles[i],
                                  index: i,
                                  isWideLayout: isWideLayout,
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Divider(thickness: 1, height: 1),
                            _buildBottomNavItem(
                              icon: Icons.settings,
                              outlinedIcon: Icons.settings_outlined,
                              label: 'Settings',
                              onPressed: () {
                                // Handle settings button press
                              },
                              isWideLayout: isWideLayout,
                            ),
                            _buildBottomNavItem(
                              icon: Icons.account_circle,
                              outlinedIcon: Icons.account_circle_outlined,
                              label: 'Account',
                              onPressed: () {
                                // Handle account button press
                              },
                              isWideLayout: isWideLayout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _pages[selectedIndex],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData outlinedIcon,
    required String label,
    required int index,
    required bool isWideLayout,
  }) {
    final isSelected = selectedIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() {
        hoveredIndex = index;
      }),
      onExit: (_) => setState(() {
        hoveredIndex = null;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue[100]
              : hoveredIndex == index
                  ? Colors.blue[50]
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 60),
          ),
          onPressed: () {
            setState(() {
              selectedIndex = index;
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
          child: Row(
            mainAxisAlignment: isWideLayout
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Padding(
                padding: isWideLayout
                    ? const EdgeInsets.only(left: 16.0)
                    : EdgeInsets.zero,
                child: Icon(
                  isSelected ? icon : outlinedIcon,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              if (isWideLayout) SizedBox(width: 8),
              if (isWideLayout)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData outlinedIcon,
    required String label,
    required VoidCallback onPressed,
    required bool isWideLayout,
  }) {
    final isSelected = hoveredIndex == label.hashCode;
    return MouseRegion(
      onEnter: (_) => setState(() {
        hoveredIndex = label.hashCode;
      }),
      onExit: (_) => setState(() {
        hoveredIndex = null;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 60),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: isWideLayout
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Padding(
                padding: isWideLayout
                    ? const EdgeInsets.only(left: 16.0)
                    : EdgeInsets.zero,
                child: Icon(
                  isSelected ? icon : outlinedIcon,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              if (isWideLayout) SizedBox(width: 8),
              if (isWideLayout)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
