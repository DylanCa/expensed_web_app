import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/models/expense.dart';

class TestData {
  static final List<Category> categories = [
    Category(
        id: '2188e2bf-b126-463e-a41e-b33421870d24',
        name: 'Groceries',
        color: Colors.green),
    Category(
        id: '1186e92d-7914-4a0a-9357-cdbb869e6d54',
        name: 'Dining',
        color: Colors.red),
    Category(
        id: 'ba4c46d3-b84e-44ab-a286-055c0de309aa',
        name: 'Transportation',
        color: Colors.purple),
    Category(
        id: 'a002a86b-8efd-4cc1-b331-9a3cf312bed6',
        name: 'Entertainment',
        color: Colors.teal),
    Category(
        id: 'b9c66dbb-51b1-4964-861b-fa22edeaa7c0',
        name: 'Health',
        color: Colors.indigo),
    Category(
        id: '3ca901e7-0435-42b4-a3a1-99a3a5f55884',
        name: 'Education',
        color: Colors.brown),
    Category(
        id: 'fb70af88-a1b2-4672-9124-b474de422b87',
        name: 'Shopping',
        color: Colors.cyan),
  ];

  static final List<Person> persons = [
    Person(
        id: 'acf909f7-3e69-4398-b76f-9d91c37339ab',
        name: 'Alice',
        color: Colors.blue),
    Person(
        id: '98f85943-acf4-4104-ae17-2ba5b73718ef',
        name: 'Bob',
        color: Colors.orange),
    Person(
        id: 'b869c082-c1e9-4cd5-ba6b-5f2d67a0f8be',
        name: 'Charlie',
        color: Colors.pink),
  ];

  static Future<List<Expense>> getTestExpenses() async {
    try {
      // Load the JSON file
      final String jsonString =
          await rootBundle.loadString('lib/data/expenses.json');
      if (jsonString.isEmpty) {
        throw Exception('The expenses.json file is empty');
      }
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> expensesJson = jsonMap['expenses'];

      if (expensesJson.isEmpty) {
        throw Exception('No expenses found in the JSON file');
      }

      // Convert JSON to List<Expense>
      List<Expense> expenses = expensesJson.map((json) {
        return Expense(
          id: json['id'],
          shopName: json['shopName'],
          amount: json['amount'].toDouble(),
          category: categories.firstWhere((c) => c.id == json['categoryId']),
          paidBy: persons.firstWhere((p) => p.id == json['paidById']),
          dateTime: DateTime.parse(json['dateTime']),
        );
      }).toList();

      // Sort expenses by date (most recent first)
      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return expenses;
    } catch (e) {
      print('Error loading test expenses: $e');
      return [];
    }
  }
}
