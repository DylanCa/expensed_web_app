import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/components/goals_list.dart';
import 'package:expensed_web_app/components/goal_details.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';

class Goals extends StatefulWidget {
  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  Goal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        return Row(
          children: [
            SizedBox(
              width: 400, // Fixed width for the goals list
              child: buildElevatedContainer(
                child: GoalsList(
                  goals: goalProvider.goals,
                  onGoalSelected: (goal) {
                    setState(() {
                      _selectedGoal = goal;
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                width: 600, // Fixed width for the goal details
                child: buildElevatedContainer(
                  child: _selectedGoal != null
                      ? GoalDetails(goal: _selectedGoal!)
                      : Center(child: Text('Select a goal to view details')),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
