import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';

class GoalsList extends StatelessWidget {
  final List<Goal> goals;
  final Function(Goal) onGoalSelected;

  const GoalsList({
    Key? key,
    required this.goals,
    required this.onGoalSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);

    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final currentSpent = goalProvider.getGoalSpending(goal.category.id);
        final progress = currentSpent / goal.monthlyBudget;
        final entryCount = goalProvider.getMonthlyEntryCount(goal.category.id);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          child: buildElevatedContainer(
            child: InkWell(
              onTap: () => onGoalSelected(goal),
              child: Container(
                height: 70, // Increased height to accommodate subheader
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getProgressColor(progress),
                      Colors.white,
                    ],
                    stops: [progress.clamp(0.0, 1.0), progress.clamp(0.0, 1.0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: goal.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          goal.category.icon,
                          color: goal.category.color,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              goal.category.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '$entryCount entries this month',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${currentSpent.toStringAsFixed(0)} / \$${goal.monthlyBudget.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(progress),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return Colors.green.withOpacity(0.2);
    } else if (progress < 0.75) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.red.withOpacity(0.2);
    }
  }

  Color _getTextColor(double progress) {
    if (progress < 0.5) {
      return Colors.green;
    } else if (progress < 0.75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
