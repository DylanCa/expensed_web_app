import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';

class TestData {
  static final List<Category> categories = [
    Category(id: '1', name: 'Groceries', color: Colors.green),
    Category(id: '2', name: 'Food', color: Colors.red),
    Category(id: '3', name: 'Transportation', color: Colors.purple),
    Category(id: '4', name: 'Entertainment', color: Colors.teal),
    Category(id: '5', name: 'Health', color: Colors.indigo),
    Category(id: '6', name: 'Education', color: Colors.brown),
    Category(id: '7', name: 'Shopping', color: Colors.cyan),
  ];

  static final List<Person> persons = [
    Person(id: '1', name: 'Alice', color: Colors.blue),
    Person(id: '2', name: 'Bob', color: Colors.orange),
    Person(id: '3', name: 'Charlie', color: Colors.pink),
  ];

  static Category getCategoryById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => Category(id: '0', name: 'Unknown', color: Colors.grey),
    );
  }

  static Person getPersonById(String id) {
    return persons.firstWhere(
      (person) => person.id == id,
      orElse: () => Person(id: '0', name: 'Unknown', color: Colors.grey),
    );
  }
}
