import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensed_web_app/components/goals_list.dart';
import 'package:expensed_web_app/components/goal_details.dart';
import 'package:expensed_web_app/components/add_goal_panel.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class Goals extends StatefulWidget {
  final String? categoryId;

  Goals({super.key, this.categoryId});

  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> with SingleTickerProviderStateMixin {
  Goal? _selectedGoal;
  bool _showAddPanel = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  DateTime _selectedMonth = DateTime.now();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId != null) {
        final goalProvider = Provider.of<GoalProvider>(context, listen: false);
        final goal = goalProvider.goals
            .firstWhere((goal) => goal.category.id == widget.categoryId);
        setState(() {
          _selectedGoal = goal;
        });
      }
    });
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

  void _selectPreviousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _selectNextMonth() {
    final nextMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime.now()) ||
        nextMonth.month == DateTime.now().month) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  void _resetToCurrentMonth() {
    setState(() {
      _selectedMonth = DateTime.now();
    });
  }

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final currentMonth =
            DateTime(DateTime.now().year, DateTime.now().month);
        final isCurrentMonth = _selectedMonth.year == currentMonth.year &&
            _selectedMonth.month == currentMonth.month;

        return Row(
          children: [
            SizedBox(
              width: 400,
              child: Stack(
                children: [
                  buildElevatedContainer(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios),
                                  onPressed: _selectPreviousMonth,
                                ),
                                GestureDetector(
                                  onTap: _resetToCurrentMonth,
                                  child: Text(
                                    DateFormat('MMMM yyyy')
                                        .format(_selectedMonth),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios),
                                  onPressed:
                                      isCurrentMonth ? null : _selectNextMonth,
                                  color: isCurrentMonth ? Colors.grey : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: GoalsList(
                              onGoalSelected: (goal) {
                                setState(() {
                                  _selectedGoal = goal;
                                });
                              },
                              selectedMonth: _selectedMonth,
                            ),
                          ),
                        ],
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
                        ? GoalDetails(
                            goal: _selectedGoal!,
                            selectedMonth: _selectedMonth,
                            onMonthSelected: _onMonthSelected)
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
