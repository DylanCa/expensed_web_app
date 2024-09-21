import 'package:uuid/uuid.dart';
import 'package:expensed_web_app/models/category.dart';

class Goal {
  final String id;
  final Category category;
  final double monthlyBudget;

  Goal({
    String? id,
    required this.category,
    required this.monthlyBudget,
  }) : id = id ?? Uuid().v4();

  double get progress => currentSpent / monthlyBudget;

  bool get isExceeded => currentSpent > monthlyBudget;

  double get remainingBudget => monthlyBudget - currentSpent;

  // currentSpent will be calculated in the GoalProvider
  double get currentSpent => 0.0;

  // Add more methods or properties as needed
}
