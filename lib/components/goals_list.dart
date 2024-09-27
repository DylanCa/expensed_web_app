import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';
import 'package:go_router/go_router.dart';

class GoalsList extends StatefulWidget {
  final Function(Goal) onGoalSelected;
  final DateTime selectedMonth;

  const GoalsList({
    Key? key,
    required this.onGoalSelected,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  _GoalsListState createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  Goal? _hoveredGoal;
  Goal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final goals = goalProvider.goals;

        return ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final currentSpent = goalProvider.getGoalSpendingForMonth(
                goal.category.id, widget.selectedMonth);
            final progress = currentSpent / goal.monthlyBudget;
            final entryCount = goalProvider.getMonthlyEntryCountForMonth(
                goal.category.id, widget.selectedMonth);

            final isHovered = _hoveredGoal == goal;
            final isSelected = _selectedGoal == goal;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredGoal = goal),
                onExit: (_) => setState(() => _hoveredGoal = null),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey
                            .withOpacity(isHovered || isSelected ? 0.5 : 0.1),
                        spreadRadius: isHovered || isSelected ? 2 : 1,
                        blurRadius: isHovered || isSelected ? 6 : 3,
                        offset: Offset(0, isHovered || isSelected ? 3 : 1),
                      ),
                    ],
                  ),
                  child: buildElevatedContainer(
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedGoal = goal);
                        widget.onGoalSelected(goal);
                        context.go('/goals/${goal.category.id}');
                      },
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getProgressColor(progress),
                              Colors.white,
                            ],
                            stops: [
                              progress.clamp(0.0, 1.0),
                              progress.clamp(0.0, 1.0)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(2),
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
                                  borderRadius: BorderRadius.circular(10),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
                ),
              ),
            );
          },
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
