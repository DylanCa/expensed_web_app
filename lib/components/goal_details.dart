import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class GoalDetails extends StatelessWidget {
  final Goal goal;

  const GoalDetails({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final currentSpent = goalProvider.getGoalSpending(goal.category.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goal.category.name, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 16),
        Text('Target: \$${goal.monthlyBudget.toStringAsFixed(2)}'),
        Text('Current: \$${currentSpent.toStringAsFixed(2)}'),
        Text('Days remaining: ${_getRemainingDays()}'),
        // Add more details and possibly a progress indicator here
      ],
    );
  }

  int _getRemainingDays() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(now).inDays + 1;
  }
}
