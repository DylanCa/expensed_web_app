import 'package:flutter/foundation.dart' hide Category;
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/data/test_data.dart';

class GoalProvider with ChangeNotifier {
  Map<String, Goal> _goals = {}; // Using category ID as key
  List<Expense> _expenses = [];

  GoalProvider() {
    // Initialize with test data
    for (var goal in TestData.goals) {
      _goals[goal.category.id] = goal;
    }
    // Load test expenses
    _loadTestExpenses();
  }

  void _loadTestExpenses() async {
    _expenses = await TestData.getTestExpenses();
    notifyListeners();
  }

  List<Goal> get goals => _goals.values.toList();

  void setGoal(Category category, double monthlyBudget) {
    _goals[category.id] = Goal(
      category: category,
      monthlyBudget: monthlyBudget,
    );
    notifyListeners();
  }

  double getGoalSpending(String categoryId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _expenses
        .where((expense) =>
            expense.category.id == categoryId &&
            expense.dateTime.isAfter(startOfMonth) &&
            expense.dateTime.isBefore(endOfMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  int getMonthlyEntryCount(String categoryId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _expenses
        .where((expense) =>
            expense.category.id == categoryId &&
            expense.dateTime.isAfter(startOfMonth) &&
            expense.dateTime.isBefore(endOfMonth))
        .length;
  }

  Goal? getGoalForCategory(String categoryId) {
    return _goals[categoryId];
  }

  // Add more methods as needed
}
