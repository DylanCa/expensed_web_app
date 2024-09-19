import 'dart:async';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/data/test_data.dart';

class ExpenseRepository {
  final List<Expense> _expenses = [
    Expense(
      id: '1',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 2)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 85.50,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '2',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 5)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 45.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '3',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 8)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 40.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '4',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 1)),
      shopName: "Cinema",
      category: TestData.getCategoryById('4'),
      amount: 30.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '5',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 6)),
      shopName: "Pharmacy",
      category: TestData.getCategoryById('5'),
      amount: 25.75,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '6',
      dateTime: DateTime.now().subtract(Duration(days: 5, hours: 3)),
      shopName: "Bookstore",
      category: TestData.getCategoryById('6'),
      amount: 50.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '7',
      dateTime: DateTime.now().subtract(Duration(days: 6, hours: 7)),
      shopName: "Clothing Store",
      category: TestData.getCategoryById('7'),
      amount: 120.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '8',
      dateTime: DateTime.now().subtract(Duration(days: 7, hours: 4)),
      shopName: "Electronics Store",
      category: TestData.getCategoryById('8'),
      amount: 299.99,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '9',
      dateTime: DateTime.now().subtract(Duration(days: 8, hours: 9)),
      shopName: "Gym",
      category: TestData.getCategoryById('9'),
      amount: 60.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '10',
      dateTime: DateTime.now().subtract(Duration(days: 9, hours: 2)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 75.25,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '11',
      dateTime: DateTime.now().subtract(Duration(days: 10, hours: 5)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 55.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '12',
      dateTime: DateTime.now().subtract(Duration(days: 11, hours: 8)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 35.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '13',
      dateTime: DateTime.now().subtract(Duration(days: 12, hours: 1)),
      shopName: "Movie Theater",
      category: TestData.getCategoryById('4'),
      amount: 28.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '14',
      dateTime: DateTime.now().subtract(Duration(days: 13, hours: 6)),
      shopName: "Pharmacy",
      category: TestData.getCategoryById('5'),
      amount: 15.50,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '15',
      dateTime: DateTime.now().subtract(Duration(days: 14, hours: 3)),
      shopName: "Bookstore",
      category: TestData.getCategoryById('6'),
      amount: 40.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '16',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 4)),
      shopName: "Coffee Shop",
      category: TestData.getCategoryById('2'),
      amount: 5.75,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '17',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 7)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 65.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '18',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 10)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 40.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '19',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 3)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 45.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '20',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 8)),
      shopName: "Clothing Store",
      category: TestData.getCategoryById('7'),
      amount: 89.99,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '21',
      dateTime: DateTime.now().subtract(Duration(days: 5, hours: 5)),
      shopName: "Pharmacy",
      category: TestData.getCategoryById('5'),
      amount: 22.50,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '22',
      dateTime: DateTime.now().subtract(Duration(days: 6, hours: 9)),
      shopName: "Bookstore",
      category: TestData.getCategoryById('6'),
      amount: 35.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '23',
      dateTime: DateTime.now().subtract(Duration(days: 7, hours: 2)),
      shopName: "Electronics Store",
      category: TestData.getCategoryById('8'),
      amount: 199.99,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '24',
      dateTime: DateTime.now().subtract(Duration(days: 8, hours: 7)),
      shopName: "Gym",
      category: TestData.getCategoryById('9'),
      amount: 55.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '25',
      dateTime: DateTime.now().subtract(Duration(days: 9, hours: 4)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 70.25,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '26',
      dateTime: DateTime.now().subtract(Duration(days: 10, hours: 6)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 50.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '27',
      dateTime: DateTime.now().subtract(Duration(days: 11, hours: 1)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 38.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '28',
      dateTime: DateTime.now().subtract(Duration(days: 12, hours: 8)),
      shopName: "Movie Theater",
      category: TestData.getCategoryById('4'),
      amount: 32.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '29',
      dateTime: DateTime.now().subtract(Duration(days: 13, hours: 3)),
      shopName: "Pharmacy",
      category: TestData.getCategoryById('5'),
      amount: 18.75,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '30',
      dateTime: DateTime.now().subtract(Duration(days: 14, hours: 5)),
      shopName: "Bookstore",
      category: TestData.getCategoryById('6'),
      amount: 45.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '31',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 6)),
      shopName: "Coffee Shop",
      category: TestData.getCategoryById('2'),
      amount: 6.25,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '32',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 9)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 80.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '33',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 2)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 42.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '34',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 7)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 47.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '35',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 4)),
      shopName: "Clothing Store",
      category: TestData.getCategoryById('7'),
      amount: 95.99,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '36',
      dateTime: DateTime.now().subtract(Duration(days: 5, hours: 8)),
      shopName: "Pharmacy",
      category: TestData.getCategoryById('5'),
      amount: 28.50,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '37',
      dateTime: DateTime.now().subtract(Duration(days: 6, hours: 1)),
      shopName: "Bookstore",
      category: TestData.getCategoryById('6'),
      amount: 38.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '38',
      dateTime: DateTime.now().subtract(Duration(days: 7, hours: 6)),
      shopName: "Electronics Store",
      category: TestData.getCategoryById('8'),
      amount: 249.99,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '39',
      dateTime: DateTime.now().subtract(Duration(days: 8, hours: 3)),
      shopName: "Gym",
      category: TestData.getCategoryById('9'),
      amount: 58.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '40',
      dateTime: DateTime.now().subtract(Duration(days: 9, hours: 9)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 72.50,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '41',
      dateTime: DateTime.now().subtract(Duration(days: 10, hours: 2)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 52.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '42',
      dateTime: DateTime.now().subtract(Duration(days: 11, hours: 7)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 39.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '43',
      dateTime: DateTime.now().subtract(Duration(days: 12, hours: 4)),
      shopName: "Movie Theater",
      category: TestData.getCategoryById('4'),
      amount: 34.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '44',
      dateTime: DateTime.now().subtract(Duration(days: 13, hours: 8)),
      shopName: "Pharmacy",
      category: TestData.getCategoryById('5'),
      amount: 20.25,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '45',
      dateTime: DateTime.now().subtract(Duration(days: 14, hours: 1)),
      shopName: "Bookstore",
      category: TestData.getCategoryById('6'),
      amount: 47.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '46',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 8)),
      shopName: "Coffee Shop",
      category: TestData.getCategoryById('2'),
      amount: 7.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '47',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 3)),
      shopName: "Grocery Store",
      category: TestData.getCategoryById('1'),
      amount: 82.00,
      paidBy: TestData.getPersonById('2'),
    ),
    Expense(
      id: '48',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 6)),
      shopName: "Restaurant",
      category: TestData.getCategoryById('2'),
      amount: 44.00,
      paidBy: TestData.getPersonById('3'),
    ),
    Expense(
      id: '49',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 9)),
      shopName: "Gas Station",
      category: TestData.getCategoryById('3'),
      amount: 48.00,
      paidBy: TestData.getPersonById('1'),
    ),
    Expense(
      id: '50',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 2)),
      shopName: "Clothing Store",
      category: TestData.getCategoryById('7'),
      amount: 99.99,
      paidBy: TestData.getPersonById('2'),
    ),
  ];

  Future<void> loadExpenses() async {
    // Simulating a delay
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> saveExpenses() async {
    // Simulating a delay
    await Future.delayed(Duration(seconds: 1));
  }

  Future<List<Expense>> getExpenses({int page = 0, int pageSize = 20}) async {
    // Simulating a delay
    await Future.delayed(Duration(milliseconds: 500));
    int start = page * pageSize;
    int end = (page + 1) * pageSize;
    if (end > _expenses.length) end = _expenses.length;
    return _expenses.sublist(start, end);
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await saveExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      await saveExpenses();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await saveExpenses();
  }
}
