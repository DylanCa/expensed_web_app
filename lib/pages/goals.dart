import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/components/goals_list.dart';
import 'package:expensed_web_app/components/goal_details.dart';
import 'package:expensed_web_app/components/add_goal_panel.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';

class Goals extends StatefulWidget {
  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> with SingleTickerProviderStateMixin {
  Goal? _selectedGoal;
  bool _showAddPanel = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAddPanel() {
    setState(() {
      _showAddPanel = !_showAddPanel;
    });
    if (_showAddPanel) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        return Row(
          children: [
            SizedBox(
              width: 400, // Fixed width for the goals list
              child: Stack(
                children: [
                  buildElevatedContainer(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: GoalsList(
                      onGoalSelected: (goal) {
                        setState(() {
                          _selectedGoal = goal;
                        });
                      },
                    ),
                    ),
                  ),
                  if (_showAddPanel)
                    SlideTransition(
                      position: _slideAnimation,
                      child: AddGoalPanel(
                        onClose: _toggleAddPanel,
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: _toggleAddPanel,
                        child: Icon(_showAddPanel ? Icons.close : Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                color:
                    Colors.transparent, // Set background color to transparent
                child: SizedBox(
                  width: 600, // Fixed width for the goal details
                  child: buildElevatedContainer(
                    backgroundColor: _selectedGoal != null
                        ? Colors.transparent
                        : Colors.white,
                    child: _selectedGoal != null
                        ? GoalDetails(goal: _selectedGoal!)
                        : Center(child: Text('Select a goal to view details')),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
