import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/goal.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:expensed_web_app/components/current_month_transactions.dart';
import 'package:expensed_web_app/components/monthly_average_graph.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

class GoalDetails extends StatelessWidget {
  final Goal goal;

  const GoalDetails({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final currentSpent = goalProvider.getGoalSpending(goal.category.id);
    final expenses = goalProvider.getExpensesForCategory(goal.category.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200, // Fixed height for the graph
          child: ClipRect(
            child: MonthlyAverageGraph(expenses: expenses, goal: goal),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.category.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  _buildSummaryCard(context, currentSpent),
                  SizedBox(height: 16),
                  _buildTransactionsCard(context, expenses),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, double currentSpent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Target: \$${goal.monthlyBudget.toStringAsFixed(2)}'),
            Text('Current: \$${currentSpent.toStringAsFixed(2)}'),
            Text(
                'Remaining: \$${(goal.monthlyBudget - currentSpent).toStringAsFixed(2)}'),
            Text('Days remaining: ${_getRemainingDays()}'),
            LinearProgressIndicator(
              value: currentSpent / goal.monthlyBudget,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                currentSpent > goal.monthlyBudget ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard(BuildContext context, List<Expense> expenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Month Transactions',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            CurrentMonthTransactions(expenses: expenses),
          ],
        ),
      ),
    );
  }

  int _getRemainingDays() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(now).inDays + 1;
  }
}
