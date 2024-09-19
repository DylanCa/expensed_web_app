import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
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
