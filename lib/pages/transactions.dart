import 'package:expensed_web_app/components/expense_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/components/transaction_list.dart';
import 'package:expensed_web_app/components/spending_by_person.dart';
import 'package:expensed_web_app/components/spending_per_category.dart';
import 'package:expensed_web_app/components/expense_summary.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  bool _showExpensePanel = false;
  bool _isFilterMode = false;
  Expense? _selectedExpense;
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
      begin: Offset(-1.0, 0.0),
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

  void _toggleExpensePanel({Expense? expense, bool isFilterMode = false}) {
    setState(() {
      _showExpensePanel = !_showExpensePanel;
      _selectedExpense = _showExpensePanel ? expense : null;
      _isFilterMode = isFilterMode;
    });
    if (_showExpensePanel) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        print("Building Transactions widget");
        print("Is loading: ${expenseProvider.isLoading}");
        print("Error: ${expenseProvider.error}");
        print(
            "Filtered expenses count: ${expenseProvider.getFilteredExpenses().length}");

        if (expenseProvider.isLoading) {
          return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor));
        }

        if (expenseProvider.error != null) {
          return Center(
              child: Text("Error: ${expenseProvider.error}",
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
                  // Expense panel (middle z-index)
                  if (_showExpensePanel)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: 400,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: buildElevatedContainer(
                          backgroundColor: Colors.white,
                          child: ExpensePanel(
                            expenseProvider: expenseProvider,
                            onClose: () => _toggleExpensePanel(),
                            expenseToEdit: _selectedExpense,
                            isFilterMode: _isFilterMode,
                          ),
                        ),
                      ),
                    ),
                  // Transaction list (highest z-index)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 366, // Right column width + padding
                    child: buildElevatedContainer(
                      child: TransactionList(
                        expenses: filteredExpenses,
                        onSearch: expenseProvider.setSearchQuery,
                        showFilterPanel: () =>
                            _toggleExpensePanel(isFilterMode: true),
                        selectedCategories: expenseProvider.selectedCategories,
                        selectedPersons: expenseProvider.selectedPersons,
                        startDate: expenseProvider.startDate,
                        endDate: expenseProvider.endDate,
                        searchQuery: expenseProvider.searchQuery,
                        expenseProvider: expenseProvider,
                        onExpenseSelected: (expense) =>
                            _toggleExpensePanel(expense: expense),
                        selectedExpense: _selectedExpense,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 382, // Right column width + padding + 16
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: () => _toggleExpensePanel(),
                      child: Icon(Icons.add),
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
