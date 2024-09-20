import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/components/transaction_list.dart';
import 'package:expensed_web_app/components/spending_by_person.dart';
import 'package:expensed_web_app/components/spending_per_category.dart';
import 'package:expensed_web_app/components/expense_summary.dart';
import 'package:expensed_web_app/components/add_expense_panel.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';
import 'package:expensed_web_app/components/filter_bottom_sheet.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  bool _showAddExpensePanel = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAddExpensePanel() {
    setState(() {
      _showAddExpensePanel = !_showAddExpensePanel;
    });
    if (_showAddExpensePanel) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor));
        }

        if (expenseProvider.error != null) {
          return Center(
              child: Text(expenseProvider.error!,
                  style: Theme.of(context).textTheme.bodyLarge));
        }

        List<Expense> filteredExpenses = expenseProvider.getFilteredExpenses();
        List<Expense> allFilteredExpenses =
            expenseProvider.getAllFilteredExpenses();

        double currentWeekTotal = _calculateCurrentWeekTotal(filteredExpenses);
        double currentMonthTotal =
            _calculateCurrentMonthTotal(filteredExpenses);
        double averageWeeklyTotal =
            _calculateAverageWeeklyTotal(allFilteredExpenses);
        double averageMonthlyTotal =
            _calculateAverageMonthlyTotal(allFilteredExpenses);
        double selectedDateRangeTotal =
            _calculateSelectedDateRangeTotal(filteredExpenses);

        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  // Right column (lowest z-index)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 350,
                    child: Container(
                      height: constraints.maxHeight,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildElevatedContainer(
                              child: ExpenseSummary(
                                currentWeekTotal: currentWeekTotal,
                                currentMonthTotal: currentMonthTotal,
                                selectedDateRangeTotal: selectedDateRangeTotal,
                                startDate: expenseProvider.startDate,
                                endDate: expenseProvider.endDate,
                                averageWeeklyTotal: averageWeeklyTotal,
                                averageMonthlyTotal: averageMonthlyTotal,
                              ),
                            ),
                            SizedBox(height: 16),
                            buildElevatedContainer(
                              child: SpendingByPerson(
                                filteredExpenses: filteredExpenses,
                              ),
                            ),
                            SizedBox(height: 16),
                            buildElevatedContainer(
                              child: SpendingPerCategory(
                                filteredExpenses: filteredExpenses,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Add expense panel (middle z-index)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: 0,
                        bottom: 0,
                        right: _slideAnimation.value.dx * 400,
                        width: 400,
                        child: buildElevatedContainer(
                          backgroundColor: Colors.white,
                          child: AddExpensePanel(
                            expenseProvider: expenseProvider,
                            onClose: _toggleAddExpensePanel,
                          ),
                        ),
                      );
                    },
                  ),
                  // Transaction list (highest z-index)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 366, // Right column width + padding
                    child: Stack(
                      children: [
                        buildElevatedContainer(
                          child: TransactionList(
                            expenses: filteredExpenses,
                            onSearch: expenseProvider.setSearchQuery,
                            showFilterBottomSheet: () =>
                                showFilterBottomSheet(context, expenseProvider),
                            selectedCategories:
                                expenseProvider.selectedCategories,
                            selectedPersons: expenseProvider.selectedPersons,
                            startDate: expenseProvider.startDate,
                            endDate: expenseProvider.endDate,
                            searchQuery: expenseProvider.searchQuery,
                            expenseProvider: expenseProvider,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: FloatingActionButton(
                            onPressed: _toggleAddExpensePanel,
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _calculateCurrentWeekTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return expenses
        .where((expense) =>
            expense.dateTime.isAfter(weekStart.subtract(Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateCurrentMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return expenses
        .where((expense) =>
            expense.dateTime.isAfter(monthStart.subtract(Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateSelectedDateRangeTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateAverageWeeklyTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    final oldestExpense =
        expenses.reduce((a, b) => a.dateTime.isBefore(b.dateTime) ? a : b);
    final totalWeeks =
        DateTime.now().difference(oldestExpense.dateTime).inDays / 7;
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return totalAmount / totalWeeks;
  }

  double _calculateAverageMonthlyTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    final oldestExpense =
        expenses.reduce((a, b) => a.dateTime.isBefore(b.dateTime) ? a : b);
    final totalMonths =
        (DateTime.now().year - oldestExpense.dateTime.year) * 12 +
            (DateTime.now().month - oldestExpense.dateTime.month) +
            1;
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return totalAmount / totalMonths;
  }
}
