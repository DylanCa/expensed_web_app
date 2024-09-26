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
  late DateTime _selectedMonth;
  late DateTime _oldestMonth;

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

    // Initialize _oldestMonth and _selectedMonth
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    _oldestMonth = goalProvider.getOldestMonthWithData();
    _selectedMonth = DateTime.now();

    if (widget.categoryId != null) {
      final goal = goalProvider.goals
          .firstWhere((goal) => goal.category.id == widget.categoryId);
      _selectedGoal = goal;
    }
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
    final previousMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    if (previousMonth.isAfter(_oldestMonth) ||
        previousMonth.isAtSameMomentAs(_oldestMonth)) {
      setState(() {
        _selectedMonth = previousMonth;
      });
    }
  }

  void _selectNextMonth() {
    final nextMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    if (nextMonth.isBefore(currentMonth) ||
        nextMonth.isAtSameMomentAs(currentMonth)) {
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
        final isOldestMonth = _selectedMonth.year == _oldestMonth.year &&
            _selectedMonth.month == _oldestMonth.month;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 400,
              child: buildElevatedContainer(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed:
                                isOldestMonth ? null : _selectPreviousMonth,
                            color: isOldestMonth ? Colors.grey : null,
                          ),
                          GestureDetector(
                            onTap: _resetToCurrentMonth,
                            child: Text(
                              DateFormat('MMMM yyyy').format(_selectedMonth),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: isCurrentMonth ? null : _selectNextMonth,
                            color: isCurrentMonth ? Colors.grey : null,
                          ),
                        ],
                      ),
                    ),
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
                    SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: _toggleAddPanel,
                      child: Icon(_showAddPanel ? Icons.close : Icons.add),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: buildElevatedContainer(
                backgroundColor:
                    _selectedGoal != null ? Colors.transparent : Colors.white,
                child: _selectedGoal != null
                    ? GoalDetails(
                        goal: _selectedGoal!,
                        selectedMonth: _selectedMonth,
                        onMonthSelected: _onMonthSelected)
                    : Center(child: Text('Select a goal to view details')),
              ),
            ),
            if (_showAddPanel)
              SlideTransition(
                position: _slideAnimation,
                child: SizedBox(
                  width: 400,
                  child: buildElevatedContainer(
                    child: AddGoalPanel(
                      onClose: _toggleAddPanel,
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
