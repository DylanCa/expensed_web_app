import 'package:flutter/material.dart';

class Person {
  final String id;
  final String name;
  final Color color;

  Person({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }
}
