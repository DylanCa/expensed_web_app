import 'dart:async';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:flutter/material.dart';

class ExpenseRepository {
  final List<Expense> _expenses = [
    // 50 test expenses spread between today and 2 weeks ago
    Expense(
      id: '1',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 2)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 85.50,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '2',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 5)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 45.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '3',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 8)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 40.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '4',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 1)),
      shopName: "Cinema",
      category: Category(id: '4', name: 'Entertainment', color: Colors.teal),
      amount: 30.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '5',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 6)),
      shopName: "Pharmacy",
      category: Category(id: '5', name: 'Health', color: Colors.indigo),
      amount: 25.75,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '6',
      dateTime: DateTime.now().subtract(Duration(days: 5, hours: 3)),
      shopName: "Bookstore",
      category: Category(id: '6', name: 'Education', color: Colors.brown),
      amount: 50.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '7',
      dateTime: DateTime.now().subtract(Duration(days: 6, hours: 7)),
      shopName: "Clothing Store",
      category: Category(id: '7', name: 'Shopping', color: Colors.cyan),
      amount: 120.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '8',
      dateTime: DateTime.now().subtract(Duration(days: 7, hours: 4)),
      shopName: "Electronics Store",
      category: Category(id: '8', name: 'Shopping', color: Colors.cyan),
      amount: 299.99,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '9',
      dateTime: DateTime.now().subtract(Duration(days: 8, hours: 9)),
      shopName: "Gym",
      category: Category(id: '9', name: 'Health', color: Colors.indigo),
      amount: 60.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '10',
      dateTime: DateTime.now().subtract(Duration(days: 9, hours: 2)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 75.25,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '11',
      dateTime: DateTime.now().subtract(Duration(days: 10, hours: 5)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 55.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '12',
      dateTime: DateTime.now().subtract(Duration(days: 11, hours: 8)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 35.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '13',
      dateTime: DateTime.now().subtract(Duration(days: 12, hours: 1)),
      shopName: "Movie Theater",
      category: Category(id: '4', name: 'Entertainment', color: Colors.teal),
      amount: 28.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '14',
      dateTime: DateTime.now().subtract(Duration(days: 13, hours: 6)),
      shopName: "Pharmacy",
      category: Category(id: '5', name: 'Health', color: Colors.indigo),
      amount: 15.50,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '15',
      dateTime: DateTime.now().subtract(Duration(days: 14, hours: 3)),
      shopName: "Bookstore",
      category: Category(id: '6', name: 'Education', color: Colors.brown),
      amount: 40.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '16',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 4)),
      shopName: "Coffee Shop",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 5.75,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '17',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 7)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 65.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '18',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 10)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 40.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '19',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 3)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 45.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '20',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 8)),
      shopName: "Clothing Store",
      category: Category(id: '7', name: 'Shopping', color: Colors.cyan),
      amount: 89.99,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '21',
      dateTime: DateTime.now().subtract(Duration(days: 5, hours: 5)),
      shopName: "Pharmacy",
      category: Category(id: '5', name: 'Health', color: Colors.indigo),
      amount: 22.50,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '22',
      dateTime: DateTime.now().subtract(Duration(days: 6, hours: 9)),
      shopName: "Bookstore",
      category: Category(id: '6', name: 'Education', color: Colors.brown),
      amount: 35.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '23',
      dateTime: DateTime.now().subtract(Duration(days: 7, hours: 2)),
      shopName: "Electronics Store",
      category: Category(id: '8', name: 'Shopping', color: Colors.cyan),
      amount: 199.99,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '24',
      dateTime: DateTime.now().subtract(Duration(days: 8, hours: 7)),
      shopName: "Gym",
      category: Category(id: '9', name: 'Health', color: Colors.indigo),
      amount: 55.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '25',
      dateTime: DateTime.now().subtract(Duration(days: 9, hours: 4)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 70.25,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '26',
      dateTime: DateTime.now().subtract(Duration(days: 10, hours: 6)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 50.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '27',
      dateTime: DateTime.now().subtract(Duration(days: 11, hours: 1)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 38.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '28',
      dateTime: DateTime.now().subtract(Duration(days: 12, hours: 8)),
      shopName: "Movie Theater",
      category: Category(id: '4', name: 'Entertainment', color: Colors.teal),
      amount: 32.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '29',
      dateTime: DateTime.now().subtract(Duration(days: 13, hours: 3)),
      shopName: "Pharmacy",
      category: Category(id: '5', name: 'Health', color: Colors.indigo),
      amount: 18.75,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '30',
      dateTime: DateTime.now().subtract(Duration(days: 14, hours: 5)),
      shopName: "Bookstore",
      category: Category(id: '6', name: 'Education', color: Colors.brown),
      amount: 45.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '31',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 6)),
      shopName: "Coffee Shop",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 6.25,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '32',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 9)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 80.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '33',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 2)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 42.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '34',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 7)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 47.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '35',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 4)),
      shopName: "Clothing Store",
      category: Category(id: '7', name: 'Shopping', color: Colors.cyan),
      amount: 95.99,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '36',
      dateTime: DateTime.now().subtract(Duration(days: 5, hours: 8)),
      shopName: "Pharmacy",
      category: Category(id: '5', name: 'Health', color: Colors.indigo),
      amount: 28.50,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '37',
      dateTime: DateTime.now().subtract(Duration(days: 6, hours: 1)),
      shopName: "Bookstore",
      category: Category(id: '6', name: 'Education', color: Colors.brown),
      amount: 38.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '38',
      dateTime: DateTime.now().subtract(Duration(days: 7, hours: 6)),
      shopName: "Electronics Store",
      category: Category(id: '8', name: 'Shopping', color: Colors.cyan),
      amount: 249.99,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '39',
      dateTime: DateTime.now().subtract(Duration(days: 8, hours: 3)),
      shopName: "Gym",
      category: Category(id: '9', name: 'Health', color: Colors.indigo),
      amount: 58.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '40',
      dateTime: DateTime.now().subtract(Duration(days: 9, hours: 9)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 72.50,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '41',
      dateTime: DateTime.now().subtract(Duration(days: 10, hours: 2)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 52.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '42',
      dateTime: DateTime.now().subtract(Duration(days: 11, hours: 7)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 39.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '43',
      dateTime: DateTime.now().subtract(Duration(days: 12, hours: 4)),
      shopName: "Movie Theater",
      category: Category(id: '4', name: 'Entertainment', color: Colors.teal),
      amount: 34.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '44',
      dateTime: DateTime.now().subtract(Duration(days: 13, hours: 8)),
      shopName: "Pharmacy",
      category: Category(id: '5', name: 'Health', color: Colors.indigo),
      amount: 20.25,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '45',
      dateTime: DateTime.now().subtract(Duration(days: 14, hours: 1)),
      shopName: "Bookstore",
      category: Category(id: '6', name: 'Education', color: Colors.brown),
      amount: 47.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '46',
      dateTime: DateTime.now().subtract(Duration(days: 0, hours: 8)),
      shopName: "Coffee Shop",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 7.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '47',
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 3)),
      shopName: "Grocery Store",
      category: Category(id: '1', name: 'Groceries', color: Colors.green),
      amount: 82.00,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
    ),
    Expense(
      id: '48',
      dateTime: DateTime.now().subtract(Duration(days: 2, hours: 6)),
      shopName: "Restaurant",
      category: Category(id: '2', name: 'Food', color: Colors.red),
      amount: 44.00,
      paidBy: Person(id: '3', name: 'Charlie', color: Colors.pink),
    ),
    Expense(
      id: '49',
      dateTime: DateTime.now().subtract(Duration(days: 3, hours: 9)),
      shopName: "Gas Station",
      category: Category(id: '3', name: 'Transportation', color: Colors.purple),
      amount: 48.00,
      paidBy: Person(id: '1', name: 'Alice', color: Colors.blue),
    ),
    Expense(
      id: '50',
      dateTime: DateTime.now().subtract(Duration(days: 4, hours: 2)),
      shopName: "Clothing Store",
      category: Category(id: '7', name: 'Shopping', color: Colors.cyan),
      amount: 99.99,
      paidBy: Person(id: '2', name: 'Bob', color: Colors.orange),
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
