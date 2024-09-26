import 'package:flutter/foundation.dart' hide Category;
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/data/test_data.dart';

class GoalProvider with ChangeNotifier {
  Map<String, Goal> _goals = {}; // Using category ID as key
  List<Expense> _expenses = [];
  List<Category> _categories = [];

  GoalProvider() {
    // Initialize with test data
    _categories = List.from(TestData.categories);
    for (var goal in TestData.goals) {
      _goals[goal.category.id] = goal;
    }
  }

  void updateExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  List<Goal> get goals => _goals.values.toList();
  List<Category> get categories => _categories;

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void setGoal(Category category, double monthlyBudget) {
    _goals[category.id] = Goal(
      category: category,
      monthlyBudget: monthlyBudget,
    );
    if (!_categories.contains(category)) {
      addCategory(category);
    }
    notifyListeners();
  }

  double getGoalSpending(String categoryId) {
    final now = DateTime.now();
    return getGoalSpendingForMonth(categoryId, now);
  }

  double getGoalSpendingForMonth(String categoryId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return _expenses
        .where((expense) =>
            expense.category.id == categoryId &&
            expense.dateTime
                .isAfter(startOfMonth.subtract(Duration(days: 1))) &&
            expense.dateTime.isBefore(endOfMonth.add(Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  int getMonthlyEntryCount(String categoryId) {
    final now = DateTime.now();
    return getMonthlyEntryCountForMonth(categoryId, now);
  }

  int getMonthlyEntryCountForMonth(String categoryId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return _expenses
        .where((expense) =>
            expense.category.id == categoryId &&
            expense.dateTime
                .isAfter(startOfMonth.subtract(Duration(days: 1))) &&
            expense.dateTime.isBefore(endOfMonth.add(Duration(days: 1))))
        .length;
  }

  Goal? getGoalForCategory(String categoryId) {
    return _goals[categoryId];
  }

  List<Expense> getExpensesForCategory(String categoryId) {
    return _expenses
        .where((expense) => expense.category.id == categoryId)
        .toList();
  }

  List<Expense> getExpensesForCategoryAndMonth(
      String categoryId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return _expenses
        .where((expense) =>
            expense.category.id == categoryId &&
            expense.dateTime.isAfter(startOfMonth) &&
            expense.dateTime.isBefore(endOfMonth.add(Duration(days: 1))))
        .toList();
  }

  double getAverageExpenseForPersonAndCategory(
      String personId, String categoryId, DateTime upToMonth) {
    final relevantExpenses = _expenses.where((expense) =>
        expense.paidBy.id == personId &&
        expense.category.id == categoryId &&
        expense.dateTime.isBefore(upToMonth.add(Duration(days: 1))));

    if (relevantExpenses.isEmpty) return 0.0;

    final totalAmount =
        relevantExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final firstExpenseDate = relevantExpenses
        .map((e) => e.dateTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final monthsDifference = (upToMonth.year - firstExpenseDate.year) * 12 +
        upToMonth.month -
        firstExpenseDate.month +
        1;

    return totalAmount / monthsDifference;
  }

  DateTime getOldestMonthWithData() {
    if (_expenses.isEmpty) {
      return DateTime.now();
    }
    return _expenses
        .map((e) => DateTime(e.dateTime.year, e.dateTime.month, 1))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  // Add more methods as needed
}
