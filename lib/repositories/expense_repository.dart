import 'package:expensed_web_app/models/expense.dart';

class ExpenseRepository {
  List<Expense> _expenses = [];

  Future<void> loadExpenses() async {
    // In a real application, this method would fetch expenses from a database or API
    // For now, we'll just initialize it with an empty list
    _expenses = [];
  }

  Future<void> addExpense(Expense expense) async {
    // In a real application, this method would add the expense to a database or API
    _expenses.add(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    // In a real application, this method would update the expense in a database or API
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  Future<void> deleteExpense(String id) async {
    // In a real application, this method would delete the expense from a database or API
    _expenses.removeWhere((e) => e.id == id);
  }

  List<Expense> getExpenses() {
    return _expenses;
  }
}
