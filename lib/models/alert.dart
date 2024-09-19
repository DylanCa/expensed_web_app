import 'package:flutter/foundation.dart';
import 'package:expensed_web_app/models/person.dart';
import 'package:expensed_web_app/models/expense.dart';

enum AlertAction { added, updated, deleted }

class Alert {
  final String id;
  final Person user;
  final AlertAction action;
  final Expense expense;
  final DateTime dateTime;

  Alert({
    required this.id,
    required this.user,
    required this.action,
    required this.expense,
    required this.dateTime,
  });

  String get actionString {
    switch (action) {
      case AlertAction.added:
        return 'added';
      case AlertAction.updated:
        return 'updated';
      case AlertAction.deleted:
        return 'deleted';
    }
  }

  String get formattedAlert {
    return '${user.name} $actionString ${expense.shopName} - ${expense.formattedAmount}';
  }
}
